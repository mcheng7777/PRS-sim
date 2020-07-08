
#$ -N gwas-sim
#$ -cwd
#$ -l h_rt=1:00:00,h_data=8G

#!/bin/bash


# load modules
. /u/local/Modules/default/init/modules.sh
module load plink

# create directory and file variables
pop="sim"
bin_files="../data/${pop}/pheno/${pop}"
phen_file="../data/${pop}/pheno-test/${pop}-h2-1-scaled-train.phen"
outdir="../data/${pop}/gwas/gwas-pca-covar"
pca_out="../data/${pop}/pca"
mkdir $outdir

mkdir $pca_out

#LD prune and PCA
plink \
        --bfile $b_files \
        --indep-pairwise 200 50 0.25 \
        --out "../data/${pop}/pca/${outname}"
plink \
        --bfile $b_files \
        --extract "../data/${pop}/pca/${outname}.prune.in" \
        --pca 5 \
        --out "../data/${pop}/pca/${outname}-pruned-pca"\
# run plink quantitative association simulation
plink --bfile $bin_files --linear 'hide-covar' --pheno $phen_file --all-pheno --allow-no-sex --covar ${pca_out}/h2-0.1-pca.eigenvec --covar-name PC1, PC2, PC3, PC4, PC5 --out ${outdir}/h2-0.1-scaled


# for hoffman time requirement
echo "sleeping"
sleep 5m
