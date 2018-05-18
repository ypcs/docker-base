#!/bin/sh
set -e

[ -z "${TARGET}" ] && echo "E: Missing target!" && exit 1

export DOCKER_TARGET="${TARGET}.docker"

sudo cp -ax "${TARGET}" "${DOCKER_TARGET}"

