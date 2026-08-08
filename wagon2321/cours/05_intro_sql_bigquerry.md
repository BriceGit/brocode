# 📝 #5 — Introduction à SQL & BigQuery : ERD, syntaxe de base et fonctions

**Date** : 10 juillet 2026
**Thème** : Bases de données relationnelles, ERD, prise en main de BigQuery, syntaxe SQL (SELECT/WHERE/ORDER BY/LIMIT), fonctions (IF, CASE WHEN, ROUND, CAST/SAFE_CAST), types de données
**Compréhension (1→5)** : ⭐⭐⭐

---

## 🎯 Contexte de la session

- Tout premier cours SQL du bootcamp, juste après 3 jours de formation Google Sheets
- Objectif affiché : montrer que SQL n'est pas un langage complexe, et qu'il répond à des limites que Google Sheets ne peut pas résoudre
- Session en deux parties : (1) concepts de bases de données relationnelles & ERD, (2) prise en main de BigQuery et syntaxe SQL

---

## 🗂️ Bases de données relationnelles & ERD

### Le modèle relationnel

- Un **modèle relationnel** = plusieurs tables liées entre elles plutôt qu'une seule table à plat — orienté transaction, pensé pour éviter de répéter la donnée (contrairement à un classeur Google Sheets)
- **Clé primaire (PK)** : identifiant unique d'une ligne dans sa table
- **Clé étrangère (FK / Join Key)** : référence à la clé primaire d'une autre table, c'est elle qui matérialise la relation

### Les types de relations

| Relation | Définition | Exemple |
|---|---|---|
| **1:1** (one-to-one) | Une ligne d'une table = une seule ligne d'une autre | Une commande ↔ un coût logistique |
| **1:N** (one-to-many) | Une ligne d'une table = plusieurs lignes d'une autre | Un client → plusieurs commandes |
| **N:1** (many-to-one) | L'inverse du 1:N, même relation lue dans l'autre sens | Plusieurs commandes → un client |
| **N:N** (many-to-many) | Plusieurs lignes ↔ plusieurs lignes, rare, passe généralement par une table intermédiaire | Élèves ↔ matières |

### L'ERD (Entity Relationship Diagram)

Schéma visuel qui représente comment les **entités** (tables) se relient entre elles — indispensable pour prendre en main une base existante ou en concevoir une nouvelle, à la main ou avec un outil dédié.

Notation de cardinalité (patte d'oie) :

| Symbole | Terme (slide) | Signification |
|---|---|---|
| Ligne + cercle | **Zero or one** | Zéro ou un |
| Ligne + patte d'oie | **Many** | Plusieurs |
| Une barre | **One** | Un — rarement utilisé seul |
| Deux barres | **One (and only one)** | Exactement un |
| Cercle + patte d'oie | **Zero or many** | Zéro ou plusieurs |
| Barre + patte d'oie | **One or many** | Un ou plusieurs |

Lecture type : *"un client unique peut passer zéro ou plusieurs commandes"* (client —‖ ←o— commandes), *"une commande référence exactement un client"*.

### Exemple concret — table intermédiaire en pratique

```
customers (PK customers_id) ──1:N──▶ orders (FK customers_id, PK orders_id)
orders    (PK orders_id)    ──1:N──▶ sales  (FK orders_id)
products  (PK products_id)  ──1:N──▶ sales  (FK products_id)
```

💡 La table `sales` joue ici le rôle de **table intermédiaire** entre `orders` et `products` : c'est une application concrète du pattern many-to-many évoqué plus haut (élèves ↔ matières) — une commande peut contenir plusieurs produits, un produit peut apparaître dans plusieurs commandes, et `sales` matérialise chaque association individuelle via ses deux clés étrangères.

### Data dictionary

Documentation du **sens métier** de chaque colonne importante (à quoi elle correspond, comment elle est utilisée) — peut être directement intégrée à l'ERD. Bonne pratique de base pour qu'un collègue qui reprend la base ne parte pas de zéro.

---

## ☁️ Prise en main de BigQuery

- BigQuery vit dans l'environnement **Google Cloud** — hiérarchie : **Projet** > **Dataset** > **Table**
- 📌 Mettre son projet en favori pour y revenir facilement (évite des soucis de facturation/enregistrement sur le mauvais projet)
- En cliquant sur une table : schéma détaillé, infos de création, source, aperçu des 50 premières lignes
- Deux types de tables à distinguer :
  - **Table connectée à un Google Sheet** → se met à jour automatiquement si la feuille source change
  - **Table stockée en direct dans BigQuery** → dispose d'un onglet **Preview** dédié pour visualiser un échantillon
- Interface en **onglets de requêtes**, comme un navigateur : chaque nouvelle requête peut s'ouvrir dans un nouvel onglet

---

## 🧱 Syntaxe SQL de base

### SELECT

```sql
SELECT *          -- toutes les colonnes
FROM People
```

```sql
SELECT name, surname   -- uniquement les colonnes utiles
FROM People
```

- ⚠️ `SELECT *` **impacte les performances et la facturation** : BigQuery facture au volume de données scanné. Exemple vu en session : un `SELECT *` sur une table traite ~216 Mo, contre ~54 Mo pour un `SELECT name` seul sur la même table → prendre l'habitude de ne sélectionner que les colonnes nécessaires, surtout en production
- `SELECT DISTINCT colonne` : ne retourne que les valeurs uniques
- `AS` : renomme une colonne (alias) pour la lisibilité — fonctionne aussi sur les tables (utile pour les jointures, vues plus tard)
- Un `SELECT` **ne modifie jamais la table source** ; pour persister un résultat, il faut l'enregistrer comme nouvelle table BigQuery
- BigQuery affiche le **volume de données à traiter** avant l'exécution, et met en **cache** les requêtes identiques (pas re-facturées si rejouées à l'identique)
- Raccourcis : `Ctrl + Entrée` pour exécuter, `Edit > Format Query` pour formater automatiquement

