#!/bin/bash

readonly OSes=(centos-6 centos-7 opensuse-13 ubuntu-12 ubuntu-14)

for os in ${OSes[*]}
do
  image=irods-plugin-build:4.1.10-"$os"

  docker build --file dockerfiles/Dockerfile."$os" --tag "$image" .

  docker run --interactive --rm \
             --name=netcdf-builder \
             --user=$(id -u):$(id -g) \
             --volume=$(pwd)/irods_netcdf:/src \
             --volume=$(pwd)/packages:/packages \
             --volume=$(pwd)/scripts/clean-packages.sh:/clean-packages.sh \
             "$image" /clean-packages.sh "$os"

  docker run --interactive --rm \
             --name=netcdf-builder \
             --user=$(id -u):$(id -g) \
             --volume=$(pwd)/irods_netcdf:/src \
             --volume=$(pwd)/packages:/packages \
             --volume=$(pwd)/scripts/build-packages.sh:/build-packages.sh \
             "$image" /build-packages.sh "$os"
done

# There are some bugs in the NetCDF build logic

if [ -e packages/centos-7 ]
then        
  for f in $(ls packages/centos-7/*.rpm)
  do
    mv "$f" "${f/centos6/centos7}"
  done
fi

if [ -e packages/ubuntu-12 ]
then
  for f in $(ls packages/ubuntu-12/*.deb)
  do
    mv "$f" "${f/.deb/-ubuntu12.deb}"
  done
fi

if [ -e packages/ubuntu-14 ]
then
  for f in $(ls packages/ubuntu-14/*.deb)
  do
    mv "$f" "${f/.deb/-ubuntu14.deb}"
  done
fi
