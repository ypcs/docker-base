#!/bin/bash
set -e

SUITE="$1"

[ -z "${SUITE}" ] && echo "usage: $0 <suite>" && exit 1

case "${SUITE}"
in
    wheezy|jessie|stretch|buster|sid)
        DISTRIBUTION="debian"
        MIRROR="http://deb.debian.org/debian"
        ;;
    artful|bionic|trusty|xenial)
        DISTRIBUTION="ubuntu"
        MIRROR="http://archive.ubuntu.com/ubuntu"
        ;;
    *)
        echo "Invalid suite: ${SUITE}"
        exit 1
        ;;
esac

TEMPDIR="$(mktemp -d baseimage.XXXXXX)"
TARGET="${TEMPDIR}/target"

echo "D: Using tempdir \"${TEMPDIR}\"..."

chroot_mount() {
    local TARGET="$1"
    echo "I: Mounting /dev, /proc, /sys..."
    sudo mount -o bind /dev "${TARGET}/dev" || true
    sudo mount -t proc none "${TARGET}/proc" || true
    sudo mount -o bind /sys "${TARGET}/sys" || true
}

chroot_umount() {
    local TARGET="$1"
    echo "I: Unmounting /dev, /proc, /sys..."
    sudo umount -l "${TARGET}/dev" || true
    sudo umount -l "${TARGET}/proc" || true
    sudo umount -l "${TARGET}/sys" || true    
}

cleanup() {
    echo "I: Doing cleanup..."
    chroot_umount "${TARGET}"
}

trap cleanup EXIT

echo "I: Run debootstrap..."
sudo debootstrap \
    --arch="amd64" \
    --variant="minbase" \
    "${SUITE}" \
    "${TARGET}" \
    "${MIRROR}"

echo "I: Add helper scripts..."
HELPERDIR="${TARGET}/usr/share/baseimage-helpers"
sudo mkdir -p "${HELPERDIR}"
sudo cp helpers/* "${HELPERDIR}/"
sudo chmod +x "${HELPERDIR}/*"

# Generate sources.list
echo "I: Generate sources.list..."
SOURCESLIST="${TARGET}/etc/apt/sources.list"
case "${DISTRIBUTION}"
in
    debian)
        cat > "${SOURCESLIST}" << EOF
deb ${MIRROR} ${SUITE} main
#deb-src ${MIRROR} ${SUITE} main
EOF
        if [ "${SUITE}" != "sid" ]
        then
            cat >> "${SOURCESLIST}" << EOF
deb ${MIRROR} ${SUITE}-updates main
#deb-src ${MIRROR} ${SUITE}-updates main
deb ${MIRROR}-security ${SUITE}/updates main
#deb-src ${MIRROR}-security ${SUITE}/updates main
EOF
        fi
        ;;
    ubuntu)
        cat > "${SOURCESLIST}" << EOF
deb ${MIRROR} ${SUITE} main
deb ${MIRROR} ${SUITE}-security main
deb ${MIRROR} ${SUITE}-updates main
        EOF
        ;;
    *)
        echo "Invalid distribution: ${DISTRIBUTION}"
        exit 1
esac

# Disable translations
cat > "${TARGET}/etc/apt/apt.conf.d/99translations" << EOF
Acquire::Languages "none";
EOF

chroot_mount

chroot "${TARGET}" apt-get update
chroot "${TARGET}" apt-get --assume-yes dist-upgrade
chroot "${TARGET}" /usr/share/baseimage-helpers/apt-cleanup