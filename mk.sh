#!/bin/bash
# 1 - helper dir; 2 - input

. $1/mk_common.sh $2

function replacement {
    sed 's/\//\\\//g' <<<$1 |
        sed 's/^\s\+/\\t/' |
        sed 's/\&/\\\&/g' |
        awk 'NR == 1 { line = $0 } NR > 1 { line = line "\\n" $0} END { print line }'
}

function mk_args {
    cat <<EOF
$KEYS/args/$1:
    mkdir -p \$(dir \$@)
    touch \$@
EOF
}

function mk_arg {
    cat <<EOF
$KEYS/arg/$1/$2: force
    @ true \$(shell VALUE=$3 bash -c ' \
        (test -f \$@ && test "\$\$(cat \$@)" = "\$\$VALUE") \
        || (mkdir -p \$(dir \$@) && echo \$\$VALUE > \$@ && echo updated \$@)')
$KEYS/args/$1: $KEYS/arg/$1/$2
EOF
}

ext_git_clone_replacement=$(
    cat <<<'
'$KEYS'/repo/commit/\1:
    mkdir -p $(dir $@)
    echo \3 > $@

'$KEYS'/repo/\1: '$KEYS'/repo/commit/\1
    rm -rf '$TMP'/\1
    git clone --no-checkout \2 '$TMP'/\1
    git -C '$TMP'/\1 sparse-checkout set \4
    git -C '$TMP'/\1 config user.email _
    git -C '$TMP'/\1 config user.name _
    git -C '$TMP'/\1 checkout \3 -b _
    mkdir -p $(dir $@)
    touch $@
'
)

ext_git_clone_regexp='^$(clone\s\+\(\w\+\),\([[:graph:]]\+\),\(\w\+\),\([[:graph:][:blank:]]\+\))'
ext_git_clone="s/$ext_git_clone_regexp/$(replacement "$ext_git_clone_replacement")/"

ext_git_patch_replacement=$(
    cat <<EOS
$KEYS/patch/\\1: $KEYS/repo/\\1 \\2
    git -C $TMP/\\1 reset HEAD --hard
    patch -d $TMP/\\1 -p1 < \\2
    git -C $TMP/\\1 add .
    mkdir -p \$(dir \$@)
    touch \$@

$DIR/update_patch/\\1: $KEYS/repo/\\1
    git -C $TMP/\\1 diff HEAD > \\2

.PHONY: $DIR/update_patch/\\1
EOS
)

ext_git_patch_regexp='^$(patch\s\+\(\w\+\),\([[:graph:]]\+\))'
ext_git_patch="s/$ext_git_patch_regexp/$(replacement "$ext_git_patch_replacement")/"

ext_touch="s/"

ext_err_to_log_replacement='(mkdir -p '$LOGS'/$(dir $@) && \1 2> '$LOGS'/$@ || (cat '$LOGS'/$@ && false))'
ext_err_to_log_regexp='$(log_err\s\+\([[:graph:][:blank:]]\+\))'
ext_err_to_log="s/$ext_err_to_log_regexp/$(replacement "$ext_err_to_log_replacement")/"

cat $INPUT_FILE |
    sed 's/$D/'$(replacement $DIR)'/g' |
    sed 's/$K/'$(replacement $KEYS)'/g' |
    sed 's/$T/'$(replacement $TMP)'/g' |
    sed "$ext_git_clone" |
    sed "$ext_git_patch" |
    sed "$ext_err_to_log"
