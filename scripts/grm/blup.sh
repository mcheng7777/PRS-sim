#$ -N job-blup
#$ -cwd
#$ -t 1-100:1
#$ -l h_rt=02:30:00,h_data=8G
#$ -j y
##$ -hold_jid job-grm
#!/bin/bash


if [ $# -ne 1 ]
then
	echo "Usage: ./blup.sh [pop]"
	exit 1
fi
gcta="../../bin/gcta64"

#SGE_TASK_ID=87
#h2=$(( SGE_TASK_ID - 1))
r=$SGE_TASK_ID
pop=$1

bfile="../../data/train/${pop}/pheno/${pop}" 
grm="../../data/train/${pop}/grm/${pop}"
pheno="../../data/train/${pop}/pheno/${pop}"

for h2 in {0..9}
do
	phenoin="${pheno}-h2-${h2}.phen" 
	out="../../data/train/${pop}/blup/${pop}-h2-${h2}-r-${r}" 

	# variance estimation
	$gcta \
	--reml \
	--reml-pred-rand  \
	--grm ${grm} \
	--mpheno ${r} \
	--pheno ${phenoin} \
	--thread-num 8 \
	--out ${out}

	# blup
	$gcta \
	--bfile ${bfile} \
	--blup-snp ${out}.indi.blp \
	--out ${out}
done

echo "sleeping"
sleep 5m
echo "done"
