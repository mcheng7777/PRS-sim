#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load vcftools
module load gcta
module load plink

popinfo='../data/1000Genomes_Samples_Populations.txt'
hapmatrix='../data/ALL.chr1.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz'
pop="euro"
out="../data/$pop/$pop"

# select european individuals
grep "CEU\|TSI\|FIN\|GBR\|IBS" $popinfo | awk '{print $1}' > $out.txt

# filter vcf by MAF and pop
# vcftools --gzvcf $hapmatrix --plink --maf 0.01 --keep $pop.txt --out $pop

# create bed files for gcta sim
plink --vcf $out.recode.vcf --make-bed --out $out

awk '{print $2"\t"1}' $out.bim > causal.snplist
# Simulate a quantitative trait with the heritability of 0.5 for a subset of individuals for 1 times
gcta64  --bfile $out --simu-qt --simu-hsq 0.5 --simu-rep 10 --simu-causal-loci causal.snplist --out $out



