#!/bin/bash
#$ -N get_P
#$ -t 4-4:1
#$ -tc 1
#$ -l h_rt=4:00:00
#$ -l h_vmem=8G
#$ -e "/data/scc3/shared/African_cichlids/scripts/logs/PIRs"
#$ -o "/data/scc3/shared/African_cichlids/scripts/logs/PIRs"

export PATH="/data/scc3/shared/software/bin:$PATH"

COUNTER=$(( $SGE_TASK_ID -1 ))
RUN_ID="${JOB_ID}.${COUNTER}"
echo "Starting job ${JOB_ID}, task ${SGE_TASK_ID}, run ${RUN_ID}."

WORKDIR="/data/scc3/shared/African_cichlids"
SCRATCH="/data/scc3/shared/scratch/$RUN_ID"
REFSEQ="$WORKDIR/references/Curated_P_nyererei_v1_no6781.assembly.fasta"
BAMLIST="20200714_bamfile_no6781_all.txt"
VCFFOLDER="$WORKDIR/vcf_freebayes/scaffolds/Pnye/no6781/new/all/concat"
VCFFILE="Pnye_all_wg.srt.flt.snps.norm.decomposed.vcf.gz"
OUTFOLDER="$WORKDIR/PIRs_5mb/Pnye/no6781/20200714/all"
OUTFILE_PREFIX="PIRlist_no6781_Pnye_all"

if [ ! -d $OUTFOLDER ]; then mkdir -p $OUTFOLDER; fi
if [ ! -d $SCRATCH ]; then mkdir -p $SCRATCH; fi

CHROMOSOME=`awk -v line=$SGE_TASK_ID 'NR==line {print $1; exit}' ${REFSEQ}.fai`

OUTFILE="${OUTFILE_PREFIX}_${CHROMOSOME}.txt"

echo "sed -e s/"{chromosome}"/${CHROMOSOME}/ $WORKDIR/samplelists/PIRs/$BAMLIST > $SCRATCH/${BAMLIST%.txt}_${CHROMOSOME}.txt"
sed -e s/"{chromosome}"/${CHROMOSOME}/ $WORKDIR/samplelists/PIRs/$BAMLIST > $SCRATCH/${BAMLIST%.txt}_${CHROMOSOME}.txt

echo "tabix -h $VCFFOLDER/$VCFFILE $CHROMOSOME | gzip > $SCRATCH/${VCFFILE%.vcf.gz}_${CHROMOSOME}.vcf.gz"
tabix -h $VCFFOLDER/$VCFFILE $CHROMOSOME | awk '/^#/{print; next;} {if(length($4)>1 || length($5)>1 || $6=="." || length($9)<6) next; print;}' | gzip > $SCRATCH/${VCFFILE%.vcf.gz}_${CHROMOSOME}.vcf.gz

cd $SCRATCH

echo "extractPIRs --base-quality 13 --read-quality 10 --bam ${BAMLIST%.txt}_${CHROMOSOME}.txt --vcf ${VCFFILE%.vcf.gz}_${CHROMOSOME}.vcf.gz --out $OUTFILE"
extractPIRs --base-quality 13 --read-quality 10 --bam ${BAMLIST%.txt}_${CHROMOSOME}.txt --vcf ${VCFFILE%.vcf.gz}_${CHROMOSOME}.vcf.gz --out $OUTFILE

mv $OUTFILE $OUTFOLDER

rm -rf $SCRATCH
