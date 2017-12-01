#!/bin/bash


main()
{
  local os="$1"

  mkdir --parents /packages/"$os"

  for pkg in api microservices icommands
  do
    /src/"$pkg"/packaging/build.sh -r
    cp --update /src/"$pkg"/build/* /packages/"$os"
  done

  local pkgId=

  case "$os"
  in
    centos-6)
      pkgId=centos6
      ;;
    centos-7)
      pkgId=centos7
      ;;
    ubuntu-12)
      pkgId=ubuntu12
      ;;
    ubuntu-14)
      pkgId=ubuntu14
      ;;    
  esac

  # Gather irods-runtime contents
  mkdir --parents /src/tar/irods/externals
  cp --no-dereference --update /usr/lib/libirods*.so* /src/tar
  cp --no-dereference --update /usr/lib/irods/externals/*.so* /src/tar/irods/externals

  tar --create --gzip \
      --directory /src/tar --file /packages/"$os"/irods-runtime-4.1.10-"$pkgId".tgz \
      .
}


set -e

main "$*"
