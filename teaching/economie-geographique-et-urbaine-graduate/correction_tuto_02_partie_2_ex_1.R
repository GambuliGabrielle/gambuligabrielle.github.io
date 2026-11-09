## TUTORIEL SEANCE 2 - PARTIE 2

library(readxl)
library(purrr)
library(sf)
library(fixest)
library(ggplot2)
library(rnaturalearth)

## ==== Importation des données ====

# remplacer le chemin d'accès aux données par votre chemin d'accès
your_path <- "G:/Mon Drive/TEACHING/MCF_Nantes/cours/M2_eco_spatiale/materiel/GEcon/Gecon40_post_final.xls"

# importer les données
Gecon <- read_excel(your_path)

## ==== Transformation des données en données spatial ====

# Construction de la géométrie des données : des carreaux
# la latitude et longitude correspondent au coin inférieur gauche du carreau de l'observation

Gecon$geometry <- map2(
  Gecon$LONGITUDE,
  Gecon$LAT,
  ~ st_polygon(list(
    matrix(
      c(
        .x,     .y,
        .x + 1, .y,
        .x + 1, .y + 1,
        .x,     .y + 1,
        .x,     .y
      ),
      ncol = 2,
      byrow = TRUE
    )
  ))
)

# Transformation de l'objet en objet spatial (sf)
Gecon <- st_as_sf(
  Gecon,
  crs = 4326
)

# calcul du log de la population et du log du pib par tête
Gecon$log_pop_2005 <- log(1+Gecon$POPGPW_2005_40)
Gecon$log_gdppc_2005 <- log(1+Gecon$PPP2005_40 * 1e9 / Gecon$POPGPW_2005_40)

# enlever les valeurs infinies de log_gdppc_2005 (du aux zéros dans la variable population)
Gecon <- Gecon %>% 
  filter(is.finite(log_gdppc_2005))

# visualiser les données sur une carte
mapview(Gecon, zcol="log_gdppc_2005")

Gecon$elevation <- Gecon$D3
Gecon$elevation_sq <- Gecon$D3^2
Gecon$TEMP_NEW_sq <- Gecon$TEMP_NEW^2

# modeles OLS avec feols
model_pop <- feols(log_pop_2005 ~ log(DIS_OCEAN) + log(DIS_RIVER) + log(PREC_NEW) + TEMP_NEW + TEMP_NEW_sq + elevation + elevation_sq | COUNTRY, data = Gecon)
model_prod <- feols(log_gdppc_2005~ log(DIS_OCEAN) + log(DIS_RIVER) + log(PREC_NEW) + TEMP_NEW + TEMP_NEW_sq +  elevation + elevation_sq | COUNTRY, data = Gecon)
etable(model_pop, model_prod)











