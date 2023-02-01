LINT_REQUIRED_BINS += hadolint
BUILD_REQUIRED_BINS += buildah

DOCKERFILE_SRCS := $(shell $(FIND_CMD) '*Dockerfile')

ifeq ($(origin BUILDAH_CMD), undefined)
	BUILDAH_CMD := buildah
endif
ifeq ($(origin HADOLINT_CMD), undefined)
	HADOLINT_CMD := hadolint
endif

## Lint all container files using hadolint
container.lint:
	$(START) "$(@)"
	$(foreach f, \
		$(DOCKERFILE_SRCS), \
		$(INFO) "Checking $(f)"$(\n) \
		@$(HADOLINT_CMD) "$(f)"$(\n))
	$(DONE) "$(@)"
.PHONY: container.lint

lint.run: container.lint
