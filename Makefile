VERSION = $(shell GOOS=$(shell go env GOHOSTOS) GOARCH=$(shell go env GOHOSTARCH) \
	go run tools/build-version.go)
SYSTEM = ${GOOS}_${GOARCH}
GOVARS = -X main.Version=$(VERSION)

build:
	go build -trimpath -ldflags "-s -w $(GOVARS)" .

build-dist:
	go build -trimpath -ldflags "-s -w $(GOVARS)" -o dist/bin/binpull-$(VERSION)-$(SYSTEM) .

install:
	go install -trimpath -ldflags "-s -w $(GOVARS)" .

fmt:
	gofmt -s -w .

vet:
	go vet

binpull:
	go build -trimpath -ldflags "-s -w $(GOVARS)" .

test: binpull
	cd test; EGET_CONFIG=binpull.toml EGET_BIN= TEST_EGET=../binpull go run test_binpull.go

binpull.1: man/binpull.md
	pandoc man/binpull.md -s -t man -o binpull.1

package: build-dist binpull.1
	mkdir -p dist/binpull-$(VERSION)-$(SYSTEM)
	cp README.md dist/binpull-$(VERSION)-$(SYSTEM)
	cp LICENSE dist/binpull-$(VERSION)-$(SYSTEM)
	cp binpull.1 dist/binpull-$(VERSION)-$(SYSTEM)
	if [ "${GOOS}" = "windows" ]; then\
		cp dist/bin/binpull-$(VERSION)-$(SYSTEM) dist/binpull-$(VERSION)-$(SYSTEM)/binpull.exe;\
		cd dist;\
		zip -r -q -T binpull-$(VERSION)-$(SYSTEM).zip binpull-$(VERSION)-$(SYSTEM);\
	else\
		cp dist/bin/binpull-$(VERSION)-$(SYSTEM) dist/binpull-$(VERSION)-$(SYSTEM)/binpull;\
		cd dist;\
		tar -czf binpull-$(VERSION)-$(SYSTEM).tar.gz binpull-$(VERSION)-$(SYSTEM);\
	fi

version:
	echo "package main\n\nvar Version = \"$(VERSION)+src\"" > version.go

clean:
	rm -f test/binpull.1 test/fd test/micro test/nvim test/pandoc test/rg.exe
	rm -rf dist

.PHONY: build clean install package version fmt vet test
