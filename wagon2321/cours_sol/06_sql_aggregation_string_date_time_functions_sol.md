# 📝 #6 – SQL : Aggregations, String, Date & Time Functions

**Date : 13 juillet 2026**  
**Thème :** Agrégations SQL, manipulation de chaînes, dates et temps dans BigQuery / GoogleSQL  
**Tags :** `SQL` `BigQuery` `GROUP BY` `HAVING` `COUNT` `STRING` `REGEX` `DATE` `DATETIME` `TIMESTAMP` `EXTRACT` `DATE_TRUNC` `PARSE_DATE`  
**Compréhension (1→5) :** ⭐⭐⭐⭐☆

---

> **Objectif du chapitre :** construire une référence durable sur trois familles de transformations omniprésentes en Data Analytics :
>
> 1. **agréger** des lignes avec `COUNT`, `SUM`, `AVG`, `GROUP BY` et `HAVING` ;
> 2. **nettoyer / normaliser / rechercher** du texte avec les fonctions `STRING` et les expressions régulières ;
> 3. **manipuler correctement le temps** avec les types `DATE`, `TIME`, `DATETIME`, `TIMESTAMP` et les fonctions BigQuery associées.
>
> Le point essentiel n'est pas de mémoriser toutes les fonctions. Il est de comprendre :
>
> ```text
> quel est le type de ma donnée ?
> ↓
> quelle transformation veux-je produire ?
> ↓
> quel type doit avoir le résultat ?
> ↓
> à quelle granularité dois-je travailler ?
> ```

---

# 🧭 0. Vue d'ensemble du chapitre

Le cours mélange plusieurs notions qui sont en réalité très liées.

```text
DONNÉE BRUTE
│
├── NUMERIC
│   ├── SUM
│   ├── AVG
│   ├── ROUND
│   └── SAFE_DIVIDE
│
├── STRING
│   ├── CONCAT
│   ├── REPLACE
│   ├── LOWER / UPPER
│   ├── TRIM
│   ├── TRANSLATE
│   └── REGEXP_*
│
└── TEMPORAL
    ├── DATE
    ├── TIME
    ├── DATETIME
    └── TIMESTAMP
        │
        ├── EXTRACT
        ├── DATE_TRUNC
        ├── DATE_ADD / DATE_SUB
        ├── DATE_DIFF
        ├── FORMAT_DATE
        └── PARSE_DATE
```

Puis viennent les opérations analytiques :

```text
lignes brutes
   ↓
WHERE
   ↓
GROUP BY + agrégations
   ↓
HAVING
   ↓
résultat analytique
```

---

# 🧠 1. Le premier réflexe : connaître le type

Une fonction SQL n'agit pas simplement sur « une colonne ».

Elle agit sur :

```text
une valeur
+
un type
```

Exemple :

```sql
SUM(turnover)
```

n'a de sens que si `turnover` est numérique.

```sql
EXTRACT(YEAR FROM purchase_date)
```

attend une valeur temporelle compatible.

```sql
LOWER(customer_name)
```

travaille sur une chaîne de caractères.

---

# 🧩 2. Les grands types BigQuery à connaître

## Numériques

```text
INT64
FLOAT64
NUMERIC
BIGNUMERIC
```

## Booléen

```text
BOOL
```

## Texte / binaire

```text
STRING
BYTES
```

## Temps

```text
DATE
TIME
DATETIME
TIMESTAMP
```

## Types complexes

```text
ARRAY
STRUCT
JSON
GEOGRAPHY
RANGE
...
```

---

# ⚠️ 3. Correction Brocode — `BOOL` n'est pas un type numérique

Une slide classe :

```text
BOOLEAN
```

dans la partie « Numeric ».

Pour raisonner proprement dans BigQuery :

```text
BOOL
```

est un **type distinct**.

Il contient :

```text
TRUE
FALSE
NULL
```

et non pas conceptuellement :

```text
1 / 0
```

même si certains systèmes ou langages représentent parfois les booléens numériquement.

---

# ⚠️ 4. Correction Brocode — `YEAR`, `MONTH`, `DAY` ne sont pas des data types

La slide affiche notamment :

```text
YEAR
MONTH
QUARTER
WEEK
DAY
HOUR
MINUTE
```

dans la catégorie « Date ».

Dans BigQuery, ce ne sont pas des types.

Ce sont généralement des :

```text
date parts
time parts
granularities
```

utilisés dans des fonctions comme :

```sql
EXTRACT(MONTH FROM date_col)

DATE_TRUNC(date_col, MONTH)

DATE_DIFF(end_date, start_date, DAY)
```

Les véritables types temporels sont :

```text
DATE
TIME
DATETIME
TIMESTAMP
```

---

# ============================================================
# PARTIE I — AGRÉGATIONS
# ============================================================

# 📊 5. Qu'est-ce qu'une agrégation ?

Une agrégation transforme :

```text
plusieurs lignes
```

en :

```text
une information résumée
```

Exemple :

```text
purchase_id   buyer   spend
-----------   -----   -----
1             Julie      7.5
2             Julie      5.0
3             Paul      10.0
4             Thomas     5.0
5             Julien    15.0
6             Julien     2.5
```

Avec :

```sql
SELECT
  buyer,
  SUM(spend) AS total_spend
FROM purchases
GROUP BY buyer;
```

on obtient :

```text
buyer    total_spend
-------  -----------
Julie           12.5
Paul            10.0
Thomas           5.0
Julien          17.5
```

---

# 🧠 6. Une agrégation change la granularité

Avant :

```text
1 ligne = 1 achat
```

Après :

```sql
GROUP BY buyer
```

la granularité devient :

```text
1 ligne = 1 buyer
```

C'est une notion centrale du SQL analytique.

---

# 🔢 7. Les principales fonctions d'agrégation

Fonctions fondamentales :

```sql
COUNT()
SUM()
AVG()
MIN()
MAX()
```

Très utiles également :

```sql
COUNTIF()
COUNT(DISTINCT ...)
STRING_AGG()
ARRAY_AGG()
```

---

# 🔢 8. `COUNT(*)`

```sql
SELECT
  COUNT(*) AS row_count
FROM purchases;
```

`COUNT(*)` compte :

> **le nombre de lignes de l'entrée.**

---

# ⚠️ 9. Correction importante — `COUNT(*)` compte même une ligne remplie de `NULL`

Le résumé du cours dit approximativement :

> `COUNT(*)` compte toutes les lignes ayant au moins une valeur non nulle.

Ce n'est pas la règle exacte de BigQuery.

```sql
COUNT(*)
```

compte **les lignes**, indépendamment des valeurs contenues dans leurs colonnes.

Conceptuellement :

```text
row 1 : NULL | NULL | NULL
row 2 : 42   | NULL | NULL
row 3 : NULL | "x"  | NULL
```

```sql
COUNT(*)
```

retourne :

```text
3
```

La différence importante concerne :

```sql
COUNT(expression)
```

---

# 🔍 10. `COUNT(column)`

```sql
SELECT
  COUNT(email) AS email_count
FROM customers;
```

Cette forme compte :

```text
uniquement les lignes
où email IS NOT NULL
```

Exemple :

```text
email
----------------
a@example.com
NULL
b@example.com
NULL
```

Résultat :

```text
COUNT(*)      = 4
COUNT(email)  = 2
```

---

# 🧮 11. `COUNT(DISTINCT ...)`

```sql
SELECT
  COUNT(DISTINCT customer_id) AS unique_customers
FROM purchases;
```

Cette fonction répond à :

```text
combien de valeurs uniques non NULL ?
```

Très utile pour :

```text
nombre de clients
nombre de produits
nombre de commandes
contrôles de cardinalité
```

---

# ✅ 12. `COUNTIF`

BigQuery propose :

```sql
COUNTIF(condition)
```

Exemple :

```sql
SELECT
  COUNTIF(turnover > 100) AS high_value_orders
FROM orders;
```

C'est particulièrement lisible pour compter une condition.

---

# ➕ 13. `SUM`

```sql
SELECT
  SUM(turnover) AS total_turnover
FROM sales;
```

`SUM` additionne les valeurs non `NULL`.

---

# 📐 14. `AVG`

En BigQuery :

```sql
AVG(price)
```

et non :

```sql
AVERAGE(price)
```

`AVG` calcule la moyenne des valeurs non `NULL`.

---

# 📏 15. `MIN` et `MAX`

```sql
SELECT
  MIN(price) AS min_price,
  MAX(price) AS max_price
FROM products;
```

Ces fonctions sont également utilisables sur certains types non numériques, notamment les dates.

Exemple :

```sql
SELECT
  MIN(order_date) AS first_order,
  MAX(order_date) AS last_order
FROM orders;
```

---

# 🕳 16. Les agrégations et `NULL`

De manière générale :

```text
SUM
AVG
MIN
MAX
COUNT(expression)
```

ignorent les valeurs `NULL`.

Exemple :

```text
price
-----
10
20
NULL
```

```sql
AVG(price)
```

donne :

```text
(10 + 20) / 2
=
15
```

et non :

```text
(10 + 20 + 0) / 3
```

`NULL` n'est pas égal à `0`.

---

# ⚠️ 17. `NULL` ≠ zéro ≠ chaîne vide

Ces trois valeurs sont différentes :

```text
NULL
0
''
```

### `NULL`

```text
valeur absente / inconnue
```

### `0`

```text
valeur numérique connue
```

### `''`

```text
STRING connue mais vide
```

Cette distinction devient très importante lors des contrôles de qualité.

---

# 🧱 18. `GROUP BY`

Structure classique :

```sql
SELECT
  grouping_column,
  AGGREGATE_FUNCTION(metric) AS metric
FROM table
GROUP BY grouping_column;
```

Exemple :

```sql
SELECT
  buyer,
  SUM(spend) AS total_spend
FROM purchases
GROUP BY buyer;
```

---

# 📦 19. Règle fondamentale du `SELECT` agrégé

Dans une requête agrégée, une expression du `SELECT` doit généralement être :

```text
1. agrégée

OU

2. incluse dans le GROUP BY
```

Valide :

```sql
SELECT
  buyer,
  SUM(spend)
FROM purchases
GROUP BY buyer;
```

Invalide :

```sql
SELECT
  buyer,
  product,
  SUM(spend)
FROM purchases
GROUP BY buyer;
```

Pourquoi ?

BigQuery ne sait pas quel `product` retourner pour un buyer ayant plusieurs achats.

---

# 🧠 20. Le moteur pose implicitement la question

Avec :

```text
buyer = Paul
```

on peut avoir :

```text
banana
apple
pear
```

Après :

```sql
GROUP BY buyer
```

une seule ligne doit rester pour Paul.

Quel produit faudrait-il afficher ?

```text
banana ?
apple ?
pear ?
```

Il n'y a pas de réponse unique.

D'où l'erreur.

---

# 🧩 21. `GROUP BY` sur plusieurs colonnes

```sql
SELECT
  buyer,
  product,
  SUM(quantity) AS total_quantity
FROM purchases
GROUP BY
  buyer,
  product;
```

La granularité devient :

```text
1 ligne
=
1 buyer × 1 product
```

---

# 🧠 22. `GROUP BY` = définition de la nouvelle clé analytique

C'est une excellente manière de raisonner.

```sql
GROUP BY buyer
```

signifie :

```text
clé du résultat
=
buyer
```

```sql
GROUP BY buyer, product
```

signifie :

```text
clé du résultat
=
buyer + product
```

---

# 🔢 23. Références ordinales

BigQuery permet :

```sql
SELECT
  buyer,
  product,
  SUM(quantity) AS total_quantity
FROM purchases
GROUP BY 1, 2;
```

Ici :

```text
1 = buyer
2 = product
```

Cela fonctionne aussi avec :

```sql
ORDER BY 2 DESC
```

---

# ⚠️ 24. Faut-il utiliser les numéros de colonnes ?

Pratique pour :

```text
requêtes ad hoc
exploration rapide
```

Mais plus fragile dans du code maintenu.

Si quelqu'un réordonne le `SELECT`, le sens de :

```sql
GROUP BY 1, 2
```

change.

Dans un modèle dbt ou du SQL de production, les noms explicites sont souvent plus lisibles :

```sql
GROUP BY
  buyer,
  product
```

---

# 🧪 25. Contrôler une candidate Primary Key avec `GROUP BY`

Supposons que :

```text
product_id
```

doive être unique.

```sql
SELECT
  product_id,
  COUNT(*) AS row_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC;
```

Résultat attendu :

```text
0 ligne
```

Si des lignes apparaissent :

```text
product_id n'est pas unique
```

---

# 🕳 26. Tester les `NULL`

```sql
SELECT
  COUNTIF(product_id IS NULL) AS null_product_ids
FROM products;
```

Une vraie clé primaire logique doit généralement satisfaire :

```text
unique
+
non NULL
```

---

# 🧪 27. Pattern de contrôle de clé

```sql
SELECT
  COUNT(*) AS rows,
  COUNT(product_id) AS non_null_ids,
  COUNT(DISTINCT product_id) AS distinct_ids
FROM products;
```

Si :

```text
rows
=
non_null_ids
=
distinct_ids
```

alors la colonne est compatible avec une clé unique non nulle.

---

# ============================================================
# PARTIE II — WHERE, GROUP BY, HAVING
# ============================================================

# 🔎 28. `WHERE` = pré-filtrage

```sql
WHERE
```

filtre les lignes **avant l'agrégation**.

Exemple :

```sql
SELECT
  buyer,
  SUM(spend) AS total_spend
FROM purchases
WHERE spend > 10
GROUP BY buyer;
```

Le moteur commence par conserver uniquement :

```text
les achats individuels > 10
```

Puis il agrège ces lignes restantes.

---

# 📊 29. `HAVING` = filtre après agrégation

```sql
SELECT
  buyer,
  SUM(spend) AS total_spend
FROM purchases
GROUP BY buyer
HAVING total_spend > 10;
```

Ici :

```text
1. tous les achats sont agrégés par buyer
2. on calcule total_spend
3. on conserve les buyers dont le total > 10
```

---

# 🧠 30. `WHERE` vs `HAVING`

```text
WHERE
│
├── travaille sur les lignes brutes
├── avant GROUP BY
└── filtre ce qui entre dans l'agrégation

HAVING
│
├── travaille sur les groupes agrégés
├── après GROUP BY / aggregation
└── filtre le résultat de l'agrégation
```

---

# 📐 31. Exemple visuel

Source :

```text
buyer    spend
-------  -----
Julie      7.5
Julie      5.0
Paul      10.0
Thomas     5.0
Julien    15.0
Julien     2.5
```

## `WHERE spend > 10`

Avant agrégation :

```text
Julien   15.0
```

Puis :

```text
Julien   15.0
```

---

## `HAVING SUM(spend) > 10`

Agrégation d'abord :

```text
Julie     12.5
Paul      10.0
Thomas     5.0
Julien    17.5
```

Puis filtre :

```text
Julie     12.5
Julien    17.5
```

Résultat métier complètement différent.

---

# 🚫 32. Pourquoi pas `SUM()` dans `WHERE` ?

Ceci est invalide :

```sql
SELECT
  buyer,
  SUM(spend) AS total_spend
FROM purchases
WHERE SUM(spend) > 10
GROUP BY buyer;
```

Au moment où `WHERE` est évalué :

```text
SUM(spend)
```

n'a pas encore été calculé.

---

# ⏱ 33. Ordre logique d'évaluation BigQuery

Version simplifiée :

```text
FROM
↓
WHERE
↓
GROUP BY + AGGREGATION
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

L'ordre écrit dans le SQL n'est pas nécessairement l'ordre conceptuel d'évaluation.

---

# 🏷 34. Alias dans `HAVING`

BigQuery permet :

```sql
SELECT
  buyer,
  SUM(spend) AS total_spend
FROM purchases
GROUP BY buyer
HAVING total_spend > 10;
```

`total_spend` est un alias du `SELECT`, mais il est visible dans `HAVING`.

---

# 🏷 35. Alias et `WHERE`

En revanche :

```sql
SELECT
  spend * 1.2 AS spend_tax
FROM purchases
WHERE spend_tax > 10;
```

n'est pas valide.

`WHERE` est évalué trop tôt pour accéder à cet alias de `SELECT`.

---

# 🧱 36. `ROLLUP` — aperçu

Le cours mentionne l'idée de produire des grands totaux.

BigQuery permet notamment :

```sql
GROUP BY ROLLUP(...)
```

Exemple :

```sql
SELECT
  country,
  product,
  SUM(revenue) AS revenue
FROM sales
GROUP BY ROLLUP(country, product);
```

Cela peut produire :

```text
country + product
country subtotal
grand total
```

C'est utile dans certains exports ou tableaux analytiques.

Pour du code métier complexe, une agrégation explicite reste souvent plus simple à raisonner.

---

# ============================================================
# PARTIE III — FONCTIONS NUMÉRIQUES UTILES
# ============================================================

# ➗ 37. `SAFE_DIVIDE`

```sql
SAFE_DIVIDE(numerator, denominator)
```

Exemple :

```sql
SAFE_DIVIDE(margin, turnover)
```

Au lieu de faire échouer la requête sur une division problématique telle qu'un dénominateur nul, `SAFE_DIVIDE` retourne une valeur sûre, généralement `NULL`.

---

# 🎯 38. `ROUND`

```sql
ROUND(value, decimal_places)
```

Exemple :

```sql
ROUND(3.141592, 2)
```

retourne :

```text
3.14
```

Sans deuxième argument :

```sql
ROUND(3.7)
```

arrondit à l'entier.

---

# ⚠️ 39. Ne pas arrondir trop tôt

Pour un calcul financier ou un ratio utilisé en aval :

```text
calcul exact
↓
agrégations
↓
ROUND à la sortie
```

est souvent préférable à :

```text
ROUND
↓
multiplications
↓
SUM
```

L'arrondi précoce peut introduire un écart cumulé.

---

# ============================================================
# PARTIE IV — STRING FUNCTIONS
# ============================================================

# 🔤 40. Pourquoi les fonctions STRING sont importantes

La donnée textuelle brute contient souvent :

```text
majuscules incohérentes
espaces
typos
préfixes
suffixes
accents
formats hétérogènes
informations encodées dans une chaîne
```

Exemples :

```text
"  PARIS "
"Paris"
"paris"
"PARIS"
```

Analytically, cela peut représenter :

```text
la même ville
```

mais SQL les considère comme des chaînes différentes si on utilise une comparaison sensible à la casse / valeur exacte.

---

# 🔗 41. `CONCAT`

Syntaxe :

```sql
CONCAT(value1, value2, ...)
```

Exemple du cours :

```sql
SELECT
  CONCAT(year, '-', month, '-', day) AS date_string
FROM fruit;
```

Résultat :

```text
2021-06-03
```

---

# ⚠️ 42. `CONCAT` et `NULL`

Un piège important :

```sql
CONCAT(...)
```

retourne `NULL` si l'un de ses arguments est `NULL`.

Exemple :

```sql
CONCAT('Brice', ' ', NULL)
```

→

```text
NULL
```

Si nécessaire :

```sql
CONCAT(
  COALESCE(first_name, ''),
  ' ',
  COALESCE(last_name, '')
)
```

---

# 🔗 43. Alternative `||`

BigQuery permet également :

```sql
first_name || ' ' || last_name
```

équivalent conceptuellement à :

```sql
CONCAT(first_name, ' ', last_name)
```

---

# 🔢 44. `CONCAT` avec d'autres types

BigQuery peut accepter dans `CONCAT` des valeurs pouvant être converties en `STRING`.

Exemple :

```sql
CONCAT('year=', 2026)
```

Mais pour du code explicite et robuste, surtout avec des schémas complexes :

```sql
CAST(year AS STRING)
```

rend le contrat plus lisible.

---

# 🔄 45. `REPLACE`

Syntaxe :

```sql
REPLACE(value, from_value, to_value)
```

Exemple du cours :

```sql
SELECT
  REPLACE(product, 'i', 'a') AS product
