+++
title = "Tutoriel d'Econométrie (for dummies) : les MCO sur R"
date = 2023-03-29
description = """
Etude de la reproduction intrafamiliale du nombre d'années d'éducation

"""
[extra]
year = 2023
+++

## Introduction

Ce tutoriel présente les bases pour effectuer des régressions linéaires simples sur R. Tout d'abord, si ce n'est pas déjà fait, [installez](https://posit.co/download/rstudio-desktop/) R (*le logiciel*) puis R Studio (*l'interface*) sur votre ordinateur. Avant de commencer, veillez à prendre en main R Studio. Je vous conseille de regarder cette [vidéo](https://www.youtube.com/watch?v=BGP9OzfqRPs) (*durée: 2 minutes*). Il en existe pleins d'autres. Beaucoup de ressources sont mises à disposition sur internet par la grande communauté des utilisateurs de R.

Dans le cadre de l'exercice, nous allons étudier la reproduction intergénérationelle de l'éducation. L'économétrie nous permettra de répondre aux questions suivantes : *Le niveau d'éducation scolaire des parents a-t-il un impact sur le niveau d'éducation scolaire de leurs enfants ? Quelle est la magnitude de cet impact ? Quels autres facteurs peuvent jouer un rôle ?* 

Pour répondre à ces questions, nous utilisons les [données](https://rdrr.io/cran/wooldridge/man/htv.html) mises à disposition par [Jeffrey M. Wooldridge](https://en.wikipedia.org/wiki/Jeffrey_Wooldridge) comme ressources complémentaires à son livre *Wooldridge, J. M. (2015). Introductory econometrics: A modern approach. Cengage learning*. D'autres bases de données sont disponibles dans le package "Wooldridge".

Vous pouvez télécharger le [code R](/teaching/econometrics-undergraduate/htv.R) pour suivre les étapes du tutoriel au fil de votre lecture.

## Prise en main

R repose sur des packages et bibliothèques (libraries) qui contiennent le code de différentes fonctions. Il faut donc d'abord installer ceux dont on a besoin pour cet exercice. Inscrivez dans votre console :

```{r}
install.packages("wooldridge") # pour télécharger les données de Wooldridge
install.packages("dplyr") # pour manipuler les données
```

Ensuite, pour utiliser ces packages, il faut les appelez dans la bibliothèque. Ecrivez sur votre éditeur :

```{r}
# Bibliothèques
library(dplyr) # pour faire des manipulations de données
library(wooldridge) # pour télécharger les données de Wooldridge
```

## Les données

Pour importer les données sur les niveaux d'éducation des individus et de leurs parents, on importe les données *htv* de Wooldridge. 
Nous écrivons dans l'éditeur :
```{r}
# Importer les données
data(htv) 
```
"htv" est un object enregistré dans la fenêtre environnement des données.
Le détails des variables se trouve sur ce [site](https://rdrr.io/cran/wooldridge/man/htv.html).


Il y a plusieurs façons de visualiser la base de données. Tout d'abord, regardons combien d'observations et de variables contient la base de données en utilisant la fonction *dim( )*, pour dimension. Nous écrivons dans l'éditeur :

```{r}
dim(htv) 
```
Dans la console apparaît : 
```{r}
> dim(htv)
[1] 1230   23
```
Cela signifie qu'il y a <span style="color: darkblue;">**1 230 observations**</span> et <span style="color: darkblue;">**23 variables**</span> dans la base de données.

La fonction *View( )* ouvre une nouvelle fenêtre sur l'ensemble des données. La fonction *head( )* affiche les premières lignes de la base de données dans la console. La fonction *names( )* affiche le noms des variables dans la console. Nous écrivons dans l'éditeur :

```{r}
# Visualiser les données
head(htv) 
```
Dans la console apparaît :

```{r}
> head(htv) 
       wage     abil educ ne nc west south exper motheduc fatheduc brkhme14 sibs urban ne18 nc18 south18 west18
1 12.019231 5.027738   15  0  0    1     0     9       12       12        0    1     1    1    0       0      0
2  8.912656 2.037170   13  1  0    0     0     8       12       10        1    4     1    1    0       0      0
3 15.514334 2.475895   15  1  0    0     0    11       12       16        0    2     1    1    0       0      0
4 13.333333 3.609240   15  1  0    0     0     6       12       12        0    1     1    1    0       0      0
5 11.070110 2.636546   13  1  0    0     0    15       12       15        1    2     1    1    0       0      0
6 17.482517 3.474334   18  1  0    0     0     8       12       12        0    2     1    1    0       0      0
  urban18   tuit17    tuit18    lwage expersq      ctuit
1       1 7.582914  7.260242 2.486508      81 -0.3226714
2       1 8.595144  9.499537 2.187472      64  0.9043922
3       1 7.311346  7.311346 2.741764     121  0.0000000
4       1 9.499537 10.162070 2.590267      36  0.6625338
5       1 7.311346  7.311346 2.404249     225  0
```
Les variables qui nous intéressent sont :
- ***educ***, pour le nombre d'années d'éducation de l'individu, 
- ***motheduc***, pour le nombre d'années d'éducation de sa mère et 
- ***fatheduc***, pour le nombre d'années d'éducation de son père. 

On ajoutera par la suite les variables :
- ***abil***, une mesure des capacités cognitives de l'individu, 
- ***sibs***, le nombre de frères et soeurs de l'individu, et 
- ***urban*** une variable indicatrice égale à 1 si l'individu vit dans une ville, 0 s'il vit à la campagne.

## Régressions

### Modèle 1

On veut savoir si le niveau d'éducation des parents influence celui de leurs enfants. On pose le modèle suivant : 
<div class="math ct"><i>educ</i><sub>i</sub> = <i>b</i><sub>0</sub> &plus; <i>b</i><sub>1</sub> <i>motheduc</i><sub>i</sub> &plus; <i>b</i><sub>2</sub> <i>fatheduc</i><sub>i</sub> &plus; <i>u</i><sub>i</sub> </div>

avec ***i*** désignant l'observation (l'individu), ***b<sub>0</sub>*** la constante, ***b<sub>1</sub>*** l'effet moyen d'une année d'éducation supplémentaire d'une mère sur le nombre d'années d'éducation d'un individu, ***b<sub>2</sub>*** l'effet moyen d'une année d'éducation supplémentaire d'un père sur le nombre d'années d'éducation d'un individu, et ***u<sub>i</sub>*** le terme d'erreur.

La méthode des moindres carrés ordinaires (MCO) nous permet d'estimer les coefficients ***b<sub>0</sub>***, ***b<sub>1</sub>*** et ***b<sub>2</sub>*** en minimisant la somme des carrés des résidus, ces résidus étant les estimateurs des termes d'erreur ***u<sub>i</sub>***.
Le modèle s'appuie sur certaines [hypothèses](https://fr.wikipedia.org/wiki/R%C3%A9gression_lin%C3%A9aire_multiple), qui, si respectées, estime correctement (sans biais) les coefficients. 

On utilise la fonction *lm( )* pour estimer notre modèle linéaire et la fonction *summary( )* pour afficher les résultats. Nous écrivons dans l'éditeur :

```{r}
regression1 <- lm(educ ~ motheduc + fatheduc, data = htv)
summary(regression1)
```

La console affiche les résultats suivant :

```{r}
> regression1 <- lm(educ ~ motheduc + fatheduc, data = htv) # lm = modèle linéaire
> summary(regression1)

Call:
lm(formula = educ ~ motheduc + fatheduc, data = htv)

Residuals:
    Min      1Q  Median      3Q     Max 
-6.2898 -0.9400 -0.4037  1.1239  8.1672 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  6.96435    0.31982  21.776   <2e-16 ***
motheduc     0.30420    0.03193   9.528   <2e-16 ***
fatheduc     0.19029    0.02228   8.539   <2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 2.042 on 1227 degrees of freedom
Multiple R-squared:  0.2493,	Adjusted R-squared:  0.248 
F-statistic: 203.7 on 2 and 1227 DF,  p-value: < 2.2e-16
```

Le résumé de la régression est organisé en 4 parties:
 1) ***Call*** : rappelle la régression effectuée.
 2) ***Residuals*** : présente des statistiques sur les résidus (valeurs minimum, 1er quartile, médiane, 3ème quartile, maximum).
 3) ***Coefficients*** : présente les coefficients estimés, ainsi que les écart-types, les statistiques de Student (qui teste l'hypothèse nulle selon laquelle le coefficient est égal à zéro (*H<sub>0</sub>* : b=0), les p-valeur et les niveaux de significativité des estimateurs.
 4) ***Statistiques complémentaires*** : présente les écart-types estimés des résidus, le R carré (ajusté et non-ajusté du nombre de variables), et les résultat du test de Fisher selon lequel aucun des coefficient n'est statistiquement différent de zéro.

