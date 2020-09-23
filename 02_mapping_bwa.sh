#!/bin/bash
#$ -N mapping_wgs
#$ -t 1-2:1
#$ -tc 2
#$ -l h_rt=60:00:00
#$ -pe smp 4
#$ -l h_vmem=16G

JAVA_HOME=/usr/lib64/jvm/jre-1.8.0-openjdk
module load samtools

COUNTER=$(( $SGE_TASK_ID - 1 ))
RUN_ID="${JOB_ID}.${COUNTER}"
echo "Starting job ${JOB_ID}, task ${SGE_TASK_ID}, run ${RUN_ID}."
WORKDIR="/data/scc3/shared"
PICARD="$WORKDIR/software/picard-2.18.16"
SCRATCH="/data/scc3/scratch/$RUN_ID"
SAMPLELIST="$WORKDIR/African_cichlids/samplelists/mapping_samplelist.txt"
REFSEQ="$WORKDIR/African_cichlids/references/Curated_P_nyererei_v1_no6781.assembly.fasta"
INFOLDER="$WORKDIR/African_cichlids/bam/unmapped"
OUTFOLDER="$WORKDIR/African_cichlids/bam/mapped"

if [ ! -d $OUTFOLDER ]; then mkdir -p $OUTFOLDER; fi
if [ ! -d $SCRATCH ]; then mkdir -p $SCRATCH; fi

UBAM_ID=`awk -v line=$SGE_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`
LIB=`awk -v line=$SGE_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`
NEW_ID=`awk -v line=$SGE_TASK_ID 'NR==line{print $4; exit}' $SAMPLELIST`

java -Djava.io.tmpdir=$SCRATCH -XX:ParallelGCThreads=4 -Xmx8G -jar $PICARD/picard.jar SamToFastq \
	I=$INFOLDER/${UBAM_ID}.unmapped.markadap.bam \
	FASTQ=/dev/stdout \
	CLIPPING_ATTRIBUTE=XT \
	CLIPPING_ACTION=2 \
	INTERLEAVE=true \
	NON_PF=true \
	TMP_DIR=$SCRATCH | \
	$WORKDIR/software/bin/bwa mem -M -t 8 -p $REFSEQ \
		/dev/stdin | \
		java -Djava.io.tmpdir=$SCRATCH -XX:ParallelGCThreads=4 -Xmx16G -jar $PICARD/picard.jar MergeBamAlignment \
			R=$REFSEQ \
			UNMAPPED_BAM=$INFOLDER/${UBAM_ID}.unmapped.markadap.bam \
			ALIGNED_BAM=/dev/stdin \
			OUTPUT=$OUTFOLDER/${NEW_ID}.markadap.mapped.bam \
			CREATE_INDEX=false \
			ADD_MATE_CIGAR=true \
			CLIP_ADAPTERS=false \
			CLIP_OVERLAPPING_READS=true \
			INCLUDE_SECONDARY_ALIGNMENTS=true \
			MAX_INSERTIONS_OR_DELETIONS=-1 \
			PRIMARY_ALIGNMENT_STRATEGY=BestMapq \
			ATTRIBUTES_TO_RETAIN=XS \
			ATTRIBUTES_TO_RETAIN=XT \
			TMP_DIR=$SCRATCH

samtools sort -o $OUTFOLDER/${NEW_ID}.srt.markadap.mapped.bam \
-@ 4 $OUTFOLDER/${NEW_ID}.unsrt.markadap.mapped.bam	 

java -Djava.io.tmpdir=$SCRATCH -XX:ParallelGCThreads=4 -Xmx24G -jar $PICARD/picard.jar MarkDuplicates \
	OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 \
	MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
	I=$OUTFOLDER/${NEW_ID}.markadap.mapped.bam \
	O=$OUTFOLDER/${NEW_ID}.Pnye.markadap.mapped.markdup.bam \
	M=$OUTFOLDER/${NEW_ID}.Pnye.markadap.mapped.markdup.metrics \
	TMP_DIR=$SCRATCH

samtools index $OUTFOLDER/${NEW_ID}.Pnye.markadap.mapped.markdup.bam

rm -f $OUTFOLDER/${NEW_ID}.srt.markadap.mapped.bam
rm -f $OUTFOLDER/${NEW_ID}.unsrt.markadap.mapped.bam
rm -f $OUTFOLDER/${NEW_ID}.markadap.mapped.bam
rm -rf $SCRATCH
