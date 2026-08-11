# 📝 #7 — Jointures SQL : INNER/LEFT/RIGHT/FULL OUTER, granularité & test de clé primaire

**Date** : 14 juillet 2026
**Thème** : Clés primaires/étrangères, syntaxe `JOIN` (`ON` vs `USING`), les 5 types de jointures, jointures sur plusieurs colonnes/plusieurs tables, granularité et duplicatas, test de clé primaire et autres contrôles qualité, aperçu `UNION`
**Compréhension (1→5)** : ⭐

---

## 🎯 Contexte de la session

- Suite directe du [#6 — SQL : agrégations, dates & chaînes](06-sql-aggregation-date-string-functions.md), qui annonçait ce chapitre dédié aux jointures.
- Journée dense en allers-retours oraux et en exercices collectifs sur le vif (beaucoup de "à votre avis, qu'est-ce qui se passe ?") — ce qui explique la note de compréhension basse sur le moment. Le contenu, une fois remis à plat, est en réalité assez linéaire.
- Structure de la journée : (1) clés primaires/étrangères → syntaxe de base → types de jointures, (2) pause, (3) test de clé primaire et contrôles qualité, (4) le piège classique de la duplication par jointure, illustré par un cas concret de coûts logistiques.
- Éléments explicitement renvoyés au lendemain : dédoublonnage/partitionnement pour corriger les duplicatas de jointure, et `UNION` en détail.

---

## 🔑 Clés primaires et clés étrangères

- **Clé primaire (Primary Key, PK)** : identifie de façon unique chaque ligne d'une table — elle ne se répète jamais.
- **Clé étrangère (Foreign Key, FK)** : la même valeur, présente dans une autre table, où elle *peut* se dupliquer.
- Exemple filé toute la session — trois tables :

| Table | Rôle | Clé primaire | Clé(s) étrangère(s) |
|---|---|---|---|
| `Product` | Référentiel produit | `ProductID` | — |
| `Customer` | Référentiel client | `CustomerID` | — |
| `Purchase` | **Table intermédiaire** (une commande) | `PurchaseID`/`OrderID` | `ProductID`, `CustomerID` |

- `Purchase` récupère de l'information des deux tables référentielles et ajoute ses propres colonnes complémentaires (date d'achat, quantité). C'est le schéma classique **table de faits ↔ tables de dimension**, qu'on retrouvera tel quel au moment du star schema en Power BI.
- Une PK peut exister sans que son nom soit identique d'une table à l'autre : dans l'exemple travaillé en direct, `Product` a une clé primaire nommée simplement `id`, alors que `Purchase` la référence sous `product_id`. C'est fréquent en pratique — ne pas partir du principe que noms de PK et de FK matchent forcément.

---

## 🧬 Syntaxe de base d'une jointure

```sql
SELECT ...
FROM purchases
(JOIN TYPE) JOIN products
    ON purchases.product_id = products.product_id
```

- Ordre d'écriture : `SELECT` (colonnes) → `FROM` (table de gauche) → `JOIN` (table de droite) → `ON`/`USING` (clé de jointure).
- **Bonne pratique** : jamais de `SELECT *` sur une grosse table — BigQuery facture au volume scanné, et c'est illisible dès que le nombre de colonnes augmente.
- Toujours préfixer les colonnes par l'alias de leur table (`pr.id`, `pu.quantity`) pour lever toute ambiguïté, dès qu'au moins deux tables sont en jeu.

### `ON` vs `USING`

| | `ON` | `USING` |
|---|---|---|
| Quand l'utiliser | Noms de colonnes différents entre les deux tables (cas général) | Noms de colonnes **strictement identiques** des deux côtés |
| Portabilité | Standard SQL, disponible partout | Standard SQL également, mais **absent de T-SQL/SQL Server** — à ne pas présumer disponible sur tous les moteurs, même si ce n'est pas propre à BigQuery |
| Colonne de jointure dans le résultat | Apparaît deux fois (dupliquée, une par table) | Apparaît une seule fois |

> 🔍 Précision utile : contrairement à ce qui a été dit en classe, `USING` n'est pas une exclusivité BigQuery — c'est du SQL standard, supporté aussi par PostgreSQL, MySQL ou SQLite. Ce qui est vrai, c'est qu'il n'est *pas* disponible partout (SQL Server notamment), donc `ON` reste le réflexe le plus universel si on ne connaît pas le moteur cible.

