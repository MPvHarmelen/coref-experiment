#! /bin/bash

usage="`dirname $0` [ -h | --help ] <tag>" || exit 1
detailedusage="Usage: $usage"

sourcedir=`dirname $0` || exit 1
source "$sourcedir/shared_constants.sh" || exit 1


if [[ ! -s "$infileslog" ]]; then
    errcho No input files selected!
    exit 1
fi

ninfiles="`cat "$infileslog" | wc -l`" || exit 1

# Run the experiment
cd "$naf2conlldir" || exit 1

progress=0
for filename in `cat "$infileslog"`; do
    let progress++
    echo $progress / $ninfiles: Calculating coreferences for $filename...
    activate "$expenv" || exit 1
    cat "$indir/$filename" | python -m multisieve_coreference -l $loglevel > "$nafdir/$filename" || exit 1
    deactivate
    conllout=$conlldir/${filename%.naf}.conll
    activate "$naf2conllenv" || exit 1
    python -m naf2conll -c fill_config.yml "$conllout" "$nafdir/$filename" -l $loglevel || exit 1
    deactivate
done
