---
title: "SQL — CTEs, Subqueries & UNION"
aliases:
  - "SQL CTEs"
  - "SQL Subqueries"
  - "CTEs Subqueries UNION"
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 8
language: "SQL"
database: "BigQuery / GoogleSQL"
topics:
  - "SQL"
  - "BigQuery"
  - "CTEs"
  - "Subqueries"
  - "UNION"
tags:
  - brocode
  - wagon2321/cours
  - sql
  - bigquery
  - ctes
  - subqueries
  - union
---

# 📝 08 — SQL · CTEs, Subqueries & UNION

> [!info] Navigation Brocode
> **← Précédent :** [[07_joins_and_testing_sol|07 — SQL · JOINs & Testing]] · **Suivant → :** [[09_udf_window_functions_sol|09 — SQL · UDFs & Window Functions]]
>
> [!tip] Navigation Obsidian
> Utilise l’**Outline** pour parcourir les sections, `Cmd/Ctrl + O` pour le Quick Switcher et les **backlinks** pour retrouver les connexions entre notes.

---

> [!abstract] Objectif du chapitre
> **Objectif du chapitre :** apprendre à découper une requête SQL complexe en étapes lisibles grâce aux **CTEs**, comprendre les différentes formes de **sous-requêtes**, savoir choisir entre `JOIN`, CTE et nested subquery, et maîtriser les opérations verticales `UNION ALL` / `UNION DISTINCT` sans casser la granularité ni introduire de doublons.

---

## 🧭 0. Où se situe ce chapitre ?

Le chapitre précédent introduisait les **JOINs** et surtout une idée fondamentale :

```text
le vrai danger d'une jointure
≠
la syntaxe du JOIN

le vrai danger
=
la granularité + la cardinalité + les duplications
```

Dans ce chapitre, on ajoute les outils permettant de **préparer** les données avant une jointure ou avant un calcul supplémentaire.

```text
Table brute
   │
   ├── GROUP BY
   │
   ├── calcul
   │
   ├── filtre
   │
   ▼
CTE / subquery
   │
   ├── JOIN
   │
   ├── nouveau calcul
   │
   ▼
résultat final
```

Les notions principales sont :

```text
CTE
Subquery
Nested subquery
UNION ALL
UNION DISTINCT
Granularité
GROUP BY
JOIN
```

Le fil conducteur du cours est particulièrement important :

> **Faire une opération intermédiaire sans être obligé d'enregistrer physiquement une nouvelle table à chaque étape.**

---

## 🔁 1. Rappel : éviter `SELECT *`

Dans les exercices précédents, `SELECT *` était pratique pour apprendre.

En production, c'est rarement une bonne habitude.

```sql
SELECT *
FROM sales AS s
LEFT JOIN orders AS o
  ON s.orders_id = o.orders_id;
```

Cette requête peut récupérer :

- toutes les colonnes de `sales`;
- toutes les colonnes de `orders`;
- des colonnes inutiles ;
- des colonnes portant le même nom ;
- plus de données que nécessaire.

Préférer :

```sql
SELECT
  s.orders_id,
  s.turnover,
  s.product_id,
  o.shipping_fee
FROM sales AS s
LEFT JOIN orders AS o
  ON s.orders_id = o.orders_id;
```

### Pourquoi ?

Parce qu'on sait immédiatement :

```text
quelle colonne
vient de
quelle table
```

et parce que la requête exprime mieux son intention métier.

---

## 🏷 2. Construire une requête avec les alias

Le formateur conseille une méthode très pratique :

```text
1. identifier les tables
2. écrire FROM / JOIN
3. créer les alias
4. utiliser l'autocomplétion
5. construire SELECT
```

Exemple :

```sql
FROM buyers AS bu
LEFT JOIN purchases AS pu
  ON bu.id = pu.buyer_id
```

Ensuite :

```sql
SELECT
  bu.name,
  bu.surname,
  pu.quantity
FROM buyers AS bu
LEFT JOIN purchases AS pu
  ON bu.id = pu.buyer_id;
```

Cette méthode devient particulièrement utile quand une requête contient :

```text
3 tables
+
4 JOINs
+
plusieurs CTEs
+
20 colonnes
```

---

## 🔬 3. Granularité : le prérequis indispensable

La **granularité**, la **maille** ou le **niveau de détail** décrivent ce que représente **une ligne**.

Exemple :

```text
buyer_name | purchase_date | quantity
-----------|---------------|---------
Louis      | 2026-07-01    | 2
Louis      | 2026-07-04    | 3
```

Ici :

```text
1 ligne ≠ 1 buyer
```

Une ligne représente plutôt :

```text
1 buyer × 1 date d'achat
```

La granularité est donc plus fine que le buyer seul.

---

### Réduire la granularité

Si on souhaite :

```text
1 ligne = 1 buyer
```

on peut agréger :

```sql
SELECT
  buyer_id,
  SUM(quantity) AS total_quantity
FROM purchases
GROUP BY buyer_id;
```

Résultat :

```text
buyer_id | total_quantity
---------|---------------
1        | 5
2        | 8
3        | 2
```

La table est maintenant à la maille :

```text
buyer_id
```

---

## 🧮 4. Agrégation et `GROUP BY`

Une fonction comme :

```sql
SUM()
AVG()
COUNT()
MIN()
MAX()
```

agrège plusieurs lignes.

Exemple :

```sql
SELECT
  orders_id,
  SUM(turnover) AS total_turnover
FROM sales
GROUP BY orders_id;
```

Si `orders_id = 451` existe sur plusieurs produits :

```text
orders_id | product_id | turnover
----------|------------|---------
451       | 6532       | 39.40
451       | 1068       | 55.20
```

le résultat devient :

```text
orders_id | total_turnover
----------|---------------
451       | 94.60
```

La granularité passe de :

```text
order × product
```

à :

```text
order
```

---

### ⚠️ Correction Brocode : agrégation ≠ toujours `GROUP BY`

Le cours utilise souvent le raccourci :

> « une agrégation implique un `GROUP BY` »

C'est vrai **si l'on retourne aussi des colonnes non agrégées**.

Par exemple :

```sql
SELECT SUM(turnover)
FROM sales;
```

est parfaitement valide sans `GROUP BY`.

En revanche :

```sql
SELECT
  orders_id,
  SUM(turnover)
FROM sales;
```

nécessite :

```sql
GROUP BY orders_id
```

car `orders_id` n'est pas agrégé.

---

## 🏷 5. Bien nommer les colonnes agrégées

Éviter :

```sql
SUM(turnover) AS turnover
```

Préférer :

```sql
SUM(turnover) AS total_turnover
```

Pourquoi ?

Parce que :

```text
turnover
```

peut signifier :

```text
turnover d'une ligne
```

alors que :

```text
total_turnover
```

indique clairement :

