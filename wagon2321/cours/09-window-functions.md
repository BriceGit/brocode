---
title: "SQL — User-Defined Functions & Window Functions"
aliases:
  - "SQL Window Functions"
  - "Window Functions"
  - "SQL UDFs"
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 9
language: "SQL"
database: "BigQuery / GoogleSQL"
topics:
  - "SQL"
  - "BigQuery"
  - "UDFs"
  - "Window Functions"
  - "Ranking"
tags:
  - brocode
  - wagon2321/cours
  - sql
  - bigquery
  - window-functions
  - udf
---


# 09 - Window Functions (BigQuery)

**Date :** 16 juillet 2026
**Thème :** Fonctions SQL personnalisées (UDF) & Window Functions — module Data Transformation
**Intervenant :** freelance data engineer / data analyst (pipelines SQL, Airflow, Python), en reconversion (ex-cinéma)

---

## 🎯 RECAP

- Une **UDF** (`CREATE FUNCTION`) encapsule un traitement répétitif dans un objet réutilisable, rattaché à un **dataset** (pas à une table)
- Une **Window Function** (`OVER (...)`) fait un calcul d'agrégation ou de tri **sans réduire la granularité** — contrairement à `GROUP BY`
- `PARTITION BY` = un `GROUP BY` qui garde toutes les lignes
- Trio classique d'entretien : `ROW_NUMBER()` (pas de gestion des ex-æquo) / `RANK()` (ex-æquo + saut de numéros) / `DENSE_RANK()` (ex-æquo sans saut)
- Le plus gros insight de la session : les Window Functions permettent de **répartir une valeur agrégée au prorata** d'une autre colonne, tout en gardant la granularité fine **et** la conservation des totaux → lien direct avec mon principe "conservation test"

---

## 🧩 Rappel — Fonctions personnalisées (UDF)

Les fonctions natives BigQuery (`ROUND`, `SUM`, `SAFE_DIVIDE`...) ne couvrent pas tout : dès qu'un calcul revient souvent dans les requêtes, on peut l'encapsuler dans sa propre fonction.

### Anatomie

```sql
CREATE FUNCTION dataset.nom_fonction(param1 TYPE1, param2 TYPE2) AS (
  -- corps de la fonction : ce qui est retourné
);
```

- Stockée dans un **dataset**, pas dans une table → objet indépendant, appelable depuis n'importe quelle table du même projet BigQuery (visible sous **Routines** dans le dataset)
- **Typage des paramètres strict** : un mismatch de type renvoie une erreur
- Pour modifier une fonction existante sans erreur *"already exists"* → `CREATE OR REPLACE FUNCTION`
- Les noms de paramètres sont libres : BigQuery vérifie le **typage** des arguments à l'appel, pas la correspondance avec des noms de colonnes
- Une fonction peut en appeler une autre (composition), et peut elle-même encapsuler une Window Function si elle est assez générique
- Portée : accessible sans restriction entre tous les datasets d'un **même projet** BigQuery ; restreinte entre projets différents

### Exemples vus en cours

**Calcul simple :**
```sql
CREATE FUNCTION course17.margin(turnover FLOAT64, purchase_cost FLOAT64) AS (
  turnover - purchase_cost
);
```

**Logique conditionnelle (`CASE WHEN`) :**
```sql
CREATE FUNCTION course17.age_category(birth_date DATE) AS (
  CASE
    WHEN birth_date < "1980-01-01" THEN "wise"
    WHEN birth_date < "1990-01-01" THEN "medium"
    WHEN birth_date < "2000-01-01" THEN "young"
    ELSE "child"
  END
);
```
Utilisation → remplace un `CASE WHEN` répété par un appel en une ligne, requête plus lisible :
```sql
SELECT
  customers_id,
  birth_date,
  course17.age_category(birth_date) AS age_category
FROM people
```

**Standardiser un ratio** *(⚠️ lien direct avec mes principes brocode : `SAFE_DIVIDE` + `ROUND` uniquement en sortie, jamais sur une colonne intermédiaire)* :
```sql
CREATE FUNCTION course17.ratio(numerator FLOAT64, denominator FLOAT64) AS (
  ROUND(SAFE_DIVIDE(numerator, denominator), 3)
);
```
Réutilisable telle quelle sur des métiers différents :
```sql
SELECT orders_id, turnover, margin, course17.ratio(margin, turnover) AS margin_P FROM sales
SELECT email, opening, click, course17.ratio(click, opening) AS CTR FROM mail
```

