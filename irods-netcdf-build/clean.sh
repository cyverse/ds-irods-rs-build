#!/bin/bash

readonly OSes=(centos-6 centos-7 opensuse-13 ubuntu-12 ubuntu-14)

for os in ${OSes[*]}
do 
  image=irods-plugin-build:4.1.10-"$os"

  if [ -n $(docker images --quiet "$image") ]
  then
    docker run --interactive --rm \
               --name=netcdf-builder \
               --user=$(id -u):$(id -g) \
               --volume=$(pwd)/irods_netcdf:/src \
               --volume=$(pwd)/packages:/packages \
               --volume=$(pwd)/scripts/clean-packages.sh:/clean-packages.sh \
               "$image" /clean-packages.sh "$os"
  fi
done
