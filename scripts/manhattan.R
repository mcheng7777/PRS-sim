#!/u/local/apps/R/3.5.1/gcc-4.9.3_MKL-2018/bin/R
args = commandArgs(trailingOnly=TRUE)

# 2 arguments supplied
# args[1] - absolute/path/of/.qassoc.linear/file
# args[2] - absolute/path/of/output/directory/with/filename
if (length(args)!=2) {
  stop("2 arguments must be supplied (input file).n", call.=FALSE)
}

setwd(getwd())
# install qqman if haven't already
ifelse(is.element("qqman",installed.packages()[,1]),"qqman installed",install.packages("qqman"))
library(qqman)

# read in 
df <- read.table(args[1],header=TRUE)
# df <- read.table("/u/home/m/mikechen/project-sriram/PRS-sim/data/euro/gwas/gwas.P1.qassoc",header=TRUE)
dim(df)
# remove rows with NA p-values
df <- df[which(is.na(df$P)==FALSE),]
dim(df)

# add pseudo count to p-values of 0. Replace them with next mininimum value
pseudo<- min(df$P[which(df$P>0)])
df[which(df$P==0),"P"] <- pseudo


print("generating plot")
# save png of manhattan plot

# png(file="/u/home/m/mikechen/project-sriram/PRS-sim/manhattans/P1_man_plot_annoPval.png", 
#     res=300,
#     width=10,
#     height=10,
#     units='in')

png(file=paste(args[2],".png",sep=""))

manhattan(df)

dev.off()




