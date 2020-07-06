#$ -N pheno-sim
#$ -cwd
#$ -l h_rt=00:30:00,h_data=8G
#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load vcftools
module load bcftools
module load gcta
module load plink

gcta='../bin/gcta64'
popinfo='../data/1000Genomes_Samples_Populations.txt'
hapmatrix='../data/ALL.chr1.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz'
pop="euro"
out="../data/$pop/pheno/$pop"

# select european individuals
grep "CEU\|TSI\|FIN\|GBR\|IBS" $popinfo | awk '{print $1}' > $out.txt

# filter vcf by MAF and pop
if [ -f ${out}.recode.vcf ]; then
	echo "using filtered file: " ${out}.recode.vcf
else 
	echo "creating filtered file"
	vcftools --gzvcf $hapmatrix --plink --maf 0.01 --keep $pop.txt --out $pop
	bcftools view ${out}.recode.vcf -Oz -o ${out}.vcf.gz
	bcftools index ${out}.vcf.gz
fi

# create bed files for gcta sim
if [ -f ${out}.bed ]; then
	echo "using files: " ${out}.bed", "${out}.fam", "${out}.bim
else 
	echo "creating *.bed, *.fam, *.bim files"
	plink --vcf ${out}.recode.vcf --make-bed --out ${out}-temp

	# remove duplicates
	cut -f 2 ${out}-temp.bim | sort | uniq -d > ${out}.dups
	plink --bfile ${out}-temp --exclude ${out}.dups --make-bed --out ${out}
	rm ${out}-temp*
fi

# get causal traits
if [ -f ${out}-causal.snplist ]; then
	echo "using existing causal.snplist"
else 
	echo "generating new causal.snplist"
	awk '{print $2}' $out.bim > ${out}-causal.snplist
fi

# Simulate a quantitative trait with the heritability of 0.5 for a subset of individuals for 1 times

for h2 in {1..9}
do
	$gcta \
	--bfile $out \
	--simu-qt \
	--chr 1 \
	--simu-hsq 0.${h2} \
	--simu-rep 100 \
	--simu-causal-loci ${out}-causal.snplist \

	--out ${out}-h2-${h2}
done

# split into training and validation
awk '{print $2}' ${out}.fam | sort -R > indi-rand.txt
./train-val.sh $pop

# for hoffman time out
echo "sleeping"
sleep 5m

