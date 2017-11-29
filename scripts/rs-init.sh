#! /bin/bash
#
# Usage:
#  rs-init [PASSWD]
#
# Parameter:
#  PASSWD  the password used to authenticate the clerver account with the IES
#
# Initializes the clerver account so that this resource server can connect to
# the IES. It uses PASSWD to authenticate the clerver account. If PASSWD isn't
# provided, This script will ask for the password.
#


main()
{
  local password="$*"

  if [ -z "$password" ]
  then
    local user=$(jq --raw-output .irods_user_name < /var/lib/irods/.irods/irods_environment.json)

    printf 'Please enter password for user %s: ' "$user"
    read -s password
    printf '\n'
  fi

  local ies="$(jq --raw-output .icat_host < /etc/irods/server_config.json)"

  IRODS_HOST="$ies" iinit "$password"
}


set -e

main "$*"
