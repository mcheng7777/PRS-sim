#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load vcftools
module load gcta
module load plink

gcta='../bin/gcta64'
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

# get causal traits
awk '{print $2}' $out.bim | sort | uniq > causal.snplist

# Simulate a quantitative trait with the heritability of 0.5 for a subset of individuals for 1 times
$gcta --bfile $out --simu-qt --chr 1 --simu-hsq 0.5 --simu-rep 10 --simu-causal-loci causal.snplist --out $out



