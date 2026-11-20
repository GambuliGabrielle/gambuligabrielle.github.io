### TUTORIEL SEANCE 2 PARTIE 1
### Données géolocalisées
### 17/09/2026

library(dplyr)
library(ggplot2)
library(sf)
library(mapview)
library(units)

## ==== Les communes de Nantes métropole ====

# API données communes
url_communes <- paste0(   
  "https://data.nantesmetropole.fr/api/explore/v2.1/catalog/datasets/",
  "244400404_communes-nantes-metropole/",   
  "exports/geojson" 
)

communes <- st_read(url_communes)

# Transformer le système de coordonnées
st_crs(communes)
# actuellement, la géométrie des communes est codée en WGS (4326)

# transformation en Lambert-93 (2154)
communes_lambert <- st_transform(communes, crs = 2154)
st_crs(communes_lambert)

head(communes$geometry)
head(communes_lambert$geometry)

# calcul de superficie de Nantes
superficie_nantes_m2 <- communes_lambert %>% 
  filter(toponyme=="Nantes") %>% 
  st_area(geometry)
superficie_nantes_m2

superficie_nantes_km2 <- superficie_nantes_m2 %>% 
  set_units("km^2")
superficie_nantes_km2

# calcul de superficie de Nantes
superficie_nantes_m2 <- communes_lambert %>% 
  filter(toponyme=="Nantes") %>% 
  st_area(geometry)

superficie_nantes_km2 <- superficie_nantes_m2 %>% 
  set_units("km^2")

## Superficie de chaque commune
communes_lambert <- communes_lambert %>% 
  mutate(superficie = set_units(st_area(geometry),"km^2"))

# Trouver la commune de la métropole de Nantes la plus grande
commune_la_plus_grande <- communes_lambert %>% 
  slice_max(superficie) %>% 
  pull(toponyme)
commune_la_plus_grande

## ==== Les tronçons de voies routières de Nantes métropole ====

url_voies <- paste0(   
"https://data.nantesmetropole.fr/api/explore/v2.1/catalog/datasets/",
"244400404_troncons-voies-nantes-metropole/",   
"exports/geojson"
)  

voies <- st_read(url_voies)

# Combien a-t-elle de lignes et de colonnes ?
dim(voies)

# Comment s’appelle la géométrie utilisée ?
head(voies$geometry)
# Réponse : multistring

# Quel CRS est utilisé ?
# Réponse : WGS 84 (latitude longitude)

# Faites une carte en ne faisant apparaître que les voies principales et magistrales de la zone d’étude.
unique(voies$classement_pdu)

voies_mag <- voies %>% 
  filter(classement_pdu %in% c("Voie principale de catégorie A",
                               "Voie principale de catégorie B",
                               "Voie Magistrale")
         )

mapview(voies_mag, zcol="classement_pdu")

# Calculer la longueur totale des voies principales et magistrales en utilisant la fonction set_units(st_length(), "km")).
voies_mag %>% 
  mutate(longueur = set_units(st_length(geometry), "km")) %>% 
  summarise(longueur = sum(longueur,na.rm=T)) %>% 
  pull(longueur)
# 1068.219 [km]

# Créez un nouvel objet, que vous appelez voies_lambert, où la géométrie est codée en Lambert-93.
voies_lambert_mag <- st_transform(voies_mag, crs = 2154)

# A partir de ce nouvel objet, calculez la longueur totale des voies principales et magistrales. Que constatez vous ?
voies_lambert_mag %>% 
  mutate(longueur = set_units(st_length(geometry), "km")) %>% 
  summarise(longueur = sum(longueur,na.rm=T)) %>% 
  pull(longueur)
# 1068.861 [km]


## ==== Les équipements publics ====

url_equip_pub <- paste0(   
  "https://data.nantesmetropole.fr/api/explore/v2.1/catalog/datasets/",
  "244400404_equipements-publics-nantes-metropole/",      
  "exports/geojson" 
)  

equip_pub <- st_read(url_equip_pub)

# Choisissez un type d’équipement publique et faites une carte
# (interactive ou non) pour montrer leur localisation
# au sein de la métropole nantaise.

#pour regarder les différents équipements
names(equip_pub)
# c'est la variable theme qui catégorise les équipements
unique(equip_pub$theme)

equip_enseignement <- equip_pub %>% 
  filter(theme == "Enseignement") %>% 
  select(idobj_equipub, nom, theme, categorie, commune, code_postal, code_insee, geometry)

# carte 
mapview(equip_enseignement, zcol="categorie")

# Visualiser un unique point sur une carte : notre IAE.
iae <- equip_enseignement %>%
  filter(grepl("IAE", nom))

mapview(iae)

# Compter le nombre d’infrastructures de sport et loisirs présents 
# dans chaque commune de la métropole de Nantes.
unique(equip_pub$theme)

#filtrer
equip_sport <- equip_pub %>% 
  filter(theme=="Sport et loisirs")

# compter par commune
equip_sport_commune <- equip_sport %>% 
  st_drop_geometry() %>% 
  group_by(commune,code_insee) %>% 
  summarise(n = n())
  
# Faites une carte chloropèthe affichant le nombre d’infrastructures 
# de sport et loisirs par commune.

equip_sport_commune_lambert <- communes_lambert %>% 
  left_join(
    equip_sport_commune,
    by = c("id_insee" = "code_insee")
  )
class(equip_sport_commune$code_insee)
class(communes_lambert$id_insee)

equip_sport_commune_lambert <- communes_lambert %>% 
  mutate(id_insee = as.integer(id_insee)) %>% 
  left_join(
    equip_sport_commune,
    by = c("id_insee" = "code_insee")
  )

mapview(equip_sport_commune_lambert, zcol="n")

## ==== Spatial join ====

equip_pub_simple <- equip_pub %>% 
  select(idobj_equipub, nom, nom_complet, theme, categorie, type, geometry)

equip_pub_commune <- st_join(equip_pub_simple,communes_lambert)
# problème de CRS (c'est important)

st_crs(communes_lambert)
st_crs(equip_pub_simple)

equip_pub_commune <- equip_pub_simple %>% 
  st_transform(geometry,crs = 2154) %>% 
  st_join(communes_lambert)

mapview(equip_pub_commune)

## ==== Centroïdes ====

centroides <- st_centroid(communes_lambert)

ggplot() + 
  geom_sf(data = communes, fill = "white", color = "grey50") + 
  geom_sf(data = centroides, color = "red", size = 2) + 
  theme_void()

points_internes <- st_point_on_surface(communes_lambert)

ggplot() + 
  geom_sf(data = communes, fill = "white", color = "grey50") + 
  geom_sf(data = centroides, color = "red", size = 2) + 
  geom_sf(data = points_internes, color = "green", size = 2) + 
  theme_void()

## ==== Calcul de distance ====

nantes <- centroides %>% 
  filter(toponyme == "Nantes")

coueron <- centroides %>% 
  filter(toponyme == "Couëron")

distance <- st_distance(nantes, coueron)

distance_km <- set_units(distance, "km")

distance_km
# 13.77579
