#! /bin/sh

# Functions
errcho(){ >&2 echo $@; }
activate(){ source "$1/bin/activate"; }


# Evaluation metric

# muc     MUCScorer (Vilain et al, 1995)
# bcub    B-Cubed (Bagga and Baldwin, 1998)
# ceafm   CEAF (Luo et al, 2005) using mention-based similarity
# ceafe   CEAF (Luo et al, 2005) using entity-based similarity
# blanc   BLANC
# all     uses all the metrics to score   (takes very long)
metric=blanc


# Directory configuration
sourcedir="$(realpath `dirname "$0"`)" || exit 1

expdir="$sourcedir/../../../../Experiments"
configdir="$sourcedir/../config"

indir="$expdir/../Data/SoNaR1-NAF"
golddir="$expdir/../Data/SoNaR1-CoNLL-filled-uniqueyfied"

# The following is only used to read the content of commit messages
# and only in `run_and_commit.sh` (for if you're as lazy as I am.)
localcorefcopy="$sourcedir/../../coref_draft"

for arg in $@; do
    if [ "$arg" = '-h' -o "$arg" = '--help' ]; then
        echo "$detailedusage"
        exit 0
    fi
done

# Experiment tag (change to run different experiment)
tag=$1

if [ -z "$tag" ]; then
    errcho Please specify a tag to use.
    echo Usage: $usage
    exit 1
fi

# Script configuration
naf2conllconfig="$configdir/$tag-naf2conll-config.yml"
msc_args_file="$configdir/$tag-multisieve_coreference-args.txt"
verifygold=no
# verifygold=yes

# Repository
corefrepo=https://github.com/mpvharmelen/coref_draft.git
scorerrepo=https://github.com/conll/reference-coreference-scorers.git
scorertag=v8.01
naf2conllpackage='git+https://github.com/cltl/FormatConversions.git#subdirectory=naf2conll'

# Logging
# loglevel=INFO
loglevel=WARNING
scorerverbosity=1


# Make paths absolute
expdir="`realpath "$expdir"`" || exit 1
indir="`realpath "$indir"`" || exit 1

golddir="`realpath "$golddir"`" || exit 1

# Derived names
outdir="$expdir/experiment-data/$tag"
nafdir="$outdir/NAF"
conlldir="$outdir/CoNLL"
skippedlog="$outdir/skipped_files.txt"
infileslog="$outdir/input_files.txt"
outfile="$outdir/system.conll"
goldfile="$outdir/gold.conll"
resultsfile="$outdir/results.txt"
summaryfile="$outdir/summary.md"
commitmessagefile="$outdir/commit-message.md"

envdir="$expdir/environment"
codedir="$expdir/code"

expenv="$envdir/$tag"
naf2conllenv="$envdir/naf2conll"

scorerdir="$codedir/reference-coreference-scorers"


# Make sure the same input files are used during the whole experiment,
# because something may be adding files while the experiment is running.
# allfiles=`ls "$indir"` || exit 1
# allfiles='dpc-bmm-001081-nl-sen.naf'
# allfiles='WR-P-P-G-0000000020.naf'
# allfiles='very much gibberish'

# 39 random files without problems
allfiles='
dpc-bal-001239-nl-sen.naf
dpc-bmm-001091-nl-sen.naf
dpc-bmm-001098-nl-sen.naf
dpc-bmm-001105-nl-sen.naf
dpc-cam-001280-nl-sen.naf
dpc-dns-001066-nl-sen.naf
dpc-eli-000944-nl-sen.naf
dpc-eup-000017-nl-sen.naf
dpc-fsz-000552-nl-sen.naf
dpc-ind-001649-nl-sen.naf
dpc-kok-001326-nl-sen.naf
dpc-med-000680-nl-sen.naf
dpc-qty-000936-nl-sen.naf
dpc-riz-000460-nl-sen.naf
dpc-rou-000981-nl-sen.naf
dpc-svb-000431-nl-sen.naf
dpc-vhs-000725-nl-sen.naf
wiki1532.naf
wiki5177.naf
wiki-1928.naf
WR-P-E-C-0000000036.naf
WR-P-E-H-0000000009.naf
WR-P-E-I-0000000011.naf
WR-P-E-J-0000000014.naf
WR-P-P-C-0000000038.naf
WR-P-P-F-0000000006.naf
WR-P-P-G-0000000020.naf
WR-P-P-H-0000000001.naf
WR-P-P-H-0000000086.naf
WR-P-P-H-0000000090.naf
WR-P-P-I-0000000010.naf
WR-P-P-I-0000000014.naf
WR-P-P-I-0000000128.naf
WR-P-P-I-0000000262.naf
WR-P-P-J-0000000012.naf
WS-U-E-A-0000000001.naf
WS-U-E-A-0000000002.naf
WS-U-E-A-0000000003.naf
WS-U-E-A-0000000004.naf
'

