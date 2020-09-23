#!/bin/bash
#$ -N phase
#$ -t 4-4:1
#$ -tc 1
#$ -l h_rt=60:00:00
#$ -l h_vmem=8G
#$ -pe smp 4
#$ -e "/data/scc3/shared/African_cichlids/scripts/logs/phasing"
#$ -o "/data/scc3/shared/African_cichlids/scripts/logs/phasing"

export PATH="/data/scc3/shared/software/bin:$PATH"

COUNTER=$(( $SGE_TASK_ID - 1 ))
RUN_ID="${JOB_ID}.${COUNTER}"
echo "Starting job ${JOB_ID}, task ${SGE_TASK_ID}, run ${RUN_ID}."

WORKDIR="/data/scc3/shared/African_cichlids"
SCRATCH="/data/scc3/shared/scratch/$RUN_ID"

REFSEQ="$WORKDIR/references/Curated_P_nyererei_v1_no6781.assembly.fasta"
VCFFOLDER="$WORKDIR/vcf_freebayes/scaffolds/Pnye/no6781/new/nopop/concat"
VCFFILE="Pnye.no6781.nopop.5mb.scaffold3.srt.flt.snps.norm.decomposed.newname.vcf.gz"
PIRFILE_PREFIX="PIRlist_no6781_Pnye_nopop"
PIRFOLDER="$WORKDIR/PIRs_5mb/Pnye/no6781/"
OUTFOLDER="$WORKDIR/phasing/Pnye/no6781/"
OUTFILE_PREFIX="phasing_Pnye_no6781"

if [ ! -d $OUTFOLDER ]; then mkdir -p $OUTFOLDER; fi
if [ ! -d $SCRATCH ]; then mkdir -p $SCRATCH; fi

CHROMOSOME=`awk -v line=$SGE_TASK_ID 'NR==line {print $1; exit}' ${REFSEQ}.fai`
OUTFILE="${OUTFILE_PREFIX}_${CHROMOSOME}"
PIRFILE="${PIRFILE_PREFIX}_${CHROMOSOME}.txt"

echo "$CHROMOSOME $OUTFILE"

echo "tabix -h $VCFFOLDER/$VCFFILE $CHROMOSOME | awk '/^#/{print; next;} {if(length($4)>1 || length($5)>1 || $6=="." || length($9)<6) next; print;}' > $SCRATCH/${VCFFILE%.vcf.gz}_${CHROMOSOME}.vcf"
tabix -h $VCFFOLDER/$VCFFILE $CHROMOSOME | awk '/^#/{print; next;} {if(length($4)>1 || length($5)>1 || $6=="." || length($9)<6) next; print;}' > $SCRATCH/${VCFFILE%.vcf.gz}_${CHROMOSOME}.vcf

# checks if there are individuals with only missing genotypes. If so, sets the missing genotype in the last row of the vcf file to 0/0:
awk -F "\t" 'BEGIN{OFS="\t"; lastline=""} /^#/{print; next;} {if(length(lastline)!=0) print lastline; lastline=$0; for(i=10; i<=NF; ++i) if($i!=".:.:.:.:.:.:.:.") valid[i]=1 } END{ORS=""; if(length(lastline)!=0){ n=split(lastline, fields, FS); print fields[1]; for(i=2; i<=n; ++i){ if(fields[i]==".:.:.:.:.:.:.:." && valid[i]!=1) fields[i]="0/0:.:.:.:.:.:.:."; print "\t" fields[i]} print "\n"} }' $SCRATCH/${VCFFILE%.vcf.gz}_${CHROMOSOME}.vcf | gzip > $SCRATCH/${VCFFILE%.vcf.gz}_${CHROMOSOME}_nomissind.vcf.gz

echo "shapeit -assemble --thread 4 --states 200 --window 0.5 --burn 10 --prune 10 --main 50 --input-vcf $SCRATCH/${VCFFILE%.vcf.gz}_${CHROMOSOME}_nomissind.vcf.gz --input-pir $PIRFOLDER/$PIRFILE -O $SCRATCH/$OUTFILE"
shapeit -assemble --f --thread 4 --states 200 --window 0.5 --burn 10 --prune 10 --main 50 --input-vcf $SCRATCH/${VCFFILE%.vcf.gz}_${CHROMOSOME}_nomissind.vcf.gz --input-pir $PIRFOLDER/$PIRFILE -O $SCRATCH/$OUTFILE

echo "shapeit -convert --input-haps $SCRATCH/$OUTFILE --output-vcf $SCRATCH/${OUTFILE}.vcf"
shapeit -convert --input-haps $SCRATCH/$OUTFILE --output-vcf $SCRATCH/${OUTFILE}.vcf

mv $SCRATCH/${OUTFILE}.vcf $OUTFOLDER
rm -rf $SCRATCH
