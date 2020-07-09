#$ -N job-pheno-sim
#$ -cwd
#$ -l h_rt=00:30:00,h_data=8G
#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load plink
module load R/3.5.1

gcta='../bin/gcta64'
pop=$1
outdir="../data/$pop/pheno"
out="${outdir}/$pop"

# create bed files for gcta sim
if [ $pop == "sim" ]
then 
	echo "simulating genotype"
	./geno-sim.sh
else 
	plink --vcf ${out}.recode.vcf --make-bed --out ${out}-temp

	# remove duplicates
	cut -f 2 ${out}-temp.bim | sort | uniq -d > ${out}.dups
	plink --bfile ${out}-temp --exclude ${out}.dups --make-bed --out ${out}
	rm ${out}-temp*
fi

# get causal traits
awk '{print $2}' $out.bim > ${out}-causal.snplist

# simulate a quantitative traits at various heritability levels

for h2 in {0..9}
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

# standardized the phenotypes
Rscript ./standardize_phen.R /u/project/sriram/dtang200/PRS-sim/data/${pop}/pheno/

# split into training and validation
./train-val.sh $pop

# for hoffman time out
echo "sleeping"
sleep 5m