**Segmentation :**
```sql
CREATE FUNCTION course17.segment(nb_orders INT64) AS (
  CASE
    WHEN nb_orders = 0 THEN "Prospect"
    WHEN nb_orders = 1 THEN "New"
    WHEN nb_orders IN (2, 3) THEN "Occasional"
    WHEN nb_orders > 3 THEN "Frequent"
    ELSE NULL
  END
);
```

### Bonnes pratiques

- Créer une fonction dès qu'un traitement devient **répétitif**
- La rendre **générique** (pas de nom de colonne en dur) pour qu'elle survive à plusieurs cas d'usage
- **Documenter** avec des commentaires — utile pour soi-même 3 mois plus tard et pour l'équipe
- Communiquer à l'équipe où vivent les fonctions (dataset) pour éviter les doublons

---

## 🪟 Window Functions — Aggregation

Une Window Function fait un calcul sur une **fenêtre de lignes** définie par `OVER (...)`, sans `GROUP BY` et **sans perdre la granularité** : le résultat est répété sur chaque ligne concernée plutôt que de réduire le nombre de lignes.

| | `GROUP BY` | Window Function (`OVER`) |
|---|---|---|
| Granularité | Réduite (1 ligne / groupe) | **Conservée** (1 ligne / ligne source) |
| Résultat agrégé | Une seule fois par groupe | **Répété** sur chaque ligne du groupe |
| Détail par ligne | ❌ perdu | ✅ conservé |

### `OVER ()` vide → agrégat sur toute la table

```sql
SELECT
  model, model_type, stock_value,
  SUM(stock_value) OVER () AS stock_global
FROM circle_stock
```
→ `stock_global` = même valeur (total général) répétée sur **toutes** les lignes.

### `PARTITION BY` → agrégat par sous-groupe, réparti sur chaque ligne du sous-groupe

`PARTITION BY` = l'équivalent du `GROUP BY` à l'intérieur du `OVER`, mais **ne réduit pas les lignes** — il détermine juste la largeur de la fenêtre.

```sql
SELECT
  model, model_type, stock_value,
  SUM(stock_value) OVER (PARTITION BY model_type) AS stock_model_type
FROM circle_stock
```

| model | model_type | stock_value | stock_model_type |
|---|---|---|---|
| T-shirt Liberty | T-shirt | 5400 | 11 550 |
| T-shirt Nature | T-shirt | 2950 | 11 550 |
| T-shirt Mountainer | T-shirt | 0 | 11 550 |
| T-shirt Sea lover | T-shirt | 3200 | 11 550 |
| Leggin Confort | Legging | 4000 | 9 200 |
| Leggin Sport | Legging | 5200 | 9 200 |

### Équivalence avec un CTE + JOIN (comprendre le "sous le capot")

```sql
WITH stock_model_type AS (
  SELECT model_type, SUM(stock_value) AS stock_model_type
  FROM circle_stock
  GROUP BY model_type
)
SELECT model, model_type, stock_value, stock_model_type
FROM circle_stock
INNER JOIN stock_model_type USING (model_type)
```
Même résultat que la Window Function, mais en **2 étapes** (agrégation + jointure) au lieu d'une seule ligne de calcul → la Window Function est plus lisible et plus simple à maintenir, surtout en équipe ou pour soi-même dans 3 mois.

### Cas d'usage : calculer des proportions → *aggregate before divide* en action

```sql
SELECT
  model, model_type, stock_value,
  stock_value / SUM(stock_value) OVER () AS P_global,
  stock_value / SUM(stock_value) OVER (PARTITION BY model_type) AS P_model_type
FROM circle_stock
```

C'est exactement le principe **"aggregate before divide"** déjà noté dans mon brocode : le `SUM() OVER()` calcule d'abord l'agrégat, *ensuite* on divise chaque ligne par cet agrégat — jamais l'inverse.

Usage business : *"45% du stock est composé d'équipements confort"* — répondre à ce type de question demande de garder le détail par produit **et** le total, ce qu'un simple `GROUP BY` ne permet pas.

---

## 🔢 Window Functions — Sorting

Même logique `OVER (...)`, mais avec une fonction de tri plutôt que d'agrégation. `ORDER BY` **à l'intérieur** du `OVER` définit l'ordre du classement — différent d'un `ORDER BY` en fin de requête, qui ne trie que l'affichage final.

```sql
SELECT
  model, model_type, stock_value,
  ROW_NUMBER() OVER (ORDER BY stock_value DESC) AS rn_global
FROM circle_stock
```

