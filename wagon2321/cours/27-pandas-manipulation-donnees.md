---
title: 'Pandas — Manipulation de données : Series, DataFrame, agrégations & jointures'
aliases:
- Python 2
- Pandas — Manipulation de données
- Masque booléen Pandas
- loc vs iloc
- GroupBy Pandas
- Merge Pandas (Join)
- Pivot table Pandas
type: course
status: active
course: Le Wagon — Data Analytics
batch: 2321
session: 27
date: 2026-08-11
language: fr
database: n/a — pas de connexion SQL native dans cette session ; DataFrames construits en local (CSV / dictionnaire
  / liste) + un CSV chargé directement depuis une URL (dataset *tips*, cas d'étude « Le Wagon Rouge »)
topics:
- Python
- NumPy
- Pandas
- DataFrame
- Series
- Masques booléens
- GroupBy
- Merge / Jointures
- Pivot tables
- Dates (datetime64)
- Agrégations
tags:
- brocode
- wagon2321/cours
modeles_ia:
- '[[modeles-ia/Claude Sonnet]]'
attribution: confirmee
code_language: Python
course_id: pandas-manipulation-donnees
role_version: reference
---

# 27 - Pandas : manipulation de données

> [!info] Repères Brocode
> **Modèle IA — rédaction :** [[modeles-ia/Claude Sonnet|Claude Sonnet]]
> **Version :** référence · [[navigation/Cours|Index des cours]]


> [!info] TL;DR
> Deuxième jour de Python — cette fois on retrouve un terrain connu. NumPy pose le socle du calcul vectoriel, Pandas construit par-dessus pour donner des **DataFrames**, l'équivalent Python des tables SQL / Google Sheets. Au programme : création, exploration, sélection (`loc`/`iloc`), filtrage par masque booléen, colonnes calculées, agrégations, `groupby`, `pivot_table`, assemblage (`concat`/`merge`) et gestion des dates — puis un cas d'étude filé sur un restaurant fictif, **Le Wagon Rouge**.

🔗 Fait suite à [[wagon2321/cours/26_python_intro|Intro Python]] (bases du langage — variables, boucles, fonctions, jour 1)
📅 Suite du programme : Excel/JSON/SQLAlchemy le lendemain, Machine Learning avec Scikit-Learn la semaine suivante, cours dédié aux stats le vendredi

---

## 🗺️ Sommaire

- [[#1. NumPy — le socle vectoriel]]
- [[#2. Pandas — Series & DataFrame]]
- [[#3. Créer un DataFrame]]
- [[#4. Explorer un DataFrame]]
- [[#5. Sélectionner des données]]
- [[#6. Masques booléens (filtrage)]]
- [[#7. Créer et modifier des colonnes]]
- [[#8. Fonctions personnalisées : apply() et lambda]]
- [[#9. Agrégations]]
- [[#10. GroupBy]]
- [[#11. Pivot tables]]
- [[#12. Assembler des DataFrames : concat & merge]]
- [[#13. Gérer les dates]]
- [[#14. Étude de cas — Le Wagon Rouge (dataset tips)]]
- [[#15. Bonnes pratiques retenues]]
- [[#✅ Actions post-session]]
- [[#🧾 Corrections & remarques sur la source]]

---

## 1. NumPy — le socle vectoriel

**NumPy** est la librairie de calcul vectoriel sur laquelle Pandas est construit. Son intérêt : éviter les boucles imbriquées sur des listes Python natives en appliquant les opérations en quasi-parallèle sur l'ensemble des données — un gain de performance énorme sur de gros volumes.

```python
import numpy as np  # np : alias conventionnel, à respecter pour la collaboration

# Créer un array à partir d'une liste
arr1 = np.array([1, 2, 3, 4, 5])

# Créer un array à partir d'un intervalle (borne de fin exclue, comme range())
arr2 = np.arange(0, 10, 2)  # start, stop, step → [0 2 4 6 8]
```

**Opérations vectorisées** — pas besoin de boucle `for` :

```python
sum_of_array = arr1 + arr2
diff = arr1 - arr2
```

> [!warning] Règle critique
> Pour opérer entre deux arrays, ils doivent avoir **la même dimension** (`.shape` identique). `arr1` (5 valeurs) + un array de 10 valeurs → erreur explicite. C'est la même règle qui réapparaîtra plus loin pour l'insertion de colonnes dans un DataFrame (cf. [[#7. Créer et modifier des colonnes]]).

**Arrays multi-dimensionnels (matrices)** :

```python
matrice = np.array([[1, 2, 3], [4, 5, 6]])
```

`.shape` est l'attribut de référence pour connaître les dimensions :

| Objet | `.shape` | Interprétation |
|---|---|---|
| `arr1` | `(5,)` | 1D — un seul nombre dans le tuple |
| `matrice` | `(2, 3)` | 2D — deux nombres : lignes × colonnes |

> [!tip] Au-delà de 2D
> NumPy supporte jusqu'à 50 dimensions. Exemple concret : une image RGB est un array **3D** (hauteur × largeur × couche couleur). C'est ce terrain que Pandas vient ensuite spécialiser pour l'analyse tabulaire (2D essentiellement).

---

## 2. Pandas — Series & DataFrame

Pandas hérite des performances de NumPy et ajoute une représentation tabulaire pensée pour l'analyse de données.

```python
import pandas as pd  # pd : alias conventionnel
```

### Series

Une **Series** est un array **1D labellisé**, capable de contenir n'importe quel type de donnée.

- Les labels des axes s'appellent des **index**
- Analogue à **une colonne** dans un Google Sheet ou une table SQL (pas une ligne, pas un dictionnaire, pas une requête)
- Les index n'ont pas besoin d'être uniques, mais doivent être **hashables** — donc pas de listes ni de dictionnaires comme index (risque de conflit avec `.loc`)
- Deux Series juxtaposées (une par colonne) → un DataFrame

### DataFrame

Un **DataFrame** est une structure **2D** avec axes labellisés (lignes et colonnes), composée de **3 éléments** : les données, les lignes, les colonnes. Chaque colonne d'un DataFrame est elle-même une Series — un DataFrame est donc un ensemble de Series concaténées côte à côte.

> [!note] Comparaison — valeurs manquantes
> Pandas représente l'absence de valeur par **`NaN`** (Not a Number), à ne pas confondre avec ses cousins :
>
> | Contexte | Valeur manquante |
> |---|---|
> | Pandas | `NaN` |
> | Python pur | `None` |
> | SQL | `NULL` |
>
> Une chaîne vide `""` n'est **pas** une valeur manquante — c'est une chaîne de caractères comme une autre.

---

## 3. Créer un DataFrame

### Depuis un fichier CSV

```python
df = pd.read_csv("introduction_dataframe_data.csv")
# df = pd.read_excel() existe aussi, ainsi que read_sql, read_json, etc.
```

> [!warning] Points d'attention
> - Le chemin est **relatif au dossier d'ouverture du notebook**
> - `read_csv` est **sensible à la casse**

Dataset utilisé pour les exemples de ce chapitre (6 lignes) :

| date | store_id | item_id | price | quantity |
|---|---|---|---|---|
| 20190101 | 23 | 67 | 100 | 2 |
| 20190101 | 11 | 87 | 20 | 3 |
| 20190103 | 11 | 56 | 50 | 1 |
| 20190105 | 13 | 87 | 20 | 5 |
| 20190107 | 13 | 56 | 50 | 2 |
| 20190111 | 23 | 56 | 50 | 3 |

### Depuis un dictionnaire

Méthode la plus intuitive : les clés deviennent les noms de colonnes.

```python
df = pd.DataFrame({
    "date": ["20190101", "20190101", "20190103", "20190105", "20190107", "20190111"],
    "store_id": [23, 11, 11, 13, 13, 23],
    "item_id": [67, 87, 56, 87, 56, 56],
    "price": [100, 20, 50, 20, 50, 50],
    "quantity": [2, 3, 1, 5, 2, 3]
})
```

### Depuis une liste de listes

Raisonnement ligne par ligne — il faut préciser les noms de colonnes.

```python
df = pd.DataFrame([['20190101', 23, 67, 100, 2],
                    ['20190101', 11, 87, 20, 3],
                    ['20190103', 11, 56, 50, 1],
                    ['20190105', 13, 87, 20, 5],
                    ['20190107', 13, 56, 50, 2],
                    ['20190111', 23, 56, 50, 3]],
                   columns=["date", "store_id", "item_id", "price", "quantity"])
```

**Autres sources possibles** (aperçu, détaillées lors d'un prochain cours) : `read_excel`, `read_sql`, `read_json`, connexion BigQuery, web scraping.

**Exporter** : `df.to_csv("chemin.csv", index=False)` — `index=False` évite d'exporter une colonne d'index inutile.

---

## 4. Explorer un DataFrame

| Méthode / attribut | Rôle |
|---|---|
| `df.shape` | Nombre de lignes et colonnes — **réflexe n°1** à la découverte d'un dataset |
| `df.columns` | Liste des intitulés de colonnes |
| `df.index` | Range d'index des lignes |
| `df.dtypes` | Type de donnée par colonne — utile pour repérer des dates mal typées |
| `df.info()` | Synthèse complète : dtypes + nombre de valeurs non nulles par colonne |
| `df.describe()` | Statistiques descriptives (moyenne, min, max, quartiles) — **colonnes numériques uniquement** par défaut |
| `df.head(n)` / `df.tail(n)` | n premières / dernières lignes (5 par défaut) |
| `df.isnull().sum()` | Nombre de valeurs nulles par colonne |

```python
df.shape    # (6, 5)
df.dtypes
```

```
date         object
store_id      int64
item_id       int64
price         int64
quantity      int64
dtype: object
```

> [!tip] Pourquoi `dtype: object` en bas alors que mes colonnes sont en `int64` ?
> C'est un détail qui surprend souvent : `df.dtypes` renvoie elle-même une **Series**, dont chaque valeur est un objet dtype NumPy (`int64`, `object`...). Cette Series-là, qui contient des dtypes hétérogènes, a pour propre type `object` — c'est le type de *la Series des types*, pas celui de vos colonnes. Un bon réflexe pédagogique pour ne pas confondre les deux niveaux de lecture.

`df.describe()` cible uniquement les colonnes numériques par défaut : impossible d'agréger statistiquement une colonne texte au-delà d'un comptage — d'où l'exclusion automatique des colonnes `object`.

---

## 5. Sélectionner des données

### Sélection de colonnes

```python
df["store_id"]                              # → Series
df[["store_id"]]                             # → DataFrame (une seule colonne)
df[["store_id", "item_id", "quantity"]]      # → DataFrame (colonnes multiples)

columns_to_keep = ["store_id", "item_id", "quantity"]
df[columns_to_keep]                          # équivalent, via variable
```

> [!note] `df.nom_colonne`
> Une syntaxe raccourcie existe (accès par attribut) mais elle est **moins robuste** — elle casse dès que le nom de colonne contient un espace ou entre en collision avec une méthode Pandas existante. À réserver à l'exploration rapide.

### `.loc` vs `.iloc`

| | Sélectionne par | Borne de fin |
|---|---|---|
| `.loc` | **labels** (index et noms de colonnes) | **incluse** |
| `.iloc` | **positions entières** | **exclue** (comme `range`/`arange`) |

```python
df.loc[1:3, ["store_id", "item_id"]]   # lignes d'index 1 à 3 INCLUS, colonnes nommées
df.loc[:, ["store_id", "item_id"]]     # toutes les lignes, colonnes nommées

df.iloc[1:4, 1:3]                      # lignes en position 1 à 4 EXCLU, colonnes en position 1 à 3 EXCLU
```

> [!question] Détail transversal — voir la fiche dédiée [[codex/python/loc vs iloc (Pandas)|loc vs iloc (Pandas)]] pour la confusion classique entre labels et positions quand l'index par défaut est numérique.

---

## 6. Masques booléens (filtrage)

Le filtrage de lignes en Pandas passe par le **masquage booléen** : on construit une condition logique sur une colonne, ce qui produit une Series de `True`/`False` alignée sur l'index d'origine, puis on l'applique au DataFrame entre crochets.

```python
# 1. Créer la condition
mask_store_id_23 = (df["store_id"] == 23)

mask_store_id_23
# 0     True
# 1    False
# 2    False
# 3    False
# 4    False
# 5     True
# dtype: bool

# 2. Appliquer le masque
df_stores_id_23 = df[mask_store_id_23]
```

**Syntaxe condensée**, équivalente et plus courante en pratique :

```python
df[df["store_id"] == 23]
```

**Combiner des conditions** : `&` (ET), `|` (OU), `!=` (négation) — chaque condition doit être entre parenthèses à cause de la précédence des opérateurs Python.

```python
df[(df["store_id"] == 23) & (df["quantity"] > 2)]
```

> [!tip] Détail transversal — voir la fiche dédiée [[codex/python/Masque booléen (Pandas & NumPy)|Masque booléen (Pandas & NumPy)]] pour le lien entre masque booléen et le `WHERE` SQL, et l'astuce `.sum()` sur une Series booléenne pour compter des occurrences.

---

## 7. Créer et modifier des colonnes

Même syntaxe pour créer et pour modifier — comme pour un dictionnaire, référencer une clé qui n'existe pas encore la crée.

```python
df["my_1_column"] = 1   # constante → toutes les lignes reçoivent la même valeur
```

> [!warning] Règle de conservation du nombre de lignes
> Si vous assignez une **liste** plutôt qu'une constante, elle doit contenir **exactement** le même nombre d'éléments que de lignes dans le DataFrame — sinon : erreur explicite (*"Length of values does not match length of index"*). Cette règle est la même que celle vue en NumPy pour les opérations entre arrays ([[#1. NumPy — le socle vectoriel]]) : le nombre de valeurs doit matcher.

### Opérations arithmétiques entre colonnes

```python
df["total_spend"] = df["quantity"] * df["price"]
```

L'opération se fait **ligne à ligne**, en s'appuyant sur l'alignement des **index** : Pandas compare index 0 avec index 0, index 1 avec index 1, etc. — c'est ce même mécanisme d'alignement par index qui sous-tend les masques booléens ([[#6. Masques booléens (filtrage)]]).

---

## 8. Fonctions personnalisées : `apply()` et `lambda`

Pour une logique de classification qu'une simple opération arithmétique ne peut pas exprimer (l'équivalent d'un `CASE WHEN` SQL), on définit une fonction et on l'applique colonne par colonne avec `.apply()` :

```python
def classify(spend):
    if spend >= 100:
        return "grosse dépense"
    else:
        return "petite dépense"

df["spend_category"] = df["total_spend"].apply(classify)
```

Pour une fonction rapide, à usage unique, on peut éviter de la nommer avec une **fonction lambda** :

```python
df["quantity"].apply(lambda x: x * 2)  
# équivalent plus simple ici : df["quantity"] * 2
```

> [!tip] Conseil du formateur
> Pour bien comprendre le fonctionnement d'`apply()`, mieux vaut d'abord maîtriser la syntaxe avec des **fonctions nommées définies au préalable**, avant de passer aux `lambda` — qui font gagner de la place une fois l'aisance acquise, mais compliquent la lecture au démarrage.

---

## 9. Agrégations

Une fonction d'agrégation réduit un ensemble de valeurs à une seule (même logique qu'en SQL).

| Fonction | Rôle |
|---|---|
| `.sum()` | Somme |
| `.max()` / `.min()` | Maximum / minimum |
| `.median()` | Médiane |
| `.mean()` | Moyenne |
| `.mode()` | Valeur la plus fréquente |
| `.unique()` | Valeurs uniques (équivalent `SELECT DISTINCT`) |
| `.nunique()` | Nombre de valeurs uniques |
| `.value_counts()` | Comptage par valeur unique (équivalent `GROUP BY` + `COUNT`) |

```python
df["date"].unique()      # array(['20190101', '20190103', '20190105', '20190107', '20190111'], dtype=object)
df["quantity"].sum()     # np.int64(16)

# Prix moyen pondéré
df["price"].sum() / df["quantity"].sum()   # np.float64(18.125)
```

> [!tip] Cross-link — Aggregate before divide
> `df["price"].sum() / df["quantity"].sum()` (moyenne pondérée globale) plutôt que `df["price"].mean()` — c'est le même principe **"aggregate before divide"** déjà rencontré côté SQL/BigQuery : sommer d'abord, diviser ensuite, pour ne pas fausser une moyenne par un calcul ligne à ligne prématuré.

### `.agg()` — plusieurs fonctions, plusieurs colonnes

```python
df.agg({"price": "mean", "quantity": "median"})
# price       48.333333
# quantity     2.500000
```

Le paramètre est un dictionnaire : `{nom_de_colonne: fonction_d'agrégation}`.

---

## 10. GroupBy

`.groupby()` segmente **avant** d'agréger — équivalent du `GROUP BY` SQL, mais jugé par le formateur "plus puissant" en Pandas pour des opérations complexes.

**Syntaxe, décomposée en 4 étapes** :
1. Nom du DataFrame
2. `.groupby(["colonne_de_segmentation"])`
3. `[["colonnes_à_garder"]]` entre crochets
4. La fonction d'agrégation à appliquer

```python
df.groupby(["store_id"])["quantity"].sum()
# store_id
# 11    4
# 13    7
# 23    5

df.groupby(["store_id"])[["quantity", "price"]].mean()
#           quantity  price
# store_id
# 11             2.0   35.0
# 13             3.5   35.0
# 23             2.5   75.0
```

> [!warning] Comportement par défaut : la colonne de groupement devient l'index
> Pour la conserver comme colonne à part entière, ajouter `as_index=False` : `df.groupby(["store_id"], as_index=False)[...]`.

**Grouper sur plusieurs colonnes à la fois** : `df.groupby(["store_id", "date"])[...]` — comme en SQL, on peut passer une liste.

### Trier le résultat — `sort_values`

Équivalent de `ORDER BY`. Par défaut ordre **croissant** ; pour l'ordre décroissant, `ascending=False` (pas de mot-clé `DESC` comme en SQL).

```python
df.groupby(["store_id"])[["quantity", "price"]].mean().sort_values(by=["quantity"], ascending=False)
```

---

## 11. Pivot tables

Équivalent Pandas des tableaux croisés dynamiques vus dans Google Sheets.

```python
df_pivot = pd.pivot_table(df, values=["quantity"], index=["item_id"], columns=["store_id"], aggfunc="sum")
```

| | `store_id` 11 | `store_id` 13 | `store_id` 23 |
|---|---|---|---|
| `item_id` 56 | 1.0 | 2.0 | 3.0 |
| `item_id` 67 | NaN | NaN | 2.0 |
| `item_id` 87 | 3.0 | 5.0 | NaN |

Utile pour repérer d'un coup d'œil les combinaisons absentes (magasins qui ne vendent pas certains articles → `NaN`). Peu utilisé en pratique quotidienne selon le formateur, mais bon à connaître.

---

## 12. Assembler des DataFrames : `concat` & `merge`

### `pd.concat()` — empiler des DataFrames

```python
df_concat = pd.concat([df1, df2], axis=0)   # axis=0 (défaut) : empilement par LIGNES
pd.concat([df1, df2], axis=1)               # axis=1 : côte à côte, par COLONNES (cas plus rare)
```

> [!warning] Index dupliqués après un `concat` par lignes
> Après un `concat(axis=0)`, les index se répètent (0, 1, 2, 0, 1, 2...). Réflexe : `df_concat = df_concat.reset_index(drop=True)`. Sans `drop=True`, l'ancien index est conservé comme nouvelle colonne plutôt que d'être jeté.

### `pd.merge()` — l'équivalent des `JOIN` SQL

En Pandas, les jointures s'appellent des **merges**, mais le principe est rigoureusement identique à SQL : source de données, clé de jointure, type de jointure.

```python
pd.merge(df_concat, df3, on=["id"], how="inner")
# ou en syntaxe méthode : df_concat.merge(df3, on=["id"], how="inner")
```

| Paramètre `how=` | Comportement |
|---|---|
| `"inner"` | Ne garde que les `id` communs aux deux DataFrames |
| `"left"` | Garde tous les `id` du DataFrame de gauche ; complète avec `NaN` si pas de correspondance à droite |
| `"outer"` | Garde l'union de tous les `id` des deux côtés ; `NaN` là où une des deux tables n'a pas d'enregistrement |

**Colonnes de jointure à noms différents** : remplacer `on=` par `left_on=` et `right_on=` (respectivement le nom de la colonne clé dans le DataFrame de gauche et dans celui de droite). Ceci génère deux colonnes de clé distinctes dans le résultat — pensez à modifier les noms de colonnes en amont si vous voulez éviter la redondance.

> [!warning] Unicité de la clé de jointure — piège classique
> Contrairement à une clé SQL, Pandas **n'impose aucune contrainte d'unicité** sur la colonne de jointure : elle peut contenir des doublons sans lever d'erreur, ce qui peut dupliquer silencieusement des lignes après un merge. Si la granularité doit rester unique côté droit (ex. table de correspondance code postal → ville), dédupliquez / agrégez cette table **avant** le merge pour garantir une valeur unique par clé.

---

## 13. Gérer les dates

Les dates importées (CSV notamment) sont très souvent typées `object` (chaîne de caractères) — un problème qu'on ne détecte qu'en vérifiant `df.dtypes` ou `df.info()`.

```python
print(df.loc[0, "date"])    # 20190101
type(df.loc[0, "date"])     # str

df["date"] = pd.to_datetime(df["date"], format="%Y%m%d")  # le format dépend de l'écriture d'origine
```

Une fois converti en `datetime64[ns]`, la colonne donne accès à l'accesseur `.dt` :

```python
df["date"].dt.day       # extraire le jour (aussi : .month, .year)
df["date-year-week"] = df["date"].dt.strftime("%Y-%U")   # créer une colonne année-semaine
```

> [!warning] Priorité absolue
> Toujours vérifier et convertir les colonnes de dates **en tout début d'analyse**. Une fois converties, elles ouvrent l'accès à des agrégations temporelles très puissantes — mais rien de tout cela n'est disponible tant que la colonne reste un `object`.

---

## 14. Étude de cas — Le Wagon Rouge (dataset *tips*)

Exercice fil rouge, mené en co-construction avec le groupe : analyse du service d'un restaurant fictif à partir d'un jeu de données public (dataset *tips* — 244 lignes, 7 colonnes : `total_bill`, `tip`, `sex`, `smoker`, `day`, `time`, `size`).

### Charger un CSV directement depuis une URL

Pas besoin de télécharger le fichier localement — `read_csv` accepte un lien direct, à la manière d'un `IMPORTDATA` sur Google Sheets :

```python
df = pd.read_csv("https://.../tips.csv")
```

> [!note] Limite pratique
> Fonctionne bien pour un lien de téléchargement direct (type raw GitHub, Kaggle...) ; les liens Google Drive posent parfois problème.

### Explorer

```python
df.shape        # (244, 7)
df.head()       # 5 premières lignes (paramétrable : df.head(10), df.head(3)...)
df.tail()
df.dtypes
df.info()       # + complet que dtypes : ajoute le nombre de valeurs non nulles
df.describe()   # stats descriptives, colonnes numériques uniquement
```

### Valeurs uniques et comptage — trois méthodes pour la même question

**Question posée : combien de valeurs possibles dans `smoker` et `time` ?**

```python
df["smoker"].unique()   # array(['No', 'Yes'])
df["time"].unique()     # array(['Dinner', 'Lunch'])
```

**Question posée : combien de personnes sont venues déjeuner (`time == "Lunch"`) ?**

Trois façons d'arriver au même résultat (68) :

```python
# Méthode 1 — masque booléen + .sum() (True vaut 1, False vaut 0)
(df["time"] == "Lunch").sum()

# Méthode 2 — masque booléen + filtrage + .shape
df[df["time"] == "Lunch"].shape[0]

# Méthode 3 — value_counts, puis sélection de la valeur qui intéresse
df["time"].value_counts()["Lunch"]
```

> [!tip] "Il n'y a pas de one-liner absolu"
> Le formateur insiste : peu importe si vous ne connaissez pas les trois méthodes, l'essentiel est d'en maîtriser une. Mieux vaut du code lisible en plusieurs lignes qu'une syntaxe condensée mal comprise. Voir la fiche [[codex/python/Masque booléen (Pandas & NumPy)|Masque booléen (Pandas & NumPy)]] pour le détail du principe `True=1 / False=0`.

> [!warning] Piège rencontré en live : `df["Dinner"]` → `KeyError`
> Une tentative de filtrage directe avec `df["Dinner"]` échoue : entre crochets simples, Pandas attend un **nom de colonne**, pas une valeur d'une colonne. `Dinner` est une valeur de la colonne `time`, pas un intitulé de colonne existant — d'où l'erreur. Décomposer en pseudo-code *avant* de coder (ici : "compter" + "filtrer sur Lunch") aide à éviter ce genre de confusion.

### Créer une colonne calculée arrondie

```python
df["avg_per_person"] = round(df["total_bill"] / df["size"], 2)
```

### Autre agrégation simple

```python
df["total_bill"].max()
```

---

## 15. Bonnes pratiques retenues

- Toujours importer les librairies en début de notebook — une erreur `NameError: name 'np' is not defined` signale quasi systématiquement un import manquant ou une cellule d'import non exécutée
- `Shift + Tab` dans Jupyter affiche la documentation dynamique (docstring) d'une fonction — utile pour ne pas chercher systématiquement en ligne
- Construire le code de manière itérative : tester une expression **avant** de l'assigner à une variable, plutôt que d'écrire variable + logique d'un coup
- Préférer la lisibilité (plusieurs lignes explicites) à la concision (*one-liner*) tant que la maîtrise n'est pas acquise
- SQL reste souvent privilégié en **production** (mise à jour quotidienne via un orchestrateur type dbt) ; Python/Pandas excelle pour l'**analyse exploratoire** et les traitements ad hoc/one-shot

---

## ✅ Actions post-session

- [ ] **Toi** : réaliser les 3 challenges du jour (DataFrame Basics + 2 cas d'analyse) — matériel de pratique directement lié à ce chapitre
- [ ] **Toi** : privilégier les tickets aux questions à main levée pour un meilleur suivi pédagogique
- [ ] *(Formateur)* Envoi du notebook mis à jour aux étudiants — à récupérer si pas encore reçu
- [ ] *(Formateur)* Doit revenir sur la référence de l'exercice CSV de la veille mentionnée par un étudiant

---

## 🧾 Corrections & remarques sur la source

- **Fiabilité du transcript** : la transcription audio brute contient de nombreux artefacts de reconnaissance vocale (ex. "orifice" pour DataFrame, "df.cat" pour `df_concat`, "trou"/"vrai" pour `True`, "MathMotiv" pour "de toute façon"). Ce chapitre s'appuie prioritairement sur les deux blocs de notes structurées (fiables) et sur les 44 captures d'écran ; la transcription brute n'a servi qu'à retrouver le fil pédagogique et le contexte des questions/réponses en live.
- **Coquille mineure côté slide** : le titre de section "Agregation operations" (capture) omet un "g" — orthographe correcte : *Aggregation*. Aucun impact sur le contenu.
- **Aucune erreur de calcul repérée** dans les exemples chiffrés des captures (sommes, moyennes, groupby, pivot, merges) — tous les résultats affichés ont été revérifiés manuellement et sont cohérents avec les données sources.
- **Contenu ajouté au-delà du transcript** : le tableau de comparaison `NaN`/`None`/`NULL`, la mise en perspective avec le principe *aggregate before divide* déjà présent au vault, le lien entre `.iloc` et la convention d'exclusion de `arange`/`range`, et la note sur `df.dtypes` retournant elle-même un `dtype: object`.

---

🔗 Voir aussi : [[wagon2321/cours/26_python_intro|Intro Python]] · [[codex/python/Masque booléen (Pandas & NumPy)|Masque booléen (Pandas & NumPy)]] · [[codex/python/loc vs iloc (Pandas)|loc vs iloc (Pandas)]]
