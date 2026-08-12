---
title: "SQL — JOINs & Testing"
aliases:
  - "SQL JOINs"
  - "JOINs & Testing"
  - "SQL Joins and Data Quality"
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 7
language: "SQL"
database: "BigQuery / GoogleSQL"
topics:
  - "SQL"
  - "BigQuery"
  - "JOINs"
  - "Granularity"
  - "Data Quality"
tags:
  - brocode
  - wagon2321/cours
  - sql
  - bigquery
  - joins
  - data-quality
  - granularity
---

# 📝 07 — SQL · JOINs & Testing

> [!info] Navigation Brocode
> **← Précédent :** [[06_sql_aggregation_string_date_time_functions_sol|06 — SQL · Aggregations, String, Date & Time]] · **Suivant → :** [[08_subqueries_ctes_union_sol|08 — SQL · CTEs, Subqueries & UNION]]
>
> [!tip] Navigation Obsidian
> Utilise l’**Outline** pour parcourir les sections, `Cmd/Ctrl + O` pour le Quick Switcher et les **backlinks** pour retrouver les connexions entre notes.

---

> [!abstract] Objectif du chapitre
> **Objectif du chapitre :** comprendre comment relier plusieurs tables SQL proprement, choisir le bon type de jointure, maîtriser la granularité du résultat et **tester** qu'une jointure n'a ni perdu ni dupliqué de l'information.
**rédigé par : ChatGPT SOL**
---

## 🧠 1. Pourquoi faire des jointures ?

Dans une base de données relationnelle, les informations sont volontairement réparties dans plusieurs tables.

Exemple simplifié :

- `products` contient les informations sur les produits ;
- `buyers` contient les informations sur les clients ;
- `purchases` contient les transactions.

La table `purchases` joue alors le rôle de **table de faits / table intermédiaire** : elle relie un acheteur à un produit et porte des informations propres à l'achat (`quantity`, `sale_date`, etc.).

```text
buyers                         purchases                         products
──────                         ─────────                         ────────
buyer_id   ───────────────┐    purchase_id                       product_id
name                      └──► buyer_id                          name
                              product_id ◄────────────────────── product_id
                              quantity                           price
                              sale_date
```

Une jointure permet donc de **rapatrier dans un même résultat des colonnes provenant de plusieurs tables**.

```sql
SELECT
  pu.purchase_id,
  bu.name AS buyer_name,
  pr.name AS product_name,
  pu.quantity
FROM purchases AS pu
INNER JOIN buyers AS bu
  ON pu.buyer_id = bu.buyer_id
INNER JOIN products AS pr
  ON pu.product_id = pr.product_id;
```

💡 **Idée centrale :** avant d'écrire un `JOIN`, il faut savoir **quelle ligne représente quoi dans chaque table** et **quelles colonnes permettent de relier ces lignes**.

---

## 🔑 2. Primary Key & Foreign Key

### Primary Key — clé primaire

Une **Primary Key (PK)** identifie de manière unique chaque ligne d'une table.

Exemple :

```text
products
product_id | name
-----------|--------
1          | Apple
2          | Banana
3          | Tomato
```

Ici :

```text
product_id = Primary Key
```

Chaque `product_id` apparaît une seule fois.

---

### Foreign Key — clé étrangère

Une **Foreign Key (FK)** est une colonne qui référence généralement la clé primaire d'une autre table.

```text
purchases
purchase_id | product_id | quantity
------------|------------|---------
101         | 1          | 2
102         | 1          | 4
103         | 3          | 1
```

Ici :

- `purchase_id` peut être la PK de `purchases`;
- `product_id` est une FK vers `products.product_id`.

Le `product_id = 1` peut apparaître plusieurs fois dans `purchases` parce qu'un même produit peut être acheté plusieurs fois.

```text
products.product_id   PK
        │
        └──────────────► purchases.product_id   FK
```

#### À retenir

| Notion | Rôle | Unicité |
|---|---|---|
| **Primary Key** | Identifie une ligne | Oui |
| **Foreign Key** | Référence une autre table | Pas forcément |
| **Join key** | Colonne(s) utilisées pour relier deux tables | Dépend du modèle |

> 🧠 **Complément Brocode :** SQL n'oblige pas techniquement un `JOIN` à utiliser une PK et une FK. On peut joindre deux tables sur n'importe quelle condition booléenne valide. En revanche, comprendre les PK/FK est essentiel pour éviter les jointures incohérentes.

