#!/bin/sh
set -e

/usr/lib/docker-helpers/apt-cleanup

sed -i "s/\/\/.*:3142\//\/\//g" /etc/apt/sources.list