---

## 🏷️ Aliasage des tables (`AS`)

```sql
SELECT *
FROM purchases AS purchase
INNER JOIN products AS product
    ON purchase.product_id = product.product_id
```

- Sans alias, une colonne présente dans plusieurs tables jointes provoque une erreur **d'ambiguïté** dès qu'on la nomme sans préfixe (`Ambiguous column name`).
- Convention recommandée : un alias court mais lisible, proche du nom réel de la table (`pu` pour `purchase`, `pr` pour `product`) plutôt qu'une lettre arbitraire — ça reste lisible à 300 lignes, pas juste sur un exemple à 4 lignes.
- Intérêt supplémentaire sur BigQuery : les noms de table complets s'écrivent `projet.dataset.table` — sans alias, chaque référence à une colonne oblige à réécrire ce chemin complet à chaque fois. L'alias absorbe cette lourdeur une fois pour toutes en haut de la requête.

---

## 🔀 Les types de jointures

Exemple filé avec des valeurs concrètes : `Purchase.product_id` (table de gauche) contient `1, 3, 4, 32` (avec répétitions côté FK) ; `Product.id` (table de droite) contient `1, 2, 3, 4, 5`.

| Jointure | `product_id` retournés | NULL générés |
|---|---|---|
| `INNER JOIN` | `1, 3, 4` | Aucun |
| `LEFT JOIN` | `1, 3, 4, 32` | Colonnes de `Product` NULL pour `32` |
| `RIGHT JOIN` | `1, 3, 4, 2, 5` | Colonnes de `Purchase` NULL pour `2` et `5` |
| `FULL OUTER JOIN` | `1, 2, 3, 4, 5, 32` | NULL des deux côtés selon les cas |
| `CROSS JOIN` | produit cartésien : chaque ligne de gauche × chaque ligne de droite | Aucun (mais explosion du nombre de lignes) |

### INNER JOIN — intersection stricte

```sql
SELECT *
FROM purchases
INNER JOIN products
    ON purchases.product_id = products.product_id
```
Ne garde que les valeurs présentes **dans les deux tables**. `32` (absent de `Product`) et `2`/`5` (absents de `Purchase`) disparaissent complètement du résultat — pas de NULL, la ligne n'existe simplement pas.

### LEFT JOIN — toutes les lignes de gauche

```sql
SELECT *
FROM purchases
LEFT JOIN products
    ON purchases.product_id = products.product_id
```
Garde tout `purchases`, complète avec `products` quand une correspondance existe, sinon NULL. La table de gauche est toujours celle du `FROM` — pas celle physiquement écrite « à gauche » du mot `JOIN ».

### RIGHT JOIN — l'inverse du LEFT

```sql
SELECT * FROM purchases  RIGHT JOIN products ON purchases.product_id = products.product_id
-- strictement équivalent à :
SELECT * FROM products   LEFT  JOIN purchases ON purchases.product_id = products.product_id
```
En pratique, quasiment jamais utilisé : un `RIGHT JOIN` n'est qu'un `LEFT JOIN` avec les tables inversées. Autant garder `LEFT JOIN` comme unique réflexe et inverser `FROM`/`JOIN` si besoin — ça évite d'avoir deux syntaxes à maintenir mentalement pour le même résultat.

### FULL OUTER JOIN — tout, des deux côtés

```sql
SELECT *
FROM purchases
FULL OUTER JOIN products
    ON purchases.product_id = products.product_id
```
Rapatrie l'ensemble des lignes des deux tables, matchées ou non — grosse table avec beaucoup de NULL potentiels. Utile pour un audit complet ("où ai-je de l'information, où n'en ai-je pas ?"), rarement pour un usage final. Peut être filtré avec `WHERE ... IS NOT NULL` pour nettoyer après coup.

### CROSS JOIN — produit cartésien

Rarement utilisé en tant que tel, mais un cas d'usage réel et fréquent : construire une **grille complète** sans trous, par exemple toutes les combinaisons `date × magasin` ou `date × produit` sur une période, pour être sûr d'avoir une ligne (même à 0) partout où on en attend une — utile en amont d'un dashboard de suivi (et c'est justement ce type de grille "sans trou" qui sert de base à une table de calendrier complète, voir [#23](23-power-bi-2.md)).

---

## 🔗 Jointures sur plusieurs colonnes

```sql
SELECT *
FROM purchases
INNER JOIN products
    ON purchases.product_id = products.product_id
    AND purchases.sale_date = products.purchase_date
