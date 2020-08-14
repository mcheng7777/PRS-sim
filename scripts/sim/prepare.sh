#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: ./prepare.sh [pop] [train|val]"
	exit 1
fi

. /u/local/Modules/default/init/modules.sh
module load plink

pop=$1
mode=$2

outdir="../../data/${mode}/${pop}"
pheno="../../data/${mode}/${pop}/pheno/${pop}"
bfile="../../data/bfile/${pop}"

mkdir ${outdir}
mkdir ${outdir}/pheno

if [ ${mode} == "train" ] 
then
	mkdir ${outdir}/grm
	mkdir ${outdir}/blup
else
	mkdir ${valdir}/prs
	mkdir ${valdir}/corr
fi

cp ${bfile}.bed ${pheno}.bed
cp ${bfile}.bim ${pheno}.bim
