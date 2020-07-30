#$ -N job-prs-plots
#$ -l h_rt=00:10:00,h_data=8G
#$ -t 1-10:1
#$ -cwd

#!/u/bin/bash

 
# load modules
. /u/local/Modules/default/init/modules.sh

module load R/3.5.1

# SGE_TASK_ID=10
pop=$1
effect=$2
working_dir="../../data/train/${pop}"
pca_file="pca/${pop}-pruned-pca.eigenvec"
herit=$(( SGE_TASK_ID - 1))
if [ $effect == "genetic" ]
then
	outfile="genetic-max-pvals-${herit}.txt"
else
	outfile="max-pvals-${herit}.txt"
fi
echo $herit
for r in {1..100}
do
	name="${pop}-h2-${herit}-r-${r}"
	echo "generating validation plots"
	# plot test prs
	if [ $effect = "genetic" ]
	then
		Rscript best-fit-genetic-prs.R ${name} $pca_file $working_dir $outfile
	else
		Rscript best-fit-prs.R ${name} $pca_file $working_dir $outfile
	fi
done

echo "sleeping"
sleep 5m
