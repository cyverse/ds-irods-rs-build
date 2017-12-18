#! /bin/bash
#
# Usage:
#  entrypoint [CMD]...
#
# Parameters:
#  CMD  One or more terms in the command to execute once the container is ready.
#
# This is the container entrypoint script. It finalizes the resource server
# configuration with the container information so that the resource server can
# interoperate with the other iRODS grid nodes. The resource server is not
# started though.
#
# To allow iRODS to run as a non-root user and still mount volumes, this script
# allows for the ability to run iRODS with as a user from the docker host
# server. To do this, set the environment variable CYVERSE_DS_HOST_UID to the
# UID of the host user to run iRODS as.
#
# If a command is provided to this script, it will be executed as the
# appropriate user after the configuration has been updated. Otherwise, a bash
# shell will be entered into.
#
# This script expects the following environment variables to be defined.
#
# CYVERSE_DS_CLERVER_PASSWORD   the password used to authenticate the clerver
#                               user with the IES.
# CYVERSE_DS_CONTROL_PLANE_KEY  the encryption key required for communicating
#                               over the relevant iRODS grid control plane
# CYVERSE_DS_HOST_UID           the UID on the hosting server to run iRODS as
# CYVERSE_DS_NEGOTIATION_KEY    the encryption key shared by the iplant zone for
#                               advanced negotiation during client connections
# CYVERSE_DS_ZONE_KEY           the shared secret used during server-to-server
#                               communication


main()
{
  if [ "$#" -eq 0 ]
  then
    local cmdTerms=(/start-irods)
  else
    local cmdTerms=("$@")
  fi

  jq_in_place \
    ".irods_server_control_plane_key |= \"$CYVERSE_DS_CONTROL_PLANE_KEY\"" \
    /var/lib/irods/.irods/irods_environment.json

  jq_in_place \
    ".negotiation_key          |= \"$CYVERSE_DS_NEGOTIATION_KEY\" |
     .server_control_plane_key |= \"$CYVERSE_DS_CONTROL_PLANE_KEY\" |
     .zone_key                 |= \"$CYVERSE_DS_ZONE_KEY\"" \
    /etc/irods/server_config.json

  if [ -n "$CYVERSE_DS_HOST_UID" ]
  then
    printf 'Executing as irods-override (UID:%s)\n' "$CYVERSE_DS_HOST_UID"

    local user=irods-override

    useradd --no-create-home --non-unique \
            --comment 'iRODS Administrator override' \
            --groups irods \
            --home-dir /var/lib/irods \
            --shell /bin/bash \
            --uid "$CYVERSE_DS_HOST_UID" \
            "$user"
  else
    printf 'Executing as irods\n'

    local user=irods
  fi

  exec gosu "$user" "${cmdTerms[@]}"
}


jq_in_place()
{
  local filter="$1"
  local file="$2"

  jq "$filter" "$file" | awk 'BEGIN { RS=""; getline<"-"; print>ARGV[1] }' "$file"
}


set -e

main "$@"
