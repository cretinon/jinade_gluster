#!/bin/bash

_start_debug () {
    if [ $VERBOSE = "true" ]; then echo "start" $* ; fi
}

_end_debug () {
    if [ $VERBOSE = "true" ]; then echo "end" $* ; fi
}

_usage () {
    case $1 in
	*)
	    echo "create new gluster cluster   : ./`basename $0`" "-c"
	    echo "run                          : ./`basename $0`" "-r"
	    ;;
    esac
}

_aloneinpool () {
    gluster pool list 2>&1 > /tmp/pool
    NB_PEER=$(grep -i connected /tmp/pool | wc -l)
    if [ $NB_PEER -eq 2 ]; then return 0; else return 1; fi
}

_gluster_peer_probe () {
    _start_debug ${FUNCNAME[0]} $*

    _aloneinpool
    RETURN=$?
    while [ $RETURN -eq 1 ]; do
	if [ $VERBOSE = "true" ]; then echo "alone in pool" $* ; fi
	for IP in $(echo "10.2.0.10 10.2.0.11"); do
	    gluster peer probe $IP
	done
	_aloneinpool
	RETURN=$?
	sleep 5
    done
    
    _end_debug ${FUNCNAME[0]} $*
}

_novolumepresent () {
    gluster volume list 2>&1 > /tmp/volumes
    NB_DATASTORE=$(grep -i datastore /tmp/volumes | wc -l)
    if [ $NB_DATASTORE -eq 1 ]; then return 0; else return 1; fi
}
_gluster_volume_create () {
    _start_debug ${FUNCNAME[0]} $*

    _novolumepresent
    RETURN=$?
    while [ $RETURN -eq 1 ]; do
	if [ $VERBOSE = "true" ]; then echo "no volume" $* ; fi
	IP1="gluster-1"
	IP2="gluster-2"
	gluster --mode=script volume create datastore replica 2 $IP1:/data/datastore $IP2:/data/datastore
	gluster volume start datastore
	_novolumepresent
	RETURN=$?
	sleep 5
    done
    
    _end_debug ${FUNCNAME[0]} $*
}

_startswith() {
    _str="$1"
    _sub="$2"
    echo "$_str" | grep "^$_sub" >/dev/null 2>&1
}

_isdefined () {
    if [ -z ${1+x} ]; then return 1; else return 0; fi
}

_isnotdefined () {
    if [ -z ${1+x} ]; then return 0; else return 1; fi
}

_isbothdefined () {
    if _isdefined $1 && _isdefined $2 ; then return 0; else return 1; fi
}

_arenotbothdefined () {
    if _isdefined $1 && _isdefined $2 ; then return 1; else return 0; fi
}

_notatleastonedefined () {
    if _isdefined $1 || _isdefined $2 ; then return 1; else return 0; fi
}

_fileexist () {
    if [ -e $1 ]; then return 0; else return 1; fi
}

_filenotexist () {
    if [ -e $1 ]; then return 1; else return 0; fi
}

_process () {
    _start_debug ${FUNCNAME[0]} $*
    
    # Option strings
    SHORT=rcvt
    LONG=run,create,verbose,test,ip1:,ip2:

    # read the options
    OPTS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")

    if [ $? != 0 ] ; then _usage >&2 ; exit 1 ; fi

    eval set -- "$OPTS"

    # extract options and their arguments into variables.
    while true ; do
	case "$1" in
	    -r | --run)
		RUN="yes"
		ACTION="RUN"
		shift
		;;
	    -c | --create)
		CREATE="yes"
		ACTION="CREATE"
		shift
		;;
	    --ip1)
		IP1=$2
		shift 2
		;;
	    --ip2)
		IP2=$2
		shift 2
		;;
	    -v | --verbose )
		VERBOSE=true
		shift
		;;
	    -t | --test )
		shift
		;;
	    -- )
		shift
		break
		;;
	    *)
		_usage
		exit 1
		;;
	esac
    done
    
    _end_debug ${FUNCNAME[0]} $*
}

main() {
    _start_debug ${FUNCNAME[0]} $*
    
    [ -z "$1" ] && _usage && return
    if _startswith "$1" '-'; then _process "$@"; else "$@"; fi

    _end_debug ${FUNCNAME[0]} $*
}

# set initial values
VERBOSE=false

main "$@"

/usr/sbin/glusterd
_gluster_peer_probe
_gluster_volume_create
tail -f /var/log/glusterfs/etc-glusterfs-glusterd.vol.log

exit 0
