#$ -N job-filter
#$ -cwd
#$ -l h_rt=05:00:00,h_data=16G
#$ -j y
#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load vcftools
module load bcftools

if [ $# -ne 1 ]
then
	echo "Usage: ./filter.sh [population 1]"
	exit 1
fi


# input files
hapmatrix='../../data/vcf/full.recode.vcf'
pop=$1
out="../../data/vcf/$pop"

# filter by population
vcftools \
	--vcf $hapmatrix \
	--recode \
	--keep "${out}.txt" \
	--out ${out}

# for hoffman time out
echo "sleeping"
sleep 5m
