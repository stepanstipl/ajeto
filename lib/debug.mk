# ==============================================================================
# Debug targets

debug.vars: 
	# shellcheck disable=SC2016
	$(foreach v, \
        	$(shell echo "$(filter-out .VARIABLES,$(.VARIABLES))" | tr ' ' '\n' | sort), \
		@printf -- "%-s\n" '$(v)=$(subst ','\'',$(subst $(\n), ,$(value $(v))))$(NOCOL)'$(\n) \
    	)
.PHONY: debug.vars

debug.test: 
	$(DBG) "Testing DBG"
	$(INFO) "Testing INFO"
	$(WARN) "Testing WARN"
	$(ERR) "Testing ERR"
	$(OK) "Testing OK"
	$(HEADER) "Test Section echo xxx"
	$(START) "test"
	$(DONE) "test"
	$(INFO) "Shell: $(shell echo $$0)"
.PHONY: debug.test

debug.cmd:
ifndef ARGS
	$(ERR) "\$$ARGS is undefined"
else
	@$(ARGS)
endif
.PHONY: debug.cmd

debug.targets:
	@$(MAKE) -pq : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}'
.PHONY: debug.targets
