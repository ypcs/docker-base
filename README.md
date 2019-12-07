# Base images for containers etc.

This repository contains various scripts for generating somewhat standardized Debian/Ubuntu base images for containers and other usages.

Docker images built using these scripts are available at Docker Hub: [ypcs/debian](https://hub.docker.com/r/ypcs/debian) and [ypcs/ubuntu](https://hub.docker.com/r/ypcs/ubuntu).
## Debian images
This assumes that your build host is Debian, and you've installed docker.io package.

### Build images
This creates Docker images and also exports them as `.tar` archives

    sudo make <wheezy|jessie|stretch|sid>

Images are also imported into Docker, by default with namespace `ypcs/{debian,ubuntu}:{codename}`

## Docker
You may import images using

    docker import - <image> < <rootfs tar>

eg.

    docker import - ypcs/debian:sid < debian-sid.tar


## LXC
To import images into LXC, execute

    lxc image import <metadata .tar.gz> <rootfs tar> --alias <name of the image>

eg.

    lxc image import debian-sid_metadata.tar.gz debian-sid.tar --alias debian-sid
