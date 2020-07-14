#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: ./batch.sh [population 1] [population 2]"
	exit 1
fi

if [ ${1} == ${2} ]
then 
	echo "one population"
	pop=$1
	popnum=1
else 
	echo "two populations"
	pop="${1}-${2}"
	popnum=2
fi

mkdir ../data/${pop}
mkdir ../data/${pop}/vcf
mkdir ../data/${pop}/pheno
mkdir ../data/${pop}/grm
mkdir ../data/${pop}/blup
mkdir ../data/${pop}/prs

# filter vcf
qsub ./filter.sh ${1} ${2}
# phenotype simulations
qsub -hold_jid job-filter ./pheno-sim.sh $pop $popnum
# grm
qsub -hold_jid job-pheno-sim ./grm.sh $pop
# blup
qsub -hold_jid job-grm ./blup.sh $pop
# prs using gcta
qsub -hold_jid job-blup ./gcta-prs.sh $pop
# calculate the correlations
qsub -hold_jid job-gcta-prs ./corr.sh $pop