#### Résultats du modèle 1

Les résultats du modèle nous permettent d'écrire la relation linéaire suivante :
<div class="math ct"><i>educ</i> = 6.96 &plus; 0.30 <i>motheduc</i> &plus; 0.19 <i>fatheduc</i> </div>

- Ceteris paribus, une année supplémentaire d'éducation chez la mère est associée en moyenne à 0.3 années supplémentaires d'éducation pour un individu (environ 4 mois). Pour le père, une année supplémentaire d'éducation est associée à 2 mois d'études supplémentaires pour l'individu. Les coefficients estimés sont très significatifs. D'après les p-valeurs, il y ait plus de 99% de chances que la différence ne soit pas due au hasard.

- Il semblerait donc que l'éducation des parents ait une influence positive et très significative sur l'éducation de leurs enfants. De plus, on trouve que l'éducation de la mère a plus d'influence que celle du père dans la durée d'éducation de leurs enfants en moyenne. Ceci est en tout cas valable pour l'échantillon étudié.

- Le R carré est le coefficient de détermination du modèle. Compris entre 0 et 1, il croît avec l’adéquation de la régression au modèle.
Le R carré de notre régression est de 0.25, ce qui signifie que 25% de la variation de l'éducation observée dans le modèle calculé peut être expliquée par l'éducation des parents. Ce coefficient est plutôt faible, car nous avons omis du modèle beaucoup de facteurs déterminant l'éducation d'un individu. Cependant, les variables d'éducation des parents détermine à elles seules 25% de la variation de l'éducation des individus, ce qui est en fait assez conséquent.

