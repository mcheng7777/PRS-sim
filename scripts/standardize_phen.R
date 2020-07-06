#!/u/local/apps/R/3.5.1/gcc-4.9.3_MKL-2018/bin/R
ifelse(is.element("dplyr", installed.packages()[,1]), "dplyr installed", install.packages("dplyr"))


library(dplyr)
args = commandArgs(trailingOnly=TRUE)

# 1 argument - desired directory
if (length(args)!=1) {
	stop("1 arguments must be supplied: /abspath/to/directory/", call.=FALSE)
}

setwd(args[1])
# get list of files from desired directory
all_files <- list.files(args[1])
# print(all_files)
# grep desired files
phen_files <- grep("[0-9].phen$", all_files, value=T)
phen_files
# scale each file
for(h in c(1:9)/10){
  p <- grep(paste(h,'.phen','$', sep=""),phen_files,value=T)[1]
  d <- read.table(paste(args[1],p,sep=""),header=F)
  new_d <- mutate_at(d,colnames(d)[3:ncol(d)], funs(scale))
  apply(new_d[,3:12], 2, summary)
  apply(new_d[,3:12], 2, var)
  write.table(new_d, file=paste(args[1],p,".scaled",sep=""), row.names=F, col.names=F, quote=F)
  }
