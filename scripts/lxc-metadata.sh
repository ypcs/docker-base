#!/bin/sh
set -e

DISTRO="$1"
RELEASE="$2"

TEMPDIR="$(mktemp --tmpdir --directory lxc-metadata.XXXXXX)"

cat > "${TEMPDIR}/metadata.yaml" << EOF
architecture: "x86_64"
creation_date: $(date +%s)
properties:
architecture: "x86_64"
description: "${DISTRO} ${RELEASE} ($(date +%Y%m%d))"
os: "${DISTRO}"
release: "${RELEASE}"
EOF

tar -C "${TEMPDIR}" -cvzf "${DISTRO}-${RELEASE}_metadata.tar.gz" metadata.yaml