---

## 🧱 3. Anatomie d'un JOIN

Structure générale :

```sql
SELECT
  ...
FROM table_left AS l
JOIN table_right AS r
  ON l.key = r.key;
```

Les éléments principaux sont :

```text
SELECT     → quelles colonnes retourner ?
FROM       → quelle est la table de départ ?
JOIN       → quelle table ajouter ?
ON / USING → sur quelle(s) clé(s) relier les lignes ?
```

Exemple :

```sql
SELECT
  pu.purchase_id,
  pu.quantity,
  pr.name,
  pr.price
FROM purchases AS pu
INNER JOIN products AS pr
  ON pu.product_id = pr.product_id;
```

Dans cette requête :

```text
table de gauche  = purchases
table de droite  = products
clé de jointure  = product_id
type de JOIN     = INNER JOIN
```

---

## 🏷 4. Alias de tables

Les alias rendent les requêtes plus lisibles et évitent les ambiguïtés.

```sql
FROM purchases AS pu
INNER JOIN products AS pr
```

On peut ensuite écrire :

```sql
pu.product_id
pr.product_id
```

plutôt que :

```sql
purchases.product_id
products.product_id
```

#### Pourquoi qualifier les colonnes ?

Supposons que les deux tables contiennent une colonne `product_id`.

Ceci peut devenir ambigu :

```sql
SELECT product_id
```

SQL ne sait pas nécessairement de quelle table vient la colonne.

Préférer :

```sql
SELECT pu.product_id
```

ou :

```sql
SELECT pr.product_id
```

#### Bonne pratique

Utiliser des alias :

- courts ;
- explicites ;
- cohérents.

```text
purchases → pu
products  → pr
buyers    → bu
orders    → ord
```

Éviter autant que possible :

```text
p
p1
x
t
tmp
```

lorsque la requête devient longue.

> ⚠️ L'alias lui-même n'est pas toujours obligatoire. Ce qui devient indispensable en cas d'ambiguïté, c'est de **qualifier la colonne** avec sa table ou son alias.

---

## 🔗 5. `ON` vs `USING`

### `ON`

`ON` permet d'écrire explicitement la condition de jointure.

```sql
SELECT *
FROM purchases AS pu
INNER JOIN products AS pr
  ON pu.product_id = pr.id;
```

Très utile lorsque les colonnes ont des noms différents :

```text
purchases.product_id
products.id
```

`ON` permet aussi des conditions plus complexes :

```sql
ON pu.product_id = pr.product_id
AND pu.sale_date = pr.purchase_date
```

---

### `USING`

`USING` peut être utilisé lorsque la colonne de jointure porte **le même nom dans les deux tables**.

```sql
SELECT *
FROM purchases
INNER JOIN products
USING (product_id);
```

Au lieu de :

```sql
SELECT *
FROM purchases AS pu
INNER JOIN products AS pr
  ON pu.product_id = pr.product_id;
```

Un avantage pratique est que la clé utilisée dans `USING` n'apparaît qu'une seule fois dans le résultat d'un `SELECT *`.

#### Résumé

| | `ON` | `USING` |
|---|---|---|
| Noms de colonnes différents | ✅ | ❌ |
| Même nom de colonne | ✅ | ✅ |
| Plusieurs conditions complexes | ✅ | Limité |
| Syntaxe concise | ◑ | ✅ |
| Contrôle explicite | ✅ | ◑ |

> 🧠 **Complément Brocode :** `USING` n'est pas propre à BigQuery. On le retrouve dans plusieurs dialectes SQL. En BigQuery, il est néanmoins très pratique lorsque les clés ont exactement le même nom.

---

## 👈 6. Table de gauche vs table de droite

Dans :

```sql
FROM purchases AS pu
LEFT JOIN products AS pr
```

la table de gauche est :

```text
purchases
```

et la table de droite est :

```text
products
```

Cette notion est particulièrement importante pour :

- `LEFT JOIN`;
- `RIGHT JOIN`.

```text
FROM A
LEFT JOIN B
```

signifie :

```text
garder toutes les lignes de A
```

---

## 🟣 7. Les principaux types de JOIN

Prenons deux ensembles de clés :

