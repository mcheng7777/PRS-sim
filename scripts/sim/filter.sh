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


#hapmatrix='../data/ALL.chr1.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz'
hapmatrix='../../data/vcf/full.recode.vcf'
pop=$1
out="../../data/vcf/$pop"

vcftools \
	--vcf $hapmatrix \
	--recode \
	--keep "${out}.txt" \
	--out ${out}

# for hoffman time out
echo "sleeping"
sleep 5m

# --keep ${out}.txt \
# --gzvcf $hapmatrix \
# --maf 0.05 \