FROM fruit;
```

Si :

```text
binini
```

alors :

```text
banana
```

---

# 🧠 46. `REPLACE` = remplacement littéral

`REPLACE` ne comprend pas une expression régulière.

```sql
REPLACE(value, '.', 'x')
```

cherche réellement :

```text
le caractère "."
```

Il ne traite pas `.` comme :

```text
n'importe quel caractère
```

Pour cela :

```sql
REGEXP_REPLACE
```

est nécessaire.

---

# 🔡 47. `LOWER`

```sql
LOWER(value)
```

Exemple :

```sql
SELECT
  LOWER(buyer) AS buyer
FROM fruit;
```

```text
Ema
Paul
Thomas
```

devient :

```text
ema
paul
thomas
```

---

# 🔠 48. `UPPER`

```sql
UPPER(value)
```

Transformation inverse :

```text
paris
→
PARIS
```

---

# ✨ 49. `INITCAP`

BigQuery fournit :

```sql
INITCAP(value)
```

utile pour obtenir :

```text
jean dupont
→
Jean Dupont
```

C'est surtout une transformation de présentation.

---

# ⚠️ 50. Normaliser pour comparer

Un pattern courant :

```sql
WHERE LOWER(city) = 'paris'
```

fonctionne.

Mais si cette comparaison est répétée partout, mieux vaut souvent normaliser la donnée en amont :

```text
raw
→ clean_city
→ analyses
```

Cela :

```text
centralise la règle
réduit la duplication de logique
améliore la lisibilité
```

---

# 🧠 51. Complément BigQuery — `NORMALIZE_AND_CASEFOLD`

Pour des comparaisons Unicode insensibles à la casse, BigQuery propose :

```sql
NORMALIZE_AND_CASEFOLD(value)
```

Exemple conceptuel :

```sql
NORMALIZE_AND_CASEFOLD(city)
=
NORMALIZE_AND_CASEFOLD('Paris')
```

C'est plus précis qu'un simple `LOWER()` lorsque l'on doit gérer des variations Unicode.

---

# ✂️ 52. `TRIM`

Très fréquent en data cleaning :

```sql
TRIM(value)
```

Exemple :

```text
"   Paris   "
```

devient :

```text
"Paris"
```

Il existe également :

```sql
LTRIM()
RTRIM()
```

---

# 📏 53. `LENGTH`

```sql
LENGTH(value)
```

retourne le nombre de caractères d'une `STRING`.

Pour mesurer la taille en octets :

```sql
BYTE_LENGTH(value)
```

Les deux nombres peuvent être différents avec certains caractères Unicode.

---

# ✂️ 54. `SUBSTR` / `SUBSTRING`

Permet d'extraire une portion de chaîne.

Exemple :

```sql
SUBSTR('ABCDEFG', 2, 3)
```

→

```text
BCD
```

Très utile pour :

```text
codes
identifiants structurés
préfixes
suffixes
```

mais si le format est complexe, la regex peut être plus appropriée.

---

# 🔤 55. `TRANSLATE`

Syntaxe :

```sql
TRANSLATE(
  expression,
  source_characters,
  target_characters
)
```

BigQuery remplace chaque caractère de :

```text
source_characters
```

par le caractère correspondant de :

```text
target_characters
```

Exemple :

```sql
TRANSLATE(
  'été à Genève',
  'éèêëàâä',
  'eeeeaaa'
)
```

peut être utilisé comme stratégie simple de normalisation d'accents explicitement connus.

---

# ⚠️ 56. `TRANSLATE` n'est pas un moteur de normalisation linguistique complet

Il s'agit d'un mapping caractère → caractère.

Cela peut être excellent si la règle métier est claire :

```text
é → e
è → e
à → a
```

Mais pour une normalisation Unicode plus générale, penser à :

```sql
NORMALIZE()
NORMALIZE_AND_CASEFOLD()
```

selon le besoin.

---

# ============================================================
# PARTIE V — REGULAR EXPRESSIONS
# ============================================================

# 🧩 57. Qu'est-ce qu'une regex ?

Une expression régulière décrit :

```text
un pattern de texte
```

au lieu d'une valeur exacte.

Exemple :

```text
"paul"
```

est une valeur.

Alors que :

```text
r'^[A-Za-z]+$'
```

décrit :

```text
une chaîne contenant uniquement des lettres
du début à la fin
```

---

# 🔎 58. `REGEXP_CONTAINS`

Syntaxe :

```sql
REGEXP_CONTAINS(value, regexp)
```

Retourne :

```text
TRUE
```

si une partie de `value` correspond au pattern.

Exemple du cours :

```sql
SELECT
  REGEXP_CONTAINS(buyer, r'ma') AS contains_ma
FROM fruit;
```

---

# 🧠 59. Matching partiel

Par défaut :

```sql
REGEXP_CONTAINS('Thomas', r'ma')
```

cherche une correspondance partielle.

Il n'est pas nécessaire que :

```text
toute la chaîne
```

corresponde au pattern.

---

# 🎯 60. Matching complet

Pour exiger une correspondance sur toute la chaîne :

```text
^
```

marque le début.

```text
$
```

marque la fin.

Exemple :

```sql
REGEXP_CONTAINS(
  email,
  r'^([\w.+-]+@example\.com)$'
)
```

---

# 📚 61. BigQuery utilise RE2

Les expressions régulières de GoogleSQL / BigQuery utilisent la bibliothèque :

```text
RE2
```

Cela signifie qu'il faut utiliser la syntaxe compatible RE2 plutôt que supposer que toutes les fonctionnalités PCRE / Python sont disponibles.

---

# 🪄 62. Le préfixe `r`

On écrit souvent :

```sql
r'\d+'
```

au lieu de :

```sql
'\\d+'
```

Le `r` indique une **raw string**.

Cela rend beaucoup de regex plus lisibles car on échappe moins les backslashes.

---

# 🧱 63. Quelques symboles regex essentiels

```text
.        n'importe quel caractère
\d       chiffre
\w       caractère "word"
\s       espace / whitespace
[abc]    a OU b OU c
[a-z]    intervalle
[^abc]   tout sauf a/b/c
*        0 ou plusieurs
+        1 ou plusieurs
?        0 ou 1
{n}      exactement n
{n,m}    entre n et m
^        début
$        fin
|        OR
(...)    groupe
```

---

# 🔀 64. `|` = OR

```text
cat|dog
```

signifie :

```text
cat
OU
dog
```

Exemple :

```sql
REGEXP_CONTAINS(
  LOWER(product),
  r'apple|banana'
)
```

---

# 🔎 65. `LIKE` vs Regex

`LIKE` est très utile pour des patterns simples :

```sql
WHERE email LIKE '%@gmail.com'
```

Wildcards :

```text
%  = n'importe quelle suite de caractères
_  = un caractère
```

Regex devient utile lorsque le pattern contient :

```text
alternatives
classes de caractères
quantités
ancres
groupes
formats structurés
```

---

# ✅ 66. Choisir le bon outil

```text
égalité exacte
→ =

simple contains
→ CONTAINS_SUBSTR / LIKE

préfixe / suffixe simple
→ STARTS_WITH / ENDS_WITH

pattern complexe
→ REGEXP_CONTAINS

extraction d'un pattern
→ REGEXP_EXTRACT

replacement pattern
→ REGEXP_REPLACE
```

---

# 🔎 67. `CONTAINS_SUBSTR` — complément BigQuery

Pour une simple recherche de sous-chaîne, BigQuery fournit :

```sql
CONTAINS_SUBSTR(expression, search_value)
```

Cette fonction effectue une recherche normalisée et insensible à la casse.

Exemple :

```sql
CONTAINS_SUBSTR(
  'The Blue House',
  'blue house'
)
```

→

```text
TRUE
```

Pour un simple « contient », cela peut être plus lisible qu'une regex.

---

# 🧲 68. `REGEXP_EXTRACT`

```sql
REGEXP_EXTRACT(value, regexp)
```

retourne la partie du texte qui correspond.

Exemple :

```sql
SELECT
  REGEXP_EXTRACT(
    'foo@example.com',
    r'^[A-Za-z0-9_.+-]+'
  ) AS username;
