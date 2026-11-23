# Tuto du 24/02

library(dplyr)
library(lmtest)
library(sandwich)

# Données

APT <- read.csv("C:/Users/gabri/OneDrive/Documents/Teaching/TD_MagFin2/data/Microsoft.csv", header = T, dec = "," , sep = ";")

# Description des données

dim(APT)

summary(APT)

# Transformation des données
APT <- APT %>% 
  mutate(Date = as.Date(Date, format = "%d/%m/%Y"),
         Micro.L1 = lag(Microsoft,1)
         )

# Calculer le rendement de l'action Microsoft
APT <- APT %>% 
  mutate(
    Micro.return = (Microsoft-Micro.L1)/Micro.L1 * 100,
    Micro.excess.return = Micro.return - USTB3M/12       # prime de risque de l'action microsoft
  )

# Transaformation des variables epxlicatives
APT <- APT %>%
  mutate(
    dcredit = consumer.credit - lag(consumer.credit ,1),
    dspread = baa.aaa.spread - lag(baa.aaa.spread ,1),
    dprod   = industrial.production - lag(industrial.production ,1),
    dmoney  = money.supply - lag(money.supply ,1),
    
    # inflation
    IPC.L1 = lag(IPC, 1),
    inflation = (IPC-IPC.L1)/IPC.L1 * 100,
    dinflation = inflation - lag(inflation,1),
    
    # Prime de maturité
    maturity  = USTB10Y - USTB3M,
    dmaturity = maturity - lag(maturity ,1),
    
    # Prime de risque du marché
    SP.L1             = lag(SP ,1),                     #lag de l'indice
    SP.return         = ((SP - SP.L1) / SP.L1) * 100,   #calcul du taux de croissance de l'indice
    SP.excess.return  = SP.return - USTB3M / 12         #transformation de la variable en différence
  ) %>% 
  filter(complete.cases(.)) # ne garde que les lignes sans aucune observation manquante (NA value)

# Modèle de régression multiple

reg_APT <- lm(Micro.excess.return ~ dcredit + dprod + dspread + dmoney + dinflation + dmaturity + SP.excess.return, data = APT)

summary(reg_APT)

# Tests sur les coefficients
coeftest(reg_APT)
# En corrigeant de l'hétéroscédasticité
coeftest(reg_APT, vcov = vcovHC(reg_APT, type = "HC1"))

# test d'hétéroscédasticité
bptest(reg_APT) 
# P-valeur très grande, on ne rejette pas H0, donc les erreurs sont homoscédastiques.

## Comparaison des modèles CAPM et APT

reg_CAPM <- lm(Micro.excess.return ~ SP.excess.return, data = APT)
summary(reg_CAPM)
summary(reg_APT)

cor.test(APT$SP.excess.return, APT$dmaturity, method = "pearson")
