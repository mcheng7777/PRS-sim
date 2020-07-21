#$ -N job-prs-plots
#$ -l h_rt=1:00:00,h_data=8G
#$ -t 1-10:1
#$ -cwd

#!/u/bin/bash

if [ $# -eq 0 ]
then
	echo "Usage: qsub run-best-fit.sh [population]"
	sleep 5m
	exit 1
fi
 
# load modules
. /u/local/Modules/default/init/modules.sh

module load R/3.5.1

# SGE_TASK_ID=10
pop=$1
working_dir="../data/${pop}"
pca_file="pca/${pop}-pruned-pca.eigenvec"
herit=$(( SGE_TASK_ID - 1))
outfile="genetic-max-pvals-${herit}.txt"
echo $herit
for r in {1..100}
do
	name="${pop}-h2-${herit}-r-${r}"
	echo "generating validation plots"
	# plot test prs
	Rscript best-fit-prs.R ${name} $pca_file $working_dir $outfile
done

echo "sleeping"
sleep 5m
