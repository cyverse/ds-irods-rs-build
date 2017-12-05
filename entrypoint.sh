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
    local cmdTerms=(rs-start)
  else
    local cmdTerms=("$@")
  fi

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

  # Wait for IES to become available
  until exec 3<> /dev/tcp/data.cyverse.org/1247
  do
    printf 'Waiting for IES\n'
    sleep 1
  done 2> /dev/null

  exec 3<&-
  exec 3>&-

  # TODO sort out signal handling
  # TODO remove unneeded rs- scripts
  gosu "$user" "${cmdTerms[@]}"

  # TODO convert to service
}


set -e

main "$@"
