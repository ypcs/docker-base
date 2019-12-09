NAMESPACE = ypcs

DEBIAN_SUITES = stretch buster sid bullseye
DEBIAN_MIRROR ?= http://deb.debian.org/debian

UBUNTU_SUITES = bionic xenial cosmic disco eoan
UBUNTU_MIRROR ?= http://archive.ubuntu.com/ubuntu

APT_PROXY ?= 127.0.0.1:3142

SUDO = /usr/bin/sudo
DEBOOTSTRAP = /usr/sbin/debootstrap
DEBOOTSTRAP_FLAGS = --variant=minbase
TAR = /bin/tar

DOCKER ?= docker

all: clean $(DEBIAN_SUITES) $(UBUNTU_SUITES)

alllocalmirror: clean
	$(MAKE) DEBIAN_MIRROR=http://$(APT_PROXY)/deb.debian.org/debian UBUNTU_MIRROR=http://$(APT_PROXY)/archive.ubuntu.com/ubuntu DOCKER="/bin/true"

push:
	$(DOCKER) push $(NAMESPACE)/debian
	$(DOCKER) push $(NAMESPACE)/ubuntu

clean:
	rm -rf *.tar *.tar.gz chroot-*

$(DEBIAN_SUITES): % : debian-%.tar import-debian-%

$(UBUNTU_SUITES): % : ubuntu-%.tar import-ubuntu-%

%.tar: chroot-%
	$(TAR) -C $< -c . -f $@
	./scripts/lxc-metadata.sh $(patsubst %.tar,%,$@)

import-debian-%: debian-%.tar
	$(DOCKER) import - "$(NAMESPACE)/debian:$*" < $<

import-ubuntu-%: ubuntu-%.tar
	$(DOCKER) import - "$(NAMESPACE)/ubuntu:$*" < $<

push-debian-%: import-debian-%
	$(DOCKER) push "$(NAMESPACE)/debian:$*"

push-ubuntu-%: import-ubuntu-%
	$(DOCKER) push "$(NAMESPACE)/ubuntu:$*"

chroot-debian-%:
	$(DEBOOTSTRAP) $(DEBOOTSTRAP_FLAGS) $* $@ $(DEBIAN_MIRROR)
	rsync --chown=root:root -avh rootfs/* $@/
	chroot $@ bash -c 'UBUNTU_MIRROR="$(UBUNTU_MIRROR)" DISTRIBUTION="debian" CODENAME="$*" run-parts --verbose --report --exit-on-error --regex ".*\.sh$$" /usr/lib/baseimage-helpers/build'

chroot-ubuntu-%:
	$(DEBOOTSTRAP) $(DEBOOTSTRAP_FLAGS) $* $@ $(UBUNTU_MIRROR)
	rsync --chown=root:root -avh rootfs/* $@/
	chroot $@ bash -c 'DEBIAN_MIRROR="$(DEBIAN_MIRROR)" DISTRIBUTION="ubuntu" CODENAME="$*" run-parts --verbose --report --exit-on-error --regex ".*\.sh$$" /usr/lib/baseimage-helpers/build'

images:
	$(MAKE) -C $@

.PHONY: images
