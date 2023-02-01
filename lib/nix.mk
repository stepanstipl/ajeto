NIX_INSTALL_SCRIPT := $(SCRIPTS_DIR)/nix-install.sh

## Install Nix
nix.install:
	$(START) "$(@)"
	@HOST_OS="$(HOST_OS)" \
	  $(NIX_INSTALL_SCRIPT)
	$(DONE) "$(@)"
.PHONY: nix.install
