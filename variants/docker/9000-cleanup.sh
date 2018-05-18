#!/bin/sh
set -e

[ -z "${TARGET}" ] && echo "E: Missing target!" && exit 1

echo "I: Add Docker-specific cleanup script..."
cat << EOF |sudo tee "${TARGET}.docker/usr/share/baseimage-helpers/apt-cleanup.d/docker.sh"
#!/bin/sh
set -e

# Minimize Docker image size by removing documentation,
# manuals, locales

rm -rf /usr/share/doc/*
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
EOF

sudo chroot "${TARGET}.docker" sh /usr/share/baseimage-helpers/apt-cleanup.d/docker.sh