# Inégalités spatiales
# 01 octobre 2026

library(readxl)
library(purrr)
library(sf)
library(fixest)
library(ggplot2)
library(rnaturalearth)
library(dplyr)
library(units)
library(mapview)
library(geosphere)
library(tidyr)

## ===== IMPORT DATA =====

your_path <- "G:/Mon Drive/TEACHING/MCF_Nantes/cours/M2_eco_spatiale/data/GEcon/Gecon40_post_final.xls"

Gecon <- read_excel(your_path)

## ===== CLEAN/MANIPULATE DATA =====

## Construire la géométrie de la données : des carreaux
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

## Transformer votre objet en objet spatial (sf)
Gecon <- st_as_sf(
  Gecon,
  crs = 4326
)

## ==== Manipulation des données ====

# on renomme certaines variables
Gecon <- Gecon %>% 
  rename(
    pop_1990 = POPGPW_1990_40,
    pop_1995 = POPGPW_1995_40,
    pop_2000 = POPGPW_2000_40,
    pop_2005 = POPGPW_2005_40,
    gdp_ppp_1990 = PPP1990_40,
    gdp_ppp_1995 = PPP1995_40,
    gdp_ppp_2000 = PPP2000_40,
    gdp_ppp_2005 = PPP2005_40,
    dist_ocean = DIS_OCEAN,
    dist_river = DIS_RIVER,
    precip_mean = PREC_NEW,
    temp_mean = TEMP_NEW,
    elevation = ELEV_SRTM_PRED,
    area = AREA
  )

# on calcule le log de la population et du log du pib par tête
Gecon <- Gecon %>% 
  mutate(
    log_pop_2005 = log(1 + pop_2005),
    log_gdppc_2005 = log(1 + gdp_ppp_2005 * 1e9 / pop_2005), # on multiplie par 1 millard le PIB car il était exprimé en milliard alors que la population est exprimée en unité
    temp_mean_sq = temp_mean^2,
    elevation_sq = elevation^2,
    pop_density_2005 = pop_2005/area
  )

# enlever les valeurs infinies de log_gdppc_2005 (dû aux zéros dans la variable population)
Gecon <- Gecon %>% 
  filter(is.finite(log_gdppc_2005) & area > 0)

## ===== EXERCICE 2 : ZIPF LAW =====

## Classement décroissant des carreaux par taille 
## -> carreau le plus peuplé a un rang 1, le deuxième carrea le plus peuplé un rang 2...

zipf_pop <- Gecon %>%
  st_drop_geometry() %>% 
  select(COUNTRY,pop_2005) %>% 
  arrange(desc(pop_2005)) %>%
  mutate(rang = row_number())

## Visualisation de la relation entre taille de la population et rang

ggplot(zipf_pop, aes(x = rang, y = pop_2005)) +
  geom_point(alpha = 0.4, size = 1) +
  labs(
    title = "La loi de Zipf",
    subtitle = "Population et rang des carreaux en 2005",
    x = "Rang",
    y = "Population"
  ) +
  theme_minimal()

## Modèle économétrique qui teste la relation de a loi de Zipf

zipf_law_model <- feols(
  log(pop_2005) ~ log(rang),
  data = zipf_pop
)

etable(zipf_law_model)

## Est-ce que le beta estimé est significativement différent de -1 ?

beta_hat <- zipf_law_model[["coefficients"]][["log(rang)"]]
se_beta <- zipf_law_model[["se"]][["log(rang)"]]

t_stat <- (beta_hat - (-1)) / se_beta
t_stat
abs(t_stat) > 1.96

## Est-ce que la constante estimée est significativement différente de log(pop1) ?
# càd de la population du carreau la plus peuplée (de rang 1).

pop_r1 <- zipf_pop$pop_2005[zipf_pop$rang == 1]
log_pop_r1 <- log(pop_r1)

log_pop_r1

const_hat <- zipf_law_model[["coefficients"]][["(Intercept)"]]
se_const <- zipf_law_model[["se"]][["(Intercept)"]]

t_stat_const <- (const_hat - log_pop_r1) / se_const

t_stat_const

abs(t_stat_const) > 1.96

## Impose la constante = log(pop) du carreaux de rang 1

