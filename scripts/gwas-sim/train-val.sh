#/bin/bash

# Usage: train-val.sh [population]["genetic" or "original"]
# Split phenotype file into training and validation individuals

pop=$1
effect=$2
outdir="../../data/train/$pop/pheno"
names="${outdir}/${pop}-indi"
out="${outdir}/$pop"

# pseudorandomize individuals
awk '{print $1}' ${out}.fam | sort -R > ${names}-rand.txt
total=$(cat ${names}-rand.txt | wc -l)
train=$(( total / 100 * 80 ))

# subset phenotype individuals
head -n $train ${names}-rand.txt > ${names}-train.txt
tail -n +$((train + 1)) ${names}-rand.txt > ${names}-val.txt

for h2 in {0..9}
do
        # Read In original train file and split into train and validation
        data="../../data/train/${pop}/pheno/${pop}-h2-${h2}"
        datagen="../../data/train/${pop}/pheno/${pop}-h2-${h2}-genetic"
	# If applicable, make sure genetic-effect file has same ID columns as original effect file 
        if [ $effect == "genetic" ]
        then
        	awk '{print $1}' ${data}-train.phen > ${names}-genetic-train.txt
                awk '{print $1}' ${data}-val.phen > ${names}-genetic-val.txt
                grep -F -wf ${names}-genetic-train.txt ${datagen}-train.phen > ${datagen}-train-temp.phen
                grep -F -wf ${names}-genetic-val.txt  ${datagen}-train.phen > ${datagen}-val-temp.phen
                awk 'FNR==NR{a[NR]=$2;next}{$2=a[FNR]}1' ${data}-train.phen ${datagen}-train-temp.phen > ${datagen}-train.phen
                awk 'FNR==NR{a[NR]=$2;next}{$2=a[FNR]}1' ${data}-val.phen ${datagen}-val-temp.phen > ${datagen}-val.phen
                rm ${datagen}-train-temp.phen
                rm ${datagen}-val-temp.phen
	else
                grep -F -wf ${names}-train.txt ${data}.phen > ${data}-train.phen
                grep -F -wf ${names}-val.txt  ${data}.phen > ${data}-val.phen
        fi
done
