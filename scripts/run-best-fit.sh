
#!/u/bin/bash


# load modules
. /u/local/Modules/default/init/modules.sh

module load R/3.5.1

train_phen="/u/home/m/mikechen/project-sriram/PRS-sim/data/sim/pheno-test/sim-h2-4-scaled-train.phen"
val_phen="/u/home/m/mikechen/project-sriram/PRS-sim/data/sim/pheno-test/sim-h2-4-scaled-val.phen"
herit="h2-0.4"
prs_dir="/u/home/m/mikechen/project-sriram/PRS-sim/data/sim/prs/"
pca_file="/u/home/m/mikechen/project-sriram/PRS-sim/data/sim/pca/h2-0.4-pruned-pca.eigenvec"

echo "generating training plots"
# plot training prs
Rscript best-fit-prs.R ${herit}-train $train_phen $pca_file $prs_dir 

echo "generating validation plots"
# plot test prs
Rscript best-fit-prs.R ${herit}-val $val_phen $pca_file $prs_dir


