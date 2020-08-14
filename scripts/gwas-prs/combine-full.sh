#$ -N job-combine-test
#$ -l h_rt=00:15:00,h_data=4G
#$ -cwd

#!/bin/bash
# Usage: combine-full.sh [test population] [original or genetic]
# Combine populations' correlation files into one file

# declare variables
pop=$1
effect=$2
cd ../../data/val/$pop/corr
if [[ -f ${pop}-gwas.txt ]]
then
	rm ${pop}-gwas.txt
fi

# combine 
if [ $effect == "genetic" ]
then
        ls | grep "full-genetic-corr-test" | xargs cat >> ${pop}-genetic-gwas.txt
else
	ls | grep "full-corr-test" | xargs cat >> ${pop}-gwas.txt
fi
echo "sleeping"
sleep 5m
