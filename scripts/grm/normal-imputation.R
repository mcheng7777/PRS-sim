library("dplyr")
library("ggplot2")

args = commandArgs(trailingOnly=TRUE)

# 1 argument - desired directory
if (length(args)!=1) {
    stop("1 arguments must be supplied: population", call.=FALSE)
}

pop <- args[1]

ReadGRMBin=function(prefix, AllN=F, size=4){
    sum_i=function(i){
        return(sum(1:i))
    }
    BinFileName=paste(prefix,".grm.bin",sep="")
    NFileName=paste(prefix,".grm.N.bin",sep="")
    IDFileName=paste(prefix,".grm.id",sep="")
    
    id = read.table(IDFileName) 
    n=dim(id)[1]
    
    BinFile=file(BinFileName, "rb");
    grm=readBin(BinFile, n=n*(n+1)/2, what=numeric(0), size=size)
    NFile=file(NFileName, "rb");
    if(AllN==T){
        N=readBin(NFile, n=n*(n+1)/2, what=numeric(0), size=size)
    }
    else { 
        N=readBin(NFile, n=1, what=numeric(0), size=size)
    }
    i=sapply(1:n, sum_i)
	close(NFile)
	close(BinFile)
    return(list(diag=grm[i], off=grm[-i], id=id, N=N))
}

# file paths
grm.dir <- paste0("../../data/", pop, "/grm/")
blup.dir <- paste0("../../data/", pop, "/blup/")
pheno.dir <- paste0("../../data/", pop, "/pheno/")
prs.dir <- paste0("../../data/", pop, "/prs/")

# read in the data
data <- paste0(grm.dir, pop) %>% ReadGRMBin()

# create matrix from the data
grm <- matrix(0, length(data$diag), length(data$diag))
upper.triangle <- which(upper.tri(grm, diag = FALSE), arr.ind=TRUE)
grm[upper.triangle] <- data$off
grm <- t(grm)
grm[upper.triangle] <- data$off
diag(grm) <- data$diag


# find training and validation individuals
train <- paste0(pheno.dir, pop, "-indi-train.txt") %>% read.table()
val <- paste0(pheno.dir, pop, "-indi-val.txt") %>% read.table()

index.train <- which(data$id$V1 %in% train$V1)
index.val <- which(data$id$V1 %in% val$V1)

# get coefficients
cat("computing coefficients\n")
coef <- grm[index.val, index.train] %*% solve(grm[index.train, index.train])
cat("done with coefficients\n")

df <- data.frame()

# get genetic effects in training data and true phenotype
for (h2 in c(0:9)) {
	cat(paste("imputing h2", h2, "\n"))
	pheno <- paste0(prs.dir, pop, "-h2-", h2, "-combined.phen") %>% read.table()
	train.gen <- paste0(blup.dir, pop, "-h2-", h2, "-genetic-train.phen") %>% read.table()

	cat(dim(coef), dim(train.gen), "\n")

	# compute imputed genetic effects
	val.gen <- coef %*% (train.gen[,-c(1, 2)] %>% as.matrix())
	pheno.val <- pheno[,-c(1, 2)] %>% as.matrix()

	# calculate correlation
	df <- rbind(df, data.frame(heritability = rep(h2), R2 = diag(cor(val.gen, pheno.val))^2))
}


df %>% 
	mutate(h2 = heritability * 0.1) %>% 
	ggplot(aes(h2, R2)) +
	geom_smooth() +
	geom_boxplot(aes(group = h2)) +
	labs(title = "BLUP Genetic Prediction vs BLUP SNP Prediction",
		x = "Heritability",
		y= "R squared") +
	ylim(c(0, 1))
ggsave("./mvn-vs-snp.png")

