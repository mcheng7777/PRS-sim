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
library(ggplot2)

# read in 
df <- read.table(args[1],header=TRUE)
# df <- read.table("/u/home/m/mikechen/project-sriram/PRS-sim/data/euro/gwas/gwas.P1.qassoc",header=TRUE)
dim(df)
# remove rows with NA p-values
df <- df[which(is.na(df$P)==FALSE),]
dim(df)

# add pseudo count to p-values of 0. Replace them with next mininimum value
pseudo<- min(df$P[which(df$P>0)])
df_no_zero <- df[which(df$P!=0),]
df_0_replaced <- df[which(df$P==0),"P"] <- pseudo


print("generating plot")
# save png of manhattan plot

# png(file="/u/home/m/mikechen/project-sriram/PRS-sim/manhattans/P1_man_plot_annoPval.png", 
#     res=300,
#     width=10,
#     height=10,
#     units='in')

png(file=paste(args[2],".manplot.png",sep=""))

manhattan(df)

dev.off()

png(file=paste(args[2],".qqplot.png",sep=""))
# qq(df_no_zero$P)
# dev.off()
# 
# exp_p <- c(1:length(df_no_zero$P))/length(df_no_zero$P)
# obs_p <- sort(df_no_zero$P)
# data <- data.frame(pval = exp_p, exp = exp_p, obs = obs_p)
# 
# png(file=paste(args[2],".qqplot2.png",sep=""))
# p <- ggplot(data = data, aes(x=exp)) +
#   geom_point(y=exp,color="black") +
#   geom_point(y=obs, color="red")
# p + geom_point()
# dev.off()

