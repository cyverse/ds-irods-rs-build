FROM centos:7
MAINTAINER Tony Edgin <tedgin@cyverse.org>

COPY irods-netcdf-build/packages/centos7/* /tmp/

RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
    yum --assumeyes install epel-release && \
    rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
    yum --assumeyes install \
      jq sysvinit-tools uuidd which \
      https://files.renci.org/pub/irods/releases/4.1.10/centos7/irods-resource-4.1.10-centos7-x86_64.rpm \
      https://files.renci.org/pub/irods/releases/4.1.10/centos7/irods-runtime-4.1.10-centos7-x86_64.rpm && \
    adduser --system --comment 'iRODS Administrator' --home-dir /var/lib/irods --shell /bin/bash \
            irods && \
    yum --assumeyes install \
        /tmp/irods-api-plugin-netcdf-1.0-centos7.rpm \
        /tmp/irods-icommands-netcdf-1.0-centos7.rpm \
        /tmp/irods-microservice-plugin-netcdf-1.0-centos7.rpm && \
    yum --assumeyes clean all && \
    rm --force --recursive /tmp/* /var/cache/yum && \
    mkdir --parents /var/lib/irods/.irods

ADD https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/cmd-common/calliope-ingest \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/cmd-common/de-archive-data \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/cmd-common/de-create-collection \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/cmd-common/delete-scheduled-rule \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/cmd-common/generateuuid \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/cmd-common/sanimal-ingest \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/cmd-common/set-uuid \
    /var/lib/irods/iRODS/server/bin/cmd/

ADD https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/aegis.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/bisque.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/calliope.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/coge.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/de.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/ipc-amqp.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/ipc-custom.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/ipc-housekeeping.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/ipc-json.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/ipc-logic.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/ipc-repl.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/ipc-services.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/ipc-uuid.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/pire.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/sanimal.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/sciapps.re \
    https://raw.githubusercontent.com/cyverse/ds-playbooks/master/irods/files/rule-bases/sernec.re \
    /etc/irods/

COPY irods-setavu-plugin/libraries/centos7/libmsiSetAVU.so /var/lib/irods/plugins/microservices
COPY config/hosts_config.json config/server_config.json env-rules/* /etc/irods/
COPY config/irods_environment.json /var/lib/irods/.irods
COPY scripts/entrypoint.sh /entrypoint
COPY scripts/on-build-instantiate.sh /on-build-instantiate

RUN chown --recursive irods:irods /entrypoint /var/lib/irods && \
    chmod ug+w /var/lib/irods/.irods /var/lib/irods/iRODS/server/log && \
    chmod ug+x /entrypoint && \
    chmod u+x /on-build-instantiate

VOLUME /var/lib/irods/iRODS/server/log /var/lib/irods/iRODS/server/log/proc

EXPOSE 1247/tcp 1248/tcp 20000-20009/tcp 20000-20009/udp

WORKDIR /var/lib/irods

# These need to be provided at run time.
ENV CYVERSE_DS_CONTROL_PLANE_KEY=
ENV CYVERSE_DS_NEGOTIATION_KEY=
ENV CYVERSE_DS_ZONE_KEY=

ENTRYPOINT [ "/entrypoint" ]

# These need to be provided at the build time of a derived container
ONBUILD ARG CYVERSE_DS_CLERVER_USER=ipc_admin
ONBUILD ARG CYVERSE_DS_DEFAULT_RES=CyVerseRes
ONBUILD ARG CYVERSE_DS_HOST_UID=
ONBUILD ARG CYVERSE_DS_CONTAINER_VAULT
ONBUILD ARG CYVERSE_DS_RES_SERVER
ONBUILD ARG CYVERSE_DS_STORAGE_RES

ONBUILD RUN /on-build-instantiate && \
            mkdir --parents "$CYVERSE_DS_CONTAINER_VAULT" && \
            chown --recursive \
                  irods:irods "$CYVERSE_DS_CONTAINER_VAULT" /etc/irods /var/lib/irods/.irods && \
            chmod g+w "$CYVERSE_DS_CONTAINER_VAULT" && \
            rm --force /on-build-instantiate

ONBUILD VOLUME "$CYVERSE_DS_CONTAINER_VAULT"

ONBUILD USER irods-host-user
