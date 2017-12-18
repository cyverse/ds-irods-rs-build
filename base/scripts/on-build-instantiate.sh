#! /bin/bash
#
# Usage:
#  instantiate
#
# This script expands the build time templates.
#


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
}


jq_in_place()
{
  local filter="$1"
  local file="$2"

  jq "$filter" "$file" | awk 'BEGIN { RS=""; getline<"-"; print>ARGV[1] }' "$file"
}


set -e

main
