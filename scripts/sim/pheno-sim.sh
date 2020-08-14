#$ -N job-pheno-sim
#$ -cwd
#$ -l h_rt=00:30:00,h_data=16G
#$ -t 1-10:1
#$ -j y
#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load plink
module load R/3.5.1


if [ $# -ne 2 ]
then
	echo "Usage: ./pheno-sim.sh [pop] [train|val]"
	exit 1
fi

gcta='../../bin/gcta64'

#SGE_TASK_ID=1
pop=$1
mode=$2
h2=$(( SGE_TASK_ID - 1 ))

out="../../data/${mode}/${pop}/pheno/${pop}"
causal="./effects/causal"

# simulate a quantitative traits at various heritability levels
$gcta \
	--bfile ${out} \
	--simu-qt \
	--simu-hsq 0.${h2} \
	--simu-rep 100 \
	--simu-causal-loci ${causal}-h2-${h2}.snplist \
	--out ${out}-h2-${h2}

# for hoffman time out
echo "sleeping"
sleep 5m
echo "done"



