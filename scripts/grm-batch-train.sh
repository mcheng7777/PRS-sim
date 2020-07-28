#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: ./batch-train.sh [population]"
	exit 1
fi

pop=$1

# phenotype simulations
qsub ./sim/pheno-sim-train.sh $pop
# grm
qsub ./grm/grm.sh $pop
# blup
qsub ./grm/blup.sh $pop
