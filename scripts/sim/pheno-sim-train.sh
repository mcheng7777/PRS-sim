#$ -N job-pheno-sim
#$ -cwd
#$ -l h_rt=01:00:00,h_data=32G
#$ -t 1-10:1
#$ -j y
#$ -hold_jid job-hapgen
#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load plink
module load R/3.5.1


if [ $# -ne 1 ]
then
	echo "Usage: ./pheno-sim.sh [pop]"
	exit 1
fi

gcta='../../bin/gcta64'

pop=$1
h2=$(( SGE_TASK_ID - 1 ))

train="../../data/train/${pop}/pheno/${pop}"

# simulate a quantitative traits at various heritability levels

$gcta \
	--bfile ${train} \
	--simu-qt \
	--simu-hsq 0.${h2} \
	--simu-rep 100 \
	--simu-causal-loci ${train}-causal.snplist \
	--out ${train}-h2-${h2}

tail -n +2 ${train}-h2-${h2}.par | awk '{print $1" "$4}' > ${train}-causal-h2-${h2}.snplist

# for hoffman time out
echo "sleeping"
sleep 5m
echo "done"



