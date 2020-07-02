#!/u/local/apps/R/3.5.0/gcc-6.3.0_MKL-2017/bin/Rscript
args = commandArgs(trailingOnly=TRUE)

if (length(args)!=2) {
  stop("2 arguments must be supplied (input file).n", call.=FALSE)
}

setwd(getwd())
ifelse(is.element("qqman",installed.packages()[,1]),"qqman installed",install.packages("qqman"))
library(qqman)

df <- read.table(args[1],header=TRUE)
dim(df)
df <- df[which(is.na(df$P)==FALSE),]
dim(df)
png(file=paste(args[2],".png",sep=""))

manhattan(df)

dev.off()


