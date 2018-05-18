#!/bin/sh
set -e

[ -z "${DOCKER_TARGET}" ] && echo "E: Missing target!" && exit 1

#tar -C $< -c . -f $@

#tar -C src -c . -f dest.tar
echo "package docker here..."

unset DOCKER_TARGET