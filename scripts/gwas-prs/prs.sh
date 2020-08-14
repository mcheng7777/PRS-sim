#$ -N job-prs-sim
#$ -l h_rt=4:00:00,h_data=16G
#$ -hold_jid job-gwas-sim
#$ -t 1-100:1
#$ -cwd

#!/bin/bash
# Usage: prs.sh [population] [original or genetic]
# Run prs on validation individuals with range of p-value thresholds


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
pop=$1
effect=$2
r=$(( SGE_TASK_ID ))
# r=65
echo $r

b_files="../../data/train/${pop}/pheno/${pop}"
if [ ${effect} == "genetic" ]
then
	outdir="../../data/train/${pop}/genetic-prs"
else
	outdir="../../data/train/${pop}/prs"
fi
mkdir $outdir

# make p-value rangelist
thresh_array=( "0.05" "0.1" "0.2" "0.3" "0.4" "0.5" "0.6" "0.7" "0.8" "0.9" "1" )
if [ -f ${outdir}/rangelist ]
then
    echo "rangelist: ${outdir}/rangelist"
else
    echo "p value thresholds"
    # pvalue range list for inclusion in PRS
    for i in "${thresh_array[@]}"
    do
        echo ${i}
        echo "${i} 0 ${i}" >> ${outdir}/rangelist
    done
fi

# clump and run PRS
for herit in {0..9}
do
    name=${pop}-h2-${herit}.P${r}
    outname=h2-${herit}-r-${r}
    if [ ${effect} == "genetic" ]
    then
	sum_stats="../../data/train/${pop}/genetic-gwas/${name}.assoc.linear"
	phen_file="../../data/train/${pop}/pheno/${pop}-h2-${herit}-genetic-val.phen"
    else
	sum_stats="../../data/train/${pop}/gwas/${name}.assoc.linear"
	phen_file="../../data/train/${pop}/pheno/${pop}-h2-${herit}-val.phen"
    fi
    out=${outdir}/${pop}-${outname}
    # LD clumping
    if [ -f ${out}.clumped ]
    then
        echo "using ${out}.clumped"
    else
        plink \
            --bfile $b_files \
	    --memory 15000 \
            --clump-p1 1 \
            --clump-r2 0.2 \
            --clump-kb 250 \
            --clump $sum_stats \
            --clump-snp-field SNP \
            --clump-field P \
            --out ${out}
    fi
    # extract SNP ids
    awk 'NR!=1{print $3}' ${out}.clumped > ${out}.valid.snp
    # snp id's and p-values
    awk '{print $1,$4}' $sum_stats > ${out}.SNP.pvalue
    # calculate PRS for all phenotype and split up validation
    plink \
            --bfile $b_files \
	    --memory 15000 \
            --pheno $phen_file --mpheno ${r} --allow-no-sex \
            --score $sum_stats 1 2 3 header \
            --q-score-range ${outdir}/rangelist ${out}.SNP.pvalue \
	    --extract ${out}.valid.snp \
            --out ${out}
    for i in "${thresh_array[@]}"
    do
        echo "sorting ${outname}.${i}.profile"
        awk '{printf $1 "\t" $3 "\t" $4 * $6 * 2 "\n"}' ${out}.${i}.profile > ${out}.${i}-pheno.profile
        grep -F -wf "../../data/train/${pop}/pheno/${pop}-indi-val.txt" ${out}.${i}-pheno.profile > ${out}.${i}-val.profile
	rm ${out}.${i}-pheno.profile
	rm ${out}.${i}.profile
    done
    # remove temp files
    rm ${out}.SNP.pvalue
    rm ${out}.nopred
    rm ${out}.nosex
done

echo "sleeping"
sleep 5m
echo "done"
