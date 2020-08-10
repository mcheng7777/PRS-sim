#$ -N job-gcta-prs
#$ -l h_rt=02:00:00,h_data=42G
#$ -t 1-10:1
#$ -j y
##$ -hold_jid job-blup
#$ -cwd

#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load plink


if [ $# -ne 2 ]
then
	echo "Usage: ./gcta-prs.sh [train pop] [val pop]"
	exit 1
fi

#SGE_TASK_ID=10
h2=$(( SGE_TASK_ID - 1 ))
pop1=$1
pop2=$2
bfile="../../data/val/${pop2}/pheno/${pop2}"

for r in {1..100}
do
	score="../../data/train/${pop1}/blup/${pop1}-h2-${h2}-r-${r}.snp.blp"
	out="../../data/val/${pop2}/prs/${pop1}-${pop2}-h2-${h2}-r-${r}"
	pheno="../../data/val/${pop2}/pheno/${pop2}-h2-${h2}.phen"

	plink \
		--bfile $bfile \
		--pheno $pheno --mpheno ${r} --allow-no-sex \
		--score ${score} 1 2 3 \
		--out ${out}
	awk '{printf $1 "\t" $3 "\t" $4 * $6 * 2 "\n"}' ${out}.profile \
		> ${out}-pheno.profile
done

echo "sleeping"
sleep 5m
echo "done"
