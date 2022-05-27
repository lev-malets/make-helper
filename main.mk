ROOT_DIR := $(abspath .)
TMP_DIR := tmp
KEYS := tmp/__keys
LOGS := tmp/__log

path0 = $(notdir $(patsubst %/,%,$@))
path1 = $(notdir $(patsubst %/,%,$(dir $(patsubst %/,%,$@))))
path2 = $(notdir $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $(patsubst %/,%,$@))))))

T_of = $(TMP_DIR)/t/$1

force: ;

MAIN_FILE := $(lastword $(MAKEFILE_LIST))
HELPER_DIR := $(patsubst %/,%,$(dir $(MAIN_FILE)))

touch = mkdir -p $(dir $@) && touch $@

_ := $(shell HELPER_DIR=$(HELPER_DIR) make --makefile=$(HELPER_DIR)/mk.mk) all)

include $(shell find tmp/__mk -name .mk | sort)

%: __default/%
	@ true $^
