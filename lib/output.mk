# ==============================================================================
# Colors

ifeq ($(shell which tput &> /dev/null; echo $$?), 0)
	RED	  := $(shell tput setaf 1)
	GREEN 	  := $(shell tput setaf 2)
	YELLOW 	  := $(shell tput setaf 3)
	LIGHTBLUE := $(shell tput setaf 4)
	NOCOL     := $(shell tput sgr0)
else
	RED	  := ""
	GREEN 	  := ""
	YELLOW 	  := ""
	LIGHTBLUE := ""
        NOCOL     := ""
endif

# ==============================================================================
# Output
INTERACTIVE:=$(shell [ -t 0 ] && echo 1)

# Set short time format if in interactive terminal
ifdef INTERACTIVE
	# Short local time
	TIME	?= $$(date +"%H:%M:%S ")
else
	# Full time format in UTC
	TIME	?= $$(date -u +"%Y-%m-%dT%H:%M:%S%z ")
endif

SEP     := --------------------------------------------------------------------------------

ifeq ($(DEBUG), true)
	DBG	:= @printf -- "$(TIME)[DBG] %s\n"
else
	DBG	= @true || echo 
endif

INFO	= @printf -- "$(TIME)[INF] %s\n"
WARN	= @printf -- "$(TIME)$(YELLOW)[WRN]$(NOCOL) %s\n"
ERR	= @printf -- "$(TIME)$(RED)[ERR]$(NOCOL) %s\n"
OK	= @printf -- "$(TIME)$(GREEN)[OK ]$(NOCOL) %s\n"
HEADER  = @printf -- "$(TIME)[INF] $(SEP)\n$(TIME)[INF] $(LIGHTBLUE)%s$(NOCOL)\n$(TIME)[INF] $(SEP)\n"

START	= @printf -- "$(TIME)[INF] Starting $(LIGHTBLUE)%s$(NOCOL)\n"
DONE	= @printf -- "$(TIME)$(GREEN)[OK ]$(NOCOL) Done $(LIGHTBLUE)%s$(NOCOL)\n"
