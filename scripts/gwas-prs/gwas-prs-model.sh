
#$ -N job-gwas-sim
#$ -cwd
#$ -l h_rt=24:00:00,h_data=16G,highp
# #$ -pe shared 4
#$ -t 1-100:1

#!/bin/bash

# load modules
. /u/local/Modules/default/init/modules.sh
module load plink

# SGE_TASK_ID=100
# create directory and file variables
pop=$1
effect=$2
bin_files="../data/train/${pop}/pheno/${pop}"
if [ ${effect} == "genetic" ]
then
	outdir="../data/train/${pop}/genetic-gwas"
else
	outdir="../data/train/${pop}/gwas"
fi

pca_out="../data/train/${pop}/pca"

r=$(( SGE_TASK_ID ))
for h in {0..9}
do
	herit="h2-${h}"
	if [ ${effect} == "genetic" ]
	then
		phen_file="../data/train/${pop}/pheno/${pop}-${herit}-genetic-train.phen"
	else
		phen_file="../data/train/${pop}/pheno/${pop}-${herit}-train.phen"
	fi
	# run plink quantitative association simulation
	plink \
		--bfile $bin_files \
		--memory 15000 \
		--linear 'hide-covar' \
		--pheno $phen_file --mpheno ${r} --allow-no-sex \
		--covar ${pca_out}/${pop}-pruned-pca.eigenvec --covar-name PC1, PC2, PC3, PC4, PC5 \
		--out ${outdir}/${pop}-${herit}.P${r}
done

# for hoffman time requirement
echo "sleeping"
sleep 5m
