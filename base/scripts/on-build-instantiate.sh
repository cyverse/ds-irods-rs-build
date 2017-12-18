#! /bin/bash
#
# Usage:
#  on-build-instantiate
#
# This program expands the build time templates.
#
# To allow iRODS to run as a non-root user and still mount volumes, this script
# allows for the ability to run iRODS with as a user from the docker host
# server. To do this, set the environment variable CYVERSE_DS_HOST_UID to the
# UID of the host user to run iRODS as.
#
# This program expects the following variables to be defined.
#
# CYVERSE_DS_CLERVER_USER      the name of the rodsadmin user representing the
#                              resource server within the zone
# CYVERSE_DS_CONTAINER_VAULT   the directory inside the container iRODS will use
#                              as its vault
# CYVERSE_DS_DEFAULT_RESOURCE  the name of coordinating resource this server
#                              will use by default
# CYVERSE_DS_HOST_UID          (optional) the UID of the hosting server to run
#                              iRODS as instead of the default user defined in
#                              the container
# CYVERSE_DS_SERVER_CNAME      the FQDN or address used by the rest of the grid
#                              to communicate with this server


main()
{
  jq_in_place \
    "(.host_entries[] | select(.address_type == \"local\") | .addresses)
       |= . + [{\"address\": \"$CYVERSE_DS_SERVER_CNAME\"}]" \
    /etc/irods/hosts_config.json

  jq_in_place \
    ".default_resource_directory |= \"$CYVERSE_DS_CONTAINER_VAULT\" |
     .default_resource_name      |= \"$CYVERSE_DS_DEFAULT_RESOURCE\" |
     .zone_user                  |= \"$CYVERSE_DS_CLERVER_USER\"" \
    /etc/irods/server_config.json

  jq_in_place \
    ".irods_cwd              |= \"/iplant/home/$CYVERSE_DS_CLERVER_USER\" |
     .irods_default_resource |= \"$CYVERSE_DS_DEFAULT_RESOURCE\" |
     .irods_home             |= \"/iplant/home/$CYVERSE_DS_CLERVER_USER\" |
     .irods_user_name        |= \"$CYVERSE_DS_CLERVER_USER\"" \
    /var/lib/irods/.irods/irods_environment.json

  printf "\nipc_DEFAULT_RESC = '%s'\n" "$CYVERSE_DS_DEFAULT_RESOURCE" >> /etc/irods/ipc-env.re

  if [ -n "$CYVERSE_DS_HOST_UID" ]
  then
    useradd --no-create-home --non-unique \
            --comment 'iRODS Administrator override' \
            --groups irods \
            --home-dir /var/lib/irods \
            --shell /bin/bash \
            --uid "$CYVERSE_DS_HOST_UID" \
            irods-override
  fi
}


jq_in_place()
{
  local filter="$1"
  local file="$2"

  jq "$filter" "$file" | awk 'BEGIN { RS=""; getline<"-"; print>ARGV[1] }' "$file"
}


set -e

main
