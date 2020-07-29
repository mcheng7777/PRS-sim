#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: ./prepare.sh [population 1] [population 2]"
	exit 1
fi

. /u/local/Modules/default/init/modules.sh
module load plink

pop1=$1
pop2=$2

if [ $pop1 == $pop2 ]
then 
	traindir="../../data/train/${pop1}-${pop2}"
	valdir="../../data/val/${pop1}-${pop2}"
	train="${traindir}/pheno/${pop1}-${pop2}"
	val="${valdir}/pheno/${pop1}-${pop2}"
else
	traindir="../../data/train/${pop1}"
	valdir="../../data/val/${pop1}-${pop2}"
	train="${traindir}/pheno/${pop1}"
	val="${valdir}/pheno/${pop1}-${pop2}"
fi

bfile1="../../data/bfile/$pop1"
bfile2="../../data/bfile/$pop2"

if [ ! -d $traindir ] 
then
	mkdir ${traindir}
	mkdir ${traindir}/pheno
	mkdir ${traindir}/grm
	mkdir ${traindir}/blup
fi

if [ ! -d $valdir ]
then
	mkdir ${valdir}
	mkdir ${valdir}/pheno
	mkdir ${valdir}/prs
	mkdir ${valdir}/corr
fi




if [ $pop1 == $pop2 ]
then 
	# randomly split into training and validation
	awk '{print $1}' ${bfile1}.fam | sort -R > ${train}-indi-rand.txt
	total=$(cat ${train}-indi-rand.txt | wc -l)
	numtrain=$(( total / 100 * 70 ))
	head -n $numtrain ${train}-indi-rand.txt > ${train}-indi-train.txt
	tail -n +$(( numtrain + 1 )) ${train}-indi-rand.txt > ${val}-indi-val.txt

	# create separate bfiles for training and validation
	plink --bfile $bfile1 --keep-fam ${train}-indi-train.txt --keep-allele-order --make-bed --out ${train}
	plink --bfile $bfile1 --keep-fam ${val}-indi-val.txt --keep-allele-order --make-bed --out ${val}

else
	
	[ ! -f ${train}.bed ] && cp ${bfile1}.bed ${train}.bed
	[ ! -f ${train}.bim ] && cp ${bfile1}.bim ${train}.bim
	[ ! -f ${train}.fam ] && cp ${bfile1}.fam ${train}.fam

	[ ! -f ${val}.bed ] && cp ${bfile2}.bed ${val}.bed
	[ ! -f ${val}.bim ] && cp ${bfile2}.bim ${val}.bim
	[ ! -f ${val}.fam ] && cp ${bfile2}.fam ${val}.fam
fi

# get causal traits
awk '{print $2}' ${bfile1}.bim | sort -R > ${train}-causal.snplist
numvariants=$(cat ${train}-causal.snplist | wc -l )
numcausal=$(( numvariants * 1000 / 1000 ))
head -n ${numcausal} ${train}-causal.snplist > temp
mv temp ${train}-causal.snplist
