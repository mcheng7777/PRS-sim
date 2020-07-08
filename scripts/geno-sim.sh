#!/bin/bash

. /u/local/Modules/default/init/modules.sh
module load plink

out="../data/sim/pheno"

echo -e "1000\tSNP\t0.2\t0.8\t0.001\t0" > ${out}/param.sim
plink --simulate-qt ${out}/param.sim --simulate-n 5000 --out ${out}/sim
