#!/bin/sh
set -e

[ -z "${DOCKER_TARGET}" ] && echo "E: Missing target!" && exit 1

echo "I: Add Docker-specific cleanup script..."
cat > "${DOCKER_TARGET}/usr/share/baseimage-helpers/cleanup.d/docker.sh" << EOF
#!/bin/sh
set -e

# Minimize Docker image size by removing documentation,
# manuals, locales

rm -rf /usr/share/doc/*
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
EOF

chroot "${DOCKER_TARGET}" sudo sh /usr/share/baseimage-helpers/cleanup.d/docker.sh