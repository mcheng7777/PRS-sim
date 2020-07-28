library(ggplot2)
library(dplyr)
table1 <- read.table(file = "./eur-cross-grm-corr.txt", header=F)
table1 %>% 
    mutate(h2 = V1 * 0.1) %>% 
	ggplot(aes(h2, V3)) +
	geom_smooth() +
	geom_boxplot(aes(group = h2)) +
	geom_abline(intercept = 0, slope = 1) +
	labs(title = "European Training (5000 N, 600000 M)",
		 x = "Heritability",
		 y = "R squared") +
	ylim(c(0, 1))
ggsave("./eas-hapgen-corr.png")
