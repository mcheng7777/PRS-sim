#$ -N grm-h2-07
#$ -cwd
#$ -t 1-100:1
#$ -l h_rt=00:05:00,h_data=16G
#!/bin/bash


SGE_TASK_ID=1

pop="euro"
h2="0.7"

gcta="../bin/gcta64"
bfile="../data/euro/pheno/euro" 
phenoin="${bfile}-h2-${h2}.phen" 
phenonum=${SGE_TASK_ID}
grm="../data/euro/grm/$pop"
out="../data/euro/BLUP/$pop-h2-${h2}-replication-${phenonum}" 

if [ -f ${grm}.grm.bin ]; then
    echo "using genetic sim matrix file: " ${grm}.grm.bin
else 
	echo "creating genetic sim matrix"
	$gcta --bfile ${bfile} --make-grm --out ${grm}
fi

# variance estimation
$gcta --reml --reml-pred-rand  --grm ${grm} --mpheno ${phenonum} --pheno $phenoin  --out ${out}

# blup
$gcta --bfile ${bfile} --blup-snp ${out}.indi.blp --out ${out}

echo "sleeping"
sleep 5m
echo "done sleeping"
