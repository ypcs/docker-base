# Base images for containers etc.

This repository contains various scripts for generating somewhat standardized Debian/Ubuntu base images for containers and other usages.

Docker images built using these scripts are available at Docker Hub: [ypcs/debian](https://hub.docker.com/r/ypcs/debian) and [ypcs/ubuntu](https://hub.docker.com/r/ypcs/ubuntu).
## Debian images
This assumes that your build host is Debian, and you've installed docker.io package.

### Build images
This creates Docker images and also exports them as `.tar` archives

    sudo make <wheezy|jessie|stretch|sid>

Images are also imported into Docker, by default with namespace `ypcs/{debian,ubuntu}:{codename}`
