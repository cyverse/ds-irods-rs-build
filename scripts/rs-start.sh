#! /bin/bash
#
# Usage:
#  rs-start
#
# This script starts the iRODS resource server.
#


main()
{
  if [ ! -e /auth/irodsA ]
  then
    printf 'Please run `rs-init` first to authenticate the clerver user with the IES\n' >&2
    return 1
  fi

  /var/lib/irods/iRODS/irodsctl start
  bash
}


set -e

main