```text
Table A : 1, 2, 3, 4
Table B :    2, 3, 4, 5
```

---

### 7.1 `INNER JOIN`

Un `INNER JOIN` conserve uniquement les lignes qui trouvent une correspondance dans **les deux tables**.

```text
A : 1 [2 3 4]
B :   [2 3 4] 5

Résultat : 2, 3, 4
```

```sql
SELECT
  pu.purchase_id,
  pr.name
FROM purchases AS pu
INNER JOIN products AS pr
  ON pu.product_id = pr.product_id;
```

#### Conséquence

Si :

```text
purchases.product_id = 32
```

mais que `32` n'existe pas dans `products.product_id`, cette ligne disparaît du résultat.

#### Cas d'usage

- ne garder que les correspondances valides ;
- enrichir une table lorsqu'une correspondance est obligatoire ;
- exclure automatiquement les lignes orphelines.

#### Risque

⚠️ **Perte silencieuse de lignes.**

Toujours vérifier combien de lignes existent :

```sql
SELECT COUNT(*)
FROM purchases;
```

puis après la jointure :

```sql
SELECT COUNT(*)
FROM purchases AS pu
INNER JOIN products AS pr
  ON pu.product_id = pr.product_id;
```

---

### 7.2 `LEFT JOIN`

Un `LEFT JOIN` conserve **toutes les lignes de la table de gauche**.

```text
A : [1 2 3 4]
B :    2 3 4 5

Résultat :
1 → NULL côté B
2 → match
3 → match
4 → match
```

```sql
SELECT
  pu.purchase_id,
  pu.product_id,
  pr.name
FROM purchases AS pu
LEFT JOIN products AS pr
  ON pu.product_id = pr.product_id;
```

Si `product_id = 32` n'existe pas dans `products` :

```text
purchase_id | product_id | product_name
------------|------------|-------------
145         | 32         | NULL
```

#### Cas d'usage

Le `LEFT JOIN` est extrêmement fréquent en analytics :

> « Garde mon univers de départ, et enrichis-le si une correspondance existe. »

---

### 7.3 `RIGHT JOIN`

Un `RIGHT JOIN` conserve toutes les lignes de la table de droite.

```sql
SELECT *
FROM purchases AS pu
RIGHT JOIN products AS pr
  ON pu.product_id = pr.product_id;
```

En pratique, on peut presque toujours réécrire cette requête avec un `LEFT JOIN` en inversant les tables :

```sql
SELECT *
FROM products AS pr
LEFT JOIN purchases AS pu
  ON pu.product_id = pr.product_id;
```

#### Bonne pratique

Pour améliorer la lisibilité, beaucoup d'équipes préfèrent rester sur :

```text
LEFT JOIN
```

et changer l'ordre des tables.

---

### 7.4 `FULL OUTER JOIN`

Un `FULL OUTER JOIN` conserve :

- toutes les lignes de gauche ;
- toutes les lignes de droite ;
- les correspondances ;
- les non-correspondances.

```text
A : 1 2 3 4
B :   2 3 4 5

Résultat : 1 2 3 4 5
```

Les parties non correspondantes reçoivent des `NULL`.

```sql
SELECT *
FROM purchases AS pu
FULL OUTER JOIN products AS pr
  ON pu.product_id = pr.product_id;
```

#### Cas d'usage

Très utile pour :

- comparer deux sources ;
- détecter les éléments présents d'un côté mais pas de l'autre ;
- faire de la réconciliation de données.

Exemple :

```sql
SELECT *
FROM source_a AS a
FULL OUTER JOIN source_b AS b
  ON a.id = b.id
WHERE a.id IS NULL
   OR b.id IS NULL;
```

Cette requête isole les **différences entre les deux sources**.

---

### 7.5 `CROSS JOIN`

Le `CROSS JOIN` produit le **produit cartésien**.

Si :

```text
Table A = 3 lignes
Table B = 4 lignes
```

alors :

```text
A CROSS JOIN B = 3 × 4 = 12 lignes
```

```sql
SELECT *
FROM colors
CROSS JOIN sizes;
```

Exemple :

```text
colors : Red, Blue
sizes  : S, M, L
```

Résultat :

```text
Red  S
Red  M
Red  L
Blue S
Blue M
Blue L
```

#### Cas d'usage

- construire toutes les combinaisons possibles ;
- créer un calendrier × une liste d'entités ;
- générer une grille de scénarios.

