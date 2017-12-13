#!/bin/bash


main()
{
  local os="$1"

  mkdir --parents /packages/"$os"

  for pkg in api microservices icommands
  do
    local pkgSrc=/src/"$pkg"

    if build_needed "$pkgSrc" "$pkgSrc"/build
    then
      "$pkgSrc"/packaging/build.sh -r
      cp --update "$pkgSrc"/build/* /packages/"$os"
    else
      printf 'Nothing to do for %s/\n' "$pkg"
    fi
  done

  # Gather irods-runtime contents
  local tgzSrc=/src/tar
  local tgz=/packages/"$os"/irods-runtime-4.1.10-"$os".tgz

  mkdir --parents "$tgzSrc"/irods/externals
  cp --no-dereference --update /usr/lib/libirods*.so* "$tgzSrc"
  cp --no-dereference --update /usr/lib/irods/externals/*.so* "$tgzSrc"/irods/externals

  if build_needed "$tgzSrc" "$tgz"
  then
    printf 'Creating %s\n' "$tgz"
    tar --create --gzip --directory "$tgzSrc" --file "$tgz" .
  else
    printf '%s is up to date\n' "$tgz"
  fi
}


build_needed()
{
  local srcDir="$1"
  local artifact="$2"

  if [ ! -e "$artifact" ]
  then
    return 0
  fi

  local findRes=$(find "$srcDir" -newer "$artifact" -printf ' ' -quit)
  [ -n "$findRes" ]
}


set -e

main "$*"
