# 📝 05 – SQL : User-Defined Functions & Window Functions

> **Objectif du chapitre :** comprendre et maîtriser les **Window Functions**, l'un des outils SQL les plus importants pour l'analyse de données : agréger, comparer, classer, distribuer des métriques et naviguer entre les lignes **sans perdre la granularité du dataset**.
>
> Le cours commence également par les **User-Defined Functions (UDFs)** BigQuery, qui permettent d'encapsuler une logique métier réutilisable.

---

# 🧭 0. Pourquoi ce chapitre est important ?

Jusqu'ici, plusieurs outils permettent déjà de transformer des données :

```text
CASE WHEN
GROUP BY
JOIN
CTE
subquery
fonctions natives
```

Mais une difficulté revient souvent :

> **Comment calculer une information agrégée tout en gardant le détail de chaque ligne ?**

Exemple :

```text
model              model_type   stock_value
-----------------  -----------  -----------
T-shirt Liberty    T-shirt             5400
T-shirt Nature     T-shirt             2950
T-shirt Mountainer T-shirt                0
T-shirt Sea lover  T-shirt             3200
Leggin Confort     Legging             4000
Leggin Sport       Legging             5200
```

On peut facilement calculer :

```text
stock total = 20 750
```

avec :

```sql
SELECT
  SUM(stock_value) AS stock_global
FROM circle_stock;
```

Mais cette requête retourne :

```text
1 seule ligne
```

On a perdu :

```text
model
model_type
stock_value
```

Or on pourrait vouloir :

```text
model              stock_value   stock_global
-----------------  -----------   ------------
T-shirt Liberty           5400          20750
T-shirt Nature            2950          20750
T-shirt Mountainer           0          20750
T-shirt Sea lover         3200          20750
Leggin Confort            4000          20750
Leggin Sport              5200          20750
```

C'est exactement le terrain des **Window Functions**.

---

# 🧠 1. La phrase à retenir

```text
GROUP BY
→ agrège les lignes
→ réduit la granularité

WINDOW FUNCTION
→ calcule sur plusieurs lignes
→ retourne un résultat pour chaque ligne
→ conserve la granularité
```

Cette distinction est le cœur du chapitre.

---

# 🗺 2. Position du chapitre dans le Brocode

```text
JOINs
   ↓
Granularité
   ↓
CTEs / Subqueries
   ↓
User-Defined Functions
   ↓
WINDOW FUNCTIONS
   ├── agrégation
   ├── proportion
   ├── ranking
   ├── navigation
   └── distribution de métriques
```

Les Window Functions sont donc directement liées aux chapitres précédents sur :

```text
GROUP BY
JOIN
granularité
CTE
SAFE_DIVIDE
```

---

# ============================================================
# PARTIE I — USER-DEFINED FUNCTIONS (UDFs)
# ============================================================

# 🧰 3. Fonction native vs fonction personnalisée

Depuis le début du module SQL, on utilise des fonctions natives BigQuery :

```sql
SUM()
AVG()
ROUND()
FLOOR()
SAFE_DIVIDE()
COUNT()
```

Exemple :

```sql
ROUND(SAFE_DIVIDE(margin, turnover), 3)
```

Ces fonctions sont fournies par BigQuery.

Une **User-Defined Function**, ou **UDF**, permet de créer sa propre fonction.

```text
fonction native
=
définie par BigQuery

UDF
=
définie par nous
```

---

# 🧱 4. Structure générale d'une UDF SQL

Syntaxe simple :

```sql
CREATE OR REPLACE FUNCTION dataset.function_name(
  parameter_1 TYPE,
  parameter_2 TYPE
)
AS (
  expression
);
```

Exemple du cours :

```sql
CREATE OR REPLACE FUNCTION course17.margin(
  turnover FLOAT64,
  purchase_cost FLOAT64
)
AS (
  turnover - purchase_cost
);
```

---

# 🔬 5. Anatomie de la fonction

```sql
CREATE OR REPLACE FUNCTION course17.margin(
  turnover FLOAT64,
  purchase_cost FLOAT64
)
AS (
  turnover - purchase_cost
);
```

Décomposition :

```text
CREATE OR REPLACE FUNCTION
│
├── course17
│      └── dataset
│
├── margin
│      └── nom de la fonction
│
├── turnover FLOAT64
│      ├── nom du paramètre
│      └── type attendu
│
├── purchase_cost FLOAT64
│      ├── nom du paramètre
│      └── type attendu
│
└── turnover - purchase_cost
       └── corps de la fonction
```

---

# 🏗 6. `CREATE` vs `CREATE OR REPLACE`

Si on écrit :

```sql
CREATE FUNCTION course17.margin(...)
```

et que la fonction existe déjà, BigQuery peut renvoyer une erreur.

Pendant le développement, on utilise souvent :

```sql
CREATE OR REPLACE FUNCTION
```

Cela signifie :

```text
si elle n'existe pas
→ créer

si elle existe
→ remplacer sa définition
```

---

# 📍 7. Où est stockée une UDF persistante ?

Une fonction persistante est un **objet du dataset**.

Structure BigQuery :

```text
Project
└── Dataset
    ├── Tables
    ├── Views
    └── Routines
        ├── margin
        ├── ratio
        └── age_category
```

Une fonction n'appartient donc pas à une table.

Elle peut ensuite être appelée sur différentes tables tant que :

```text
les arguments fournis
sont compatibles avec
les paramètres attendus
```

---

# 📞 8. Appeler une UDF

Après avoir créé :

```sql
CREATE OR REPLACE FUNCTION course17.margin(
  turnover FLOAT64,
  purchase_cost FLOAT64
)
AS (
  turnover - purchase_cost
);
```

on peut écrire :

```sql
SELECT
  orders_id,
  turnover,
  purchase_cost,
  course17.margin(turnover, purchase_cost) AS margin
FROM orders;
```

Le moteur effectue conceptuellement :

```text
pour chaque ligne
↓
prendre turnover
↓
prendre purchase_cost
↓
passer les deux valeurs à margin()
↓
retourner turnover - purchase_cost
```

---

# 🧠 9. Les noms des colonnes n'ont pas besoin de correspondre aux paramètres

Supposons :

```sql
CREATE OR REPLACE FUNCTION course17.margin(
  x FLOAT64,
  y FLOAT64
)
AS (
  x - y
);
```

On peut appeler :

```sql
course17.margin(turnover, purchase_cost)
```

ou :

```sql
course17.margin(revenue, cost)
```

Les noms :

```text
x
y
```

sont des **variables locales à la fonction**.

BigQuery ne cherche pas des colonnes nommées `x` et `y`.

Il reçoit simplement :

```text
argument 1
argument 2
```

---

# ⚠️ 10. L'ordre des arguments compte

Avec :

```sql
margin(turnover, purchase_cost)
```

on calcule :

```text
turnover - purchase_cost
```

Mais :

```sql
margin(purchase_cost, turnover)
```

calcule :

```text
purchase_cost - turnover
```

La fonction ne comprend pas l'intention métier.

Elle applique strictement la logique définie.

---

# 🔢 11. Types de paramètres

Exemple :

```sql
CREATE OR REPLACE FUNCTION course17.segment(
  nb_orders INT64
)
AS (
  ...
);
```

BigQuery vérifie la compatibilité des types.

Types très courants :

```text
INT64
FLOAT64
NUMERIC
STRING
BOOL
DATE
DATETIME
TIMESTAMP
ARRAY<...>
STRUCT<...>
```

---

# 🧠 12. Complément Brocode — `ANY TYPE`

BigQuery permet également des paramètres génériques :

```sql
CREATE TEMP FUNCTION my_function(
  x ANY TYPE
)
AS (
  ...
);
```

`ANY TYPE` permet d'accepter plusieurs types possibles.

Exemple conceptuel :

```sql
CREATE TEMP FUNCTION last_element(arr ANY TYPE)
AS (
  arr[ORDINAL(ARRAY_LENGTH(arr))]
);
```

Cela devient intéressant pour créer des outils très génériques.

Pour les fonctions métier simples, un type explicite reste souvent préférable :

```sql
FLOAT64
INT64
DATE
STRING
```

car le contrat de la fonction est immédiatement lisible.

---

# 🧪 13. Exemple : catégoriser une date de naissance

Le cours utilise une UDF qui encapsule un `CASE WHEN`.

Version nettoyée :

```sql
CREATE OR REPLACE FUNCTION course17.age_category(
  birth_date DATE
)
AS (
  CASE
    WHEN birth_date < DATE '1980-01-01' THEN 'wise'
    WHEN birth_date < DATE '1990-01-01' THEN 'medium'
    WHEN birth_date < DATE '2000-01-01' THEN 'young'
    ELSE 'child'
  END
);
```