⚠️ **Attention au volume.** Deux grandes tables peuvent provoquer une explosion massive du nombre de lignes.

---

## 🧾 8. Cheat sheet des JOINs

| JOIN | Lignes de gauche | Lignes de droite | Non-match |
|---|---:|---:|---|
| `INNER JOIN` | seulement si match | seulement si match | supprimés |
| `LEFT JOIN` | toutes | si match | `NULL` à droite |
| `RIGHT JOIN` | si match | toutes | `NULL` à gauche |
| `FULL OUTER JOIN` | toutes | toutes | `NULL` du côté manquant |
| `CROSS JOIN` | toutes | toutes | toutes les combinaisons |

#### Raccourci mental

```text
INNER = intersection
LEFT  = tout à gauche
RIGHT = tout à droite
FULL  = tout des deux côtés
CROSS = toutes les combinaisons
```

---

## 🧩 9. Jointure sur plusieurs conditions

Une jointure peut dépendre de plusieurs colonnes.

```sql
SELECT *
FROM purchases AS pu
INNER JOIN products_history AS pr
  ON pu.product_id = pr.product_id
 AND pu.sale_date = pr.valid_date;
```

Ici, la ligne n'est considérée comme correspondante que si :

```text
product_id correspond
ET
sale_date correspond
```

#### Cas d'usage

- clé composite ;
- historiques de prix ;
- campagnes marketing ;
- données avec plusieurs dimensions ;
- absence de clé unique simple.

On peut ajouter autant de conditions que nécessaire :

```sql
ON a.customer_id = b.customer_id
AND a.country = b.country
AND a.event_date = b.event_date
```

---

## 🕸 10. Joindre plus de deux tables

On peut chaîner les jointures.

```sql
SELECT
  bu.name AS buyer_name,
  pr.name AS product_name,
  SUM(pu.quantity) AS total_quantity
FROM purchases AS pu
INNER JOIN buyers AS bu
  ON pu.buyer_id = bu.buyer_id
INNER JOIN products AS pr
  ON pu.product_id = pr.product_id
GROUP BY
  bu.name,
  pr.name;
```

On part de :

```text
purchases
```

puis on enrichit avec :

```text
buyers
products
```

#### Résultat

```text
buyer_name      product_name   total_quantity
--------------  -------------  --------------
Charlotte       Banana         7
Brice           Apple          3
...
```

💡 Chaque `JOIN` doit être compris individuellement. Une requête de 8 jointures est simplement une succession de relations entre tables.

---

## 🔬 11. La notion de granularité

La **granularité** correspond au niveau de détail d'une table.

Exemple :

#### Table `orders`

```text
1 ligne = 1 commande
```

#### Table `sales`

```text
1 ligne = 1 produit dans une commande
```

Une commande peut contenir plusieurs produits :

```text
order_id | product_id
---------|-----------
451      | 6532
451      | 1068
```

La granularité de `sales` est donc plus fine :

```text
order_id + product_id
```

et non simplement :

```text
order_id
```

---

## 💥 12. Le piège majeur : la duplication après JOIN

Supposons :

```text
orders
order_id | shipping_cost
---------|--------------
451      | 7
```

et :

```text
sales
order_id | product_id
---------|-----------
451      | 6532
451      | 1068
```

Si on fait :

```sql
SELECT *
FROM sales AS s
LEFT JOIN orders AS o
  ON s.order_id = o.order_id;
```

résultat :

```text
order_id | product_id | shipping_cost
---------|------------|--------------
451      | 6532       | 7
451      | 1068       | 7
```

Le `shipping_cost` apparaît deux fois.

Si on fait ensuite :

```sql
SELECT SUM(shipping_cost)
```

on obtient :

```text
14
```

alors que le vrai coût de la commande était :

```text
7
```

### Pourquoi ?

Parce qu'on a joint :

```text
1 ligne côté orders
```

avec :

```text
2 lignes côté sales
```

La ligne de `orders` est donc répétée une fois pour chaque correspondance.

---

## 🔢 13. Cardinalité d'une relation

Avant un JOIN, identifier la cardinalité.

### One-to-one — 1:1

```text
A 1 ───── 1 B
```

Une ligne de A correspond au maximum à une ligne de B.

Risque de duplication : faible.

---

