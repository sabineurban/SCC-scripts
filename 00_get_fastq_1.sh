#!/bin/bash
#$ -N get_fastq
#$ -t 1-4:1
#$ -tc 1
#$ -l h_rt=72:00:00
#$ -l h_vmem=4G

export PATH=/data/scc3/shared/bin:$PATH

WORKDIR="/data/scc2/ameyer/African_cichlids"
SAMPLELIST="$WORKDIR/scripts/new_ftp.txt"
TARGETFOLDER="/data/scc2/ameyer/African_cichlids/fastq"

if [ ! -d $TARGETFOLDER ]; then mkdir -p $TARGETFOLDER; fi
cd $TARGETFOLDER

FASTQ1=`awk -v line=$SGE_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
FASTQ2=`awk -v line=$SGE_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`

wget -q $FASTQ1
wget -q $FASTQ2
