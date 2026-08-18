---
title: "Reboot SQL - Fivetran - Git - DBT"
aliases:
  - "SQL Introduction"
  - "Relational Databases & BigQuery"
  - "BigQuery Fundamentals"
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 24
date: 2026-08-07
language: "SQL"
database: "BigQuery / GoogleSQL"
topics:
  - "SQL"
  - "BigQuery"
  - "Relational Databases"
  - "ERD"
  - "joins"
  - "subqueries"
tags:
  - brocode
  - wagon2321/cours
  - sql
  - bigquery
  - relational-databases
  - dbt
  - git
---

# NN - Reboot : SQL, Fivetran/API, Git & dbt

**📅 Date :** 07 août 2026
**🎯 Thème :** Session de révision ("reboot") transversale — consolidation SQL (fondamentaux → CRUD → agrégation → jointures → subqueries/CTE → window functions), rappel Fivetran/API, Git/GitHub et dbt avant le module Python
**🔗 Contexte :** Session à la carte (SQL : 5 exercices, Fivetran : 2, Git/dbt : 2) — possibilité de revenir sur des jours précédents en cas de lacune

---

## 📋 Sommaire

- [[#🔄 Contexte de la session]]
- [[#🗃️ SQL — Rappels fondamentaux]]
- [[#🛠️ CRUD]]
- [[#🧮 Fonctions d'agrégation]]
- [[#🔑 Clés primaires & étrangères]]
- [[#🔗 Jointures]]
- [[#📦 Subqueries & CTE]]
- [[#🪟 Window Functions]]
- [[#🔌 Fivetran & API]]
- [[#🐙 Git & GitHub]]
- [[#🏗️ dbt]]
- [[#🎯 Pièges classiques (interview prep)]]
- [[#🔗 Liens avec d'autres chapitres]]
- [[#✅ Actions post-session]]
- [[#❓ Questions ouvertes]]

> 💡 *Sommaire ajouté par rapport au transcript brut — vu la densité de la session (7 thématiques), un accès rapide par section semblait utile. Liens en syntaxe Obsidian native (`[[#Titre]]`), qui pointent vers le texte exact du titre plutôt qu'un slug deviné — plus robuste qu'une ancre markdown classique.*

---

## 🔄 Contexte de la session

Journée "reboot" : pas de nouvelle notion, mais une repasse complète sur tout ce qui a été vu en SQL depuis le début du bootcamp, plus un rappel Fivetran/API, Git/GitHub et dbt. Objectif affiché par le formateur : consolider avant d'attaquer le module Python dans deux semaines.

Fonctionnement de la journée : les exercices sont **à la carte** (SQL : 5 exercices, Fivetran : 2, Git/dbt : 2) — libre de piocher selon ses lacunes, et possible de revenir sur des exercices de jours précédents (les **Window Functions** sont explicitement citées comme point sensible à retravailler si besoin).

Changement d'environnement pour les exercices SQL du jour : **SQLite Online** plutôt que BigQuery — pratique pour se frotter à un autre moteur SQL, mais deux pièges à connaître :
- Les strings s'écrivent avec des guillemets **simples** (`'texte'`) et non doubles (`"texte"`) comme sur BigQuery
- Certaines syntaxes spécifiques à BigQuery (comme `USING`) n'existent pas sur SQLite
- C'est un environnement **temporaire** — un refresh de page fait perdre le travail, pas de vraie sauvegarde derrière

L'exercice CRUD, lui, reste faisable directement sur BigQuery puisqu'il s'agit de créer ses propres tables plutôt que d'interroger des tables déjà fournies.

---

## 🗃️ SQL — Rappels fondamentaux

Base commune à toute requête : filtrer, trier, renommer, transformer. Table d'exemple (`People`) :

| id | name | surname | birth_date | number_of_children |
|---|---|---|---|---|
| 1 | Paul | Mochkovitch | 1990-08-13 | 0 |
| 2 | Charlotte | Dupuis | 1986-11-05 | 2 |
| 3 | Clara | Milaux | 1976-02-12 | 3 |
| 4 | Corine | Hamous | 1983-04-05 | 1 |
| 5 | Louis | Le beau | 1980-06-19 | 5 |
| 6 | David | Lamart | 2010-01-30 | 0 |

### WHERE — filtrer

```sql
SELECT *
FROM People
WHERE name = "Clara"
```

Opérateurs disponibles :

| Opérateur | Signification |
|---|---|
| `>` | Strictement supérieur |
| `>=` | Supérieur ou égal |
| `<` | Strictement inférieur |
| `<=` | Inférieur ou égal |
| `=` | Égal |
| `!=` (ou `<>`) | Différent de |

`AND` et `OR` se combinent avec une priorité qui suit la même logique qu'en maths : **`AND` se comporte comme une multiplication, `OR` comme une addition**. Concrètement : `A AND B` n'est vrai que si A **et** B le sont tous les deux (un seul "faux" annule tout, comme un 0 dans une multiplication) ; `A OR B` est vrai dès que l'un des deux l'est (comme une addition, un seul "vrai" suffit). Utile pour savoir où poser ses parenthèses dans une condition composée.

### LIKE — recherche de texte

```sql
SELECT *
FROM People
WHERE name LIKE "C%"
```

| Pattern | Signification |
|---|---|
| `"C%"` | Commence par C |
| `"%C"` | Termine par C |
| `"%C%"` | Contient C |
| `"_C%"` | C en 2ème caractère (`_` = un caractère quelconque) |

### IN / NOT IN — inclusion ou exclusion sur une liste

```sql
SELECT * FROM People WHERE name IN ("Louis","David")
SELECT * FROM People WHERE name NOT IN ("Louis","David")
```

### SELECT DISTINCT — valeurs uniques

```sql
SELECT DISTINCT number_of_children
FROM People
```

### AS — renommer (alias)

```sql
SELECT name AS first_name
FROM People
```

⚠️ **Point important** : `AS` ne modifie **que le nom affiché en sortie de requête** — la colonne dans la base de données reste inchangée. `AS` sert aussi à renommer des **tables** (très utile en jointure, voir plus bas), pas seulement des colonnes.

### ORDER BY — trier

```sql
SELECT *
FROM People
ORDER BY birth_date
```

Tri **ascendant par défaut**. On peut trier sur plusieurs colonnes, avec des directions différentes, et gérer les égalités avec une colonne de départage :

```sql
SELECT *
FROM People
ORDER BY number_of_children DESC, surname ASC
```

On peut aussi utiliser l'**index de colonne** plutôt que son nom (`ORDER BY 1, 2`) — écriture plus rapide, un peu moins lisible.

### SELECT * EXCEPT — tout sauf une colonne

Non présent sur les slides mais mentionné à l'oral : `SELECT * EXCEPT (colonne) FROM table` sélectionne toutes les colonnes sauf celle(s) listée(s) — pratique sur une table très large plutôt que d'énumérer une à une toutes les colonnes voulues.

### IF — transformation conditionnelle simple

```sql
SELECT *,
  IF(number_of_children > 0, 1, 0) AS parent
FROM People
```

### CASE WHEN — transformation conditionnelle complexe

```sql
SELECT
  CASE
    WHEN birth_date < "1980-01-01" THEN "wise"
    WHEN birth_date < "1990-01-01" THEN "medium"
    WHEN birth_date < "2000-01-01" THEN "young"
    ELSE "child"
  END AS age_category
FROM People
```

Les `WHEN` sont évalués **dans l'ordre** — la première condition qui matche l'emporte. `ELSE` est le filet de sécurité si aucune condition n'est vraie.

### IS NULL / IS NOT NULL — valeurs manquantes

```sql
SELECT *
FROM People
WHERE time_for_each_child IS NULL
```

`IS NOT NULL` fait l'inverse : ne garde que les lignes où la valeur existe.

---

## 🛠️ CRUD

**C**reate, **R**ead, **U**pdate, **D**elete (+ **Insert**, souvent regroupé avec Create) — les opérations de base sur une base de données.

| Opération | Rôle |
|---|---|
| Create | Créer une nouvelle table dans la base |
| Insert | Insérer de nouvelles lignes dans la table |
| Read | Select — lire des lignes |
| Update | Mettre à jour des lignes existantes |
| Delete | Supprimer des lignes |

📌 **Point clé rappelé en session** : en tant que Data Analyst, le CRUD est manipulé très marginalement — c'est surtout le terrain du Data Engineering (ingestion, création de tables). Côté analyse, la bonne pratique est de **ne jamais modifier ou supprimer la donnée source** : on privilégie un `SELECT` pour recréer une table plutôt qu'un `UPDATE`/`DELETE` direct sur la donnée d'origine. Le seul CRUD réellement utilisé au quotidien : le **Read** (`SELECT`).

### CREATE TABLE

```sql
CREATE TABLE course14.people (
  id INT64
  ,name STRING
  ,surname STRING
  ,birth_date DATE
  ,number_of_children INT64
)
```

`course14` est le **dataset** (le "dossier" contenant la table), `people` le nom de la table, chaque colonne est déclarée avec son **type de données**. Contrairement à un tableur, **une colonne SQL n'a qu'un seul type** — impossible de mélanger texte et nombre dans la même colonne.

### INSERT — avec VALUES

```sql
INSERT INTO course14.people
VALUES
  (1,"Paul","Mochkovitch","1990-08-13",0),
  (2,"Charlotte","Dupuis","1986-11-05",2)
```

Contrainte : il faut **exactement le même nombre de valeurs, dans le même ordre et du même type** que les colonnes déclarées à la création — sinon erreur.

### INSERT — avec SELECT

```sql
INSERT INTO course14.people
  SELECT * FROM course14.people_new
```

Permet d'insérer le contenu d'une table dans une autre (même structure de colonnes requise) — dans l'esprit, un peu comme un `UNION ALL` entre les deux tables.

### UPDATE

```sql
UPDATE course14.people
SET number_of_children = 1
WHERE id = 1
```

⚠️ Toujours accompagner un `UPDATE` d'un `WHERE` précis (idéalement sur une clé unique) — sans lui, la mise à jour s'applique à **toutes les lignes** de la table.

### DELETE

```sql
DELETE
FROM course14.people
WHERE id = 6
```

Même remarque que pour `UPDATE` : filtrer de préférence sur un `id` ou une clé unique plutôt que sur un nom ou une valeur qui pourrait correspondre à plusieurs lignes.

---

## 🧮 Fonctions d'agrégation

Table d'exemple (`purchases`) :

| id | buyer | date | product | quantity | spend |
|---|---|---|---|---|---|
| 1 | Julie | 2020-06-03 | banana | 3 | 3 |
| 2 | Paul | 2020-06-03 | banana | 1 | 1 |
| 3 | Thomas | 2020-06-15 | apple | 10 | 5 |
| 4 | Julien | 2020-06-18 | apple | 5 | 2.5 |
| 5 | Julie | 2020-06-20 | apple | 6 | 3 |
| 6 | Julie | 2020-06-20 | pear | 3 | 4.5 |
| 7 | Julie | *(null)* | banana | 2 | 2 |
| 8 | Paul | 2020-07-11 | pear | 4 | 6 |
| 9 | Paul | 2020-07-11 | pear | 2 | 3 |
| 10 | Julien | 2020-07-26 | apple | 30 | 15 |

### COUNT / COUNTIF

```sql
SELECT COUNT(buyer) FROM purchases   -- 10 (aucun NULL sur buyer)
SELECT COUNT(date) FROM purchases    -- 9  (une date est NULL, ligne 7)
SELECT COUNT(*) FROM purchases       -- 10 (compte les lignes, NULL ou pas)
```

🎯 **Piège classique** : `COUNT(colonne)` ne compte **pas** les valeurs `NULL` de cette colonne, alors que `COUNT(*)` compte toutes les lignes sans se soucier des `NULL`. Distinction qui tombe souvent en entretien.

```sql
SELECT COUNTIF(quantity > 3) FROM purchases   -- 5
```

`COUNTIF` combine un `COUNT` et une condition en une seule fonction — les conditions se combinent avec `AND`/`OR`, comme un `WHERE` normal.

### SUM

```sql
SELECT SUM(spend) FROM purchases   -- 45
```

### MIN / MAX

```sql
SELECT MAX(spend) FROM purchases   -- 15
```

🎯 **Piège classique (vu en quiz)** : `MIN`/`MAX` fonctionnent aussi sur une colonne de **texte**, sans erreur — le résultat est la chaîne la plus petite/grande dans l'**ordre alphabétique**. `AVG`, en revanche, ne fonctionne pas sur du texte.

### AVG

```sql
SELECT AVG(spend) FROM purchases   -- 4.5
```

`AVG` équivaut à `SUM(colonne) / COUNT(colonne)` — et c'est précisément parce qu'il repose sur ce `COUNT` en interne qu'**il ignore les `NULL`** au lieu de les traiter comme des zéros.

🎯 **Piège classique (vu en quiz)** : avec les valeurs `10, 20, NULL`, `AVG` renvoie **15** (30 ÷ 2 — le `NULL` n'est compté ni dans la somme ni dans le compte) — pas 10 (30 ÷ 3), et surtout pas une erreur.

### GROUP BY — LA clause de l'analytics

```sql
SELECT buyer, SUM(spend)
FROM purchases
GROUP BY buyer
```

**Mécanique en 2 temps** :
1. Les lignes sont regroupées selon la/les colonne(s) du `GROUP BY` → chaque valeur unique devient une sous-table
2. La fonction d'agrégation s'applique **sur chaque sous-table**

Résultat sur l'exemple : Julie 12.5, Paul 10, Thomas 5, Julien 17.5.

Règles à retenir :
- Toute colonne du `SELECT` qui n'est pas dans une fonction d'agrégation **doit** figurer dans le `GROUP BY`, sinon impossible d'afficher un résultat cohérent
- On peut grouper sur **plusieurs colonnes** (`GROUP BY colonne_1, colonne_2`)
- On peut utiliser **plusieurs fonctions d'agrégation** dans le même `SELECT`
- On peut référencer les colonnes du `GROUP BY` par leur **index** plutôt que leur nom : `GROUP BY 1, 2` reprend la 1ère et 2ème colonne du `SELECT`

🎯 **Piège classique (vu en quiz)** : on **peut** techniquement grouper sur une colonne absente du `SELECT` — ça fonctionne, la colonne n'apparaît simplement pas dans le résultat. Peu lisible, donc rarement une bonne idée, mais ce n'est pas une erreur SQL.

### HAVING — filtrer après agrégation

```sql
SELECT buyer, SUM(spend) AS total_spend
FROM purchases
GROUP BY buyer
HAVING total_spend > 10
```

Résultat : Julie (12.5) et Julien (17.5) seulement.

### HAVING vs WHERE

| | `HAVING` | `WHERE` |
|---|---|---|
| Moment du filtre | **Après** l'agrégation (post-filtering) | **Avant** l'agrégation (pre-filtering) |
| Peut utiliser une fonction d'agrégation ? | ✅ Oui | ❌ Non — la valeur agrégée n'existe pas encore à ce stade |
| S'applique sur | Le résultat groupé | Les lignes individuelles brutes |

Sur le même exemple, `WHERE spend > 10` (avant le `GROUP BY`) ne garde qu'**une seule ligne brute** — celle de Julien à 15, la seule ligne individuelle dont `spend` dépasse 10 — le résultat groupé donne donc `Julien: 15`, différent de celui obtenu avec `HAVING total_spend > 10` (Julie 12.5 + Julien 17.5), même si la condition numérique semble identique au premier coup d'œil.

🎯 **Ordre des clauses à retenir** : `WHERE` est **toujours avant** `GROUP BY` dans une requête. `WHERE` filtre les lignes individuelles avant qu'elles soient groupées ; `HAVING` filtre les lignes après le groupage. On n'est pas obligé d'avoir les deux ensemble, mais rien n'empêche de les combiner dans la même requête.

---

## 🔑 Clés primaires & étrangères

**Clé primaire (Primary Key)** : identifie **de façon unique** chaque ligne d'une table. Peut être une seule colonne ou une combinaison de plusieurs, souvent auto-incrémentale (`product_id`, `customer_id`, `order_id`...).

**Clé étrangère (Foreign Key)** : une colonne qui **référence la clé primaire d'une autre table** — c'est ce qui rend les jointures possibles.

Exemple : dans la table `purchases`, `customer_id` référence la clé primaire de `customers`, et `product_id` référence la clé primaire de `products`. Ce sont ces relations de clés qui permettent de relier les tables entre elles.

---

## 🔗 Jointures

Table `products` :

| product_id | name | price |
|---|---|---|
| 1 | apple | 0.50 |
| 2 | pear | 1.50 |
| 3 | banana | 1 |
| 4 | tomato | 0.50 |
| 5 | strawberry | 0.1 |

### INNER JOIN

```sql
SELECT *
FROM purchases AS purchase
INNER JOIN products AS product
  ON purchase.product_id = product.id
```

Ne garde que les lignes où la clé existe **des deux côtés** (intersection). `JOIN` seul, sans préciser le type, équivaut à un `INNER JOIN` par défaut sur BigQuery.

### LEFT JOIN

```sql
SELECT *
FROM purchases AS purchase
LEFT JOIN products AS product
  ON purchase.product_id = product.id
```

Garde **toutes les lignes de la table de gauche** (celle du `FROM`), et complète avec `NULL` côté droit quand il n'y a pas de correspondance. Exemple concret vu en slide : une commande référence un `product_id` qui n'existe pas dans `products` — un `INNER JOIN` fait disparaître cette ligne, un `LEFT JOIN` la garde avec des `NULL` sur les colonnes produit.

### RIGHT JOIN

Symétrique du `LEFT JOIN` : garde toutes les lignes de la table de **droite**. Peu utilisé en pratique — on obtient le même résultat en inversant simplement l'ordre `FROM`/`JOIN` avec un `LEFT JOIN`.

### FULL OUTER JOIN

Garde **toutes les lignes des deux tables**, correspondance ou non, avec des `NULL` des deux côtés là où ça ne matche pas. Cas d'usage plus rare. Se visualise comme la somme de trois zones : les lignes qui matchent (comme un `INNER JOIN`), les lignes de gauche sans correspondance (comme un `LEFT JOIN`), et les lignes de droite sans correspondance (comme un `RIGHT JOIN`).

### Comparatif des jointures

| Type | Lignes conservées |
|---|---|
| `INNER JOIN` | Correspondance dans les deux tables uniquement |
| `LEFT JOIN` | Toutes les lignes de gauche + correspondances à droite |
| `RIGHT JOIN` | Toutes les lignes de droite + correspondances à gauche |
| `FULL OUTER JOIN` | Toutes les lignes des deux tables |

🎯 **Piège classique (vu en quiz)** : une jointure **sans le mot-clé `ON`** ne fonctionne pas — `ON` (ou `USING` si les colonnes ont le même nom, spécifique BigQuery) définit la condition de correspondance entre les deux tables.

### Jointures avec conditions multiples

```sql
SELECT *
FROM purchases AS purchase
INNER JOIN products AS product
  ON purchase.product_id = product.id
  AND purchase.sale_date = product.purchase_date
```

Plusieurs égalités séparées par `AND` dans le `ON`.

### Jointures multiples

```sql
SELECT
  buyer.name AS buyer_name,
  product.name AS product_name,
  SUM(purchase.quantity) AS total_quantity
FROM purchases AS purchase
INNER JOIN buyers AS buyer
  ON purchase.buyer_id = buyer.id
INNER JOIN products AS product
  ON purchase.product_id = product.id
GROUP BY buyer.name, product.name
```

Rien n'empêche d'enchaîner autant de `JOIN` que nécessaire dans une même requête.

> ⚠️ **Coquille repérée sur le slide "Multiple Joins"** : la deuxième condition de jointure y est écrite `ON purchase.product_id = buyer.id`. Logiquement, ça doit être `product.id` (on joint `products` sur sa propre clé, pas sur celle de `buyers`) — corrigé ci-dessus.

---

## 📦 Subqueries & CTE

**Définition** : une subquery permet de regrouper plusieurs requêtes distinctes en une seule — la sortie d'une première requête devient la source (`FROM`) d'une seconde. Intérêt principal : **simplifier des opérations SQL complexes** et améliorer la lisibilité/flexibilité du code.

### La clause WITH ... AS

```sql
WITH name_subquery AS (
  SELECT ...
  FROM source_table
)
SELECT ...
FROM name_subquery
```

Syntaxe standard d'une **CTE (Common Table Expression)** : on nomme un bloc de requête (`name_subquery`), réutilisable ensuite comme une table normale dans le `FROM` de la requête principale. Toujours entourer la subquery de parenthèses.

**Deux cas d'usage concrets vus en session :**

**1. Injecter une agrégation `GROUP BY` dans une requête de jointure ultérieure**

```sql
WITH orders_subquery AS (
    SELECT
      orders_id
      ,SUM(turnover) AS turnover
    FROM sales
    GROUP BY
      orders_id)

SELECT
  orders_id
  ,turnover
  ,shipping_fee
FROM orders_subquery
INNER JOIN orders_ship USING(orders_id)
```

**2. Enchaîner plusieurs calculs successifs dans une seule requête**

```sql
WITH margin_subquery AS (
    SELECT
      orders_id
      ,turnover
      ,turnover - purchase_cost AS margin
    FROM course17.orders
  )

SELECT
  orders_id
  ,turnover
  ,margin
  ,SAFE_DIVIDE(margin,turnover) AS margin_percent
FROM margin_subquery
```

📌 Ce deuxième exemple illustre bien le principe **"jamais de division directe sur une colonne intermédiaire"** : la marge (`margin`) est calculée dans la CTE, puis divisée par le chiffre d'affaires dans la requête finale, avec `SAFE_DIVIDE` pour se prémunir d'une division par zéro.

**Nested query (sous-requête imbriquée) vs CTE** : une nested query est une requête directement imbriquée dans le `FROM` ou le `WHERE` d'une autre, sans `WITH`. Une CTE nomme explicitement ce bloc via `WITH ... AS` en amont. Les deux appartiennent à la même famille (subqueries), mais une CTE est en général plus lisible dès que la logique se complexifie.

---

## 🪟 Window Functions

**Définition** : une window function effectue un calcul sur une **fenêtre de lignes** (window frame) pour renvoyer un résultat — **sans réduire le nombre de lignes**, contrairement à un `GROUP BY` qui condense les lignes en sous-tables.

- La largeur de la fenêtre est déterminée par `PARTITION BY` (l'équivalent conceptuel du `GROUP BY`, mais qui ne fusionne pas les lignes)
- Le calcul peut être une **agrégation** (`SUM`, `AVG`, `MIN`, `MAX`...) ou un **tri/rang** (`ROW_NUMBER`, `RANK`, `DENSE_RANK`)

### Agrégation globale avec OVER()

```sql
SELECT
  model
  ,model_type
  ,SUM(stock_value) OVER () AS stock_global
FROM circle_stock
```

Le mot-clé **`OVER`** signale une window function — **pas de `GROUP BY`** ici. `OVER ()` vide = fenêtre globale sur toutes les lignes : le total général est calculé une fois puis **répété sur chaque ligne** (contrairement à un `GROUP BY` qui condenserait tout en une seule ligne).

### Agrégation par partition

```sql
SELECT
  model
  ,model_type
  ,stock_value
  ,SUM(stock_value) OVER (PARTITION BY model_type) AS stock_model_type
FROM circle_stock
```

`PARTITION BY model_type` détermine la largeur de la fenêtre : le total est calculé **par `model_type`**, et répété sur chaque ligne de ce groupe — toutes les lignes "T-shirt" affichent le même total, toutes les lignes "Legging" affichent le leur, **sans que les lignes individuelles disparaissent**.

### Window function vs GROUP BY + JOIN : la même chose, deux écritures

Le même résultat que l'exemple `PARTITION BY` ci-dessus peut être obtenu avec un `GROUP BY` suivi d'un `JOIN` :

```sql
WITH stock_model_type AS (
    SELECT
      model_type
      ,SUM(stock_value) AS stock_model_type
    FROM circle_stock
    GROUP BY model_type
  )

SELECT
  model
  ,model_type
  ,stock_value
  ,stock_model_type
FROM circle_stock
INNER JOIN stock_model_type USING (model_type)
```

La window function fait strictement la même chose **en une seule requête, plus courte** — c'est tout l'intérêt pratique par rapport à un `GROUP BY` + `JOIN` classique.

### ROW_NUMBER / RANK / DENSE_RANK

Mentionnées à l'oral (sans slide dédié dans ce lot de captures) : ces fonctions numérotent/classent les lignes au lieu d'agréger.

```sql
SELECT
  *,
  ROW_NUMBER() OVER (ORDER BY date, order_id) AS row_num
FROM orders
```

Assigne un numéro de ligne croissant selon l'ordre choisi (**ascendant par défaut**). Cas d'usage typique : isoler la première commande de chaque client. Pour filtrer sur ce rang (`WHERE row_num = 1`), il faut obligatoirement **passer par une CTE** — impossible d'utiliser `WHERE` directement sur le résultat d'une window function dans la requête où elle est calculée, car `WHERE` s'exécute avant que la window function soit évaluée.

🎯 **Piège classique (vu en quiz)** : `ROW_NUMBER() OVER (ORDER BY date)` **n'écrit pas** l'ordre trié dans la table, **ne supprime pas** les doublons, et **ne calcule pas** de somme — ça se contente d'assigner un numéro séquentiel à chaque ligne, sans rien changer d'autre.

### Window function combinée avec GROUP BY

🎯 **Piège classique (vu en quiz)** : une requête peut tout à fait combiner `GROUP BY` et une window function dans le même `SELECT` — par exemple `RANK() OVER (ORDER BY SUM(salary))` avec un `GROUP BY department` à la fin. Ça fonctionne car le `GROUP BY` s'exécute **avant** le `SELECT` (et donc avant l'évaluation de la window function) : l'agrégation `SUM(salary)` est donc déjà disponible quand la fonction fenêtrée l'utilise pour classer les lignes.

---

## 🔌 Fivetran & API

### API — qu'est-ce que c'est

Une API, c'est une requête HTTP envoyée à un serveur qui renvoie une réponse. Deux notions à ne pas confondre :
- **API** : la requête est **active** — c'est vous qui demandez l'information
- **Webhook** : à l'inverse, **passif** — l'information arrive automatiquement quand un événement se produit côté serveur, sans que vous ayez à la demander

### Anatomie d'une requête

Une requête HTTP a 4 composants.

**URL**, décomposée en :

```
https://www.google.com:443/search?q=le+wagon&hl=en
```

| Élément | Exemple | Rôle |
|---|---|---|
| scheme | `https://` | Protocole |
| host | `www.google.com` | Serveur ciblé |
| port | `:443` | Peut être omis si port par défaut |
| endpoint | `/search` | Ressource demandée |
| query parameters | `?q=le+wagon&hl=en` | Paramètres de la requête |

- **Méthodes** : `GET` (récupérer de la donnée) / `POST` (envoyer/soumettre de la donnée)
- **Headers** : contexte additionnel pour le serveur (`Accept`, `Accept-Language`, `User-Agent`...)
- **Body** (optionnel) : payload envoyé au serveur, uniquement sur les requêtes `POST`

La plupart des API nécessitent une authentification — toujours vérifier la doc spécifique de chaque API. Deux méthodes principales :
- Dans les **query parameters** (`api_key=xxxxx`)
- Dans les **headers** (`Authorization: Bearer xxxx`)

### Anatomie d'une réponse

Une réponse HTTP a 3 composants.

**Status codes** :

| Code | Signification |
|---|---|
| 200 | Succès |
| 301 | Redirection |
| 401 | Unauthorized (requête non authentifiée) |
| 403 | Forbidden (accès interdit) |
| 404 | Not Found |
| 500 | Internal Server Error (problème côté serveur) |

- **Headers** : méta-information pour aider à parser la réponse
- **Body** : contenu réellement renvoyé (HTML, JSON, données...)

### Fivetran — méthodes de transfert de données

Fivetran est un outil d'**ingestion de données** vers une data platform (d'autres alternatives existent pour de gros volumes, ex. Airbyte). Plusieurs méthodes existent pour synchroniser les données selon la source :

| Méthode | Update | Charge serveur | Perte de données |
|---|---|---|---|
| **Table dump** | Batch | Lourde — refresh complet | ⚠️ Oui, sur les changements d'état |
| **Table differencing** | Batch | — | Init ou full reSync |
| **Timestamp tracking** | Batch | Légère — incrémental (mais `delete` complexe) | ⚠️ Oui, sur les changements d'état |
| **Log-based CDC** | Temps réel ou batch | Légère — incrémental | ✅ Non — via un fichier `LOG` d'événements |
| **Trigger-based CDC** | Temps réel | Légère — incrémental | ✅ Non |

Le choix de la méthode de synchronisation incrémentale dépend du **format de la source** et de **ses quotas/limites**. Les méthodes CDC (*Change Data Capture*, log-based ou trigger-based) sont les plus fiables : elles capturent chaque événement individuellement plutôt que l'état global de la table, donc pas de perte d'information même en cas de suppression côté source.

---

## 🐙 Git & GitHub

### Pourquoi Git

Outil de collaboration pour :
- **Tracker** les versions d'un document
- **Garder un historique** des changements
- **Faciliter le travail en équipe**

### Principe de suivi des fichiers

```
Untracked / Modified  --git add-->  Staged  --git commit-->  Local repo  --git push-->  Remote repo
```

- **Untracked** : nouveau fichier jamais ajouté à Git
- **Modified** : fichier déjà suivi mais changé depuis le dernier commit
- **Staged** : fichier prêt à être "photographié" au prochain commit
- **Local repo** : historique de commits sur la machine
- **Remote repo** : historique poussé sur GitHub

📌 Git doit tracker le code, **pas** les datasets, les gros fichiers, les fichiers temporaires ou les credentials.

### Branching

- `master`/`main` = le code **en production** — on ne travaille jamais directement dessus
- Créer une **nouvelle branche** pour chaque nouvelle fonctionnalité ou correction de bug
- Faire des **commits** sur cette branche au fil des modifications (permet de revenir en arrière en cas d'erreur)
- Une fois le travail prêt, **merge** (fusion) dans `master`/`main`
- **Nettoyer** : supprimer la branche une fois fusionnée, puis répéter le cycle pour la fonctionnalité suivante

### GitHub

Serveur web qui héberge le repo à distance — permet de sauvegarder/accéder à son travail depuis n'importe où, et de collaborer à plusieurs sur le même repo.

```
git clone   →  copie initiale du repo distant vers le poste local
git push    →  envoie les commits locaux vers le repo distant ("origin")
git pull    →  récupère la dernière version du repo distant en local
```

Avec plusieurs collaborateurs, chacun a son propre repo local relié au même repo distant ("origin") : on `pull` pour se mettre à jour, on `add`/`commit` ses changements en local, on `push` pour les partager.

### Workflow de collaboration Git

1. Découper le travail en jobs parallèles (ex. chargement / nettoyage / agrégation)
2. Diviser chaque job en petites tâches
3. Travailler sur des **branches différentes** pour chaque partie du projet
4. Fusionner les commits dans `master` via une **pull request**
5. Résoudre les éventuels **conflits**

**Top tips à retenir :**
- Committer **souvent et par petits incréments**
- Mettre à jour sa branche **régulièrement** (`git pull`)
- **Tester** son code avant de le publier

### Workflow détaillé (démo live en session)

Démo terminal complète faite par le formateur, utile à garder en mémoire pour la pratique :

```bash
mkdir mon-projet && cd mon-projet
git init                          # initialise un repo vide (crée le .git)
touch query.sql
# ... on édite et sauvegarde le fichier ...
git status                        # affiche les fichiers non-trackés/modifiés
git add query.sql                 # ou : git add .   pour tout ajouter
git commit -m "message de commit" # "prend une photo" de l'état actuel

# mise en ligne (une seule fois, après création du repo vide sur github.com) :
git remote add origin <url-du-repo>
git branch -M main                # renomme la branche par défaut en "main"
git push -u origin main

# pour une nouvelle fonctionnalité :
git checkout -b feature-xyz       # nouvelle branche
# ... modifications, add, commit ...
git push -u origin feature-xyz
# → ouvrir une Pull Request sur GitHub pour merger dans main
```

📌 Point à retenir : `git init` et `git remote add` sont **deux étapes distinctes** — un repo local et un repo GitHub sont "techniquement décorrélés" à la base, il faut explicitement les relier.

---

## 🏗️ dbt

### Concept général

dbt gère une version **production** de la donnée transformée — **opérationnelle, optimisée et fiable** — sans jamais stocker la donnée lui-même : il orchestre les transformations, la donnée elle-même reste sur la data platform (BigQuery, Snowflake, etc.).

Plusieurs développeurs (chacun avec son environnement dbt Cloud personnel) peuvent travailler en parallèle, **modulariser**, **centraliser** et **tester** leurs transformations avant de converger vers un environnement de **production** commun (dbt Cloud Prod). Cette version prod, une fois lue depuis la data platform, alimente les outils BI (Power BI, Looker...).

### Créer des modèles

Un modèle dbt est simplement une requête `SELECT` sauvegardée dans un fichier `.sql`.

| Commande | Effet |
|---|---|
| `dbt run` | Exécute le(s) modèle(s) et crée les vues correspondantes sur la data platform |
| `dbt test` | Exécute les tests déclarés dans `models/schema.yml` |
| `dbt build` | `dbt test` **puis** `dbt run` (tests d'abord, exécution ensuite) |

Les modèles se lient entre eux (un modèle peut lire un autre modèle en `FROM`) et forment un **DAG** (Directed Acyclic Graph) — un graphe de dépendances orienté et sans boucle, que dbt utilise pour déterminer automatiquement l'ordre d'exécution.

### Organiser un projet dbt — architecture en 3 couches

| Couche | Rôle | Jointures/agrégations ? | Sortie |
|---|---|---|---|
| **Staging** | Nettoyage de la donnée brute | ❌ Non | View |
| **Intermediate** | Découpe la complexité, jointures, groupements | ✅ Oui | View |
| **Mart** | Transformation légère, insight business, prêt pour la BI | ✅ Oui (léger) | **Table** matérialisée |

L'ordre d'exécution (staging → intermediate → mart) est géré **automatiquement** par dbt via le DAG — pas besoin de l'orchestrer à la main.

### Version control avec Git

dbt s'intègre nativement à Git pour le versionning :
- Gestion effective des versions **prod** et **dev**
- Historique des modifications (commits) pour un rollback facile
- Organisation du développement de fonctionnalités par **branches**
- L'exécution des commandes dbt en production est gérée via des **Jobs**
- C'est **GitHub** qui gère la version de production via les branches et les pull requests — la même logique `feature_a/b/c` → PR → merge dans `main/master/prod` que pour n'importe quel projet Git

---

## 🎯 Pièges classiques (interview prep)

Cette session s'est terminée par un quiz interactif volontairement piégeux. Les pièges ci-dessous valent le détour pour un entretien technique — exactement le genre de question "on dirait un piège mais en fait ça marche" qui teste une vraie compréhension plutôt qu'un apprentissage par cœur.

| Question piège | Réponse |
|---|---|
| `MIN`/`MAX` sur une colonne texte : erreur ? | Non — fonctionne, retourne la valeur la plus petite/grande par ordre alphabétique |
| `AVG` sur une colonne texte : ça marche aussi ? | Non — contrairement à `MIN`/`MAX`, `AVG` ne fonctionne pas sur du texte |
| `AVG` sur `10, 20, NULL` : le résultat ? | **15** (30 ÷ 2) — le `NULL` n'est compté ni dans la somme ni dans le compte, jamais traité comme 0 |
| `COUNT(colonne)` vs `COUNT(*)` avec des `NULL` ? | `COUNT(colonne)` ignore les `NULL` ; `COUNT(*)` compte toutes les lignes |
| Peut-on grouper (`GROUP BY`) sur une colonne absente du `SELECT` ? | Oui — mais la colonne n'apparaît simplement pas dans le résultat |
| `GROUP BY 1` — ça veut dire quoi ? | Fait référence à l'**index** de la 1ère colonne du `SELECT`, pas à une valeur littérale |
| `WHERE` peut-il venir après `GROUP BY` ? | Non — `WHERE` est **toujours avant** `GROUP BY` dans l'ordre d'une requête |
| Nested query vs CTE — même chose ? | Famille proche (subqueries), mais une CTE se nomme explicitement via `WITH ... AS` ; une nested query est directement imbriquée dans le `FROM`/`WHERE` sans être nommée |
| Quel mot-clé signale une window function ? | `OVER` (`SUM(...) OVER`, `RANK() OVER`, `COUNT(...) OVER`...) |
| `ROW_NUMBER() OVER (ORDER BY date)` trie/déduplique/somme la table ? | Non à tout — assigne juste un numéro de ligne séquentiel. Ascendant par défaut |
| Une window function peut-elle cohabiter avec un `GROUP BY` dans la même requête ? | Oui — le `GROUP BY` s'exécute avant le `SELECT`, l'agrégation est donc déjà prête quand la window function s'exécute |
| Une jointure sans `ON` fonctionne ? | Non — `ON` (ou `USING`) est obligatoire pour définir la clé de correspondance |

> ❓ Une question du quiz portait sur les clauses "obligatoires" à partir d'un `SELECT` + `WHERE` donnés, mais le passage du transcript est resté trop ambigu pour la retranscrire fidèlement — reportée en question ouverte ci-dessous.

---

## 🔗 Liens avec d'autres chapitres

- Chapitre SQL initial (fondamentaux, avant ce reboot) — *lien à ajouter une fois le nom de fichier confirmé*
- Chapitre dbt initial (intro/architecture) — *lien à ajouter*
- Chapitre Git/GitHub initial — *lien à ajouter*
- Chapitre Power BI (juste avant cette session — la notion de `SAFE_DIVIDE` y était déjà vue) — *lien à ajouter*
- Piste pour `references/` : un mémo "SQL — pièges & questions type entretien" regroupant la section ci-dessus, réutilisable indépendamment de ce chapitre

---

## ✅ Actions post-session

- [ ] Proposer des idées de sujets de projet au formateur (deadline **une semaine après la session**, soit vers le 14 août — deux sujets nécessaires pour les deux groupes)
- [ ] Faire les exercices SQL sur SQLite Online (environnement temporaire — ne pas compter sur une sauvegarde)
- [ ] Revoir les exercices des journées précédentes si besoin, notamment sur les **Window Functions**
- [ ] Trouver/tester des fichiers de base de données compatibles BigQuery pour l'exercice CRUD
- [ ] Faire les 2 exercices Fivetran et les 2 exercices Git/dbt (à la carte)

---

## ❓ Questions ouvertes

- [ ] Clause "obligatoire" avec un `SELECT` + `WHERE` donnés — passage du quiz resté ambigu dans le transcript, à re-clarifier (voir note dans la section Pièges classiques)
- [ ]  
- [ ]  
