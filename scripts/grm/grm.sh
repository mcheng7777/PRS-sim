#$ -N job-grm
#$ -cwd
#$ -l h_rt=03:00:00,h_data=32G
#$ -j y
#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: ./grm.sh [pop]"
	exit 1
fi

pop=$1

gcta="../../bin/gcta64"
bfile="../../data/train/${pop}/pheno/${pop}" 
grm="../../data/train/${pop}/grm/${pop}"

$gcta --bfile ${bfile} --make-grm --out ${grm} 

echo "sleeping"
sleep 5m
echo "done"

#--extract ${prune}.prune.in