Puis :

```sql
SELECT
  customer_id,
  birth_date,
  course17.age_category(birth_date) AS age_category
FROM people;
```

---

# 💡 14. Pourquoi créer cette fonction ?

Sans UDF :

```sql
SELECT
  customer_id,
  birth_date,
  CASE
    WHEN birth_date < DATE '1980-01-01' THEN 'wise'
    WHEN birth_date < DATE '1990-01-01' THEN 'medium'
    WHEN birth_date < DATE '2000-01-01' THEN 'young'
    ELSE 'child'
  END AS age_category
FROM people;
```

Avec UDF :

```sql
SELECT
  customer_id,
  birth_date,
  course17.age_category(birth_date) AS age_category
FROM people;
```

La logique métier devient :

```text
centralisée
réutilisable
plus facile à maintenir
```

---

# 🧩 15. Exemple : fonction de segmentation

```sql
CREATE OR REPLACE FUNCTION course17.segment(
  nb_orders INT64
)
AS (
  CASE
    WHEN nb_orders = 0 THEN 'Prospect'
    WHEN nb_orders = 1 THEN 'New'
    WHEN nb_orders IN (2, 3) THEN 'Occasional'
    WHEN nb_orders > 3 THEN 'Frequent'
    ELSE NULL
  END
);
```

Utilisation :

```sql
SELECT
  customer_id,
  nb_orders,
  course17.segment(nb_orders) AS customer_segment
FROM customers;
```

---

# ♻️ 16. Standardiser une opération répétitive

Exemple du cours :

```sql
CREATE OR REPLACE FUNCTION course17.ratio(
  numerator FLOAT64,
  denominator FLOAT64
)
AS (
  ROUND(
    SAFE_DIVIDE(numerator, denominator),
    3
  )
);
```

Puis :

```sql
SELECT
  orders_id,
  turnover,
  margin,
  course17.ratio(margin, turnover) AS margin_percentage
FROM sales;
```

Et ailleurs :

```sql
SELECT
  email,
  opening,
  click,
  course17.ratio(click, opening) AS ctr
FROM mail;
```

Même fonction :

```text
margin / turnover
click / opening
```

car le concept général est :

```text
numérateur / dénominateur
```

---

# ⚠️ 17. Correction importante — ne pas arrondir trop tôt

L'exemple pédagogique du cours encapsule :

```sql
ROUND(SAFE_DIVIDE(...), 3)
```

Mais si le ratio sert ensuite à **distribuer une métrique**, arrondir à ce stade peut créer une erreur de conservation.

Exemple :

```text
0.609137...
+
0.390862...
=
1
```

Si on arrondit trop tôt :

```text
0.609 + 0.391 = 1.000
```

ici tout va bien.

Mais avec de nombreux éléments :

```text
0.333
+ 0.333
+ 0.333
=
0.999
```

Le total n'est plus exactement égal à `1`.

### Principe Brocode

```text
calculer avec la précision complète
↓
agréger / distribuer
↓
ROUND uniquement pour l'affichage final
```

---

# ✅ 18. UDF : cas d'usage adaptés

Créer une UDF quand une logique est :

```text
répétitive
stable
réutilisable
générique
métier
```

Exemples :

```text
ratio sécurisé
segmentation standard
normalisation de texte
catégorie d'âge
conversion métier
score métier
```

---

# 🚫 19. Quand ne PAS créer une UDF

Éviter une UDF pour :

```text
un calcul utilisé une seule fois
une logique extrêmement spécifique
un traitement expérimental
une règle métier encore instable
```

Une fonction ajoute aussi :

```text
une dépendance
un objet à documenter
un objet à maintenir
```

---

# 🧾 20. UDF temporaire vs persistante

BigQuery permet deux grandes formes.

## Temporaire

```sql
CREATE TEMP FUNCTION ...
```

Elle existe seulement pendant la requête / session concernée.

## Persistante

```sql
CREATE FUNCTION dataset.function_name(...)
```

Elle est créée dans un dataset et peut être réutilisée plus tard.

```text
TEMP FUNCTION
→ locale / éphémère

persistent UDF
→ objet réutilisable du dataset
```

---

# ============================================================
# PARTIE II — WINDOW FUNCTIONS
# ============================================================

# 🪟 21. Qu'est-ce qu'une Window Function ?

Une Window Function calcule une valeur sur un **ensemble de lignes reliées à la ligne courante**, appelé une **window**.

Syntaxe :

```sql
FUNCTION(...) OVER (...)
```

Exemple :

```sql
SUM(stock_value) OVER ()
```

Le mot-clé fondamental est :

```text
OVER
```

Il indique :

> « Utilise cette fonction comme une fonction analytique sur une fenêtre de lignes. »

---

# 🎯 22. Aggregate Function vs Window Function

## Agrégation classique

```sql
SELECT
  SUM(stock_value) AS stock_global
FROM circle_stock;
```

Résultat :

```text
stock_global
------------
20750
```

---

## Window Function

```sql
SELECT
  model,
  model_type,
  stock_value,
  SUM(stock_value) OVER () AS stock_global
FROM circle_stock;
```

Résultat :

```text
model              type      stock   stock_global
-----------------  --------  ------  ------------
T-shirt Liberty    T-shirt     5400         20750
T-shirt Nature     T-shirt     2950         20750
T-shirt Mountainer T-shirt        0         20750
T-shirt Sea lover  T-shirt     3200         20750
Leggin Confort     Legging     4000         20750
Leggin Sport       Legging     5200         20750
```

La somme existe **sur chaque ligne**.

---

# 🧠 23. Modèle mental

Pense à une Window Function comme à une caméra placée sur chaque ligne.

```text
ligne actuelle
     │
     ▼
┌───────────────────────────────┐
│ fenêtre de lignes observées   │
│                               │
│ row 1                         │
│ row 2                         │
│ row 3   ← calcul              │
│ row 4                         │
│ row 5                         │
└───────────────────────────────┘
     │
     ▼
1 valeur retournée
pour la ligne actuelle
```

Pour chaque ligne, BigQuery :

```text
1. détermine sa fenêtre
2. exécute la fonction sur cette fenêtre
3. écrit le résultat sur cette ligne
```

---

# 🧱 24. Anatomie générale

```sql
FUNCTION(expression)
OVER (
  PARTITION BY ...
  ORDER BY ...
  ROWS BETWEEN ...
)
```

On peut lire :

```text
FUNCTION
→ que calculer ?

PARTITION BY
→ dans quel groupe ?

ORDER BY
→ dans quel ordre ?

ROWS / RANGE
→ quelles lignes autour de la ligne actuelle ?
```

---

# ⭐ 25. Les quatre pièces à connaître

```text
FUNCTION
OVER
PARTITION BY
ORDER BY
```

Puis, à un niveau plus avancé :

```text
WINDOW FRAME
→ ROWS / RANGE
```

---

# 🪟 26. `OVER ()` sans instruction

```sql
SUM(stock_value) OVER ()
```

Ici :

```text
PARTITION BY absent
ORDER BY absent
frame absent
```

La fenêtre contient toutes les lignes de l'entrée.

```text
row 1 ─┐
row 2  │
row 3  ├── SUM = total global
row 4  │
row 5  │
row 6 ─┘
```

Puis le total est répété sur chaque ligne.

---

# 📊 27. Agrégation globale sans perdre le détail

```sql
SELECT
  model,
  model_type,
  stock_value,
  SUM(stock_value) OVER () AS stock_global
FROM circle_stock;
```

C'est l'équivalent analytique de :

```text
calculer le total global
+
le rattacher à chaque ligne
```

sans écrire :

```text
CTE
+
JOIN
```

---

# 🧩 28. `PARTITION BY`

Supposons :

```text
T-shirt
T-shirt
T-shirt
T-shirt
Legging
Legging
```

On souhaite calculer le total indépendamment dans chaque groupe.

```sql
SUM(stock_value)
OVER (
  PARTITION BY model_type
)
```

---

# 🧠 29. Mental model de `PARTITION BY`

```text
table
│
├── partition T-shirt
│   ├── Liberty
│   ├── Nature
│   ├── Mountainer
│   └── Sea lover
│
└── partition Legging
    ├── Confort
    └── Sport
```

BigQuery calcule :

```text
SUM(T-shirts)
```

indépendamment de :

```text
SUM(Leggings)
```

---

# 📊 30. Exemple complet

