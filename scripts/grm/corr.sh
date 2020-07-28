#!/bin/bash
#$ -N job-corr
#$ -l h_rt=00:30:00,h_data=8G
#$ -t 1-10:1 
#$ -j y
#$ -hold_jid job-gcta-prs
#$ -cwd

. /u/local/Modules/default/init/modules.sh
module load R/3.5.1


if [ $# -ne 2 ]
then
	echo "Usage: ./corr.sh [train pop] [val pop]"
	exit 1
fi

#SGE_TASK_ID=10
h2=$(( SGE_TASK_ID - 1))
pop1=$1
pop2=$2
pop=${pop1}-${pop2}

out="${pop}-grm-corr-${h2}.txt"

for r in {1..100}
do
	echo "replica $r"
	R2=$(Rscript r2-calc.R ../../data/val/${pop}/prs/${pop}-h2-${h2}-r-${r}-pheno.profile)
	echo -e ${h2}"\t"${r}"\t"$R2"\t"$pop2 >> $out
done

echo "sleeping"
sleep 5m
echo "done"


