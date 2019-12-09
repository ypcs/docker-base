#!/bin/sh
set -e

if [ "$(id -u)" != "0" ]
then
    echo "run as root!"
    exit 1
fi

TARGET="$1"
SOURCE="$2"
SIZE="${3:-4096}"

if [ -e "${TARGET}" ]
then
    echo "Target already exists! Exiting..."
    exit 1
fi

if [ ! -f "${SOURCE}" ]
then
    echo "Source archive not found! Exiting..."
    exit 1
fi

dd if=/dev/zero of="${TARGET}" bs=1M count="${SIZE}" status=progress
/usr/sbin/mkfs.ext4 "${TARGET}"

TEMPDIR="$(mktemp --tmpdir --directory "$(basename "$0").XXXXXX")"
SRC="$(realpath "${SOURCE}")"

#mount "${TARGET}" "${TEMPDIR}"
#(cd "${TEMPDIR}" && tar xf "${SRC}")

#echo "${TEMPDIR}"
#echo "Acquire::HTTP::Proxy \"http://127.0.0.1:3142/\";" > "${TEMPDIR}/etc/apt/apt.conf.d/99proxy"

#chroot "${TEMPDIR}" /usr/lib/docker-helpers/apt-setup
#chroot "${TEMPDIR}" apt dist-upgrade -y

#chroot "${TEMPDIR}" apt install --assume-yes linux-image-amd64 grub2

#chroot "${TEMPDIR}" /usr/lib/docker-helpers/apt-cleanup

#umount -l "${TEMPDIR}"
