#$ -N job-prs-plots
#$ -l h_rt=1:00:00,h_data=8G
#$ -t 1-10:1
#$ -cwd

#!/u/bin/bash

 
# load modules
. /u/local/Modules/default/init/modules.sh

module load R/3.5.1

# SGE_TASK_ID=10
pop="sim"
prs_dir="/u/home/m/mikechen/project-sriram/PRS-sim/data/${pop}/prs/"
herit=$(( SGE_TASK_ID - 1))
mkdir ${prs_dir}plots/
echo $herit
for r in {1..10}
do    val_phen="/u/home/m/mikechen/project-sriram/PRS-sim/data/${pop}/pheno-test/${pop}-h2-${herit}-scaled-val.phen"
    name=h2-${herit}.P${r}
    pca_file="/u/home/m/mikechen/project-sriram/PRS-sim/data/${pop}/pca/h2-${herit}-pruned-pca.eigenvec"


    echo "generating validation plots"
    # plot test prs
    Rscript best-fit-prs.R ${name} $pca_file $prs_dir
done

echo "sleeping"
sleep 5m