```

→

```text
foo
```

---

# 🔁 69. `REGEXP_REPLACE`

```sql
REGEXP_REPLACE(
  value,
  regexp,
  replacement
)
```

Exemple :

```sql
REGEXP_REPLACE(
  phone,
  r'[^0-9]',
  ''
)
```

permet de supprimer les caractères non numériques.

```text
"+33 (0)6 12-34-56-78"
↓
"330612345678"
```

---

# 🧪 70. Regex et qualité de données

Exemples de contrôles :

```text
format email
code postal
IBAN simplifié
numéro de téléphone
référence produit
format d'identifiant
```

Mais attention :

> une regex valide seulement la **forme**, pas la vérité métier.

Un email peut avoir un format plausible et ne pas exister.

---

# ============================================================
# PARTIE VI — TEMPORAL DATA TYPES
# ============================================================

# 🕐 71. Les quatre types temporels BigQuery

C'est le cœur du chapitre.

```text
DATE
TIME
DATETIME
TIMESTAMP
```

Ils ne sont pas interchangeables conceptuellement.

---

# 📅 72. `DATE`

Un `DATE` contient :

```text
année
mois
jour
```

Exemple :

```text
2026-08-08
```

Il ne contient pas :

```text
heure
timezone
```

Utiliser `DATE` pour :

```text
date de naissance
date comptable
jour de commande
date de clôture
jour férié
```

---

# 🕒 73. `TIME`

Un `TIME` contient uniquement :

```text
heure
minute
seconde
fraction de seconde
```

Exemple :

```text
14:35:17.123
```

Pas de :

```text
date
timezone
```

---

# 🗓 74. `DATETIME`

Un `DATETIME` contient :

```text
DATE
+
TIME
```

Exemple :

```text
2026-08-08 14:35:17
```

Mais :

```text
pas de timezone intrinsèque
```

C'est une **date et heure civile**.

---

# 🌍 75. `TIMESTAMP`

Un `TIMESTAMP` représente :

> **un instant absolu dans le temps.**

Exemple :

```text
2026-08-08 12:35:17 UTC
```

Le même instant peut être affiché différemment selon la timezone.

```text
UTC             12:35
Europe/Paris    14:35
America/New_York 08:35
```

mais il s'agit du même événement temporel.

---

# 🧠 76. Le tableau mental essentiel

| Type | Date | Heure | Timezone / instant absolu |
|---|---:|---:|---:|
| `DATE` | ✅ | ❌ | ❌ |
| `TIME` | ❌ | ✅ | ❌ |
| `DATETIME` | ✅ | ✅ | ❌ |
| `TIMESTAMP` | ✅ | ✅ | ✅ concept d'instant |

---

# 🎯 77. Quel type choisir ?

Question :

```text
Est-ce un jour civil ?
```

→

```text
DATE
```

Question :

```text
Est-ce une heure locale sans jour ?
```

→

```text
TIME
```

Question :

```text
Est-ce une date+heure civile sans fuseau ?
```

→

```text
DATETIME
```

Question :

```text
Est-ce un événement exact dans le monde ?
```

→

```text
TIMESTAMP
```

---

# 🏦 78. Exemple banking

### Date de naissance

```text
DATE
```

### Jour comptable

```text
DATE
```

### Heure d'ouverture d'une agence

```text
TIME
```

### Rendez-vous local « 10:30 »

Selon architecture :

```text
DATETIME + timezone séparée
```

ou conversion vers :

```text
TIMESTAMP
```

### Instant d'une transaction

```text
TIMESTAMP
```

car :

```text
2026-08-08 14:01 en Suisse
```

et :

```text
2026-08-08 08:01 à New York
```

peuvent représenter le même instant.

---

# ============================================================
# PARTIE VII — CONVERSION, CAST & PARSING
# ============================================================

# 🔄 79. Type correct vs apparence visuelle

Ceci :

```text
"2026-08-08"
```

peut être un :

```text
STRING
```

même si cela ressemble à une date.

Alors que :

```text
DATE '2026-08-08'
```

est réellement un :

```text
DATE
```

Toujours vérifier le schéma.

---

# 🧱 80. `CAST`

Si une chaîne est déjà dans un format directement convertible :

```sql
CAST('2026-08-08' AS DATE)
```

---

# 🛡 81. `SAFE_CAST`

```sql
SAFE_CAST(value AS DATE)
```

Si la conversion échoue :

```text
CAST
→ erreur

SAFE_CAST
→ NULL
```

Très utile en exploration / nettoyage.

Mais il ne faut pas utiliser `SAFE_CAST` pour silencieusement masquer un problème de qualité sans le mesurer.

---

# 🧪 82. Pattern de Data Quality avec `SAFE_CAST`

```sql
SELECT
  COUNTIF(
    raw_date IS NOT NULL
    AND SAFE_CAST(raw_date AS DATE) IS NULL
  ) AS invalid_dates
FROM source;
```

On compte explicitement :

```text
les valeurs présentes
mais non convertibles
```

---

# 📅 83. `PARSE_DATE`

Syntaxe :

```sql
PARSE_DATE(
  format_string,
  date_string
)
```

Utiliser `PARSE_DATE` lorsque la chaîne contient un format non standard.

Exemple du cours :

```text
Thursday, 3 June 2021
```

---

# 🧩 84. Exemple `PARSE_DATE`

```sql
SELECT
  PARSE_DATE(
    '%A, %e %B %Y',
    date_purchase
  ) AS date_purchase
FROM fruit;
```

Résultat :

```text
2021-06-03
```

---

# 🎼 85. Le format doit correspondre à la chaîne

Si la valeur est :

```text
Thursday, 3 June 2021
```

le format doit décrire :

```text
weekday
virgule
espace
jour
espace
mois
espace
année
```

On ne donne pas simplement :

```text
année / mois / jour
```

On décrit précisément la représentation textuelle.

---

# 📚 86. Format elements essentiels

```text
%Y  année sur 4 chiffres    2026
%y  année sur 2 chiffres    26
%m  mois numérique          08
%B  mois complet            August
%b  mois abrégé             Aug
%d  jour du mois 01-31      08
%e  jour du mois            8
%A  weekday complet         Saturday
%a  weekday abrégé          Sat
%H  heure 00-23
%M  minute
%S  seconde
```

---

# 🔄 87. `PARSE_*` vs `FORMAT_*`

Deux directions opposées :

```text
STRING
↓ PARSE
DATE / DATETIME / TIMESTAMP
```

et :

```text
DATE / DATETIME / TIMESTAMP
↓ FORMAT
STRING
```

---

# 🎨 88. `FORMAT_DATE`

```sql
FORMAT_DATE(
  '%Y-%m',
  order_date
)
```

retourne :

```text
STRING
```

par exemple :

```text
2026-08
```

---

# ⚠️ 89. Ne pas confondre affichage et donnée temporelle

```sql
FORMAT_DATE('%Y-%m', order_date)
```

retourne une chaîne.

Si l'objectif est de regrouper chronologiquement par mois, il est souvent plus robuste d'utiliser :

```sql
DATE_TRUNC(order_date, MONTH)
```

qui retourne encore un type temporel.

---

# ============================================================
# PARTIE VIII — EXTRACT
# ============================================================

# ⛏ 90. `EXTRACT`

Syntaxe :

```sql
EXTRACT(
  date_part
  FROM temporal_expression
)
```

Exemple :

```sql
SELECT
  EXTRACT(YEAR FROM date_purchase) AS year
FROM fruit;
```

---

# 📆 91. Exemples de parties extractibles sur une date

```sql
EXTRACT(YEAR FROM date_col)
EXTRACT(QUARTER FROM date_col)
EXTRACT(MONTH FROM date_col)
EXTRACT(WEEK FROM date_col)
EXTRACT(ISOWEEK FROM date_col)
EXTRACT(DAY FROM date_col)
EXTRACT(DAYOFWEEK FROM date_col)
EXTRACT(DAYOFYEAR FROM date_col)
```

Selon le type source, des parties temporelles comme :

```text
HOUR
MINUTE
SECOND
```

sont également disponibles.

---

# ⚠️ 92. Correction Brocode — `EXTRACT` n'exige pas un `DATETIME`

Une slide indique approximativement :

> la date doit être au format DATETIME, sinon utiliser DATE().

C'est trop restrictif pour BigQuery.

`EXTRACT` possède des variantes pour :

```text
DATE
TIME
DATETIME
TIMESTAMP
```

Exemples :

```sql
EXTRACT(YEAR FROM DATE '2026-08-08')

EXTRACT(HOUR FROM TIME '14:30:00')

EXTRACT(MONTH FROM DATETIME '2026-08-08 14:30:00')

EXTRACT(HOUR FROM TIMESTAMP '2026-08-08 12:30:00+00')
```

Il faut surtout que :

```text
le type source
soit compatible avec
la partie demandée
```

---

# 🔢 93. `EXTRACT(MONTH)` retourne un nombre

```sql
EXTRACT(
  MONTH
  FROM DATE '2026-08-08'
)
```

→

```text
8
```

Le résultat est un :

```text
INT64
```

Ce n'est plus une date.

---

# 🎯 94. Quand `EXTRACT` est utile

Très adapté à des questions comme :

```text
Quel jour de semaine génère le plus de ventes ?

Quel mois de l'année est historiquement le meilleur ?

Quelle heure de la journée concentre le plus de transactions ?

Quel trimestre ?
```

---

# ⚠️ 95. Perte d'information avec `EXTRACT`

Si on écrit :

```sql
EXTRACT(MONTH FROM order_date)
```

alors :

```text
2024-06-10
2025-06-10
2026-06-10
```

deviennent toutes :

```text
6
```

L'année a disparu.

Cela peut être :

```text
exactement voulu
```

ou une énorme erreur analytique.

---

# 🧠 96. Question réflexe avant `EXTRACT`

Demander :

> Est-ce que je veux analyser **juin en général**, ou **juin 2026** ?

### Juin toutes années confondues

```sql
EXTRACT(MONTH FROM order_date)
```

### Mois chronologique distinct

```sql
DATE_TRUNC(order_date, MONTH)
```

---

# ============================================================
# PARTIE IX — DATE_TRUNC
# ============================================================

# ✂️ 97. `DATE_TRUNC`

Syntaxe :

```sql
DATE_TRUNC(
  date_value,
  granularity
)
```

Exemple :

```sql
DATE_TRUNC(
  DATE '2026-08-08',
  MONTH
)
```

→

```text
2026-08-01
```

---

# 🧠 98. `DATE_TRUNC` conserve un type temporel

Contrairement à :

```sql
EXTRACT(MONTH ...)
```

qui retourne :

```text
8
```

`DATE_TRUNC(..., MONTH)` retourne :

```text
2026-08-01
```

donc :

```text
année + mois
```

restent représentés.

---

# 📅 99. Exemples

```sql
DATE_TRUNC(date_col, YEAR)
```

→ premier jour de l'année.

```sql
DATE_TRUNC(date_col, QUARTER)
```

→ premier jour du trimestre.

```sql
DATE_TRUNC(date_col, MONTH)
```

→ premier jour du mois.

```sql
DATE_TRUNC(date_col, WEEK)
```

→ début de la semaine selon la granularité utilisée.

---

# 📊 100. `EXTRACT` vs `DATE_TRUNC`

Supposons :

```text
2025-06-12
2026-06-15
```

## `EXTRACT(MONTH)`

```text
6
6
```

Les deux années fusionnent naturellement dans un `GROUP BY`.

---

## `DATE_TRUNC(..., MONTH)`

```text
2025-06-01
2026-06-01
```

Les périodes restent distinctes.

---

# 🧭 101. Cas d'usage

## Saisonnalité annuelle

> Comment les clients se comportent-ils en moyenne au mois de juin, quelle que soit l'année ?

```sql
GROUP BY
  EXTRACT(MONTH FROM order_date)
