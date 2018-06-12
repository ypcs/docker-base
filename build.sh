#!/bin/bash
set -e

SUITE="$1"

[ -z "${SUITE}" ] && echo "usage: $0 <suite>" && exit 1

case "${SUITE}"
in
    wheezy|jessie|stretch|buster|sid)
        DISTRIBUTION="debian"
        MIRROR="http://127.0.0.1:3142/deb.debian.org/debian"
        ;;
    artful|bionic|trusty|xenial)
        DISTRIBUTION="ubuntu"
        MIRROR="http://127.0.0.1:3142/archive.ubuntu.com/ubuntu"
        ;;
    *)
        echo "Invalid suite: ${SUITE}"
        exit 1
        ;;
esac
export SUITE
export DISTRIBUTION

TEMPDIR="$(mktemp -d baseimage.XXXXXX)"
export TARGET="${TEMPDIR}/target"

echo "D: Using tempdir \"${TEMPDIR}\"..."

chroot_mount() {
    local TARGET="$1"
    echo "I: Mounting /dev, /proc, /sys..."
    [ -z "${TARGET}" ] && echo "W: Missing target, skip..." && return
    sudo mount -o bind /dev "${TARGET}/dev" || true
    sudo mount -t proc none "${TARGET}/proc" || true
    sudo mount -o bind /sys "${TARGET}/sys" || true
}

chroot_umount() {
    local TARGET="$1"
    echo "I: Unmounting /dev, /proc, /sys..."
    [ -z "${TARGET}" ] && echo "W: Missing target, skip..." && return
    sudo umount -l "${TARGET}/dev" || true
    sudo umount -l "${TARGET}/proc" || true
    sudo umount -l "${TARGET}/sys" || true    
}

cleanup() {
    echo "I: Doing cleanup..."
    chroot_umount "${TARGET}"
    unset DISTRIBUTION
    unset SUITE
    unset TARGET
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
for helper in apt-cleanup apt-setup apt-upgrade
do
    sudo cp helpers/template "${HELPERDIR}/${helper}"
    sudo chmod +x "${HELPERDIR}/${helper}"
done
sudo cp -R helpers/*.d "${HELPERDIR}/"

# Generate sources.list
echo "I: Generate sources.list..."
SOURCESLIST="${TARGET}/etc/apt/sources.list"
case "${DISTRIBUTION}"
in
    debian)
        cat << EOF |sudo tee "${SOURCESLIST}"
deb ${MIRROR} ${SUITE} main
#deb-src ${MIRROR} ${SUITE} main
EOF
        if [ "${SUITE}" != "sid" ]
        then
            cat << EOF |sudo tee -a "${SOURCESLIST}"
deb ${MIRROR} ${SUITE}-updates main
#deb-src ${MIRROR} ${SUITE}-updates main
deb ${MIRROR}-security ${SUITE}/updates main
#deb-src ${MIRROR}-security ${SUITE}/updates main
EOF
        fi
        ;;
    ubuntu)
        cat << EOF |sudo tee "${SOURCESLIST}"
deb ${MIRROR} ${SUITE} main
deb ${MIRROR} ${SUITE}-security main
deb ${MIRROR} ${SUITE}-updates main
EOF
        ;;
    *)
        echo "Invalid distribution: ${DISTRIBUTION}"
        exit 1
        ;;
esac

# Disable translations
cat << EOF |sudo tee "${TARGET}/etc/apt/apt.conf.d/99translations"
Acquire::Languages "none";
EOF

chroot_mount "${TARGET}"

sudo chroot "${TARGET}" apt-get update
sudo chroot "${TARGET}" apt-get --assume-yes dist-upgrade
sudo chroot "${TARGET}" /usr/share/baseimage-helpers/apt-cleanup

for variant in variants/*
do
    VARIANT="$(basename "${variant}")"
    echo "I: Generate variant \"${VARIANT}\"..."
    PARTS="$(find "${variant}" -type f -print |sort)"
    for script in ${PARTS}
    do
        echo "I: Execute \"${script}\" from ${VARIANT}..."
         sh "${script}"
    done
done
