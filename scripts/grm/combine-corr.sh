#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: ./corr.sh [train pop] [val pop]"
	exit 1
fi

pop1=$1
pop2=$2
pop=${pop1}-${pop2}

cat ${pop}-grm-corr-* >> ${pop}-grm-corr.txt
