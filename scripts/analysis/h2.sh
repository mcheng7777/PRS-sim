#!/bin/bash


if [ $# -ne 1 ]
then
	echo "Usage: ./h2.sh [pop name]"
	exit 1
fi

for h2 in {0..9}
do
	cat ../../data/train/$1/blup/*h2-${h2}-*.hsq | 
	grep "V(G)/Vp" |
	cut -f2 |
	awk -v h2=$h2 -v pop=$1 '{print h2"\t"$0"\t"pop}' \
		> ${1}-h2-${h2}.txt
done
cat ${1}-h2-*.txt > ${1}-h2.txt
rm ${1}-h2-*.txt