### Modèle 2

Nous voulons augmenter l'adéquation de notre modèle, c'est-à-dire augmenter le R carré et éviter les biais dans les coefficients estimés.
- *Pour augmenter la précision du modèle,* il faut ajouter des variables explicatives que nous pensons être importantes. 
- *Pour réduire le biais potentiel de nos estimateurs,* il faut ajouter les variables explicatives qui sont corrélées avec les variables déjà présentes dans le modèle pour éviter une corrélation entre le terme d'erreur *u<sub>i</sub>* et les variables explicatives. En effet, les variables non intégrées au modèle, qui pourtant expliquent le niveau d'éducation des individus, se cachent dans le terme d'erreur.


Nous ajoutons la variable d'habileté qui traduit des capacités cognitives des individus :

<div class="math ct"><i>educ</i><sub>i</sub> = <i>b</i><sub>0</sub> &plus; <i>b</i><sub>1</sub> <i>motheduc</i><sub>i</sub> &plus; <i>b</i><sub>2</sub> <i>fatheduc</i><sub>i</sub> &plus; <i>b</i><sub>3</sub> <i>abil</i><sub>i</sub> &plus; <i>u</i><sub>i</sub> </div>

Nous écrivons dans l'éditeur :

```{r}
regression2 <- lm(educ ~ motheduc + fatheduc + abil, data = htv)
summary(regression2)
```

La console affiche :

```{r}
> regression2 <- lm(educ ~ motheduc + fatheduc + abil, data = htv)
> summary(regression2)

Call:
lm(formula = educ ~ motheduc + fatheduc + abil, data = htv)

Residuals:
   Min     1Q Median     3Q    Max 
-5.407 -1.195 -0.199  1.076  7.012 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  8.44869    0.28954  29.180  < 2e-16 ***
motheduc     0.18913    0.02851   6.635 4.87e-11 ***
fatheduc     0.11109    0.01988   5.586 2.85e-08 ***
abil         0.50248    0.02572  19.538  < 2e-16 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 1.784 on 1226 degrees of freedom
Multiple R-squared:  0.4275,	Adjusted R-squared:  0.4261 
F-statistic: 305.2 on 3 and 1226 DF,  p-value: < 2.2e-16
```

#### Résultats du modèle 2

Les résultats du modèle nous permettent d'écrire la relation linéaire suivante :
<div class="math ct"><i>educ</i> = 8.45 &plus; 0.19 <i>motheduc</i> &plus; 0.11 <i>fatheduc</i> &plus; 0.50 <i>abil</i> </div>

- Le coefficient positif et significatif de la variable *abil* indique que plus les capacités cognitives des individus sont élevées, plus ils auront tendance à avoir une éducation scolaire et/ou universitaire longue. Nous pouvons interpréter ce résultat de plusieurs façons : (1) des capacités cognitives élevées permettent aux individus de réussir leurs études et donc de les poursuivre; (2) les individus aux capacités cognitives élevées sont plus souvent encouragés à faire des études; (3) des capacités cognitives élevées stimulent l'envie des individus de faire des études.

