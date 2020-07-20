#!/bin/bash


if [ $# -ne 1 ]
then
	echo "Usage: ./batch.sh [pop name]"
	exit 1
fi

for h2 in {0..9}
do
	cat ../data/$1/blup/*h2-${h2}-*.hsq | grep "V(G)/Vp" | cut -f2 > h2-${h2}.txt
done
