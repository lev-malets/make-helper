
HELPER_DIR := $(shell echo $$HELPER_DIR)

FILES := $(shell . $(HELPER_DIR)/make_mk_list.sh)
GHOST_FILES := $(foreach file,$(FILES),$(if $(shell test -f $(file) || echo 'x'),$(file)))
REAL_FILES := $(foreach file,$(FILES),$(if $(shell test -f $(file) && echo 'x'),$(file)))

GHOST_TARGETS := $(patsubst %,tmp/__mk/%,$(GHOST_FILES))
REAL_TARGETS := $(patsubst %,tmp/__mk/%,$(REAL_FILES))

all: $(GHOST_TARGETS) $(REAL_TARGETS)

$(GHOST_TARGETS): tmp/__mk/%: $(HELPER_DIR)/mk_common.sh
	mkdir -p $(dir $@)
	. $(HELPER_DIR)/mk_common.sh $(patsubst tmp/__mk/%,%,$@) > $@.tmp
	mv $@.tmp $@

$(REAL_TARGETS): tmp/__mk/%: % $(HELPER_DIR)/mk_common.sh $(HELPER_DIR)/mk.sh
	mkdir -p $(dir $@)
	. $(HELPER_DIR)/mk.sh $(HELPER_DIR) $< > $@.tmp
	mv $@.tmp $@
