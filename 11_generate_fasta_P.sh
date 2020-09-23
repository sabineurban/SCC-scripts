#!/bin/bash
#$ -N get_fasta
#$ -t 1-1:1
#$ -tc 1
#$ -l h_rt=4:00:00
#$ -l h_vmem=8G
#$ -e "/data/scc3/shared/African_cichlids/scripts/logs/get_fasta"
#$ -o "/data/scc3/shared/African_cichlids/scripts/logs/get_fasta"

export PATH="/data/scc3/shared/software/bin:$PATH"
export TMPDIR=/data/scc3/scratch/tmp

RUN_ID="${JOB_ID}.${SGE_TASK_ID}"
echo "Starting job ${JOB_ID}, task ${SGE_TASK_ID}, run ${RUN_ID}."

WORKDIR="/data/scc3/shared/African_cichlids"
BIN="$WORKDIR/scripts"
SCRATCH="/data/scc3/scratch/$RUN_ID"

ALLSITESLIST="$BIN/allsiteslist_Pnye_no6781_LMLV.txt"
VCFLIST="$BIN/vcflist_Pnye_no6781_LMLV.txt"
POPLIST="$BIN/poplist.coverage.Pnye.no6781.new.LMLV.txt"
GROUPLIST="none"
REFSEQ="$WORKDIR/references/Curated_P_nyererei_v1_no6781.assembly.fasta"
REGIONS="Pnye_scaffold_3_1Mb.bed"
OUTFOLDER="$WORKDIR/fasta/Pnye/new/LMLV/max_miss_0.50"
SUBPOPS="all"
SUBINDS="all"
NINDIVIDUALS="all"
PREPHASED=1
RANDOM_PHASING=0
HAPLOTIZE=0
MAX_MISSINGNESS=0.50
VERBOSE=1

mkdir -p $OUTFOLDER
mkdir -p $SCRATCH

CHROMOSOME="all"
#CHROMOSOME=`awk -v line=$SGE_TASK_ID 'NR==line{print $1; exit}' ${REFSEQ}.fai`

cd $BIN

echo "./generate_fasta.pl $REFSEQ $OUTFOLDER $ALLSITESLIST $VCFLIST $GROUPLIST $CHROMOSOME $SUBPOPS $SUBINDS $NINDIVIDUALS $REGIONS $PREPHASED $RANDOM_PHASING $HAPLOTIZE $MAX_MISSINGNESS $SCRATCH $VERBOSE"
./generate_fasta_coverage.pl $REFSEQ $OUTFOLDER $ALLSITESLIST $VCFLIST $POPLIST $GROUPLIST $CHROMOSOME $SUBPOPS $SUBINDS $NINDIVIDUALS $REGIONS $PREPHASED $RANDOM_PHASING $HAPLOTIZE $MAX_MISSINGNESS $SCRATCH $VERBOSE

rm -rf $SCRATCH

