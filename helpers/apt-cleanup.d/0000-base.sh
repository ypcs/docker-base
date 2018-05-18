#!/bin/sh
set -e

apt-get --assume-yes autoremove
apt-get clean

rm -f /etc/apt/apt.conf.d/99proxy
rm -rf /var/lib/apt/lists/* /var/cache/apt/*.bin /var/cache/apt/archives/*.deb
mkdir -p /var/lib/apt/lists/partial
