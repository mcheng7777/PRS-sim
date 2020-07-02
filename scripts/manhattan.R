#!/u/local/apps/R/3.5.0/gcc-6.3.0_MKL-2017/bin/Rscript
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
dim(df)
# remove rows with NA p-values
df <- df[which(is.na(df$P)==FALSE),]
dim(df)

# save png of manhattan plot
png(file=paste(args[2],".png",sep=""))

manhattan(df)

dev.off()


