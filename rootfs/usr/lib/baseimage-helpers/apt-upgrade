#!/bin/sh
set -e

MODE="${1:-upgrade}"

export DEBIAN_FRONTEND="noninteractive"

case "${MODE}" in
    upgrade)
        apt-get --assume-yes upgrade
        ;;
    dist-upgrade)
        apt-get --assume-yes dist-upgrade
        ;;
    *)
        echo "Invalid mode: ${MODE}"
        exit 1
esac