### One-to-many — 1:N

```text
A 1 ───── N B
```

Exemple :

```text
1 buyer → plusieurs purchases
```

Normal dans une base relationnelle.

---

### Many-to-many — N:N

```text
A N ───── N B
```

C'est le cas le plus dangereux.

Si une clé apparaît :

```text
3 fois dans A
4 fois dans B
```

la jointure peut produire :

```text
3 × 4 = 12 lignes
```

pour cette seule clé.

💡 **Une jointure ne "fusionne" pas magiquement des lignes. Elle construit toutes les paires qui satisfont la condition `ON`.**

---

## 🧪 14. Tester une clé primaire

Une colonne candidate à une PK doit être unique.

Test :

```sql
SELECT
  id,
  COUNT(*) AS nb_id
FROM my_table
GROUP BY id
HAVING COUNT(*) > 1;
```

#### Interprétation

Si la requête retourne :

```text
0 ligne
```

alors aucune valeur n'est dupliquée.

Si elle retourne :

```text
id  | nb_id
----|------
451 | 2
650 | 3
```

alors `id` n'est pas unique.

#### Variante synthétique

```sql
SELECT
  COUNT(*) AS rows,
  COUNT(DISTINCT id) AS distinct_ids
FROM my_table;
```

Si :

```text
rows = distinct_ids
```

la colonne est unique **à condition de vérifier également les `NULL`**.

```sql
SELECT COUNT(*)
FROM my_table
WHERE id IS NULL;
```

---

## 🧪 15. Tests à faire avant et après une jointure

Une jointure doit être **testée**, pas seulement exécutée.

## 1. Nombre de lignes

Avant :

```sql
SELECT COUNT(*) AS rows_before
FROM purchases;
```

Après :

```sql
SELECT COUNT(*) AS rows_after
FROM purchases AS pu
LEFT JOIN products AS pr
  ON pu.product_id = pr.product_id;
```

Si un `LEFT JOIN` destiné uniquement à enrichir `purchases` produit beaucoup plus de lignes qu'avant, il faut investiguer.

---

## 2. Unicité de la clé côté dimension

```sql
SELECT
  product_id,
  COUNT(*) AS n
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;
```

Si `products.product_id` est censé être unique et ne l'est pas, chaque doublon peut multiplier les lignes de la jointure.

---

## 3. Clés orphelines

Trouver les achats sans produit correspondant :

```sql
SELECT
  pu.product_id,
  COUNT(*) AS n
FROM purchases AS pu
LEFT JOIN products AS pr
  ON pu.product_id = pr.product_id
WHERE pr.product_id IS NULL
GROUP BY pu.product_id;
```

---

## 4. Valeurs `NULL`

```sql
SELECT COUNT(*) AS null_product_ids
FROM purchases
WHERE product_id IS NULL;
```

---

## 5. Métriques avant / après

Exemple :

```sql
SELECT SUM(turnover)
FROM sales;
```

Comparer avec :

```sql
SELECT SUM(s.turnover)
FROM sales AS s
LEFT JOIN orders AS o
  ON s.order_id = o.order_id;
```

Si la métrique change alors que le JOIN ne devait qu'ajouter des colonnes, il y a probablement une **multiplication de lignes**.

---

## 🕳 16. Les `NULL` dans les jointures

Un `NULL` après un `LEFT JOIN` peut signifier :

1. aucune correspondance dans la table de droite ;
2. une clé source manquante ;
3. une donnée réellement inconnue ;
4. une erreur d'ingestion / de qualité.

Il ne faut donc pas automatiquement transformer :

```text
NULL → 0
```

ou :

```text
NULL → "unknown"
```

sans comprendre le sens métier.

#### Important

En SQL classique :

```sql
NULL = NULL
```

n'est pas `TRUE`.

Le résultat logique est `UNKNOWN`.

Par conséquent, deux clés `NULL` ne se correspondent pas dans une jointure d'égalité classique :

```sql
ON a.id = b.id
```

> 🧠 **Complément Brocode :** c'est une source fréquente de surprise lorsqu'on inspecte des clés de jointure contenant des `NULL`.

---

## 🧹 17. Filtrer après une jointure

Exemple :

```sql
SELECT *
FROM purchases AS pu
LEFT JOIN products AS pr
  ON pu.product_id = pr.product_id
WHERE pr.product_id IS NOT NULL;
```

