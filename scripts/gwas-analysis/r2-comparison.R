# version R/3.5.1
library(dplyr)
library(ggplot2)

# Compare genetic effect vs. simulated phenotype prs scores
# Things to change: dir's, pop's, ggplot titles, axes limits, file save path

# define directories and populations
dir1 <- "../../data/val/eurval/corr/"
pop1 <- "eur-sim"
dir2 <- "../../data/val/eurval/corr/"
pop2 <- "eur-genetic"
pop <- "eur"

# t-test and R2 plot
df1 <- read.table(paste0(dir1,pop,"-full-corr-test.txt"), header=F)
colnames(df1) <- c("heritability","replica","R2","train","test","method")
df2 <- read.table(paste0(dir2,pop,"-full-genetic-corr-test.txt"), header=F)
colnames(df2) <- c("heritability","replica","R2","train","test","method")

# merge dataframes
comb <- merge(df1,df2,by=c("heritability","replica"))
comb_herit <- group_by(comb,heritability)%>%
  group_split()

# make dataframe for t-test stats and pval
t <- data.frame(heritability=c(0:9)/10,t_stat=rep(0,10),p_val=rep(0,10))

# run t-test for each heritability level
row_i <- 1
for (h in comb_herit) {
  res <- t.test(h$R2.x,h$R2.y,alternative="two.sided",paired=T)
  t[row_i,] <- c(h[1,1],res$statistic,res$p.value)
  row_i <- row_i+1
}
write.table(t,file=paste0(dir1,"plots/",pop1,"-vs-",pop2,"-paired-t-statistics.txt"),row.names=F,sep='\t',quote=F)

# plot r2-r2 scatter plot
ggplot(comb,aes(x=R2.x,y=R2.y,color=heritability))+
  labs(x="original phenotype", y="BLUP genetic effect phenotype", title="PRS Accuracy Comparison - HapGen Eur SNPS (5000 N, 600000 M)")+
  geom_point()
ggsave(paste0(dir1,"plots/",pop1,"-vs-",pop2,"-R2-scatter.png"),width=7,height=7)

# plot heritability boxplots
df1$group <- pop1
df2$group <- pop2
df <- rbind(df1,df2)
df$heritability <- df[,1]/10
ggplot(df,aes(x=heritability,y=R2,group=interaction(heritability,group),color=group))+
  labs(title=paste0("PRS EUR Testing (5000 N,600000 M)"))+ # subtitle=paste0("sim"," (5000 N) and ", "blup gen effects", " (5000 N) Testing"))+
  geom_boxplot()+
  expand_limits(x=c(0,1),y=c(0,0.3))+
  # scale_x_continuous(breaks=c(0:10)/10)+
  # scale_y_continuous(breaks=c(0:10)/10)+
  geom_abline(intercept=0,slope=1)+
  geom_smooth(size=0.5, aes(group=group), se=F)+
  theme(#panel.grid.minor = element_blank(),
        plot.title=element_text(size=15),
        plot.subtitle=element_text(size=12))
ggsave(paste0(dir1,"plots/",pop1,"-vs-",pop2,"-R2-comparison-scaled.png"), height=7, width=7)

