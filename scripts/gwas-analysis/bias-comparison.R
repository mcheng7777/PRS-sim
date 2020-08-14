# version R/3.5.1
library(dplyr)
library(ggplot2)

# Compare Biases of Validation PRS scores with true phenotype
# Things to manipulate: Validation Population, training populations, ggplot titles, axes limits, file save path

# validation population
valpop <- "eurval"
dir <- paste0("../../data/val/",valpop,"/bias/")


## read bias file
df <- read.table(paste0(dir,valpop,"-bias-gwas.txt"),header=F)
colnames(df) <- c("heritability","replica","diff","train","test")

# plot heritability boxplots
df$heritability <- df[,1]/10

# specify order and inclusion of training population for plotting
df$train <- factor(df$train, levels = c("afr","eur","eas","eurafr","eureas","afreas"))
df <- df[order(df$train),]

# plot mean difference
ggplot(df,aes(x=heritability,y=diff,group=interaction(heritability,train),color=train))+
  labs(title=paste0("GWAS European Validation Bias (5000 N,600000 M)"))+ #, subtitle=paste0("0.2 African, 0.8 European"))+
  geom_boxplot(outlier.size=0.5)+
  expand_limits(x=c(0,1),y=c(0,1))+
  scale_color_discrete(name="train")+
  # scale_x_continuous(breaks=c(0:10)/10)+
  # scale_y_continuous(breaks=c(0:10)/10)+
  geom_abline(intercept=0,slope=0)+
  geom_smooth(size=0.5, aes(group=train), se=F)+
  theme(#panel.grid.minor = element_blank(),
        plot.title=element_text(size=15),
        plot.subtitle=element_text(size=12))
ggsave(paste0(dir,valpop, "-raw-meandiff-comparison.png"), height=7, width=7)

