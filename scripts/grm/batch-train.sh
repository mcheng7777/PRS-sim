#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: ./batch-train.sh [population]"
	exit 1
fi

pop=$1

./prepare.sh $pop
# phenotype simulations
qsub ./pheno-sim-train.sh $pop
# grm
qsub ./grm.sh $pop
# blup
qsub ./blup.sh $pop