```text
valeur déjà agrégée
```

Cette distinction devient essentielle quelques CTEs plus tard.

---

## 🧠 6. Pourquoi les CTEs existent-elles ?

Avant les CTEs, on pourrait construire un pipeline comme ceci :

```text
query 1
   ↓
enregistrer table_A
   ↓
query 2
   ↓
enregistrer table_B
   ↓
query 3
   ↓
résultat
```

Exemple :

```text
sales
   ↓ GROUP BY
sales_by_order
   ↓ JOIN
orders_enriched
   ↓ calcul margin
orders_margin
```

Cela fonctionne, mais crée de nombreuses tables intermédiaires.

Une **CTE** permet de garder ces étapes dans **une seule requête**.

```text
query unique
│
├── CTE 1
├── CTE 2
├── CTE 3
│
└── SELECT final
```

---

## 🧱 7. CTE — Common Table Expression

CTE signifie :

```text
Common Table Expression
```

Une CTE est une **requête nommée** définie dans une clause `WITH`.

Syntaxe :

```sql
WITH reference_for_cte AS (
  SELECT
    ...
  FROM source_table
)

SELECT
  ...
FROM reference_for_cte;
```

Le nom :

```text
reference_for_cte
```

devient ensuite utilisable comme une table dans la requête qui suit.

---

## 🧩 8. Lire une CTE mentalement

Prenons :

```sql
WITH sales_by_order AS (
  SELECT
    orders_id,
    SUM(turnover) AS total_turnover
  FROM sales
  GROUP BY orders_id
)

SELECT
  orders_id,
  total_turnover
FROM sales_by_order;
```

On peut la lire comme :

```text
ÉTAPE 1
Créer un résultat appelé sales_by_order

ÉTAPE 2
Dans ce résultat :
    une ligne = un order_id
    total_turnover = somme du turnover

ÉTAPE 3
Interroger sales_by_order
```

La CTE devient donc un **nom intermédiaire dans le raisonnement**.

---

## ⚠️ 9. CTE ≠ vraie table temporaire matérialisée

Le cours présente la CTE comme :

> une table temporaire stockée pendant l'exécution.

C'est un bon **modèle mental**, mais il faut ajouter une précision importante pour BigQuery.

> 🧠 **Correction / complément Brocode — BigQuery**

Une CTE non récursive n'est pas forcément matérialisée comme une vraie table temporaire physique.

Elle agit comme :

```text
un résultat de sous-requête nommé
```

que le moteur peut intégrer dans le plan d'exécution.

En BigQuery, les CTEs non récursives sont principalement un outil de :

```text
lisibilité
organisation
modularité
```

et non une garantie d'optimisation.

Si la même CTE est référencée plusieurs fois, BigQuery peut devoir la réévaluer plusieurs fois.

Donc :

```text
CTE
≠
cache automatique
```

et :

```text
CTE
≠
garantie de réduction du coût
```

Pour réutiliser plusieurs fois un calcul réellement coûteux, une :

```text
TEMP TABLE
table matérialisée
materialized view
```

peut parfois être plus adaptée.

---

## 🎯 10. Premier grand cas d'usage : `GROUP BY` puis `JOIN`

C'est **le cas central du cours**.

Supposons :

```text
sales
```

avec une granularité :

```text
1 ligne = 1 produit d'une commande
```

et :

```text
operational
```

avec :

```text
1 ligne = 1 commande
```

---

### Table `sales`

```text
orders_id | product_id | turnover
----------|------------|---------
451       | 6532       | 39.40
451       | 1068       | 55.20
623       | 6532       | 30.10
623       | 1068       | 40.00
```

Granularité :

```text
order × product
```

---

### Table `operational`

```text
orders_id | logistic_cost | shipping_fee
----------|---------------|-------------
451       | 4.50          | 7.00
623       | 5.00          | 8.00
```

Granularité :

```text
order
```

---

## 💥 11. Le problème : joindre avant d'agréger

Si on fait directement :

```sql
SELECT
  s.orders_id,
  s.turnover,
  o.logistic_cost,
  o.shipping_fee
FROM sales AS s
LEFT JOIN operational AS o
USING (orders_id);
```

on obtient :

```text
451 | 39.40 | 4.50 | 7.00
451 | 55.20 | 4.50 | 7.00
```

Les coûts sont répétés.

---

### Calcul faux

Si on écrit ensuite :

```sql
SUM(logistic_cost)
```

on obtient pour `451` :

```text
4.50 + 4.50 = 9.00
```

alors que la commande n'a coûté que :

```text
4.50
```

Le JOIN n'est pas syntaxiquement faux.

Le problème est :

```text
granularité incompatible
```

---

## ✅ 12. Solution : pré-agréger dans une CTE

On ramène d'abord `sales` à la granularité de `operational`.

```sql
WITH sales_by_order AS (
  SELECT
    orders_id,
    SUM(turnover) AS total_turnover
  FROM sales
  GROUP BY orders_id
)

SELECT
  s.orders_id,
  s.total_turnover,
  o.logistic_cost,
  o.shipping_fee
FROM sales_by_order AS s
LEFT JOIN operational AS o
USING (orders_id);
```

Maintenant :

```text
sales_by_order
1 ligne = 1 order
```

et :

```text
operational
1 ligne = 1 order
```

La relation devient beaucoup plus sûre :

```text
1:1
```

---

## 🧠 13. Mémo du cours

Le raccourci pédagogique à retenir :

```text
GROUP BY
+
JOIN
=
penser CTE
```

Ce n'est pas une obligation syntaxique.

C'est une excellente alerte mentale :

> « Est-ce que je dois d'abord mettre les deux tables à la même granularité ? »

---

## 🧮 14. Calculer la marge après la CTE

Après l'agrégation, on peut calculer :

```text
margin
=
turnover
-
logistic_cost
-
shipping_fee
```

```sql
WITH sales_by_order AS (
  SELECT
    orders_id,
    SUM(turnover) AS total_turnover
  FROM sales
  GROUP BY orders_id
)

SELECT
  s.orders_id,
  s.total_turnover,
  o.logistic_cost,
  o.shipping_fee,
  s.total_turnover
    - o.logistic_cost
    - o.shipping_fee AS margin
FROM sales_by_order AS s
LEFT JOIN operational AS o
USING (orders_id);
```

---

## 🔗 15. Deuxième grand cas d'usage : réutiliser un calcul

Supposons :

```sql
SELECT
  orders_id,
  turnover,
  purchase_cost,
  turnover - purchase_cost AS margin
FROM orders;
```

On souhaite maintenant calculer :

```text
margin_percentage
=
margin / turnover
```

L'idée naturelle serait :

```sql
SELECT
  orders_id,
  turnover,
  turnover - purchase_cost AS margin,
  SAFE_DIVIDE(margin, turnover) AS margin_percentage
FROM orders;
```

