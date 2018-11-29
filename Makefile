TEMP_FOLDER ?= /tmp/Saber.dst

PREFIX ?= /usr/local
INSTALL_PATH = $(PREFIX)/bin/saber

SWIFT_BUILD_FLAGS = --configuration release
SWIFT_TEST_FLAGS = -Xswiftc -DTEST

BIN_PATH = $(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/SaberLauncher

VERSION_SOURCE = SaberVersion
VERSION_SWIFT_SOURCE = Sources/Saber/SaberVersion.swift
CURRENT_VERSION = $(shell cat "$(VERSION_SOURCE)")

clean:
	rm -rf "$(TEMP_FOLDER)"
	swift package clean

build:
	swift build $(SWIFT_BUILD_FLAGS) $(SWIFT_BUILD_XFLAGS)

install: clean build
	install -d "$(INSTALL_PATH)"
	install "$(BIN_PATH)" "$(INSTALL_PATH)"

uninstall:
	rm -rf "$(INSTALL_PATH)"

test: clean
	swift test $(SWIFT_TEST_FLAGS)

docker_linux_test:
	swift test --generate-linuxmain
	docker run --rm -i -t --volume "$(shell pwd):/package" --workdir "/package" swift:4.2 /bin/bash -c "make test"

xcodeproj:
	swift package generate-xcodeproj --xcconfig-overrides Saber.xcconfig

get_version:
	@echo "$(CURRENT_VERSION)"

set_version:
	$(eval NEW_VERSION := $(filter-out $@,$(MAKECMDGOALS)))
	@echo "$(NEW_VERSION)" > "$(VERSION_SOURCE)"
	@echo "// DO NOT EDIT! See Makefile 'set_version'" > "$(VERSION_SWIFT_SOURCE)"
	@echo "public let saberVersion = \"$(NEW_VERSION)\"" >> "$(VERSION_SWIFT_SOURCE)"

%:
	@:
