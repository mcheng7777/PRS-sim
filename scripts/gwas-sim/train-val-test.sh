#!/bin/bash

pop=$1
# testpop=$3
effect=$2
outdir="../../data/train/$pop/pheno"
# testdir="../../data/val/$testpop/pheno"
names="${outdir}/${pop}-indi"
# testnames="${testdir}/${testpop}-indi"
out="${outdir}/$pop"
# testout="${testdir}/$testpop"
awk '{print $1}' ${out}.fam | sort -R > ${names}-rand.txt
# awk '{print $1}' ${testout}.fam > ${testnames}-test.txt
# awk -v a=${out}-afr.txt -v e=${out}-eur.txt '{ if ($1 ~ /afr/) print $1 > a; else print $1 > e; }' ${out}.fam
total=$(cat ${names}-rand.txt | wc -l)
train=$(( total / 100 * 80 ))
# val=$(( total / 100 * 20))

head -n $train ${names}-rand.txt > ${names}-train.txt
tail -n +$((train + 1)) ${names}-rand.txt > ${names}-val.txt # | head -n ${val} > ${names}-val.txt
# tail -n +$((train + $val + 1)) ${names}-rand.txt > ${names}-test.txt

for h2 in {0..9}
do
	# Read In original train file and split into train and validation
	# data="../../data/${pop}/pheno/${pop}-h2-${h2}-scaled"
	data="../../data/train/${pop}/pheno/${pop}-h2-${h2}"
	datagen="../../data/train/${pop}/pheno/${pop}-h2-${h2}-genetic"
	# echo "partitioning h2: ${h2}"
	# grep -F -wf ${names}-train.txt ${data}.phen > ${data}-train.phen
	# grep -F -wf ${names}-val.txt ${data}.phen > ${data}-val.phen
	# grep -F -wf ${names}-test.txt ${data}.phen > ${data}-test.phen
	## subset training into 60% train, 10% val, scaled = just a naming convention (not actually scaled all the time)
	# If applicable, make sure genetic-effect file has same ID columns as original effect file 
	if [ $effect == "genetic" ]
	then
		grep -F -wf ${names}-train.txt ${datagen}-train.phen > ${datagen}-train-temp.phen
        	grep -F -wf ${names}-val.txt  ${datagen}-train.phen > ${datagen}-val-temp.phen
		awk 'FNR==NR{a[NR]=$2;next}{$2=a[FNR]}1' ${data}-train.phen ${datagen}-train-temp.phen > ${datagen}-train.phen
		awk 'FNR==NR{a[NR]=$2;next}{$2=a[FNR]}1' ${data}-val.phen ${datagen}-val-temp.phen > ${datagen}-val.phen
		# cp ${data}-val.phen ${data}-scaled-test.phen
		rm ${datagen}-train-temp.phen
		rm ${datagen}-val-temp.phen
	else
		grep -F -wf ${names}-train.txt ${data}.phen > ${data}-train.phen
        	grep -F -wf ${names}-val.txt  ${data}.phen > ${data}-val.phen
		grep -F -wf ${names}-val.txt  ${data}.phen > ${data}-test.phen
		# cp ${data}-val.phen ${data}-scaled-test.phen
	fi
done
