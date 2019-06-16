#! /bin/bash

usage="`dirname $0` [ -h | --help ] <tag>" || exit 1
detailedusage="Usage: $usage"

sourcedir=`dirname $0` || exit 1
source "$sourcedir/shared_constants.sh" || exit 1

if [ ! -d "$envdir" ]; then
    mkdir $envdir
fi
if [ ! -d "$codedir" ]; then
    mkdir $codedir
fi


# multisieve_coreference environment
if [ ! -d "$expenv" ]; then
    # Check the tag
    echo Verifying tag...
    tag_exists="`git ls-remote "$corefrepo" "$tag" | wc -l`"

    if [[ "$tag_exists" != "1" ]]; then
        # Fingers crossed and hope that git-checkout will understand
        echo Tag not found, but I\'ll try to use it anyway.
    fi

    echo Setting up experiment environment...
    virtualenv "$expenv" -p python3 > /dev/null || exit 1
    activate "$expenv" || exit 1
    pip install --quiet "git+$corefrepo@$tag" || exit 1
    deactivate
fi

# naf2conll environment
if [ ! -d "$naf2conllenv" ]; then
    echo Setting up NAF to CoNLL converter environment...
    virtualenv "$naf2conllenv" -p python3 > /dev/null || exit 1
    activate "$naf2conllenv" || exit 1
    pip install --quiet "$naf2conllpackage" || exit 1
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
