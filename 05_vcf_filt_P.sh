#!/bin/bash
#$ -N vcf_flt
#$ -l h_rt=2:00:00
#$ -l h_vmem=16G

RUN_ID="${JOB_ID}"

export PATH="/data/scc3/shared/software/bin:$PATH"

WORKDIR="/data/scc3/shared/African_cichlids"
REFSEQ="$WORKDIR/references/Curated_P_nyererei_v1_no6781.assembly.fasta"
BIN="/data/scc3/shared/software/vt"
INFOLDER="$WORKDIR/vcf_freebayes/scaffolds/Pnye/no6781/new/all/scaffold3/concat"
VCFFILE="Pnye_all_nooutgroups_scaffold3"

module load vcftools
module load vcflib
module load bcftools

cd $INFOLDER

cat ${VCFFILE}.raw.snps.indels.comp.vcf | \
vcf-sort > ${VCFFILE}.srt.snps.indels.vcf

##( grep  '^#' ${VCFFILE}.srt.snps.indels.vcf ; grep -v "^#" ${VCFFILE}.srt.snps.indels.vcf | LC_ALL=C sort -t $'\t' -k1,1 -k2,2n -k4,4 | awk -F '\t' 'BEGIN{ prev="";} {key=sprintf("%s\t%s\t%s",$1,$2,$4);if(key==prev) next;print;prev=key;}' )  > ${VCFFILE}.srt.nodup.snps.indels.vcf

cat ${VCFFILE}.srt.snps.indels.vcf | \
vcffilter -s -f "QUAL > 1 & QUAL / AO > 10 & SAF > 0 & SAR > 0 & RPR > 1 & RPL > 1" > \
${VCFFILE}.flt.snps.indels.vcf

$BIN/vt normalize ${VCFFILE}.flt.snps.indels.vcf -r $REFSEQ | \
$BIN/vt uniq - > ${VCFFILE}.flt.snps.indels.norm.vcf

$WORKDIR/scripts/process_complex.py ${VCFFILE}.flt.snps.indels.norm.vcf \
${VCFFILE}.flt.snps.indels.norm.decomposed.vcf

vcftools --vcf ${VCFFILE}.flt.snps.indels.norm.decomposed.vcf \
--stdout --remove-indels --recode --recode-INFO-all \
--max-alleles 2 --max-missing 0.05 --remove-filtered-all > \
${VCFFILE}.flt.snps.norm.decomposed.vcf

#bcftools reheader --samples rehead.txt \
#--output ${VCFFILE}.flt.snps.norm.decomposed.newname.vcf \
##${VCFFILE}.flt.snps.norm.decomposed.vcf

#cat ${VCFFILE}.flt.snps.norm.decomposed.vcf | \
#awk 'BEGIN{OFS="\t"} FNR==NR{coltrans[int($2)+9]=$3+9; next} /^##/{print; next} FNR!=NR{split($0,oldline,OFS); for(i=10;i<=NF;++i) $i=oldline[coltrans[i]]; print}' conversion_vcf.txt - | \
#bgzip > ${VCFFILE}.srt.flt.snps.norm.decomposed.newname.vcf.gz && tabix -p vcf \
##${VCFFILE}.srt.flt.snps.norm.decomposed.vcf.gz
