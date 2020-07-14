#$ -N job-gcta-prs
#$ -l h_rt=1:00:00,h_data=8G
#$ -t 1-10:1
#$ -cwd

#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load plink


if [ $# -ne 1 ]
then
	echo "Usage: ./gcta-prs.sh [population]"
	exit 1
fi

# SGE_TASK_ID=10
pop=$1
bfile="../data/${pop}/pheno/${pop}"
h2=$(( SGE_TASK_ID - 1 ))
echo $h2

for r in {1..100}
do
	name="${pop}-h2-${h2}-r-${r}"
	score="../data/${pop}/blup/${name}.snp.blp"
	out="../data/${pop}/prs/${name}"
	pheno="../data/${pop}/pheno/${pop}-h2-${h2}-scaled.phen"
	plink \
		--bfile $bfile \
		--pheno $pheno --mpheno ${r} --allow-no-sex \
		--score ${score} 1 2 3 \
		--out ${out}
	awk '{printf $1 "\t" $3 "\t" $4 * $6 * 2 "\n"}' ${out}.profile > ${out}-pheno.profile
	grep -F -wf "../data/${pop}/pheno/indi-val.txt" ${out}-pheno.profile > ${out}-val.profile
done

echo "sleeping"
sleep 5m
echo "done sleeping"
