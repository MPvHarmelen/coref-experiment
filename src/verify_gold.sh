#! /bin/sh

usage="`basename $0` [ -h | --help ] <tag>" || exit 1
detailedusage="Usage: $usage"

sourcedir=`dirname $0` || exit 1
. "$sourcedir/shared_constants.sh" || exit 1

# Find problems
echo Checking the gold for problems...
problems="`"$scorerdir/scorer.pl" all "$goldfile" "$goldfile" | grep -P 'Invented (?!0)|F1: (?!100).+%'`"

if [ ! -z "$problems" ]; then
    errcho There are problems with the gold data
    errcho "$problems"
    exit 1
fi
