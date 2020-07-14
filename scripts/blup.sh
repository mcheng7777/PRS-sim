#$ -N job-blup
#$ -cwd
#$ -t 1-10:1
#$ -l h_rt=01:00:00,h_data=16G
#!/bin/bash

h2=$(( SGE_TASK_ID - 1))
pop=$1
gcta="../bin/gcta64"
bfile="../data/${pop}/pheno/${pop}" 
grm="../data/${pop}/grm/${pop}"

for r in {1..100}
do
	phenonum=$r
	phenoin="${bfile}-h2-${h2}-scaled-train.phen" 
	out="../data/${pop}/blup/${pop}-h2-${h2}-r-${phenonum}" 

	# variance estimation
	$gcta \
	--reml \
	--reml-pred-rand  \
	--grm ${grm} \
	--mpheno ${phenonum} \
	--pheno ${phenoin} \
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