Mais `margin` est créé dans **ce même `SELECT`**.

Il n'est pas disponible comme entrée pour l'expression suivante dans la même liste `SELECT`.

---

## ✅ 16. Résoudre le problème avec une CTE

```sql
WITH margin_cte AS (
  SELECT
    orders_id,
    turnover,
    turnover - purchase_cost AS margin
  FROM orders
)

SELECT
  orders_id,
  turnover,
  margin,
  SAFE_DIVIDE(margin, turnover) AS margin_percentage
FROM margin_cte;
```

On sépare le raisonnement :

```text
Étape 1
calculer margin

Étape 2
utiliser margin
```

C'est beaucoup plus lisible.

---

## 🛡 17. `SAFE_DIVIDE`

Dans BigQuery :

```sql
SAFE_DIVIDE(x, y)
```

effectue une division mais évite que la requête échoue sur certains cas problématiques comme une division par zéro.

Exemple :

```sql
SAFE_DIVIDE(margin, turnover)
```

Si :

```text
turnover = 0
```

on préfère obtenir un résultat sûr (`NULL`) plutôt qu'une erreur bloquant toute la requête.

---

## 🪜 18. Enchaîner plusieurs CTEs

On ne répète pas `WITH`.

Syntaxe :

```sql
WITH cte_1 AS (
  ...
),

cte_2 AS (
  ...
),

cte_3 AS (
  ...
)

SELECT ...
FROM cte_3;
```

---

### Exemple

```sql
WITH sales_by_order AS (
  SELECT
    orders_id,
    SUM(turnover) AS total_turnover
  FROM sales
  GROUP BY orders_id
),

orders_margin AS (
  SELECT
    s.orders_id,
    s.total_turnover,
    o.logistic_cost,
    o.shipping_fee,
    s.total_turnover
      - o.logistic_cost
      - o.shipping_fee AS margin
  FROM sales_by_order AS s
  LEFT JOIN operational AS o
  USING (orders_id)
),

orders_kpi AS (
  SELECT
    *,
    SAFE_DIVIDE(margin, total_turnover) AS margin_percentage
  FROM orders_margin
)

SELECT
  orders_id,
  total_turnover,
  logistic_cost,
  shipping_fee,
  margin,
  margin_percentage
FROM orders_kpi;
```

---

## 🧠 19. Lire une chaîne de CTEs comme un pipeline

La requête précédente correspond à :

```text
sales
  │
  │ GROUP BY order
  ▼
sales_by_order
  │
  │ JOIN operational
  ▼
orders_margin
  │
  │ SAFE_DIVIDE
  ▼
orders_kpi
  │
  ▼
SELECT final
```

Chaque CTE doit idéalement avoir :

```text
un rôle
une granularité
un nom clair
```

---

## 🏷 20. Bien nommer les CTEs

Mauvais :

```text
cte1
cte2
temp
toto
test
query_final2
```

Mieux :

```text
sales_by_order
orders_with_costs
orders_margin
customers_monthly
products_clean
```

Le nom doit décrire :

```text
ce que représente le dataset
```

et parfois sa granularité :

```text
sales_by_order
sales_by_product
sales_by_customer_month
```

---

## 🧱 21. Une CTE peut dépendre d'une CTE précédente

```sql
WITH base AS (
  SELECT ...
),

clean AS (
  SELECT ...
  FROM base
),

aggregated AS (
  SELECT ...
  FROM clean
)

SELECT *
FROM aggregated;
```

Dans une chaîne non récursive classique :

```text
base
  ↓
clean
  ↓
aggregated
```

la dépendance va naturellement des CTEs définies plus tôt vers les suivantes.

---

## 🔁 22. CTE récursive — à connaître

Le cours mentionne l'existence d'autres sous-requêtes, notamment les CTEs récursives.

Une CTE récursive peut se référencer elle-même.

Exemple conceptuel :

```text
employee
   ↓ manager
manager
   ↓ manager
manager du manager
```

Ce type de requête est utile pour :

- organigrammes ;
- arbres ;
- graphes ;
- catégories imbriquées ;
- chemins hiérarchiques.

Syntaxe BigQuery :

```sql
WITH RECURSIVE ...
```

Ce n'est pas le sujet principal de ce chapitre, mais il est utile de reconnaître le terme.

---

## 🧩 23. CTE vs sous-requête : relation entre les concepts

Une **subquery** est une requête à l'intérieur d'une autre requête.

Une CTE contient elle-même une sous-requête nommée.

On peut visualiser la famille ainsi :

```text
Subqueries
│
├── CTEs
│   ├── non-recursive CTE
│   └── recursive CTE
│
├── scalar subqueries
├── IN subqueries
├── EXISTS subqueries
├── table subqueries
└── correlated subqueries
```

---

## 📦 24. Sous-requête dans le `WHERE`

Exemple du cours :

```sql
SELECT
  orders_id,
  turnover,
  margin
FROM sales
WHERE orders_id IN (
  SELECT orders_id
  FROM orders
  WHERE code = 'HAPPYHOUR'
);
```

La sous-requête retourne :

```text
liste d'orders_id
```

puis :

```sql
WHERE orders_id IN (...)
```

conserve les ventes dont l'ID apparaît dans cette liste.

---

## 🧠 25. Lire `WHERE ... IN (subquery)`

Mentalement :

```sql
SELECT orders_id
FROM orders
WHERE code = 'HAPPYHOUR'
```

donne par exemple :

```text
451
492
623
```

La requête externe devient conceptuellement :

```sql
WHERE orders_id IN (451, 492, 623)
```

---

## 🔄 26. Même logique avec un `JOIN`

On peut souvent réécrire :

```sql
SELECT
  s.orders_id,
  s.turnover,
  s.margin
FROM sales AS s
WHERE s.orders_id IN (
  SELECT o.orders_id
  FROM orders AS o
  WHERE o.code = 'HAPPYHOUR'
);
```

en :

```sql
SELECT
  s.orders_id,
  s.turnover,
  s.margin
FROM sales AS s
INNER JOIN orders AS o
  ON s.orders_id = o.orders_id
WHERE o.code = 'HAPPYHOUR';
```

Le JOIN permet aussi de récupérer :

```sql
o.code
o.transporter
o.shipping_fee
...
```

sans multiplier les sous-requêtes.

---

## ⚖️ 27. JOIN ou nested subquery ?

Le cours insiste sur la lisibilité du `JOIN`.

C'est un bon réflexe quand on veut réellement **enrichir une table avec les colonnes d'une autre table**.

```text
Besoin de colonnes de A + B
→ JOIN
```

Exemple :

```sql
SELECT
  s.orders_id,
  o.code,
  o.transporter,
  s.turnover,
  s.margin
FROM sales AS s
INNER JOIN orders AS o
USING (orders_id);
```