```sql
SELECT
  model,
  model_type,
  stock_value,
  SUM(stock_value)
    OVER (
      PARTITION BY model_type
    ) AS stock_model_type
FROM circle_stock;
```

Résultat :

```text
model              type      stock   stock_model_type
-----------------  --------  ------  ----------------
T-shirt Liberty    T-shirt     5400             11550
T-shirt Nature     T-shirt     2950             11550
T-shirt Mountainer T-shirt        0             11550
T-shirt Sea lover  T-shirt     3200             11550
Leggin Confort     Legging     4000              9200
Leggin Sport       Legging     5200              9200
```

---

# 🔑 31. `GROUP BY` vs `PARTITION BY`

## `GROUP BY`

```sql
SELECT
  model_type,
  SUM(stock_value) AS stock_model_type
FROM circle_stock
GROUP BY model_type;
```

Résultat :

```text
model_type   stock_model_type
-----------  ----------------
T-shirt                 11550
Legging                  9200
```

Granularité :

```text
1 ligne = 1 model_type
```

---

## `PARTITION BY`

```sql
SELECT
  model,
  model_type,
  stock_value,
  SUM(stock_value)
    OVER (PARTITION BY model_type) AS stock_model_type
FROM circle_stock;
```

Granularité :

```text
1 ligne = 1 model
```

---

# 🧠 32. Mémo essentiel

```text
GROUP BY
=
change la granularité

PARTITION BY
=
définit des groupes de calcul
sans supprimer les lignes
```

---

# ⚠️ 33. Correction de vocabulaire importante : partition ≠ frame

Certaines slides présentent :

```text
PARTITION BY
→ determines the window frame width
```

Pour construire une intuition au début, cela aide à comprendre que `PARTITION BY` limite le groupe.

Mais techniquement :

```text
PARTITION
≠
WINDOW FRAME
```

### Partition

```sql
PARTITION BY model_type
```

découpe les lignes en groupes indépendants.

### Window frame

```sql
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
```

sélectionne un sous-ensemble **à l'intérieur d'une partition** autour de la ligne courante.

Mentalement :

```text
PARTITION
└── contient plusieurs lignes
    └── FRAME
        └── portion de la partition utilisée pour ce calcul
```

Cette différence deviendra essentielle pour :

```text
running total
moving average
FIRST_VALUE / LAST_VALUE
```

---

# 🧩 34. Plusieurs colonnes dans `PARTITION BY`

On peut écrire :

```sql
SUM(turnover)
OVER (
  PARTITION BY customer_id, year
)
```

Cela crée des partitions selon la combinaison :

```text
customer_id + year
```

Exemple :

```text
Brice + 2025
Brice + 2026
Alice + 2025
Alice + 2026
```

Chaque combinaison est une partition indépendante.

---

# 🚫 35. Partitionner sur une clé unique

Supposons :

```text
product_id
```

est une vraie Primary Key.

Alors :

```sql
SUM(stock_value)
OVER (
  PARTITION BY product_id
)
```

est généralement inutile.

Pourquoi ?

Parce que chaque partition ne contient qu'une ligne :

```text
SUM(5400) = 5400
SUM(2950) = 2950
...
```

La Window Function reproduit simplement la valeur d'origine.

---

# 📈 36. Calculer une proportion du total global

Objectif :

> Quelle part du stock total représente chaque modèle ?

Formule :

```text
stock_value
────────────
stock_global
```

Avec Window Function :

```sql
SELECT
  model,
  model_type,
  stock_value,
  SAFE_DIVIDE(
    stock_value,
    SUM(stock_value) OVER ()
  ) AS p_global
FROM circle_stock;
```

---

# 📊 37. Calculer une proportion dans la catégorie

Objectif :

> Quelle part du stock de son `model_type` représente chaque modèle ?

```sql
SELECT
  model,
  model_type,
  stock_value,
  SAFE_DIVIDE(
    stock_value,
    SUM(stock_value)
      OVER (PARTITION BY model_type)
  ) AS p_model_type
FROM circle_stock;
```

---

# 🧮 38. Les deux ratios en une requête

```sql
SELECT
  model,
  model_type,
  stock_value,

  SAFE_DIVIDE(
    stock_value,
    SUM(stock_value) OVER ()
  ) AS p_global,

  SAFE_DIVIDE(
    stock_value,
    SUM(stock_value)
      OVER (PARTITION BY model_type)
  ) AS p_model_type

FROM circle_stock;
```

---

# 🧠 39. Pourquoi la Window Function est particulièrement adaptée

Sans Window Function, pour calculer :

```text
stock_value / total_par_model_type
```

il faudrait généralement :

```text
1. GROUP BY model_type
2. calculer SUM(stock_value)
3. créer une CTE
4. JOIN avec la table originale
5. calculer le ratio
```

Avec Window Function :

```sql
stock_value
/
SUM(stock_value)
OVER (PARTITION BY model_type)
```

Une seule expression suffit.

---

# 🔄 40. Équivalence conceptuelle CTE + JOIN

## Version CTE

```sql
WITH stock_by_type AS (
  SELECT
    model_type,
    SUM(stock_value) AS stock_model_type
  FROM circle_stock
  GROUP BY model_type
)

SELECT
  cs.model,
  cs.model_type,
  cs.stock_value,
  sbt.stock_model_type
FROM circle_stock AS cs
INNER JOIN stock_by_type AS sbt
USING (model_type);
```

---

## Version Window Function

```sql
SELECT
  model,
  model_type,
  stock_value,
  SUM(stock_value)
    OVER (PARTITION BY model_type) AS stock_model_type
FROM circle_stock;
```

Même idée analytique :

```text
agréger
+
réattacher le résultat
```

mais sans réduire puis reconstruire la granularité.

---

# ⚖️ 41. CTE + JOIN ou Window Function ?

Il n'existe pas une règle absolue.

### Window Function souvent préférable quand :

```text
je veux conserver les lignes originales
+
ajouter une mesure calculée sur leur groupe
```

### GROUP BY souvent préférable quand :

```text
je veux réellement produire une table agrégée
```

### CTE + JOIN reste pertinent quand :

```text
la logique d'agrégation est complexe
la table intermédiaire est utile conceptuellement
plusieurs transformations doivent être isolées
```

La bonne question est donc :

> **Quelle granularité doit avoir mon résultat final ?**

---

# ============================================================
# PARTIE III — SORTING & RANKING
# ============================================================

# 🏁 42. `ORDER BY` à l'intérieur de `OVER`

Les Window Functions de classement utilisent souvent :

```sql
ORDER BY
```

dans la fenêtre.

Exemple :

```sql
ROW_NUMBER()
OVER (
  ORDER BY stock_value DESC
)
```

Cela signifie :

```text
utiliser stock_value DESC
pour déterminer les numéros de lignes
```

---

# ⚠️ 43. `ORDER BY` dans `OVER` ≠ tri de l'output

C'est un piège essentiel.

Cette requête :

```sql
SELECT
  model,
  stock_value,
  ROW_NUMBER()
    OVER (ORDER BY stock_value DESC) AS rn_global
FROM circle_stock;
```

garantit que :

```text
rn_global = 1
```

correspond à la plus grande `stock_value`.

Mais elle ne garantit pas que la table finale sera affichée :

```text
1
2
3
4
5
6
```

dans cet ordre.

Pour trier le résultat :

```sql
SELECT
  model,
  stock_value,
  ROW_NUMBER()
    OVER (ORDER BY stock_value DESC) AS rn_global
FROM circle_stock
ORDER BY stock_value DESC;
```

Il y a donc deux `ORDER BY` conceptuellement différents :

```text
ORDER BY dans OVER
→ logique du calcul analytique

ORDER BY final
→ ordre d'affichage du résultat
```

---

# 🔢 44. `ROW_NUMBER()`

```sql
ROW_NUMBER()
OVER (
  ORDER BY stock_value DESC
)
```

attribue un entier unique :

```text
1
2
3
4
5
6
...
```

Exemple :

```sql
SELECT
  model,
  model_type,
  stock_value,
  ROW_NUMBER()
    OVER (
      ORDER BY stock_value DESC
    ) AS rn_global
FROM circle_stock;
```

---

# 🧠 45. Mental model de `ROW_NUMBER`

Supposons :

```text
stock_value
-----------
5400
5200
4000
3200
2950
0
```

Alors :

```text
stock   row_number
-----   ----------
5400         1
5200         2
4000         3
3200         4
2950         5
0            6
```

---

# ⚠️ 46. `ROW_NUMBER` ne gère pas les ex æquo

Supposons :

```text
5200
5200
4000
```

`ROW_NUMBER` produit nécessairement :

