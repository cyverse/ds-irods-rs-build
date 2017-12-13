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
# server. To do this, set the environment variable LOCAL_USER_ID to the name of
# the host user to run iRODS as.
#
# If a command is provided to this script, it will be executed as the
# appropriate user after the configuration has been updated. Otherwise, a bash
# shell will be entered into.
#


main()
{
  if [ "$#" -eq 0 ]
  then
    local cmdTerms=(irods-rs)
  else
    local cmdTerms=("$@")
  fi

  jq_in_place \
    ".irods_server_control_plane_key |= \"$CONTROL_PLANE_KEY\"" \
    /var/lib/irods/.irods/irods_environment.json

  jq_in_place \
    ".negotiation_key          |= \"$NEGOTIATION_KEY\" |
     .server_control_plane_key |= \"$CONTROL_PLANE_KEY\" |
     .zone_key                 |= \"$ZONE_KEY\"" \
    /etc/irods/server_config.json

  if [ -n "$LOCAL_USER_ID" ]
  then
    printf 'Executing as irods-override (UID:%s)\n' "$LOCAL_USER_ID"

    local user=irods-override

    useradd --no-create-home --non-unique \
            --comment 'iRODS Administrator override' \
            --groups irods \
            --home-dir /var/lib/irods \
            --shell /bin/bash \
            --uid "$LOCAL_USER_ID" \
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
