#$ -N job-grm
#$ -cwd
#$ -l h_rt=02:00:00,h_data=16G
#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: ./grm.sh [pop1] [pop2]"
	exit 1
fi

pop1=$1
pop2=$2

if [ $pop1 == $pop2 ]
then 
	pop=$pop1
else
	pop=${pop1}-${pop2}
fi

gcta="../../bin/gcta64"
bfile="../../data/${pop}/pheno/${pop}-train" 
grm="../../data/${pop}/grm/${pop1}"

$gcta --bfile ${bfile} --make-grm --out ${grm} 

echo "sleeping"
sleep 5m
echo "done sleeping"