```text
5200 → 1
5200 → 2
4000 → 3
```

Les deux lignes à `5200` sont égales sur le critère métier, mais `ROW_NUMBER` doit quand même leur donner deux numéros différents.

---

# 🎲 47. Tie-breaker : rendre `ROW_NUMBER` déterministe

Si deux lignes ont la même `stock_value`, leur ordre relatif peut être non déterministe si aucun autre critère n'est fourni.

Éviter :

```sql
ROW_NUMBER()
OVER (
  ORDER BY stock_value DESC
)
```

si les égalités sont possibles et que le résultat doit être reproductible.

Préférer :

```sql
ROW_NUMBER()
OVER (
  ORDER BY
    stock_value DESC,
    model ASC
)
```

On définit alors :

```text
critère 1 = stock_value
critère 2 = model
```

---

# 🧩 48. Ranking par catégorie

On peut recommencer le classement dans chaque `model_type`.

```sql
SELECT
  model,
  model_type,
  stock_value,
  ROW_NUMBER()
    OVER (
      PARTITION BY model_type
      ORDER BY stock_value DESC
    ) AS rn_model_type
FROM circle_stock;
```

Mentalement :

```text
T-shirt
  Liberty      → 1
  Sea lover    → 2
  Nature       → 3
  Mountainer   → 4

Legging
  Sport        → 1
  Confort      → 2
```

Le compteur redémarre à `1` à chaque partition.

---

# 🧠 49. Lire une Window Function de droite à gauche

Pour :

```sql
ROW_NUMBER()
OVER (
  PARTITION BY model_type
  ORDER BY stock_value DESC
)
```

lecture humaine :

```text
1. sépare les lignes par model_type
2. dans chaque groupe,
   trie logiquement par stock_value DESC
3. attribue un numéro séquentiel
```

C'est souvent la meilleure manière de déchiffrer une Window Function.

---

# 🥇 50. `RANK()`

`RANK()` gère les égalités.

```sql
RANK()
OVER (
  ORDER BY stock_value DESC
)
```

Exemple :

```text
stock   RANK
-----   ----
5200      1
5200      1
4000      3
3200      4
```

Pourquoi `3` après les deux premières lignes ?

Parce que deux positions ont été occupées au rang `1`.

---

# 🥇 51. `DENSE_RANK()`

```sql
DENSE_RANK()
OVER (
  ORDER BY stock_value DESC
)
```

Exemple :

```text
stock   DENSE_RANK
-----   ----------
5200        1
5200        1
4000        2
3200        3
```

Il n'y a **aucun trou dans les rangs**.

---

# 📊 52. `ROW_NUMBER` vs `RANK` vs `DENSE_RANK`

Pour :

```text
100
100
80
60
60
20
```

on obtient :

| valeur | `ROW_NUMBER` | `RANK` | `DENSE_RANK` |
|---:|---:|---:|---:|
| 100 | 1 | 1 | 1 |
| 100 | 2 | 1 | 1 |
| 80 | 3 | 3 | 2 |
| 60 | 4 | 4 | 3 |
| 60 | 5 | 4 | 3 |
| 20 | 6 | 6 | 4 |

---

# 🧠 53. Raccourci mental

```text
ROW_NUMBER
→ chaque ligne a son propre numéro

RANK
→ égalités partagent le rang
→ trous après les égalités

DENSE_RANK
→ égalités partagent le rang
→ aucun trou
```

---

# 🎯 54. Quel ranking choisir ?

## `ROW_NUMBER`

Question :

```text
Je veux exactement une ligne numéro 1,
une ligne numéro 2,
une ligne numéro 3...
```

Exemple :

```text
déduplication
top 1 strict
choisir une ligne canonique
```

---

## `RANK`

Question :

```text
Je veux représenter une vraie position de classement
avec des ex æquo.
```

Exemple :

```text
compétition
classement commercial
```

---

## `DENSE_RANK`

Question :

```text
Je veux classer les valeurs distinctes
sans trou.
```

Exemple :

```text
niveaux de performance
catégories ordinales
```

---

# 🧪 55. Top 3 avec CTE

Pattern présenté dans le cours :

```sql
WITH ranked_products AS (
  SELECT
    model,
    model_type,
    stock_value,
    ROW_NUMBER()
      OVER (
        ORDER BY stock_value DESC
      ) AS rn_global
  FROM circle_stock
)

SELECT
  *
FROM ranked_products
WHERE rn_global <= 3;
```

Pourquoi la CTE ?

Parce que `rn_global` est calculé dans le `SELECT` interne puis devient une vraie colonne disponible dans la requête externe.

---

# ⭐ 56. Complément BigQuery essentiel : `QUALIFY`

BigQuery possède une clause spécialement conçue pour filtrer les résultats des Window Functions :

```sql
QUALIFY
```

Le Top 3 précédent peut s'écrire :

```sql
SELECT
  model,
  model_type,
  stock_value,
  ROW_NUMBER()
    OVER (
      ORDER BY stock_value DESC
    ) AS rn_global
FROM circle_stock
QUALIFY rn_global <= 3;
```

Beaucoup plus direct.

---

# 🎯 57. Top N par groupe avec `QUALIFY`

Exemple extrêmement courant :

> Top 3 produits de chaque catégorie.

```sql
SELECT
  model,
  model_type,
  stock_value,
  ROW_NUMBER()
    OVER (
      PARTITION BY model_type
      ORDER BY stock_value DESC
    ) AS rn_model_type
FROM circle_stock
QUALIFY rn_model_type <= 3;
```

---

# 🧠 58. `WHERE` vs `QUALIFY`

```text
WHERE
→ filtre les lignes AVANT les Window Functions

QUALIFY
→ filtre APRÈS les Window Functions
```

Ordre logique simplifié BigQuery :

```text
FROM
↓
WHERE
↓
GROUP BY / aggregation
↓
HAVING
↓
WINDOW
↓
QUALIFY
↓
DISTINCT
↓
ORDER BY
↓
LIMIT
```

---

# 🔧 59. Déduplication avec `ROW_NUMBER`

Cas extrêmement courant en Data Analytics / Data Engineering :

```text
customer_id
updated_at
email
```

On possède plusieurs versions du même client et on veut garder la dernière.

```sql
SELECT
  *
FROM customer_history
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY customer_id
  ORDER BY updated_at DESC
) = 1;
```

Lecture :

```text
pour chaque customer_id
↓
ordonner les versions de la plus récente à la plus ancienne
↓
numéroter
↓
garder uniquement la ligne 1
```

C'est l'un des patterns SQL les plus utiles à connaître.

---

# ============================================================
# PARTIE IV — GRANULARITÉ & DISTRIBUTION DE MÉTRIQUES
# ============================================================

# ⚠️ 60. Rappel : joindre deux granularités différentes

Table `sales` :

```text
1 ligne = 1 produit dans une commande
```

```text
orders_id   products_id   turnover
---------   -----------   --------
451         6532              24.0
451         1068              15.4
623         4102              19.4
623         928               24.8
623         6532              12.0
```

Table `orders_operational` :

```text
1 ligne = 1 commande
```

```text
orders_id   log_cost   ship_cost
---------   --------   ---------
451             4.5        7.0
623             3.5        5.0
```

---

# 💥 61. Direct JOIN : duplication

```sql
SELECT
  s.orders_id,
  s.products_id,
  s.turnover,
  o.log_cost,
  o.ship_cost
FROM sales AS s
LEFT JOIN orders_operational AS o
USING (orders_id);
```

Résultat :

```text
451  6532  24.0   4.5  7
451  1068  15.4   4.5  7

623  4102  19.4   3.5  5
623   928  24.8   3.5  5
623  6532  12.0   3.5  5
```

Si on additionne ensuite :

```text
log_cost
```

on obtient :

```text
451
4.5 + 4.5 = 9
```

alors que le vrai coût de la commande est :

```text
4.5
```

---

# 🧱 62. Première solution : agréger puis joindre

Si le résultat final doit avoir :

```text
1 ligne = 1 order
```

on peut d'abord réduire `sales` :

```sql
WITH orders AS (
  SELECT
    orders_id,
    SUM(turnover) AS turnover
  FROM sales
  GROUP BY orders_id
)

SELECT
  o.orders_id,
  o.turnover,
  op.log_cost,
  op.ship_cost
FROM orders AS o
LEFT JOIN orders_operational AS op
USING (orders_id);
```

C'est le pattern du chapitre précédent.

---

# 🎯 63. Mais que faire si on veut garder la granularité produit ?

Supposons que le besoin métier soit :

