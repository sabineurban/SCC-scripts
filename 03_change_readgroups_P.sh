#!/bin/bash
#$ -N readgroups
#$ -t 1-4:1
#$ -tc 4
#$ -l h_rt=24:00:00
#$ -pe smp 2
#$ -l h_vmem=8G

COUNTER=$(( $SGE_TASK_ID - 1 ))
RUN_ID="${JOB_ID}.${COUNTER}"
echo "Starting job ${JOB_ID}, task ${SGE_TASK_ID}, run ${RUN_ID}."

WORKDIR="/data/scc3"
SCRATCH="$WORKDIR/scratch/$RUN_ID"

PICARD="$WORKDIR/shared/software/picard-2.18.16/picard.jar"
module load samtools

SAMPLELIST="$WORKDIR/shared/African_cichlids/samplelists/change_readgroup.txt"
NEW_ID=`awk -v line=$SGE_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
OLD_ID=`awk -v line=$SGE_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`
ID=`awk -v line=$SGE_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
AC=`awk -v line=$SGE_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`

INFOLDER="$WORKDIR/shared/African_cichlids/bam/mapped/Pnye/no6781"
OUTFOLDER="$WORKDIR/shared/African_cichlids/bam/mapped/Pnye/no6781"

if [ ! -d $OUTFOLDER ]; then mkdir -p $OUTFOLDER; fi
if [ ! -d $SCRATCH ]; then mkdir -p $SCRATCH; fi

java -Djava.io.tmpdir=$SCRATCH -XX:ParallelGCThreads=4 -Xmx8G -jar $PICARD AddOrReplaceReadGroups \
I=$INFOLDER/${NEW_ID}_Pnye.RG.markadap.mapped.markdup.bam \
O=$OUTFOLDER/${NEW_ID}_Pnye.RG.markadap.mapped.markdup.bam \
RGID=${NEW_ID} \
RGLB=${OLD_ID} \
RGPL=illumina \
RGPU=${AC} \
RGSM=${NEW_ID} \
SORT_ORDER=coordinate \
CREATE_INDEX=true \
TMP_DIR=$SCRATCH

samtools index $OUTFOLDER/${NEW_ID}_Pnye.RG.markadap.mapped.markdup.bam

rm -rf $SCRATCH