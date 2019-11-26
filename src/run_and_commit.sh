#! /bin/bash

usage="`dirname $0` [ -h | --help ] <tag>" || exit 1
detailedusage="
Usage: $usage

Create the necessary files to run an experiment of coref_draft,
then run the experiment and finally commit the result.

See https://github.com/mpvharmelen/coref_draft/releases for the available tags.
Any description that git will understand when using \`git checkout <description>\`
is accepted as "tag".
"

sourcedir="`dirname $0`" || exit 1

. "$sourcedir/shared_constants.sh" || exit 1


# Get the most recently added configuration files
echo "Copying configuration files..."
prevtag=`git -C "$sourcedir" log -n 1 --format=oneline | cut -d' ' -f5` || exit 1
prevnaf2conllconfig=${naf2conllconfig/$tag/$prevtag}
prevmsc_args_file=${msc_args_file/$tag/$prevtag}

# Copy the old files to the new place
cp "$prevnaf2conllconfig" "$naf2conllconfig" || exit 1
cp "$prevmsc_args_file" "$msc_args_file" || exit 1

# Run the experiment
"$sourcedir/run.sh" "$tag" || exit 1

# Create the commit message
# https://git-scm.com/docs/pretty-formats#Documentation/pretty-formats.txt-s
echo "Composing commit message..."
echo -en "Add configuration for $tag\n\n> " > "$commitmessagefile" || exit 1
git -C "$localcorefcopy" log -n 1 --format='format:%s' "$tag" >> "$commitmessagefile" || exit 1
echo >> "$commitmessagefile" || exit 1
cat "$summaryfile" >> "$commitmessagefile" || exit 1

# Commit and push the result
echo "Committing and pushing..."
git add "$naf2conllconfig" "$msc_args_file" || exit 1
git -C "$sourcedir" commit -F "$commitmessagefile" || exit 1
git push || exit 1

exit 0
