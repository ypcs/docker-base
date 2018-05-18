DEBIAN_SUITES = wheezy jessie stretch buster sid
UBUNTU_SUITES = artful bionic trusty xenial

all: $(DEBIAN_SUITES) $(UBUNTU_SUITES)

clean:
	rm -rf artifacts baseimage.*

$(DEBIAN_SUITES): %:
	sh ./build.sh $<

$(UBUNTU_SUITES): %:
	sh ./build.sh $<