La provenance des colonnes est claire.

---

## ⚠️ 28. Correction Brocode : subquery ≠ automatiquement plus lente

Le cours présente parfois la règle :

```text
JOIN
=
toujours plus performant

subquery
=
toujours moins performant
```

C'est trop absolu.

> 🧠 **Complément Brocode — BigQuery**

Les optimiseurs SQL modernes peuvent réécrire certaines sous-requêtes et certains JOINs pour produire des plans d'exécution proches ou équivalents.

La performance dépend notamment de :

```text
volume lu
filtres
cardinalité
correlation
shuffle
partition pruning
clustering
répétition des calculs
plan d'exécution
```

Donc :

```text
JOIN n'est pas universellement plus rapide
```

et :

```text
subquery n'est pas universellement plus lente
```

En revanche, une **correlated subquery** mal conçue ou un même calcul répété peut être coûteux.

Le meilleur réflexe :

```text
1. choisir la forme la plus claire
2. vérifier la sémantique
3. regarder le query plan / coût si performance critique
```

---

## 🧮 29. Scalar subquery

Une sous-requête scalaire retourne une seule valeur.

Exemple :

```sql
SELECT
  product_id,
  price,
  (
    SELECT AVG(price)
    FROM products
  ) AS avg_price
FROM products;
```

La sous-requête :

```sql
SELECT AVG(price)
FROM products
```

retourne une valeur unique.

Cette valeur peut alors être utilisée comme une expression.

---

## 📋 30. `IN` subquery

Structure :

```sql
value IN (
  SELECT single_column
  FROM ...
)
```

Exemple :

```sql
SELECT *
FROM sales
WHERE orders_id IN (
  SELECT orders_id
  FROM orders
  WHERE code = 'HAPPYHOUR'
);
```

La sous-requête doit retourner une colonne comparable à :

```text
orders_id
```

---

## ✅ 31. `EXISTS` subquery

`EXISTS` répond à une question différente :

```text
Existe-t-il au moins une ligne correspondante ?
```

```sql
SELECT
  s.*
FROM sales AS s
WHERE EXISTS (
  SELECT 1
  FROM orders AS o
  WHERE o.orders_id = s.orders_id
    AND o.code = 'HAPPYHOUR'
);
```

Mentalement :

```text
pour chaque ligne de sales
vérifier si une commande correspondante existe
```

`EXISTS` est particulièrement utile pour des tests d'existence.

---

## 📦 32. Table subquery dans `FROM`

Une sous-requête peut aussi produire une table.

```sql
SELECT
  orders_id,
  total_turnover
FROM (
  SELECT
    orders_id,
    SUM(turnover) AS total_turnover
  FROM sales
  GROUP BY orders_id
);
```

C'est valide.

Mais une CTE peut être plus lisible :

```sql
WITH sales_by_order AS (
  SELECT
    orders_id,
    SUM(turnover) AS total_turnover
  FROM sales
  GROUP BY orders_id
)

SELECT
  orders_id,
  total_turnover
FROM sales_by_order;
```

---

## 🔗 33. Correlated subquery

Une correlated subquery référence une colonne de la requête externe.

Exemple :

```sql
SELECT
  s.orders_id,
  s.turnover,
  (
    SELECT o.code
    FROM orders AS o
    WHERE o.orders_id = s.orders_id
  ) AS code
FROM sales AS s;
```

Ici :

```text
s.orders_id
```

vient de la requête externe.

La sous-requête dépend donc de la ligne courante de `sales`.

---

## 🚨 34. Pourquoi les correlated subqueries demandent de l'attention

Une sous-requête corrélée peut être conceptuellement exécutée en fonction des lignes de la requête externe.

Selon le plan d'exécution, cela peut être coûteux.

Et surtout, elle peut devenir très difficile à lire :

```sql
SELECT
  s.orders_id,
  (
    SELECT o.code
    FROM orders AS o
    WHERE o.orders_id = s.orders_id
  ) AS code,
  (
    SELECT o.transporter
    FROM orders AS o
    WHERE o.orders_id = s.orders_id
  ) AS transporter
FROM sales AS s;
```

Ici on répète deux fois :

```text
orders
+
condition de relation
```

Un JOIN est beaucoup plus naturel :

```sql
SELECT
  s.orders_id,
  o.code,
  o.transporter
FROM sales AS s
LEFT JOIN orders AS o
  ON o.orders_id = s.orders_id;
```

---

## 🧠 35. Décider entre JOIN, CTE et subquery

### Utiliser un `JOIN` quand...

```text
Je dois combiner des colonnes de plusieurs tables.
```

Exemple :

```text
sales + orders + customers
```

---

### Utiliser une CTE quand...

```text
Je veux découper une requête complexe en étapes nommées.
```

Particulièrement utile pour :

```text
GROUP BY avant JOIN
calcul intermédiaire
nettoyage
enchaînement de transformations
debug
lisibilité
```

---

### Utiliser une nested subquery quand...

```text
Le raisonnement est local et compact.
```

Exemples :

```text
IN (...)
EXISTS (...)
valeur scalaire
petite table intermédiaire
```

---

## 🧭 36. Arbre de décision

```text
Ai-je besoin de colonnes de plusieurs tables ?
│
├── oui → JOIN
│
└── non
     │
     ├── ai-je plusieurs étapes de transformation ?
     │      ├── oui → CTE
     │      └── non
     │
     ├── ai-je seulement besoin d'un test d'existence ?
     │      └── EXISTS
     │
     ├── ai-je besoin d'une liste de valeurs ?
     │      └── IN (subquery)
     │
     └── ai-je besoin d'une valeur unique ?
            └── scalar subquery
```

---

## ⏱ 37. Ordre logique d'exécution SQL

Pour comprendre pourquoi certaines colonnes ne sont pas encore disponibles :

```text
FROM
→ JOIN / ON
→ WHERE
→ GROUP BY
→ HAVING
→ SELECT
→ DISTINCT
→ ORDER BY
→ LIMIT
```

C'est particulièrement important pour les alias calculés.

---

## ⚠️ 38. Alias créé dans le même `SELECT`

Exemple problématique :

```sql
SELECT
  turnover - purchase_cost AS margin,
  SAFE_DIVIDE(margin, turnover) AS margin_percentage
FROM orders;
```

`margin` est une **sortie** du `SELECT`.

Ce n'est pas une colonne d'entrée disponible pour une autre expression du même `SELECT`.

Une CTE résout cela :

```sql
WITH margin_cte AS (
  SELECT
    turnover,
    turnover - purchase_cost AS margin
  FROM orders
)

SELECT
  turnover,
  margin,
  SAFE_DIVIDE(margin, turnover) AS margin_percentage
FROM margin_cte;
```

---

