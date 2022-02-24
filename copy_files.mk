
$T := $T/_

src_files := $(patsubst $D/%,$T/%,$(shell find $D -maxdepth 1 -mindepth 1 ! -name '_.mk'))
dep_files := $(patsubst $D/%,$T/%,$(shell find $D ! -name '_.mk'))

define cmd
$(src_files): $T/%: | $D/%
	mkdir -p $$(dir $$@)
	ln -s $(ROOT_DIR)/$$(patsubst $T/%,$D/%,$$@) $$@
endef

$(eval $(cmd))