Cette requête supprime les lignes sans correspondance.

Mais attention :

```text
LEFT JOIN + WHERE colonne_droite IS NOT NULL
```

se comporte alors, pour ce critère, de manière proche d'un `INNER JOIN`.

Inversement, pour chercher uniquement les non-matchs :

```sql
SELECT pu.*
FROM purchases AS pu
LEFT JOIN products AS pr
  ON pu.product_id = pr.product_id
WHERE pr.product_id IS NULL;
```

Cette technique est appelée un **anti-join logique**.

---

## 📚 18. `WHERE` vs `HAVING`

### `WHERE`

Filtre les lignes **avant l'agrégation**.

```sql
SELECT
  product_id,
  SUM(quantity) AS total_quantity
FROM purchases
WHERE sale_date >= '2026-07-01'
GROUP BY product_id;
```

---

### `HAVING`

Filtre les groupes **après l'agrégation**.

```sql
SELECT
  product_id,
  COUNT(*) AS nb_purchases
FROM purchases
GROUP BY product_id
HAVING COUNT(*) > 1;
```

C'est pourquoi `HAVING` est très pratique pour détecter les doublons.

---

### Ordre logique d'exécution SQL

> ⚠️ **Correction / précision Brocode :** l'ordre logique utile à retenir est :

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

L'ordre d'écriture reste évidemment :

```sql
SELECT ...
FROM ...
JOIN ...
WHERE ...
GROUP BY ...
HAVING ...
ORDER BY ...
LIMIT ...
```

Cette différence explique pourquoi un alias défini dans le `SELECT` n'est généralement pas disponible dans le `WHERE`.

---

## 🏗 19. JOINs dans une architecture Bronze / Silver / Gold

Le cours replace les jointures dans une pipeline analytique.

```text
Sources
   │
   ▼
BRONZE
données brutes
   │
   │ cleaning / cast / normalisation
   ▼
SILVER
données propres
   │
   │ JOINs / enrichissement / agrégations
   ▼
GOLD
données prêtes pour l'analyse / BI
```

#### Bronze

Données proches de la source :

- peu transformées ;
- potentiellement sales ;
- formats hétérogènes.

#### Silver

Données nettoyées :

- types corrects ;
- colonnes normalisées ;
- anomalies principales corrigées ou identifiées.

#### Gold

Données orientées métier :

- tables enrichies ;
- agrégations ;
- KPIs ;
- datasets utilisés en BI.

💡 Une erreur dans une jointure Silver → Gold peut rendre un KPI faux même si le SQL s'exécute parfaitement.

---

## ⚠️ 20. Erreurs en cascade

Une erreur peut apparaître :

```text
Extraction
→ Raw data
→ Cleaning
→ JOIN
→ Aggregation
→ Dashboard
```

Si elle n'est pas détectée, elle peut se propager à chaque étape.

Exemples :

- mauvaise plage de dates à l'extraction ;
- colonne absente ;
- type mal casté ;
- filtre `WHERE` trop restrictif ;
- mauvais type de `JOIN`;
- clé de jointure incorrecte ;
- relation N:N non anticipée ;
- somme dupliquée ;
- `NULL` mal interprété.

#### Principe

```text
Une query qui s'exécute ≠ une query correcte.
```

Le testing sert à vérifier le **sens métier** du résultat.

---

## ↔️ 21. JOIN vs UNION

Les deux opérations assemblent des données, mais pas dans la même direction.

### JOIN

Ajoute surtout des **colonnes**.

```text
Table A          Table B
id | qty         id | price
        JOIN
          ↓
id | qty | price
```

---

### UNION

Ajoute des **lignes**.

```text
January
id | qty
1  | 10
2  | 20

February
id | qty
3  | 30

        UNION ALL
            ↓

id | qty
1  | 10
2  | 20
3  | 30
```

```sql
SELECT id, qty
FROM january

UNION ALL

SELECT id, qty
FROM february;
```

#### `UNION` vs `UNION ALL`

> 🧠 **Complément Brocode :**

```text
UNION     → supprime les lignes dupliquées
UNION ALL → conserve toutes les lignes
```

En analytics, `UNION ALL` est souvent préférable lorsqu'on sait que les tables représentent des périodes ou lots distincts et qu'on veut éviter un dédoublonnage inutile.