## 🧰 39. CTE vs TEMP TABLE vs VIEW

Ces objets sont proches conceptuellement mais différents.

| Outil | Persiste ? | Principal usage |
|---|---:|---|
| CTE | ❌ | Structurer une requête |
| Subquery | ❌ | Logique locale imbriquée |
| TEMP TABLE | temporairement | Réutiliser un résultat matérialisé |
| VIEW | ✅ définition | Réutiliser une requête |
| Materialized view | ✅ résultat pré-calculé | Performance / accélération |

---

## 📌 40. CTE : portée

Une CTE existe seulement dans la requête où elle est définie.

```sql
WITH my_cte AS (
  SELECT ...
)

SELECT *
FROM my_cte;
```

Après la fin de la requête :

```text
my_cte
```

n'est pas une table du dataset.

---

## 👀 41. Comment inspecter une CTE pendant le développement ?

Le cours conseille de construire progressivement.

Commencer par :

```sql
SELECT
  orders_id,
  SUM(turnover) AS total_turnover
FROM sales
GROUP BY orders_id;
```

Vérifier le résultat.

Puis encapsuler :

```sql
WITH sales_by_order AS (
  SELECT
    orders_id,
    SUM(turnover) AS total_turnover
  FROM sales
  GROUP BY orders_id
)

SELECT *
FROM sales_by_order;
```

Ensuite seulement ajouter le JOIN.

C'est une excellente méthode de debug.

---

## 🐛 42. Débugger une requête à plusieurs CTEs

Supposons :

```text
raw
↓
clean
↓
aggregated
↓
joined
↓
final
```

Si `final` est faux :

```sql
SELECT *
FROM aggregated;
```

puis :

```sql
SELECT *
FROM joined;
```

permet de trouver l'étape qui introduit l'erreur.

---

## 🧪 43. Tester la granularité d'une CTE

Si :

```text
sales_by_order
```

est censée avoir :

```text
1 ligne = 1 orders_id
```

tester :

```sql
WITH sales_by_order AS (
  SELECT
    orders_id,
    SUM(turnover) AS total_turnover
  FROM sales
  GROUP BY orders_id
)

SELECT
  orders_id,
  COUNT(*) AS n
FROM sales_by_order
GROUP BY orders_id
HAVING COUNT(*) > 1;
```

Résultat attendu :

```text
0 ligne
```

---

## 🧪 44. Tester le nombre de lignes

Avant :

```sql
SELECT COUNT(*)
FROM operational;
```

Après jointure :

```sql
WITH sales_by_order AS (
  ...
)

SELECT COUNT(*)
FROM operational AS o
LEFT JOIN sales_by_order AS s
USING (orders_id);
```

Si la relation devait être `1:1`, le nombre de lignes ne devrait pas exploser.

---

## 🧪 45. Tester les métriques

Avant :

```sql
SELECT
  SUM(logistic_cost) AS logistic_cost
FROM operational;
```

Après :

```sql
WITH sales_by_order AS (
  ...
)

SELECT
  SUM(o.logistic_cost) AS logistic_cost
FROM sales_by_order AS s
LEFT JOIN operational AS o
USING (orders_id);
```

Si le montant double :

```text
⚠️ granularité / cardinalité à investiguer
```

---

## ↕️ 46. JOIN vs UNION

Une différence fondamentale :

```text
JOIN
=
combiner horizontalement
```

```text
UNION
=
empiler verticalement
```

---

### JOIN

```text
sales                products

order | product  +   product | name

           ↓ JOIN

order | product | name
```

On ajoute des colonnes.

---

### UNION

```text
january

date | order | turnover

+

february

date | order | turnover

          ↓

date | order | turnover
date | order | turnover
date | order | turnover
...
```

On ajoute des lignes.

---

## 🧱 47. `UNION ALL`

Syntaxe BigQuery :

```sql
SELECT
  date_purchase,
  orders_id,
  turnover
FROM orders_1

UNION ALL

SELECT
  date_purchase,
  orders_id,
  turnover
FROM orders_2;
```

`UNION ALL` conserve **toutes les lignes**.

Si une même ligne existe deux fois :

```text
elle apparaît deux fois
```

---

## 🎯 48. Cas d'usage de `UNION ALL`

Exemple :

```text
inventory_january
inventory_february
inventory_march
...
```

Objectif :

```text
inventory_year
```

```sql
SELECT * FROM inventory_january
UNION ALL
SELECT * FROM inventory_february
UNION ALL
SELECT * FROM inventory_march;
```

---

## 🧹 49. `UNION DISTINCT`

```sql
SELECT
  date_purchase,
  orders_id,
  turnover
FROM orders_1

UNION DISTINCT

SELECT
  date_purchase,
  orders_id,
  turnover
FROM orders_2;
```

`UNION DISTINCT` élimine les **lignes entièrement dupliquées**.

---

## ⚠️ 50. DISTINCT porte sur la ligne complète

Supposons :

```text
order | turnover
------+---------
451   | 100
451   | 120
```

Ces deux lignes ne sont pas des doublons.

Même si :

```text
orders_id
```

est identique.

Pour être supprimées par `UNION DISTINCT`, les lignes doivent être identiques sur les colonnes retournées par le set operation.

---

## 🚀 51. `UNION ALL` est souvent préférable

Si on sait que les datasets sont disjoints :

```text
janvier
février
mars
```

et qu'on veut conserver toutes les lignes :

```sql
UNION ALL
```

exprime clairement l'intention.

`UNION DISTINCT` nécessite une étape de déduplication.

Ne l'utiliser que lorsque la déduplication est réellement voulue.

---

## ⚠️ 52. Correction Brocode : les noms de colonnes n'ont pas besoin d'être identiques

Les slides indiquent :

```text
mêmes noms de colonnes
+
mêmes types
```

pour faire un `UNION`.

En BigQuery, le comportement par défaut est plus précis :

```text
les colonnes sont associées par POSITION
```

Il faut principalement :

```text
même nombre de colonnes
+
types compatibles par position
```

Exemple :

```sql
SELECT
  customer_id,
  revenue
FROM january

UNION ALL

SELECT
  client_id,
  turnover
FROM february;
```

peut fonctionner si :

```text
customer_id ↔ client_id
revenue     ↔ turnover
```

ont des types compatibles.

Le résultat prendra les noms de colonnes issus de la première requête.

---

## 🚨 53. Attention à l'ordre des colonnes

Ceci est dangereux :

```sql
SELECT
  orders_id,
  turnover
FROM table_a

UNION ALL

SELECT
  turnover,
  orders_id
FROM table_b;
```

Même si les colonnes semblent être les mêmes conceptuellement, elles ne sont pas dans le même ordre.

Le moteur associe par défaut :

```text
colonne 1 ↔ colonne 1
colonne 2 ↔ colonne 2
```

---

