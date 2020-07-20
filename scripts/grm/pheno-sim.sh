#$ -N job-pheno-sim
#$ -cwd
#$ -l h_rt=05:00:00,h_data=16G
#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load plink
module load R/3.5.1


if [ $# -ne 2 ]
then
	echo "Usage: ./pheno-sim.sh [pop1] [pop2]"
	exit 1
fi

gcta='../../bin/gcta64'

pop1=$1
pop2=$2

bfile1="../../data/bfile/$pop1"
bfile2="../../data/bfile/$pop2"

if [ $pop1 == $pop2 ]
then 
	pop=$pop1
	out="../../data/${pop}/pheno/${pop}"

	# randomly split into training and validation
	awk '{print $1}' ${bfile1}.fam | sort -R > ${out}-indi-rand.txt
	total=$(cat ${out}-indi-rand.txt | wc -l)
	train=$(( total / 100 * 70 ))
	head -n $train ${out}-indi-rand.txt > ${out}-indi-train.txt
	tail -n +$((train + 1)) ${out}-indi-rand.txt > ${out}-indi-val.txt

	# create separate bfiles for training and validation
	plink --bfile $bfile1 --keep-fam ${out}-indi-train.txt --make-bed --out ${out}-train
	plink --bfile $bfile1 --keep-fam ${out}-indi-val.txt --make-bed --out ${out}-val

else
	pop=${pop1}-${pop2}
	out="../../data/${pop}/pheno/${pop}"

	cp ${bfile1}.bed ${out}-train.bed
	cp ${bfile1}.bim ${out}-train.bim
	cp ${bfile1}.fam ${out}-train.fam


	cp ${bfile2}.bed ${out}-val.bed
	cp ${bfile2}.bim ${out}-val.bim
	cp ${bfile2}.fam ${out}-val.fam
fi

# get causal traits
awk '{print $2}' ${bfile1}.bim | sort -R > ${out}-causal.snplist
numvariants=$(cat ${out}-causal.snplist | wc -l )
numcausal=$(( numvariants * 10 / 10 ))
head -n ${numcausal} ${out}-causal.snplist > temp
mv temp ${out}-causal.snplist

# simulate a quantitative traits at various heritability levels

for h2 in {0..9}
do
	$gcta \
	--bfile ${out}-train \
	--simu-qt \
	--simu-hsq 0.${h2} \
	--simu-rep 100 \
	--simu-causal-loci ${out}-causal.snplist \
	--out ${out}-h2-${h2}-train

	tail -n +2 ${out}-h2-${h2}-train.par | awk '{print $1" "$4}' > ${out}-causal-h2-${h2}.snplist

	$gcta \
	--bfile ${out}-val \
	--simu-qt \
	--simu-hsq 0.${h2} \
	--simu-rep 100 \
	--simu-causal-loci ${out}-causal-h2-${h2}.snplist \
	--out ${out}-h2-${h2}-val
done

# for hoffman time out
echo "sleeping"
sleep 5m
echo "done sleeping"