```

---

## Série temporelle mensuelle

> Comment le CA évolue-t-il mois après mois depuis 2024 ?

```sql
GROUP BY
  DATE_TRUNC(order_date, MONTH)
```

---

# 📈 102. Pattern mensuel recommandé

```sql
SELECT
  DATE_TRUNC(order_date, MONTH) AS month,
  SUM(revenue) AS revenue
FROM orders
GROUP BY month
ORDER BY month;
```

Le résultat conserve un axe chronologique exploitable par un outil BI.

---

# 📅 103. Semaine : attention au début de semaine

Les semaines sont un terrain classique d'erreur.

Selon le besoin :

```sql
WEEK
WEEK(MONDAY)
ISOWEEK
```

peuvent produire des découpages différents.

Pour une entreprise européenne, une semaine commençant le lundi est souvent plus naturelle :

```sql
DATE_TRUNC(
  date_col,
  WEEK(MONDAY)
)
```

Toujours documenter la convention.

---

# ============================================================
# PARTIE X — DATE ARITHMETIC
# ============================================================

# ➕ 104. `DATE_ADD`

```sql
DATE_ADD(
  date_expression,
  INTERVAL n date_part
)
```

Exemple :

```sql
DATE_ADD(
  DATE '2026-08-08',
  INTERVAL 30 DAY
)
```

---

# ➖ 105. `DATE_SUB`

```sql
DATE_SUB(
  date_expression,
  INTERVAL n date_part
)
```

Exemple :

```sql
DATE_SUB(
  CURRENT_DATE(),
  INTERVAL 30 DAY
)
```

Très utile pour :

```text
30 derniers jours
année précédente
cohorte
fenêtres temporelles
```

---

# 📅 106. Parties supportées

Pour `DATE_ADD` / `DATE_SUB` :

```text
DAY
WEEK
MONTH
QUARTER
YEAR
```

---

# ⚠️ 107. Fin de mois

Ajouter ou soustraire des mois n'est pas équivalent à ajouter un nombre fixe de jours.

Exemple :

```text
31 janvier
+ 1 mois
```

pose une question :

```text
février n'a pas de 31
```

BigQuery applique une logique particulière de fin de mois et utilise le dernier jour valide lorsque nécessaire.

C'est une raison de préférer :

```sql
DATE_ADD(..., INTERVAL 1 MONTH)
```

à :

```sql
DATE_ADD(..., INTERVAL 30 DAY)
```

lorsqu'on pense en mois calendaires.

---

# 📐 108. `DATE_DIFF`

Syntaxe :

```sql
DATE_DIFF(
  end_date,
  start_date,
  granularity
)
```

Exemple du cours :

```sql
SELECT
  DATE_DIFF(
    date_delivery,
    date_purchase,
    DAY
  ) AS delivery_time
FROM fruit;
```

---

# 🧠 109. Ordre des arguments

```text
end_date
-
start_date
```

Donc :

```sql
DATE_DIFF(
  DATE '2026-08-10',
  DATE '2026-08-08',
  DAY
)
```

→

```text
2
```

Si on inverse :

```text
-2
```

---

# ⚠️ 110. `DATE_DIFF` compte des frontières de périodes

Point très important :

`DATE_DIFF` ne doit pas toujours être interprété comme :

```text
durée physique continue
/
taille d'une unité
```

Il compte des **boundaries** de la granularité demandée.

Exemple :

```text
samedi → dimanche
```

peut produire :

```text
DATE_DIFF(..., WEEK) = 1
```

car une frontière de semaine est franchie.

---

# 📅 111. `DATE_DIFF` et les semaines

Comparer :

```sql
DATE_DIFF(end_date, start_date, WEEK)

DATE_DIFF(end_date, start_date, WEEK(MONDAY))

DATE_DIFF(end_date, start_date, ISOWEEK)
```

peut produire des résultats différents.

Le choix doit refléter la convention métier.

---

# 🧮 112. Age — piège classique

On pourrait être tenté de calculer :

```sql
DATE_DIFF(
  CURRENT_DATE(),
  birth_date,
  YEAR
)
```

Cela compte les frontières d'années.

Pour un âge exact selon anniversaire, il faut vérifier que la logique correspond précisément au besoin métier.

Pour une simple segmentation approximative, cela peut suffire.

Pour une règle légale / réglementaire :

```text
ne jamais utiliser une approximation sans validation
```

---

# ============================================================
# PARTIE XI — FORMAT_DATE & LAST_DAY
# ============================================================

# 🎨 113. `FORMAT_DATE`

```sql
FORMAT_DATE(
  format_string,
  date_expression
)
```

Exemple :

```sql
FORMAT_DATE(
  '%d/%m/%Y',
  order_date
)
```

→

```text
08/08/2026
```

Retour :

```text
STRING
```

---

# 🧠 114. `FORMAT_DATE` est une fonction d'affichage

À utiliser pour :

```text
labels
exports
fichiers
présentation
```

Éviter de remplacer systématiquement une vraie date par une chaîne trop tôt dans un pipeline analytique.

Une date typée permet :

```text
tri chronologique
date arithmetic
partition pruning
comparaisons temporelles
```

---

# 📆 115. `LAST_DAY`

BigQuery fournit :

```sql
LAST_DAY(date_expression)
```

Par défaut :

```text
dernier jour du mois
```

Exemple :

```sql
LAST_DAY(DATE '2026-02-10')
```

→

```text
2026-02-28
```

Peut également travailler sur :

```text
YEAR
QUARTER
MONTH
WEEK
ISOWEEK
ISOYEAR
```

selon la signature.

---

# 💼 116. Usage de `LAST_DAY`

Exemples :

```text
date de clôture mensuelle
reporting fin de mois
date de maturité alignée
cohorte
snapshot
```

---

# ============================================================
# PARTIE XII — CURRENT DATE/TIME
# ============================================================

# 🕒 117. Date / heure actuelle

BigQuery propose notamment :

```sql
CURRENT_DATE()
CURRENT_TIME()
CURRENT_DATETIME()
CURRENT_TIMESTAMP()
```

---

# 🌍 118. `CURRENT_DATE` et timezone

Sans timezone explicite :

```sql
CURRENT_DATE()
```

utilise par défaut :

```text
UTC
```

On peut préciser :

```sql
CURRENT_DATE('Europe/Paris')
```

Pour une entreprise suisse :

```sql
CURRENT_DATE('Europe/Zurich')
```

peut être plus cohérent pour une logique de jour local.

---

# 🧠 119. Pourquoi la timezone compte

Imaginons :

```text
2026-08-08 23:30 UTC
```

En Suisse en été :

```text
2026-08-09 01:30
```

Donc :

```text
date UTC = 8 août
date locale = 9 août
```

Une règle métier basée sur la date locale doit choisir explicitement la timezone pertinente.

---

# ============================================================
# PARTIE XIII — TIMESTAMP & TIMEZONES
# ============================================================

# 🌍 120. `TIMESTAMP` et instant absolu

Lorsqu'une donnée représente :

```text
un événement exact
```

exemple :

```text
transaction_authorized_at
login_at
payment_received_at
```

`TIMESTAMP` est souvent le type naturel.

---

# 🔄 121. Convertir un `TIMESTAMP` en date locale

```sql
DATE(
  transaction_timestamp,
  'Europe/Zurich'
)
```

permet d'obtenir le jour civil suisse correspondant à l'instant.

---

# ⚠️ 122. Ne jamais supposer implicitement la timezone

Une colonne appelée :

```text
transaction_datetime
```

ne suffit pas pour savoir :

```text
UTC ?
Europe/Zurich ?
heure du système source ?
```

La timezone fait partie du contrat de donnée.

Si elle n'est pas documentée :

```text
investiguer
```

plutôt que deviner.

---

# 🕰 123. Heure d'été / DST

Les timezones régionales comme :

```text
Europe/Zurich
America/New_York
```

portent les règles historiques de changement d'heure.

Un offset fixe comme :

```text
+02
```

ne décrit pas toujours correctement l'heure locale toute l'année.

Pour de la logique business locale :

```text
timezone régionale
```

est souvent préférable.

---

# ============================================================
# PARTIE XIV — PARSE_DATETIME / PARSE_TIMESTAMP / FORMAT
# ============================================================

# 🧩 124. Famille cohérente de fonctions

```text
PARSE_DATE
PARSE_TIME
PARSE_DATETIME
PARSE_TIMESTAMP
```

et :

```text
FORMAT_DATE
FORMAT_TIME
FORMAT_DATETIME
FORMAT_TIMESTAMP
```

Le choix dépend du type cible.

---

# 📥 125. Parsing

```text
STRING
→ type temporel
```

Exemple :

```sql
PARSE_TIMESTAMP(
  '%Y-%m-%d %H:%M:%S',
  raw_timestamp
)
```

---

# 📤 126. Formatting

```text
type temporel
→ STRING
```

Exemple :

```sql
FORMAT_TIMESTAMP(
  '%Y-%m-%d %H:%M',
  event_timestamp,
  'Europe/Zurich'
)
```

---

# ⚠️ 127. Parsing strict = Data Quality

Si une source affirme :

```text
format = DD/MM/YYYY
```

mais qu'une ligne contient :

```text
2026-08-08
```

la conversion peut échouer.

C'est une information de qualité de données.

Ne pas corriger automatiquement sans réfléchir :

```text
format réellement variable ?
source corrompue ?
nouvelle version ?
```

---

# ============================================================
# PARTIE XV — DATE_TRUNC vs EXTRACT : CHOIX ANALYTIQUE
# ============================================================

# 🧭 128. Question 1 — saisonnalité

> Quel mois de l'année génère le plus de commandes, en moyenne sur plusieurs années ?

```sql
SELECT
  EXTRACT(MONTH FROM order_date) AS month_number,
  COUNT(*) AS orders
