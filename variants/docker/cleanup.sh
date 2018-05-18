#!/bin/sh
set -e

[ -z "${TARGET}" ] && echo "E: Missing target!" && exit 1

echo "I: Add Docker-specific cleanup script..."
cat > "${TARGET}/usr/share/baseimage-helpers/cleanup.d/docker.sh" << EOF
#!/bin/sh
set -e

# Minimize Docker image size by removing documentation,
# manuals, locales

rm -rf /usr/share/doc/*
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
EOF