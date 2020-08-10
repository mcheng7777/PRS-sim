#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: ./combine-corr.sh [val pop]"
	exit 1
fi

pop=$1

dir="../../data/val/${pop}/corr"
out="/u/project/sriram/dtang200/corr"
cat ${dir}/*.txt > ${out}/${pop}-grm.txt
