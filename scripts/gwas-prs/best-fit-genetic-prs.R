# #!/u/local/apps/R/3.5.1/gcc-4.9.3_MKL-2018/bin/R

library(stringr)
args = commandArgs(trailingOnly = TRUE)
# 1 argument - desired directory
print(args)

if (length(args)!=4) {
  stop("4 arguments must be supplied: h2-0.P1 /abspath/to/pca.eigenvec /abspath/to/prs/directory outfile", call.=FALSE)
}


setwd(args[3])
p.threshold <- c(0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0)
outname = paste0(args[1],".")
# Obtain phenotype from prs file with arbitrary p-value thresh (all reference phenotypes are the same)
phenotype <- read.table(paste0("genetic-prs/",outname,0.05,"-val.profile"), header=F)
phenotype <- phenotype[,c(1,2)]
colnames(phenotype) <- c("FID","Phen")

# Read in the PCs
pcs <- read.table(args[2], header=T)
# pcs <- pcs[which(pcs[,1]%in%phenotype[,1]),]
# colnames(pcs) <- c("FID", "IID", paste0("PC",1:5))


# no covariates
# Read in the covariates (here, it is sex)
# covariate <- read.table("EUR.covariate", header=T)

# Now merge the files
pheno <- merge(phenotype, pcs, by=c("FID"))
pheno <- pheno[,c(1,3,2,4:ncol(pheno))]
# We can then calculate the null model (model with PRS) using a linear regression
# (as height is quantitative)
null.model <- lm(Phen~., data=pheno[,!colnames(pheno)%in%c("FID","IID")])
# And the R2 of the null model is
null.r2 <- summary(null.model)$r.squared
prs.result <- NULL
for(i in p.threshold){
  # Go through each p-value threshold
  prs <- read.table(paste0("genetic-prs/",outname,i,"-val.profile"), header=F)
  prs <- prs[,c(1,3)]
  colnames(prs) <- c("FID", "SCORE")
  # Merge the prs with the phenotype matrix
  # We only want the FID, IID and PRS from the PRS file, therefore we only select the
  # relevant columns
  pheno.prs <- merge(pheno, prs[,c("FID", "SCORE")], by=c("FID"))
  # Now perform a linear regression on Height with PRS and the covariates
  # ignoring the FID and IID from our model
  model <- lm(Phen~., data=pheno.prs[,!colnames(pheno.prs)%in%c("FID","IID")])
  # model R2 is obtained as
  model.r2 <- summary(model)$r.squared
  # R2 of PRS is simply calculated as the model R2 minus the null R2
  prs.r2 <- model.r2-null.r2
  # We can also obtain the coeffcient and p-value of association of PRS as follow
  prs.coef <- summary(model)$coeff["SCORE",]
  prs.beta <- as.numeric(prs.coef[1])
  prs.se <- as.numeric(prs.coef[2])
  prs.p <- as.numeric(prs.coef[4])
  # We can then store the results
  prs.result <- rbind(prs.result, data.frame(Threshold=i, R2=prs.r2, P=prs.p, BETA=prs.beta,SE=prs.se))
}
# Best result is:
maxthresh <- prs.result[which.max(prs.result$R2),]
h2 <- str_split(outname,"-")[[1]][3]
r <- str_sub(str_split(outname,"-")[[1]][5],1,-2)
write(paste0(h2,"\t",r,"\t",maxthresh$Threshold,"\t",maxthresh$R2),file=args[4],append=T)
