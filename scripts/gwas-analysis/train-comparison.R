# version R/3.5.1
library(dplyr)
library(ggplot2)

# Compare PRS scores of validation population trained with different populations
# Things to manipulate: validation population, training populations, ggplot titles, axes limits, file save path

# validation population
valpop <- "pur"
dir <- paste0("../../data/val/",valpop,"/corr/")
# read correlation file
df <- read.table(paste0(dir,valpop,"-gwas.txt"),header=F)
colnames(df) <- c("heritability","replica","R2","train","test","method")

# plot heritability boxplots
# df$heritability <- df[,1]/10

# adjust order and inclusion of the training populations for plotting purposes
df$train <- factor(df$train, levels = c("afr","eur","eas","eurafr","eureas","afreas","eurafreas","deurafreas")) # for "full / full-scaled"
# df$train <- factor(df$train, levels = c("afr","eur","eas","eurafreas","deurafreas")) # for "downsamp-full / downsamp-full-scaled"

# omit any rows not in the specified levels
# df <- na.omit(df[order(df$train),])

# plot prediction accuracy
lab <- "GWAS Admixed Testing Population (5000 N,600000 M)"
# sub <- ""
sub <- "0.2 African, 0.67 European, 0.13 East Asian"
out <- paste0(dir,"plots/",valpop, "-R2-comparison-gwas.png")
outscaled <- paste0(dir,"plots/",valpop, "-R2-comparison-gwas-scaled.png")

# no downsamples
df %>% 
    filter(train %in% c("afr", "eas", "eur", "eurafr", "eureas", "afreas", "eurafreas")) %>% 
    mutate(h2 = heritability * 0.1) %>% 
    ggplot(aes(h2, R2, color=train)) +
    geom_smooth(se = F) +
    geom_boxplot(aes(group = interaction(h2, train)), lwd=0.2, outlier.size = 0.2) +
    geom_abline(intercept = 0, slope = 1) +
    labs(title = lab,
         subtitle = sub,
         x = "Heritability",
         y= "R squared") +
    ylim(c(0, 1)) +
ggsave(out, height=7, width=7)

# no downsamples, scaled
df %>% 
    filter(train %in% c("afr", "eas", "eur", "eurafr", "eureas", "afreas", "eurafreas")) %>%
    mutate(h2 = heritability * 0.1) %>% 
    ggplot(aes(h2, R2, color=train)) +
    geom_smooth(se = F) +
    geom_boxplot(aes(group = interaction(h2, train)), lwd=0.2, outlier.size = 0.2) +
    geom_abline(intercept = 0, slope = 1) +
    labs(title = lab,
         subtitle = sub,
         x = "Heritability",
         y= "R squared") +
ggsave(outscaled, height=7, width=7)


# Plot downsampled comparison plots
lab <- "Sample Size Effect GWAS Admixed Testing Population (5000 N,600000 M)"
dout <- paste0(dir,"plots/",valpop, "-R2-comparison-downsamp-gwas.png")
doutscaled <- paste0(dir,"plots/",valpop, "-R2-comparison-downsamp-gwas-scaled.png")

# downsample
df %>%   
    filter(train %in% c("afr", "eas", "eur", "eurafreas", "deurafreas")) %>% 
    mutate(h2 = heritability * 0.1) %>% 
    ggplot(aes(h2, R2, color=train)) +
    geom_smooth(se = F) +
    geom_boxplot(aes(group = interaction(h2, train)), lwd=0.2, outlier.size = 0.2) +
    geom_abline(intercept = 0, slope = 1) +
    labs(title = lab,
         subtitle = sub,
         x = "Heritability",
         y= "R squared") +
    ylim(c(0, 1)) +
ggsave(dout, height=7, width=7)

# downsample, scaled
df %>%   
    filter(train %in% c("afr", "eas", "eur", "eurafreas", "deurafreas")) %>%
    mutate(h2 = heritability * 0.1) %>%
    ggplot(aes(h2, R2, color=train)) +
    geom_smooth(se = F) +
    geom_boxplot(aes(group = interaction(h2, train)), lwd=0.2, outlier.size = 0.2) +
    geom_abline(intercept = 0, slope = 1) +
    labs(title = lab,
         subtitle = sub,
         x = "Heritability",
         y= "R squared") +
ggsave(doutscaled, height=7, width=7)



