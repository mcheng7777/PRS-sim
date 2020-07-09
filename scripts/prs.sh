#$ -N prs-sim
#$ -l h_rt=1:00:00,h_data=8G
#$ -cwd

#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load plink

# tutorial: https://choishingwan.github.io/PRS-Tutorial/plink/
# Generating PRS model
# Requisites:
# phenotype summary statistics (output of gwas-prs-model.sh)
# bed/bim/fam files
# phenotype matrix
# covariate matrix

pop="sim"
herit="h2-0.4"
sum_stats="../data/${pop}/gwas/${herit}.P1.assoc.linear"
b_files="../data/${pop}/pheno/${pop}"
phen_file="../data/${pop}/pheno-test/${pop}-h2-4-scaled-train.phen"
phen_val="../data/${pop}/pheno-test/${pop}-h2-4-scaled-val.phen"

outdir="../data/${pop}/prs/"
mkdir $outdir

# step 1 - clumping/LD
if [ -f ${outdir}${herit}.clumped ] 
then
	echo "using ${outdir}${herit}.clumped"
else
	plink \
		--bfile $b_files \
		--clump-p1 1 \
		--clump-r2 0.1 \
		--clump-kb 250 \
		--clump $sum_stats \
		--clump-snp-field SNP \
		--clump-field P \
		--out ${outdir}${herit}
fi

# extract SNP ids
awk 'NR!=1{print $3}' ${outdir}${herit}.clumped > ${outdir}${herit}.valid.snp

# snp id's and p-values
awk '{print $2,$9}' $sum_stats > ${outdir}${herit}.SNP.pvalue

# pvalue range list for inclusion in PRS
echo "0.001 0 0.001" > ${outdir}${herit}.rangelist
echo "0.05 0 0.05" >> ${outdir}${herit}.rangelist
echo "0.1 0 0.1" >> ${outdir}${herit}.rangelist
echo "0.2 0 0.2" >> ${outdir}${herit}.rangelist
echo "0.3 0 0.3" >> ${outdir}${herit}.rangelist
echo "0.4 0 0.4" >> ${outdir}${herit}.rangelist
echo "0.5 0 0.5" >> ${outdir}${herit}.rangelist

# calculate PRS for training and validation
plink \
	--bfile $b_files \
	--pheno $phen_file --all-pheno --allow-no-sex \
	--score $sum_stats 2 4 7 header \
	--q-score-range ${outdir}${herit}.rangelist ${outdir}${herit}.SNP.pvalue \
	--extract ${outdir}${herit}.valid.snp \
	--out ${outdir}${herit}-train

plink \
        --bfile $b_files \
        --pheno $phen_val --all-pheno --allow-no-sex \
        --score $sum_stats 2 4 7 header \
        --q-score-range ${outdir}${herit}.rangelist ${outdir}${herit}.SNP.pvalue \
        --extract ${outdir}${herit}.valid.snp \
        --out ${outdir}${herit}-val

#LD prune and PRS
if [ -f ../data/${pop}/pca/${herit}.prune.in ]
then
	echo "using ../data/${pop}/pca/${herit}.prune.in"
else
	plink \
		--bfile $b_files \
		--indep-pairwise 200 50 0.25 \
		--out "../data/${pop}/pca/${herit}"
	plink \
		--bfile $b_files \
		--extract "../data/${pop}/pca/${herit}.prune.in" \
		--pca 5 header \
		--out "../data/${pop}/pca/${herit}-pruned-pca"
fi

echo "sleeping"
sleep 5m
