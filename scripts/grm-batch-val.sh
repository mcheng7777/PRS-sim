#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: ./batch-val.sh [population 1] [population 2]"
	exit 1
fi

pop1=$1
pop2=$2

# phenotype simulations
qsub ./pheno-sim/pheno-sim-val.sh $pop1 $pop2
# prs using gcta
qsub ./grm/gcta-prs.sh $pop1 $pop2
# calculate the correlations
qsub ./analysis/corr.sh $pop1 $pop2
