#!/bin/sh
set -e

for suite in wheezy jessie stretch buster sid trusty xenial artful bionic
do
    echo "I: Building \"${suite}\"..."
    sh ./build.sh "${suite}"
done