```
Utile quand une seule colonne ne suffit pas à garantir une correspondance stricte — typiquement en l'absence de clé primaire unique côté droit (ex. : rattacher une ligne à une campagne marketing précise à une date précise, pas à toute la campagne).

## 🧩 Jointures sur plusieurs tables

```sql
SELECT
    buyers.name   AS buyer_name,
    products.name AS product_name,
    SUM(purchases.quantity) AS total_quantity
FROM purchases
INNER JOIN buyers
    ON purchases.buyer_id = buyers.buyer_id
INNER JOIN products
    ON purchases.product_id = products.product_id
GROUP BY buyers.name, products.name
```
On enchaîne les `JOIN` plutôt que de sauvegarder un résultat intermédiaire et le rejoindre à nouveau — plus lisible, plus performant.

### La notion de granularité, introduite ici

Le `GROUP BY buyers.name, products.name` illustre bien la **granularité** (le niveau de détail de la table) : si Charlotte Dupuis a acheté 3 fois des bananes et 4 fois des tomates, le regroupement par *acheteur + produit* donne deux lignes distinctes (3 et 4). Retirer `products.name` du `GROUP BY` regrouperait tout au niveau acheteur seul et donnerait un total agrégé de 7 — un chiffre correct pour "combien Charlotte a-t-elle acheté au total", mais qui masque le détail par produit. Ici, le produit est le niveau de détail le plus fin, pas le nom de l'acheteur (un acheteur n'a qu'une seule ligne d'identité, un produit peut revenir plusieurs fois).

---

## ⚠️ Granularité et duplicatas : le piège classique des jointures

C'est le point le plus important, techniquement, de cette session — et celui qui revient le plus souvent en pratique.

**Le principe** : quand la table de gauche a une granularité plus fine que la table de droite, la jointure **duplique** les valeurs de la table de droite, une fois par ligne correspondante à gauche.

**Cas travaillé en classe** — deux tables autour d'une commande :

```sql
-- Table "sales" — grain : une ligne par produit commandé (le plus fin)
-- order_id | product_id | turnover
-- 451      | 6532       | ...
-- 451      | 1068       | ...

-- Table "operational_orders" — grain : une ligne par commande
-- order_id | shipping_cost
-- 451      | 7

SELECT s.order_id, s.product_id, o.shipping_cost
FROM sales AS s
LEFT JOIN operational_orders AS o
    USING (order_id)
