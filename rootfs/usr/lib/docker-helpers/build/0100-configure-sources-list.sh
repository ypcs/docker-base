#!/bin/sh
set -e

if [ -z "${DISTRIBUTION}" ]
then
    . /etc/os-release
    DISTRIBUTION="${ID:-debian}"
fi

if [ -z "${CODENAME}" ]
then
    CODENAME="${CODENAME:-sid}"
fi

# Default mirrors
DEBIAN_MIRROR="${DEBIAN_MIRROR:-http://deb.debian.org/debian}"
UBUNTU_MIRROR="${UBUNTU_MIRROR:-http://archive.ubuntu.com/ubuntu}"

SOURCESLIST="/etc/apt/sources.list"

cat /etc/debian_version
cat /etc/os-release

case "${DISTRIBUTION}"
in
    debian)
        echo "deb ${DEBIAN_MIRROR} ${CODENAME} main" > "${SOURCESLIST}"
        echo "#deb-src ${DEBIAN_MIRROR} ${CODENAME} main" >> "${SOURCESLIST}"
        case "${CODENAME}"
	in
	    sid|unstable)
	        ;;
	    bullseye|testing)
		;;
	    rc-buggy|experimental)
		;;
            *)
            echo "deb ${DEBIAN_MIRROR} ${CODENAME}-updates main" >> "${SOURCESLIST}"
            echo "#deb-src ${DEBIAN_MIRROR} ${CODENAME}-updates main" >> "${SOURCESLIST}"
            echo "deb ${DEBIAN_MIRROR}-security ${CODENAME}/updates main" >> "${SOURCESLIST}"
            echo "#deb-src ${DEBIAN_MIRROR}-security ${CODENAME}/updates main" >> "${SOURCESLIST}"
        esac
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
