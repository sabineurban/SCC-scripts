#!/bin/bash

WORKDIR="/data/scc3/shared/African_cichlids"
VCFFOLDER="$WORKDIR/vcf_freebayes/scaffolds/Pnye/no6781/new/all"
REGIONLIST="$VCFFOLDER/scaffoldlist.bed"
PREFIX="Pnye_all_wg_raw.snps.indels"
OUTFILE="$VCFFOLDER/concat/Pnye_all_wg_raw.snps.indels.last_positions.bed"

while read CHROM START END; do
  echo "Working on file $VCFFOLDER/${PREFIX}.${CHROM}:${START}-${END}.vcf ..." > /dev/stderr
  tail -n 1 $VCFFOLDER/${PREFIX}.${CHROM}:${START}-${END}.vcf | \
  awk -v chrom=$CHROM -v start=$START -v end=$END -v OFS="\t" '/^#/{print chrom,start,end,0,end; next} {print chrom,start,end,$2,end-$2}' 
done < $REGIONLIST > $OUTFILE