```text
je veux conserver
1 ligne = 1 produit

ET

je veux attribuer à chaque produit
sa part des coûts de la commande
```

On ne peut pas simplement agréger par `orders_id`.

On doit **distribuer les coûts**.

---

# 📐 64. Étape 1 — calculer la part du turnover

Pour chaque ligne :

```text
turnover de la ligne
────────────────────
turnover total de la commande
```

Window Function :

```sql
SAFE_DIVIDE(
  turnover,
  SUM(turnover)
    OVER (PARTITION BY orders_id)
)
```

---

# 🧮 65. Exemple pour la commande 451

Données :

```text
product   turnover
-------   --------
6532          24.0
1068          15.4
```

Total :

```text
24 + 15.4 = 39.4
```

Parts :

```text
24 / 39.4
≈ 60.9 %

15.4 / 39.4
≈ 39.1 %
```

Conservation :

```text
60.9 % + 39.1 %
≈ 100 %
```

---

# 🧩 66. Requête de pondération

```sql
SELECT
  orders_id,
  products_id,
  turnover,
  SAFE_DIVIDE(
    turnover,
    SUM(turnover)
      OVER (PARTITION BY orders_id)
  ) AS turnover_share
FROM sales;
```

---

# 💰 67. Étape 2 — joindre les coûts opérationnels

```sql
WITH sales_percent AS (
  SELECT
    orders_id,
    products_id,
    turnover,
    SAFE_DIVIDE(
      turnover,
      SUM(turnover)
        OVER (PARTITION BY orders_id)
    ) AS turnover_share
  FROM sales
)

SELECT
  sp.orders_id,
  sp.products_id,
  sp.turnover,
  sp.turnover_share,
  op.log_cost,
  op.ship_cost
FROM sales_percent AS sp
LEFT JOIN orders_operational AS op
USING (orders_id);
```

---

# 🧮 68. Étape 3 — distribuer les coûts

```text
allocated_log_cost
=
order_log_cost × turnover_share

allocated_ship_cost
=
order_ship_cost × turnover_share
```

Requête :

```sql
WITH sales_percent AS (
  SELECT
    orders_id,
    products_id,
    turnover,
    SAFE_DIVIDE(
      turnover,
      SUM(turnover)
        OVER (PARTITION BY orders_id)
    ) AS turnover_share
  FROM sales
)

SELECT
  sp.orders_id,
  sp.products_id,
  sp.turnover,
  sp.turnover_share,

  op.log_cost
    * sp.turnover_share AS allocated_log_cost,

  op.ship_cost
    * sp.turnover_share AS allocated_ship_cost

FROM sales_percent AS sp
LEFT JOIN orders_operational AS op
USING (orders_id);
```

---

# 📊 69. Résultat conceptuel

Commande `451` :

```text
product  turnover   share   allocated_log   allocated_ship
-------  --------   -----   -------------   --------------
6532        24.0    60.9%         2.74            4.26
1068        15.4    39.1%         1.76            2.74
```

Conservation :

```text
2.74 + 1.76
≈ 4.50

4.26 + 2.74
≈ 7.00
```

La granularité produit est conservée **et** les coûts restent cohérents.

---

# 🔐 70. Metric conservation

C'est un principe fondamental.

Avant transformation :

```text
commande 451
log_cost = 4.50
```

Après distribution :

```text
SUM(allocated_log_cost)
=
4.50
```

On doit pouvoir reconstruire le total original.

```text
metric conservation
=
la transformation redistribue la valeur
sans en créer ni en détruire
```

---

# 🧪 71. Test de conservation

Après calcul :

```sql
WITH allocated AS (
  ...
)

SELECT
  orders_id,
  SUM(allocated_log_cost) AS reconstructed_log_cost,
  SUM(allocated_ship_cost) AS reconstructed_ship_cost
FROM allocated
GROUP BY orders_id;
```

Comparer avec la source :

```sql
SELECT
  orders_id,
  log_cost,
  ship_cost
FROM orders_operational;
```

Les valeurs doivent correspondre, à la précision numérique près.

---

# ⚠️ 72. Ne jamais arrondir la part avant la distribution

Mauvais :

```sql
ROUND(
  SAFE_DIVIDE(
    turnover,
    SUM(turnover) OVER (PARTITION BY orders_id)
  ),
  2
) AS turnover_share
```

puis :

```text
cost × turnover_share arrondi
```

Avec suffisamment de lignes, on peut casser la conservation.

Préférer :

```sql
SAFE_DIVIDE(
  turnover,
  SUM(turnover) OVER (PARTITION BY orders_id)
) AS turnover_share
```

puis seulement à l'affichage :

```sql
ROUND(allocated_log_cost, 2)
```

---

# 🧠 73. Principe général de distribution

Le pattern fonctionne bien au-delà des coûts logistiques.

```text
valeur à distribuer
×
poids de la ligne
```

avec :

```text
poids de la ligne
=
métrique ligne
/
métrique totale du groupe
```

Applications :

```text
allocation de coûts
budget marketing
revenus
commissions
charges
volume
stock
trafic
attribution
```

---

# 🏦 74. Exemple bancaire

Supposons :

```text
customer_id
account_id
balance
```

On connaît un coût opérationnel au niveau :

```text
customer_id
```

mais on veut l'attribuer aux comptes proportionnellement à leur balance.

```sql
SAFE_DIVIDE(
  balance,
  SUM(balance)
    OVER (PARTITION BY customer_id)
)
```

On conserve :

```text
1 ligne = 1 account
```

tout en redistribuant :

```text
customer_cost
```

au niveau compte.

---

# ============================================================
# PARTIE V — WINDOW FRAMES
# ============================================================

# 🪟 75. Partition et frame : deux niveaux différents

Considérons :

```sql
SUM(amount)
OVER (
  PARTITION BY customer_id
  ORDER BY transaction_date
  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
```

Il y a :

```text
PARTITION
=
toutes les transactions d'un customer

ORDER
=
ordre chronologique

FRAME
=
du début de la partition
jusqu'à la ligne actuelle
```

---

# 📈 76. Running total

Exemple :

```sql
SELECT
  customer_id,
  transaction_date,
  amount,

  SUM(amount) OVER (
    PARTITION BY customer_id
    ORDER BY transaction_date
    ROWS BETWEEN UNBOUNDED PRECEDING
             AND CURRENT ROW
  ) AS cumulative_amount

FROM transactions;
```

Résultat :

```text
date       amount   cumulative
---------  ------   ----------
01/01        100        100
02/01         50        150
03/01        -20        130
04/01         70        200
```

---

# 🧠 77. Lecture du running total

Pour la troisième ligne :

```text
frame
=
ligne 1
+
ligne 2
+
ligne 3
```

Pour la quatrième :

```text
frame
=
ligne 1
+
ligne 2
+
ligne 3
+
ligne 4
```

La fenêtre évolue avec la ligne courante.

---

# 📉 78. Moving average

Moyenne sur la ligne actuelle et les deux précédentes :

```sql
AVG(amount)
OVER (
  ORDER BY transaction_date
  ROWS BETWEEN 2 PRECEDING
           AND CURRENT ROW
)
```

Mentalement :

```text
row 1
→ row 1

row 2
→ row 1 + row 2

row 3
→ row 1 + row 2 + row 3

row 4
→ row 2 + row 3 + row 4
```

---

# 📦 79. Syntaxe courante des frames

```sql
ROWS BETWEEN UNBOUNDED PRECEDING
         AND CURRENT ROW
```

```text
du début
jusqu'à maintenant
```

---

```sql
ROWS BETWEEN 2 PRECEDING
         AND CURRENT ROW
```

```text
2 lignes avant
+
ligne actuelle
```

---

```sql
ROWS BETWEEN 1 PRECEDING
         AND 1 FOLLOWING
```

```text
ligne précédente
+
ligne actuelle
+
ligne suivante
```

---

```sql
ROWS BETWEEN UNBOUNDED PRECEDING
         AND UNBOUNDED FOLLOWING
```

```text
toute la partition
```

---

# ⚠️ 80. `ORDER BY` peut changer le comportement d'un agrégat analytique

Comparer :

```sql
SUM(amount)
OVER (
  PARTITION BY customer_id
)
```

avec :

```sql
SUM(amount)
OVER (
  PARTITION BY customer_id
  ORDER BY transaction_date
)
```

Le premier calcule typiquement :

```text
total complet du customer
```

sur chaque ligne.

Avec un `ORDER BY`, un **window frame** intervient et le comportement peut devenir cumulatif selon la fonction et le frame utilisé.

Pour éviter l'ambiguïté dans les requêtes importantes, écrire explicitement le frame :

