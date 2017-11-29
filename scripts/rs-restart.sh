#! /bin/bash
#
# Usage:
#  rs-restart
#
# This script restarts the iRODS resource server.
#


main()
{
  if [ ! -e /auth/irodsA ]
  then
    printf 'Please run `rs-init` first to authenticate the clerver user with the IES\n' >&2
    return 1
  fi

  /var/lib/irods/iRODS/irodsctl restart
}


set -e

main
