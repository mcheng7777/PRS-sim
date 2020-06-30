#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load vcftools
module load gcta
module load plink

popinfo='../data/1000Genomes_Samples_Populations.txt'
hapmatrix='../data/ALL.chr1.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz'
pop="euro"

grep "CEU\|TSI\|FIN\|GBR\|IBS" $popinfo | awk '{print $1}' > $pop.txt

vcftools --gzvcf $hapmatrix --plink --maf 0.01 --keep $pop.txt --out $pop-only


