# use $/3.5.1
library(dplyr)
library(ggplot2)

# Compare genetic effect and simulated phenotype GWAS significance
# things to mainpulate: data files and pop names, pruned snps file if applicable, causal snplist file if applicable, plot titles and save file paths


df1 <- read.table("../../data/train/eur/gwas/eur-h2-5.P50.assoc.linear", header=T)
pop1 <- "sim"
df2 <- read.table("../../data/train/eur/genetic-gwas/eur-h2-5.P50.assoc.linear", header=T)
pop2 <- "genetic"
valpop <- "eurval"
trainpop <- "eur"

# extract filter out pruned-out SNPS
pruned_in <- read.table("../../data/train/eur/pheno/eur.prune.in", header=F)
df1 <- df1[which(df1$SNP %in% pruned_in[,1]),]
df2 <- df2[which(df2$SNP %in% pruned_in[,1]),]

# add group column
df1$group <- "sim"
df2$group <- "genetic"


# -log10(p)
df1$P <- -log10(df1$P)
df2$P <- -log10(df2$P)

# subset df's based on which df has higher number of threshold hits 
rownames(df1) <- df1$SNP
rownames(df2) <- df2$SNP
valid_rows <- c(nrow(df1[which(df1$P>4),]),nrow(df2[which(df2$P>4),]))
names(valid_rows) <- c("df1","df2")
thresh_df <- names(which.max(valid_rows))
thresh_rows <- rownames(get(thresh_df)[which(get(thresh_df)$P>4),])

# merge subsetted df's
df <- merge(df1[thresh_rows,],df2[thresh_rows,], by=0)

# or plot using entire dataframe
# df <- merge(df1,df2, by=0)

# graph aesthetics
df <- df[,c(2,5,6,10,11)]
colnames(df)[[1]] <- "SNP"
df <- na.omit(df)
# add causal snp column
causal_snps <- read.table("../../data/train/causal.snplist",header=F)
df$causal <- ifelse(df$SNP %in% causal_snps[,1], "yes", "no")
df$causal <- factor(df$causal, levels=c("no","yes"))



# plot logp y vs. x
ggplot(df%>%arrange(causal),aes(x=P.x, y=P.y, color=causal))+
  # expand_limits(x=c(0,15),y=(c(0,15)))+
  geom_point(cex=0.2)+
  labs(title=paste0("EUR BLUP Genetic Effect vs. Simulated Phenotype Beta Significance, pruned"))+
  scale_color_manual(values = c("black","red"))+
  geom_abline(intercept=0,slope=1)+
  geom_hline(yintercept=-log10(0.05/600000),color="red")+
  geom_vline(xintercept=-log10(0.05/600000),color="red")+
  xlab("Simulated Phenotype -log10(p)")+
  ylab("Genetic Effect -log10(p)")+
  theme(plot.title=element_text(size=12))
ggsave(paste0("../../data/val/",valpop,"/corr/plots/",trainpop,"-",pop1,"-",pop2,"-gwas-pval-comparison.png"),width=7,height=7)
# ggsave(paste0("../../data/val/",valpop,"/corr/plots/",trainpop,"-",pop1,"-",pop2,"-gwas-pruned-pval-comparison.png"),width=7,height=7)


# plot separate qqplots
# sim
df1 <- df1[is.na(df1$P)==F,]
df1 <- df1 %>%
  arrange(-P)
df1$expP <- -(log10(c(1:nrow(df1))/ (nrow(df1)+1)))
rownames(df1) <- df1$SNP
df1$causal <- ifelse(df1$SNP %in% causal_snps[,1], "yes", "no")
df1$causal <- factor(df1$causal, levels = c("no","yes"))
# df1$pointsize <- ifelse(df1$causal=="yes",0.2,0.1)
# d1 <- df1[thresh_rows,c("SNP","P","expP")] %>%
#   arrange(-P)
ggplot(df1 %>% arrange(causal),aes(x=expP, y=P, color=causal))+
  # expand_limits(x=c(0,15),y=(c(0,15)))+
  geom_point(cex=0.2)+
  labs(title=paste0("EUR Simulated Phenotype Beta Significance, pruned"))+
  scale_color_manual(values = c("black","red"))+
  geom_abline(intercept=0,slope=1)+
  geom_hline(yintercept=-log10(0.05/600000),color="red")+
  geom_vline(xintercept=-log10(0.05/600000),color="red")+
  xlab("Expected -log10(p)")+
  ylab("Observed -log10(p)")+
  theme(plot.title=element_text(size=12))
# ggsave(paste0("../../data/val/",valpop,"/corr/plots/",trainpop,"-",pop1,"-gwas-qqplot-full.png"),width=7,height=7)
ggsave(paste0("../../data/val/",valpop,"/corr/plots/",trainpop,"-",pop1,"-gwas-pruned-qqplot-full.png"),width=7,height=7)


# genetic
df2 <- df2[is.na(df2$P)==F,]
df2 <- df2 %>%
  arrange(-P)
df2$expP <- -(log10(c(1:nrow(df2))/ (nrow(df2)+1)))
rownames(df2) <- df2$SNP
df2$causal <- ifelse(df2$SNP %in% causal_snps[,1], "yes", "no")
df2$causal <- factor(df2$causal, levels = c("no","yes"))
# df2$pointsize <- ifelse(df2$causal=="yes",2,1)
# d2 <- df2[thresh_rows,c("SNP","P","expP")] %>%
#   arrange(-P)
ggplot(df2%>%arrange(causal),aes(x=expP, y=P, color=causal))+
  # expand_limits(x=c(0,15),y=(c(0,15)))+
  geom_point(cex=0.2)+
  labs(title=paste0("EUR BLUP Genetic Effect Beta Significance, pruned"))+
  scale_color_manual(values = c("black","red"))+
  geom_abline(intercept=0,slope=1)+
  geom_hline(yintercept=-log10(0.05/600000),color="red")+
  geom_vline(xintercept=-log10(0.05/600000),color="red")+
  xlab("Expected -log10(p)")+
  ylab("Observed -log10(p)")+
  theme(plot.title=element_text(size=12))
# ggsave(paste0("../../data/val/",valpop,"/corr/plots/",trainpop,"-",pop2,"-gwas-qqplot-full.png"),width=7,height=7)
ggsave(paste0("../../data/val/",valpop,"/corr/plots/",trainpop,"-",pop2,"-gwas-pruned-qqplot-full.png"),width=7,height=7)