Avec `PARTITION BY`, le classement **repart à 1 dans chaque partition** :
```sql
SELECT
  model, model_type, stock_value,
  ROW_NUMBER() OVER (PARTITION BY model_type ORDER BY stock_value DESC) AS rn_model_type
FROM circle_stock
```

### `ROW_NUMBER()` vs `RANK()` vs `DENSE_RANK()` — LE classique d'entretien

Sur un jeu de données avec deux ex-æquo à 5200 et deux ex-æquo à 3200 :

| model | stock_value | `ROW_NUMBER()` | `RANK()` | `DENSE_RANK()` |
|---|---|---|---|---|
| T-shirt Liberty | 5200 | 1 | 1 | 1 |
| Leggin Sport | 5200 | 2 | 1 | 1 |
| Leggin Confort | 4000 | 3 | 3 | 2 |
| T-shirt Nature | 3200 | 5 | 4 | 3 |
| T-shirt Sea lover | 3200 | 4 | 4 | 3 |
| T-shirt Mountainer | 0 | 6 | 6 | 4 |

- **`ROW_NUMBER()`** : ignore les ex-æquo, numérote 1, 2, 3... dans un ordre arbitraire entre égalités
- **`RANK()`** : même rang pour les ex-æquo, puis **saute** les numéros suivants (2 lignes en rang 1 → la suivante est rang 3, pas 2)
- **`DENSE_RANK()`** : même rang pour les ex-æquo, **sans sauter** (rang suivant = rang précédent + 1)

### Pièges / précisions utiles pour l'entretien

- `ROW_NUMBER()` **sans `ORDER BY`** dans le `OVER` s'exécute quand même (numérotation arbitraire, non nulle), mais n'a aucun intérêt pratique — sans tri, le numéro ne veut rien dire
- Partitionner sur une **clé primaire / colonne unique** n'a pas de sens : chaque partition ne contiendrait qu'une seule ligne
- Pattern **Top N** très fréquent en entretien : passer par un CTE, puis filtrer sur le rang
```sql
WITH ranked AS (
  SELECT model, model_type, stock_value,
    ROW_NUMBER() OVER (ORDER BY stock_value DESC) AS rn_global
  FROM circle_stock
)
SELECT * FROM ranked WHERE rn_global <= 3
```

### Pourquoi utiliser les Window Functions de tri ?

- Calculer un classement
- Filtrer sur un classement (Top N)
- Calculer un score basé sur un rang (ex. customer health score, merchandising produit)

---

## 🔗 Cas d'usage avancé — Jointures à granularités différentes

Le morceau le plus riche de la session : que faire quand deux tables à joindre n'ont pas la même granularité ?

**Le problème :** `sales` est à la granularité `products_id` (plusieurs lignes par commande), `orders_operationnal` est à la granularité `orders_id` (une ligne par commande, avec `log_cost` et `ship_cost`).

### ❌ Piège — Direct Join

Joindre directement sans remonter la granularité de `sales` fait que BigQuery **répète** le coût de la commande sur chaque produit :

```sql
SELECT s.orders_id, s.products_id, s.turnover, op.log_cost, op.ship_cost
FROM sales s
INNER JOIN orders_operationnal op USING (orders_id)
```

| orders_id | products_id | turnover | log_cost | ship_cost |
|---|---|---|---|---|
| 451 | 6532 | 24 | 4.5 | 7 |
| 451 | 1068 | 15.4 | 4.5 | 7 |
| 623 | 4102 | 19.4 | 3.5 | 5 |
| 623 | 928 | 24.8 | 3.5 | 5 |
| 623 | 6532 | 12 | 3.5 | 5 |

`log_cost` = 4.5 est répété 2 fois pour la commande 451 : un `SUM(log_cost)` sur cette table donnerait 9 au lieu de 4.5. **Conservation cassée** → mon principe "vérifier le SUM avant/après" prend tout son sens ici.

### ✅ Solution 1 — Aggregate & Join

Remonter `sales` à la granularité `orders_id` *avant* de joindre :

```sql
WITH orders AS (
  SELECT orders_id, SUM(turnover) AS turnover
  FROM sales
  GROUP BY orders_id
)
SELECT o.orders_id, o.turnover, op.log_cost, op.ship_cost
FROM orders o
INNER JOIN orders_operationnal op USING (orders_id)
```
Correct, conservation respectée, mais on **perd le détail par produit**.

### ✅✅ Solution 2 — Distribution au prorata via Window Function

La solution "best of both worlds" : garder la granularité produit **et** répartir le coût de la commande au prorata du poids de chaque produit dans le turnover, via `SUM() OVER (PARTITION BY orders_id)` — encore une fois de l'*aggregate before divide* :

