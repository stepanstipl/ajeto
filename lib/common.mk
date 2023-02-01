t ==============================================================================
# Initial setup

# Remove default targets
.SUFFIXES:

# Use bash as std. shell
SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c

# Make config
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables
MAKEFLAGS += --no-print-directory

# Set default target
.DEFAULT_GOAL := help

# Define new line
define \n


endef

# ==============================================================================
# Common variables

# Platforms to build - use go os and arch
ifeq ($(origin PLATFORMS), undefined)
	PLATFORMS ?= darwin_amd64 darwin_arm64 windows_amd64 linux_amd64 linux_arm64
endif

# Host info 
HOST_OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
HOST_ARCH := $(shell uname -m)

# Translate to go arch 
ifeq ($(HOST_ARCH),x86_64)
	HOST_ARCH := amd64
endif
ifeq ($(HOST_ARCH),aarch64)
	HOST_ARCH := arm64
endif

HOST_PLATFORM := $(HOST_OS)_$(HOST_ARCH)

# Set target arch, os and platform to host one, if not set already
ifeq ($(origin TARGET_OS), undefined)
	TARGET_OS := $(HOST_OS)
endif
ifeq ($(origin TARGET_ARCH), undefined)
	TARGET_ARCH := $(HOST_ARCH)
endif
ifeq ($(origin TARGET_PLATFORM), undefined)
	TARGET_PLATFORM := $(HOST_PLATFORM)
endif

# Dirs
COMMON_SELF_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
ifeq ($(origin AJETO_DIR), undefined)
	AJETO_DIR := $(abspath $(COMMON_SELF_DIR)/..)
endif
ifeq ($(origin ROOT_DIR), undefined)
	ROOT_DIR := $(abspath $(CURDIR))
endif
ifeq ($(origin CACHE_DIR), undefined)
	CACHE_DIR := $(ROOT_DIR)/cache
endif
ifeq ($(origin OUTPUT_DIR), undefined)
	OUTPUT_DIR := $(ROOT_DIR)/output
endif
ifeq ($(origin SCRIPTS_DIR), undefined)
	SCRIPTS_DIR := $(ROOT_DIR)/scripts
endif

# Common steps
LINT_REQUIRED_BINS ?=
TEST_REQUIRED_BINS ?=
BUILD_REQUIRED_BINS ?=

# Common cmds
FIND_CMD := find . -name "$(AJETO_DIR:$(ROOT_DIR)=)" -type d -prune -o -type f -iname

# ==============================================================================
# Debug & Output

# Set DEBUG=true to turn on debug logging
export DEBUG ?= false

include $(COMMON_SELF_DIR)/output.mk

# ==============================================================================
# Help

## Print help message
help: targets
.PHONY: help

## List all available make targets
targets:
	# shellcheck disable=SC1004
	$(HEADER) "targets"
	@awk -v time="$(TIME)" 'BEGIN {FS=":"} /^## .*/,/^[a-zA-Z0-9._-]+:/ { \
		if ($$0 ~ /^## /) { desc=substr($$0, 4) } \
		else { printf time "[INF] $(YELLOW)%-30s$(NOCOL) - %s\n", $$1, desc } \
		}' $(MAKEFILE_LIST) | sort
.PHONY: targets

# ==============================================================================
# Common build targets

build.init: ; @:
	$(foreach exec,$(BUILD_REQUIRED_BINS), $(call require_binary,$(exec)))
.PHONY: build.init

build.code: ; @:
.PHONY: build.code

build.artifacts: ; @:
.PHONY: build.artifacts

build.done: ; @:
.PHONY: build.done

build.all:
	@$(MAKE) build.init
	@$(MAKE) build.code
	@$(MAKE) build.artifacts
	@$(MAKE) build.done
.PHONY: build.all

# ==============================================================================
# Common lint targets

lint.init: ; @:
	$(foreach exec,$(LINT_REQUIRED_BINS), $(call require_binary,$(exec)))
.PHONY: lint.init

lint.run: ; @:
.PHONY: lint.run

lint.done: ; @:
.PHONY: lint.done

## Run lint code analysis
lint:
	$(HEADER) lint
	@$(MAKE) lint.init
	@$(MAKE) lint.run
	@$(MAKE) lint.done
.PHONY: lint

# ==============================================================================
# Common test targets

test.init: ; @:
	$(foreach exec,$(TEST_REQUIRED_BINS), $(call require_binary,$(exec)))
.PHONY: test.init

test.run: ; @:
.PHONY: test.run

test.done: ; @:
.PHONY: test.done

## Run tests
test:
	$(HEADER) test
	@$(MAKE) test.init
	@$(MAKE) test.run
	@$(MAKE) test.done
.PHONY: test

# ==============================================================================
# Clean targets

## Clean all files created during the build
clean:
	$(START) "clean"
	@rm -rf $(OUTPUT_DIR)
	$(DONE) "clean"

## Clean all files created during the build, including cache
distclean: clean
	$(START) "distclean"
	@rm -rf $(CACHE_DIR)
	$(DONE) "distclean"

# ==============================================================================
# Common functions
#
define require_binary
$(if $(shell which $(1)),,$(ERR) "No $(1) binary in \$$PATH"; false$(\n))
endef
