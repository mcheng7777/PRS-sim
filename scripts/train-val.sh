#!/bin/bash

pop="euro"
names="../data/${pop}/pheno/indi"

total=$(cat ${names}-rand.txt | wc -l)
train=$(( total / 100 * 80 ))

head -n $train ${names}-rand.txt > ${names}-train.txt
tail -n +$((train + 1)) ${names}-rand.txt > ${names}-val.txt

for h2 in {1..9}
do
	data="../data/${pop}/pheno/${pop}-h2-${h2}"
	grep -f ${names}-train.txt ${data}.phen > ${data}-train.phen
	grep -f ${names}-val.txt ${data}.phen > ${data}-val.phen
done