---

## 🗺 22. ERD — Entity Relationship Diagram

Un ERD permet de visualiser les relations entre les tables.

```text
┌──────────────┐
│ buyers       │
│ PK buyer_id  │
└──────┬───────┘
       │ 1
       │
       │ N
┌──────▼──────────┐
│ purchases       │
│ PK purchase_id  │
│ FK buyer_id     │
│ FK product_id   │
└──────┬──────────┘
       │ N
       │
       │ 1
┌──────▼──────────┐
│ products        │
│ PK product_id   │
└─────────────────┘
```

Avant une grosse requête SQL, un ERD aide à répondre à trois questions :

1. quelle table contient l'information recherchée ?
2. quelle clé relie les tables ?
3. quelle est la cardinalité de la relation ?

---

## 🛡 23. Checklist avant un JOIN

Avant d'écrire la requête :

- [ ] Quelle est la **granularité** de la table de gauche ?
- [ ] Quelle est la granularité de la table de droite ?
- [ ] Quelle colonne est la clé de jointure ?
- [ ] Est-elle unique du côté où elle devrait l'être ?
- [ ] Y a-t-il des `NULL` dans cette clé ?
- [ ] Relation `1:1`, `1:N` ou `N:N` ?
- [ ] Veut-on conserver les non-correspondances ?
- [ ] `INNER`, `LEFT`, `FULL`, ou autre ?
- [ ] Quel nombre de lignes attend-on après le JOIN ?
- [ ] Quelles métriques doivent rester invariantes ?

---

## ✅ 24. Checklist après un JOIN

Après exécution :

- [ ] Comparer `COUNT(*)` avant / après.
- [ ] Comparer `COUNT(DISTINCT key)`.
- [ ] Vérifier les clés orphelines.
- [ ] Inspecter les nouveaux `NULL`.
- [ ] Tester les doublons.
- [ ] Comparer les `SUM`, `AVG`, `COUNT` critiques.
- [ ] Contrôler quelques IDs manuellement.
- [ ] Vérifier que le niveau de granularité final est celui attendu.

---

## 🧰 25. Pattern de requête robuste

```sql
WITH purchases_clean AS (
  SELECT
    purchase_id,
    buyer_id,
    product_id,
    quantity,
    sale_date
  FROM purchases
),

products_unique AS (
  SELECT
    product_id,
    name,
    price
  FROM products
)

SELECT
  pu.purchase_id,
  pu.buyer_id,
  pu.product_id,
  pr.name AS product_name,
  pr.price,
  pu.quantity,
  pu.sale_date
FROM purchases_clean AS pu
LEFT JOIN products_unique AS pr
  ON pu.product_id = pr.product_id;
```

Cette écriture rend visibles :

- les colonnes utilisées ;
- les tables préparées ;
- la granularité attendue ;
- la condition de jointure.

Elle est beaucoup plus maintenable qu'un :

```sql
SELECT *
FROM ...
```

sur plusieurs grosses tables.

---

## 🚫 26. Erreurs fréquentes

#### 1. Choisir le JOIN sans réfléchir à l'objectif

```sql
INNER JOIN
```

peut supprimer des lignes importantes.

---

#### 2. Joindre sur une colonne non unique sans le savoir

Peut créer une multiplication de lignes.

---

#### 3. Utiliser `SELECT *`

Problèmes possibles :

- coût inutile ;
- colonnes ambiguës ;
- output illisible ;
- dépendance à des changements de schéma.

---

#### 4. Ne pas qualifier les colonnes

Mauvais :

```sql
SELECT id, name
```

Mieux :

```sql
SELECT
  pu.id AS purchase_id,
  pr.name AS product_name
```

---

#### 5. Croire qu'une FK doit avoir le même nom que la PK

Faux.

```text
purchases.product_id
```

peut très bien référencer :

```text
products.id
```

---

#### 6. Somme après un JOIN sans contrôler la granularité

```sql
SUM(shipping_cost)
```

peut devenir faux si `shipping_cost` a été répété sur plusieurs lignes.

---

#### 7. Traiter tous les `NULL` comme des erreurs

Un `NULL` peut être une information métier importante.

---

## 🎯 27. Exemple complet

Objectif :

> Calculer la quantité totale achetée par client et par produit.

