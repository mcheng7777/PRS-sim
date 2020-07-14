#!/bin/bash

pop=$1
gblup="../data/${pop}/blup/${pop}"

for h2 in {0..9}
do
	echo "extracting h2 ${h2}"

	# output file 
	out=${gblup}-train-gen-h2-${h2}.indi.blp
	if [ -f $out ]; then rm $out; fi

	for r in {1..100}
	do
		# get the column of genetic effects
		awk '{print $1"\t"$4}' ${gblup}-h2-${h2}-r-${r}.indi.blp > col

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
done
