#!/bin/bash
#$ -N concat_P
#$ -l h_rt=2:00:00
#$ -pe smp 4
#$ -l h_vmem=8G

WORKDIR="/data/scc3/shared/African_cichlids"
INFOLDER="$WORKDIR/vcf_freebayes/scaffolds/Pnye/no6781/new/all/scaffold3"
OUTFOLDER="$WORKDIR/vcf_freebayes/scaffolds/Pnye/no6781/new/all/scaffold3/concat"
SCAFFOLDLIST="$WORKDIR/references/Curated_P_nyererei_v1_no6781_scaffold3.txt"
BIN="/data/scc3/shared/software/bin"

if [ ! -d $OUTFOLDER ]; then mkdir -p $OUTFOLDER; fi

awk '/^#/{print} /^#CHROM/{exit}' $INFOLDER/Pnye_all_nooutgroups_scaffold3_raw.snps.indels.scaffold_3:1-5000000.vcf > \
$OUTFOLDER/Pnye_all_nooutgroups_scaffold3.raw.snps.indels.vcf

while read REGION
do
 VCFFILE="$INFOLDER/Pnye_all_nooutgroups_scaffold3_raw.snps.indels.${REGION}.vcf"
 if [ ! -f $VCFFILE ]; then echo "file $VCFFILE doesn't exist";
 else
   awk '/^#/{next} {print}' $INFOLDER/Pnye_all_nooutgroups_scaffold3_raw.snps.indels.${REGION}.vcf >> $OUTFOLDER/Pnye_all_nooutgroups_scaffold3.raw.snps.indels.vcf
 fi
done < ${SCAFFOLDLIST}
