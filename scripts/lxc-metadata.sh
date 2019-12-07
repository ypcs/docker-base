#!/bin/sh
set -e

DISTRO="$1"
RELEASE="$2"

[ -z "${DISTRO}" ] && exit 1

if [ -z "${RELEASE}" ]
then
    TMP="${DISTRO}"
    DISTRO="$(echo "${TMP}" |cut -d'-' -f1)"
    RELEASE="$(echo "${TMP}" |cut -d'-' -f2)"
fi

[ -z "${RELEASE}" ] && exit 1

echo "Generate LXC metadata: ${DISTRO} ${RELEASE}"

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
