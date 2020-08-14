#$ -N job-combine-test
#$ -l h_rt=00:15:00,h_data=4G
#$ -cwd

#!/bin/bash
# Usage: combine-test.sh [train population] [test population] [original or genetic]
# Combine correlation files

# declare variables
trainpop=$1
pop=$2
effect=$3

# set working directory
cd ../../data/val/$pop/$trainpop/
mkdir ../corr

# combine correlation files
if [ $effect == "genetic" ]
then
        ls | grep "genetic-corr-[0-9]-test" | xargs cat >> ../corr/${trainpop}-full-genetic-corr-test.txt
else
	ls | grep "^corr-[0-9]-test" | xargs cat >> ../corr/${trainpop}-full-corr-test.txt
fi
echo "sleeping"
sleep 5m
