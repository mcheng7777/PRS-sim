#!/bin/bash
#$ -N job-corr
#$ -l h_rt=00:30:00,h_data=8G
#$ -t 1-10:1 
#$ -cwd

. /u/local/Modules/default/init/modules.sh
module load R/3.5.1

h2=$(( SGE_TASK_ID - 1))
pop=$1
out="corr-${h2}.txt"

echo -e "heritability\treplica\tR2" > $out

for r in {1..100}
do
	echo "replica $r"
	R2=$(Rscript r2-calc.R ../data/${pop}/prs/${pop}-h2-${h2}-r-${r}-val.profile)
	echo -e ${h2}"\t"${r}"\t"$R2 >> $out
done

echo "sleeping"
sleep 5m
echo "done sleeping"


