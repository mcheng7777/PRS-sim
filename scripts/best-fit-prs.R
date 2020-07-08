#!/u/local/apps/R/3.5.1/gcc-4.9.3_MKL-2018/bin/R
<<<<<<< HEAD
args = commandArgs(trailingOnly = TRUE)

# 1 argument - desired directory
if (length(args)!=2) {
  stop("2 arguments must be supplied: h2-0.1-train /abspath/to/phenotype/file", call.=FALSE)
}
=======
# args = commandArgs(trailingOnly = TRUE)

# # 1 argument - desired directory
# if (length(args)!=1) {
#   stop("1 arguments must be supplied: /abspath/to/directory/", call.=FALSE)
# }
>>>>>>> a0d71329980097c4168c31a5d32902a8997905e0


setwd("/u/home/m/mikechen/project-sriram/PRS-sim/data/euro/prs")
p.threshold <- c(0.001,0.05,0.1,0.2,0.3,0.4,0.5)
<<<<<<< HEAD
outname = paste0(args[1],".")
phen_file <- args[2]
# Read in the phenotype file 
phenotype <- read.table(phen_file, header=F)
phenotype <- phenotype[,c(1:3)]
colnames(phenotype) <- c("FID","IID","Phen")

# Read in the PCs
pcs <- read.table("/u/home/m/mikechen/project-sriram/PRS-sim/data/euro/pca/h2-0.1-pruned-pca.eigenvec", header=F)
colnames(pcs) <- c("FID", "IID", paste0("PC",1:5))
=======
outname <- "h2-0.1."
# Read in the phenotype file 
phenotype <- read.table("/u/home/m/mikechen/project-sriram/PRS-sim/data/euro/pheno-test/euro-h2-1-scaled-train.phen", header=F)
phenotype <- phenotype[,c(1:3)]
colnames(phenotype) <- c("FID","IID","Phen")
# Read in the PCs
pcs <- read.table("/u/home/m/mikechen/project-sriram/PRS-sim/data/euro/pca/h2-0.1-pca.eigenvec", header=T)
>>>>>>> a0d71329980097c4168c31a5d32902a8997905e0

# no covariates
# Read in the covariates (here, it is sex)
# covariate <- read.table("EUR.covariate", header=T)

# Now merge the files
pheno <- merge(phenotype, pcs, by=c("FID","IID"))
# We can then calculate the null model (model with PRS) using a linear regression 
# (as height is quantitative)
null.model <- lm(Phen~., data=pheno[,!colnames(pheno)%in%c("FID","IID")])
# And the R2 of the null model is 
null.r2 <- summary(null.model)$r.squared
prs.result <- NULL
for(i in p.threshold){
  # Go through each p-value threshold
  prs <- read.table(paste0(outname,i,".profile"), header=T)
  # Merge the prs with the phenotype matrix
  # We only want the FID, IID and PRS from the PRS file, therefore we only select the 
  # relevant columns
  pheno.prs <- merge(pheno, prs[,c("FID","IID", "SCORE")], by=c("FID", "IID"))
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
prs.result[which.max(prs.result$R2),]
<<<<<<< HEAD
maxthresh <- prs.result[which.max(prs.result$R2),]$Threshold[1]
=======

>>>>>>> a0d71329980097c4168c31a5d32902a8997905e0

# Plot PRS

library(ggplot2)
# generate a pretty format for p-value output
prs.result$print.p <- round(prs.result$P, digits = 3)
prs.result$print.p[!is.na(prs.result$print.p) &
                     prs.result$print.p == 0] <-
  format(prs.result$P[!is.na(prs.result$print.p) &
                        prs.result$print.p == 0], digits = 2)
prs.result$print.p <- sub("e", "*x*10^", prs.result$print.p)
# Initialize ggplot, requiring the threshold as the x-axis (use factor so that it is uniformly distributed)
ggplot(data = prs.result, aes(x = factor(Threshold), y = R2)) +
  # Specify that we want to print p-value on top of the bars
  geom_text(
    aes(label = paste(print.p)),
    vjust = -1.5,
    hjust = 0,
    angle = 45,
    cex = 4,
    parse = T
  )  +
  # Specify the range of the plot, *1.25 to provide enough space for the p-values
  scale_y_continuous(limits = c(0, max(prs.result$R2) * 1.25)) +
  # Specify the axis labels
  xlab(expression(italic(P) - value ~ threshold ~ (italic(P)[T]))) +
  ylab(expression(paste("PRS model fit:  ", R ^ 2))) +
  # Draw a bar plot
  geom_bar(aes(fill = -log10(P)), stat = "identity") +
  # Specify the colors
  scale_fill_gradient2(
    low = "dodgerblue",
    high = "firebrick",
    mid = "dodgerblue",
    midpoint = 1e-4,
    name = bquote(atop(-log[10] ~ model, italic(P) - value),)
  ) +
  # Some beautification of the plot
  theme_classic() + theme(
    axis.title = element_text(face = "bold", size = 18),
    axis.text = element_text(size = 14),
    legend.title = element_text(face = "bold", size =
                                  18),
    legend.text = element_text(size = 14),
    axis.text.x = element_text(angle = 45, hjust =
                                 1)
  )
# save the plot
<<<<<<< HEAD
ggsave(paste0(outname,"png"), height = 7, width = 7)


# Read in the files
prs <- read.table(paste0(outname,maxthresh,".profile"), header=T)
# Merge the files
dat <- merge(prs, phenotype)
=======
ggsave(paste0(outname,".png"), height = 7, width = 7)
q() # exit R


# Read in the files
prs <- read.table(paste0(outname,"0.4.profile"), header=T)
phen_val <- read.table("/u/home/m/mikechen/project-sriram/PRS-sim/data/euro/pheno-test/euro-h2-1-scaled-val.phen", header=F)
phen_val <- phen_val[,c(1:3)]
colnames(phen_val) <- c("FID","IID","Phen")
# Merge the files
dat <- merge(prs, phenotype)
dat_val <- merge(prs, phen_val)
>>>>>>> a0d71329980097c4168c31a5d32902a8997905e0
# Start plotting
ggplot(dat, aes(x=SCORE, y=Phen))+
  geom_point()+
  theme_classic()+
  labs(x="Polygenic Score", y="Phen")
<<<<<<< HEAD
ggsave(paste0(outname,maxthresh,"-PRS-plot.png"), height = 7, width = 7)
=======
ggsave(paste0(outname,"0.4-PRS-plot.png"), height = 7, width = 7)

ggplot(dat_val, aes(x=SCORE, y=Phen))+
  geom_point()+
  theme_classic()+
  labs(x="Polygenic Score", y="Phen")
ggsave(paste0(outname,"0.4-PRS-plot-val.png"), height = 7, width = 7)
>>>>>>> a0d71329980097c4168c31a5d32902a8997905e0
