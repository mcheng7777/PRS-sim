#$ -N job-grm
#$ -cwd
#$ -l h_rt=00:05:00,h_data=8G
#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: ./grm.sh [population]"
	exit 1
fi

pop=$1
gcta="../bin/gcta64"
bfile="../data/${pop}/pheno/${pop}" 
grm="../data/${pop}/grm/${pop}"

$gcta --bfile ${bfile} --make-grm --out ${grm} 

echo "sleeping"
sleep 5m
echo "done sleeping"
