#! /bin/bash
#
# Usage:
#  rs-stop
#
# This script stops the iRODS resource server.
#


main()
{
  /var/lib/irods/iRODS/irodsctl stop
}


set -e

main
