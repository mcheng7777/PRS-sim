#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: ./batch.sh [population 1] [population 2]"
	exit 1
fi

pop1=$1
pop2=$2

if [ $pop1 == $pop2 ]
then 
	pop=$pop1
else
	pop=${pop1}-${pop2}
fi

mkdir ../../data/${pop}
mkdir ../../data/${pop}/pheno
mkdir ../../data/${pop}/grm
mkdir ../../data/${pop}/blup
mkdir ../../data/${pop}/prs

# phenotype simulations
qsub ./pheno-sim.sh $pop1 $pop2
# grm
qsub -hold_jid job-pheno-sim ./grm.sh $pop1 $pop2
# blup
qsub -hold_jid job-grm ./blup.sh $pop1 $pop2
# prs using gcta
qsub -hold_jid job-blup ./gcta-prs.sh $pop1 $pop2
# calculate the correlations
qsub -hold_jid job-gcta-prs ./corr.sh $pop1 $pop2
