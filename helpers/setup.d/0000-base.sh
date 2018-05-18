#!/bin/sh
set -e

if [ -n "${APT_PROXY}" ]
then
    echo "I: Set APT proxy '${APT_PROXY}'."
    echo "Acquire::HTTP::Proxy \"${APT_PROXY}\";" > /etc/apt/apt.conf.d/99proxy
fi

apt-get update