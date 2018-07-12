#! /bin/bash
# Aggregate only

usage="`dirname $0` [ -h | --help ] <tag>" || exit 1
detailedusage="Usage: $usage"

sourcedir=`dirname $0` || exit 1
source "$sourcedir/shared_constants.sh" || exit 1

if [[ -f "$outfile" ]]; then
    errcho ERROR: Aggregated CoNLL file already exists: $outfile
    exit 1
fi

# Aggregate system output
for filepath in "$conlldir"/*; do
    cat "$filepath" >> "$outfile" || exit 1
done

# Check
goldsize=`grep -P . $goldfile | wc -l`
outsize=`grep -P . $outfile | wc -l`

if [[ "$goldsize" != "$outsize" ]]; then
    errcho "WARNING: there are $goldsize lines in the gold data and $outsize lines in the output data. (Small difference are mostly caused by a difference in tokenisation and sentence boundaries.)"
fi
