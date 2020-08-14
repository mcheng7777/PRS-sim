#$ -N job-pca
#$ -l h_rt=3:00:00,h_data=16G
#$ -cwd

#!/bin/bash
# Usage: gwas-prs-model.sh [population] ["original" or "genetic"]
# Prune SNPS and find principal components for GWAS



. /u/local/Modules/default/init/modules.sh
module load plink

# create directory and file variables
pop=$1
bin_files="../../data/train/${pop}/pheno/${pop}"

pca_out="../../data/train/${pop}/pca"
mkdir $pca_out
#LD prune and PCA
plink \
	--bfile $bin_files \
	--indep-pairwise 200 50 0.25 \
	--out ${bin_files}
plink \
	--bfile $bin_files \
	--extract ${bin_files}.prune.in \
	--pca 5 header \
	--out ${pca_out}/${pop}-pruned-pca

echo "sleeping"
sleep 5m
