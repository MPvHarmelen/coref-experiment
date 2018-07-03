#! /bin/bash

usage="`dirname $0` [ -h | --help ] <tag>" || exit 1
detailedusage="Usage: $usage"

sourcedir=`dirname $0` || exit 1
source "$sourcedir/shared_constants.sh" || exit 1

# multisieve_coreference environment
if [ ! -d "$expenv" ]; then
    # Check the tag
    echo Verifying tag...
    tag_exists="`git ls-remote "$corefrepo" "$tag" | wc -l`"

    if [[ "$tag_exists" != "1" ]]; then
        errcho Tag doesnt exist. Choose between the following tags:
        git ls-remote "$corefrepo" >&2
        exit 1
    fi

    echo Setting up experiment environment...
    virtualenv "$expenv" -p python3 > /dev/null || exit 1
    activate "$expenv" || exit 1
    pip install --quiet "git+https://www.github.com/mpvharmelen/coref_draft@$tag" || exit 1
    deactivate
fi

# naf2conll code
if [ ! -d "$naf2conlldir" ]; then
    echo Downloading NAF to CoNLL converter from $formatconversionsrepo...
    git clone --quiet "$formatconversionsrepo" "$formatconversionsdir" || exit 1
fi
if [ ! -d "$naf2conlldir" ]; then
    errcho ERROR: Failed to download the code for NAF2CoNLL conversion.
    errcho $naf2conll is probably not a direct child of $formatconversionsdir
fi

# naf2conll environment
if [ ! -d "$naf2conllenv" ]; then
    echo Setting up NAF to CoNLL converter environment...
    virtualenv "$naf2conllenv" -p python3 > /dev/null || exit 1
    activate "$naf2conllenv" || exit 1
    pip install --quiet -r "$naf2conlldir/requirements.txt" || exit 1
    deactivate
fi

# scorer
if [ ! -d "$scorerdir" ]; then
    echo Downloading CoNLL scorer from $scorerrepo, version $scorertag...
    # For later
    origdir="`pwd`"
    git clone --quiet "$scorerrepo" "$scorerdir" || exit 1
    cd "$scorerdir" || exit 1
    git checkout --quiet "$scorertag" || exit 1
    # Set the verbosity to 0
    echo "$scorerdiff" | patch --quiet -p1      # It's not fatal if this fails
    cd "$origdir"
fi
