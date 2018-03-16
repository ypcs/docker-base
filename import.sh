#!/bin/sh
set -e

NAMESPACE="ypcs"

for f in *.tar
do
    DISTRO="$(echo "${f}" |cut -d- -f1)"
    SUITE="$(echo "${f}" |cut -d- -f2 |cut -d. -f1)"
    docker import - "${NAMESPACE}/${DISTRO}:${SUITE}" < "${f}"
done
