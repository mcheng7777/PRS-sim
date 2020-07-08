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

sum_stats="../data/euro/gwas-test/h2-0.1-scaled.P1.assoc.linear"
b_files="../data/euro/pheno-test/euro"
phen_file="../data/euro/pheno-test/euro-h2-1-scaled-train.phen"
phen_val="../data/euro/pheno-test/euro-h2-1-scaled-val.phen"
cov_file="../data/euro/pca/h2-0.1-pca.eigenvec"

outdir="../data/euro/prs/"
mkdir $outdir
outname="h2-0.1"
# step 1 - clumping/LD
if [ -f ${outdir}${outname}.clumped ] 
then
	echo "using ${outdir}${outname}.clumped"
else
	plink \
		--bfile $b_files \
		--clump-p1 1 \
		--clump-r2 0.1 \
		--clump-kb 250 \
		--clump $sum_stats \
		--clump-snp-field SNP \
		--clump-field P \
		--out ${outdir}${outname}
fi

# extract SNP ids
awk 'NR!=1{print $3}' ${outdir}${outname}.clumped > ${outdir}${outname}.valid.snp

# snp id's and p-values
awk '{print $2,$9}' $sum_stats > ${outdir}${outname}.SNP.pvalue

# pvalue range list for inclusion in PRS
echo "0.001 0 0.001" > ${outdir}${outname}.rangelist
echo "0.05 0 0.05" >> ${outdir}${outname}.rangelist
echo "0.1 0 0.1" >> ${outdir}${outname}.rangelist
echo "0.2 0 0.2" >> ${outdir}${outname}.rangelist
echo "0.3 0 0.3" >> ${outdir}${outname}.rangelist
echo "0.4 0 0.4" >> ${outdir}${outname}.rangelist
echo "0.5 0 0.5" >> ${outdir}${outname}.rangelist

# calculate PRS for training and validation
plink \
	--bfile $b_files \
	--pheno $phen_file --all-pheno --allow-no-sex \
	--score $sum_stats 2 4 7 header \
	--q-score-range ${outdir}${outname}.rangelist ${outdir}${outname}.SNP.pvalue \
	--extract ${outdir}${outname}.valid.snp \
	--out ${outdir}${outname}-train

plink \
        --bfile $b_files \
        --pheno $phen_val --all-pheno --allow-no-sex \
        --score $sum_stats 2 4 7 header \
        --q-score-range ${outdir}${outname}.rangelist ${outdir}${outname}.SNP.pvalue \
        --extract ${outdir}${outname}.valid.snp \
        --out ${outdir}${outname}-val

#LD prune and PRS
plink \
	--bfile $b_files \
	--indep-pairwise 200 50 0.25 \
	--out "../data/euro/pca/${outname}"
plink \
	--bfile $b_files \
	--extract "../data/euro/pca/${outname}.prune.in" \
	--pca 5 \
	--out "../data/euro/pca/${outname}-pruned-pca"


echo "sleeping"
sleep 5m
