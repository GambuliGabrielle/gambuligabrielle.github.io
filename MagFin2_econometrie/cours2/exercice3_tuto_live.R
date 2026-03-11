# Exercice 3, tuto du 03/02

install.packages("MASS")

library(MASS)
library(ggplot2)

## Data
data(hills)

unlist(lapply(hills, class))

## Quel effet de la distance et de l'inclinaison du terrain sur les temps de course ?

model1 <- lm(time ~ dist, data = hills)
model2 <- lm(time ~ climb, data = hills)
model3 <- lm(time ~ dist + climb, data = hills)

summary(model1)
summary(model2)
summary(model3)
