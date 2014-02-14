VENDOR_DIR := $(CURDIR)/vendor

GOPATH ?= $(VENDOR_DIR)
export GOPATH

ifeq ($(VERBOSE), 1)
GO_OPTIONS += -v
endif

VERSION=$(shell cat VERSION)

.PHONY: all clean

all:
	git submodule init && git submodule update
	test -f $(CURDIR)/build/lib/libdevmapper.a || (cd lvm2 && ./configure --prefix $(CURDIR)/build --enable-static_link && make device-mapper && make install_device-mapper)
	PATH="$(PATH):$(CURDIR)/go/bin" GOROOT="$(CURDIR)/go" CGO_CFLAGS="-I $(CURDIR)/build/include/" CGO_LDFLAGS="-L $(CURDIR)/build/lib/" DOCKER_BUILDTAGS="exclude_graphdriver_btrfs" ./hack/make.sh binary

clean:
	rm -rf $(dir $(DOCKER_BIN))

install:
	mkdir -p ${DESTDIR}/usr/bin
	install -m 0755 bundles/${VERSION}/binary/docker-${VERSION} ${DESTDIR}/usr/bin/docker
