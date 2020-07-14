#$ -N job-filter
#$ -cwd
#$ -l h_rt=05:00:00,h_data=16G
#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load vcftools
module load bcftools

popinfo='../data/1000Genomes_Samples_Populations.txt'
hapmatrix='../data/ALL.chr1.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz'
snps='../data/first-2000-snps.txt'
pop=$1
outdir="../data/$pop/pheno"
out="${outdir}/$pop"

echo "creating filtered file"
vcftools \
	--gzvcf $hapmatrix \
	--maf 0.05 \
	--recode \
	--keep ${out}.txt \
	--out ${out}
bcftools view ${out}.recode.vcf -Oz -o ${out}.vcf.gz
bcftools index ${out}.vcf.gz

# for hoffman time out
echo "sleeping"
sleep 5m

# --keep ${out}.txt \