### WHERE — filtrer

```sql
SELECT *
FROM People
WHERE name = "Clara"
```

- ⚠️ Sensible à la **casse**, et l'ordre des clauses est obligatoire : `SELECT → FROM → WHERE` (mettre `WHERE` avant `FROM` = erreur)
- Les valeurs textuelles et les **dates** doivent être entre guillemets (`"..."`), sinon l'interpréteur ne sait pas de quel type est la valeur — erreur classique de débutant, silencieuse et déroutante

**Recherche textuelle avec `LIKE`** :

| Symbole | Signification | Exemple |
|---|---|---|
| `%` | N'importe quel nombre de caractères | `LIKE 'P%'` → commence par P |
| `_` | Exactement un caractère | `LIKE '_a%'` → "a" en 2ᵉ position |
| `NOT LIKE` | Inverse la recherche | `NOT LIKE '%a%'` → ne contient pas de "a" |

**Combiner des conditions** :
```sql
WHERE name = "Dupuis" AND birth_date > "1990-01-01"
```
- `AND` / `OR` : ⚠️ priorité des opérateurs comme en mathématiques (`AND` prime sur `OR`) → utiliser des **parenthèses** pour lever toute ambiguïté, sinon le nombre de lignes retourné peut être différent de ce qu'on attend
- `IN (valeur1, valeur2, ...)` : remplace une série de `OR` sur la même colonne ; `NOT IN` pour l'inverse — plus lisible, mais ne permet pas de wildcard à l'intérieur (dans ce cas, repasser par des `OR` + `LIKE`)
- Commentaires : `--` (une ligne) ou `/* ... */` (plusieurs lignes) — bonne pratique dès que les requêtes s'enchaînent, pour se souvenir de l'intention derrière chaque étape

### ORDER BY, LIMIT & ordre des clauses

```sql
SELECT *
FROM People
ORDER BY birth_date DESC
LIMIT 3
```

