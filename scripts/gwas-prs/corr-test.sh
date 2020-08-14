#!/bin/bash

#$ -N job-test-corr
#$ -l h_rt=2:00:00,h_data=8G
#$ -t 1-10:1
#$ -hold_jid job-prs-test
#$ -cwd

#!/bin/bash
# Usage: corr-test [train population] [test population] [original or genetic]
# Find correlation between original and predicted phenotype

. /u/local/Modules/default/init/modules.sh
module load R/3.5.1

# SGE_TASK_ID=10
h2=$(( SGE_TASK_ID - 1))
# h2=7

# declare variables
trainpop=$1
pop=$2
effect=$3

# set writing file
if [ $effect == "genetic" ]
then
	out="../../data/val/${pop}/${trainpop}/genetic-corr-${h2}-test.txt"
else
	out="../../data/val/${pop}/${trainpop}/corr-${h2}-test.txt"
fi

# find correlation between prs and phenotype (found in prs test.profile)
for r in {1..100}
do
	echo "replicate: ${r}"
	if [ $effect == "genetic" ]
	then
		R2=$(Rscript r2-calc.R ../../data/val/${pop}/${trainpop}/genetic-prs/${pop}-h2-${h2}-r-${r}-test.profile)
	else
		R2=$(Rscript r2-calc.R ../../data/val/${pop}/${trainpop}/prs/${pop}-h2-${h2}-r-${r}-test.profile)
	fi
	# write into out file
	if [[ $r -eq 1 ]]
	then
                echo -e ${h2}"\t"${r}"\t"${R2}"\t"${trainpop}"\t"${pop}"\t""gwas" > $out
        else
                echo -e ${h2}"\t"${r}"\t"${R2}"\t"${trainpop}"\t"${pop}"\t""gwas" >> $out
        fi
done

echo "sleeping"
sleep 5m
echo "done sleeping"


