#$ -N pheno-sim
#$ -cwd
#$ -t 1-9:1
#$ -l h_rt=00:05:00,h_data=8G
#!/bin/bash

# SGE_TASK_ID=1

. /u/local/Modules/default/init/modules.sh
module load vcftools
module load gcta
module load plink

gcta='../bin/gcta64'
popinfo='../data/1000Genomes_Samples_Populations.txt'
hapmatrix='../data/ALL.chr1.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz'
pop="euro"
out="../data/$pop/$pop"

# set heritibility parameter
h2=0.${SGE_TASK_ID}
phenout=${out}-h2-${h2}

# select european individuals
grep "CEU\|TSI\|FIN\|GBR\|IBS" $popinfo | awk '{print $1}' > $out.txt

# filter vcf by MAF and pop
if [ -f ${out}.recode.vcf ]; then
	echo "using filtered file: " ${out}.recode.vcf
else 
	echo "creating filtered file"
	vcftools --gzvcf $hapmatrix --plink --maf 0.01 --keep $pop.txt --out $pop
fi

# create bed files for gcta sim
if [ -f ${out}.bed ]; then
	echo "using files: " ${out}.bed", "${out}.fam", "${out}.bim
else 
	echo "creating *.bed, *.fam, *.bim files"
	plink --vcf $out.recode.vcf --make-bed --out $out
fi

# get causal traits
if [ -f causal.snplist ]; then
	echo "using existing causal.snplist"
else 
	echo "generating new causal.snplist"
	awk '{print $2}' $out.bim | sort | uniq > causal.snplist
fi

# Simulate a quantitative trait with the heritability of 0.5 for a subset of individuals for 1 times
$gcta --bfile $out --simu-qt --chr 1 --simu-hsq $h2 --simu-rep 10 --simu-causal-loci causal.snplist --out $phenout

# training and validation file paths
train=${phenout}-train.phen
val=${phenout}-val.phen

# splitting data into test and validation
sort -R ${phenout}.phen | awk '{if(rand() < 0.2) {print $0 > "val"} else {print $0 > "train"}}'
mv train $train
mv val $val

# for hoffman time out
echo "sleeping"
sleep 5m

