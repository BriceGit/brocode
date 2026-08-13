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

# 📝 8 — CTE (WITH...AS), sous-requêtes imbriquées & UNION

**Date** : 15 juillet 2026
**Thème** : Rappel jointures/granularité, GROUP BY et agrégation, Common Table Expressions (CTE), sous-requêtes imbriquées (subqueries), `UNION`/`UNION ALL`/`UNION DISTINCT`
**Compréhension (1→5)** : ⭐

---

## 🎯 Contexte de la session

- Suite directe du [#7 — Jointures SQL](07-sql-joins-testing.md), qui renvoyait explicitement le dédoublonnage/partitionnement et `UNION` à cette session.
- Le fil rouge de la journée est **exactement le problème de duplication par jointure** identifié au #7 (commande `451`, coût logistique compté en double) — cette fois avec la solution : la CTE.
- Structure : rappel jointures/SELECT * → granularité et GROUP BY → CTE (syntaxe + 2 cas d'usage) → sous-requêtes imbriquées → `UNION`/`UNION DISTINCT` → exemple filé complet de bout en bout.

---

## 🔁 Rappel : jointures et bonnes pratiques SELECT

- **Le problème du `SELECT *`** : après une jointure, il ramène toutes les colonnes des deux tables selon le type de jointure choisi — au-delà de quelques colonnes, on ne sait plus ce qu'on récupère réellement.
- **Bonne pratique** : toujours lister explicitement les colonnes voulues dans le `SELECT`.
- **Astuce d'écriture** : commencer par écrire le `FROM` (et les `JOIN`) avant le `SELECT` — l'autocomplétion de l'éditeur propose alors les bonnes colonnes au moment de rédiger le `SELECT`, plutôt que de deviner les noms à l'avance.
- Rappel express des types de jointures (détaillés au [#7](07-sql-joins-testing.md)) : `INNER JOIN` (valeurs communes uniquement), `LEFT JOIN` (tout à gauche + correspondances à droite, `NULL` sinon), `FULL OUTER JOIN` (tout des deux côtés).

---

## 📏 Granularité : reprise et lien direct avec les CTE

- La **granularité** (ou maille) d'une table, c'est son niveau de détail — combien de lignes représentent une même entité.
- Exemple : une table d'achats avec une ligne par date d'achat a une granularité "à la date", pas "à la personne" — une personne qui achète 3 fois apparaît sur 3 lignes.
- Un `GROUP BY` sert justement à **réduire la granularité** : passer de plusieurs lignes par entité à une seule.
- Le problème central, déjà identifié au #7 : **joindre deux tables de granularités différentes duplique les données** de la table la plus grossière, et fausse tous les calculs faits après. C'est précisément ce que les CTE permettent de corriger *avant* la jointure plutôt qu'après coup.

---

## 🧮 GROUP BY et agrégation : une règle et une convention

- Dès qu'une fonction d'agrégation (`SUM`, `AVG`, `COUNT`...) est utilisée dans le `SELECT`, **toutes les colonnes non agrégées doivent apparaître dans le `GROUP BY`** — sinon SQL ne sait pas à quel niveau les regrouper.
- **Convention recommandée** : renommer explicitement une colonne agrégée plutôt que de garder son nom d'origine.

```sql
SELECT
    order_id,
    SUM(turnover) AS total_turnover   -- et non juste "AS turnover"
FROM sales
GROUP BY order_id
```

Sans ce renommage, retrouver une colonne `turnover` six mois plus tard ne dit pas si c'est la valeur brute ou une somme déjà agrégée — source d'erreur classique en relecture ou en debug.

---

## 🧱 CTE — Common Table Expressions (`WITH ... AS`)

### Définition et syntaxe

Une CTE est une **table temporaire**, qui n'existe que le temps de l'exécution de la requête — rien n'est écrit en dur dans la base de données, contrairement à une vraie table ou une vue.

```sql
WITH reference_for_cte AS (
    SELECT ...
    FROM source_table
)

SELECT ...
FROM reference_for_cte
```

- Pour visualiser uniquement le contenu de la CTE (sans le `SELECT` final), il faut **sélectionner manuellement** la portion de code correspondante dans l'éditeur et l'exécuter séparément — la CTE seule n'est pas un objet qu'on peut appeler indépendamment autrement.
- On peut **enchaîner plusieurs CTE à la suite**, séparées par une virgule, sans répéter le mot-clé `WITH` :

```sql
WITH cte_1 AS (
    SELECT ...
),
cte_2 AS (
    SELECT ... FROM cte_1
)

SELECT ... FROM cte_2
```

### Cas d'usage n°1 — insérer un GROUP BY avant une jointure

Le cas le plus fréquent : réduire la granularité d'une table (via `GROUP BY`) *avant* de la joindre à une autre, pour ne pas dupliquer les valeurs de la table jointe.

```sql
WITH orders_cte AS (
    SELECT
        orders_id,
        SUM(turnover) AS turnover
    FROM sales
    GROUP BY orders_id
)

SELECT
    orders_id,
    turnover,
    shipping_fee
FROM orders_cte
INNER JOIN orders_ship USING (orders_id)
```

### Cas d'usage n°2 — réutiliser une colonne calculée dans le SELECT

Une colonne créée dans le `SELECT` (ex. `margin`) n'est **pas connue** au moment du `GROUP BY` ou d'un calcul suivant, à cause de l'ordre d'exécution SQL :

```
FROM/JOIN → WHERE → GROUP BY → HAVING → SELECT
```

Le `SELECT` est lu en dernier — impossible d'y référencer `margin` dans un second calcul de la même requête, ce même `SELECT` n'existant pas encore au moment où SQL en aurait besoin.

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
    SAFE_DIVIDE(margin, turnover) AS margin_percent
FROM margin_cte
```

La CTE calcule `margin` dans une première étape ; le `SELECT` final peut alors la réutiliser librement, comme s'il s'agissait d'une colonne native de la table.

### Pourquoi préférer une CTE à une table intermédiaire enregistrée

- **Lisibilité** — le raisonnement complet (étape par étape) reste dans une seule requête, lisible de haut en bas.
- **Flexibilité** — pas besoin de créer/gérer une table physique juste pour une étape intermédiaire.
- **Performance et coût** — sur BigQuery, éviter l'écriture d'une table intermédiaire évite aussi une requête (et donc un coût) supplémentaire.

### Mémo-technique

> **GROUP BY suivi d'un JOIN → penser CTE.**
> **Un calcul à réutiliser plus loin dans la même requête → penser CTE.**

---

## 🪆 Sous-requêtes (Subqueries / Nested Subqueries)

Une sous-requête est une requête `SELECT` imbriquée à l'intérieur d'une autre — dans le `SELECT`, le `FROM` ou le `WHERE`.

```sql
SELECT
    orders_id,
    turnover,
    margin
FROM sales
WHERE orders_id IN (
    SELECT orders_id
    FROM orders
    WHERE code = "HAPPYHOUR"
)
```

### Pourquoi préférer une jointure à une sous-requête imbriquée

| | Sous-requête imbriquée | Jointure |
|---|---|---|
| Lisibilité | Plus complexe à relire/maintenir | Plus claire, structure à plat |
| Colonnes accessibles | Limitées à ce que la sous-requête ramène explicitement | Toutes les colonnes des deux tables disponibles directement |
| Performance | Moins bonne — la sous-requête dans un `WHERE` est évaluée après le `FROM`/`JOIN` dans l'ordre d'exécution, ce qui la pénalise structurellement | Meilleure, l'un des cas où l'ordre d'exécution SQL joue directement en faveur du `JOIN` |

```sql
-- Sous-requête imbriquée
SELECT
    orders_id,
    turnover,
    margin
FROM sales
WHERE orders_id IN (
    SELECT orders_id
    FROM orders
    WHERE code = "HAPPYHOUR"
)

-- Équivalent en jointure — plus lisible et plus rapide
SELECT
    sales.orders_id,
    orders.code,
    sales.turnover,
    sales.margin
FROM sales
INNER JOIN orders USING (orders_id)
WHERE orders.code = "HAPPYHOUR"
```

Une sous-requête peut aussi être imbriquée **directement dans le `SELECT`**, colonne par colonne :

```sql
SELECT
    orders_id,
    (SELECT code FROM orders WHERE orders.orders_id = sales.orders_id) AS code,
    (SELECT transporter FROM orders WHERE orders.orders_id = sales.orders_id) AS transporter,
    turnover,
    margin
FROM sales
```

Ici, deux sous-requêtes distinctes sont nécessaires pour rapatrier `code` et `transporter` — une jointure unique donnerait accès aux deux colonnes (et à toutes les autres de la table `orders`) en une seule opération. C'est l'argument le plus concret en faveur du `JOIN` : moins de sous-requêtes à écrire, et un accès complet à la table de droite plutôt qu'une sélection colonne par colonne.

**À retenir même si on ne les écrit jamais soi-même** : les sous-requêtes sont fréquentes dans du code existant écrit par d'autres — savoir les reconnaître et les relire est aussi important que savoir les éviter.

---

## ➕ UNION, UNION ALL, UNION DISTINCT

Contrairement à un `JOIN` qui ajoute des colonnes à l'horizontale, `UNION` empile des lignes à la **verticale** — utile pour consolider plusieurs tables de même structure (ex. un inventaire mensuel réparti sur plusieurs tables, à recoller en une table annuelle).

### Contraintes strictes

- Les deux requêtes doivent avoir **le même nombre de colonnes**, dans le **même ordre**, avec **les mêmes noms** et **les mêmes types**.
- Impossible de rapatrier une colonne absente de l'une des deux tables via un `UNION` — contrairement à un `JOIN`, il n'y a pas de `NULL` de comblement pour une colonne manquante entière, la requête échoue simplement si les structures ne correspondent pas.
- Si une valeur précise manque sur une ligne (mais que la colonne existe bien des deux côtés), elle apparaît en `NULL` — la ligne, elle, est conservée.

### UNION ALL — empile tout, doublons compris

```sql
SELECT date_purchase, orders_id, turnover FROM orders_1
UNION ALL
SELECT date_purchase, orders_id, turnover FROM orders_2
```

### UNION DISTINCT — empile en supprimant les doublons

```sql
SELECT date_purchase, orders_id, turnover FROM orders_1
UNION DISTINCT
SELECT date_purchase, orders_id, turnover FROM orders_2
```

> ⚠️ Sur BigQuery, le mot-clé `UNION` seul (sans `ALL` ni `DISTINCT`) n'est **pas une syntaxe valide** — il faut toujours préciser explicitement l'un des deux. C'est une différence avec d'autres moteurs SQL (PostgreSQL, MySQL) où `UNION` seul se comporte par défaut comme `UNION DISTINCT`. Un bon réflexe pour éviter l'hésitation en entretien ou en le retrouvant dans du code non-BigQuery.

---

## 🧪 Exemple filé complet : du problème de duplication à sa correction

C'est la reprise directe de l'exemple du [#7](07-sql-joins-testing.md) (commande `451`, coût logistique dupliqué par la jointure) — cette fois avec la solution.

**Le problème (rappel du #7)** : `sales` a une ligne par produit acheté (granularité fine), `operational` a une ligne par commande (granularité grossière, avec `log_cost` et `shipping_cost`). La commande `451` contient 2 produits (pommes et bananes) ; la commande `623` en contient 3 (pommes, bananes, pois).

```sql
-- Jointure naïve, sans réduire la granularité au préalable
SELECT
    s.orders_id,
    SUM(o.log_cost) AS total_log_cost
FROM sales AS s
LEFT JOIN operational AS o USING (orders_id)
GROUP BY s.orders_id
```

Résultat faux : `total_log_cost = 9` pour la commande `451`, alors que le vrai coût logistique de cette commande est `4.5` — dupliqué une fois par produit de la commande (2 produits → ×2).

**La correction, avec CTE** : agréger `sales` à la granularité `orders_id` (une ligne par commande) *avant* de joindre `operational`.

```sql
WITH orders_cte AS (
    SELECT
        orders_id,
        ROUND(SUM(turnover), 2) AS total_turnover
    FROM sales
    GROUP BY orders_id
),

margin_calculation AS (
    SELECT
        c.orders_id,
        c.total_turnover,
        o.log_cost,
        o.shipping_cost,
        c.total_turnover - o.log_cost - o.shipping_cost AS margin
    FROM orders_cte AS c
    LEFT JOIN operational AS o USING (orders_id)
)

SELECT
    orders_id,
    total_turnover,
    margin,
    ROUND(SAFE_DIVIDE(margin, total_turnover) * 100, 1) AS margin_percent
FROM margin_calculation
```

Résultat correct sur cet exemple : commande `451` → marge d'environ `70%` ; commande `623` → marge d'environ `84.8%` — chaque coût opérationnel n'est plus compté qu'une seule fois par commande, indépendamment du nombre de produits qu'elle contient.

**Point de méthode confirmé en classe** : appliquer `ROUND` sur le résultat global (le calcul complet), pas sur une valeur intermédiaire — cohérent avec le principe déjà noté ailleurs dans le brocode (**agréger avant d'arrondir/diviser**). `ROUND` prend toujours deux arguments : le calcul, puis le nombre de décimales souhaité.

---

## 🎯 Points clés pour les entretiens

- Savoir dire en une phrase **quand utiliser une CTE plutôt qu'une sous-requête ou une table intermédiaire enregistrée** — le mémo-technique ("GROUP BY + JOIN → CTE" / "calcul à réutiliser → CTE") est un bon point d'ancrage.
- Expliquer **pourquoi une jointure est plus performante qu'une sous-requête dans un `WHERE`** — la réponse tient à l'ordre d'exécution SQL (`WHERE` après `FROM`/`JOIN`), pas à une préférence de style.
- Reconnaître une sous-requête imbriquée dans du code qu'on n'a pas écrit soi-même, et être capable de la réécrire en jointure équivalente — plus utile en entretien que de savoir en écrire une de zéro.
- Différence exacte entre `UNION ALL` et `UNION DISTINCT`, et le piège BigQuery (`UNION` seul invalide, contrairement à d'autres moteurs).
- Pouvoir dérouler l'exemple concret commande `451` (duplication de coût logistique → correction par CTE) — un cas d'usage réel raconte mieux la notion de granularité qu'une définition abstraite.

---

## 🔗 Liens avec d'autres notions

- Le problème de duplication corrigé ici est **exactement** celui identifié au [#7 — Jointures SQL](07-sql-joins-testing.md) (commande `451`, coût logistique compté en double) — ce chapitre en est la suite directe et la résolution.
- Le principe **agréger avant d'arrondir/diviser**, déjà noté côté dbt, Looker Studio et Power BI dans le brocode, est repris ici avec `ROUND` appliqué sur le résultat final plutôt que sur une valeur intermédiaire.
- `SAFE_DIVIDE`, déjà standard pour toute division avec dénominateur potentiellement nul, réapparaît ici pour le calcul de `margin_percent`.
- Une CTE de dédoublonnage/agrégation avant jointure est l'équivalent SQL manuel de ce qu'une couche **staging/intermediate** fait systématiquement dans un projet dbt ([#9](09-dbt-intro.md)) — la logique de réduction de granularité avant modélisation finale est la même.

---

## ✅ Actions post-session

- [ ] Refaire l'exemple filé (commande 451/623) de zéro sans regarder la correction
- [ ] Repérer une sous-requête imbriquée dans un ancien exercice et la réécrire en jointure
- [ ] Tester `UNION ALL` vs `UNION DISTINCT` sur un même jeu de données pour visualiser concrètement la différence

---

## ❓ Questions / Points flous

- [ ]
- [ ]

---

*Suite directe du [#7 — Jointures SQL](07-sql-joins-testing.md), qui annonçait ce chapitre pour la correction des duplicatas de jointure et `UNION`.*
