#! /bin/bash
#
# Usage:
#  start-irods
#
# This script starts the iRODS resource server and waits for a SIGTERM. It
# expects the environment variable CYVERSE_DS_CLERVER_PASSWORD to hold clerver
# user password.
#

tailPid=

main()

{
  # Wait for IES to become available
  until exec 3<> /dev/tcp/data.cyverse.org/1247
  do
    printf 'Waiting for IES\n'
    sleep 1
  done 2> /dev/null

  exec 3<&-
  exec 3>&-

  IRODS_HOST=data.cyverse.org iinit "$CYVERSE_DS_CLERVER_PASSWORD"
  /var/lib/irods/iRODS/irodsctl start
  iadmin modresc "$CYVERSE_DS_STORAGE_RESOURCE" status up
  trap stop SIGTERM
  printf 'Ready\n'

  local irodsPid=

  while irodsPid=$(pidof -s /var/lib/irods/iRODS/server/bin/irodsServer)
  do
    tail --follow /dev/null --pid "$irodsPid" &
    tailPid="$!"
    wait "$tailPid"
    tailPid=
  done
}


stop()
{
  iadmin modresc "$CYVERSE_DS_STORAGE_RESOURCE" status down
  /var/lib/irods/iRODS/irodsctl stop

  if [ -n "$tailPid" ]
  then
    kill "$tailPid"
    wait "$tailPid"
  fi
}

set -e

main
