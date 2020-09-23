#!/bin/bash
#$ -N iqtree
#$ -l h_rt=48:00:00
#$ -t 1-6655:1
#$ -tc 500
#$ -l h_vmem=16G
#$ -pe smp 2
#$ -e "/data/scc3/shared/African_cichlids/scripts/logs/iqtree"
#$ -o "/data/scc3/shared/African_cichlids/scripts/logs/iqtree"

COUNTER=$(( $SGE_TASK_ID - 1 ))
RUN_ID="${JOB_ID}.${COUNTER}"
echo "Starting job ${JOB_ID}, task ${SGE_TASK_ID}, run ${RUN_ID}."

WORKDIR="/data/scc3/shared/African_cichlids"
SCRATCH="/data/scc3/scratch/$RUN_ID"
BIN="/data/scc3/shared/software/iqtree-1.6.9-Linux/bin"
INDIR="/data/scc3/shared/African_cichlids/fasta/loci_2kb_3kb_100kb/phylo2/max_miss_0.75"
SAMPLELIST="$INDIR/samplelist_loci_phylo2.txt"

SAMPLE=`awk -v line=$SGE_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`

cd $INDIR

$BIN/iqtree -s ${SAMPLE} -st DNA -v -m TESTNEW \
-bb 1000 -wbt -alrt 1000 -nt 2  -mem 16G -pre ${SAMPLE}

## Interpretatioon: One would typically start to rely on the clade if its SH-aLRT >= 80% and UFboot >= 95%