## 🏷 54. BigQuery : `UNION ... BY NAME`

BigQuery permet aussi d'aligner les colonnes par nom :

```sql
SELECT
  orders_id,
  turnover
FROM table_a

UNION ALL BY NAME

SELECT
  turnover,
  orders_id
FROM table_b;
```

Ici :

```text
orders_id ↔ orders_id
turnover  ↔ turnover
```

même si l'ordre diffère.

C'est une fonctionnalité très utile pour éviter des erreurs de positionnement.

---

## 🧩 55. Colonnes différentes entre les deux tables

Le cours indique qu'une colonne présente dans une seule table ne peut pas être unionnée directement.

C'est vrai avec un `UNION ALL` positionnel classique si les deux `SELECT` n'ont pas le même nombre de colonnes.

Exemple :

```text
orders_1
date | id | turnover | shipping_fee

orders_2
date | id | turnover
```

Ceci ne fonctionne pas directement :

```sql
SELECT *
FROM orders_1

UNION ALL

SELECT *
FROM orders_2;
```

---

## 🩹 56. Solution classique : créer explicitement la colonne manquante

```sql
SELECT
  date_purchase,
  orders_id,
  turnover,
  shipping_fee
FROM orders_1

UNION ALL

SELECT
  date_purchase,
  orders_id,
  turnover,
  NULL AS shipping_fee
FROM orders_2;
```

On contrôle explicitement le schéma final.

---

## 🧠 57. BigQuery avancé : `FULL OUTER ... UNION ALL BY NAME`

BigQuery propose aussi des variantes de set operations par nom permettant de gérer des colonnes différentes.

Exemple conceptuel :

```sql
SELECT ...
FROM table_a

FULL OUTER UNION ALL BY NAME

SELECT ...
FROM table_b;
```

Les colonnes absentes d'un côté peuvent être remplies par `NULL`.

> 🧠 **Complément Brocode :** ce n'est pas nécessaire pour maîtriser le cours actuel. Le pattern explicite `NULL AS missing_column` reste très clair et portable.

---

## 🔢 58. Compatibilité des types

Les colonnes correspondantes doivent avoir des types compatibles.

Exemple problématique :

```text
table_1.date_purchase = STRING
table_2.date_purchase = DATE
```

Il peut être nécessaire de caster :

```sql
SELECT
  CAST(date_purchase AS DATE) AS date_purchase,
  orders_id,
  turnover
FROM table_1

UNION ALL

SELECT
  date_purchase,
  orders_id,
  turnover
FROM table_2;
```

---

## 🧼 59. Normaliser avant un UNION

Une bonne architecture consiste à préparer les deux sources.

```sql
WITH source_1 AS (
  SELECT
    CAST(date_purchase AS DATE) AS date_purchase,
    CAST(orders_id AS INT64) AS orders_id,
    CAST(turnover AS NUMERIC) AS turnover
  FROM orders_1
),

source_2 AS (
  SELECT
    CAST(date_purchase AS DATE) AS date_purchase,
    CAST(orders_id AS INT64) AS orders_id,
    CAST(turnover AS NUMERIC) AS turnover
  FROM orders_2
)

SELECT * FROM source_1

UNION ALL

SELECT * FROM source_2;
```

Les CTEs et `UNION ALL` fonctionnent donc très bien ensemble.

---

## 🚫 60. Erreur fréquente : utiliser `UNION DISTINCT` pour masquer un problème

Supposons qu'une mauvaise jointure ait créé des doublons.

Faire :

```sql
SELECT DISTINCT ...
```

ou :

```sql
UNION DISTINCT
```

pour « nettoyer » le résultat sans comprendre l'origine est dangereux.

Le doublon peut venir de :

```text
mauvaise clé
relation N:N
granularité incohérente
donnée source réellement dupliquée
```

La bonne question est :

```text
Pourquoi ai-je ces doublons ?
```

avant de demander :

```text
Comment les supprimer ?
```

---

## 🧠 61. CTE + JOIN + UNION : un pipeline réaliste

Exemple :

```sql
WITH january AS (
  SELECT
    orders_id,
    SUM(turnover) AS total_turnover
  FROM sales_january
  GROUP BY orders_id
),

february AS (
  SELECT
    orders_id,
    SUM(turnover) AS total_turnover
  FROM sales_february
  GROUP BY orders_id
),

all_sales AS (
  SELECT * FROM january
  UNION ALL
  SELECT * FROM february
),

sales_by_order AS (
  SELECT
    orders_id,
    SUM(total_turnover) AS total_turnover
  FROM all_sales
  GROUP BY orders_id
)

SELECT
  s.orders_id,
  s.total_turnover,
  o.shipping_fee
FROM sales_by_order AS s
LEFT JOIN operational AS o
USING (orders_id);
```

Le raisonnement est clair :

```text
janvier
+
février
↓ UNION ALL
historique
↓ GROUP BY
commande
↓ JOIN
coûts
```

---

## 🧪 62. Vérifier un UNION

Avant :

```sql
SELECT COUNT(*) FROM orders_1;
SELECT COUNT(*) FROM orders_2;
```

Après un `UNION ALL` :

```sql
SELECT COUNT(*)
FROM (
  SELECT ... FROM orders_1
  UNION ALL
  SELECT ... FROM orders_2
);
```

Le nombre attendu est :

```text
rows_1 + rows_2
```

---

## 🧪 63. Tester les doublons après un UNION

```sql
WITH all_orders AS (
  SELECT ... FROM orders_1
  UNION ALL
  SELECT ... FROM orders_2
)

SELECT
  orders_id,
  COUNT(*) AS n
FROM all_orders
GROUP BY orders_id
HAVING COUNT(*) > 1;
```

Attention :

```text
plusieurs lignes par orders_id
```

ne signifient pas forcément un problème.

Tout dépend de la granularité attendue.

---

## 🧠 64. `WHERE ... IN`

Le cours se termine aussi sur :

```sql
WHERE column IN (...)
```

`IN` compare une valeur à un ensemble.

Exemple statique :

```sql
WHERE country IN ('FR', 'BE', 'CH')
```

équivaut conceptuellement à :

```sql
WHERE country = 'FR'
   OR country = 'BE'
   OR country = 'CH'
```

---

## 🔗 65. `IN` avec une sous-requête

```sql
WHERE orders_id IN (
  SELECT orders_id
  FROM orders
  WHERE code = 'HAPPYHOUR'
)
```

La liste n'est plus écrite manuellement.

Elle est générée dynamiquement par la sous-requête.

---

## ⚠️ 66. `NOT IN` et `NULL`

Un piège SQL classique concerne :

```sql
NOT IN
```

si la sous-requête peut retourner `NULL`.

La logique tri-valuée SQL peut produire des résultats surprenants.

Pour des exclusions relationnelles complexes, on préfère souvent :

