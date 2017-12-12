#! /bin/bash
#
# Usage:
#  instantiate
#
# This script expands the build time templates.
#

readonly BaseDir=$(dirname $(readlink -f "$0"))



main()
{
  expand_template "$BaseDir"/hosts_config.tmpl > /etc/irods/hosts_config.json
  expand_template "$BaseDir"/irods_environment.tmpl > /run-time-templates/irods_environment.tmpl
  expand_template "$BaseDir"/server_config.tmpl > /run-time-templates/server_config.tmpl
}


escape_for_sed()
{
  local var="$*"

  # Escape \ first to avoid escaping the escape character, i.e. avoid / -> \/ -> \\/
  var="${var//\\/\\\\}"

  printf '%s' "${var//\//\\/}"
}


expand_template()
{
  local tmplFile="$1"

  cat <<EOF | sed --file - "$tmplFile"
s/__CLERVER_USER_NAME__/$(escape_for_sed "$CLERVER_USER_NAME")/g
s/__DEFAULT_RESOURCE_DIR__/$(escape_for_sed "$DEFAULT_RESOURCE_DIR")/g
s/__DEFAULT_RESOURCE_NAME__/$(escape_for_sed "$DEFAULT_RESOURCE_NAME")/g
s/__RS_CNAME__/$(escape_for_sed "$RS_CNAME")/g
EOF
}


set -e

main
