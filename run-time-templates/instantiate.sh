#! /bin/bash
#
# Usage:
#  instantiate [SRV_ACNT]
#
# Parameter:
#  SRV_ACNT  the user that will own the iRODS processes
#
# This script adapts the iRODS configuration for the docker container where this
# script is run. It will configure the iRODS server processes to be owned by
# SRV_ACNT if it is provided. Otherwise the irods user will own them.
#


main()
{
  if [ "$#" -ge 1 ]
  then
    local servAcnt="$1"
  else
    local servAcnt="$(whoami)"
  fi

  sed "s/_SERVICE_ACCOUNT_NAME_/$servAcnt/" /var/lib/irods/templates/service_account.tmpl \
    > /etc/irods/service_account.config
}


set -e

main "$@"
