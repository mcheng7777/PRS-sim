#!/bin/bash
#$ -N job-hapgen
#$ -cwd
#$ -l h_rt=04:00:00,h_data=32G
#$ -j y

. /u/local/Modules/default/init/modules.sh
module load plink
module load vcftools

if [ $# -ne 2 ]
then
	echo "Usage: ./hapgen-sim.sh [pop] [rate]"
	exit 1
fi

hapgen2="../../bin/hapgen2"
gtool="../../bin/gtool"
pop=$1
rate=$2
out="../../data/hapgen/${pop}"
bfile="../../data/bfile/${pop}"
vcf="../../data/vcf/${pop}"

echo "position COMBINED_rate(cM/Mb) Genetic_Map(cM)" > ${out}.map
cat ${vcf}.recode.vcf | \
	cut -f 2 | \
	tail -n +254 | \
	awk -v rate=$rate '{print $1" "rate" "$1 / 1000000 * rate}'>> ${out}.map

vcftools --vcf ${vcf}.recode.vcf --IMPUTE --out ${out}

$hapgen2 \
	-m ${out}.map \
	-l ${out}.impute.legend \
	-h ${out}.impute.hap \
	-dl 10177 1 1.5 2.5 \
	-o ${out}.out \
	-n 5000 0

$gtool -G --g ${out}.out.controls.gen --s ${out}.out.controls.sample --ped ${out}.ped --map ${out}.map
plink --file ${out} --make-bed -out ${bfile}-temp

cut -f 2 ${bfile}-temp.bim | sort | uniq -d > ${bfile}.dups
plink --bfile ${bfile}-temp --exclude ${bfile}.dups --make-bed --out ${bfile}
rm ${bfile}-temp*

sed -i "s/id/${pop}/g" ${bfile}.fam
mv ${bfile}.bim ${bfile}.old.bim
awk '{$1 = 1; print;}' ${bfile}.old.bim > ${bfile}.bim
