#!/bin/sh
set -e

for suite in jessie stretch buster sid xenial artful bionic
do
    echo "I: Building \"${suite}\"..."
    sh ./build.sh "${suite}"
done
