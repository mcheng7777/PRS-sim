GWAS PRS pipeline

1. Prepare Files
- Get bed files through plink
- Get phenotype files from phenotype simulation
Scripts in gwas-sim/
- Split phenotype file into train and validation
	train-val.sh
- For blup genetic effect files, make sure it is in the same folder as the phenotypes
	train-val.sh
- Gather testing individual ID's
	test.sh

2. GWAS
Scripts in gwas-prs/
- PCA and LD pruning
	pca.sh
- GWAS
	gwas-prs-model.sh

3. PRS on validation to optimize hyperparameters
Scripts in gwas-prs/
- PRS
	prs.sh
- Find optimal pvalues
	run-best-fit.sh

4. PRS on testing population
Scripts in gwas-prs/
- PRS on test
	prs-test.sh
- Find Correlation between original and predicted phenotype
	corr-test.sh
- Combine correlation files
	combine-test.sh
- Combine populations' correlation files into one file
	combine-full.sh

5. Analysis
Scripts in gwas-analysis/
- Compare Training Population PRS accuracy
	train-comparison.R
- Assess Bias in PRS
	bias.sh
	combine-full.sh
	bias-comparison.R
- Compare Genetic Effect and Simulated Phenotype PRS
	r2-comparison.R
- Compare Genetic Effect and Simulated Phenotype GWAS significance
	blup-sim-sig.R
