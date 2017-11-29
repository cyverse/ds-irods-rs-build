#! /bin/bash
#
# Usage:
#  instantiate
#
# This script expands the build time templates.
#


main()
{
  local baseDir=$(dirname $(readlink -f "$0"))

  expand_template "$baseDir"/hosts_config.tmpl > /var/lib/irods/templates/hosts_config.tmpl

  expand_template "$baseDir"/irods_environment.tmpl \
    > /var/lib/irods/templates/irods_environment.tmpl

  expand_template "$baseDir"/server_config.tmpl > /etc/irods/server_config.json
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
s/__CONTROL_PLANE_KEY__/$(escape_for_sed "$CONTROL_PLANE_KEY")/g
s/__DEFAULT_RESOURCE_DIR__/$(escape_for_sed "$DEFAULT_RESOURCE_DIR")/g
s/__DEFAULT_RESOURCE_NAME__/$(escape_for_sed "$DEFAULT_RESOURCE_NAME")/g
s/__NEGOTIATION_KEY__/$(escape_for_sed "$NEGOTIATION_KEY")/g
s/__RS_CNAME__/$(escape_for_sed "$RS_CNAME")/g
s/__ZONE_KEY__/$(escape_for_sed "$ZONE_KEY")/g
EOF
}


set -e

main
