#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load plink

if [ $# -ne 2 ]
then
	echo "Usage: ./combine-pheno.sh [pop1] [pop2]"
	exit 1
fi

pop1=$1
pop2=$2

phen1="../../data/train/${pop1}/pheno/${pop1}"
phen2="../../data/train/${pop2}/pheno/${pop2}"

bfile1="../../data/bfile/${pop1}"
bfile2="../../data/bfile/${pop2}"

out="../../data/train/${pop1}${pop2}/pheno/${pop1}${pop2}"
traindir="../../data/train/${pop1}${pop2}"

bfile1="../../data/bfile/$pop1"
bfile2="../../data/bfile/$pop2"

if [ ! -d $traindir ] 
then
	mkdir ${traindir}
	mkdir ${traindir}/pheno
	mkdir ${traindir}/grm
	mkdir ${traindir}/blup
fi

# create merged bed files
echo -e "$bfile1\n$bfile2" > temp
plink --bfile $bfile1 --merge-list temp --make-bed --out $out

# merge phenotype files
for h2 in {0..9}
do
	cat ${phen1}-h2-${h2}.phen ${phen2}-h2-${h2}.phen > ${out}-h2-${h2}.phen
done
