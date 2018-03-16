NAMESPACE = ypcs

DEBIAN_SUITES = wheezy jessie stretch buster sid
DEBIAN_MIRROR ?= http://deb.debian.org/debian

UBUNTU_SUITES = artful bionic trusty xenial
UBUNTU_MIRROR ?= http://archive.ubuntu.com/ubuntu

SUDO = /usr/bin/sudo
DEBOOTSTRAP = /usr/sbin/debootstrap
DEBOOTSTRAP_FLAGS = --variant=minbase
TAR = /bin/tar

all: $(DEBIAN_SUITES) $(UBUNTU_SUITES)

push:
	docker push $(NAMESPACE)/debian
	docker push $(NAMESPACE)/ubuntu

clean:
	rm -rf *.tar chroot-*

$(DEBIAN_SUITES): % : debian-%.tar

$(UBUNTU_SUITES): % : ubuntu-%.tar

%.tar: chroot-%
	$(TAR) -C $< -c . -f $@

chroot-debian-%:
	$(DEBOOTSTRAP) $(DEBOOTSTRAP_FLAGS) $* $@ $(DEBIAN_MIRROR)
	mkdir -p $@/usr/lib/docker-helpers
	cp helpers/* $@/usr/lib/docker-helpers/
	chmod +x $@/usr/lib/docker-helpers/*
	cp setup.sh $@/tmp/setup.sh
	chmod +x $@/tmp/setup.sh
	chroot $@ /tmp/setup.sh debian $* $(DEBIAN_MIRROR)
	rm -f $@/tmp/setup.sh

chroot-ubuntu-%:
	$(DEBOOTSTRAP) $(DEBOOTSTRAP_FLAGS) $* $@ $(UBUNTU_MIRROR)
	mkdir -p $@/usr/lib/docker-helpers
	cp helpers/* $@/usr/lib/docker-helpers/
	chmod +x $@/usr/lib/docker-helpers/*
	cp setup.sh $@/tmp/setup.sh
	chmod +x $@/tmp/setup.sh
	chroot $@ /tmp/setup.sh ubuntu $* $(UBUNTU_MIRROR)
	rm -f $@/tmp/setup.sh

import-all:
	./import.sh

images:
	$(MAKE) -C $@

.PHONY: images
