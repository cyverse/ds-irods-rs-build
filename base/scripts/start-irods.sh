#! /bin/bash
#
# Usage:
#  start-irods
#
# This script starts the iRODS resource server and waits for a SIGTERM.
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

  IRODS_HOST=data.cyverse.org iinit "$CLERVER_USER_PASSWORD"

  /var/lib/irods/iRODS/irodsctl start
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
  /var/lib/irods/iRODS/irodsctl stop

  if [ -n "$tailPid" ]
  then
    kill "$tailPid"
    wait "$tailPid"
  fi
}

set -e

main
