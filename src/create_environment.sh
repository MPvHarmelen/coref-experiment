#! /bin/sh

usage="`basename $0` [ -h | --help ] <tag>" || exit 1
detailedusage="Usage: $usage"

sourcedir=`dirname $0` || exit 1
. "$sourcedir/shared_constants.sh" || exit 1

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

    if [ "$tag_exists" != "1" ]; then
        # Fingers crossed and hope that git-checkout will understand
        echo Tag not found, but I\'ll try to use it anyway.
    fi

    echo Setting up experiment environment...
    virtualenv "$expenv" -p python3 > /dev/null || exit 1
    activate "$expenv" || exit 1
    pip install --quiet "git+$corefrepo@$tag" || (
        errcho Available tags:
        errcho Any branch name or commit hash, or one of the following tags:
        git ls-remote "$corefrepo" >&2
        errcho Cleaning up broken virtual environment...
        deactivate
        rm -r "$expenv"
        exit 1
    )
    deactivate
fi

# naf2conll environment
if [ ! -d "$naf2conllenv" ]; then
    echo Setting up NAF to CoNLL converter environment...
    virtualenv "$naf2conllenv" -p python3 > /dev/null || exit 1
    activate "$naf2conllenv" || exit 1
    pip install --quiet "$naf2conllpackage" || (
        errcho Cleaning up broken virtual environment...
        deactivate
        rm -r "$naf2conllenv"
        exit 1
    )
    deactivate
fi

# scorer
if [ ! -d "$scorerdir" ]; then
    echo Downloading CoNLL scorer from $scorerrepo, version $scorertag...
    (
        git clone --quiet "$scorerrepo" "$scorerdir" \
        &&
        cd "$scorerdir" \
        &&
        git checkout --quiet "$scorertag" \
        &&
        # It's not fatal if this fails
        # Set the verbosity to 0
        (echo "$scorerdiff" | patch --quiet -p1 || errcho Changing scorer verbosity level failed)
    ) || exit 1
fi
