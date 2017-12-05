#! /bin/bash
#
# Usage:
#  irods-rs
#
# This script starts the iRODS resource server and waits for a SIGTERM.
#


tailPid=

main()
{
  if [ ! -e /auth/irodsA ]
  then
    printf 'Please run `auth-clerver` first to authenticate the clerver user with the IES.\n' >&2
    return 1
  fi

  # Wait for IES to become available
  until exec 3<> /dev/tcp/data.cyverse.org/1247
  do
    printf 'Waiting for IES\n'
    sleep 1
  done 2> /dev/null

  exec 3<&-
  exec 3>&-

  trap stop SIGTERM
  /var/lib/irods/iRODS/irodsctl start
  printf 'Ready\n'

  while true
  do
    tail --follow /dev/null &
    tailPid="$!"
    wait "$tailPid"
  done
}


stop()
{
  /var/lib/irods/iRODS/irodsctl stop
  local ret="$?"

  if [ -n "$tailPid" ]
  then
    kill "$tailPid"
    wait "$tailPid"
  fi

  return "$ret"
}


set -e

main
