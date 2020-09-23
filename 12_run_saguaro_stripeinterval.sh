#!/bin/bash
#$ -N saguaro
#$ -t 1-1:1
#$ -l h_rt=2:00:00
#$ -l h_vmem=16G

COUNTER=$(( $SGE_TASK_ID - 1 ))
RUN_ID="${JOB_ID}.${SGE_TASK_ID}"
echo "Starting job ${JOB_ID}, task ${SGE_TASK_ID}, run ${RUN_ID}."

BIN="/data/scc3/shared/software/saguaro_r44"
WORKDIR="/data/scc3/shared/African_cichlids"
INFOLDER="$WORKDIR/fasta/Pnye/LMLV"

FASTAFILES=( $INFOLDER/LM2_haplotypes_scaffold3:1-9443038.fasta )
FASTAFILE=${FASTAFILES[$COUNTER]}

if [[ $FASTAFILE =~ LM2_haplotypes_(.*[0-9]+):([0-9]+)-([0-9]+).fasta 
]]; then
	CHROMOSOME=${BASH_REMATCH[1]}
	START=${BASH_REMATCH[2]}
	END=${BASH_REMATCH[3]}
fi

OUTFOLDER="$WORKDIR/saguaro/output/Pnye/LMLV/20200718_LM2_haplotypes_${CHROMOSOME}_${START}_${END}"
echo "$OUTFOLDER"

if [ ! -d $OUTFOLDER ]; then mkdir -p $OUTFOLDER; fi

cd $BIN

echo "./Fasta2HMMFeature -i $FASTAFILE -n $CHROMOSOME -o ${FASTAFILE%.fasta}.out"
./Fasta2HMMFeature -i $FASTAFILE -n $CHROMOSOME -o ${FASTAFILE%.fasta}.out

INFILE=${FASTAFILE%.fasta}.out

echo "./Saguaro -f ${FASTAFILE%.fasta}.out -o $OUTFOLDER"
./Saguaro -f ${FASTAFILE%.fasta}.out -o $OUTFOLDER