```sql
NOT EXISTS
```

ou un anti-join bien contrôlé.

---

## 🧰 67. Pattern CTE robuste : pré-agrégation + JOIN

```sql
WITH sales_by_order AS (
  SELECT
    orders_id,
    ROUND(SUM(turnover), 2) AS total_turnover
  FROM sales
  GROUP BY orders_id
)

SELECT
  s.orders_id,
  s.total_turnover,
  o.logistic_cost,
  o.shipping_fee,
  ROUND(
    s.total_turnover
      - o.logistic_cost
      - o.shipping_fee,
    2
  ) AS margin
FROM sales_by_order AS s
LEFT JOIN operational AS o
USING (orders_id);
```

---

## 🪜 68. Pattern CTE robuste : calculs en cascade

```sql
WITH base AS (
  SELECT
    orders_id,
    turnover,
    purchase_cost
  FROM orders
),

margin AS (
  SELECT
    *,
    turnover - purchase_cost AS margin
  FROM base
),

margin_rate AS (
  SELECT
    *,
    SAFE_DIVIDE(margin, turnover) AS margin_percentage
  FROM margin
)

SELECT *
FROM margin_rate;
```

---

## 🔍 69. Pattern `EXISTS`

```sql
SELECT
  s.*
FROM sales AS s
WHERE EXISTS (
  SELECT 1
  FROM orders AS o
  WHERE o.orders_id = s.orders_id
    AND o.code = 'HAPPYHOUR'
);
```

À lire :

```text
garder cette vente
si une commande correspondante
avec code HAPPYHOUR existe
```

---

## ↕️ 70. Pattern `UNION ALL`

```sql
SELECT
  date_purchase,
  orders_id,
  turnover
FROM orders_january

UNION ALL

SELECT
  date_purchase,
  orders_id,
  turnover
FROM orders_february;
```

---

## 🏷 71. Pattern `UNION ALL BY NAME`

```sql
SELECT
  orders_id,
  turnover,
  date_purchase
FROM orders_january

UNION ALL BY NAME

SELECT
  date_purchase,
  orders_id,
  turnover
FROM orders_february;
```

La correspondance se fait par nom et non par position.

---

## 🚫 72. Anti-patterns

## 1. CTE `cte1`, `cte2`, `cte3`

```sql
WITH cte1 AS (...),
cte2 AS (...),
cte3 AS (...)
```

Difficile à maintenir.

---

## 2. CTE géante de 300 lignes

Une CTE doit simplifier.

Si elle contient toute la logique du projet, elle n'apporte plus de modularité.

---

## 3. Répéter le même calcul partout

```sql
turnover - purchase_cost
```

répété dans six expressions.

Créer une étape intermédiaire.

---

## 4. JOIN avant l'agrégation alors que les granularités diffèrent

Peut multiplier les métriques.

---

## 5. `UNION DISTINCT` utilisé « au cas où »

Le DISTINCT a une sémantique et un coût.

---

## 6. `SELECT *` dans tous les CTEs

Cela propage des colonnes inutiles dans tout le pipeline.

---

## 7. Croire qu'une CTE garantit de meilleures performances

Faux.

Elle garantit surtout une meilleure structure du code.

---

## 8. Croire qu'une subquery est toujours mauvaise

Faux.

Certaines formes comme :

```sql
EXISTS
```

sont très naturelles.

---

## 🧭 73. Principes de lisibilité

Une bonne requête complexe ressemble à un récit :

```sql
WITH cleaned_sales AS (...),
sales_by_order AS (...),
orders_with_costs AS (...),
orders_with_margin AS (...)

SELECT ...
FROM orders_with_margin;
```

On peut presque lire :

```text
nettoyer les ventes
→ agréger par commande
→ ajouter les coûts
→ calculer la marge
→ produire le résultat
```

---

## 💰 74. Coût et performance BigQuery

Le cours insiste à juste titre sur le fait que BigQuery traite potentiellement de gros volumes.

Mais la performance ne dépend pas seulement du nombre apparent de lignes de SQL.

Elle dépend notamment de :

```text
octets lus
partitions scannées
colonnes lues
JOIN shuffle
agrégations
tri
répétitions
matérialisation
concurrence
```

Deux requêtes visuellement différentes peuvent avoir des performances proches après optimisation.

Et deux requêtes très courtes peuvent avoir des coûts très différents.

---

## 📊 75. Ne pas optimiser à l'aveugle

Méthode :

```text
1. écrire une requête correcte
2. rendre la logique claire
3. tester les métriques
4. vérifier la granularité
5. inspecter le query plan si nécessaire
6. optimiser
```

Pas :

```text
1. rendre le SQL très compact
2. espérer qu'il soit rapide
```

---

## 🧪 76. Checklist avant une CTE

- [ ] Quel est le rôle exact de cette étape ?
- [ ] Quelle est la granularité d'entrée ?
- [ ] Quelle sera la granularité de sortie ?
- [ ] Quelles colonnes sont réellement nécessaires ?
- [ ] Est-ce une transformation, une agrégation ou un enrichissement ?
- [ ] Le nom de la CTE décrit-il clairement son contenu ?

---

## ✅ 77. Checklist après une CTE

- [ ] Le nombre de lignes est-il cohérent ?
- [ ] La clé attendue est-elle unique ?
- [ ] Les métriques sont-elles correctes ?
- [ ] Des `NULL` ont-ils été introduits ?
- [ ] La granularité correspond-elle à ce que j'attendais ?
- [ ] Puis-je inspecter cette étape indépendamment ?

---

## 🔗 78. Checklist avant un JOIN après CTE

```text
CTE gauche
granularité = ?

table droite
granularité = ?

relation
1:1 ?
1:N ?
N:N ?
```

Puis :

```text
Quel JOIN ?
Quelle clé ?
Quel nombre de lignes attendu ?
```

---

## ↕️ 79. Checklist avant un UNION

- [ ] Même nombre de colonnes ?
- [ ] Même signification métier par position ?
- [ ] Types compatibles ?
- [ ] Ordre des colonnes identique ?
- [ ] `BY NAME` serait-il plus sûr ?
- [ ] Faut-il conserver les doublons ?
- [ ] `UNION ALL` ou `UNION DISTINCT` ?
- [ ] Des colonnes manquent-elles d'un côté ?
- [ ] Faut-il ajouter `NULL AS column` ?
- [ ] La granularité est-elle la même ?

---

## 🧠 80. Ce qu'il faut vraiment retenir

Une CTE n'est pas juste une nouvelle syntaxe.

Elle permet de transformer :

```text
une grosse requête difficile
```

en :

```text
une suite d'étapes nommées
```

Le pattern principal du cours est :

```text
source détaillée
↓
GROUP BY
↓
CTE à la bonne granularité
↓
JOIN
↓
calcul métier
```

