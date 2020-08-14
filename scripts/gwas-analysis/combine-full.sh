#$ -N job-combine-test
#$ -l h_rt=00:15:00,h_data=4G
#$ -cwd

#!/bin/bash

# trainpop=$1
pop=$1
effect=$2
cd ../../data/val/$pop/bias
if [[ -f ${pop}-bias-gwas.txt ]]
then
	rm ${pop}-bias-gwas.txt
fi
if [ $effect == "genetic" ]
then
        ls | grep "bias-genetic.txt" | xargs cat >> ${pop}-genetic-gwas.txt
else
	ls | grep "bias.txt" | xargs cat >> ${pop}-bias-gwas.txt
fi
echo "sleeping"
sleep 5m