```

La commande `451` contient deux produits → `shipping_cost = 7` apparaît sur **les deux lignes**. Un `SUM(shipping_cost)` naïf après cette jointure renvoie `14` au lieu des `7` réels — le coût logistique est compté une fois par produit de la commande, alors qu'il est unique par commande.

- Retirer `product_id` du `SELECT` **ne règle rien** : les lignes restent dupliquées en amont, seule leur présentation change.
- La vraie correction (dédoublonner avant de joindre, ou agréger `sales` au niveau `order_id` avant la jointure) est explicitement renvoyée à la session suivante — pas de solution donnée ce jour-là.
- Attention symétrique côté `INNER JOIN` : au-delà de la duplication, un `INNER JOIN` peut aussi faire perdre de l'information (lignes sans correspondance exclues silencieusement) — les deux risques (duplication et perte) sont à évaluer à chaque jointure, pas seulement l'un ou l'autre.

> 💡 C'est exactement le type d'erreur que le principe **agréger avant de diviser/sommer** (déjà noté côté dbt, Looker Studio et Power BI dans le brocode) vise à prévenir, et exactement ce qu'un **test de conservation** (SUM avant la jointure = SUM après) permet de détecter avant de livrer un chiffre faux.

### 🧪 Petit exercice vécu en classe

Deux tables : `T1` (id 1 à 6, avec `product` et `quantity`) et `T2` (prix, disponible seulement pour les id `2`, `3`, `4`).

| Jointure | Résultat |
|---|---|
| `INNER JOIN T1, T2` | Uniquement les id `2, 3, 4` — les id `1`, `5` et `6` **disparaissent entièrement**, pas seulement leur prix |
| `LEFT JOIN T1 → T2` | Tous les id `1` à `6` conservés, `price` = NULL pour `1`, `5`, `6` |
| `FULL OUTER JOIN` | Identique au LEFT ici, car `T2` ne contient aucun id absent de `T1` — rien à rapatrier en plus côté droit |

Le point à retenir : le choix du type de jointure ne change pas seulement la présence de NULL, il peut faire disparaître des lignes entières si l'information cherchée (ici `price`) leur manque et qu'on choisit un `INNER JOIN`.

---

## ✅ Tester la qualité d'une table après une jointure ("le testing" du titre de session)

### Test de clé primaire

```sql
SELECT id, COUNT(*) AS nb_id
FROM table
GROUP BY id
HAVING nb_id > 1
```
- Aucune ligne retournée → `id` est bien une clé primaire (toutes les valeurs sont uniques).
- Une/des ligne(s) retournée(s) → `id` **n'est pas** une clé primaire.
- Exemple concret : test sur `sales.order_id` → `order_id` **n'est pas** une clé primaire (`451` apparaît 2 fois, `650` apparaît 3 fois — cohérent avec le grain "une ligne par produit" vu plus haut).
- Bonne pratique : `COUNT(*)` plutôt que `COUNT(colonne)`, pour compter toutes les lignes sans exception liée à d'éventuels NULL dans une colonne spécifique.
- Recommandation explicite du cours : **sauvegarder cette requête telle quelle** et se contenter de changer le nom de table/colonne à chaque nouveau test — c'est littéralement le brouillon manuel des tests génériques `unique` et `not_null` qu'on retrouvera automatisés dans dbt (#9, dbt intro, et #14, dbt advanced).

### Autres contrôles de qualité

| Contrôle | Requête type | Objectif |
|---|---|---|
| Nulls sur une colonne | `WHERE colonne IS NULL` / `IS NOT NULL` | Repérer les trous d'information |
| Cohérence d'une métrique après jointure | `SUM(métrique)` avant/après jointure, à comparer | Détecter une duplication silencieuse (cf. section précédente) |

- Rappel important : un NULL après jointure ne signifie pas forcément une erreur — ça peut être une vraie absence de correspondance (légitime), ou une mauvaise entrée de données à la source. **Ne jamais remplacer un NULL par une valeur arbitraire** : impossible de deviner la vraie valeur, et c'est particulièrement risqué sur des tables de plusieurs millions de lignes.

### ⚠️ Correction : l'ordre d'exécution des clauses SQL

Les notes de session indiquent l'ordre `FROM → JOIN → GROUP BY → WHERE → HAVING → SELECT`, ce qui est **incorrect** (et d'ailleurs contredit par le reste de la même session : "le `WHERE` filtre avant l'agrégation, le `HAVING` filtre après"). L'ordre réel, déjà posé au [#6](06-sql-aggregation-date-string-functions.md), est :

```
FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
```

C'est cet ordre qui explique, entre autres, pourquoi un alias défini dans `SELECT` (ex. `nb_id`) est utilisable dans `HAVING` mais pas dans `WHERE` : `HAVING` est lu au même niveau que `SELECT`, après agrégation ; `WHERE` est lu avant, quand l'alias n'existe pas encore.

---

## 🥉🥈🥇 Où se situent les jointures dans un pipeline (Bronze / Silver / Gold)

- **Bronze → Silver** : nettoyage basique — formatage des colonnes, `CAST`.
- **Silver → Gold** : enrichissement via jointures et agrégations (`GROUP BY`) pour réduire la granularité vers un niveau exploitable par les décisionnaires.
- Les erreurs peuvent apparaître à **chaque** étape (extraction, cleaning, enrichissement, jointure) et se propagent **en cascade** : une erreur non détectée en bronze se retrouve amplifiée en gold — d'où l'intérêt des tests de qualité vus ci-dessus, à chaque étape plutôt qu'une fois à la fin.
- Le travail à plusieurs est lui-même une source d'erreur (mauvaise jointure, mauvais rapatriement d'un collègue) — une pipeline se maintient dans la durée, elle ne se construit pas une fois pour toutes.

> Cette architecture Bronze/Silver/Gold est l'équivalent conceptuel exact des couches staging/intermediate/marts de dbt (#9) — même logique, vocabulaire différent selon le contexte (Medallion Architecture vs dbt).

---

## 📎 Aperçus rapides (détaillés dans une session ultérieure)

- **`UNION`** : contrairement à une jointure qui ajoute des colonnes à l'horizontale, `UNION` empile des lignes à la verticale — utile pour fusionner deux tables de même structure (ex. deux mois d'inventaire) en une seule.
- **ERD** : rappel de la notion vue au [#5](05-intro-sql-bigquery.md) — un schéma relationnel permet de visualiser quelles colonnes relier avant d'écrire une jointure, plutôt que de le découvrir en lisant les données ligne par ligne.

---

## 🎯 Points clés pour les entretiens

- Savoir expliquer la **différence entre `INNER`, `LEFT`, `RIGHT` et `FULL OUTER`** avec un schéma mental simple (cercles concentriques gauche/droite) plutôt qu'une définition apprise par cœur.
- Justifier pourquoi **`RIGHT JOIN` est rarement utilisé** en pratique (équivalent à un `LEFT JOIN` inversé) — bon réflexe pour montrer une compréhension au-delà de la syntaxe.
- Le **piège de la duplication par jointure à grain différent** est un classique d'entretien technique : donner l'exemple concret (coût logistique compté deux fois) plutôt qu'une explication abstraite.
- Le lien entre le test manuel `GROUP BY ... HAVING COUNT(*) > 1` et les tests génériques `unique`/`not_null` de dbt — bon moyen de montrer qu'on comprend ce qu'un outil automatise, pas juste comment l'utiliser.
- Toujours pouvoir réciter l'**ordre d'exécution des clauses SQL** sans hésiter — c'est une question de base très fréquente, et l'erreur de note ci-dessus montre à quel point l'inversion `WHERE`/`GROUP BY` est facile à mal mémoriser.

---

## 🔗 Liens avec d'autres notions

- Le test manuel de clé primaire (`GROUP BY id HAVING COUNT(*) > 1`) est littéralement le brouillon des tests génériques `unique` et `not_null` automatisés par dbt — voir [#9 — Introduction à dbt](09-dbt-intro.md) et [#14 — dbt Advanced](14-dbt-advanced.md).
- Le piège de duplication par jointure (grain fin à gauche, grain grossier à droite) est un cas particulier du principe **agréger avant de diviser/sommer**, déjà noté côté dbt, Looker Studio et Power BI dans le brocode — même prudence, un contexte de plus.
- L'architecture Bronze/Silver/Gold vue ici est l'équivalent du staging/intermediate/marts de dbt ([#9](09-dbt-intro.md)) — vocabulaire différent, même logique de couches.
- La duplication par jointure à grain fin est la cause exacte du phénomène de **fan-out** en modélisation Power BI (une relation mal maîtrisée entre deux tables qui gonfle artificiellement une mesure) — la bonne pratique du star schema vue au [#23](23-power-bi-2.md) existe en grande partie pour éviter ce problème en amont.
- L'ordre d'exécution des clauses (`FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT`), corrigé plus haut, est celui déjà posé au [#6](06-sql-aggregation-date-string-functions.md) — bon repère pour vérifier la cohérence des futures fiches.

---

## ✅ Actions post-session

- [ ] Sauvegarder la requête de test de clé primaire (`GROUP BY id HAVING COUNT(*) > 1`) pour la réutiliser telle quelle sur d'autres tables
- [ ] Refaire les exercices pratiques sur les jointures
- [ ] Session suivante : dédoublonnage/partitionnement pour corriger les duplicatas de jointure à grain fin, `UNION` en détail

---

## ❓ Questions / Points flous

- [ ]
- [ ]

---

*Suite directe du [#6 — SQL : agrégations, dates & chaînes](06-sql-aggregation-date-string-functions.md). La correction des duplicatas de jointure (dédoublonnage, partitionnement) et `UNION` feront l'objet d'un chapitre dédié à la session suivante.*
