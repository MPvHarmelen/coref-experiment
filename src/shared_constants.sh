#! /bin/bash

# Functions
errcho(){ >&2 echo $@; }
activate(){ source "$1/bin/activate"; }

# Directory configuration
sourcedir="`dirname "$0"`" || exit 1

expdir="$sourcedir/.."
indir="$expdir/../Data/SoNaR1-NAF"
golddir="$expdir/../Data/SoNaR1-CoNLL-filled-uniqueyfied"

formatconversionsdir=~/repos/FormatConversions
scorerdir=~/repos/reference-coreference-scorers



for arg in $@; do
    if [ "$arg" == '-h' -o "$arg" == '--help' ]; then
        echo "$detailedusage"
        exit 0
    fi
done

# Experiment tag (change to run different experiment)
tag=$1

if [[ -z "$tag" ]]; then
    errcho Please specify a tag to use.
    echo Usage: $usage
    exit 1
fi

verifygold=no
# verifygold=yes

# Repository
corefrepo=git@github.com:mpvharmelen/coref_draft.git
scorerrepo=git@github.com:conll/reference-coreference-scorers.git
scorertag=v8.01
formatconversionsrepo=git@github.com:cltl/FormatConversions

# loglevel=INFO
loglevel=WARNING
scorerverbosity=1


# Make paths absolute
expdir="`realpath "$expdir"`" || exit 1
indir="`realpath "$indir"`" || exit 1

golddir="`realpath "$golddir"`" || exit 1

# It's okay if the following directories don't exist, but then the following
# commands crash.
# formatconversionsdir="`realpath "$formatconversionsdir"`" || exit 1
# scorerdir="`realpath "$scorerdir"`" || exit 1

# Derived names
outdir="$expdir/$tag"
nafdir="$outdir/NAF"
conlldir="$outdir/CoNLL"
outfile="$outdir/system.conll"
goldfile="$outdir/gold.conll"
resultsfile="$outdir/results.txt"
skippedlog="$outdir/skipped_files.txt"
infileslog="$outdir/input_files.txt"
expenv="$expdir/$tag-env"
naf2conlldir="$formatconversionsdir/naf2conll"
naf2conllenv="$naf2conlldir/env"

# Data problems (for details, see:
# - `2018-06-20 - first test.md`
# - `2018-06-19 - verify gold data/2018-06-20 - notes.md`
ignoredfiles='
dpc-bmm-001109-nl-sen.naf
dpc-dns-001068-nl-sen.naf
dpc-qty-000932-nl-sen.naf
wiki-1823.naf
wiki7064.naf
wiki832.naf
wiki8894.naf
WR-P-E-J-0000000005.naf
WR-P-E-J-0000000012.naf
WR-P-P-C-0000000007.naf
WR-P-P-C-0000000046.naf
WR-P-P-H-0000000037.naf
WR-P-P-H-0000000046.naf
WS-U-E-A-0000000216.naf
dpc-ind-001633-nl-sen.naf
dpc-med-000674-nl-sen.naf
wiki1112.naf
wiki1541.naf
wiki1550.naf
wiki209.naf
WR-P-P-I-0000000022.naf
WR-P-P-I-0000000081.naf
WR-P-P-I-0000000108.naf
WR-P-P-I-0000000110.naf
WR-P-P-I-0000000111.naf
WR-P-P-I-0000000112.naf
WR-P-P-I-0000000113.naf
WR-P-P-I-0000000114.naf
WR-P-P-I-0000000115.naf
WR-P-P-I-0000000116.naf
WR-P-P-I-0000000117.naf
WR-P-P-I-0000000118.naf
WR-P-P-I-0000000119.naf
WR-P-P-I-0000000121.naf
WR-P-P-I-0000000122.naf
WR-P-P-I-0000000124.naf
WR-P-P-I-0000000135.naf
WR-P-P-I-0000000144.naf
WR-P-P-I-0000000235.naf
WR-P-P-I-0000000236.naf
WR-P-P-I-0000000256.naf
WR-P-E-I-0000041235.naf
dpc-vla-001161-nl-sen.naf
'

scorerdiff='
diff --git a/lib/CorScorer.pm b/lib/CorScorer.pm
index b6e1b68..397ad4d 100644
--- a/lib/CorScorer.pm
+++ b/lib/CorScorer.pm
@@ -61,7 +61,7 @@ print "version: " . $VERSION . " " . Cwd::realpath(__FILE__) . "\n";
 # 1.02 Corrected BCUB bug. It fails when the key file does not have any mention

 # global variables
-my $VERBOSE         = 2;
+my $VERBOSE         = '"$scorerverbosity"';
 my $HEAD_COLUMN     = 8;
 my $RESPONSE_COLUMN = -1;
 my $KEY_COLUMN      = -1;
'
