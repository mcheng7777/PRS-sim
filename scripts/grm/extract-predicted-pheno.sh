#!/bin/bash

pop=$1
prs="../../data/${pop}/prs-train/${pop}"

for h2 in {0..9}
do
	echo "extracting h2 ${h2}"

	# output file 
	out=${prs}-h2-${h2}-combined.phen
	if [ -f $out ]; then rm $out; fi

	for r in {1..100}
	do
		# get the column of genetic effects
		awk '{print $1" "$3}' ${prs}-h2-${h2}-r-${r}-pheno.profile > col

		if [ -f $out ]
		then 
			# merge the data into a single matrix
			join -j 1 $out col > tmp
			mv tmp $out
		else 
			# create the file
			cat col > $out 
		fi
		rm col
	done
	awk '{print $1" "$0}' $out | tail -n +2 > tmp
	mv tmp $out
done
