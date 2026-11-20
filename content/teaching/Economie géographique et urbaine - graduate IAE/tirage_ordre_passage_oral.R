## TIRAGE AU SORT DE L'ORDRE DE PASSAGE DEs GROUPES
## POUR LES EVALUATIONS ORALES

# Définir les groupes
groupes <- data.frame(
  groupe = 1:12,
  membres = c(
    "Emma, Jules",
    "Ainara, David",
    "Elliott, Louane",
    "Augustin, Félicia",
    "Diane, Elisée",
    "Raphaëlle, Romane",
    "Elise, Lomane",
    "Céline, Sarah",
    "Nene, Patrice, Samuel",
    "Amélie, Ikram",
    "Jameson, Nassim",
    "Ahmat, Royer"
  )
)

x <- 3 # chiffre choisi par les étudiants

# Tirage au sort reproductible
set.seed(x)
tirage <- groupes[sample(nrow(groupes)), ]

# Répartition en deux séances de 6 groupes
tirage$seance <- rep(c("Séance 1", "Séance 2"), each = 6)

# Ordre de passage au sein de chaque séance
tirage$passage <- rep(1:6, times = 2)

# Tableau final
tirage <- tirage[, c("seance", "passage", "membres")]
rownames(tirage) <- NULL

print(tirage, row.names = FALSE)

