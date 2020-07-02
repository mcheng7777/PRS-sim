
#$ -N gwas-sim
#$ -cwd
#$ -l h_rt=1:00:00,h_data=8G

#!/bin/bash


# load modules
. /u/local/Modules/default/init/modules.sh
module load plink

# create directory and file variables
bin_files=../data/euro/euro
phen_file=../data/euro/euro-h2-0.1-train.phen
outdir=../data/euro/gwas/gwas
mkdir $outdir

# run plink quantitative association simulation
plink --bfile $bin_files --assoc --pheno $phen_file --all-pheno --allow-no-sex --out $outdir


# for hoffman time requirement
# echo "sleeping"
# sleep 5m
