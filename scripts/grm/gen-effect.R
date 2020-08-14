library("dplyr")
library("ggplot2")

args = commandArgs(trailingOnly=TRUE)

# 1 argument - desired directory
if (length(args)!=1) {
    stop("1 arguments must be supplied: population", call.=FALSE)
}

pop <- args[1]

# file paths
grm.dir <- paste0("../../data/", pop, "/grm/")
blup.dir <- paste0("../../data/", pop, "/blup/")
pheno.dir <- paste0("../../data/", pop, "/pheno/")
prs.dir <- paste0("../../data/", pop, "/prs/")
truth.dir <- paste0("../../data/", pop, "/true-gen/")

df1 <- data.frame()
df2 <- data.frame()

# get genetic effects in training data and true phenotype
for (h2 in c(1, 2, 3, 4, 5, 6, 7, 8, 9)) {
	cat(paste("calculating h2", h2, "\n"))
	pheno <- paste0(truth.dir, pop, "-h2-", h2, "-combined.phen") %>% read.table()
	#snp.gen <- paste0(prs.dir, pop, "-h2-", h2, "-combined.phen") %>% read.table()
	train.gen <- paste0(blup.dir, pop, "-h2-", h2, "-genetic-train.phen") %>% read.table()

	#snp.gen <- snp.gen[,-c(1, 2)] %>% as.matrix()
	train.gen <- train.gen[,-c(1, 2)] %>% as.matrix()
	pheno <- pheno[,-c(1, 2)] %>% as.matrix()

	# calculate correlation
	df1 <- rbind(df1, data.frame(heritability = rep(h2), R2 = diag(cor(train.gen, pheno))^2))
	#df2 <- rbind(df2, data.frame(heritability = rep(h2), R2 = diag(cor(snp.gen, pheno))^2))

}
df1 <- df1 %>% mutate(estimate="BLUP Genetic Effect")
#df2 <- df2 %>% mutate(estimate="BLUP SNP")
df <- rbind(df1, df2)

print(df)

df %>% 
	mutate(h2 = heritability * 0.1) %>% 
	ggplot(aes(h2, R2)) +
	geom_smooth() +
	geom_boxplot(aes(group = h2)) +
	labs(title = "BLUP Effects vs True Genetic Effects (5000 N, 3000 M)",
		x = "Heritability",
		y= "R squared") +
	ylim(c(0, 1))
ggsave("./genetic-plink.png")


