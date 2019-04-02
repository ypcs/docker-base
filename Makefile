NAMESPACE = ypcs

DEBIAN_SUITES = stretch buster sid
DEBIAN_MIRROR ?= http://deb.debian.org/debian

UBUNTU_SUITES = bionic xenial cosmic disco
UBUNTU_MIRROR ?= http://archive.ubuntu.com/ubuntu

SUDO = /usr/bin/sudo
DEBOOTSTRAP = /usr/sbin/debootstrap
DEBOOTSTRAP_FLAGS = --variant=minbase
TAR = /bin/tar

all: clean $(DEBIAN_SUITES) $(UBUNTU_SUITES)

push:
	docker push $(NAMESPACE)/debian
	docker push $(NAMESPACE)/ubuntu

clean:
	rm -rf *.tar chroot-*

$(DEBIAN_SUITES): % : debian-%.tar import-debian-%

$(UBUNTU_SUITES): % : ubuntu-%.tar import-ubuntu-%

%.tar: chroot-%
	$(TAR) -C $< -c . -f $@

import-debian-%: debian-%.tar
	docker import - "$(NAMESPACE)/debian:$*" < $<

import-ubuntu-%: ubuntu-%.tar
	docker import - "$(NAMESPACE)/ubuntu:$*" < $<

push-debian-%: import-debian-%
	docker push "$(NAMESPACE)/debian:$*"

push-ubuntu-%: import-ubuntu-%
	docker push "$(NAMESPACE)/ubuntu:$*"

chroot-debian-%:
	$(DEBOOTSTRAP) $(DEBOOTSTRAP_FLAGS) $* $@ $(DEBIAN_MIRROR)
	cp -a rootfs/* $@/
	chroot $@ bash -c 'UBUNTU_MIRROR="$(UBUNTU_MIRROR)" run-parts --verbose --report --exit-on-error --regex ".*\.sh$$" /usr/lib/docker-helpers/build'

chroot-ubuntu-%:
	$(DEBOOTSTRAP) $(DEBOOTSTRAP_FLAGS) $* $@ $(UBUNTU_MIRROR)
	cp -a rootfs/* $@/
	chroot $@ bash -c 'DEBIAN_MIRROR="$(DEBIAN_MIRROR)" run-parts --verbose --report --exit-on-error --regex ".*\.sh$$" /usr/lib/docker-helpers/build'

images:
	$(MAKE) -C $@

.PHONY: images
