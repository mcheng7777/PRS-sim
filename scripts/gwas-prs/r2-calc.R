#!/u/local/apps/R/3.5.1/gcc-4.9.3_MKL-2018/bin/R

args = commandArgs(trailingOnly=TRUE)

# 1 argument - desired directory
if (length(args)!=1) {
	stop("1 arguments must be supplied: /abspath/to/file", call.=FALSE)
}

file <- args[1]
df <- read.table(file, header=T)

cat(cor(df[[2]], df[[3]])^2)