- Le R carré est de 0.43. Le pouvoir de prédiction du modèle a donc fortement augmenté. Les capacités cognitives des individus représentent un déterminant important du nombre d'années d'éducation.

- On remarque aussi que l'effet estimé de l'éducation des parents a diminué. Les estimateurs du premier modèle incluaient un biais positif, certainement dû à une corrélation positive entre éducation des parents et capacités cognitives. Plus des parents sont éduqués, plus ils vont stimuler leurs enfants intellectuellement, meilleures seront les capacités cognitives de l'enfant, et plus il aura la facilité et l'envie de faire de longues études.

### Modèle 3

Dans un troisème, nous ajoutons d'autres variables qui sont censées avoir un effet sur l'éducation : le nombre de frères et soeurs, désigné par la variable *sibs (siblings)*, et le lieu de vie, qui est soit urbain, soit rural, désigné par la variable *urban*.

<div class="math ct"><i>educ</i><sub>i</sub> = <i>b</i><sub>0</sub> &plus; <i>b</i><sub>1</sub> <i>motheduc</i><sub>i</sub> &plus; <i>b</i><sub>2</sub> <i>fatheduc</i><sub>i</sub> &plus; <i>b</i><sub>3</sub> <i>abil</i><sub>i</sub> &plus; <i>b</i><sub>4</sub> <i>sibs</i><sub>i</sub> &plus; <i>b</i><sub>5</sub> <i>urban</i><sub>i</sub> &plus; <i>u</i><sub>i</sub> </div>

Nous écrivons dans l'éditeur :

```{r}
regression3 <- lm(educ ~ motheduc + fatheduc + abil + sibs + urban, data = htv)
summary(regression3)
```

La console affiche :

```{r}
> regression3 <- lm(educ ~ motheduc + fatheduc + abil + sibs + urban, data = htv)
> summary(regression3)

Call:
lm(formula = educ ~ motheduc + fatheduc + abil + sibs + urban, 
    data = htv)

Residuals:
    Min      1Q  Median      3Q     Max 
-5.7411 -1.1774 -0.1683  1.1051  6.8351 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept)  8.84210    0.32327  27.352  < 2e-16 ***
motheduc     0.16967    0.02865   5.923 4.10e-09 ***
fatheduc     0.10766    0.01984   5.428 6.88e-08 ***
abil         0.49087    0.02567  19.120  < 2e-16 ***
sibs        -0.10870    0.02788  -3.899 0.000102 ***
urban        0.27854    0.13326   2.090 0.036803 *  
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 1.771 on 1224 degrees of freedom
Multiple R-squared:  0.4365,	Adjusted R-squared:  0.4342 
F-statistic: 189.7 on 5 and 1224 DF,  p-value: < 2.2e-16
```
#### Résultats du modèle 3

Les résultats du modèle nous permettent d'écrire la relation linéaire suivante :
<div class="math ct"><i>educ</i> = 8.44 &plus; 0.17 <i>motheduc</i> &plus; 0.11 <i>fatheduc</i> &plus; 0.49 <i>abil</i> &minus; 0.11 <i>sibs</i> &plus; 0.28 <i>urban</i> </div>

- En moyenne, le fait d'avoir un frère ou une soeur supplémentaire dans la famille a tendance à réduire l'éducation des individus de 0.11 années, soit 1 mois. 
	- Cette relation négative peut venir du fait que plus il y a d'enfants dans la famille, moins les parents auront les moyens de financer leurs études et moins ils ont de temps pour aider leurs enfants à étudier. Aussi, une famille nombreuse aura un revenu disponible pour chaque enfant plus faible, ce qui peut forcer les enfants à finir leurs études plus tôt pour pouvoir travailler et subvenir à leurs besoins.
- Habiter en ville est associé à 0.28 années d'éducation supplémentaires, soit 3 mois.
	- Habiter en ville c'est habiter à proximité des lieux d'éducation : écoles, universités, musées... Un accès géographique à l'éducation favorise le nombre d'années d'éducation des individus.
- Le pouvoir de prédiction du modèle n'a pas vraiment augmenté, le R carré est de 0.44. L'ajout des deux nouvelles variables du modèle n'améliore pas vraiment la prédiction du nombre d'années d'éducation d'un individu.
- On remarque que l'effet estimé de l'éducation de la mère a diminué. L'estimateur se composait encore d'un biais dû au fait que la variable est certainement corrélée avec le nombre d'enfants dans la famille, ainsi qu'avec la variable indicatrice du milieu de vie urbain.

