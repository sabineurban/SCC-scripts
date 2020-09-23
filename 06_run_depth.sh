#!/bin/bash
#$ -N doc_P
#$ -l h_rt=24:00:00
#$ -pe smp 8
#$ -l h_vmem=32G

# Job submission script for Grid Engine.
# Takes mapped, merged, and duplicate-marked bam files and outputs individiual seuqencing coverage at all sites in the reference genome. Output is bgzipped and tabix-indexed.
# Requires Samtools, generate_regions.py from Freebayes package, GNU Parallel, bgzip, and tabix.

export PATH=/data/scc3/shared/software/bin:$PATH

module load samtools

WORKDIR="/data/scc3/shared/African_cichlids"
SCRATCH="/data/scc3/scratch/$RUN_ID"
SAMPLELIST="$WORKDIR/samplelists/bamlist_Pnye_agrp2.txt"
REFSEQ="$WORKDIR/references/Curated_P_nyererei_v1_no6781.assembly.fasta"
BAMFOLDER="$WORKDIR/bam/mapped/Pnye/no6781"
OUTFOLDER="$WORKDIR/depth"
OUTFILE="Pnye_no6781_agrp2_samtools_depth.txt"
MIN_BASEQUAL=20
MIN_MAPPINGQUAL=30
REGION_SIZE=1000000

if [ ! -d $OUTFOLDER ]; then mkdir -p $OUTFOLDER; fi
if [ ! -d $SCRATCH ]; then mkdir -p $SCRATCH; fi

function join_by { local IFS="$1"; shift; echo "$*"; }
SAMPLES=(); BAMIDS=()
while read ID; do
  SAMPLES+=($ID)
  BAMIDS+=($BAMFOLDER/${ID}_Pnye.RG.markadap.mapped.markdup.bam)
done < $SAMPLELIST

join_by $'\t' "#CHROM" "POS" ${SAMPLES[@]} > $OUTFOLDER/$OUTFILE

$WORKDIR/scripts/generate_regions_for_run_depth.py $REFSEQ $REGION_SIZE | parallel --tmpdir $SCRATCH -k -j 16 samtools depth -q $MIN_BASEQUAL -Q $MIN_MAPPINGQUAL -r {} ${BAMIDS[@]} >> $OUTFOLDER/$OUTFILE

bgzip $OUTFOLDER/$OUTFILE && tabix -s 1 -b 2 -e 2 $OUTFOLDER/${OUTFILE}.gz

rm -rf $SCRATCH