Et le deuxième pattern essentiel :

```text
calcul A
↓ CTE
colonne A disponible
↓
calcul B utilisant A
```

---

## 🎯 81. Les réflexes à automatiser

1. **Toujours identifier la granularité avant un JOIN.**
2. **Pré-agréger quand une table est trop détaillée.**
3. **Nommer les calculs intermédiaires.**
4. **Utiliser les CTEs pour rendre les étapes visibles.**
5. **Ne pas considérer les CTEs comme un cache automatique.**
6. **Choisir JOIN vs subquery selon la sémantique et la lisibilité.**
7. **Utiliser `UNION ALL` pour empiler en conservant toutes les lignes.**
8. **Utiliser `UNION DISTINCT` seulement si la déduplication est voulue.**
9. **Contrôler l'ordre des colonnes dans les set operations.**
10. **Tester systématiquement le nombre de lignes et les métriques.**

---

## 🧾 82. Cheat sheet finale

### CTE simple

```sql
WITH my_cte AS (
  SELECT
    ...
  FROM source
)

SELECT
  ...
FROM my_cte;
```

---

### Plusieurs CTEs

```sql
WITH cte_1 AS (
  ...
),

cte_2 AS (
  SELECT ...
  FROM cte_1
),

cte_3 AS (
  SELECT ...
  FROM cte_2
)

SELECT *
FROM cte_3;
```

---

### Pré-agrégation avant JOIN

```sql
WITH sales_by_order AS (
  SELECT
    orders_id,
    SUM(turnover) AS total_turnover
  FROM sales
  GROUP BY orders_id
)

SELECT
  s.orders_id,
  s.total_turnover,
  o.shipping_fee
FROM sales_by_order AS s
LEFT JOIN operational AS o
USING (orders_id);
```

---

### Calcul en cascade

```sql
WITH margin_cte AS (
  SELECT
    turnover,
    turnover - purchase_cost AS margin
  FROM orders
)

SELECT
  turnover,
  margin,
  SAFE_DIVIDE(margin, turnover) AS margin_percentage
FROM margin_cte;
```

---

### `IN` subquery

```sql
SELECT *
FROM sales
WHERE orders_id IN (
  SELECT orders_id
  FROM orders
  WHERE code = 'HAPPYHOUR'
);
```

---

### `EXISTS`

```sql
SELECT *
FROM sales AS s
WHERE EXISTS (
  SELECT 1
  FROM orders AS o
  WHERE o.orders_id = s.orders_id
);
```

---

### Table subquery

```sql
SELECT *
FROM (
  SELECT
    orders_id,
    SUM(turnover) AS total_turnover
  FROM sales
  GROUP BY orders_id
);
```

---

### `UNION ALL`

```sql
SELECT
  id,
  value
FROM source_1

UNION ALL

SELECT
  id,
  value
FROM source_2;
```

---

### `UNION DISTINCT`

```sql
SELECT
  id,
  value
FROM source_1

UNION DISTINCT

SELECT
  id,
  value
FROM source_2;
```

---

### BigQuery : aligner par nom

```sql
SELECT
  id,
  value
FROM source_1

UNION ALL BY NAME

SELECT
  value,
  id
FROM source_2;
```

---

## 💡 Ce que j'ai retenu

- Une **CTE** est une sous-requête nommée définie avec `WITH ... AS (...)`.
- Elle est surtout utile pour découper une transformation complexe en étapes lisibles.
- Le pattern **`GROUP BY` → CTE → `JOIN`** permet de contrôler la granularité avant d'enrichir une table.
- Une CTE est très pratique pour réutiliser un calcul intermédiaire comme `margin`.
- Une CTE BigQuery non récursive n'est pas une vraie table temporaire matérialisée automatiquement.
- Une nested subquery peut apparaître dans `SELECT`, `FROM`, `WHERE` ou dans des expressions comme `IN` / `EXISTS`.
- Un `JOIN` est souvent plus clair lorsque l'objectif est de récupérer plusieurs colonnes d'une autre table.
- Une sous-requête n'est pas automatiquement moins performante : le plan réel dépend de l'optimiseur et de la structure de la requête.
- `UNION ALL` empile toutes les lignes.
- `UNION DISTINCT` empile puis élimine les lignes dupliquées.
- En BigQuery, les set operations classiques alignent les colonnes **par position**, pas obligatoirement par nom.
- `UNION ... BY NAME` permet un alignement par noms de colonnes.
- `UNION DISTINCT` ne doit pas servir à masquer des doublons dont on ignore la cause.
- La granularité reste le fil conducteur de toutes ces opérations.

---

## ❓ Questions / points à garder en tête

- [ ] Quand préférer une `TEMP TABLE` à une CTE ?
- [ ] Comment BigQuery choisit-il de réévaluer ou d'optimiser une CTE ?
- [ ] Quand utiliser `EXISTS` plutôt que `IN` ?
- [ ] Qu'est-ce qu'une correlated subquery et pourquoi peut-elle coûter cher ?
- [ ] Comment fonctionnent les CTEs récursives ?
- [ ] Quand utiliser `UNION ALL BY NAME` ?
- [ ] Comment tester automatiquement la granularité entre deux étapes dbt ?

---

## 🔗 Liens avec les autres notions du Brocode

```text
JOINs
  ↓
Granularité
  ↓
GROUP BY
  ↓
CTEs / Subqueries
  ↓
Calculs intermédiaires
  ↓
UNION / consolidation
  ↓
Testing
  ↓
dbt models
  ↓
Data Warehouse
  ↓
BI
```

Les CTEs deviennent particulièrement importantes dans **dbt**, où un modèle SQL est très souvent structuré comme une succession d'étapes :

```text
source
→ staging
→ intermediate
→ marts
```

La logique intellectuelle est exactement la même :

> transformer progressivement la donnée, en rendant explicite la granularité et le rôle de chaque étape.

---

## 📚 Vérifications techniques ajoutées au Brocode

Les points suivants ont été volontairement précisés par rapport au support de cours à partir de la documentation officielle BigQuery :

```text
- une CTE non récursive BigQuery n'est pas automatiquement matérialisée ;
- une CTE n'est pas une garantie de gain de performance ;
- une sous-requête n'est pas systématiquement plus lente qu'un JOIN ;
- UNION ALL / UNION DISTINCT alignent par défaut les colonnes par position ;
- les noms de colonnes n'ont pas besoin d'être identiques pour un UNION positionnel ;
- BigQuery propose BY NAME pour aligner les colonnes par leur nom ;
- plusieurs formes de subqueries existent : scalar, IN, EXISTS, table et correlated.
```

Ces précisions complètent le raisonnement pédagogique du cours sans modifier son objectif principal : **écrire du SQL lisible, contrôlé et cohérent en granularité**.
