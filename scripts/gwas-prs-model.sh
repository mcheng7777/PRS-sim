
#$ -N job-gwas-sim
#$ -cwd
#$ -l h_rt=30:00:00,h_data=16G,highp

#!/bin/bash

# load modules
. /u/local/Modules/default/init/modules.sh
module load plink

# create directory and file variables
pop=$1
bin_files="../data/${pop}/pheno/${pop}"
outdir="../data/${pop}/gwas/"
pca_out="../data/${pop}/pca/"

if [ -f ${pca_out}${pop}.prune.in ]
then
    echo "using ${pca_out}${pop}.prune.in"
else
	#LD prune and PCA
	plink \
		--bfile $bin_files \
		--indep-pairwise 200 50 0.25 \
		--out ${pca_out}${pop}
	plink \
		--bfile $bin_files \
		--extract ${pca_out}${pop}.prune.in \
		--pca 5 header \
		--out ${pca_out}${pop}-pruned-pca
fi
for h in {0..9}
do
    herit="h2-${h}"
    phen_file="../data/${pop}/pheno/${pop}-${herit}-scaled-train.phen"
	# run plink quantitative association simulation
	plink \
		--bfile $bin_files \
		--linear 'hide-covar' \
		--pheno $phen_file --all-pheno --allow-no-sex \
		--covar ${pca_out}${pop}-pruned-pca.eigenvec --covar-name PC1, PC2, PC3, PC4, PC5 \
		--out ${outdir}${herit}
done

# for hoffman time requirement
echo "sleeping"
sleep 5m
