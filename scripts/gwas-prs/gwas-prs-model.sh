
#$ -N job-gwas-sim
#$ -cwd
#$ -l h_rt=24:00:00,h_data=16G,highp
#$ -hold_jid job-pca
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
bin_files="../../data/train/${pop}/pheno/${pop}"
if [ ${effect} == "genetic" ]
then
	outdir="../../data/train/${pop}/genetic-gwas"
else
	outdir="../../data/train/${pop}/gwas"
fi
mkdir $outdir
pca_out="../../data/train/${pop}/pca"

r=$(( SGE_TASK_ID ))
# r=66
for h in {0..9}
do
	herit="h2-${h}"
	if [ ${effect} == "genetic" ]
	then
		phen_file="../../data/train/${pop}/pheno/${pop}-${herit}-genetic-train.phen"
	else
		phen_file="../../data/train/${pop}/pheno/${pop}-${herit}-train.phen"
	fi
	# run plink quantitative association simulation
	plink \
		--bfile $bin_files \
		--memory 15000 \
		--linear 'hide-covar' \
		--pheno $phen_file --mpheno ${r} --allow-no-sex \
		--covar ${pca_out}/${pop}-pruned-pca.eigenvec --covar-name PC1, PC2, PC3, PC4, PC5 \
		--out ${outdir}/${pop}-${herit}.P${r}
	# eliminate unnecessary columns
        mv ${outdir}/${pop}-${herit}.P${r}.assoc.linear ${outdir}/${pop}-${herit}.P${r}.assoc.linear-temp
        awk '{printf $2 "\t" $4 "\t" $7 "\t" $9 "\n"}' ${outdir}/${pop}-${herit}.P${r}.assoc.linear-temp > ${outdir}/${pop}-${herit}.P${r}.assoc.linear
        rm ${outdir}/${pop}-${herit}.P${r}.assoc.linear-temp
done

# for hoffman time requirement
echo "sleeping"
sleep 5m
