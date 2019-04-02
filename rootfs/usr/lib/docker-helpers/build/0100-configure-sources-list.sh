#!/bin/sh
set -e

. /etc/os-release

DISTRIBUTION="${ID:-debian}"
VERSION="${VERSION:-sid}"
CODENAME="$(echo "${VERSION}" |awk '{print $NF}' |tr -d '()' |tr '[A-Z]' '[a-z]')"

# Default mirrors
DEBIAN_MIRROR="${DEBIAN_MIRROR:-http://deb.debian.org/debian}"
UBUNTU_MIRROR="${UBUNTU_MIRROR:-http://archive.ubuntu.com/ubuntu}"

SOURCESLIST="/etc/apt/sources.list"

case "${DISTRIBUTION}"
in
    debian)
        echo "deb ${DEBIAN_MIRROR} ${CODENAME} main" > "${SOURCESLIST}"
        echo "#deb-src ${DEBIAN_MIRROR} ${CODENAME} main" >> "${SOURCESLIST}"
        if [ "${CODENAME}" != "sid" ]
        then
            echo "deb ${DEBIAN_MIRROR} ${CODENAME}-updates main" >> "${SOURCESLIST}"
            echo "#deb-src ${DEBIAN_MIRROR} ${CODENAME}-updates main" >> "${SOURCESLIST}"
            echo "deb ${DEBIAN_MIRROR}-security ${CODENAME}/updates main" >> "${SOURCESLIST}"
            echo "#deb-src ${DEBIAN_MIRROR}-security ${CODENAME}/updates main" >> "${SOURCESLIST}"
        fi
    ;;
    ubuntu)
	echo "deb ${UBUNTU_MIRROR} ${CODENAME} main" > "${SOURCESLIST}"
	echo "#deb-src ${UBUNTU_MIRROR} ${CODENAME} main" >> "${SOURCESLIST}"
	echo "deb ${UBUNTU_MIRROR} ${CODENAME}-security main" >> "${SOURCESLIST}"
	echo "#deb-src ${UBUNTU_MIRROR} ${CODENAME}-security main" >> "${SOURCESLIST}"
	echo "deb ${UBUNTU_MIRROR} ${CODENAME}-updates main" >> "${SOURCESLIST}"
	echo "#deb-src ${UBUNTU_MIRROR} ${CODENAME}-updates main" >> "${SOURCESLIST}"
    ;;
    *)
        echo "Error: Unknown distribution: '${DISTRIBUTION}'."
        exit 1
    ;;
esac

cat /etc/apt/sources.list

/usr/lib/docker-helpers/apt-setup