```sql
WITH sales_percent AS (
  SELECT
    orders_id, products_id, turnover,
    turnover / SUM(turnover) OVER (PARTITION BY orders_id) AS pct_turnover
  FROM sales
)
SELECT
  sp.orders_id, sp.products_id, sp.turnover, sp.pct_turnover,
  op.log_cost * sp.pct_turnover AS log_cost_alloc,
  op.ship_cost * sp.pct_turnover AS ship_cost_alloc
FROM sales_percent sp
INNER JOIN orders_operationnal op USING (orders_id)
```
> 🔧 SQL reconstitué à partir du schéma du cours (cette partie était présentée en diagramme, pas en requête à l'écran) — à ajuster si tes noms de colonnes réels diffèrent.

| orders_id | products_id | turnover | pct_turnover | log_cost_alloc | ship_cost_alloc |
|---|---|---|---|---|---|
| 451 | 6532 | 24 | 60.9% | 2.74 | 4.26 |
| 451 | 1068 | 15.4 | 39.1% | 1.76 | 2.74 |
| 623 | 4102 | 19.4 | 34.5% | 1.21 | 1.73 |
| 623 | 928 | 24.8 | 44.1% | 1.54 | 2.21 |
| 623 | 6532 | 12 | 21.4% | 0.75 | 1.07 |

**✅ Conservation test :** commande 451 → 2.74 + 1.76 = **4.50** = `log_cost` d'origine. Commande 623 → 1.21 + 1.54 + 0.75 = **3.50** = `log_cost` d'origine. Idem sur `ship_cost`. Rien n'est créé ni perdu dans la distribution, et le détail par produit est conservé.

### Comparatif des 3 approches

| | Granularité produit | Conservation des totaux | Détail proportionnel |
|---|---|---|---|
| Direct Join | ✅ conservée | ❌ cassée | ❌ |
| Aggregate & Join | ❌ perdue | ✅ | ❌ |
| Window Function distribution | ✅ conservée | ✅ | ✅ |

🔗 À relier à [`07-sql-joins-testing.md`](./07-sql-joins-testing.md) pour la mécanique des jointures de base.

---

## 🎤 Prep entretien

| Question probable | Réponse clé |
|---|---|
| C'est quoi une Window Function, différence avec `GROUP BY` ? | `GROUP BY` réduit la granularité, `OVER()` la conserve en répétant l'agrégat sur chaque ligne |
| `PARTITION BY` vs `GROUP BY` ? | Même logique de découpage, mais `PARTITION BY` ne fusionne pas les lignes |
| `ROW_NUMBER()` vs `RANK()` vs `DENSE_RANK()` ? | Voir tableau dédié — le point clé est la gestion des ex-æquo et le saut (ou non) de numéros |
| Comment sortir un Top 3 en SQL ? | CTE avec `ROW_NUMBER() OVER (ORDER BY ... DESC)`, puis `WHERE rn <= 3` |
| Donne un exemple concret où tu as géré un problème de granularité | 🎯 **le cas `sales` / `orders_operationnal` ci-dessus** — bon exemple business à raconter tel quel (problème → risque de total faux → solution Window Function → vérification par conservation test) |
| Pourquoi créer une fonction personnalisée plutôt que répéter le SQL ? | Standardisation, consistance des calculs, maintenabilité (un seul endroit à corriger) |

---

## ✅ Actions post-session

- [ ] Consulter les requêtes partagées sur Slack par le formateur
- [ ] Pratiquer les Window Functions en autonomie sur BigQuery *(auto-évaluation compréhension de la session : 1/5 → prioriser cette pratique avant d'enchaîner sur la suite)*
- [ ] Retester le cas "distribution au prorata" sur un dataset perso pour consolider

## ❓ Questions ouvertes

- [ ] Le schéma du cours affichait aussi `date_purchase` sur la table `orders` du cas pratique — simplifié ici pour rester focus sur la mécanique, à vérifier si utile dans ton usage réel
- [ ] Existe-t-il un nom "officiel" (data modeling) pour ce pattern de distribution au prorata (allocation, apportionment...) ? Utile à connaître pour un entretien

## 🔗 Liens avec d'autres chapitres

- [`07-sql-joins-testing.md`](./07-sql-joins-testing.md) — jointures de base
- [ ] Lien vers un chapitre fonctions d'agrégation SQL natives (`SUM`, `AVG`, `ROUND`...) si tu en as un séparé
- [ ] Lien vers le chapitre dbt si tu réutilises ces UDF / window functions dans un modèle dbt
