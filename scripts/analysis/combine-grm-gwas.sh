#!/bin/bash


if [ $# -ne 4 ]
then
	echo "Usage: ./combine-grm-gwas.sh [grm] [gwas] [train] [pop]"
	exit 1
fi

grm=$1
gwas=$2
train=$3
val=$4


awk -v pop=$val '{print $1"\t"$2"\t"$4"\tpop\tgwas"}' $gwas > grm-gwas-${train}-${val}-corr.txt
awk '{print $0"\tgrm"}' $grm >> grm-gwas-${train}-${val}-corr.txt


