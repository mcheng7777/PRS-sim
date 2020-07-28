#$ -N job-pheno-sim
#$ -cwd
#$ -l h_rt=01:00:00,h_data=32G
#$ -t 1-10:1
#$ -j y
#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load plink
module load R/3.5.1


if [ $# -ne 2 ]
then
	echo "Usage: ./pheno-sim.sh [train pop] [val pop]"
	exit 1
fi

gcta='../../bin/gcta64'

#SGE_TASK_ID=1
pop1=$1
pop2=$2
h2=$(( SGE_TASK_ID - 1 ))

train="../../data/train/${pop1}/pheno/${pop1}"
val="../../data/val/${pop1}-${pop2}/pheno/${pop1}-${pop2}"

# simulate a quantitative traits at various heritability levels

$gcta \
	--bfile ${val} \
	--simu-qt \
	--simu-hsq 0.${h2} \
	--simu-rep 100 \
	--simu-causal-loci ${train}-causal-h2-${h2}.snplist \
	--out ${val}-h2-${h2}

# for hoffman time out
echo "sleeping"
sleep 5m
echo "done"



