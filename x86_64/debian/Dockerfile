ARG ARCH=frommakefile
ARG DISTRIB=frommakefile
ARG DOCKERSRC=frommakefile
ARG USERNAME=frommakefile
#
FROM ${USERNAME}/${DOCKERSRC}:${DISTRIB}_${ARCH}
#
RUN apt-get update && apt-get -y -q install --no-install-recommends glusterfs-server && apt-get clean && rm -rf /var/cache/apt/* /var/lib/apt/lists/*

VOLUME ["/data", "/var/lib/glusterd"]
EXPOSE 111 111/udp 24007 24009 49152
CMD ["/usr/sbin/glusterd","-N"]
