#!/bin/bash

pop=$1
names="../data/${pop}/pheno-test/indi"


total=$(cat ${names}-rand.txt | wc -l)
train=$(( total / 100 * 80 ))

head -n $train ${names}-rand.txt > ${names}-train.txt
tail -n +$((train + 1)) ${names}-rand.txt > ${names}-val.txt

for h2 in {0..9}
do
	data="../data/${pop}/pheno-test/${pop}-h2-${h2}-scaled"
	grep -f ${names}-train.txt ${data}.phen > ${data}-train.phen
	grep -f ${names}-val.txt ${data}.phen > ${data}-val.phen
done
