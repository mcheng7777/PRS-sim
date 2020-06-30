#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load vcftools
module load gcta
module load plink

popinfo='../data/1000Genomes_Samples_Populations.txt'
hapmatrix='../data/ALL.chr1.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz'
pop="euro"

# select european individuals
grep "CEU\|TSI\|FIN\|GBR\|IBS" $popinfo | awk '{print $1}' > $pop.txt

# filter vcf by MAF and pop
 vcftools --gzvcf $hapmatrix --plink --maf 0.01 --keep $pop.txt --out $pop

# create bed files for gcta sim
plink --vcf $pop.recode.vcf --make-bed --out euro

# Simulate a quantitative trait with the heritability of 0.5 for a subset of individuals for 3 times
# gcta64  --bfile test  --simu-qt  --simu-causal-loci causal.snplist  --simu-hsq 0.5 --simu-rep 10 --keep test.indi.list --out test