```sql
SELECT
  bu.name AS buyer_name,
  pr.name AS product_name,
  SUM(pu.quantity) AS total_quantity
FROM purchases AS pu

INNER JOIN buyers AS bu
  ON pu.buyer_id = bu.buyer_id

INNER JOIN products AS pr
  ON pu.product_id = pr.product_id

GROUP BY
  bu.name,
  pr.name

ORDER BY
  total_quantity DESC;
```

#### Lecture humaine

```text
1. Partir des achats.
2. Trouver le buyer correspondant à chaque achat.
3. Trouver le produit correspondant.
4. Regrouper les lignes par buyer + produit.
5. Additionner les quantités.
6. Trier du plus gros volume au plus petit.
```

---

## 🧠 28. Ce qu'il faut vraiment retenir

```text
JOIN = relation entre lignes
```

Pas simplement :

```text
JOIN = ajouter des colonnes
```

Le résultat dépend de trois choses :

```text
1. la condition de jointure
2. la cardinalité
3. la granularité
```

#### Les 5 réflexes

1. **Identifier la clé de jointure.**
2. **Connaître la granularité des deux tables.**
3. **Choisir volontairement le type de JOIN.**
4. **Anticiper les non-matchs et les NULL.**
5. **Tester le nombre de lignes et les métriques après la jointure.**

---

## 🧾 29. Mini cheat sheet finale

```sql
-- INNER : seulement les correspondances
SELECT ...
FROM A
INNER JOIN B
  ON A.id = B.id;
```

```sql
-- LEFT : toutes les lignes de A
SELECT ...
FROM A
LEFT JOIN B
  ON A.id = B.id;
```

```sql
-- RIGHT : toutes les lignes de B
SELECT ...
FROM A
RIGHT JOIN B
  ON A.id = B.id;
```

```sql
-- FULL : toutes les lignes de A et B
SELECT ...
FROM A
FULL OUTER JOIN B
  ON A.id = B.id;
```

```sql
-- USING : même nom de clé
SELECT ...
FROM A
LEFT JOIN B
USING (id);
```

```sql
-- Plusieurs conditions
SELECT ...
FROM A
LEFT JOIN B
  ON A.id = B.id
 AND A.date = B.date;
```

```sql
-- Trouver les doublons
SELECT
  id,
  COUNT(*) AS n
FROM A
GROUP BY id
HAVING COUNT(*) > 1;
```

```sql
-- Trouver les lignes de A sans correspondance dans B
SELECT A.*
FROM A
LEFT JOIN B
  ON A.id = B.id
WHERE B.id IS NULL;
```

```sql
-- Empiler des tables
SELECT * FROM january
UNION ALL
SELECT * FROM february;
```

---

### 💡 Ce que j'ai retenu

- Une jointure relie des lignes selon une ou plusieurs **clés de jointure**.
- `INNER JOIN` garde uniquement les correspondances.
- `LEFT JOIN` conserve l'univers de la table de gauche.
- `RIGHT JOIN` est généralement remplaçable par un `LEFT JOIN` inversé.
- `FULL OUTER JOIN` est utile pour la comparaison et la réconciliation.
- `CROSS JOIN` génère toutes les combinaisons possibles.
- Le principal danger n'est pas la syntaxe mais la **granularité** et la **duplication des métriques**.
- Une jointure doit être accompagnée de **tests de qualité**.
- Une requête qui s'exécute sans erreur peut malgré tout produire un résultat métier faux.

---

### ❓ Questions / points à garder en tête

- [ ] Quelle est la bonne stratégie lorsqu'une table contient plusieurs lignes pour une clé censée être unique ?
- [ ] Comment dédupliquer proprement avant une jointure ?
- [ ] Quand utiliser `ROW_NUMBER()` + `PARTITION BY` ?
- [ ] Comment tester automatiquement la qualité des JOINs dans dbt ?

---

### 🔗 Liens avec les autres notions du Brocode

```text
Primary / Foreign Keys
        ↓
JOINs
        ↓
Granularité
        ↓
GROUP BY / Aggregations
        ↓
Testing
        ↓
dbt tests / Data Quality
        ↓
Data Warehouse Bronze / Silver / Gold
        ↓
BI / Power BI / Looker Studio
```

Le chapitre suivant sur les **window functions / `PARTITION BY`** permettra notamment de traiter certains cas de déduplication et de contrôle de granularité.
