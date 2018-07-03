#! /bin/bash

usage="`dirname $0` [ -h | --help ] <tag>" || exit 1
detailedusage="Usage: $usage"

sourcedir=`dirname $0` || exit 1
source "$sourcedir/shared_constants.sh" || exit 1


# Make sure the same input files are used during the whole experiment,
# because something may be adding files while the experiment is running.
# allfiles=`ls "$indir"`
# allfiles='dpc-bmm-001081-nl-sen.naf'
# allfiles='WR-P-P-G-0000000020.naf'
# allfiles='very much gibberish'

# 103 random files without problems
allfiles='
dpc-bmm-001086-nl-sen.naf
dpc-bmm-001092-nl-sen.naf
dpc-bmm-001096-nl-sen.naf
dpc-cam-001282-nl-sen.naf
dpc-dns-001069-nl-sen.naf
dpc-ind-001635-nl-sen.naf
dpc-ind-001641-nl-sen.naf
dpc-ind-001645-nl-sen.naf
dpc-ind-001651-nl-sen.naf
dpc-kok-001326-nl-sen.naf
dpc-riz-001055-nl-sen.naf
dpc-riz-001057-nl-sen.naf
dpc-riz-001060-nl-sen.naf
dpc-svb-000431-nl-sen.naf
wiki-11.naf
wiki-1181.naf
wiki1609.naf
wiki3821.naf
wiki5452.naf
wiki60.naf
wiki6616.naf
wiki7891.naf
wiki889.naf
wiki89.naf
WR-P-E-C-0000000036.naf
WR-P-E-E-0000000020.naf
WR-P-E-H-0000000027.naf
WR-P-E-H-0000000040.naf
WR-P-E-H-0000000050.naf
WR-P-E-I-0000000014.naf
WR-P-E-I-0000011406.naf
WR-P-E-J-0000000014.naf
WR-P-E-J-0000000029.naf
WR-P-P-C-0000000001.naf
WR-P-P-C-0000000006.naf
WR-P-P-C-0000000037.naf
WR-P-P-C-0000000041.naf
WR-P-P-C-0000000047.naf
WR-P-P-C-0000000052.naf
WR-P-P-H-0000000002.naf
WR-P-P-H-0000000011.naf
WR-P-P-H-0000000016.naf
WR-P-P-H-0000000018.naf
WR-P-P-H-0000000019.naf
WR-P-P-H-0000000032.naf
WR-P-P-H-0000000042.naf
WR-P-P-H-0000000066.naf
WR-P-P-H-0000000068.naf
WR-P-P-H-0000000070.naf
WR-P-P-H-0000000074.naf
WR-P-P-H-0000000079.naf
WR-P-P-H-0000000082.naf
WR-P-P-H-0000000097.naf
WR-P-P-H-0000000098.naf
WR-P-P-H-0000000100.naf
WR-P-P-H-0000000103.naf
WR-P-P-H-0000000104.naf
WR-P-P-I-0000000013.naf
WR-P-P-I-0000000016.naf
WR-P-P-I-0000000019.naf
WR-P-P-I-0000000021.naf
WR-P-P-I-0000000043.naf
WR-P-P-I-0000000045.naf
WR-P-P-I-0000000051.naf
WR-P-P-I-0000000057.naf
WR-P-P-I-0000000064.naf
WR-P-P-I-0000000066.naf
WR-P-P-I-0000000069.naf
WR-P-P-I-0000000088.naf
WR-P-P-I-0000000132.naf
WR-P-P-I-0000000143.naf
WR-P-P-I-0000000146.naf
WR-P-P-I-0000000150.naf
WR-P-P-I-0000000154.naf
WR-P-P-I-0000000155.naf
WR-P-P-I-0000000164.naf
WR-P-P-I-0000000169.naf
WR-P-P-I-0000000170.naf
WR-P-P-I-0000000171.naf
WR-P-P-I-0000000176.naf
WR-P-P-I-0000000186.naf
WR-P-P-I-0000000192.naf
WR-P-P-I-0000000205.naf
WR-P-P-I-0000000206.naf
WR-P-P-I-0000000210.naf
WR-P-P-I-0000000211.naf
WR-P-P-I-0000000215.naf
WR-P-P-I-0000000219.naf
WR-P-P-I-0000000233.naf
WR-P-P-I-0000000238.naf
WR-P-P-I-0000000261.naf
WS-U-E-A-0000000014.naf
WS-U-E-A-0000000024.naf
WS-U-E-A-0000000036.naf
WS-U-E-A-0000000042.naf
WS-U-E-A-0000000047.naf
WS-U-E-A-0000000212.naf
WS-U-E-A-0000000218.naf
WS-U-E-A-0000000223.naf
WS-U-E-A-0000000227.naf
WS-U-E-A-0000000243.naf
WS-U-E-A-0000000245.naf
WS-U-E-A-0000000246.naf
'

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
