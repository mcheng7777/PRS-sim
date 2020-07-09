#!/bin/bash

if [ $1 != "sim" ]
then
	qsub ./filter.sh $1
fi 
# phenotype simulations
qsub --hold_jid job-filter ./pheno-sim.sh $1
# grm and blup
./grm.sh $1
# prs using gcta
qsub --hold_jid job-blup ./gcta-prs.sh $1
# calculate the correlations
qsub --hold_jid job-gcta-prs ./corr.sh $1
