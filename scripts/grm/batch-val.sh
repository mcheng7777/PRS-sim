#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: ./batch-val.sh [population 1] [population 2]"
	exit 1
fi

pop1=$1
pop2=$2

# phenotype simulations
qsub ./pheno-sim-val.sh $pop1 $pop2
# prs using gcta
qsub ./gcta-prs.sh $pop1 $pop2
# calculate the correlations
qsub ./corr.sh $pop1 $pop2
