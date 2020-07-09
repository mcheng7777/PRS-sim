
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
phen_file="../data/${pop}/pheno-test/${pop}-h2-4-scaled-train.phen"
outdir="../data/${pop}/gwas/"
pca_out="../data/${pop}/pca/"
herit="h2-0.4"

mkdir $outdir

mkdir $pca_out

#LD prune and PCA
plink \
        --bfile $bin_files \
        --indep-pairwise 200 50 0.25 \
        --out ${pca_out}${herit}
plink \
        --bfile $bin_files \
        --extract ${pca_out}${herit}.prune.in \
        --pca 5 header \
        --out ${pca_out}${herit}-pruned-pca

# run plink quantitative association simulation
plink --bfile $bin_files --linear 'hide-covar' --pheno $phen_file --all-pheno --allow-no-sex --covar ${pca_out}${herit}-pruned-pca.eigenvec --covar-name PC1, PC2, PC3, PC4, PC5 --out ${outdir}${herit}


# for hoffman time requirement
echo "sleeping"
sleep 5m