*Comment expliquer le biais du coefficient estimé de <i>b</i><sub>1</sub> ?*
- Par rapport à l'ajout de la variable *sibs*  :
	1. L'éducation d'un individu est négativement corrélée au nombre de frères et soeurs qu'il a.
	Effectivement, on trouve <i>b</i><sub>4</sub> < 0.
	2. L'éducation d'une mère est négativement corrélé au nombre d'enfants qu'elle a.
	- Résultat : Omettre la variable *sibs*, c'est ajouter un biais au coefficient estimé de <i>b</i><sub>1</sub>, qui est composé de la multiplication des corrélations expliquées en (1) et (2). Ces deux corrélations sont négatives, ce qui crée un biais positif (*moins par moins fait plus*).
- Par rapport à l'ajout de la variable *urban*  :
	1. L'éducation d'un individu est positivement corrélée au fait qu'il habite en ville.
	Effectivement, on trouve <i>b</i><sub>5</sub> > 0.
	2. L'éducation d'une mère est positivement corrélé au fait d'habiter en ville, car une éducation élevée est corrélée à un revenu élevé qui permet aux individus d'habiter en ville où la vie est plus chère.
	- Résultat : Omettre la variable *urban*, c'est ajouter un biais au coefficient estimé de <i>b</i><sub>1</sub>, qui est composé de la multiplication des corrélations expliquées en (1) et (2). Ces deux corrélations sont positives, ce qui crée un biais positif (*plus par plus fait plus*).
  
#### Vérification des hypothèses supplémentaires

Nous avons fait des hypothèses quant aux corrélations entre éducation de la mère, capacités cognitives de son enfant, nombre de frères et soeurs et le fait d'habiter en ville. Il est possible de les vérifier. Pour cela, on peut écrire le modèle suivant :

<div class="math ct"><i>motheduc</i><sub>i</sub> = <i>a</i><sub>0</sub> &plus; <i>a</i><sub>1</sub> <i>abil</i><sub>i</sub> &plus; <i>a</i><sub>2</sub> <i>sibs</i><sub>i</sub> &plus; <i>a</i><sub>2</sub> <i>urban</i><sub>i</sub> &plus; <i>e</i><sub>i</sub> </div>

Nous écrivons dans l'éditeur :
```{r}
regression4 <- lm(motheduc ~ abil + sibs + urban, data = htv)
summary(regression4)
```

Et apparaît dans la console :
```{r}
> regression4 <- lm(motheduc ~ abil + sibs + urban, data = htv)
> summary(regression4)

Call:
lm(formula = motheduc ~ abil + sibs + urban, data = htv)

Residuals:
     Min       1Q   Median       3Q      Max 
-10.7605  -1.0483  -0.1568   0.9411   7.6347 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)    
(Intercept) 11.49920    0.17679  65.044  < 2e-16 ***
abil         0.35561    0.02751  12.927  < 2e-16 ***
sibs        -0.18249    0.03207  -5.690 1.59e-08 ***
urban        0.70749    0.15329   4.615 4.33e-06 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

Residual standard error: 2.064 on 1226 degrees of freedom
Multiple R-squared:  0.181,	Adjusted R-squared:  0.179 
F-statistic: 90.31 on 3 and 1226 DF,  p-value: < 2.2e-16
```

Nos hypothèses sont vérifiées. Le nombre d'années d'éducation de la mère est :
- positivement associé à la capacité cognitive de son enfant, <i>a</i><sub>1</sub> > 0
- négativement associé au nombre de frères et soeurs de l'enfant observé, <i>a</i><sub>2</sub> <0
- positivement associé au fait de vivre en ville, <i>a</i><sub>3</sub> > 0

## Conclusion

Dans cet exercice, nous avons démontré que le niveau d'éducation des individus dépend de plusieurs facteurs tels que le contexte familial, les capacités intellectuelles et le milieu de vie. Plus précisément, le niveau d'éducation des parents, la composition de la fratrie ainsi que le fait de vivre en ville ou à la campagne ont un impact significatif sur le niveau d'éducation des individus. Nous avons présenté le sens de l'impact de ces variables, positif et négatif, ainsi que la magnitude de leur impact, représenté par la valeur de leurs coefficients. 

Bien que cette analyse soit limitée, nous constatons que la combinaison de ces facteurs peut engendrer de multiples inégalités dans la réussite scolaire avec des différences entre les milieux urbains et ruraux, entre les familles, ou même au sein des familles, entre les frères et soeurs. Il existe aussi certainement des différences entre les pays, mais les données que nous avons utilisées ne nous permettent pas de l'étudier.

![](/image/signature.png)
