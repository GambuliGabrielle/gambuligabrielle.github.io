## Correction exercices

voies %>% 
  filter(classement_pdu %in% c("Voie principale de catégorie B","Voie principale de catégorie A","Voie Magistrale")) %>% 
  mapview(zcol = "classement_pdu")

voies %>% 
  filter(classement_pdu %in% c("Voie principale de catégorie A","Voie Magistrale")) %>% 
  mutate(longueur_km = set_units(st_length(geometry), "km")) %>% 
  st_drop_geometry() %>% 
  summarise(longueur_km = sum(longueur_km))
  

voies_lambert <- voies %>% 
  st_transform(geometry, crs = 2154)

voies_lambert %>% 
  filter(classement_pdu %in% c("Voie principale de catégorie A","Voie Magistrale")) %>% 
  mutate(longueur_km = set_units(st_length(geometry), "km")) %>% 
  st_drop_geometry() %>% 
  summarise(longueur_km = sum(longueur_km))
