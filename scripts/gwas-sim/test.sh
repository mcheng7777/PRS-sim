#!/bin/bash
# Usage: test.sh [population]
# Gather the IDs of testing individuals

pop=$1
testdir="../../data/val/${pop}/pheno/${pop}"
awk '{print $1}' ${testdir}.fam > ${testdir}-indi-test.txt
