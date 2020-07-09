#$ -N job-filter
#$ -cwd
#$ -l h_rt=01:00:00,h_data=8G
#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load vcftools
module load bcftools

popinfo='../data/1000Genomes_Samples_Populations.txt'
hapmatrix='../data/ALL.chr1.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz'
pop=$1
outdir="../data/$pop/pheno"
out="${outdir}/$pop"

# select european individuals
grep "CEU\|TSI\|FIN\|GBR\|IBS" $popinfo | awk '{print $1}' > $out.txt

echo "creating filtered file"
vcftools --gzvcf $hapmatrix --plink --maf 0.01 --keep $pop.txt --out $pop
bcftools view ${out}.recode.vcf -Oz -o ${out}.vcf.gz
bcftools index ${out}.vcf.gz

# for hoffman time out
echo "sleeping"
sleep 5m