```sql
ROWS BETWEEN UNBOUNDED PRECEDING
         AND CURRENT ROW
```

---

# 🧱 81. `ROWS` vs `RANGE`

## `ROWS`

Travaille avec les positions physiques des lignes.

```sql
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
```

signifie :

```text
exactement les 2 lignes précédentes
+
la ligne actuelle
```

---

## `RANGE`

Travaille avec une plage logique autour de la valeur utilisée dans `ORDER BY`.

C'est plus subtil et utile dans certains calculs temporels / numériques.

Pour débuter :

```text
ROWS
=
souvent le plus intuitif
```

---

# ============================================================
# PARTIE VI — NAVIGATION FUNCTIONS
# ============================================================

# 🧭 82. Complément Brocode — naviguer entre les lignes

Les Window Functions ne servent pas uniquement à :

```text
SUM
ranking
```

Elles permettent aussi de récupérer une valeur située :

```text
avant
après
au début
à la fin
```

de la fenêtre.

Fonctions importantes :

```text
LAG
LEAD
FIRST_VALUE
LAST_VALUE
```

---

# ⬅️ 83. `LAG`

`LAG` récupère une valeur d'une ligne précédente.

```sql
SELECT
  customer_id,
  month,
  revenue,

  LAG(revenue) OVER (
    PARTITION BY customer_id
    ORDER BY month
  ) AS previous_revenue

FROM monthly_revenue;
```

Résultat :

```text
month   revenue   previous_revenue
-----   -------   ----------------
Jan         100      NULL
Feb         120       100
Mar          90       120
```

---

# 📈 84. Variation avec `LAG`

```sql
SELECT
  customer_id,
  month,
  revenue,

  revenue
  - LAG(revenue) OVER (
      PARTITION BY customer_id
      ORDER BY month
    ) AS revenue_delta

FROM monthly_revenue;
```

Très utile pour :

```text
MoM
YoY
variation de balance
variation de churn
évolution de KPI
```

---

# ➡️ 85. `LEAD`

`LEAD` récupère la ligne suivante.

```sql
LEAD(revenue)
OVER (
  PARTITION BY customer_id
  ORDER BY month
)
```

Applications :

```text
prochaine transaction
prochaine date
étape suivante
durée jusqu'au prochain événement
```

---

# 1️⃣ 86. `FIRST_VALUE`

```sql
FIRST_VALUE(price)
OVER (
  PARTITION BY product_id
  ORDER BY date
)
```

permet par exemple de récupérer :

```text
le premier prix connu du produit
```

sur chaque ligne.

---

# ⚠️ 87. Piège classique de `LAST_VALUE`

Cette écriture :

```sql
LAST_VALUE(price)
OVER (
  PARTITION BY product_id
  ORDER BY date
)
```

peut ne pas retourner ce que l'on imagine.

Avec le frame par défaut associé à l'ordre, la « dernière » ligne de la fenêtre peut être la ligne courante.

Pour demander explicitement la dernière valeur de toute la partition :

```sql
LAST_VALUE(price)
OVER (
  PARTITION BY product_id
  ORDER BY date
  ROWS BETWEEN UNBOUNDED PRECEDING
           AND UNBOUNDED FOLLOWING
)
```

---

# ============================================================
# PARTIE VII — PATTERNS ANALYTIQUES
# ============================================================

# 🧰 88. Pattern : pourcentage du total

```sql
SELECT
  category,
  item,
  amount,

  SAFE_DIVIDE(
    amount,
    SUM(amount) OVER ()
  ) AS share_global

FROM data;
```

---

# 🧰 89. Pattern : pourcentage dans un groupe

```sql
SELECT
  category,
  item,
  amount,

  SAFE_DIVIDE(
    amount,
    SUM(amount)
      OVER (PARTITION BY category)
  ) AS share_category

FROM data;
```

---

# 🧰 90. Pattern : ranking par groupe

```sql
SELECT
  category,
  item,
  amount,

  ROW_NUMBER() OVER (
    PARTITION BY category
    ORDER BY amount DESC
  ) AS rn

FROM data;
```

---

# 🧰 91. Pattern : Top 1 par groupe

```sql
SELECT
  category,
  item,
  amount

FROM data

QUALIFY ROW_NUMBER() OVER (
  PARTITION BY category
  ORDER BY amount DESC
) = 1;
```

---

# 🧰 92. Pattern : Top 3 avec ex æquo

Si les ex æquo doivent être conservés :

```sql
SELECT
  category,
  item,
  amount

FROM data

QUALIFY RANK() OVER (
  PARTITION BY category
  ORDER BY amount DESC
) <= 3;
```

⚠️ Le résultat peut contenir plus de trois lignes par catégorie si plusieurs lignes partagent un rang.

---

# 🧰 93. Pattern : running total

```sql
SELECT
  date,
  amount,

  SUM(amount) OVER (
    ORDER BY date
    ROWS BETWEEN UNBOUNDED PRECEDING
             AND CURRENT ROW
  ) AS running_total

FROM transactions;
```

---

# 🧰 94. Pattern : moving average

```sql
SELECT
  date,
  amount,

  AVG(amount) OVER (
    ORDER BY date
    ROWS BETWEEN 6 PRECEDING
             AND CURRENT ROW
  ) AS moving_avg_7_rows

FROM transactions;
```

---

# 🧰 95. Pattern : valeur précédente

```sql
SELECT
  date,
  value,

  LAG(value) OVER (
    ORDER BY date
  ) AS previous_value

FROM metrics;
```

---

# 🧰 96. Pattern : déduplication

```sql
SELECT
  *

FROM events

QUALIFY ROW_NUMBER() OVER (
  PARTITION BY event_id
  ORDER BY updated_at DESC
) = 1;
```

---

# 🧰 97. Pattern : distribution avec conservation

```sql
WITH weighted AS (
  SELECT
    group_id,
    item_id,
    metric,

    SAFE_DIVIDE(
      metric,
      SUM(metric)
        OVER (PARTITION BY group_id)
    ) AS weight

  FROM detail
)

SELECT
  w.*,
  g.total_cost,
  w.weight * g.total_cost AS allocated_cost

FROM weighted AS w
LEFT JOIN group_cost AS g
USING (group_id);
```

---

# ============================================================
# PARTIE VIII — PIÈGES & DEBUG
# ============================================================

# 🚨 98. Piège : confondre `GROUP BY` et `PARTITION BY`

Mauvaise intuition :

```text
PARTITION BY
=
un nouveau GROUP BY
```

Meilleure intuition :

```text
GROUP BY
→ transforme plusieurs lignes en une ligne

PARTITION BY
→ indique quelles lignes appartiennent
  au même groupe analytique
```

---

# 🚨 99. Piège : oublier `OVER`

```sql
SUM(stock_value)
```

est une agrégation classique.

```sql
SUM(stock_value) OVER ()
```

est une Window Function.

Le `OVER` change complètement la sémantique.

---

# 🚨 100. Piège : croire que `ORDER BY` dans `OVER` trie le résultat

```sql
ROW_NUMBER() OVER (
  ORDER BY value DESC
)
```

calcule selon cet ordre.

Mais pour afficher les lignes dans cet ordre :

```sql
ORDER BY value DESC
```

doit être ajouté à la requête finale.

---

# 🚨 101. Piège : `ROW_NUMBER` et les ex æquo

```sql
ROW_NUMBER() OVER (
  ORDER BY score DESC
)
```

avec deux scores identiques :

```text
l'un sera 1
l'autre sera 2
```

Si cela pose un problème métier :

```text
RANK
DENSE_RANK
```

peuvent être plus adaptés.

---

# 🚨 102. Piège : résultat non déterministe

```sql
ROW_NUMBER()
OVER (
  PARTITION BY customer_id
  ORDER BY updated_at DESC
)
```

Si deux lignes ont exactement le même `updated_at`, laquelle devient `1` ?

Il faut parfois ajouter un tie-breaker :

```sql
ORDER BY
  updated_at DESC,
  ingestion_id DESC
```

---

# 🚨 103. Piège : partition trop fine

```sql
PARTITION BY primary_key
```

si la clé est unique :

```text
1 ligne par partition
```

La Window Function ne compare plus réellement plusieurs lignes.

---

# 🚨 104. Piège : partition trop large

Si on oublie :

```sql
PARTITION BY customer_id
```

dans :

```sql
SUM(amount) OVER ()
```

on obtient le total de toute la table alors qu'on voulait peut-être le total du customer.

Toujours poser la question :

```text
quelles lignes cette ligne doit-elle "voir" ?
```

---

