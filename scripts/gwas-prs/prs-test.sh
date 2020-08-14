#$ -N job-prs-test
#$ -l h_rt=5:00:00,h_data=16G
#$ -t 1-100:1
#$ -hold_jid job-prs-plots
#$ -cwd

#!/bin/bash
# Usage: prs-test.sh [trainging population] [testing population] [original or genetic]
# Run PRS on test set with optimal p-values


. /u/local/Modules/default/init/modules.sh
module load plink

# tutorial: https://choishingwan.github.io/PRS-Tutorial/plink/
# Generating PRS model
# Requisites:
# phenotype summary statistics (output of gwas-prs-model.sh)
# bed/bim/fam files
# phenotype matrix
# covariate matrix

# SGE_TASK_ID=100
# declare variables
trainpop=$1
pop=$2
effect=$3
r=$(( SGE_TASK_ID ))
echo $r

# use val.bed (it's actually the test set)
b_files="../../data/val/${pop}/pheno/${pop}"
if [ $effect == "genetic" ]
then
	train_dir="../../data/train/${trainpop}/genetic-"
	base_dir="../../data/val/${pop}/${trainpop}/genetic-"
	outdir="../../data/val/${pop}/${trainpop}/genetic-prs"
else
	train_dir="../../data/train/${trainpop}/"
	base_dir="../../data/val/${pop}/${trainpop}/"
	outdir="../../data/val/${pop}/${trainpop}/prs"
	mkdir $base_dir
fi
mkdir $outdir

# run prs
for herit in {0..9}
do
	echo "replica: ${r}"
	echo "index: $herit , $r"
	# create optimal pvalue range file
	i=$(awk -v n=$r 'FNR == n {print $3}' ../../data/train/${trainpop}/max-pvals-${herit}.txt)
	echo "${i} 0 ${i}" > ${base_dir}pvals-${r}.txt
	cat ${base_dir}pvals-${r}.txt
	name=${trainpop}-h2-${herit}.P${r}
	outname=h2-${herit}-r-${r}
	# GWAS and SNP clump files
	if [ $effect == "genetic" ]
	then
		sum_stats="../../data/train/${trainpop}/genetic-gwas/${name}.assoc.linear"
		valsnp="../../data/train/${trainpop}/genetic-prs/${trainpop}-${outname}.valid.snp"
	else
		sum_stats="../../data/train/${trainpop}/gwas/${name}.assoc.linear"
		valsnp="../../data/train/${trainpop}/prs/${trainpop}-${outname}.valid.snp"
	fi
	phen_file="../../data/val/${pop}/pheno/${pop}-h2-${herit}.phen"
	out=${outdir}/${pop}-${outname}
	## snp id's and p-values
	awk '{print $1,$4}' $sum_stats > ${out}-test.SNP.pvalue
	# calculate PRS
	plink \
		--bfile $b_files \
		--pheno $phen_file --mpheno ${r} --allow-no-sex \
		--score $sum_stats 1 2 3 header \
		--q-score-range ${base_dir}pvals-${r}.txt ${out}-test.SNP.pvalue \
		--extract $valsnp \
		--out "${out}-test"
	# extract essential information
	echo "sorting ${outname}-test.${i}.profile"
	awk '{printf $1 "\t" $3 "\t" $4 * $6 * 2 "\n"}' ${out}-test.${i}.profile > ${out}-test.${i}-pheno.profile
	grep -F -wf "../../data/val/${pop}/pheno/${pop}-indi-test.txt" ${out}-test.${i}-pheno.profile > ${out}-test.profile
	# remove temp files
	rm ${out}-test.${i}-pheno.profile
	rm ${out}-test.${i}.profile
	rm ${out}-test.SNP.pvalue
        rm ${out}-test.nopred
        rm ${out}-test.nosex
done

echo "sleeping"
sleep 5m

