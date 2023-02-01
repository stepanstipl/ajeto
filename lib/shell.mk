LINT_REQUIRED_BINS += shellcheck
TEST_REQUIRED_BINS += bats

ifeq ($(origin SHELLCHECK_CMD), undefined)
	SHELLCHECK_CMD := shellcheck -s bash
	SHELLCHECK_CMD_BATS := shellcheck -s bash
endif
ifeq ($(origin BATS_CMD), undefined)
	BATS_CMD := bats
endif

SHELL_SRCS := $(shell $(FIND_CMD) '*.sh')
BATS_SRCS := $(shell $(FIND_CMD) '*.bats')

ifeq ($(origin BATS_LIB_PATH), undefined)
	export BATS_LIB_PATH ?= $(shell brew --prefix)/lib
endif

## Lint all .sh and .bats files using shellcheck
shell.lint:
	$(START) "$(@)"
ifneq ($(SHELL_SRCS),)
	$(INFO) "Checking $(SHELL_SRCS)"$(\n)
	@$(SHELLCHECK_CMD) $(SHELL_SRCS)
endif
ifneq ($(BATS_SRCS),)
	$(INFO) "Checking $(BATS_SRCS)"$(\n)
	@$(SHELLCHECK_CMD_BATS) $(BATS_SRCS)
endif
	$(DONE) "$(@)"
.PHONY: shell.lint

lint.run: shell.lint

## Test all .bats files using bats
shell.test:
	$(START) "$(@)"
	$(INFO) "Testing $(BATS_SRCS)"$(\n)
	@$(BATS_CMD) $(BATS_SRCS)
	$(DONE) "$(@)"
.PHONY: shell.test

test.run: shell.test
