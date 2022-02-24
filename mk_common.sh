# 1 - input

set -e

INPUT_FILE=$(sed 's/\.\///' <<< $1)

DIR=$(dirname $INPUT_FILE)
KEYS=tmp/__keys/$DIR
LOGS=tmp/__logs/$DIR
TMP=tmp/t/$DIR

rm -rf $KEYS
rm -rf $TMP

SUB_FILES=$(find $DIR -mindepth 2 -maxdepth 2 -name .mk)
SUB_DIRS=$(echo $SUB_FILES | sed 's/\/.mk$//g')
CLEAN=$DIR.clean

header=$(cat << EOS
.PHONY: $DIR $CLEAN
clean: $CLEAN
$DIR: $SUB_DIRS $KEYS/done
    @ true

$KEYS/done: $KEYS/dirs
    touch \$@

$KEYS/dirs:
    mkdir -p $KEYS
    mkdir -p $TMP
    touch \$@

$CLEAN:
    rm -rf $KEYS
    rm -rf $TMP
EOS
)

cat <<< $header | sed 's/^\s\+/\t/'
