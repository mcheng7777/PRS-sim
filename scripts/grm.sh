#!/bin/bash

pop=$1
gcta="../bin/gcta64"
bfile="../data/${pop}/pheno/${pop}" 
grm="../data/${pop}/grm/${pop}"

$gcta --bfile ${bfile} --make-grm --out ${grm}

qsub --hold_jid job-pheno-sim ./blup.sh $1