- `ORDER BY colonne ASC/DESC` : plusieurs critères possibles (tri secondaire en cas d'égalité)
- `LIMIT n` : ne garde que les n premiers résultats (après le tri)
- ⚠️ Éviter `ORDER BY 2` (numéro de position de colonne) : source de confusion silencieuse si l'ordre des colonnes du `SELECT` change plus tard

**Ordre d'écriture vs. ordre d'exécution** — à bien distinguer, piège classique :

| Écriture (ce qu'on tape) | Exécution (ce que BigQuery fait réellement) |
|---|---|
| `SELECT` | `FROM` |
| `FROM` | `JOIN` |
| `JOIN` | `WHERE` |
| `WHERE` | `GROUP BY` |
| `GROUP BY` | `HAVING` |
| `HAVING` | `SELECT` |
| `ORDER BY` | `ORDER BY` |
| `LIMIT` | `LIMIT` |

👉 On **écrit** `SELECT` en premier, mais BigQuery ne l'**exécute** qu'après avoir construit et filtré la table (`FROM → JOIN → WHERE → GROUP BY → HAVING`). *(`GROUP BY` et `HAVING` seront couverts dans une session dédiée à venir.)*

---

## 🔧 Fonctions

### IF — condition simple

```sql
SELECT *,
  IF(number_of_children > 0, 1, 0) AS has_children
FROM People
```
`IF(condition, valeur_si_vrai, valeur_si_faux)` : exactement 2 résultats possibles.

### CASE WHEN — condition à plusieurs branches

Dès qu'il faut plus de 2 résultats possibles, `IF` ne suffit plus → `CASE WHEN`.

```sql
SELECT *,
  CASE
    WHEN number_of_children > 3 THEN "grande famille"
    WHEN number_of_children >= 1 THEN "famille normale"
    WHEN number_of_children = 0 THEN "sans enfant"
    ELSE "non renseigné"
  END AS family_segment
FROM People
```

- ⚠️ **L'ordre des conditions compte** : toujours aller **du plus restrictif au moins restrictif**. Ici, `> 3` doit être testé *avant* `>= 1`, sinon toute famille de plus de 3 enfants tomberait quand même dans "famille normale" (la première condition vraie rencontrée l'emporte, les suivantes ne sont jamais évaluées)
- Les valeurs `NULL` qui ne correspondent à aucune condition explicite tombent automatiquement dans le `ELSE`
- `IF` et `CASE WHEN` ne **filtrent pas** les lignes (contrairement à `WHERE`) : ils créent une colonne affichée avec une valeur différente selon la condition, mais gardent toutes les lignes

### Une colonne calculée doit vivre dans le SELECT

Toute colonne qu'on veut afficher — existante, renommée, ou calculée via `IF`/`CASE WHEN` — doit être listée dans le `SELECT`. On ne peut pas la définir ailleurs (ex. après le `FROM`) : erreur de syntaxe garantie. L'**ordre des colonnes dans le `SELECT`** correspond à l'**ordre d'affichage** du résultat — pour un ordre précis en mélangeant colonnes existantes et calculées, il faut lister chaque colonne explicitement (pas de raccourci du type `*` + une colonne insérée au milieu).

### ROUND — arrondir

Arrondit une valeur flottante à l'affichage (n'arrondit pas la donnée source).

### CAST / SAFE_CAST — convertir un type

```sql
SELECT
  CAST(birth_date AS DATE) AS birth_date
FROM People
```

- `CAST(expression AS type)` : convertit une colonne d'un type vers un autre (Numeric ↔ String ↔ Date, dans la limite du compatible)
- Si la conversion est impossible pour une valeur (ex. `CAST` d'un texte non numérique en `INT64`), `CAST` renvoie une **erreur** et bloque toute la requête
- `SAFE_CAST` : même fonction, mais renvoie `NULL` au lieu d'une erreur sur les valeurs non convertibles

⚠️ **Bonne pratique** : toujours essayer `CAST` en premier. S'il échoue, diagnostiquer *pourquoi* avant de basculer sur `SAFE_CAST` — combien de valeurs posent problème (une poignée d'erreurs de saisie isolées, à corriger à la source ? ou un problème de format systémique sur toute la colonne ?). Utiliser `SAFE_CAST` par réflexe, sans vérifier, revient à faire disparaître silencieusement de la donnée en `NULL` sans savoir combien ni pourquoi.

---

## 🔤 Types de données

| Catégorie | Types | Notes |
|---|---|---|
| **Numeric** | `INT64`, `FLOAT64`, `NUMERIC`/`BIGNUMERIC`, `BOOLEAN` | `BOOLEAN` = 1 byte de stockage (vs. minimum 2 bytes + contenu pour un `STRING` "true"/"false" équivalent) |
| **Text** | `STRING` | |
| **Date** | `DATE`, `DATETIME`, `TIMESTAMP`, + composants `YEAR/MONTH/QUARTER/WEEK/DAY/HOUR/MINUTE` | |
| **Autres** | types géographiques, types complexes | Peu utilisés en début de parcours |

