#!/bin/bash
#$ -N job-bias
#$ -l h_rt=00:30:00,h_data=8G
##$ -t 1-10:1 
#$ -j y
#$ -hold_jid job-gcta-prs
#$ -cwd

# Usage: bias.sh [train population] [test population]
# Assess bias in PRS

. /u/local/Modules/default/init/modules.sh
module load R/3.5.1


if [ $# -ne 2 ]
then
	echo "Usage: ./bias.sh [train pop] [test pop]"
	exit 1
fi

#SGE_TASK_ID=10
#h2=$(( SGE_TASK_ID - 1))
pop1=$1
pop2=$2
pop=${pop1}-${pop2}
mkdir ../../data/val/${pop2}/bias/
out="../../data/val/${pop2}/bias/${pop1}-bias.txt"
[ -f $out ] && rm $out

# assess bias
for h2 in {0..9}
do
for r in {1..100}
	do
		echo "h2 $h2 replica $r"
		diff=$(Rscript bias.R ../../data/val/${pop2}/${pop1}/prs/${pop2}-h2-${h2}-r-${r}-test.profile)
		echo -e ${h2}"\t"${r}"\t"$diff"\t"$pop1"\t"$pop2 >> $out
	done
done

echo "sleeping"
sleep 5m
echo "done"


