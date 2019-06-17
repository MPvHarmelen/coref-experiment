#! /bin/bash

usage="`dirname $0` [ -h | --help ] <tag>" || exit 1
detailedusage="Usage: $usage"

sourcedir=`dirname $0` || exit 1
source "$sourcedir/shared_constants.sh" || exit 1


keepfile(){ echo "$1" >> "$infileslog"; }
skipfile(){ echo "$1" >> "$skippedlog"; }



if [[ -f "$infileslog" ]]; then
    errcho ERROR: Input file list already exists: $infileslog
    exit 1
else
    touch "$infileslog"
fi

if [[ -f "$skippedlog" ]]; then
    errcho ERROR: Skipped file list already exists: $skippedlog
    exit 1
else
    touch "$skippedlog"
fi

if [[ -f "$goldfile" ]]; then
    errcho ERROR: Gold data file already exists: $goldfile
    exit 1
fi




# Aggregate gold data
for filename in $allfiles; do
    # Find out whether we should ignore this file
    should_ignore='nope'
    for ignoredfile in $ignoredfiles; do
        if [ "$ignoredfile" == "$filename" ]; then
            should_ignore='yes'
        fi
    done

    conllfile=$golddir/${filename%.naf}.conll

    # Ignore if we should
    if [[ "$should_ignore" == 'yes' ]]; then
        echo Ignoring $filename because it is known to have a problem
        skipfile "$filename" || exit 1

    # Ignore if it's empty or non-existent
    elif [[ ! -s "$indir/$filename" ]]; then
        echo $filename is empty, skipping
        # wc -c "$indir/$filename" >&2
        skipfile "$filename" || exit 1

    # Ignore if the gold is empty or non-existent
    elif [[ ! -s "$conllfile" ]]; then
        echo No gold for $filename, skipping
        skipfile "$filename" || exit 1

    # Add it to the input list
    else
        cat "$conllfile" >> "$goldfile" \
            && keepfile "$filename" \
            || exit 1
    fi
done


ninfiles="`cat "$infileslog" | wc -l`" || exit 1
echo Skipped `cat "$skippedlog" | wc -l` files, kept $ninfiles
