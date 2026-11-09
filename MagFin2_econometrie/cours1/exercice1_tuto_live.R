## EXERCICE 1 - ANALYSE DONNEES DE GAINS
## 27/01/2026
## auteur : Gabrielle

getwd()

setwd("C:/Users/gabri/OneDrive/Cours/Magistere_annee_2/econometrie/exercices")

## ==== DATA CREATION ====

# Au poker
vect_poker <- c(140, -50, 20, -120, 240)

# A la roulette 
vect_roulette <-  c(-24, -50, 100, -350, 10)

#Créer un vecteur jour
vect_jours <- c("Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi")

## ==== DATA MANIPULATION ====

#Nommer les éléments des vecteurs de gains à la roulette et au poker grâce ce vecteur jour 
names(vect_poker) <- vect_jours
names(vect_roulette) <- vect_jours

vect_poker
vect_roulette

## ==== STATISTICS ====

# Totaux des gains hebdomadaires au poker et à la roulette 
total_poker <- sum(vect_poker)
total_poker

tot_roulette <- sum(vect_roulette) 
tot_roulette

total_sem_1 <- sum(vect_poker,vect_roulette)
total_sem_2 <- vect_poker + vect_roulette
total_sem_3 <- total_poker + tot_roulette

# Tests d'égalité
tot_roulette == total_poker

# Sélectionner des observations d'un vecteurs
vect_roulette[2:5] # du mardi au vendredi
vect_roulette[c(2,5)] # mardi et vendredi

roulette_mar_ven <- vect_roulette[c("Mardi","Mercredi","Jeudi","Vendredi")]

# Calculer moyenne
mean(roulette_mar_ven)

# Calculer l'écart-type
sd(roulette_mar_ven)

?quantile()

quantile(vect_poker, probs = 0.5)

summary(vect_poker)

min(vect_poker)
max(vect_poker)

## ==== SELECTION DES VALEURS POSITIVES ====

poker_positif <- vect_poker[vect_poker > 0]
roulette_positif <- vect_roulette[vect_roulette > 0]

names(poker_positif)
names(roulette_positif)

# Jours uniques avec gains (positifs)
unique(names(c(poker_positif,roulette_positif)))

# Créer une base de données (data.frame)
poker_roulette <- data.frame(jour = names(vect_poker), poker = vect_poker, roulette = vect_roulette)

# Pour visualiser la base de données
View(poker_roulette)

mean(poker_roulette$poker)



