#! /bin/sh

usage="`basename $0` [ -h | --help ] <tag>" || exit 1
detailedusage="
Usage: $usage

Summarize the results of an experiment of coref_draft.
See https://github.com/mpvharmelen/coref_draft/releases for the available tags.
Any description that git will understand when using \`git checkout <description>\`
is accepted as "tag".
"

sourcedir="`dirname $0`" || exit 1

. "$sourcedir/shared_constants.sh" || exit 1

"$sourcedir/results_to_markdown.py" < "$resultsfile" > "$summaryfile" || exit 1
