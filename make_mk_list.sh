addition_substitue='s/[^/]\+\/.mk/.mk/'

list=$(find . -mindepth 2 -name .mk -a -type f -a ! -path './tmp/*' -a ! -path './_build/*' | sed 's/^\.\///' | sort)
addition=$(sed $addition_substitue <<<$list | awk '$1 != ".mk" { print $1 }' | sort | uniq)

while [[ $addition != "" ]]; do
    list=$(echo -e "$list\n$addition" | sort | uniq)
    addition=$(sed $addition_substitue <<<$addition | awk '$1 != ".mk" { print $1 }' | sort | uniq)
done

cat <<<$list
