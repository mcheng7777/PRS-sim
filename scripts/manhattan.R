#!/u/local/apps/R/3.5.1/gcc-4.9.3_MKL-2018/bin/R
args = commandArgs(trailingOnly=TRUE)

# 2 arguments supplied
# args[1] - absolute path of .qassoc file
# args[2] - absolute path of output directory
if (length(args)!=2) {
  stop("2 arguments must be supplied (input file).n", call.=FALSE)
}

setwd(getwd())
# install qqman if haven't already
ifelse(is.element("qqman",installed.packages()[,1]),"qqman installed",install.packages("qqman"))
library(qqman)

# read in 
df <- read.table(args[1],header=TRUE)
df <- read.table("/private/var/folders/3h/cqh2f25511j9z37brssm9jgc0000gn/T/
                 a24df7af-b929-471a-b3d7-7c09ab0121b0/u/home/m/mikechen/project-sriram/
                 PRS-sim/data/euro/gwas/gwas.P1.qassoc",header=TRUE)
dim(df)
# remove rows with NA p-values
df <- df[which(is.na(df$P)==FALSE),]
dim(df)

print("generating plot")
# save png of manhattan plot
png(file=paste(args[2],".png",sep=""))

png(file="/private/var/folders/3h/cqh2f25511j9z37brssm9jgc0000gn/T/a24df7af-b929-471a-b3d7-7c09ab0121b0/u/home/m/mikechen/project-sriram/PRS-sim/manhattans/P1_man_plot_annoPval.png", 
    res=10,
    width=10,
    height=10,
    units='in')
manhattan(df, annotatePval =  0.00001)

dev.off()


