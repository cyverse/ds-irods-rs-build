FROM centos:7 AS gosu-builder
MAINTAINER Tony Edgin <tedgin@cyverse.org>

ADD https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 /gosu
ADD https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64.asc /gosu.asc

RUN mkdir --parents /root/.gnupg
RUN touch /root/.gnupg/gpg.conf
RUN gpg --quiet \
        --keyserver hkp://ha.pool.sks-keyservers.net:80 \
        --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN gpg --quiet --verify /gosu.asc
RUN chmod +x /gosu


FROM centos:7

COPY --from=gosu-builder /gosu /usr/local/bin
COPY irods-netcdf-build/packages/centos7/* /tmp/

RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum --assumeyes install epel-release && \
    rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
    yum --assumeyes install \
      jq sysvinit-tools uuidd which \
      ftp://ftp.renci.org/pub/irods/releases/4.1.10/centos7/irods-resource-4.1.10-centos7-x86_64.rpm \
      ftp://ftp.renci.org/pub/irods/releases/4.1.10/centos7/irods-runtime-4.1.10-centos7-x86_64.rpm && \
    adduser --system --comment 'iRODS Administrator' --home-dir /var/lib/irods --shell /bin/bash \
            irods && \
    yum --assumeyes install \
        /tmp/irods-api-plugin-netcdf-1.0-centos7.rpm \
        /tmp/irods-icommands-netcdf-1.0-centos7.rpm \
        /tmp/irods-microservice-plugin-netcdf-1.0-centos7.rpm && \
    yum --assumeyes clean all && \
    rm --force --recursive /tmp/* /var/cache/yum && \
    mkdir --parents /auth /var/lib/irods/.irods

ADD https://raw.githubusercontent.com/cyverse/irods-cmd-scripts/master/generateuuid.sh \
    /var/lib/irods/iRODS/server/bin/cmd

COPY irods-setavu-plugin/libraries/centos7/libmsiSetAVU.so /var/lib/irods/plugins/microservices/
COPY etc/* /etc/irods/
COPY scripts/auth-clerver.sh /usr/local/bin/auth-clerver
COPY scripts/irods-rs.sh /usr/local/bin/irods-rs
COPY entrypoint.sh /entrypoint
COPY build-time-templates/instantiate.sh /tmp/instantiate
COPY build-time-templates/*.tmpl /tmp/

RUN chown --recursive irods:irods /auth /etc/irods /var/lib/irods && \
    chmod g+w /auth /var/lib/irods/iRODS/server/log && \
    chmod a+x /usr/local/bin/auth-clerver /usr/local/bin/irods-rs && \
    chmod u+x /entrypoint /tmp/instantiate

VOLUME /auth /var/lib/irods/iRODS/server/log /var/lib/irods/iRODS/server/log/proc

EXPOSE 1247/tcp 1248/tcp 20000-20009/tcp 20000-20009/udp

WORKDIR /var/lib/irods

ENTRYPOINT [ "/entrypoint" ]

ONBUILD ARG CLERVER_USER_NAME=rods
ONBUILD ARG CONTROL_PLANE_KEY=TEMPORARY__32byte_ctrl_plane_key
ONBUILD ARG DEFAULT_RESOURCE_DIR=/var/lib/irods/Vault
ONBUILD ARG DEFAULT_RESOURCE_NAME=demoResc
ONBUILD ARG NEGOTIATION_KEY=TEMPORARY_32byte_negotiation_key
ONBUILD ARG RS_CNAME=localhost
ONBUILD ARG ZONE_KEY=TEMPORARY_zone_key

ONBUILD RUN mkdir --parents "$DEFAULT_RESOURCE_DIR" && \
            chown irods:irods "$DEFAULT_RESOURCE_DIR" && \
            chmod g+w "$DEFAULT_RESOURCE_DIR" && \
            /tmp/instantiate && \
            rm --force /tmp/*

ONBUILD VOLUME "$DEFAULT_RESOURCE_DIR"