Pourquoi le bon type compte, au-delà du principe :
1. **Stockage** : un mauvais type gonfle inutilement le volume de la table (donc le coût de stockage et de scan)
2. **Fonctions disponibles** : une fonction de date ne fonctionne que sur une colonne réellement typée `DATE` (pas sur un `STRING` qui *ressemble* à une date)
3. **Tri (`ORDER BY`)** : le comportement de tri diffère selon qu'une colonne est lue comme texte, nombre ou date — un mauvais typage peut fausser silencieusement un tri

💡 Réflexe : vérifier le type des colonnes dans le schéma de la table BigQuery **avant** de travailler dessus, plutôt que de le découvrir via une erreur en plein milieu d'une requête.

---

## 🗄️ Vue vs. requête planifiée — deux façons de "sauvegarder" un traitement

Deux concepts distincts évoqués en session, à ne pas confondre :

| | **Vue (View)** | **Requête planifiée (Scheduled query)** |
|---|---|---|
| Fonctionnement | Requête enregistrée, **ré-exécutée en direct** à chaque appel | Requête enregistrée, exécutée **automatiquement à intervalle régulier** |
| Stockage | Aucune donnée stockée à part — recalcul à la volée | Écrit son résultat dans une **table de destination** physique |
| Fraîcheur | Toujours à jour (recalculée à chaque lecture) | À jour uniquement à la fréquence de planification choisie |

👉 Approche par étapes typique : donnée brute → nettoyage dans une nouvelle table → utilisation de cette table nettoyée pour l'analyse. Ces étapes peuvent être automatisées via une requête planifiée + table de destination, ou via des outils externes de scheduling *(vus dans une session à venir)*.

📌 Ne jamais écraser directement la donnée brute — toujours travailler sur une **nouvelle table** pour le nettoyage/l'agrégation, afin de garder une trace de la source d'origine.

---

## 🎯 Points clés pour les entretiens

- Savoir expliquer la différence **CAST vs. SAFE_CAST**, et surtout *pourquoi* ne pas utiliser `SAFE_CAST` par défaut (masque les erreurs plutôt que de les résoudre)
- Le piège de l'**ordre des conditions** dans un `CASE WHEN` (du plus restrictif au moins restrictif) — bon exemple concret à donner en entretien technique
- Savoir distinguer **ordre d'écriture** et **ordre d'exécution** des clauses SQL — explique pourquoi certaines requêtes "logiques" à l'œil ne compilent pas
- Justifier l'intérêt d'éviter `SELECT *` en production avec un ordre de grandeur concret (facturation au volume scanné)
- La distinction **vue vs. requête planifiée** : bon réflexe pour parler d'architecture de pipeline en entretien (fraîcheur des données vs. coût de recalcul)

---

## 🔗 Liens avec d'autres notions

*Premier chapitre du brocode dans l'ordre chronologique des sessions — les chapitres référencés ci-dessous ont été rédigés avant celui-ci, mais couvrent des sessions ultérieures :*

- Le réflexe **CAST avant SAFE_CAST** annonce directement la prudence déjà notée sur `SAFE_DIVIDE` et le non-arrondi des colonnes intermédiaires en dbt/BigQuery : dans les deux cas, la règle est de comprendre l'anomalie avant de la masquer silencieusement
- Le `CASE WHEN` vu ici avec la segmentation par nombre d'enfants est le même outil que celui utilisé plus tard pour créer un champ calculé dans Looker Studio (#20) — la logique de recatégorisation via conditions ordonnées est transférable telle quelle entre SQL et l'interface de Looker Studio
- L'ERD et les clés primaires/étrangères posent les bases nécessaires pour aborder les jointures (`JOIN`), couvertes dans une session ultérieure

---

## ✅ Actions post-session

- [ ] Copier la table depuis l'espace Data Analytics vers son projet BigQuery personnel (instructions dans les ressources du cours)
- [ ] Revoir les notions de base SQL à partir de l'exercice 2 dans les ressources personnelles
- [ ] Alias de tables (`AS` sur les tables, utile pour les jointures) — abordé lors d'une session ultérieure (mardi/mercredi)
- [ ] `GROUP BY` / `HAVING` — abordés lors d'une prochaine session
- [ ] Vues et outils externes de scheduling — couverts dans deux semaines

---

## ❓ Questions / Points flous

- [ ]
- [ ]

---

*Premier chapitre du brocode — les sessions suivantes (jointures, GROUP BY/HAVING, dbt...) feront l'objet de chapitres dédiés.*
