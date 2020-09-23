#!/bin/bash
#$ -N freebayes
#$ -t 1-4:1
#$ -tc 4
#$ -l h_vmem=32G
#$ -l h_rt=1000:00:00
#$ -e "/data/scc3/shared/African_cichlids/scripts/logs/freebayes"
#$ -o "/data/scc3/shared/African_cichlids/scripts/logs/freebayes"

WORKDIR="/data/scc3/shared/African_cichlids"
SCAFFOLDLIST="$WORKDIR/references/Curated_P_nyererei_v1_no6781_scaffold3.txt"
SAMPLELIST="$WORKDIR/samplelists/freebayes/samplelist_Pnye_all.txt"
POPLIST="$WORKDIR/samplelists/freebayes/populationlist_Pnye_all.txt"
REFSEQ="$WORKDIR/references/Curated_P_nyererei_v1_no6781.assembly.fasta"
INFOLDER="$WORKDIR/bam/mapped/Pnye/no6781"
OUTFOLDER="$WORKDIR/vcf_freebayes/scaffolds/Pnye/no6781"

if [ ! -d $OUTFOLDER ]; then mkdir -p $OUTFOLDER; fi

SCAFFOLDID=`awk -v line=$SGE_TASK_ID 'NR==line{print $1; exit}' $SCAFFOLDLIST`

module load freebayes

freebayes -f $REFSEQ -L $SAMPLELIST -r ${SCAFFOLDID} --populations $POPLIST \
-v $OUTFOLDER/Pnye_all_scaffold3_raw.snps.indels.${SCAFFOLDID}.vcf \
--standard-filters
