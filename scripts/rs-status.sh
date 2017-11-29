#! /bin/bash
#
# Usage:
#  rs-status
#
# This script checks to see if the clever user has been authenticated with the
# IES and displays any running processes.
#


main()
{
  if [ ! -e /auth/irodsA ]
  then
    printf 'Clerver user needs to be authenticated with the IES\n'
  else
    /var/lib/irods/iRODS/irodsctl status
  fi
}


set -e

main