# 103 random files without problems
# allfiles='
# dpc-bmm-001086-nl-sen.naf
# dpc-bmm-001092-nl-sen.naf
# dpc-bmm-001096-nl-sen.naf
# dpc-cam-001282-nl-sen.naf
# dpc-dns-001069-nl-sen.naf
# dpc-ind-001635-nl-sen.naf
# dpc-ind-001641-nl-sen.naf
# dpc-ind-001645-nl-sen.naf
# dpc-ind-001651-nl-sen.naf
# dpc-kok-001326-nl-sen.naf
# dpc-riz-001055-nl-sen.naf
# dpc-riz-001057-nl-sen.naf
# dpc-riz-001060-nl-sen.naf
# dpc-svb-000431-nl-sen.naf
# wiki-11.naf
# wiki-1181.naf
# wiki1609.naf
# wiki3821.naf
# wiki5452.naf
# wiki60.naf
# wiki6616.naf
# wiki7891.naf
# wiki889.naf
# wiki89.naf
# WR-P-E-C-0000000036.naf
# WR-P-E-E-0000000020.naf
# WR-P-E-H-0000000027.naf
# WR-P-E-H-0000000040.naf
# WR-P-E-H-0000000050.naf
# WR-P-E-I-0000000014.naf
# WR-P-E-I-0000011406.naf
# WR-P-E-J-0000000014.naf
# WR-P-E-J-0000000029.naf
# WR-P-P-C-0000000001.naf
# WR-P-P-C-0000000006.naf
# WR-P-P-C-0000000037.naf
# WR-P-P-C-0000000041.naf
# WR-P-P-C-0000000047.naf
# WR-P-P-C-0000000052.naf
# WR-P-P-H-0000000002.naf
# WR-P-P-H-0000000011.naf
# WR-P-P-H-0000000016.naf
# WR-P-P-H-0000000018.naf
# WR-P-P-H-0000000019.naf
# WR-P-P-H-0000000032.naf
# WR-P-P-H-0000000042.naf
# WR-P-P-H-0000000066.naf
# WR-P-P-H-0000000068.naf
# WR-P-P-H-0000000070.naf
# WR-P-P-H-0000000074.naf
# WR-P-P-H-0000000079.naf
# WR-P-P-H-0000000082.naf
# WR-P-P-H-0000000097.naf
# WR-P-P-H-0000000098.naf
# WR-P-P-H-0000000100.naf
# WR-P-P-H-0000000103.naf
# WR-P-P-H-0000000104.naf
# WR-P-P-I-0000000013.naf
# WR-P-P-I-0000000016.naf
# WR-P-P-I-0000000019.naf
# WR-P-P-I-0000000021.naf
# WR-P-P-I-0000000043.naf
# WR-P-P-I-0000000045.naf
# WR-P-P-I-0000000051.naf
# WR-P-P-I-0000000057.naf
# WR-P-P-I-0000000064.naf
# WR-P-P-I-0000000066.naf
# WR-P-P-I-0000000069.naf
# WR-P-P-I-0000000088.naf
# WR-P-P-I-0000000132.naf
# WR-P-P-I-0000000143.naf
# WR-P-P-I-0000000146.naf
# WR-P-P-I-0000000150.naf
# WR-P-P-I-0000000154.naf
# WR-P-P-I-0000000155.naf
# WR-P-P-I-0000000164.naf
# WR-P-P-I-0000000169.naf
# WR-P-P-I-0000000170.naf
# WR-P-P-I-0000000171.naf
# WR-P-P-I-0000000176.naf
# WR-P-P-I-0000000186.naf
# WR-P-P-I-0000000192.naf
# WR-P-P-I-0000000205.naf
# WR-P-P-I-0000000206.naf
# WR-P-P-I-0000000210.naf
# WR-P-P-I-0000000211.naf
# WR-P-P-I-0000000215.naf
# WR-P-P-I-0000000219.naf
# WR-P-P-I-0000000233.naf
# WR-P-P-I-0000000238.naf
# WR-P-P-I-0000000261.naf
# WS-U-E-A-0000000014.naf
# WS-U-E-A-0000000024.naf
# WS-U-E-A-0000000036.naf
# WS-U-E-A-0000000042.naf
# WS-U-E-A-0000000047.naf
# WS-U-E-A-0000000212.naf
# WS-U-E-A-0000000218.naf
# WS-U-E-A-0000000223.naf
# WS-U-E-A-0000000227.naf
# WS-U-E-A-0000000243.naf
# WS-U-E-A-0000000245.naf
# WS-U-E-A-0000000246.naf
# '


# Data with problems. For details, see:
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
