#!/bin/bash

readonly OS="$1"

rm --force --recursive /packages/"$OS"

for pkg in api microservices icommands
do
  /src/"$pkg"/packaging/build.sh clean
done
