#$ -N job-blup
#$ -cwd
#$ -t 1-10:1
#$ -l h_rt=04:00:00,h_data=16G
#!/bin/bash


if [ $# -ne 2 ]
then
	echo "Usage: ./blup.sh [pop1] [pop2]"
	exit 1
fi
gcta="../../bin/gcta64"

#SGE_TASK_ID=10
h2=$(( SGE_TASK_ID - 1))
pop1=$1
pop2=$2

if [ $pop1 == $pop2 ]
then
	pop=$pop1
else
	pop=${pop1}-${pop2}
fi

bfile="../../data/${pop}/pheno/${pop}-train" 
grm="../../data/${pop}/grm/${pop1}"
pheno="../../data/${pop}/pheno/${pop}"


for r in {1..100}
do
	phenoin="${pheno}-h2-${h2}-train.phen" 
	out="../../data/${pop}/blup/${pop}-h2-${h2}-r-${r}" 

	# variance estimation
	$gcta \
	--reml \
	--reml-pred-rand  \
	--grm ${grm} \
	--mpheno ${r} \
	--pheno ${phenoin} \
	--thread-num 4 \
	--out ${out}

	# blup
	$gcta \
	--bfile ${bfile} \
	--blup-snp ${out}.indi.blp \
	--out ${out}
done

echo "sleeping"
sleep 5m
echo "done sleeping"
