
#$ -N gwas-sim
#$ -cwd
#$ -l h_rt=1:00:00,h_data=8G

#!/bin/bash


# load modules
. /u/local/Modules/default/init/modules.sh
module load plink

# create directory and file variables
bin_files="../data/euro/pheno/euro"
phen_file="../data/euro/pheno/euro-h2-1-scaled-train.phen"
outdir="../data/euro/gwas/gwas-pca-covar"
pca_out="../data/euro/pca"
mkdir $outdir

mkdir $pca_out

# run pca
# plink --bfile $bin_files --pca 5 'header' --out ${pca_out}/h2-0.1-pca
# run plink quantitative association simulation
plink --bfile $bin_files --linear 'hide-covar' --pheno $phen_file --all-pheno --allow-no-sex --covar ${pca_out}/h2-0.1-pca.eigenvec --covar-name PC1, PC2, PC3, PC4, PC5 --out ${outdir}/h2-0.1-scaled


# for hoffman time requirement
# echo "sleeping"
# sleep 5m
