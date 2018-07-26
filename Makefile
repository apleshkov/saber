PREFIX ?= /usr/local
INST_FOLDER = $(PREFIX)/bin

SWIFT_BUILD_FLAGS = --configuration release

BIN_PATH = $(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)

VERSION_SOURCE = SaberVersion
VERSION_SWIFT_SOURCE = Sources/Saber/SaberVersion.swift
CURRENT_VERSION = $(shell cat "$(VERSION_SOURCE)")

clean:
	swift package clean

build:
	swift build $(SWIFT_BUILD_FLAGS)

install: clean build
	install -d "$(INST_FOLDER)"
	install "$(BIN_PATH)/SaberCLI" "$(INST_FOLDER)/saber"

uninstall:
	rm -rf "$(INST_FOLDER)/saber"

test:
	swift test

get_version:
	@echo "$(CURRENT_VERSION)"

set_version:
	$(eval NEW_VERSION := $(filter-out $@,$(MAKECMDGOALS)))
	@echo "$(NEW_VERSION)" > "$(VERSION_SOURCE)"
	@echo "// DO NOT EDIT! See Makefile 'set_version'" > "$(VERSION_SWIFT_SOURCE)"
	@echo "public let saberVersion = \"$(NEW_VERSION)\"" >> "$(VERSION_SWIFT_SOURCE)"

%:
	@:
