#!/bin/bash
#$ -N job-corr
#$ -l h_rt=00:30:00,h_data=8G
##$ -t 1-10:1 
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
#h2=$(( SGE_TASK_ID - 1))
pop1=$1
pop2=$2
pop=${pop1}-${pop2}


for h2 in {0..9}
do
	out="../../data/val/${pop2}/corr/${pop}-grm-${h2}.txt"
	[ -f $out ] && rm $out
	for r in {1..100}
	do
		echo "h2 $h2 replica $r"
		R2=$(Rscript r2-calc.R ../../data/val/${pop2}/prs/${pop}-h2-${h2}-r-${r}-pheno.profile)
		echo -e ${h2}"\t"${r}"\t"$R2"\t"$pop1"\t"$pop2"\tgrm" >> $out
	done
done

echo "sleeping"
sleep 5m
echo "done"


