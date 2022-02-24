list=$(find . -mindepth 2 -name .mk -a ! -path '*_*' | sed 's/^\.\///' | sort)
addition=$(sed 's/[a-zA-Z\-]\+\/.mk/.mk/' <<< $list | awk '$1 != ".mk" { print $1 }' | sort | uniq)

while [[ "$addition" != "" ]]; do
    list=$(echo -e "$list\n$addition" | sort | uniq)
    addition=$(sed 's/[a-zA-Z\-]\+\/.mk/.mk/' <<< $addition | awk '$1 != ".mk" { print $1 }' | sort | uniq)
done

cat <<< $list