FROM orders
GROUP BY month_number
ORDER BY month_number;
```

Ici :

```text
tous les janvier fusionnent
tous les février fusionnent
...
```

C'est voulu.

---

# 📈 129. Question 2 — série temporelle

> Quel est le nombre de commandes mois par mois ?

```sql
SELECT
  DATE_TRUNC(order_date, MONTH) AS month,
  COUNT(*) AS orders
FROM orders
GROUP BY month
ORDER BY month;
```

Ici :

```text
2025-06
≠
2026-06
```

C'est voulu.

---

# 🧠 130. Raccourci mental

```text
EXTRACT
→ "quelle composante ?"

DATE_TRUNC
→ "quelle période calendaire exacte ?"
```

---

# 📊 131. BI et `DATE_TRUNC`

Pour un graphique :

```text
date en X
KPI en Y
```

une vraie date mensuelle :

```text
2026-01-01
2026-02-01
2026-03-01
```

est souvent beaucoup plus facile à exploiter qu'une simple valeur :

```text
1
2
3
```

car le contexte annuel est conservé.

---

# ============================================================
# PARTIE XVI — DATE FILTERING & PERFORMANCE
# ============================================================

# 🎯 132. Filtrer des dates

Préférer :

```sql
WHERE order_date >= DATE '2026-01-01'
  AND order_date <  DATE '2027-01-01'
