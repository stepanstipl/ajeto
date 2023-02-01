# ajeto

_The name "... a je to!" comes from Czechoslovak animated tv series
[^ajeto-name] and can be translated as "... and it's done!"._

[^ajeto-name]: https://en.wikipedia.org/wiki/Pat_%26_Mat

Build and CI framework (Make-based) and collection of opinionated dev standards
(mostly for Go and Terraform) to avoid per-project repetition and provide
better-quality and well-tested tooling.

## Install

Add submodule to your project:

```
git submodule add https://github.com/stepanstipl/ajeto ajeto
```

## Common Targets

*.platform - runs for every platform being built

```
build.init
build.code
build.code.platform
build.artifacts
build.artifacts.platform
build.done

build.all          - All commands for all platforms
build.platform     - All commands for given platform
build              - All commands for host platform

container.build.all
container.build.[PLATFORM]
container.build.

clean

lint.init
lint.run
lint.done

test.init
test.run
test.done

e2e.init
e2e.run
e2e.done
```

## Todo

NIX tests
- vars are set
- script exists and is executable

- Container image (? single or multiple?)
  - multiple
  - lint all
  - build selectively?
  - multiple platforms
  - parallel approach to go binaries
- Check git commit messages
- Changelog
- Markdown spellchecker
- Go projects
- Terraform
- GH workflows
- Virus scanning