# 🚨 105. Piège : arrondir avant la fin

Mauvais :

```text
calculer ratio
→ ROUND
→ multiplier
→ SUM
```

Meilleur :

```text
calculer ratio exact
→ multiplier
→ SUM
→ ROUND affichage
```

---

# 🚨 106. Piège : diviser par zéro

Préférer :

```sql
SAFE_DIVIDE(
  numerator,
  denominator
)
```

à :

```sql
numerator / denominator
```

quand le dénominateur peut être `0` ou `NULL`.

---

# 🚨 107. Piège : filtrer avec `WHERE` une valeur analytique

Ceci n'est pas la bonne logique :

```sql
SELECT
  ...,
  ROW_NUMBER() OVER (...) AS rn
FROM table
WHERE rn <= 3;
```

`WHERE` est évalué avant les Window Functions.

Solutions :

```text
CTE + WHERE
```

ou, dans BigQuery :

```text
QUALIFY
```

---

# 🐛 108. Méthode de debug

Face à une Window Function complexe :

### Étape 1 — afficher les colonnes brutes

```sql
SELECT
  group_id,
  value
FROM table;
```

### Étape 2 — ajouter uniquement la Window Function

```sql
SELECT
  group_id,
  value,
  SUM(value) OVER (
    PARTITION BY group_id
  ) AS group_total
FROM table;
```

### Étape 3 — vérifier manuellement un groupe

```text
prendre un group_id
additionner les lignes
comparer
```

### Étape 4 — seulement ensuite calculer le ratio

```sql
SAFE_DIVIDE(value, group_total)
```

### Étape 5 — tester la conservation

```sql
SUM(...)
```

---

# 🧪 109. Tests essentiels

## Test 1 — total global

```sql
SELECT
  SUM(stock_value)
FROM circle_stock;
```

doit correspondre à :

```sql
MAX(stock_global)
```

après :

```sql
SUM(stock_value) OVER () AS stock_global
```

---

## Test 2 — somme des proportions globales

```text
SUM(p_global)
≈
1
```

---

## Test 3 — somme des proportions par groupe

Pour chaque `model_type` :

```text
SUM(p_model_type)
≈
1
```

---

## Test 4 — conservation après distribution

```text
SUM(allocated_cost)
=
original_cost
```

au niveau du groupe.

---

# ============================================================
# PARTIE IX — WINDOW FUNCTIONS AVANCÉES
# ============================================================

# 🪟 110. Named Windows

Quand plusieurs fonctions partagent la même fenêtre :

```sql
SELECT
  customer_id,
  date,
  amount,

  SUM(amount) OVER customer_window AS running_sum,
  AVG(amount) OVER customer_window AS running_avg

FROM transactions

WINDOW customer_window AS (
  PARTITION BY customer_id
  ORDER BY date
  ROWS BETWEEN UNBOUNDED PRECEDING
           AND CURRENT ROW
);
```

Cela évite de répéter :

```text
PARTITION BY
ORDER BY
frame
```

---

# 📦 111. Familles de Window Functions

## Aggregate analytic functions

```text
SUM
AVG
COUNT
MIN
MAX
```

---

## Numbering / ranking

```text
ROW_NUMBER
RANK
DENSE_RANK
NTILE
PERCENT_RANK
CUME_DIST
```

---

## Navigation

```text
LAG
LEAD
FIRST_VALUE
LAST_VALUE
NTH_VALUE
```

---

# 🧠 112. `NTILE` — aperçu

`NTILE` divise les lignes ordonnées en plusieurs groupes.

Exemple :

```sql
NTILE(4)
OVER (
  ORDER BY revenue DESC
)
```

permet de créer :

```text
quartile 1
quartile 2
quartile 3
quartile 4
```

Cette notion est approfondie dans le chapitre Brocode dédié aux :

```text
quartiles
tertiles
NTILE
```

---

# ============================================================
# PARTIE X — QUESTIONS MÉTIER
# ============================================================

# 💼 113. Cas d'usage Data Analyst

Les Window Functions répondent à énormément de questions métier.

### Contribution

```text
Quelle part du CA total vient de ce client ?
```

```sql
revenue / SUM(revenue) OVER ()
```

---

### Contribution dans un segment

```text
Quelle part du CA Premium vient de ce client ?
```

```sql
revenue
/
SUM(revenue)
OVER (PARTITION BY segment)
```

---

### Ranking

```text
Quels sont mes 5 meilleurs clients par pays ?
```

```sql
RANK()
OVER (
  PARTITION BY country
  ORDER BY revenue DESC
)
```

---

### Évolution

```text
Comment le solde a-t-il évolué depuis le mois précédent ?
```

```sql
balance
-
LAG(balance)
OVER (
  PARTITION BY account_id
  ORDER BY month
)
```

---

### Cumul

```text
Quel est le CA cumulé depuis le début de l'année ?
```

```sql
SUM(revenue)
OVER (
  PARTITION BY year
  ORDER BY date
  ROWS BETWEEN UNBOUNDED PRECEDING
           AND CURRENT ROW
)
```

---

### Déduplication

```text
Quelle est la dernière version connue de chaque dossier ?
```

```sql
QUALIFY ROW_NUMBER()
OVER (
  PARTITION BY case_id
  ORDER BY updated_at DESC
) = 1
```

---

# 🏦 114. Exemples banking

Window Functions particulièrement utiles pour :

```text
ranking clients
ranking agences
solde cumulé
variation mensuelle
transaction précédente
transaction suivante
détection de changements
top comptes par client
contribution au portefeuille
segmentation par percentile
déduplication de dossiers
```

Exemple :

```sql
SELECT
  customer_id,
  account_id,
  balance,

  SAFE_DIVIDE(
    balance,
    SUM(balance)
      OVER (PARTITION BY customer_id)
  ) AS share_customer_assets,

  RANK() OVER (
    PARTITION BY customer_id
    ORDER BY balance DESC
  ) AS account_rank

FROM accounts;
```

---

# ============================================================
# PARTIE XI — QUESTIONS D'ENTRETIEN
# ============================================================

# 🎤 115. « Quelle différence entre `GROUP BY` et Window Function ? »

Réponse courte :

> `GROUP BY` réduit plusieurs lignes à une ligne par groupe et modifie donc la granularité. Une Window Function calcule sur un groupe de lignes mais retourne une valeur pour chaque ligne, ce qui permet de conserver la granularité initiale.

---

# 🎤 116. « À quoi sert `PARTITION BY` ? »

> `PARTITION BY` divise les lignes en groupes indépendants pour le calcul analytique. La fonction est recalculée séparément dans chaque partition sans supprimer les lignes.

---

# 🎤 117. « Différence entre `ROW_NUMBER`, `RANK` et `DENSE_RANK` ? »

```text
ROW_NUMBER
→ numéro unique pour chaque ligne

RANK
→ même rang pour les ex æquo
→ trous dans le classement

DENSE_RANK
→ même rang pour les ex æquo
→ aucun trou
```

---

# 🎤 118. « Comment récupérer le Top 3 de chaque catégorie ? »

BigQuery :

```sql
SELECT
  *
FROM products
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY category
  ORDER BY revenue DESC
) <= 3;
```

---

# 🎤 119. « Pourquoi utiliser `QUALIFY` ? »

> `QUALIFY` filtre le résultat d'une Window Function, alors que `WHERE` filtre les lignes avant son évaluation.

---

# 🎤 120. « Pourquoi `ROW_NUMBER` peut-il être non déterministe ? »

> Si plusieurs lignes sont à égalité sur les colonnes du `ORDER BY`, leur ordre relatif n'est pas garanti. On ajoute un tie-breaker supplémentaire pour obtenir un résultat reproductible.

---

# 🎤 121. « Qu'est-ce qu'un window frame ? »

> C'est le sous-ensemble de lignes de la partition utilisé pour calculer la valeur analytique de la ligne courante. Il peut être défini avec `ROWS` ou `RANGE`, par exemple `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`.

---

# 🎤 122. « À quoi sert `LAG` ? »

> `LAG` récupère la valeur d'une ligne précédente dans une fenêtre ordonnée. Il est très utile pour calculer des variations temporelles comme MoM ou comparer une transaction avec la précédente.

---

# 🎤 123. « Window Function ou CTE ? »

> Ce ne sont pas deux outils concurrents. Une CTE structure une requête en étapes nommées, tandis qu'une Window Function effectue un calcul analytique en conservant les lignes. Les deux sont fréquemment utilisés ensemble.

---

# ============================================================
# PARTIE XII — CHEAT SHEET
# ============================================================

# 🧾 124. Total global sur chaque ligne