```

à une comparaison de chaînes.

---

# 🧠 133. Half-open intervals

Pour une période :

```text
[debut, fin[
```

le pattern :

```sql
WHERE event_date >= start_date
  AND event_date < end_date
```

est extrêmement robuste.

Exemple année 2026 :

```sql
WHERE order_date >= DATE '2026-01-01'
  AND order_date <  DATE '2027-01-01'
```

Cela évite des problèmes de :

```text
heures
microsecondes
23:59:59.999...
```

sur les timestamps.

---

# 🕒 134. Exemple TIMESTAMP

```sql
WHERE event_ts >= TIMESTAMP '2026-08-01 00:00:00+00'
  AND event_ts <  TIMESTAMP '2026-09-01 00:00:00+00'
```

---

# ⚠️ 135. Appliquer une fonction sur la colonne de filtre

Exemple :

```sql
WHERE EXTRACT(YEAR FROM order_date) = 2026
```

est lisible.

Mais pour des tables partitionnées, il est souvent intéressant de réfléchir à un filtre direct sur la colonne de partition :

```sql
WHERE order_date >= DATE '2026-01-01'
  AND order_date <  DATE '2027-01-01'
```

car cela exprime directement l'intervalle.

Toujours vérifier le partitionnement réel de la table et le plan / bytes processed.

---

# ============================================================
# PARTIE XVII — GROUP BY SUR LES DATES
# ============================================================

# 📅 136. CA par jour

```sql
SELECT
  order_date,
  SUM(revenue) AS revenue
FROM orders
GROUP BY order_date
ORDER BY order_date;
```

Granularité :

```text
1 ligne = 1 jour
```

---

# 📅 137. CA par mois

```sql
SELECT
  DATE_TRUNC(order_date, MONTH) AS month,
  SUM(revenue) AS revenue
FROM orders
GROUP BY month
ORDER BY month;
```

---

# 📅 138. CA par trimestre

```sql
SELECT
  DATE_TRUNC(order_date, QUARTER) AS quarter,
  SUM(revenue) AS revenue
FROM orders
GROUP BY quarter
ORDER BY quarter;
```

---

# 📅 139. CA par weekday

```sql
SELECT
  EXTRACT(DAYOFWEEK FROM order_date) AS day_of_week,
  SUM(revenue) AS revenue
FROM orders
GROUP BY day_of_week
ORDER BY day_of_week;
```

Attention à documenter la convention numérique.

Pour un dashboard, un label explicite peut être préférable.

---

# 🧠 140. Grouper par plusieurs dimensions temporelles

```sql
SELECT
  EXTRACT(YEAR FROM order_date) AS year,
  EXTRACT(MONTH FROM order_date) AS month,
  SUM(revenue) AS revenue
FROM orders
GROUP BY
  year,
  month
ORDER BY
  year,
  month;
```

Cela fonctionne.

Mais :

```sql
DATE_TRUNC(order_date, MONTH)
```

est souvent plus compact et garde un vrai type `DATE`.

---

# ============================================================
# PARTIE XVIII — DATA QUALITY SUR LES DATES
# ============================================================

# 🧪 141. Dates impossibles

Si une date est stockée en `DATE`, BigQuery empêche déjà de représenter :

```text
2026-02-31
```

Mais avec une source `STRING`, cette valeur peut exister.

---

# 🧪 142. Mesurer les dates non parsables

```sql
SELECT
  COUNTIF(
    raw_date IS NOT NULL
    AND SAFE_CAST(raw_date AS DATE) IS NULL
  ) AS invalid_date_count
FROM raw_orders;
```

---

# 🧪 143. Dates dans le futur

Pour un champ :

```text
birth_date
```

```sql
SELECT
  COUNTIF(birth_date > CURRENT_DATE()) AS future_birth_dates
FROM customers;
```

---

# 🧪 144. Date de livraison avant commande

```sql
SELECT
  COUNTIF(
    delivery_date < order_date
  ) AS invalid_delivery_dates
FROM orders;
```

---

# 🧪 145. Distribution des dates

```sql
SELECT
  MIN(order_date) AS min_date,
  MAX(order_date) AS max_date,
  COUNT(*) AS rows
FROM orders;
```

Très utile pour détecter :

```text
date 1900 inattendue
date 2099
trou de données
source interrompue
```

---

# ============================================================
# PARTIE XIX — STRING DATA QUALITY
# ============================================================

# 🧪 146. Chaînes vides

```sql
SELECT
  COUNTIF(TRIM(customer_name) = '') AS empty_names
FROM customers;
```

---

# 🧪 147. Valeurs distinctes après normalisation

```sql
SELECT
  LOWER(TRIM(country)) AS normalized_country,
  COUNT(*) AS rows
FROM customers
GROUP BY normalized_country
ORDER BY rows DESC;
```

Permet de découvrir :

```text
france
FRANCE
 France
france 
```

comme variations d'un même concept.

---

# 🧪 148. Email pattern

```sql
SELECT
  COUNTIF(
    NOT REGEXP_CONTAINS(
      email,
      r'^([\w.+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})$'
    )
  ) AS suspicious_email_formats
FROM customers
WHERE email IS NOT NULL;
```

Ce n'est qu'un contrôle de forme.

---

# ============================================================
# PARTIE XX — ANTI-PATTERNS
# ============================================================

# 🚨 149. Anti-pattern — comparer des dates comme du texte

Éviter :

```sql
WHERE date_string > '01/12/2025'
```

sur un format non ISO.

Lexicographiquement, les chaînes ne suivent pas forcément l'ordre chronologique.

Convertir vers :

```text
DATE
DATETIME
TIMESTAMP
```

avant l'analyse.

---

# 🚨 150. Anti-pattern — stocker année/mois/jour séparés sans reconstruire une date

Des colonnes :

```text
year
month
day
```

peuvent être nécessaires à la source.

Mais pour l'analyse :

```sql
DATE(year, month, day)
```

permet d'obtenir un vrai type `DATE`.

---

# 🚨 151. Anti-pattern — utiliser `FORMAT_DATE` trop tôt

```sql
FORMAT_DATE('%d/%m/%Y', order_date)
```

est idéal pour l'affichage.

Mais si on doit encore :

```text
filtrer
agréger
soustraire
trier chronologiquement
```

garder le `DATE` natif jusqu'à la couche de présentation.

---

# 🚨 152. Anti-pattern — `EXTRACT(MONTH)` sans penser à l'année

Cette requête :

```sql
GROUP BY EXTRACT(MONTH FROM order_date)
```

fusionne les années.

Parfait pour :

```text
saisonnalité
```

incorrect pour :

```text
série temporelle mensuelle
```

---

# 🚨 153. Anti-pattern — `WHERE` et agrégat

Invalide :

```sql
WHERE SUM(revenue) > 1000
```

Utiliser :

```sql
HAVING SUM(revenue) > 1000
```

après l'agrégation.

---

# 🚨 154. Anti-pattern — confondre `COUNT(*)` et `COUNT(column)`

```sql
COUNT(*)
```

compte les lignes.

```sql
COUNT(column)
```

compte les valeurs non nulles de cette expression.

Cette différence peut complètement modifier un KPI.

---

# 🚨 155. Anti-pattern — regex pour tout

Ne pas utiliser :

```sql
REGEXP_CONTAINS
```

si une fonction beaucoup plus simple exprime mieux le besoin.

Préférer :

```text
=
STARTS_WITH
ENDS_WITH
CONTAINS_SUBSTR
LIKE
```

quand cela suffit.

Le code sera plus facile à lire.

---

# 🚨 156. Anti-pattern — masquer les erreurs avec `SAFE_*`

`SAFE_CAST` ou `SAFE_DIVIDE` évitent une erreur runtime.

Ils ne doivent pas transformer :

```text
un problème de data quality
```

en :

```text
NULL silencieux jamais mesuré
```

Toujours monitorer si ces cas sont importants.

---

# ============================================================
# PARTIE XXI — PATTERNS MÉTIER
# ============================================================

# 💼 157. Délai moyen de livraison

```sql
SELECT
  AVG(
    DATE_DIFF(
      delivery_date,
      purchase_date,
      DAY
    )
  ) AS avg_delivery_days
FROM orders
WHERE delivery_date IS NOT NULL;
```

---

# 💼 158. Délai par mois de commande

```sql
SELECT
  DATE_TRUNC(purchase_date, MONTH) AS month,
  AVG(
    DATE_DIFF(
      delivery_date,
      purchase_date,
      DAY
    )
  ) AS avg_delivery_days
FROM orders
WHERE delivery_date IS NOT NULL
GROUP BY month
ORDER BY month;
```

---

# 💼 159. Clients actifs sur les 90 derniers jours

```sql
SELECT
  customer_id,
  MAX(order_date) AS last_order_date
FROM orders
GROUP BY customer_id
HAVING last_order_date >= DATE_SUB(
  CURRENT_DATE(),
  INTERVAL 90 DAY
);
```

---

# 💼 160. Cohorte d'acquisition

```sql
WITH customers AS (
  SELECT
    customer_id,
    MIN(order_date) AS first_order_date
  FROM orders
  GROUP BY customer_id
)

SELECT
  customer_id,
  DATE_TRUNC(first_order_date, MONTH) AS acquisition_month
FROM customers;
```

---

# 💼 161. Saisonnalité par weekday

```sql
SELECT
  EXTRACT(DAYOFWEEK FROM order_date) AS weekday,
  COUNT(*) AS orders,
  SUM(revenue) AS revenue
FROM orders
GROUP BY weekday
ORDER BY weekday;
```

---

# 🏦 162. Exemples banking

## Ancienneté client

```sql
DATE_DIFF(
  CURRENT_DATE(),
  onboarding_date,
  DAY
)
```

## Volume de transactions mensuel

```sql
DATE_TRUNC(transaction_date, MONTH)
```

## Dernière activité

```sql
MAX(transaction_date)
```

## Durée entre deux étapes de dossier

```sql
DATE_DIFF(
  approval_date,
  application_date,
  DAY
)
```

## Filtre d'année comptable

```sql
WHERE accounting_date >= DATE '2026-01-01'
  AND accounting_date <  DATE '2027-01-01'
```

---

# ============================================================
# PARTIE XXII — REQUÊTES COMPLÈTES
# ============================================================

# 🧱 163. Analyse mensuelle complète

```sql
SELECT
  DATE_TRUNC(order_date, MONTH) AS month,
  COUNT(*) AS order_lines,
  COUNT(DISTINCT order_id) AS orders,
  COUNT(DISTINCT customer_id) AS customers,
  ROUND(SUM(revenue), 2) AS revenue,
  ROUND(AVG(revenue), 2) AS avg_line_revenue

FROM sales

WHERE order_date >= DATE '2026-01-01'
  AND order_date <  DATE '2027-01-01'

GROUP BY month

HAVING SUM(revenue) > 0

ORDER BY month;
```

---

# 🧠 164. Lecture de la requête

```text
FROM sales
↓
prendre les ventes

WHERE
↓
garder uniquement 2026

GROUP BY month
↓
1 ligne = 1 mois

COUNT / SUM / AVG
↓
calculer les KPI

HAVING
↓
éliminer les mois sans CA

ORDER BY
↓
ordre chronologique
```

---

# 🧱 165. Nettoyage de chaîne + date

```sql
WITH cleaned AS (
  SELECT
    customer_id,

    NORMALIZE_AND_CASEFOLD(
      TRIM(customer_name)
    ) AS customer_name_clean,

    SAFE_CAST(raw_order_date AS DATE) AS order_date

  FROM raw_orders
)

SELECT
  *
FROM cleaned;
```

---

# 🧱 166. Parsing d'une date non standard

```sql
SELECT
  PARSE_DATE(
    '%A, %e %B %Y',
    date_purchase
  ) AS date_purchase
FROM raw_fruit;
```

---

# 🧱 167. Regex + normalisation

```sql
SELECT
  email,

  REGEXP_CONTAINS(
    NORMALIZE_AND_CASEFOLD(TRIM(email)),
    r'^([\w.+-]+@[a-z0-9.-]+\.[a-z]{2,})$'
  ) AS email_format_ok

FROM customers;
```

---

# ============================================================
# PARTIE XXIII — DEBUG SQL
# ============================================================

# 🐛 168. Lire les messages d'erreur

Le cours insiste à raison :

> Les messages BigQuery sont souvent suffisamment précis pour identifier le problème.

Exemple :

```text
SELECT list expression references column X
which is neither grouped nor aggregated
```

Cela signifie généralement :

```text
colonne présente dans SELECT
↓
requête agrégée
↓
colonne ni dans GROUP BY
ni dans une fonction agrégée
```

---

# 🧠 169. Méthode de debug

Face à une requête complexe :

```text
1. lancer le FROM + SELECT minimal
2. vérifier les types
3. ajouter WHERE
4. ajouter transformations
5. ajouter GROUP BY
6. ajouter agrégations
7. ajouter HAVING
8. ajouter ORDER BY
```

Ne pas écrire 40 lignes avant le premier test.

---

# 🔬 170. Vérifier les types avec le schéma

Si une fonction échoue :

```text
avant de modifier la syntaxe
↓
vérifier le type réel de la colonne
```

Une colonne :

```text
2026-08-08
```

peut être :

```text
STRING
```

et non :

```text
DATE
```

---

# ============================================================
# PARTIE XXIV — CHECKLIST
# ============================================================

# ✅ 171. Checklist avant une agrégation

- [ ] Quelle est la granularité actuelle ?
- [ ] Quelle granularité veux-je obtenir ?
- [ ] Quelle(s) colonne(s) définissent le groupe ?
- [ ] Quelle fonction d'agrégation est correcte ?
- [ ] Les `NULL` ont-ils une signification métier ?
- [ ] Ai-je besoin de `COUNT(*)`, `COUNT(col)` ou `COUNT(DISTINCT col)` ?
- [ ] Le filtre doit-il être fait avant (`WHERE`) ou après (`HAVING`) ?

---

# ✅ 172. Checklist avant une transformation STRING

- [ ] Quelle est la valeur brute ?
- [ ] Espaces parasites ?
- [ ] Casse ?
- [ ] Unicode / accents ?
- [ ] Recherche littérale ou pattern ?
- [ ] `REPLACE` ou `REGEXP_REPLACE` ?
- [ ] Simple contains ou vraie regex ?
- [ ] La transformation doit-elle être centralisée en amont ?

---

# ✅ 173. Checklist avant une transformation DATE/TIME

- [ ] Type réel : `STRING`, `DATE`, `DATETIME`, `TIMESTAMP` ?
- [ ] Quelle timezone ?
- [ ] Ai-je besoin d'une date civile ou d'un instant absolu ?
- [ ] Parsing ou formatting ?
- [ ] `EXTRACT` ou `DATE_TRUNC` ?
- [ ] Suis-je en train de perdre l'année ?
- [ ] Quelle définition de la semaine ?
- [ ] Le filtre respecte-t-il la granularité temporelle ?
- [ ] La conversion peut-elle échouer ?
- [ ] Dois-je mesurer les valeurs invalides ?

---

# ============================================================
# PARTIE XXV — QUESTIONS D'ENTRETIEN
# ============================================================

# 🎤 174. `COUNT(*)` vs `COUNT(column)`

> `COUNT(*)` compte les lignes. `COUNT(column)` compte les lignes pour lesquelles l'expression n'est pas `NULL`.

---

# 🎤 175. `WHERE` vs `HAVING`

> `WHERE` filtre les lignes avant l'agrégation ; `HAVING` filtre les groupes après `GROUP BY` / agrégation.

---

# 🎤 176. Pourquoi une colonne du `SELECT` doit-elle être dans le `GROUP BY` ?

> Parce qu'une agrégation produit une ligne par groupe. Toute colonne non agrégée doit donc avoir une valeur déterminée pour ce groupe, ce qui est assuré en la mettant dans les clés de regroupement.

---

# 🎤 177. `DATE` vs `DATETIME` vs `TIMESTAMP`

> `DATE` représente un jour civil. `DATETIME` représente une date et une heure sans timezone intrinsèque. `TIMESTAMP` représente un instant absolu qui peut être affiché selon différents fuseaux horaires.

---

# 🎤 178. `PARSE_DATE` vs `FORMAT_DATE`

> `PARSE_DATE` convertit une chaîne vers un `DATE`. `FORMAT_DATE` convertit un `DATE` vers une chaîne de présentation.

---

# 🎤 179. `EXTRACT(MONTH)` vs `DATE_TRUNC(..., MONTH)`

> `EXTRACT(MONTH)` retourne le numéro du mois et supprime le contexte annuel. `DATE_TRUNC(date, MONTH)` retourne une date représentant le début du mois et conserve donc l'année.

---

# 🎤 180. Pourquoi `DATE_DIFF` peut surprendre ?

> Parce qu'il compte le nombre de frontières de la granularité demandée entre deux dates, ce qui peut différer d'une intuition basée sur une durée continue.

---

# 🎤 181. `REPLACE` vs `REGEXP_REPLACE`

> `REPLACE` recherche une sous-chaîne littérale. `REGEXP_REPLACE` recherche un pattern décrit par une expression régulière.

---

# 🎤 182. `LIKE` vs regex

> `LIKE` est adapté aux wildcards simples `%` et `_`. Les regex permettent des patterns plus expressifs : classes de caractères, alternatives, quantificateurs, ancres et groupes.

---

# ============================================================
# PARTIE XXVI — CHEAT SHEET
# ============================================================

# 🧾 183. Agrégations

```sql
COUNT(*)

COUNT(column)

COUNT(DISTINCT column)

COUNTIF(condition)

SUM(metric)

AVG(metric)

MIN(metric)

MAX(metric)
```

---

# 🧾 184. `GROUP BY`

```sql
SELECT
  category,
  SUM(metric) AS metric
FROM table
GROUP BY category;
```

---

# 🧾 185. `HAVING`

```sql
SELECT
  category,
  SUM(metric) AS total
FROM table
GROUP BY category
HAVING total > 100;
```

---

# 🧾 186. String cleaning

```sql
TRIM(value)

LOWER(value)

UPPER(value)

INITCAP(value)

REPLACE(value, 'old', 'new')

TRANSLATE(value, 'éèà', 'eea')
```

---

# 🧾 187. String composition

```sql
CONCAT(first_name, ' ', last_name)
```

---

# 🧾 188. Regex

```sql
REGEXP_CONTAINS(value, r'pattern')

REGEXP_EXTRACT(value, r'pattern')

REGEXP_REPLACE(value, r'pattern', 'replacement')
```

---

# 🧾 189. Date parsing

```sql
PARSE_DATE(
  '%Y-%m-%d',
  date_string
)
```

---

# 🧾 190. Date formatting

```sql
FORMAT_DATE(
  '%d/%m/%Y',
  date_col
)
```

---

# 🧾 191. Extract

```sql
EXTRACT(
  YEAR
  FROM date_col
)
```

---

# 🧾 192. Truncate

```sql
DATE_TRUNC(
  date_col,
  MONTH
)
```

---

# 🧾 193. Add / subtract

```sql
DATE_ADD(
  date_col,
  INTERVAL 1 MONTH
)

DATE_SUB(
  date_col,
  INTERVAL 30 DAY
)
```

---

# 🧾 194. Difference

```sql
DATE_DIFF(
  end_date,
  start_date,
  DAY
)
```

---

# 🧾 195. Current

```sql
CURRENT_DATE()

CURRENT_DATE('Europe/Zurich')

CURRENT_DATETIME()

CURRENT_TIMESTAMP()
```

---

# 🧾 196. Conversion

```sql
CAST(value AS DATE)

SAFE_CAST(value AS DATE)

DATE(timestamp_col, 'Europe/Zurich')
```

---

# ============================================================
# PARTIE XXVII — CARTE MENTALE
# ============================================================

# 🗺 197. Carte mentale finale

```text
SQL FUNCTIONS
│
├── AGGREGATIONS
│   │
│   ├── COUNT
│   ├── SUM
│   ├── AVG
│   ├── MIN
│   └── MAX
│
│   GROUP BY
│      ↓
│   HAVING
│
├── STRINGS
│   │
│   ├── CONCAT
│   ├── TRIM
│   ├── LOWER / UPPER
│   ├── REPLACE
│   ├── TRANSLATE
│   ├── NORMALIZE
│   │
│   └── REGEXP
│       ├── CONTAINS
│       ├── EXTRACT
│       └── REPLACE
│
└── TEMPORAL
    │
    ├── DATE
    ├── TIME
    ├── DATETIME
    └── TIMESTAMP
        │
        ├── PARSE
        ├── FORMAT
        ├── EXTRACT
        ├── TRUNC
        ├── ADD
        ├── SUB
        ├── DIFF
        └── LAST_DAY
```

---

# 💡 198. Ce que j'ai retenu

- Une fonction SQL doit être choisie en fonction du **type réel** de la donnée.
- `COUNT(*)` compte les lignes ; `COUNT(column)` ignore les `NULL`.
- `GROUP BY` change la granularité du résultat.
- Une colonne non agrégée du `SELECT` doit généralement appartenir au `GROUP BY`.
- `WHERE` filtre **avant** l'agrégation.
- `HAVING` filtre **après** l'agrégation.
- `NULL`, `0` et `''` ne sont pas équivalents.
- `REPLACE` travaille sur du texte littéral ; `REGEXP_REPLACE` sur un pattern.
- Pour une recherche simple, une regex n'est pas toujours nécessaire.
- BigQuery utilise la syntaxe regex RE2.
- `DATE`, `TIME`, `DATETIME` et `TIMESTAMP` décrivent des concepts temporels différents.
- `TIMESTAMP` représente un instant absolu ; `DATETIME` n'embarque pas de timezone.
- `PARSE_DATE` transforme une `STRING` en `DATE`.
- `FORMAT_DATE` transforme un `DATE` en `STRING`.
- `EXTRACT` récupère une composante et peut volontairement perdre une partie du contexte temporel.
- `DATE_TRUNC` conserve une période calendaire typée.
- `EXTRACT(MONTH)` et `DATE_TRUNC(..., MONTH)` ne répondent pas à la même question analytique.
- `DATE_DIFF(end, start, part)` compte les frontières de la granularité choisie.
- Une timezone doit faire partie du raisonnement dès qu'on manipule des instants.
- Les fonctions `SAFE_*` sont utiles, mais les erreurs qu'elles absorbent doivent parfois être mesurées comme problèmes de qualité.

---

# ❓ 199. Questions / points à garder en tête

- [ ] Quelle convention de semaine utilise l'entreprise : dimanche, lundi, ISO ?
- [ ] Quelle timezone métier est utilisée dans les différents systèmes ?
- [ ] Les colonnes `DATETIME` de nos sources ont-elles une timezone implicite documentée ?
- [ ] Dans quelles tables BigQuery les colonnes de date sont-elles des clés de partition ?
- [ ] Quand préférer `NORMALIZE_AND_CASEFOLD` à `LOWER` ?
- [ ] Quels contrôles de date sont critiques dans un contexte bancaire ?
- [ ] Quels champs temporels doivent être conservés en UTC ?
- [ ] Quelle couche du pipeline est responsable du formatting de présentation ?

---

# ✅ 200. Actions post-session

- [ ] Refaire un exemple `COUNT(*)` vs `COUNT(column)` avec `NULL`.
- [ ] Refaire `WHERE` vs `HAVING` sur le même dataset.
- [ ] Construire une requête mensuelle avec `DATE_TRUNC`.
- [ ] Comparer le résultat avec `EXTRACT(MONTH)`.
- [ ] Parser trois formats de dates différents.
- [ ] Écrire une validation simple avec `REGEXP_CONTAINS`.
- [ ] Tester une clé candidate avec `COUNT(*)`, `COUNT(DISTINCT)` et `GROUP BY`.
- [ ] Tester `CURRENT_DATE()` vs `CURRENT_DATE('Europe/Zurich')`.
- [ ] Construire un contrôle `SAFE_CAST` pour une date brute.

---

# 🔗 201. Liens avec les autres notions du Brocode

```text
01–02 — SQL basics
│
├── SELECT
├── WHERE
├── types
└── functions
        ↓
06 — Aggregations / String / Date & Time
│
├── GROUP BY
├── HAVING
├── cleaning
├── temporal analytics
└── Data Quality
        ↓
03 — JOINs
│
└── granularité
        ↓
04 — CTE / Subqueries
│
└── étapes analytiques
        ↓
05 — Window Functions
│
└── agrégation sans perdre la granularité
        ↓
dbt / Warehousing / BI
```

---

# 🔬 202. Précisions techniques ajoutées au Brocode

Par rapport aux slides et à la transcription, les points suivants ont été clarifiés pour correspondre au comportement GoogleSQL / BigQuery :

```text
1. COUNT(*) compte toutes les lignes, indépendamment des NULL contenus
   dans leurs colonnes.

2. BOOL est un type distinct, pas un sous-type numérique.

3. YEAR / MONTH / DAY / HOUR sont des date/time parts ou granularités,
   pas des types de données.

4. La fonction BigQuery est AVG(), pas AVERAGE().

5. EXTRACT peut travailler selon sa signature sur DATE, TIME,
   DATETIME et TIMESTAMP : il n'exige pas systématiquement DATETIME.

6. DATE_TRUNC et EXTRACT(MONTH) ont des sémantiques très différentes :
   DATE_TRUNC conserve le contexte de période, EXTRACT retourne
   uniquement la composante.

7. DATE_DIFF compte des frontières de granularité, ce qui est
   particulièrement important pour WEEK / ISOWEEK / YEAR.

8. CURRENT_DATE() utilise UTC par défaut si aucune timezone n'est fournie.

9. FORMAT_DATE retourne une STRING ; il est donc préférable de conserver
   le type DATE pendant les transformations analytiques et de formatter
   principalement pour la présentation.

10. BigQuery utilise RE2 pour ses expressions régulières.

11. REGEXP_CONTAINS effectue un match partiel par défaut ; ^ et $
    servent à encadrer un full match.

12. TRANSLATE effectue un mapping caractère par caractère et ne remplace
    pas une vraie stratégie de normalisation Unicode générale.

13. NORMALIZE_AND_CASEFOLD est disponible pour les comparaisons
    normalisées insensibles à la casse.

14. Les alias du SELECT sont utilisables dans HAVING / GROUP BY /
    ORDER BY dans BigQuery, mais pas dans WHERE.
```

---

# 🏁 203. Résumé en une phrase

> **Bien manipuler les dates et les fonctions SQL revient d'abord à maîtriser les types et la granularité : on filtre les lignes avec `WHERE`, on agrège avec `GROUP BY`, on filtre les agrégats avec `HAVING`, on normalise le texte avec les fonctions `STRING`, et on choisit entre `EXTRACT`, `DATE_TRUNC`, parsing, formatting et arithmétique temporelle selon la question métier exacte.**
