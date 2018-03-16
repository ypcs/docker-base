# docker
Misc scripts for building Docker images

## Debian images
This assumes that your build host is Debian, and you've installed docker.io package.

### Build images
This creates Docker images and also exports them as `.tar` archives

    sudo make <wheezy|jessie|stretch|sid>


