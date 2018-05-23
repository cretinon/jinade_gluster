ARG ARCH=frommakefile
ARG DISTRIB=frommakefile
ARG DOCKERSRC=frommakefile
ARG USERNAME=frommakefile
#
FROM ${USERNAME}/${DOCKERSRC}:${DISTRIB}_${ARCH}
#
RUN apt-get update && apt-get -y -q install --no-install-recommends dnsutils procps net-tools lsof iputils-ping glusterfs-server && apt-get clean && rm -rf /var/cache/apt/* /var/lib/apt/lists/*

ADD entrypoint.sh /usr/local/entrypoint.sh
RUN chmod 755 /usr/local/entrypoint.sh

VOLUME ["/data", "/var/lib/glusterd"]
EXPOSE 111 111/udp 24007 24009 49152
ENTRYPOINT ["/usr/local/entrypoint.sh"]
