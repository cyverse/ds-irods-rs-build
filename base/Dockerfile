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
    mkdir --parents /var/lib/irods/.irods

ADD https://raw.githubusercontent.com/cyverse/irods-cmd-scripts/master/generateuuid.sh \
    /var/lib/irods/iRODS/server/bin/cmd

COPY irods-setavu-plugin/libraries/centos7/libmsiSetAVU.so /var/lib/irods/plugins/microservices
COPY config/hosts_config.json config/server_config.json /etc/irods/
COPY config/irods_environment.json /var/lib/irods/.irods
COPY rules/* /etc/irods/
COPY scripts/start-irods.sh /start-irods
COPY scripts/entrypoint.sh /entrypoint
COPY scripts/on-build-instantiate.sh /on-build-instantiate

RUN chown --recursive irods:irods /start-irods /var/lib/irods && \
    chmod ug+w /var/lib/irods/.irods /var/lib/irods/iRODS/server/log && \
    chmod ug+x /start-irods && \
    chmod u+x /entrypoint /on-build-instantiate

VOLUME /var/lib/irods/iRODS/server/log /var/lib/irods/iRODS/server/log/proc

EXPOSE 1247/tcp 1248/tcp 20000-20009/tcp 20000-20009/udp

WORKDIR /var/lib/irods

ENV CONTROL_PLANE_KEY=
ENV LOCAL_USER_ID=
ENV NEGOTIATION_KEY=
ENV ZONE_KEY=

ENTRYPOINT [ "/entrypoint" ]

ONBUILD ARG CLERVER_USER_NAME=rods
ONBUILD ARG DEFAULT_RESOURCE_DIR=/var/lib/irods/Vault
ONBUILD ARG DEFAULT_RESOURCE_NAME=demoResc
ONBUILD ARG RS_CNAME

ONBUILD RUN /on-build-instantiate && \
            mkdir --parents "$DEFAULT_RESOURCE_DIR" && \
            chown --recursive \
                  irods:irods "$DEFAULT_RESOURCE_DIR" /etc/irods /var/lib/irods/.irods && \
            chmod g+w "$DEFAULT_RESOURCE_DIR" && \
            rm --force /on-build-instantiate

ONBUILD VOLUME "$DEFAULT_RESOURCE_DIR"
