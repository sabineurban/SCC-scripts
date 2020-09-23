#!/bin/bash
#$ -N preprocess
#$ -t 1-26:1
#$ -tc 1
#$ -l h_rt=72:00:00
#$ -pe smp 4
#$ -l h_vmem=8G

export PATH=/data/scc3/shared/software/bin:$PATH

COUNTER=$(( $SGE_TASK_ID - 1 ))
RUN_ID="${JOB_ID}.${COUNTER}"
echo "Starting job ${JOB_ID}, task ${SGE_TASK_ID}, run ${RUN_ID}."

WORKDIR="/data/scc3"
SCRATCH="$WORKDIR/scratch/$RUN_ID"
PICARD="$WORKDIR/shared/software/picard-2.18.16/picard.jar"
SAMPLELIST="$WORKDIR/shared/African_cichlids/samplelists/mapping_samplelist.txt"
FASTQFOLDER="/data/scc0/rawdata/African_cichlids/Target_enrichment/WGS"
OUTFOLDER="$WORKDIR/shared/African_cichlids/bam/unmapped"

if [ ! -d $OUTFOLDER ]; then mkdir -p $OUTFOLDER; fi
if [ ! -d $SCRATCH ]; then mkdir -p $SCRATCH; fi

SAMPLEID=`awk -v line=$SGE_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`
NEW_SAMPLEID=`awk -v line=$SGE_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
READINFO=(`zcat ${SAMPLEID}_1.fq.gz | awk '/^@/{split($1,a,":"); split($2,b,":"); print a[3],a[4],b[4]; exit}'`)
ID="${READINFO[0]}.${READINFO[1]}.${READINFO[2]}"
PU="${READINFO[0]}.${READINFO[1]}.${READINFO[2]}"

java -Djava.io.tmpdir=$SCRATCH -XX:ParallelGCThreads=4 -Xmx7G -jar $PICARD FastqToSam \
	FASTQ=$FASTQFOLDER/${SAMPLEID}_1.fastq.gz \
	FASTQ2=$FASTQFOLDER/${SAMPLEID}_2.fastq.gz \
	OUTPUT=/dev/stdout \
	READ_GROUP_NAME=$ID \
	SAMPLE_NAME=$NEW_SAMPLEID \
	LIBRARY_NAME=$SAMPLEID \
	PLATFORM_UNIT=$PU \
	PLATFORM=illumina \
	TMP_DIR=$SCRATCH | \
	java -Djava.io.tmpdir=$SCRATCH -XX:ParallelGCThreads=4 -Xmx7G -jar $PICARD MarkIlluminaAdapters \
		INPUT=/dev/stdin \
		OUTPUT=$OUTFOLDER/${NEW_SAMPLEID}.unmapped.markadap.bam \
		METRICS=$OUTFOLDER/${NEW_SAMPLEID}.unmapped.markadap.metric \
		TMP_DIR=$SCRATCH

rm -rf $SCRATCH
