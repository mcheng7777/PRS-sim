#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: ./corr.sh [train pop] [val pop]"
	exit 1
fi

pop1=$1
pop2=$2
pop=${pop1}-${pop2}

dir="../../data/val/${pop}/corr"
cat ${dir}/${pop}-grm-* >> ${dir}/${pop}-grm.txt