```sql
SUM(value) OVER ()
```

---

# 🧾 125. Total par groupe sur chaque ligne

```sql
SUM(value)
OVER (
  PARTITION BY group_id
)
```

---

# 🧾 126. Part du total

```sql
SAFE_DIVIDE(
  value,
  SUM(value) OVER ()
)
```

---

# 🧾 127. Part du groupe

```sql
SAFE_DIVIDE(
  value,
  SUM(value)
    OVER (PARTITION BY group_id)
)
```

---

# 🧾 128. Ranking global

```sql
ROW_NUMBER()
OVER (
  ORDER BY value DESC
)
```

---

# 🧾 129. Ranking par groupe

```sql
ROW_NUMBER()
OVER (
  PARTITION BY group_id
  ORDER BY value DESC
)
```

---

# 🧾 130. Rang avec ex æquo + trous

```sql
RANK()
OVER (
  ORDER BY value DESC
)
```

---

# 🧾 131. Rang avec ex æquo sans trous

```sql
DENSE_RANK()
OVER (
  ORDER BY value DESC
)
```

---

# 🧾 132. Top N BigQuery

```sql
SELECT
  *
FROM table
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY group_id
  ORDER BY value DESC
) <= 3;
```

---

# 🧾 133. Running total

```sql
SUM(value)
OVER (
  PARTITION BY group_id
  ORDER BY date
  ROWS BETWEEN UNBOUNDED PRECEDING
           AND CURRENT ROW
)
```

---

# 🧾 134. Moving average

```sql
AVG(value)
OVER (
  ORDER BY date
  ROWS BETWEEN 6 PRECEDING
           AND CURRENT ROW
)
```

---

# 🧾 135. Valeur précédente

```sql
LAG(value)
OVER (
  PARTITION BY group_id
  ORDER BY date
)
```

---

# 🧾 136. Valeur suivante

```sql
LEAD(value)
OVER (
  PARTITION BY group_id
  ORDER BY date
)
```

---

# 🧾 137. Déduplication

```sql
SELECT *
FROM table
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY business_key
  ORDER BY updated_at DESC
) = 1;
```

---

# ============================================================
# PARTIE XIII — SYNTHÈSE
# ============================================================

# 💡 138. Ce que j'ai retenu

- Une Window Function calcule sur plusieurs lignes **sans réduire la granularité**.
- Le mot-clé fondamental est `OVER`.
- `OVER ()` utilise toutes les lignes comme une partition unique.
- `PARTITION BY` sépare les lignes en groupes analytiques indépendants.
- `GROUP BY` réduit les lignes ; `PARTITION BY` les conserve.
- `ORDER BY` dans `OVER` définit l'ordre utilisé par la fonction mais ne garantit pas le tri visuel final.
- `ROW_NUMBER` donne un numéro unique à chaque ligne.
- `RANK` gère les ex æquo avec des trous.
- `DENSE_RANK` gère les ex æquo sans trous.
- `QUALIFY` permet de filtrer directement les résultats des Window Functions dans BigQuery.
- Les Window Functions sont idéales pour les proportions, rankings, running totals, moving averages et déduplications.
- `LAG` / `LEAD` permettent de comparer la ligne actuelle avec une autre ligne temporelle.
- Une Window Function peut remplacer certains patterns `GROUP BY → CTE → JOIN` lorsque le but est de conserver le détail.
- `PARTITION BY` et **window frame** sont deux concepts différents.
- Lors d'une distribution de coûts, la somme des valeurs distribuées doit reconstruire le total source : **metric conservation**.
- Ne jamais arrondir trop tôt une proportion utilisée dans un calcul en aval.

---

# 🧠 139. La question réflexe

Avant chaque Window Function, se demander :

```text
1. Quelle est ma ligne actuelle ?
2. Quelles autres lignes doit-elle "voir" ?
3. Dois-je créer des partitions ?
4. Dans quel ordre ?
5. Ai-je besoin de toute la partition
   ou seulement d'un frame ?
6. Quelle valeur dois-je retourner
   sur chaque ligne ?
```

Si ces six réponses sont claires, la Window Function devient beaucoup plus facile à écrire.

---

# 🗺 140. Carte mentale finale

```text
WINDOW FUNCTION
│
├── OVER
│   │
│   ├── rien
│   │   └── toute la table
│   │
│   ├── PARTITION BY
│   │   └── groupes indépendants
│   │
│   ├── ORDER BY
│   │   └── ordre analytique
│   │
│   └── ROWS / RANGE
│       └── window frame
│
├── AGGREGATION
│   ├── SUM
│   ├── AVG
│   ├── COUNT
│   ├── MIN
│   └── MAX
│
├── RANKING
│   ├── ROW_NUMBER
│   ├── RANK
│   ├── DENSE_RANK
│   └── NTILE
│
├── NAVIGATION
│   ├── LAG
│   ├── LEAD
│   ├── FIRST_VALUE
│   └── LAST_VALUE
│
└── USE CASES
    ├── proportion
    ├── ranking
    ├── top N
    ├── deduplication
    ├── cumulative sum
    ├── moving average
    ├── temporal comparison
    └── metric distribution
```

---

# ❓ 141. Questions / points à garder en tête

- [ ] Quand utiliser un `window frame` explicite plutôt que le comportement par défaut ?
- [ ] Dans quels cas `ROWS` et `RANGE` produisent-ils des résultats différents ?
- [ ] Comment choisir un tie-breaker stable pour `ROW_NUMBER()` ?
- [ ] Quand choisir `RANK()` plutôt que `DENSE_RANK()` ?
- [ ] Comment appliquer `LAG()` sur des périodes manquantes ?
- [ ] Comment dédupliquer efficacement une grosse table BigQuery ?
- [ ] Comment tester automatiquement la conservation d'une métrique distribuée ?
- [ ] Quand matérialiser une transformation plutôt que recalculer une Window Function ?

---

# ✅ 142. Actions post-session

- [ ] Refaire à la main `GROUP BY` vs `SUM() OVER(PARTITION BY ...)`.
- [ ] Reproduire `ROW_NUMBER`, `RANK`, `DENSE_RANK` sur un dataset avec ex æquo.
- [ ] Écrire un Top 3 par catégorie avec `QUALIFY`.
- [ ] Écrire une déduplication `ROW_NUMBER() ... = 1`.
- [ ] Construire un running total.
- [ ] Tester `LAG()` sur une série mensuelle.
- [ ] Refaire l'exercice de distribution `log_cost` / `ship_cost`.
- [ ] Vérifier la conservation des métriques avant/après distribution.

---

# 🔗 143. Liens avec les autres notions du Brocode

```text
03 — JOINs & Testing
│
└── problème de granularité
        ↓

04 — Subqueries / CTEs
│
└── aggregate before JOIN
        ↓

05 — UDFs & Window Functions
│
├── conserver granularité
├── calcul analytique
├── distribuer métriques
└── ranking
        ↓

05b — NTILE / Quartiles / Tertiles
│
└── segmentation ordinale
        ↓

06 — Advanced SQL
```

Les Window Functions deviennent ensuite centrales dans :

```text
dbt
data marts
customer analytics
cohort analysis
RFM
churn
BI
financial analytics
```

---

# 🔬 144. Précisions techniques ajoutées au Brocode

Les points suivants complètent volontairement les slides du cours avec le comportement BigQuery actuel :

```text
- PARTITION BY et window frame sont deux concepts distincts ;
- ROW_NUMBER peut être non déterministe entre lignes ex æquo si aucun tie-breaker n'est fourni ;
- ORDER BY dans OVER ne trie pas nécessairement l'output final ;
- BigQuery fournit QUALIFY pour filtrer les résultats des Window Functions ;
- un aggregate analytic avec ORDER BY peut utiliser un frame par défaut ;
- ROWS / RANGE permettent de contrôler explicitement ce frame ;
- LAG, LEAD, FIRST_VALUE et LAST_VALUE font partie des navigation functions ;
- une UDF peut être temporaire ou persistante ;
- les UDFs SQL peuvent utiliser des paramètres ANY TYPE dans certains cas génériques.
```

Ces précisions ne changent pas le principe pédagogique du cours. Elles permettent surtout d'éviter les pièges que l'on rencontre lorsque les Window Functions deviennent plus complexes.

---

# 🏁 145. Résumé en une phrase

> **Une Window Function permet de faire un calcul qui regarde plusieurs lignes tout en gardant une sortie au niveau de chaque ligne — et `PARTITION BY`, `ORDER BY` et le window frame définissent exactement ce que chaque ligne a le droit de regarder.**
