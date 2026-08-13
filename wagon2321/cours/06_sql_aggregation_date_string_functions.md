---
title: "SQL — Aggregations, String, Date & Time Functions"
aliases:
  - "SQL Aggregations"
  - "SQL String Functions"
  - "SQL Date & Time Functions"
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 6
date: 2026-07-13
language: "SQL"
database: "BigQuery / GoogleSQL"
topics:
  - "SQL"
  - "BigQuery"
  - "Aggregations"
  - "String"
  - "Date & Time"
tags:
  - brocode
  - wagon2321/cours
  - sql
  - bigquery
  - aggregations
  - date-time
---

# 📝 6 — SQL : agrégations (GROUP BY/HAVING) et fonctions de dates & chaînes de caractères

**Date** : 13 juillet 2026
**Thème** : Fonctions d'agrégation (COUNT/SUM/MIN/MAX/AVG), GROUP BY, HAVING vs. WHERE, fonctions STRING (CONCAT/REPLACE/LOWER/REGEXP), fonctions DATE (EXTRACT/DATE_TRUNC/DATE_DIFF/PARSE_DATE), contrôle qualité de la donnée

---

## 🎯 Contexte de la session

- Suite directe du [chapitre #5](05-intro-sql-bigquery.md), centrée sur les **fonctions d'agrégation**
- Objectif affiché : arriver, avec des formules SQL, au même résultat qu'un tableau croisé dynamique sur un tableur (Excel/Sheets)
- Journée en deux temps : théorie le matin (agrégation, GROUP BY, HAVING, fonctions string/date), puis session de révision collective en fin de journée sur les exercices

---

## 🧮 Fonctions d'agrégation

| Fonction | Comportement |
|---|---|
| `COUNT(*)` | Compte **toutes les lignes** ayant au moins une valeur non nulle — optimisé nativement dans les moteurs SQL |
| `COUNT(colonne)` | Compte les lignes **sauf les `NULL`** de cette colonne précise — peut donner un résultat différent de `COUNT(*)` selon la colonne choisie |
| `SUM`, `MIN`, `MAX`, `AVG` | Agrégats classiques |

- ⚠️ `NULL` n'est **pas considéré comme une donnée réelle** par le moteur SQL — même si on le "voit" affiché dans une cellule, il n'est pas compté par `COUNT(colonne)`
- Les agrégats se renomment avec un alias (`AS`), comme n'importe quelle colonne calculée

---

## 🗂️ GROUP BY — segmenter avant d'agréger

```sql
SELECT column, <aggregation function>
FROM purchases
GROUP BY column
```

- La colonne utilisée pour grouper doit obligatoirement apparaître dans le `SELECT` — sinon impossible de visualiser le résultat
- **Toute colonne du `SELECT` doit être soit agrégée, soit présente dans le `GROUP BY`** — sinon erreur. BigQuery est explicite sur l'erreur : si une colonne comme `model_id` apparaît dans le `SELECT` sans être ni agrégée ni groupée, le message d'erreur la nomme directement
- Plusieurs colonnes possibles dans le `GROUP BY` (regroupement multi-critères)
- Plusieurs fonctions d'agrégation possibles dans le même `SELECT`

---

## ⚖️ HAVING vs. WHERE — pré-filtrage vs. post-filtrage

C'est le piège classique de la session : les deux clauses filtrent, mais **pas au même moment ni sur les mêmes valeurs**.

```sql
-- HAVING : post-filtrage, sur le résultat agrégé
SELECT buyer, SUM(spend) AS total_spend
FROM purchases
GROUP BY buyer
HAVING total_spend > 10
```

```sql
-- WHERE : pré-filtrage, ligne par ligne, avant agrégation
SELECT buyer, SUM(spend) AS total_spend
FROM purchases
WHERE spend > 10
GROUP BY buyer
```

**Sur les mêmes données brutes, les deux requêtes donnent des résultats différents** :

| Étape | Résultat `HAVING` | Résultat `WHERE` |
|---|---|---|
| Avant filtre | Julie 12.5 / Paul 10 / Thomas 5 / Julien 17.5 (déjà agrégé) | Toutes les lignes individuelles d'achat |
| Après filtre | Julie 12.5 / **Julien 17.5** | **Julien 15** (uniquement) |

👉 `WHERE spend > 10` élimine les lignes d'achat individuelles ≤ 10 **avant** de sommer — Julien perd donc une partie de ses petits achats dans le total, qui tombe à 15 au lieu de 17.5. `HAVING total_spend > 10` filtre le total déjà calculé — Julie (12.5) et Julien (17.5) passent le seuil, Paul (10, pas strictement supérieur) et Thomas (5) sont exclus. Ce n'est pas juste une question de syntaxe : les deux requêtes répondent à des questions différentes.

- ⚠️ **Les fonctions d'agrégation sont interdites dans `WHERE`** : à ce stade de l'exécution, l'agrégation n'a pas encore eu lieu (cf. ordre d'exécution vu au [#5](05-intro-sql-bigquery.md) : `WHERE` s'exécute avant `GROUP BY`, `HAVING` après)
- Un alias créé dans le `SELECT`/`GROUP BY` (ex. `total_spend`) peut être réutilisé directement dans le `HAVING`

---

## 🔧 Fonctions par type de donnée — vue d'ensemble

| Numeric | String | Date |
|---|---|---|
| Opérateurs `+ - * /` | `CONCAT()` | `DATE_TRUNC()` |
| `SAFE_DIVIDE()` | `REPLACE()` | `DATE_SUB()` |
| `AVERAGE()` | `LENGTH()` | `DATE_DIFF()` |
| `ROUND()` | `SUBSTR()` | `FORMAT_DATE()` |
| | `LOWER()` / `UPPER()` | `EXTRACT()` |
| | `REGEXP_CONTAINS()` | `PARSE_DATE()` |

💡 `SAFE_DIVIDE()` apparaît ici formellement pour la première fois dans le cours — c'est la fonction qui gère nativement les divisions par zéro/valeurs nulles en renvoyant `NULL` plutôt qu'une erreur, à privilégier par réflexe pour tout ratio calculé sur de la donnée réelle.

### Fonctions STRING

**`CONCAT(value1, value2, ...)`** — concatène plusieurs valeurs (castables en `STRING`) :
```sql
SELECT CONCAT(year, "-", month, "-", day) AS date_string
FROM course15.fruit
-- 2021-06-03, 2021-06-03, 2021-06-15...
```

**`REPLACE(value, from_value, to_value)`** — remplace toutes les occurrences d'un sous-texte :
```sql
SELECT REPLACE(product, "i", "a") AS product
FROM course15.fruit
-- "binini" → "banana", "ipple" → "apple"
```

**`LOWER(value)` / `UPPER(value)`** — bascule la casse, utile pour des comparaisons insensibles à la casse (`LOWER(model_type) = LOWER("Top")` évite de se soucier de la casse d'origine) :
```sql
SELECT LOWER(buyer) AS buyer
FROM course15.fruit
-- "Ema" → "ema", "Paul" → "paul"
```
⚠️ `LOWER`/`UPPER` ajoutent une étape de transformation sur chaque ligne avant comparaison — moins performant qu'une comparaison stricte, à réserver aux cas où la casse n'est réellement pas fiable dans la donnée source.

**`INITCAP`** (aussi appelée `PROPER` sur d'autres moteurs) — met une majuscule en début de chaque mot.

**`REGEXP_CONTAINS(value, regexp)`** — renvoie `TRUE`/`FALSE` si `value` correspond (même partiellement) à l'expression régulière :
```sql
SELECT REGEXP_CONTAINS(buyer, "ma") AS contains_ma
FROM course15.fruit
-- Ema → TRUE, Paul → FALSE, Thomas → TRUE...
```

**`REGEXP_REPLACE(value, regexp, replacement)`** / **`REGEXP_EXTRACT(value, regexp, position, occurrence)`** — versions regex de `REPLACE` et d'extraction de sous-chaîne, pour des patterns que `LIKE` ne sait pas exprimer (ex. valider un format d'email, isoler une séquence de chiffres au milieu d'un texte).

**Pourquoi passer au regex plutôt que `LIKE`** : `LIKE` avec `%`/`_` reste très limité — impossible d'exprimer par exemple *"une séquence de chiffres entre 0 et 9"* ou *"un format d'email"* avec ces deux seuls jokers. Le regex permet des classes de caractères (`[A-Za-z0-9]`), des alternatives (`|` = OR), etc.

**Notes pratiques regex (BigQuery)** :
- Préfixer la chaîne d'un `r` (`r"..."`) dès qu'elle contient des caractères d'échappement type `\n`, `\t` — pour que BigQuery les traite comme des caractères littéraux de regex plutôt que des séquences d'échappement classiques
- `|` = opérateur **OR** à l'intérieur d'une expression régulière
- Pour retirer les accents d'une colonne texte, **`TRANSLATE()`** a été jugé en session comme l'approche la plus propre — plus lisible qu'un regex avec un joker `.` (qui matche n'importe quel caractère, pas seulement les accentués) ou qu'une liste explicite de caractères accentués à énumérer un par un
- Écrire un regex à la main n'est pas trivial en débutant — s'appuyer sur un assistant IA pour un premier jet est encouragé ; pour de la syntaxe spécifique à un moteur (ex. BigQuery), un outil entraîné sur la documentation Google (type Gemini) donne des réponses plus fiables qu'un assistant généraliste sur les spécificités BigQuery

### Fonctions DATE

**`DATE_DIFF(date_expression_a, date_expression_b, date_part)`** — nombre d'intervalles entre deux dates :
```sql
SELECT DATE_DIFF(date_delivery, date_purchase, DAY) AS delivery_time
FROM course15.fruit
```

**`EXTRACT(date_part FROM date_expression)`** — valeur numérique d'une composante de date (année, mois, semaine, jour de semaine...) :
```sql
SELECT EXTRACT(YEAR FROM date_purchase) AS year
FROM course15.fruit
```
📌 Selon le support de cours, `EXTRACT` attend une donnée au format `DATETIME` ; si la colonne est au format `DATE` simple, il peut être nécessaire de repasser par la fonction `DATE()` en amont.

**`PARSE_DATE(format_string, date_string)`** — convertit une chaîne de date non standard en objet `DATE`, à condition de préciser le format exact (y compris ponctuation et espaces) :
```sql
SELECT PARSE_DATE("%A, %e %B %Y", date_purchase) AS date_purchase
FROM course15.fruit
-- "Thursday, 3 June 2021" → 2021-06-03
```

**`DATE_TRUNC(date, date_part)`** — tronque une date à un grain donné, renvoie un objet `DATE` (pas juste un nombre).

**`DATE_SUB(date, INTERVAL n date_part)`** — soustrait un intervalle à une date (ex. reculer de 4 ans et 21 jours par rapport à une date de référence).

**`FORMAT_DATE()`** — formate une date en chaîne de caractères selon un patron donné (mentionnée en session, symétrique de `PARSE_DATE`).

#### 🆚 EXTRACT vs. DATE_TRUNC — comportement différent, à choisir selon l'usage

| | `EXTRACT(MONTH FROM date)` | `DATE_TRUNC(date, MONTH)` |
|---|---|---|
| Retourne | Un nombre (ex. `6`) | Une date tronquée (ex. `2021-06-01`) |
| Années confondues | ✅ Oui — juin 2021 et juin 2023 donnent tous les deux `6` | ❌ Non — juin 2021 (`2021-06-01`) et juin 2023 (`2023-06-01`) restent distincts |
| Cas d'usage type | Comportement moyen "peu importe l'année" (ex. saisonnalité mensuelle sur plusieurs années confondues) | Suivi mensuel dans le temps, année par année |

👉 Utiliser `EXTRACT(MONTH ...)` fait perdre la distinction d'année — pratique pour une moyenne "toutes années confondues", mais à éviter si l'objectif est justement de comparer le mois de juin 2021 à celui de 2022.

---

## 🔍 Contrôle qualité de la donnée avec l'agrégation

`COUNT` + `GROUP BY` sert aussi à **auditer une colonne** plutôt qu'à produire un résultat métier : détecter des doublons, ou tester si une colonne est un bon candidat clé primaire (valeurs non nulles et uniques).

```sql
SELECT model_type, COUNT(*) AS nb
FROM table
GROUP BY model_type
ORDER BY nb DESC
```

- Si la ligne en tête a `nb = 1` → toutes les valeurs sont uniques, la colonne est un candidat clé primaire valide
- Si des valeurs remontent avec `nb > 1` → la colonne contient des doublons. Exemple vu en session : `model_type` s'est révélée non unique, avec "accessoire couleur alu" et "top black" présents chacun 3 fois
- Ce même réflexe permet de repérer si un identifiant censé être unique est en réalité **composé de deux colonnes séparées** (l'unicité n'apparaît qu'en combinant les deux)

📌 **Lire le message d'erreur avant de chercher ailleurs** : les moteurs SQL (BigQuery en particulier) sont en général explicites sur la cause exacte du problème (ex. ils nomment directement la colonne non groupée/agrégée en cause) — un bon réflexe de débogage plutôt que de deviner.

💡 **Pour aller plus loin** : `ROLLUP` (extension du `GROUP BY`) a été mentionné brièvement en session pour calculer des sous-totaux et un grand total en une seule requête, sans empiler plusieurs `UNION`. Non détaillé en session — à creuser si le besoin se présente.

---

## 🎯 Points clés pour les entretiens

- Savoir distinguer **WHERE (pré-filtrage, avant agrégation) vs. HAVING (post-filtrage, après agrégation)** avec un exemple chiffré à l'appui — *le* classique des entretiens techniques SQL
- Expliquer *pourquoi* les fonctions d'agrégation sont interdites dans `WHERE` — pas une règle arbitraire, mais une conséquence directe de l'ordre d'exécution des clauses
- Le duo **EXTRACT vs. DATE_TRUNC** pour parler d'agrégation temporelle (comparaison intra-annuelle vs. suivi année par année)
- Justifier le passage au regex plutôt qu'à `LIKE` dès que le pattern dépasse un simple "commence par / contient" (ex. validation de format email)
- La technique **COUNT + GROUP BY** pour valider qu'une colonne est un bon candidat clé primaire — bon réflexe de data quality à mentionner spontanément

---

## 🔗 Liens avec d'autres notions

- Le couple WHERE/HAVING est une application directe de l'**ordre d'exécution des clauses** vu au [#5](05-intro-sql-bigquery.md) (`FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT`) : comprendre cet ordre rend la règle "pas d'agrégation dans WHERE" évidente plutôt qu'arbitraire
- `SAFE_DIVIDE()`, vu ici dans le tableau des fonctions numériques, est la même prudence déjà notée côté dbt/BigQuery et côté Looker Studio (agréger avant de diviser, [#20](20-looker-studio-2.md)) — trois contextes différents, un seul réflexe : ne jamais diviser avant d'avoir agrégé
- `TRANSLATE()` pour nettoyer les accents complète `CAST`/`SAFE_CAST` vu au [#5](05-intro-sql-bigquery.md) : dans les deux cas, l'idée est de normaliser une colonne texte *avant* de l'utiliser dans une comparaison ou une agrégation, plutôt que de découvrir le problème après coup

---

## ✅ Actions post-session

- [ ] Revoir les exercices sur les jointures, jugés peu clairs par le groupe
- [ ] Préparer la session du lendemain

---

## ❓ Questions / Points flous

- [ ]
- [ ]

---

*Suite directe du [#5 — Introduction à SQL & BigQuery](05-intro-sql-bigquery.md). Les jointures, peu abordées cette session, feront l'objet d'un chapitre dédié.*
