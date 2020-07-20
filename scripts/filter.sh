#$ -N job-filter
#$ -cwd
#$ -l h_rt=05:00:00,h_data=16G
#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load vcftools
module load bcftools

if [ $# -ne 2 ]
then
	echo "Usage: ./filter.sh [population 1] [population 2]"
	exit 1
fi


if [ ${1} == ${2} ]
then 
	echo "one population"
	pop=$1
else 
	echo "two populations"
	pop="${1}-${2}"
fi


#hapmatrix='../data/ALL.chr1.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz'
hapmatrix='../data/full.recode.vcf'
snps='../data/first-2000-snps.txt'
pop1=$1
pop2=$2
outdir="../data/$pop/vcf"
out="${outdir}/$pop"

if [ ${1} != ${2} ]
then 
	echo "filtering two populations"
	cat "../data/${pop1}.txt" "../data/${pop2}.txt" > "../data/${pop}.txt"
fi

vcftools \
	--vcf $hapmatrix \
	--recode \
	--keep "../data/${pop}.txt" \
	--out ${out}

phenodir="../data/${pop}/pheno"
head -1253 ${out}.recode.vcf > ${phenodir}/${pop}.recode.vcf
cp ../data/${pop1}.txt ${phenodir}/indi-train.txt
cp ../data/${pop2}.txt ${phenodir}/indi-val.txt

# for hoffman time out
echo "sleeping"
sleep 5m

# --keep ${out}.txt \
# --gzvcf $hapmatrix \
# --maf 0.05 \
