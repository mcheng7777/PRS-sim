#$ -N job-gcta-prs
#$ -l h_rt=03:00:00,h_data=8G
#$ -t 1-10:1
#$ -cwd

#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load plink


if [ $# -ne 2 ]
then
	echo "Usage: ./gcta-prs.sh [pop1] [pop2]"
	exit 1
fi

#SGE_TASK_ID=10
h2=$(( SGE_TASK_ID - 1 ))
pop1=$1
pop2=$2

if [ $pop1 == $pop2 ]
then
	pop=$pop1
else
	pop=${pop1}-${pop2}
fi
bfile="../../data/${pop}/pheno/${pop}-val"

for r in {1..100}
do
	name="${pop}-h2-${h2}-r-${r}"
	score="../../data/${pop}/blup/${name}.snp.blp"
	out="../../data/${pop}/prs/${name}"
	pheno="../../data/${pop}/pheno/${pop}-h2-${h2}-val.phen"
	plink \
		--bfile $bfile \
		--pheno $pheno --mpheno ${r} --allow-no-sex \
		--score ${score} 1 2 3 \
		--out ${out}
	awk '{printf $1 "\t" $3 "\t" $4 * $6 * 2 "\n"}' ${out}.profile > ${out}-pheno.profile
done

echo "sleeping"
sleep 5m
echo "done sleeping"
