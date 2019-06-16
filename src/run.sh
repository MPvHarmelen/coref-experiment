#! /bin/bash

usage="`dirname $0` [ -h | --help ] <tag>" || exit 1
detailedusage="
Usage: $usage

Run an experiment of coref_draft.
See https://github.com/mpvharmelen/coref_draft/releases for the available tags.
Any description that git will understand when using \`git checkout <description>\`
is accepted as "tag".
"

sourcedir="`dirname $0`" || exit 1

source "$sourcedir/shared_constants.sh" || exit 1

# Check the output directory
if [ -d "$outdir" ]; then
    errcho "Output directory exists"
    exit 1
fi

"$sourcedir/create_environment.sh" "$tag" || exit 1

# Create the output directory
# This is done after `create_environment.sh` because it verifies
# the tag
mkdir "$outdir" "$nafdir" "$conlldir" || exit 1

echo Collecting input files...
"$sourcedir/collect_data.sh" "$tag" || exit 1

echo Running experiment...
"$sourcedir/experiment_only.sh" "$tag" || exit 1


if [[ "$verifygold" == 'yes' ]]; then
    "$sourcedir/verify_gold.sh" "$tag" || exit 1
fi


echo Evaluating...
"$sourcedir/aggregate_output.sh" "$tag" || exit 1
"$sourcedir/evaluate.sh" "$tag" || exit 1

exit 0
