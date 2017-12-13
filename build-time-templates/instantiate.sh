#! /bin/bash
#
# Usage:
#  instantiate
#
# This script expands the build time templates.
#

readonly BaseDir=$(dirname $(readlink -f "$0"))


main()
{
  jq_in_place \
    "(.host_entries[] | select(.address_type == \"local\") | .addresses)
       |= . + [{\"address\": \"$RS_CNAME\"}]" \
    /etc/irods/hosts_config.json

  jq_in_place \
    ".irods_cwd              |= \"/iplant/home/$CLERVER_USER_NAME\" |
     .irods_default_resource |= \"$DEFAULT_RESOURCE_NAME\" |
     .irods_home             |= \"/iplant/home/$CLERVER_USER_NAME\" |
     .irods_user_name        |= \"$CLERVER_USER_NAME\"" \
    /run-time-templates/irods_environment.tmpl

  jq_in_place \
    ".default_resource_directory |= \"$DEFAULT_RESOURCE_DIR\" |
     .default_resource_name      |= \"$DEFAULT_RESOURCE_NAME\" |
     .zone_user                  |= \"$CLERVER_USER_NAME\"" \
    /run-time-templates/server_config.tmpl
}


jq_in_place()
{
  local filter="$1"
  local file="$2"

  jq "$filter" "$file" | awk 'BEGIN{RS="";getline<"-";print>ARGV[1]}' "$file"
}


set -e

main
