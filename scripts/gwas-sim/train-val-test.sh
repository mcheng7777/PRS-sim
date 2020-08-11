#!/bin/bash
## Description: This script partitions one population's phenotype data into training, validation, and testing

# training and validation population
pop=$1
effect=$3
outdir="../../data/train/$pop/pheno"
names="${outdir}/${pop}-indi"
out="${outdir}/$pop"

# testing population
testpop=$2
testdir="../../data/val/$testpop/pheno"
testnames="${testdir}/${testpop}-indi"
testout="${testdir}/$testpop"



for h2 in {0..9}
do
	# Read In original train file and split into train and validation
	# data="../../data/${pop}/pheno/${pop}-h2-${h2}-scaled"
	data="${outdir}/${pop}-h2-${h2}"
	testdata="${testdir}/${testpop}-h2-${h2}"
	datagen="../../data/train/${pop}/blup/${pop}-h2-${h2}-genetic"
	# echo "partitioning h2: ${h2}"
	# grep -F -wf ${names}-train.txt ${data}.phen > ${data}-train.phen
	# grep -F -wf ${names}-val.txt ${data}.phen > ${data}-val.phen
	# grep -F -wf ${names}-test.txt ${data}.phen > ${data}-test.phen
	## subset training into 60% train, 10% val, scaled = just a naming convention (not actually scaled all the time)
	# If applicable, make sure genetic-effect file has same ID columns as original effect file 
	if [ $effect == "genetic" ]
	then
		awk '{print $1}' ${data}-train.phen > ${names}-genetic-train.txt
		awk '{print $1}' ${data}-val.phen > ${names}-genetic-val.txt
		grep -F -wf ${names}-genetic-train.txt ${datagen}-train.phen > ${data}-train-temp.phen
        	grep -F -wf ${names}-genetic-val.txt  ${datagen}-train.phen > ${data}-val-temp.phen
		awk 'FNR==NR{a[NR]=$2;next}{$2=a[FNR]}1' ${data}-train.phen ${data}-train-temp.phen > ${data}-genetic-train.phen
		awk 'FNR==NR{a[NR]=$2;next}{$2=a[FNR]}1' ${data}-val.phen ${data}-val-temp.phen > ${data}-genetic-val.phen
		# cp ${data}-val.phen ${data}-scaled-test.phen
		rm ${data}-train-temp.phen
		rm ${data}-val-temp.phen
	else
		awk '{print $1}' ${out}.fam | sort -R > ${names}-rand.txt
		# awk -v a=${out}-afr.txt -v e=${out}-eur.txt '{ if ($1 ~ /afr/) print $1 > a; else print $1 > e; }' ${out}.fam
		total=$(cat ${names}-rand.txt | wc -l)
		train=$(( total / 100 * 70 ))
		val=$(( total / 100 * 20 ))
		head -n $train ${names}-rand.txt > ${names}-train.txt
		tail -n +$(($train + 1)) ${names}-rand.txt | head -n ${val} > ${names}-val.txt
		tail -n +$(($train + $val + 1)) ${names}-rand.txt > ${testnames}-test.txt
		grep -F -wf ${names}-train.txt ${data}.phen > ${data}-train.phen
        	grep -F -wf ${names}-val.txt  ${data}.phen > ${data}-val.phen
		grep -F -wf ${testnames}-test.txt  ${data}.phen > ${testdata}.phen
		# cp ${data}-val.phen ${data}-scaled-test.phen
	fi
done
