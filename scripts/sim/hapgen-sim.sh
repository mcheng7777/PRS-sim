#!/bin/bash
#$ -N job-hapgen
#$ -cwd
#$ -l h_rt=04:00:00,h_data=32G
#$ -hold_jid job-filter
#$ -j y

. /u/local/Modules/default/init/modules.sh
module load plink
module load vcftools

if [ $# -ne 2 ]
then
	echo "Usage: ./hapgen-sim.sh [pop] [rate]"
	exit 1
fi

# software tools
hapgen2="../../bin/hapgen2"
gtool="../../bin/gtool"

# vcf files to read from
pop=$1

# recombination rate to model generations since first admixture
rate=$2

# input and output directories
out="../../data/hapgen/${pop}"
bfile="../../data/bfile/${pop}"
vcf="../../data/vcf/${pop}"

# generate *.map file for hapgen2 simulator (constant recombination rate)
echo "position COMBINED_rate(cM/Mb) Genetic_Map(cM)" > ${out}.map
cat ${vcf}.recode.vcf | \
	cut -f 2 | \
	tail -n +254 | \
	awk -v rate=$rate '{print $1" "rate" "$1 / 1000000 * rate}'>> ${out}.map

# generate IMPUTE files for hapgen2 simulator
vcftools --vcf ${vcf}.recode.vcf --IMPUTE --out ${out}

# simulate 5000 haplotypes based on vcf input
$hapgen2 \
	-m ${out}.map \
	-l ${out}.impute.legend \
	-h ${out}.impute.hap \
	-dl 10177 1 1.5 2.5 \
	-o ${out}.out \
	-n 5000 0

# converting to *.ped format
$gtool \
	-G \
	--g ${out}.out.controls.gen \
	--s ${out}.out.controls.sample \
	--ped ${out}.ped \
	--map ${out}.map

# converting to *.bed format
plink --file ${out} --keep-allele-order --make-bed -out ${bfile}-temp

# removing duplicate SNPs
cut -f 2 ${bfile}-temp.bim | sort | uniq -d > ${bfile}.dups
plink \
	--bfile ${bfile}-temp \
	--exclude ${bfile}.dups \
	--keep-allele-order \
	--make-bed \
	--out ${bfile}
rm ${bfile}-temp*

# name individuals in the *.fam file
sed -i "s/id/${pop}/g" ${bfile}.fam
mv ${bfile}.bim ${bfile}.old.bim
awk '{$1 = 1; print;}' ${bfile}.old.bim > ${bfile}.bim
