#$ -N job-prs-sim
#$ -l h_rt=1:00:00,h_data=8G
#$ -t 1-10:1
#$ -cwd

#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load plink

# tutorial: https://choishingwan.github.io/PRS-Tutorial/plink/
# Generating PRS model
# Requisites:
# phenotype summary statistics (output of gwas-prs-model.sh)
# bed/bim/fam files
# phenotype matrix
# covariate matrix

# SGE_TASK_ID=10
pop=$1
herit=$(( SGE_TASK_ID - 1 ))
echo $herit

b_files="../data/${pop}/pheno/${pop}"

outdir="../data/${pop}/prs/"
mkdir $outdir

# make p-value rangelist
thresh_array=( "0.05" "0.1" "0.2" "0.3" "0.4" "0.5" )
if [ -f ${outdir}rangelist ]
then
    echo "rangelist: ${outdir}rangelist"
else
    echo "p value thresholds"
    # pvalue range list for inclusion in PRS
    for i in "${thresh_array[@]}"
    do
        echo ${i}
        echo "${i} 0 ${i}" >> ${outdir}rangelist
    done
fi

for r in {1..10}
do
    name=h2-${herit}.P${r}
    outname=h2-${herit}-r-${r}
    sum_stats="../data/${pop}/gwas/${name}.assoc.linear"
    phen_file="../data/${pop}/pheno-test/${pop}-h2-${herit}-scaled.phen"
    out=${outdir}${pop}-${outname}
    # step 1 - clumping/LD
    if [ -f ${out}.clumped ]
    then
        echo "using ${out}.clumped"
    else
        plink \
            --bfile $b_files \
            --clump-p1 1 \
            --clump-r2 0.1 \
            --clump-kb 250 \
            --clump $sum_stats \
            --clump-snp-field SNP \
            --clump-field P \
            --out ${out}
    fi
    # extract SNP ids
    awk 'NR!=1{print $3}' ${out}.clumped > ${out}.valid.snp
    # snp id's and p-values
    awk '{print $2,$9}' $sum_stats > ${out}.SNP.pvalue
    # calculate PRS for all phenotype and split up validation
    plink \
            --bfile $b_files \
            --pheno $phen_file --mpheno ${r} --allow-no-sex \
            --score $sum_stats 2 4 7 header \
            --q-score-range ${outdir}rangelist ${out}.SNP.pvalue \
            --extract ${out}.valid.snp \
            --out ${out}
    for i in "${thresh_array[@]}"
    do
        echo "sorting ${name}.${i}.profile"
        awk '{printf $1 "\t" $3 "\t" $4 * $6 * 2 "\n"}' ${out}.${i}.profile > ${out}.${i}-pheno.profile
        grep -F -wf "../data/${pop}/pheno/indi-val.txt" ${out}.${i}-pheno.profile > ${out}.${i}-val.profile
    done
done

#LD prune and PRS
if [ -f ../data/${pop}/pca/h2-${herit}.prune.in ]
then
    echo "using ../data/${pop}/pca/h2-${herit}.prune.in"
else
    plink \
        --bfile $b_files \
        --indep-pairwise 200 50 0.25 \
        --out "../data/${pop}/pca/h2-${herit}"
    plink \
        --bfile $b_files \
        --extract "../data/${pop}/pca/h2-${herit}.prune.in" \
        --pca 5 header \
        --out "../data/${pop}/pca/h2-${herit}-pruned-pca"
fi

echo "sleeping"
sleep 5m