zipf_pop$pop_div_pop_r1 <- zipf_pop$pop_2005 / pop_r1

zipf_law_model2 <- feols(
  log(pop_div_pop_r1) ~ log(rang) -1, # le -1 sert à ne pas estimer de constante dans le modèle
  data = zipf_pop
)

etable(zipf_law_model2)

etable(zipf_law_model,zipf_law_model2)

## Test sur le beta : significativement différent de -1 ?

beta_hat2 <- zipf_law_model2[["coefficients"]][["log(rang)"]]
se_beta2 <- zipf_law_model2[["se"]][["log(rang)"]]

t_stat2 <- (beta_hat2 - (-1)) / se_beta2
t_stat2
abs(t_stat2) > 1.96

## ===== EXERCICE 3 : BETA et SIGMA CONVERGENCE =====

## 1. Beta-convergence

Gecon <- Gecon %>% 
  mutate(growth_90_05 = 1/15 * log(gdp_ppp_2005/gdp_ppp_1990) * 100,
         log_gdppc_1990 = log(gdp_ppp_1990))

model <- feols(growth_90_05 ~ log_gdppc_1990, data=Gecon)
model_fe <- feols(growth_90_05 ~ log_gdppc_1990 | COUNTRY, data=Gecon)
etable(model,model_fe)

## pas de beta convergence : les régions les plus riches en 1990 ont connu
## une croissance plus soutenue que les régions plus pauvres.
## cette relation est vérifiée aussi au sein des pays.

## Evolution de la dispersion des richesses - sigma convergence

# Passage du format wide au format long
sigma_conv <- Gecon %>%
  st_drop_geometry() %>% 
  select(starts_with("gdp_ppp_")) %>%
  pivot_longer(
    cols = everything(),
    names_to = "year",
    values_to = "gdppc"
  ) %>%
  mutate(
    year = as.numeric(sub("gdp_ppp_", "", year)),
    log_gdppc = log(gdppc)
  ) %>% 
  filter(is.finite(log_gdppc)) %>%
  group_by(year) %>%
  summarise(
    sigma = sd(log_gdppc, na.rm = TRUE),
    .groups = "drop"
  )

# Afficher les résultats
sigma_conv

ggplot(sigma_conv, aes(x = year, y = sigma)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(
    x = "Année",
    y = expression(sigma[t]),
    title = "Évolution de la dispersion du PIB par habitant"
  ) +
  theme_minimal()

## Sigma convergence par pays

sigma_country <- Gecon %>%
  st_drop_geometry() %>% 
  select(COUNTRY, starts_with("gdp_ppp_")) %>%
  pivot_longer(
    cols = starts_with("gdp_ppp_"),
    names_to = "year",
    values_to = "gdppc"
  ) %>%
  mutate(
    year = as.numeric(sub("gdp_ppp_", "", year)),
    log_gdppc = log(gdppc)
  ) %>%
  filter(is.finite(log_gdppc)) %>% 
  group_by(COUNTRY, year) %>%
  summarise(
    sigma = sd(log_gdppc, na.rm = TRUE),
    .groups = "drop"
  )

sigma_change <- sigma_country %>%
  group_by(COUNTRY) %>%
  arrange(year) %>%
  summarise(
    sigma_initial = first(sigma),
    sigma_final = last(sigma),
    variation = sigma_final - sigma_initial,
    convergence = ifelse(variation < 0,
                         "Sigma-convergence",
                         "Sigma-divergence")
  )

## 3. Fond de carte
world <- ne_countries(scale = "medium", returnclass = "sf")

st_crs(world)

# Transform world map to Equal Earth projection
world_equal <- world %>%
  st_transform(crs = 8857)

# Check CRS
st_crs(world_equal)

sigma_change_sf <- world_equal %>% 
  left_join(sigma_change, by = c("name"="COUNTRY"))

mapview(sigma_change_sf, zcol="convergence")

ggplot(sigma_change_sf) +
  geom_sf(
    aes(fill = convergence),
    color = "white",
    linewidth = 0.15
  ) +
  labs(
    title = "Sigma-convergence du PIB par habitant entre 1990 et 2005",
    caption = "Bleu : convergence | Rouge : divergence"
  ) +
  theme_void()

## éventuellement tester effet du niveau de richesse sur la convergence intranationale

