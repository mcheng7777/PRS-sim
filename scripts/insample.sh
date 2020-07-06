#$ -N grm-h2
#$ -cwd
#$ -t 1-100:1
#$ -l h_rt=00:30:00,h_data=16G
#!/bin/bash

# SGE_TASK_ID=1

pop="euro"
gcta="../bin/gcta64"
bfile="../data/${pop}/pheno/${pop}" 
grm="../data/${pop}/grm/${pop}"
phenonum=$SGE_TASK_ID

if [ -f ${grm}.grm.bin ]; then
    echo "using genetic sim matrix file: " ${grm}.grm.bin
else 
	echo "creating genetic sim matrix"
	$gcta --bfile ${bfile} --make-grm --out ${grm}
fi

for h2 in {1..9}
do
	phenoin="${bfile}-h2-${h2}.phen" 
	out="../data/euro/BLUP/${pop}-h2-${h2}-replication-${phenonum}" 

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
