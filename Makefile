#############################
# Global vars
#############################
PROJECT_NAME := $(shell basename $(shell pwd))
PROJECT_VER  ?= $(shell git describe --tags --always --dirty | sed -e '/^v/s/^v\(.*\)$$/\1/g')
# Last released version (not dirty) without leading v
PROJECT_VER_TAGGED  := $(shell git describe --tags --always --abbrev=0 | sed -e '/^v/s/^v\(.*\)$$/\1/g')

SRCDIR       ?= .
GO            = go

# The root module (from go.mod)
PROJECT_MODULE  ?= $(shell $(GO) list -m)
BUILD_DIR  ?= ./bin/

# $b replaced by the binary name in the compile loop, -s/w remove debug symbols
LDFLAGS    ?= "-s -w -X main.version=$(PROJECT_VER) -X main.appName=$$b -X $(PROJECT_MODULE)/internal/client.version=$(PROJECT_VER)"
SRCDIR     ?= .
COMPILE_OS ?= darwin linux windows

# Determine commands by looking into cmd/*
COMMANDS   ?= $(wildcard ${SRCDIR}/cmd/*)

# Determine binary names by stripping out the dir names
BINS       := $(foreach cmd,${COMMANDS},$(notdir ${cmd}))

GOOS := darwin


.PHONY: bootstrap
bootstrap: clean deps

.PHONY: deps
deps:
	dep ensure -v

.PHONY: clean
clean:
	rm -rf ./vendor/
	rm -rf ./dist/
	rm -rf ./git-chglog
	rm -rf $(GOPATH)/bin/git-chglog
	rm -rf cover.out

.PHONY: build
build: compile

.PHONY: test
test:
	go test -v `go list ./... | grep -v /vendor/`

.PHONY: coverage
coverage:
	goverage -coverprofile=cover.out `go list ./... | grep -v /vendor/`
	go tool cover -func=cover.out
	@rm -rf cover.out

.PHONY: install
install:
	go install ./cmd/git-chglog

.PHONY: changelog
changelog:
	@git-chglog --next-tag $(tag) $(tag)


.PHONY: compile
compile:
	@echo "=== $(PROJECT_NAME) === [ compile          ]: building commands:"
	@mkdir -p $(BUILD_DIR)/$(GOOS)
	@for b in $(BINS); do \
		echo "=== $(PROJECT_NAME) === [ compile          ]:     $(BUILD_DIR)$(GOOS)/$$b"; \
		BUILD_FILES=`find $(SRCDIR)/cmd/$$b -type f -name "*.go"` ; \
		CGO_ENABLED=0 GOOS=$(GOOS) $(GO) build -ldflags=$(LDFLAGS) -o $(BUILD_DIR)/$(GOOS)/$$b $$BUILD_FILES ; \
	done

# Import fragments
include build/deps.mk
include build/document.mk
include build/release.mk
include build/util.mk
