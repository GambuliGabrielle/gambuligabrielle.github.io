# Exercice 2, tuto 03/02

install.packages("ggplot2") # Si pas encore installé, exécuter cette ligne pour utiliser la fonction ggplot()
library(ggplot2)

# Visualiser données

data(car)

dim(cars)[2]

names(cars)

unlist(lapply(cars, class))

head(cars, 4)

summary(cars)

## Graphiques

hist(cars$speed, breaks = 10)

plot(cars, xlab = "Vitesse (miles par heure)", ylab = "Distance de freinage (pieds)")
title("Relation entre vitesse et distance de freinage de voitures")

ggplot(cars, aes(x = speed, y = dist)) +
  geom_point(color = "dodgerblue", size = 3, alpha = 0.7) + # vous pouvez retoucher la couleur (color), la taille des points (size) et la transparence (alpha)
  labs(
    title = "Speed and Stopping Distances of Cars",
    x = "Speed (mph)",
    y = "Stopping distance (ft)"
  ) +
  theme_minimal() # thème claire

## Linear models

reg1 <- lm(dist ~ speed, data = cars)
reg1

reg2 <- lm(log(dist) ~ speed, data = cars)

reg3 <- lm(dist ~ log(speed), data = cars)

reg4 <- lm(log(dist) ~ log(speed), data = cars)

summary(reg1)

rc_1 <- summary(reg1)$adj.r.squared
rc_2 <- summary(reg2)$adj.r.squared
rc_3 <- summary(reg3)$adj.r.squared
rc_4 <- summary(reg4)$adj.r.squared

# Quel est le meilleur modèle basé sur les R carrés ?

summary(reg1)
summary(reg2)
summary(reg3)
summary(reg4)

plot(cars, xlab = "Vitesse (miles par heure)", ylab = "Distance de freinage (pieds)")
title("Relation entre vitesse et distance de freinage de voitures")
abline(coef = coef(reg2), col = "red")

ggplot(cars, aes(x = speed, y = dist)) +
  geom_point(color = "dodgerblue", size = 3, alpha = 0.6) +
  geom_abline(
    intercept = coef(reg2)[1],
    slope = coef(reg2)[2],
    color = "red", 
    linewidth = 1
  ) +
  labs(
    title = "Speed and Stopping Distances of Cars",
    x = "Speed (mph)",
    y = "Stopping distance (ft)"
  ) +
  theme_minimal()

ggplot(cars, aes(x = speed, y = dist)) +
  geom_point(color = "dodgerblue", size = 3, alpha = 0.6) +
  geom_smooth(
    method = "lm", # méthode = linear model
    se = TRUE, # afficher les erreurs standards
    color = "red",
    fill = "red",
    alpha = 0.2
  ) +
  labs(
    title = "Speed and Stopping Distances of Cars",
    x = "Speed (mph)",
    y = "Stopping distance (ft)"
  ) +
  theme_minimal()
