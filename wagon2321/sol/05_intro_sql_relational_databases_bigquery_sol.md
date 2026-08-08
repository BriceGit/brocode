# 📝 #5 – SQL : Introduction, Relational Databases & BigQuery

**Date : 10 juillet 2026**  
**Thème :** Introduction à SQL, modèle relationnel, ERD, BigQuery, requêtes de sélection, filtres, tri, fonctions de base et types de données  
**Tags :** `SQL` `BigQuery` `Relational Database` `ERD` `Primary Key` `Foreign Key` `SELECT` `WHERE` `LIKE` `IN` `ORDER BY` `CASE WHEN` `CAST` `SAFE_CAST`  
**Compréhension (1→5) :** ⭐⭐⭐☆☆

---

> **Objectif du chapitre :** construire une introduction SQL suffisamment solide pour servir de **chapitre de référence** pendant toute la suite du parcours Data Analytics.
>
> À la fin de ce chapitre, il faut être capable de répondre clairement à cinq questions :
>
> 1. **Comment les données sont-elles organisées dans une base relationnelle ?**
> 2. **Comment lire un ERD et comprendre les relations entre tables ?**
> 3. **Comment BigQuery organise-t-il les données et exécute-t-il une requête ?**
> 4. **Comment sélectionner, filtrer, trier et transformer des lignes en SQL ?**
> 5. **Quels réflexes adopter dès le début pour écrire du SQL fiable, lisible et peu coûteux ?**
>
> Le but n'est pas de mémoriser une liste de mots-clés.
>
> Le vrai objectif est de construire ce modèle mental :
>
> ```text
> Je comprends la structure de mes données
>                 ↓
> Je sais quelle table contient l'information
>                 ↓
> Je sais ce qu'une ligne représente
>                 ↓
> J'écris une requête pour sélectionner / filtrer / transformer
>                 ↓
> Je contrôle le type des données
>                 ↓
> Je contrôle le résultat obtenu
>                 ↓
> Je n'altère pas accidentellement la donnée brute
> ```

---

# 🧭 0. Vue d'ensemble : ce qu'est réellement SQL

SQL signifie :

```text
Structured Query Language
```

On peut le traduire approximativement par :

> **langage structuré de requête**

SQL sert principalement à **interroger et manipuler des données organisées dans des bases de données**.

Pour un Data Analyst, la question la plus fréquente est :

```text
Dans toutes les données disponibles,
quelles lignes et quelles colonnes
dois-je utiliser pour répondre à ma question ?
```

Une requête SQL est donc souvent une **question formulée à une base de données**.

Exemple métier :

> Quels sont les clients nés après 1990 qui ont au moins un enfant ?

On peut progressivement traduire cette question en SQL :

```sql
SELECT
  name,
  surname,
  birth_date,
  number_of_children
FROM people
WHERE birth_date >= DATE '1990-01-01'
  AND number_of_children >= 1;
```

La logique est très proche du langage naturel :

```text
SELECT    → qu'est-ce que je veux afficher ?
FROM      → d'où viennent les données ?
WHERE     → quelles lignes dois-je conserver ?
```

C'est l'une des raisons pour lesquelles SQL est relativement accessible au début.

---

# 🧠 1. Pourquoi apprendre SQL après Google Sheets ?

Google Sheets est extrêmement utile pour :

- explorer rapidement une petite table ;
- faire des calculs ponctuels ;
- créer des tableaux de synthèse ;
- partager facilement des fichiers ;
- prototyper une analyse.

Mais lorsque les volumes et la complexité augmentent, certaines limites apparaissent.

Exemples :

```text
beaucoup de lignes
+
plusieurs tables liées entre elles
+
transformations répétées
+
besoin d'automatisation
+
besoin de reproductibilité
=
SQL devient beaucoup plus adapté
```

Avec SQL, on ne manipule pas manuellement chaque cellule.

On décrit **la transformation que l'on souhaite appliquer à l'ensemble de la donnée**.

Exemple :

```sql
SELECT
  customer_id,
  SUM(turnover) AS total_turnover
FROM sales
GROUP BY customer_id;
```

Cette logique peut fonctionner sur :

```text
100 lignes
1 000 lignes
1 000 000 lignes
1 000 000 000 lignes
```

à condition que l'infrastructure soit dimensionnée pour cela.

---

# 🗃 2. Première notion fondamentale : une base de données

Une base de données est un système permettant de :

- stocker des données ;
- les organiser ;
- les retrouver ;
- les mettre à jour ;
- les relier ;
- les interroger.

Dans une base relationnelle, les données sont principalement représentées sous forme de **tables**.

Exemple :

```text
customers
─────────
customer_id
firstname
surname
birth_date
```

Une table ressemble visuellement à un tableau.

Mais il faut immédiatement apprendre le vocabulaire précis.

---

# 🧱 3. Table, ligne, colonne, champ, enregistrement

Considérons :

```text
people
─────────────────────────────────────────────────────────
id | name      | surname      | birth_date | nb_children
───|───────────|──────────────|────────────|─────────────
1  | Paul      | Mochkovitch  | 1990-08-13 | 0
2  | Charlotte | Dupuis       | 1986-11-05 | 2
3  | Clara     | Milaux       | 1976-02-12 | 3
```

## Une colonne

Une colonne représente généralement un **attribut**.

Exemples :

```text
name
birth_date
number_of_children
```

Toutes les valeurs d'une même colonne devraient avoir une signification cohérente et un type compatible.

---

## Une ligne

Une ligne représente un **enregistrement**.

Dans la table `people`, une ligne représente ici :

```text
une personne
```

Cette idée semble triviale, mais elle devient fondamentale lorsque l'on travaille avec plusieurs tables.

La question à développer dès le début est :

> **Qu'est-ce qu'une ligne représente dans cette table ?**

Cette question prépare directement la notion de **granularité**, qui deviendra essentielle dans les chapitres sur les `JOIN`, les agrégations et les Window Functions.

---

# 🔬 4. La granularité : le réflexe qui évite une grande partie des erreurs SQL

La **granularité** décrit ce que représente **une ligne** d'une table.

Exemples :

```text
customers
1 ligne = 1 client
```

```text
orders
1 ligne = 1 commande
```

```text
sales
1 ligne = 1 produit vendu dans une commande
```

Ces trois tables n'ont donc pas la même granularité.

Exemple :

```text
orders
order_id | customer_id
---------|------------
451      | 10
623      | 12
```

Une ligne représente une commande.

Mais dans :

```text
sales
order_id | product_id | turnover
---------|------------|---------
451      | 6532       | 24.0
451      | 1068       | 15.4
623      | 4102       | 19.4
623      | 928        | 24.8
623      | 6532       | 12.0
```

Une même commande peut apparaître plusieurs fois.

Ici :

```text
1 ligne ≠ 1 commande
1 ligne = 1 ligne de vente / produit d'une commande
```

> 💡 **Réflexe Brocode :** avant presque toute requête importante, demander :
>
> ```text
> 1 ligne = quoi ?
> ```

---

# 🧩 5. Qu'est-ce qu'une base de données relationnelle ?

Une base de données relationnelle organise les informations dans **plusieurs tables reliées entre elles**.

Pourquoi ne pas tout stocker dans une seule énorme table ?

Parce que l'on répéterait énormément d'informations.

Exemple naïf :

```text
order_id | customer_name | customer_email | product_name | price
---------|---------------|----------------|--------------|------
451      | Emma          | e@x.com        | Banana       | 2.5
451      | Emma          | e@x.com        | Apple        | 3.0
452      | Emma          | e@x.com        | Tomato       | 4.0
```

Le nom et l'email d'Emma sont répétés.

Dans un modèle relationnel, on peut séparer :

```text
customers
customer_id | name | email
```

```text
orders
order_id | customer_id | date_purchase
```

```text
sales
order_id | product_id | quantity
```

```text
products
product_id | product_name | price
```

Les tables sont reliées grâce à des identifiants.

---

# 🔑 6. Primary Key — clé primaire

Une **Primary Key** identifie de manière unique une ligne dans une table.

Exemple :

```text
customers
customer_id | name
------------|------
101         | Emma
102         | Paul
103         | Clara
```

Ici :

```text
customer_id
```

est une bonne candidate pour être une clé primaire.

Propriétés conceptuelles d'une clé primaire :

```text
unique
+
non NULL
+
stable
```

Cela signifie :

```text
customer_id = 101
```

doit désigner une seule ligne.

---

# 🔗 7. Foreign Key — clé étrangère

Une **Foreign Key** est une colonne qui référence une clé d'une autre table.

Exemple :

```text
customers
customer_id | name
------------|------
101         | Emma
102         | Paul
```

```text
orders
order_id | customer_id
---------|------------
451      | 101
452      | 101
453      | 102
```

Dans `orders` :

```text
customer_id
```

est une clé étrangère logique vers :

```text
customers.customer_id
```

La relation peut être représentée ainsi :

```text
customers.customer_id
        PK
        │
        ▼
orders.customer_id
        FK
```

Cette relation permet ensuite d'associer les informations des deux tables.

---

# ⚠️ 8. Important avec BigQuery : les clés peuvent être conceptuelles

Dans une base transactionnelle classique, les contraintes de clés sont souvent fortement contrôlées par le moteur.

BigQuery est avant tout une plateforme analytique.

Il sait représenter des contraintes `PRIMARY KEY` / `FOREIGN KEY`, mais dans BigQuery elles ne doivent pas être considérées comme un garde-fou automatique de qualité de données.

En pratique, en analytics :

```text
documentation
+
tests
+
connaissance du modèle
```

restent indispensables.

Il faut donc savoir vérifier soi-même :

```sql
SELECT
  customer_id,
  COUNT(*) AS nb_rows
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
```

Si cette requête retourne des lignes alors que `customer_id` devrait être unique, on a un problème de qualité ou de modélisation.

---

# 🕸 9. ERD — Entity Relationship Diagram

Un **ERD** est un diagramme représentant :

- les entités / tables ;
- leurs attributs / colonnes ;
- leurs clés ;
- les relations entre les tables ;
- leurs cardinalités.

ERD signifie :

```text
Entity Relationship Diagram
```

Exemple simplifié :

```text
┌─────────────────┐
│ customers       │
├─────────────────┤
│ customer_id PK  │
│ firstname       │
│ surname         │
└────────┬────────┘
         │
         │ 1 → N
         │
┌────────▼────────┐
│ orders          │
├─────────────────┤
│ order_id PK     │
│ customer_id FK  │
│ date_purchase   │
└────────┬────────┘
         │
         │ 1 → N
         │
┌────────▼────────┐
│ sales           │
├─────────────────┤
│ sale_id PK      │
│ order_id FK     │
│ product_id FK   │
│ turnover        │
│ qty             │
└────────┬────────┘
         │
         │ N → 1
         │
┌────────▼────────┐
│ products        │
├─────────────────┤
│ product_id PK   │
│ product_name    │
│ category        │
└─────────────────┘
```

Un ERD permet de comprendre rapidement :

```text
où se trouve chaque information
+
comment les tables peuvent être reliées
+
quelle cardinalité existe entre elles
```

---

# 🧭 10. Entité, attribut et relation

Dans un ERD :

## Entity

Une **entity** correspond généralement à un objet métier.

Exemples :

```text
Customer
Order
Product
Sale
```

---

## Attribute

Un **attribute** décrit une propriété de l'entité.

Pour `Customer` :

```text
customer_id
firstname
surname
email
birth_date
```

---

## Relationship

Une **relationship** décrit le lien entre deux entités.

Exemple :

```text
Customer
   │
   └── places ──► Order
```

---

# 🔢 11. Cardinalité : combien de lignes peuvent être reliées ?

La cardinalité décrit le nombre d'occurrences possibles de chaque côté d'une relation.

Les grands cas sont :

```text
1:1
1:N
N:1
N:N
```

Mais un ERD moderne exprime souvent également l'**optionalité** :

```text
0..1
1..1
0..N
1..N
```

---

# 🐦 12. Lire la notation « Crow's Foot »

La notation dite **Crow's Foot** utilise des symboles ressemblant à une patte d'oie.

On peut retenir :

```text
○   = zéro / optionnel
|   = un
<   = plusieurs
```

Les combinaisons donnent :

```text
○|   = zéro ou un
||   = exactement un
○<   = zéro ou plusieurs
|<   = un ou plusieurs
```

Autrement dit :

| Symbole conceptuel | Lecture |
|---|---|
| `0..1` | zéro ou un |
| `1..1` | exactement un |
| `0..N` | zéro ou plusieurs |
| `1..N` | un ou plusieurs |

---

# 1️⃣ 13. Relation One-to-One — 1:1

Une relation **one-to-one** signifie qu'une ligne d'une table est associée à une seule ligne d'une autre table.

Exemple métier :

```text
orders
order_id
451
```

```text
order_logistics
order_id | logistics_cost
451      | 4.50
```

Lecture :

```text
1 commande
↔
1 ensemble de coûts logistiques
```

Une relation 1:1 est moins fréquente qu'une relation 1:N.

Elle peut être utilisée pour :

- séparer certaines données sensibles ;
- séparer des groupes de colonnes ;
- isoler des informations optionnelles ;
- organiser différents sous-domaines métier.

---

# 1️⃣➡️♾ 14. Relation One-to-Many — 1:N

C'est l'une des relations les plus fréquentes.

Exemple :

```text
1 customer
→
plusieurs orders
```

```text
customers
customer_id
101
```

```text
orders
order_id | customer_id
451      | 101
452      | 101
453      | 101
```

Lecture :

```text
Emma peut avoir plusieurs commandes.
Chaque commande appartient ici à un seul client.
```

Du point de vue inverse :

```text
orders → customers
```

on peut parler de :

```text
many-to-one
N:1
```

Mais c'est la même relation observée depuis l'autre côté.

---

# ♾➡️♾ 15. Relation Many-to-Many — N:N

Une relation many-to-many signifie :

```text
plusieurs lignes de A
peuvent être reliées à
plusieurs lignes de B
```

Exemple :

```text
students
↔
courses
```

Un étudiant suit plusieurs cours.

Un cours contient plusieurs étudiants.

On évite généralement de matérialiser cette relation directement.

On crée une **table intermédiaire**.

```text
students
student_id
```

```text
courses
course_id
```

```text
student_courses
student_id | course_id
```

La relation N:N devient alors :

```text
students
   1
   │
   N
student_courses
   N
   │
   1
courses
```

Cette table est souvent appelée :

```text
junction table
association table
bridge table
```

selon le contexte.

---

# 🧠 16. Pourquoi l'ERD devient vital en Data Analytics

Sans ERD, on peut facilement écrire :

```sql
SELECT ...
FROM sales
JOIN orders ...
JOIN customers ...
JOIN products ...
```

sans comprendre précisément :

```text
quelle table est unique sur quelle clé
+
quelle relation est 1:1 ou 1:N
+
si la jointure va multiplier les lignes
```

L'ERD sert donc à répondre avant le SQL à :

```text
Quelle table contient l'information ?
Quelle clé dois-je utiliser ?
Quelle cardinalité dois-je attendre ?
Quelle granularité aura mon résultat ?
```

> 💡 **Règle :** un `JOIN` est une opération SQL ; la cardinalité est une propriété du modèle de données. Il faut comprendre la seconde avant d'utiliser la première.

---

# 📖 17. Le Data Dictionary

Un ERD montre surtout la **structure**.

Un **Data Dictionary** explique la **signification métier**.

Exemple :

| Colonne | Type | Description métier |
|---|---|---|
| `customer_id` | INT64 | Identifiant interne unique du client |
| `signup_date` | DATE | Date d'inscription au compte |
| `turnover` | NUMERIC | Chiffre d'affaires de la ligne de vente |
| `status` | STRING | Statut de la commande |

Un bon data dictionary peut également préciser :

- unité ;
- fréquence de mise à jour ;
- valeurs autorisées ;
- propriétaire métier ;
- règle de calcul ;
- présence possible de `NULL` ;
- source de la donnée.

Le couple :

```text
ERD
+
Data Dictionary
```

constitue une base documentaire extrêmement utile.

---

# 🏗 18. OLTP, analytique et BigQuery : nuance importante

Le cours présente le modèle relationnel car c'est la base conceptuelle des relations entre tables.

Mais il faut distinguer deux familles de systèmes.

## Base transactionnelle

Optimisée pour :

```text
écrire rapidement de petites transactions
modifier des lignes
garantir la cohérence
gérer des opérations métier
```

Exemples d'usage :

```text
passer une commande
modifier une adresse
enregistrer un paiement
```

---

## Data warehouse analytique

Optimisé pour :

```text
lire beaucoup de données
agréger
analyser
croiser plusieurs sources
produire des reporting
```

BigQuery appartient principalement à cette seconde famille.

Cela explique pourquoi certains concepts relationnels sont toujours essentiels, mais que la manière de stocker et d'exécuter les analyses peut être différente d'une base transactionnelle classique.

---

# ☁️ 19. BigQuery : l'environnement SQL utilisé dans le bootcamp

BigQuery est un service de données de Google Cloud.

Pour un Data Analyst, on peut le voir comme :

```text
un endroit où sont stockées de grandes tables
+
un moteur capable d'exécuter des requêtes SQL dessus
```

Le dialecte SQL utilisé est :

```text
GoogleSQL
```

On rencontre également encore l'expression :

```text
Standard SQL
```

dans certains contextes ou anciennes documentations.

---

# 🗂 20. Hiérarchie BigQuery : Project → Dataset → Table

La structure fondamentale est :

```text
Google Cloud Project
        ↓
Dataset
        ↓
Table
```

Exemple :

```text
my-project
└── analytics
    ├── customers
    ├── orders
    └── sales
```

---

## Project

Le projet est le grand conteneur Google Cloud.

Il sert notamment à organiser :

- les ressources ;
- les permissions ;
- les jobs ;
- la facturation.

---

## Dataset

Un dataset regroupe des objets BigQuery liés.

Exemple :

```text
raw
staging
analytics
marketing
finance
```

---

## Table

La table contient les données.

Exemple :

```text
analytics.orders
```

---

# 🧾 21. Le nom complet d'une table BigQuery

On peut rencontrer :

```sql
FROM orders
```

mais dans un environnement réel, on utilise souvent un nom qualifié.

```text
project.dataset.table
```

Exemple :

```sql
SELECT
  order_id
FROM `my-project.analytics.orders`;
```

Les backticks :

```text
` ... `
```

permettent de délimiter l'identifiant complet.

Ce point devient particulièrement important lorsqu'on travaille avec plusieurs projets ou plusieurs datasets.

---

# 👀 22. Explorer une table avant de requêter

Avant d'écrire du SQL, on doit regarder la table.

Dans BigQuery, les onglets d'une table permettent notamment d'inspecter :

```text
Schema
Details
Preview
```

Le **Schema** permet de vérifier :

- noms des colonnes ;
- types ;
- mode / nullabilité selon le contexte ;
- descriptions si elles existent.

Le **Preview** permet d'observer des lignes sans utiliser systématiquement une requête d'exploration.

> 💡 **Bon réflexe :** avant de requêter une table inconnue :
>
> ```text
> 1. lire son nom
> 2. lire son schéma
> 3. lire les descriptions
> 4. regarder quelques lignes
> 5. identifier sa granularité
> 6. identifier ses clés
> ```

---

# 🔌 23. Tables BigQuery natives vs sources externes

Une table BigQuery peut contenir des données stockées directement dans BigQuery.

Mais BigQuery peut aussi interroger certaines données externes.

Dans le cours, un exemple important est une table reliée à Google Sheets.

Conceptuellement :

```text
Google Sheet
      ↓
External table / connexion
      ↓
BigQuery query
```

Si le fichier source change, la donnée visible via la table externe peut évoluer sans qu'une copie physique complète ait nécessairement été importée dans BigQuery.

Il faut donc toujours savoir :

```text
est-ce une table native ?
ou
est-ce une source externe ?
```

---

# 🧑‍💻 24. Le Query Editor

BigQuery permet d'ouvrir plusieurs onglets de requête.

On peut y écrire :

```sql
SELECT
  ...
FROM
  ...
WHERE
  ...;
```

Puis exécuter la requête.

Un raccourci couramment utilisé est :

```text
Ctrl + Entrée
```

ou l'équivalent selon le système / l'éditeur.

La mise en forme automatique de la requête est également utile pour rendre le code plus lisible.

---

# ✍️ 25. Le SQL est insensible à la mise en page… mais les humains ne le sont pas

Cette requête peut être valide :

```sql
SELECT name,surname FROM people WHERE number_of_children>0;
```

Mais on préfère :

```sql
SELECT
  name,
  surname
FROM people
WHERE number_of_children > 0;
```

Pourquoi ?

Parce qu'un code SQL est souvent :

```text
lu beaucoup plus souvent
qu'il n'est écrit
```

La lisibilité est donc une vraie compétence technique.

---

# 💬 26. Commentaires SQL

Pour documenter une requête, on peut utiliser :

```sql
-- Commentaire sur une ligne
SELECT
  customer_id
FROM customers;
```

Ou :

```sql
/*
Commentaire
sur plusieurs lignes
*/
SELECT
  customer_id
FROM customers;
```

Les commentaires deviennent utiles lorsque la requête explique :

- une règle métier ;
- un choix de filtre ;
- une exclusion ;
- une transformation non évidente ;
- une étape d'un pipeline.

Exemple :

```sql
-- Exclure les commandes de test créées par l'équipe interne
WHERE customer_type != 'internal_test'
```

Un bon commentaire explique **pourquoi**.

Éviter :

```sql
-- Filtre sur country
WHERE country = 'FR'
```

Le code le dit déjà.

Préférer :

```sql
-- Le reporting France ne doit contenir que les ventes domestiques
WHERE country = 'FR'
```

---

# 🟦 27. `SELECT` : choisir les colonnes à retourner

Le mot-clé `SELECT` indique les expressions que l'on veut retrouver dans le résultat.

Exemple :

```sql
SELECT
  name,
  surname
FROM people;
```

Résultat :

```text
name      | surname
----------|-----------
Paul      | Mochkovitch
Charlotte | Dupuis
Clara     | Milaux
```

---

# ⭐ 28. `SELECT *`

L'étoile signifie :

```text
toutes les colonnes
```

```sql
SELECT
  *
FROM people;
```

C'est utile pour :

- un premier test rapide ;
- un petit jeu de données ;
- comprendre une table en formation.

Mais ce n'est pas un bon réflexe systématique en production.

Pourquoi ?

Parce que BigQuery est un moteur analytique orienté colonnes.

Plus on lit de colonnes, plus on peut lire de données.

Préférer donc :

```sql
SELECT
  id,
  name,
  birth_date
FROM people;
```

si ce sont les seules colonnes nécessaires.

---

# 💸 29. `SELECT *` et coût BigQuery

Dans un modèle de facturation à la donnée traitée, le volume lu par la requête compte.

BigQuery peut estimer avant exécution le volume de données qu'une requête traitera.

Deux requêtes conceptuellement proches :

```sql
SELECT *
FROM huge_table;
```

et :

```sql
SELECT
  customer_id
FROM huge_table;
```

peuvent donc lire des volumes très différents.

> 💡 **Réflexe :** sélectionner les colonnes utiles est à la fois :
>
> - plus lisible ;
> - plus robuste ;
> - potentiellement plus rapide ;
> - potentiellement moins coûteux.

---

# 🧼 30. `SELECT DISTINCT`

`DISTINCT` supprime les doublons du **résultat sélectionné**.

Exemple :

```sql
SELECT DISTINCT
  name
FROM people;
```

Si `Paul` apparaît cinq fois :

```text
Paul
Paul
Paul
Paul
Paul
```

le résultat ne contiendra qu'une fois :

```text
Paul
```

---

## Attention avec plusieurs colonnes

```sql
SELECT DISTINCT
  name,
  surname
FROM people;
```

Ici, SQL considère le couple :

```text
(name, surname)
```

Deux lignes ne sont doublons que si **les deux valeurs** sont identiques.

Exemple :

```text
Paul Dupuis
Paul Martin
```

ne sont pas des doublons.

> 💡 `DISTINCT` s'applique à la combinaison complète des expressions sélectionnées.

---

# 🏷 31. Alias avec `AS`

Un alias permet de renommer une colonne dans le résultat.

```sql
SELECT
  number_of_children AS nb_children
FROM people;
```

On peut aussi aliaser une expression :

```sql
SELECT
  turnover * 1.2 AS turnover_with_tax
FROM sales;
```

Les alias améliorent :

- la lisibilité ;
- la compréhension métier ;
- la réutilisation dans certaines clauses ;
- la clarté des résultats.

---

# 🧱 32. `FROM` : indiquer la source

`FROM` indique la source principale de la requête.

```sql
SELECT
  name
FROM people;
```

Traduction :

```text
Affiche-moi la colonne name
depuis la table people.
```

Dans les requêtes plus avancées, `FROM` peut contenir :

- une table ;
- plusieurs tables avec `JOIN` ;
- une sous-requête ;
- une CTE ;
- une table externe ;
- une fonction de table.

Mais le principe reste :

```text
FROM = d'où viennent mes lignes ?
```

---

# 🔍 33. `WHERE` : filtrer les lignes

`WHERE` sert à conserver uniquement les lignes qui respectent une condition.

```sql
SELECT
  *
FROM people
WHERE name = 'Clara';
```

Conceptuellement :

```text
table entière
   ↓
test de chaque ligne
   ↓
condition TRUE ?
   ↓
oui → conserver
non → supprimer du résultat
```

Important :

`WHERE` ne supprime pas les lignes de la table source.

Il filtre **le résultat de la requête**.

---

# ⚖️ 34. Opérateurs de comparaison

On rencontre fréquemment :

```text
=
!=
<>
>
>=
<
<=
```

Exemples :

```sql
WHERE number_of_children = 0
```

```sql
WHERE turnover > 100
```

```sql
WHERE birth_date >= DATE '1990-01-01'
```

---

# 📅 35. Dates et littéraux : mieux vaut être explicite

Dans le cours, une date est souvent écrite entre guillemets :

```sql
WHERE birth_date >= '1990-01-01'
```

GoogleSQL peut effectuer certaines conversions implicites selon le contexte.

Mais pour une note de référence durable, il est souvent plus clair d'écrire explicitement :

```sql
WHERE birth_date >= DATE '1990-01-01'
```

Cela indique immédiatement :

```text
ce littéral représente une DATE
```

Dans les chapitres consacrés aux dates, on utilisera également :

```text
DATE()
PARSE_DATE()
CAST()
SAFE_CAST()
```

selon le type source.

---

# 🔤 36. Filtrer du texte avec `LIKE`

`LIKE` permet de comparer une chaîne à un motif simple.

Deux caractères spéciaux sont particulièrement importants :

```text
%  → zéro, un ou plusieurs caractères
_  → exactement un caractère
```

---

## Commence par P

```sql
WHERE name LIKE 'P%'
```

Peut retourner :

```text
Paul
Pauline
Pierre
```

---

## Se termine par a

```sql
WHERE name LIKE '%a'
```

Peut retourner :

```text
Clara
Emma
```

---

## Contient `au`

```sql
WHERE name LIKE '%au%'
```

Peut retourner :

```text
Paul
Pauline
```

---

## Deuxième caractère = `a`

```sql
WHERE name LIKE '_a%'
```

Lecture :

```text
_   → n'importe quel premier caractère
a   → deuxième caractère = a
%   → n'importe quelle suite
```

---

# 🚫 37. `NOT LIKE`

Pour inverser la condition :

```sql
WHERE name NOT LIKE 'P%'
```

On conserve les lignes qui ne correspondent pas au motif.

---

# 🧠 38. `LIKE` n'est pas une regex complète

`LIKE` est volontairement simple.

Il sait surtout gérer :

```text
%
_
```

Pour des motifs plus complexes, BigQuery propose des fonctions `REGEXP_*`.

Exemples vus plus tard :

```text
REGEXP_CONTAINS
REGEXP_EXTRACT
REGEXP_REPLACE
```

Ne pas utiliser une regex si un simple `LIKE` suffit.

La solution la plus simple est souvent la plus lisible.

---

# ➕ 39. Combiner les conditions avec `AND`

`AND` signifie :

```text
condition A
ET
condition B
```

Exemple :

```sql
SELECT
  *
FROM people
WHERE surname = 'Dupuis'
  AND birth_date >= DATE '1990-01-01';
```

La ligne doit satisfaire les deux conditions.

---

# 🔀 40. Combiner les conditions avec `OR`

`OR` signifie :

```text
condition A
OU
condition B
```

```sql
WHERE city = 'Paris'
   OR city = 'Lyon'
```

Une ligne est conservée si au moins une condition est vraie.

---

# ⚠️ 41. Priorité entre `AND` et `OR`

Comme en mathématiques, certaines opérations ont une priorité.

En SQL, `AND` est généralement évalué avant `OR`.

Donc :

```sql
WHERE country = 'FR'
  AND city = 'Paris'
   OR city = 'Lyon'
```

est conceptuellement lu comme :

```text
(country = 'FR' AND city = 'Paris')
OR
city = 'Lyon'
```

Ce qui peut inclure Lyon même hors de France.

Si l'intention métier est :

```text
France
ET
(Paris OU Lyon)
```

il faut écrire :

```sql
WHERE country = 'FR'
  AND (
    city = 'Paris'
    OR city = 'Lyon'
  );
```

> 💡 **Règle :** dès qu'une combinaison `AND` / `OR` devient ambiguë, utiliser des parenthèses.

---

# 📦 42. `IN` : simplifier plusieurs `OR`

Au lieu de :

```sql
WHERE surname = 'Dupuis'
   OR surname = 'Milaux'
   OR surname = 'Hamous'
```

on peut écrire :

```sql
WHERE surname IN ('Dupuis', 'Milaux', 'Hamous')
```

C'est :

- plus compact ;
- plus lisible ;
- plus simple à maintenir.

---

# 🚫 43. `NOT IN`

L'inverse :

```sql
WHERE surname NOT IN ('Dupuis', 'Milaux', 'Hamous')
```

Attention : `NULL` a une logique particulière en SQL.

Il ne faut pas raisonner sur `NULL` comme sur une valeur normale.

---

# 🕳 44. `NULL` : absence de valeur

`NULL` ne signifie pas :

```text
0
```

ni :

```text
''
```

ni :

```text
'NULL'
```

`NULL` signifie :

```text
valeur absente / inconnue / non renseignée
```

Pour tester `NULL`, on écrit :

```sql
WHERE number_of_children IS NULL
```

et non :

```sql
WHERE number_of_children = NULL
```

Pour l'inverse :

```sql
WHERE number_of_children IS NOT NULL
```

---

# 🧠 45. Pourquoi `NULL` rend les conditions surprenantes

Une comparaison SQL peut produire :

```text
TRUE
FALSE
NULL / UNKNOWN
```

Exemple :

```sql
NULL > 3
```

ne vaut pas `FALSE`.

La comparaison est inconnue.

Dans un `WHERE`, seules les lignes dont la condition est `TRUE` sont conservées.

Cela explique de nombreux comportements apparemment étranges.

> 💡 La maîtrise de `NULL` est l'une des premières étapes pour passer d'un SQL « qui marche souvent » à un SQL fiable.

---

# ↕️ 46. `ORDER BY` : trier le résultat

Pour trier :

```sql
SELECT
  name,
  number_of_children
FROM people
ORDER BY number_of_children;
```

Par défaut :

```text
ASC
```

c'est-à-dire ascendant.

On peut l'écrire explicitement :

```sql
ORDER BY number_of_children ASC
```

---

## Descendant

```sql
ORDER BY number_of_children DESC
```

Exemple :

```text
5
3
2
1
0
```

---

# 🪜 47. Tri secondaire

On peut trier selon plusieurs critères.

```sql
ORDER BY
  number_of_children DESC,
  surname ASC
```

Logique :

```text
1. trier d'abord par number_of_children
2. si égalité, trier par surname
```

C'est particulièrement utile pour rendre un résultat déterministe.

---

# ⚠️ 48. Éviter `ORDER BY 2`

On peut parfois voir :

```sql
ORDER BY 2
```

Cela signifie :

```text
trier sur la deuxième expression du SELECT
```

Exemple :

```sql
SELECT
  name,
  number_of_children
FROM people
ORDER BY 2 DESC;
```

Cela fonctionne.

Mais c'est fragile.

Si l'ordre des colonnes change :

```sql
SELECT
  number_of_children,
  name
```

alors `ORDER BY 2` ne signifie plus la même chose.

Préférer :

```sql
ORDER BY number_of_children DESC
```

---

# 🔢 49. `LIMIT` : limiter le nombre de lignes retournées

```sql
SELECT
  *
FROM people
LIMIT 3;
```

Cela retourne au maximum trois lignes.

Très utile pour :

- inspecter rapidement un résultat ;
- tester une requête ;
- afficher un top N après un tri.

Exemple :

```sql
SELECT
  name,
  number_of_children
FROM people
ORDER BY number_of_children DESC
LIMIT 3;
```

Cela correspond à :

```text
Top 3 des personnes ayant le plus d'enfants
```

---

# 💸 50. Piège important : `LIMIT` ne veut pas dire « lire moins de colonnes »

Dans BigQuery, écrire :

```sql
SELECT *
FROM very_large_table
LIMIT 10;
```

ne doit pas être interprété comme :

```text
BigQuery ne lit que 10 lignes
```

`LIMIT` limite surtout le nombre de lignes retournées.

Pour réduire les données lues, les leviers importants sont notamment :

```text
sélectionner seulement les colonnes utiles
+
filtrer efficacement les partitions lorsque la table est partitionnée
+
éviter les lectures inutiles
```

Donc :

```sql
SELECT
  customer_id
FROM very_large_table
LIMIT 10;
```

peut être beaucoup plus raisonnable que :

```sql
SELECT *
FROM very_large_table
LIMIT 10;
```

---

# 🧮 51. Une requête SQL est composée de clauses

Une requête complète peut contenir :

```text
SELECT
FROM
JOIN
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT
```

Puis, plus tard :

```text
WINDOW
QUALIFY
```

Le point essentiel :

> **l'ordre dans lequel on écrit les clauses n'est pas identique à l'ordre logique dans lequel les données sont traitées.**

---

# ✍️ 52. Ordre d'écriture simplifié

Pour les notions vues à ce stade :

```text
SELECT
FROM
JOIN
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT
```

Exemple :

```sql
SELECT
  customer_id,
  SUM(turnover) AS turnover
FROM sales
WHERE country = 'FR'
GROUP BY customer_id
HAVING SUM(turnover) > 100
ORDER BY turnover DESC
LIMIT 10;
```

---

# ⚙️ 53. Ordre logique d'exécution : modèle mental

Un modèle mental pédagogique utile est :

```text
FROM
  ↓
JOIN
  ↓
WHERE
  ↓
GROUP BY + agrégations
  ↓
HAVING
  ↓
SELECT
  ↓
ORDER BY
  ↓
LIMIT
```

Autrement dit :

```text
1. trouver les données
2. construire la table de travail
3. filtrer les lignes
4. grouper / agréger
5. filtrer les groupes
6. calculer les colonnes du résultat
7. trier
8. limiter l'affichage
```

Cette logique explique beaucoup de règles SQL.

---

# 🧠 54. Pourquoi l'ordre d'exécution est important

Supposons :

```sql
SELECT
  price * quantity AS revenue
FROM sales
WHERE revenue > 100;
```

Cela peut poser problème parce que :

```text
WHERE
```

est logiquement évalué avant que l'alias du `SELECT` ne soit disponible.

On peut écrire :

```sql
SELECT
  price * quantity AS revenue
FROM sales
WHERE price * quantity > 100;
```

Ou calculer d'abord dans une CTE / sous-requête.

Cette notion prendra de plus en plus d'importance.

---

# 🪟 55. Ordre BigQuery plus complet — pour la suite du Brocode

Lorsque l'on ajoutera des notions avancées, il faudra intégrer :

```text
FROM
↓
WHERE
↓
GROUP BY + aggregation
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

Ce schéma est plus complet pour BigQuery analytique.

Attention :

> L'ordre **logique** d'évaluation n'est pas forcément l'ordre **physique interne** choisi par l'optimiseur.

Le moteur peut optimiser l'exécution tant que le résultat respecte la sémantique SQL.

---

# 🧪 56. Les expressions peuvent être écrites dans `SELECT`

`SELECT` ne sert pas uniquement à reprendre des colonnes existantes.

On peut y créer de nouvelles expressions.

Exemple :

```sql
SELECT
  price,
  quantity,
  price * quantity AS turnover
FROM sales;
```

La colonne :

```text
turnover
```

n'existe pas forcément dans la table source.

Elle est calculée dans le résultat.

---

# 🧠 57. `IF()` : condition binaire

Dans BigQuery :

```sql
IF(condition, value_if_true, value_if_false)
```

Exemple :

```sql
SELECT
  name,
  number_of_children,
  IF(number_of_children > 0, 1, 0) AS is_parent
FROM people;
```

Résultat possible :

```text
name      | nb_children | is_parent
----------|-------------|----------
Paul      | 0           | 0
Charlotte | 2           | 1
Clara     | 3           | 1
```

`IF()` est pratique lorsqu'il n'y a que deux branches.

---

# 🌳 58. `CASE WHEN` : plusieurs conditions

Structure :

```sql
CASE
  WHEN condition_1 THEN result_1
  WHEN condition_2 THEN result_2
  ELSE result_else
END
```

Exemple :

```sql
SELECT
  name,
  number_of_children,
  CASE
    WHEN number_of_children >= 3 THEN 'Large family'
    WHEN number_of_children >= 1 THEN 'Family'
    WHEN number_of_children = 0 THEN 'No child'
    ELSE 'Unknown'
  END AS family_segment
FROM people;
```

---

# ⚠️ 59. L'ordre des `WHEN` est important

SQL lit les conditions dans l'ordre.

Dès qu'une condition est vraie, le `CASE` retourne le résultat correspondant.

Exemple incorrect :

```sql
CASE
  WHEN score >= 50 THEN 'Pass'
  WHEN score >= 90 THEN 'Excellent'
END
```

Un score de `95` satisfait déjà :

```text
score >= 50
```

Il sera donc classé `Pass`.

Il faut écrire :

```sql
CASE
  WHEN score >= 90 THEN 'Excellent'
  WHEN score >= 50 THEN 'Pass'
  ELSE 'Fail'
END
```

> 💡 Pour des seuils imbriqués : traiter souvent du plus restrictif au plus général.

---

# 🕳 60. `CASE`, `IF` et `NULL`

Si :

```text
number_of_children = NULL
```

alors :

```sql
number_of_children > 0
```

ne vaut pas `TRUE`.

Dans :

```sql
IF(number_of_children > 0, 1, 0)
```

un `NULL` peut donc se retrouver dans la branche alternative selon la fonction et le contexte.

Si `NULL` a une signification métier importante, le gérer explicitement :

```sql
CASE
  WHEN number_of_children IS NULL THEN 'Unknown'
  WHEN number_of_children = 0 THEN 'No child'
  ELSE 'Parent'
END
```

---

# 🔢 61. `ROUND()`

`ROUND` permet d'arrondir une valeur numérique.

```sql
SELECT
  price,
  ROUND(price, 2) AS price_rounded
FROM products;
```

Exemple :

```text
1.64827
↓
1.65
```

Important :

`ROUND` modifie la valeur retournée par l'expression.

Il ne change pas forcément le **type conceptuel** de la colonne en entier.

Si on veut simplement afficher moins de décimales, `ROUND` est généralement plus adapté que convertir arbitrairement en `INT64`.

---

# 🧩 62. Les types de données

Une base SQL distingue les types.

Principaux types BigQuery à connaître :

```text
NUMERIC
├── INT64
├── FLOAT64
├── NUMERIC
└── BIGNUMERIC

BOOLEAN
└── BOOL

TEXT
├── STRING
└── BYTES

TEMPORAL
├── DATE
├── TIME
├── DATETIME
└── TIMESTAMP

COMPLEX
├── ARRAY
├── STRUCT
├── JSON
├── GEOGRAPHY
└── RANGE
```

Pour l'introduction, on se concentre surtout sur :

```text
INT64
FLOAT64
NUMERIC
BOOL
STRING
DATE
DATETIME
TIMESTAMP
```

---

# 🔢 63. `INT64`

`INT64` représente un entier.

Exemples :

```text
0
1
-12
45000
```

Usages fréquents :

- identifiants numériques ;
- comptages ;
- quantités entières.

Exemple :

```text
number_of_children
```

---

# 📐 64. `FLOAT64`

`FLOAT64` représente un nombre à virgule flottante.

Exemples :

```text
1.5
3.14159
-0.25
```

Important :

```text
FLOAT64 = représentation approximative
```

Il peut donc exister de petites limites de précision inhérentes aux nombres flottants.

Pour des besoins de décimaux exacts, on préfère selon le cas :

```text
NUMERIC
BIGNUMERIC
```

---

# 💰 65. `NUMERIC`

`NUMERIC` représente un décimal exact dans sa plage de précision.

C'est souvent plus approprié pour des valeurs où l'exactitude décimale est importante.

Exemples :

```text
montants financiers
prix
ratios nécessitant une précision contrôlée
```

---

# ✅ 66. `BOOL`

Un booléen représente :

```text
TRUE
FALSE
```

Exemple :

```text
is_customer
is_active
has_subscription
```

Éviter de stocker inutilement :

```text
'yes'
'no'
```

si un booléen suffit.

---

# 🔤 67. `STRING`

`STRING` représente du texte.

Exemples :

```text
'Paris'
'FR'
'Emma'
'ABC-123'
```

Attention :

un nombre stocké comme `STRING` reste du texte.

```text
'100'
```

n'est pas conceptuellement identique à :

```text
100
```

Cela a des conséquences sur :

- calculs ;
- comparaisons ;
- tri ;
- fonctions disponibles.

---

# 📅 68. `DATE`, `TIME`, `DATETIME`, `TIMESTAMP`

Présentation rapide :

```text
DATE
→ date civile
→ 2026-07-10
```

```text
TIME
→ heure sans date
→ 09:30:00
```

```text
DATETIME
→ date + heure civile sans fuseau intégré
→ 2026-07-10 09:30:00
```

```text
TIMESTAMP
→ instant absolu dans le temps
```

Ces notions seront approfondies dans le chapitre Date & Time.

---

# 🧠 69. Pourquoi le type de donnée est si important

Le bon type influence au moins quatre choses.

## 1. Les fonctions disponibles

```text
STRING → LOWER, CONCAT, REGEXP...
DATE   → DATE_DIFF, EXTRACT...
NUMERIC → SUM, ROUND...
```

---

## 2. Les comparaisons

```text
100 > 20
```

est une comparaison numérique.

Mais :

```text
'100' > '20'
```

est une comparaison de chaînes, donc la logique peut être différente.

---

## 3. Le tri

Un tri texte n'est pas un tri numérique.

---

## 4. Le stockage et l'exécution

Les systèmes analytiques utilisent le type pour organiser, lire et traiter les données efficacement.

> 💡 **Réflexe :** avant de « réparer » une valeur avec une fonction, vérifier d'abord le type dans le schema BigQuery.

---

# 🔄 70. `CAST()` : convertir explicitement un type

Syntaxe :

```sql
CAST(expression AS target_type)
```

Exemple :

```sql
SELECT
  CAST(id AS INT64) AS id
FROM raw_people;
```

Autre exemple :

```sql
SELECT
  CAST(birth_date AS DATE) AS birth_date
FROM raw_people;
```

Mais la conversion doit être valide.

Si une chaîne contient :

```text
'apple'
```

on ne peut pas la convertir correctement en entier.

---

# 🛡 71. `SAFE_CAST()`

`SAFE_CAST` fonctionne comme `CAST`, mais lorsqu'une conversion échoue à l'exécution, il peut retourner :

```text
NULL
```

au lieu de faire échouer la requête.

Exemple :

```sql
SELECT
  SAFE_CAST(raw_price AS NUMERIC) AS price_clean
FROM raw_products;
```

Avec :

```text
raw_price
---------
12.5
8.2
unknown
14.0
```

on pourrait obtenir :

```text
price_clean
-----------
12.5
8.2
NULL
14.0
```

---

# ⚠️ 72. Pourquoi `SAFE_CAST` peut masquer des problèmes

`SAFE_CAST` est pratique.

Mais :

```text
erreur de donnée
↓
SAFE_CAST
↓
NULL
```

peut cacher un problème de qualité.

Avant d'accepter des `NULL`, il faut comprendre :

```text
combien de valeurs échouent ?
pourquoi ?
peut-on les corriger ?
sont-elles perdues ?
```

Pattern de contrôle :

```sql
SELECT
  raw_price,
  SAFE_CAST(raw_price AS NUMERIC) AS price_clean
FROM raw_products
WHERE raw_price IS NOT NULL
  AND SAFE_CAST(raw_price AS NUMERIC) IS NULL;
```

Cette requête cherche les valeurs non nulles qui ne sont pas convertibles.

---

# 🧹 73. Pattern de nettoyage : brut → propre → analytique

Une architecture saine ressemble souvent à :

```text
RAW
donnée source
   ↓
STAGING / CLEAN
types corrigés
valeurs nettoyées
noms harmonisés
   ↓
ANALYTICS
agrégations
métriques
tables métier
   ↓
REPORTING
dashboard
analyse
```

L'idée n'est pas de modifier constamment la donnée brute.

On construit des couches.

---

# 🛑 74. `SELECT` ne modifie pas la table source

C'est un point essentiel du cours.

Cette requête :

```sql
SELECT
  name,
  UPPER(surname) AS surname
FROM people;
```

ne transforme pas définitivement la colonne `surname` dans `people`.

Elle produit simplement un résultat.

Conceptuellement :

```text
TABLE SOURCE
     │
     │ lecture
     ▼
   SELECT
     │
     ▼
RÉSULTAT TEMPORAIRE
```

La donnée brute reste inchangée.

---

# 💾 75. Comment persister le résultat d'une requête ?

Si l'on veut conserver le résultat, plusieurs approches existent.

## Nouvelle table

On matérialise les résultats.

```text
raw_people
↓
query
↓
clean_people
```

---

## View

Une vue stocke essentiellement une définition de requête.

Quand elle est interrogée, la logique est réévaluée sur ses sources.

---

## Scheduled Query

Une requête peut être exécutée automatiquement selon une planification et écrire dans une table destination.

Exemple :

```text
Tous les jours à 07:00
     ↓
exécuter la transformation
     ↓
mettre à jour analytics.daily_sales
```

Ces mécanismes seront approfondis plus tard.

---

# ♻️ 76. Query cache

BigQuery peut réutiliser le résultat de certaines requêtes identiques grâce à un cache.

Conceptuellement :

```text
requête exécutée
   ↓
résultat calculé
   ↓
résultat mis en cache
```

Si la même requête est relancée dans des conditions compatibles :

```text
même requête
   ↓
cache disponible
   ↓
résultat récupéré plus rapidement
```

Cela peut éviter un nouveau calcul et, selon les conditions du cache, éviter une nouvelle facturation de la requête.

Ne jamais cependant construire un pipeline métier critique en supposant que le cache est une table permanente.

---

# 📏 77. Estimation des bytes avant exécution

BigQuery peut afficher une estimation du volume que la requête devrait traiter.

C'est un réflexe extrêmement utile sur les grosses tables.

Avant d'exécuter :

```sql
SELECT *
FROM huge_table;
```

regarder :

```text
This query will process ...
```

Si le volume est beaucoup plus grand que prévu :

```text
STOP
↓
comprendre pourquoi
↓
sélectionner moins de colonnes
↓
ajouter les bons filtres
↓
retester
```

---

# 🧪 78. Preview plutôt que `SELECT *` pour simplement regarder une table

Pour découvrir une table, on peut utiliser la fonction Preview de l'interface.

Pourquoi ?

Parce que l'intention est :

```text
voir quelques exemples
```

et non :

```text
scanner toutes les colonnes avec une requête analytique
```

Le bon outil dépend de l'objectif.

---

# 💡 79. SQL : déclaratif, pas impératif

Dans un langage impératif, on décrit souvent **comment** faire étape par étape.

En SQL, on décrit surtout **le résultat souhaité**.

Exemple :

```sql
SELECT
  name
FROM people
WHERE number_of_children > 0;
```

On ne dit pas :

```text
boucle sur la ligne 1
teste la cellule
puis ligne 2
puis ligne 3
...
```

On dit :

```text
Je veux les noms
des personnes
ayant plus de zéro enfant.
```

Le moteur choisit ensuite une stratégie d'exécution.

---

# 🧠 80. Lire une requête en français

Prenons :

```sql
SELECT
  name,
  surname,
  number_of_children
FROM people
WHERE number_of_children > 0
ORDER BY number_of_children DESC
LIMIT 3;
```

Lecture :

```text
SELECT
→ affiche le nom, le prénom et le nombre d'enfants

FROM people
→ depuis la table people

WHERE number_of_children > 0
→ uniquement pour les personnes ayant au moins un enfant

ORDER BY number_of_children DESC
→ de celle qui en a le plus à celle qui en a le moins

LIMIT 3
→ et ne garde que les trois premières
```

Savoir verbaliser une requête est un excellent moyen de vérifier sa logique.

---

# 🧩 81. Une requête plus complète avec colonnes calculées

```sql
SELECT
  id,
  name,
  surname,
  birth_date,
  number_of_children,

  IF(
    number_of_children > 0,
    TRUE,
    FALSE
  ) AS is_parent,

  CASE
    WHEN number_of_children IS NULL THEN 'Unknown'
    WHEN number_of_children >= 3 THEN 'Large family'
    WHEN number_of_children >= 1 THEN 'Family'
    ELSE 'No child'
  END AS family_segment

FROM people

WHERE birth_date >= DATE '1980-01-01'

ORDER BY
  number_of_children DESC,
  surname ASC

LIMIT 10;
```

Cette seule requête mobilise déjà :

```text
SELECT
alias
IF
CASE WHEN
NULL
FROM
WHERE
DATE literal
ORDER BY
tri secondaire
LIMIT
```

---

# 🧹 82. Formatage recommandé

Préférer :

```sql
SELECT
  id,
  name,
  surname,
  number_of_children,
  CASE
    WHEN number_of_children >= 3 THEN 'Large family'
    WHEN number_of_children >= 1 THEN 'Family'
    ELSE 'No child'
  END AS family_segment
FROM people
WHERE birth_date >= DATE '1980-01-01'
ORDER BY number_of_children DESC
LIMIT 10;
```

plutôt que :

```sql
SELECT id,name,surname,number_of_children,CASE WHEN number_of_children>=3 THEN 'Large family' WHEN number_of_children>=1 THEN 'Family' ELSE 'No child' END AS family_segment FROM people WHERE birth_date>=DATE '1980-01-01' ORDER BY number_of_children DESC LIMIT 10;
```

Même résultat.

Pas la même maintenabilité.

---

# 🔧 83. Déboguer une requête SQL : méthode simple

Lorsqu'une requête ne fonctionne pas, éviter de modifier dix choses au hasard.

Procéder par couches.

## Étape 1 — la table existe-t-elle ?

```sql
SELECT
  *
FROM `project.dataset.table`
LIMIT 10;
```

---

## Étape 2 — les colonnes existent-elles ?

```sql
SELECT
  id,
  name
FROM `project.dataset.table`
LIMIT 10;
```

---

## Étape 3 — le filtre fonctionne-t-il ?

```sql
SELECT
  id,
  name
FROM `project.dataset.table`
WHERE name = 'Paul'
LIMIT 10;
```

---

## Étape 4 — ajouter les expressions

```sql
SELECT
  id,
  name,
  SAFE_CAST(raw_value AS NUMERIC) AS value_clean
FROM `project.dataset.table`;
```

---

## Étape 5 — contrôler les valeurs qui posent problème

```sql
SELECT
  raw_value
FROM `project.dataset.table`
WHERE raw_value IS NOT NULL
  AND SAFE_CAST(raw_value AS NUMERIC) IS NULL;
```

> 💡 Déboguer SQL revient souvent à réduire progressivement la requête jusqu'à trouver la première hypothèse fausse.

---

# 🚨 84. Erreurs classiques du débutant

## Erreur 1 — oublier une virgule

```sql
SELECT
  name
  surname
FROM people;
```

Au lieu de :

```sql
SELECT
  name,
  surname
FROM people;
```

---

## Erreur 2 — oublier les quotes autour d'un texte

```sql
WHERE name = Paul
```

Au lieu de :

```sql
WHERE name = 'Paul'
```

---

## Erreur 3 — confondre valeur texte et nom de colonne

```sql
WHERE country = FR
```

SQL peut interpréter `FR` comme un identifiant.

Il faut :

```sql
WHERE country = 'FR'
```

---

## Erreur 4 — tester `NULL` avec `=`

Incorrect :

```sql
WHERE price = NULL
```

Correct :

```sql
WHERE price IS NULL
```

---

## Erreur 5 — oublier les parenthèses avec `AND` / `OR`

Toujours rendre la logique explicite.

---

## Erreur 6 — utiliser `SELECT *` partout

Cela devient vite coûteux, peu lisible et fragile.

---

## Erreur 7 — utiliser `SAFE_CAST` sans inspecter les erreurs

Les valeurs invalides deviennent silencieusement `NULL`.

---

## Erreur 8 — supposer que l'ordre des lignes est garanti

Sans :

```sql
ORDER BY
```

l'ordre du résultat n'est pas à considérer comme garanti.

---

## Erreur 9 — confondre filtrer et transformer

```sql
WHERE
```

filtre les lignes.

```sql
CASE
```

crée une valeur calculée.

Ce n'est pas la même opération.

---

# 🧭 85. `WHERE` vs `CASE WHEN`

Question :

> Je veux uniquement les clients avec enfants.

Utiliser :

```sql
WHERE number_of_children > 0
```

---

Question :

> Je veux garder tous les clients et créer une catégorie parent / non-parent.

Utiliser :

```sql
CASE
  WHEN number_of_children > 0 THEN 'Parent'
  ELSE 'No child'
END
```

Différence :

```text
WHERE
→ enlève des lignes du résultat

CASE
→ conserve les lignes et crée / transforme une valeur
```

---

# 🧠 86. `SELECT`, `WHERE`, `ORDER BY`, `LIMIT` : quatre rôles à ne jamais confondre

```text
SELECT
→ quelles colonnes / expressions afficher ?
```

```text
WHERE
→ quelles lignes conserver ?
```

```text
ORDER BY
→ dans quel ordre afficher les lignes ?
```

```text
LIMIT
→ combien de lignes retourner ?
```

On peut résumer :

```text
SELECT  = colonnes
WHERE   = lignes
ORDER BY = ordre
LIMIT   = quantité affichée
```

---

# 🧮 87. Colonnes existantes vs colonnes calculées

Dans :

```sql
SELECT
  price,
  quantity,
  price * quantity AS turnover
FROM sales;
```

`price` :

```text
colonne source
```

`quantity` :

```text
colonne source
```

`turnover` :

```text
colonne calculée du résultat
```

Cette distinction deviendra essentielle pour :

- les alias ;
- les CTEs ;
- les Window Functions ;
- les tables intermédiaires.

---

# 🧱 88. Le pipeline analytique comme succession de tables logiques

Un Data Analyst ne doit pas penser :

```text
je modifie une feuille
```

mais plutôt :

```text
source
↓
transformation
↓
nouveau résultat
↓
nouvelle transformation
↓
résultat analytique
```

Exemple :

```text
raw_orders
    ↓
clean_orders
    ↓
orders_with_margin
    ↓
daily_sales
    ↓
dashboard
```

SQL devient beaucoup plus simple lorsqu'on raisonne par étapes.

---

# 🔄 89. Query enregistrée, vue et table : différence conceptuelle

## Saved Query

```text
du code SQL enregistré
```

Le code existe indépendamment du résultat.

---

## View

```text
une requête enregistrée exposée comme un objet requêtable
```

Elle représente une logique.

---

## Table

```text
des données matérialisées / stockées
```

Le résultat existe physiquement comme table BigQuery.

---

## Scheduled Query

```text
du SQL exécuté automatiquement selon une fréquence
```

Elle peut alimenter une table de destination.

---

# 🧠 90. Un des grands changements de mentalité par rapport à Sheets

Dans Sheets, on pense souvent :

```text
cellule
formule
cellule
formule
```

En SQL, il faut penser :

```text
colonne
expression
ensemble de lignes
```

Exemple Sheets :

```text
=C2*D2
```

puis recopier.

En SQL :

```sql
SELECT
  price * quantity AS turnover
FROM sales;
```

La même logique s'applique à toutes les lignes.

---

# 📚 91. Convention de nommage

Quelques bonnes pratiques :

```text
snake_case
```

Exemples :

```text
customer_id
birth_date
number_of_children
total_turnover
```

Éviter autant que possible :

```text
Customer ID Final v2
birthDate!!!!
Revenue € Final
```

Un bon nom doit être :

- court ;
- explicite ;
- cohérent ;
- stable.

---

# 🏷 92. Alias de table — aperçu

Les alias de table seront surtout utiles avec les jointures.

Exemple :

```sql
SELECT
  o.order_id,
  c.customer_name
FROM orders AS o
JOIN customers AS c
  ON o.customer_id = c.customer_id;
```

Ici :

```text
o = orders
c = customers
```

Ils permettent d'éviter :

```sql
orders.order_id
customers.customer_name
```

partout dans les grosses requêtes.

---

# ⚠️ 93. Alias : privilégier la lisibilité

Alias utiles :

```text
o  → orders
c  → customers
p  → products
```

Mais éviter des alias impossibles à comprendre :

```text
x1
z
abc42
```

dans une requête métier complexe.

Le but n'est pas de gagner trois caractères.

Le but est d'améliorer la lecture.

---

# 🧮 94. Les fonctions sont des expressions

Une fonction SQL prend des entrées et retourne une valeur.

Exemple :

```sql
ROUND(price, 2)
```

Entrée :

```text
price
```

Résultat :

```text
valeur arrondie
```

Exemple :

```sql
SAFE_CAST(raw_price AS NUMERIC)
```

Entrée :

```text
raw_price
```

Résultat :

```text
NUMERIC ou NULL
```

Exemple :

```sql
IF(number_of_children > 0, 1, 0)
```

Résultat :

```text
1 ou 0
```

---

# 🧠 95. Une colonne du `SELECT` peut être presque n'importe quelle expression

Exemples :

```sql
SELECT
  price
FROM products;
```

```sql
SELECT
  price * quantity AS turnover
FROM sales;
```

```sql
SELECT
  ROUND(price, 2) AS price
FROM products;
```

```sql
SELECT
  CASE
    WHEN price > 100 THEN 'premium'
    ELSE 'standard'
  END AS price_segment
FROM products;
```

Le `SELECT` décrit donc réellement les **valeurs que l'on veut produire**.

---

# 🧪 96. Pattern : explorer proprement une nouvelle table

Lorsque tu découvres une table :

## 1. Regarder le schema

Chercher :

```text
colonnes
types
description
```

---

## 2. Identifier la granularité

```text
1 ligne = ?
```

---

## 3. Identifier la clé

```text
quelle colonne devrait être unique ?
```

---

## 4. Preview

Observer quelques lignes.

---

## 5. Sélection explicite

```sql
SELECT
  key_column,
  important_column_1,
  important_column_2
FROM `project.dataset.table`
LIMIT 100;
```

---

## 6. Vérifier les `NULL`

```sql
SELECT
  COUNT(*) AS nb_rows,
  COUNT(key_column) AS nb_non_null_keys
FROM `project.dataset.table`;
```

---

# 🧪 97. Pattern : vérifier l'unicité d'une clé

```sql
SELECT
  customer_id,
  COUNT(*) AS nb_rows
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
```

Résultat vide :

```text
bon signe
```

Résultat non vide :

```text
customer_id n'est pas unique
ou
les données ne respectent pas le modèle attendu
```

Cette vérification deviendra essentielle avant les `JOIN`.

---

# 🧪 98. Pattern : contrôler les valeurs d'une catégorie

```sql
SELECT DISTINCT
  country
FROM customers
ORDER BY country;
```

Cela permet de découvrir :

```text
FR
France
fr
FRA
NULL
```

et donc de détecter un problème de normalisation.

---

# 🧪 99. Pattern : trouver les valeurs qui ne se castent pas

```sql
SELECT DISTINCT
  raw_price
FROM raw_products
WHERE raw_price IS NOT NULL
  AND SAFE_CAST(raw_price AS NUMERIC) IS NULL;
```

Très utile dans une étape de nettoyage.

---

# 🧪 100. Pattern : Top N

```sql
SELECT
  product_name,
  turnover
FROM products
ORDER BY turnover DESC
LIMIT 10;
```

Pattern mental :

```text
SELECT
↓
ORDER BY DESC
↓
LIMIT
```

---

# 🧪 101. Pattern : segmentation simple

```sql
SELECT
  customer_id,
  CASE
    WHEN turnover >= 1000 THEN 'High value'
    WHEN turnover >= 300 THEN 'Medium value'
    ELSE 'Low value'
  END AS customer_segment
FROM customers;
```

---

# ⚠️ 102. Une bonne requête peut produire un mauvais résultat métier

SQL peut être :

```text
syntaxiquement valide
```

mais :

```text
métierement faux
```

Exemple :

```sql
WHERE order_status = 'paid'
```

est techniquement valide.

Mais si l'entreprise considère aussi :

```text
'completed'
```

comme chiffre d'affaires réalisé, la logique est incorrecte.

> 💡 SQL ne remplace jamais la compréhension métier.

---

# 🧠 103. Les trois niveaux de validation d'une requête

## Niveau 1 — syntaxe

```text
Est-ce que SQL s'exécute ?
```

---

## Niveau 2 — données

```text
Est-ce que les types, les clés et les valeurs sont cohérents ?
```

---

## Niveau 3 — métier

```text
Est-ce que ce calcul répond vraiment à la question ?
```

Une requête professionnelle doit passer les trois.

---

# 🔐 104. Lecture vs modification : ne pas tout mettre dans la même catégorie

Dans ce chapitre, on travaille surtout avec des requêtes de lecture :

```text
SELECT
```

Mais SQL comprend également des instructions capables de modifier ou créer des objets :

```text
CREATE
INSERT
UPDATE
DELETE
MERGE
DROP
```

Elles n'ont pas la même conséquence.

Un `SELECT` n'est donc pas équivalent à :

```sql
DELETE FROM table;
```

> 💡 Avant d'utiliser une instruction de modification en production, comprendre précisément sa portée.

---

# 🧠 105. Pourquoi on conserve généralement la donnée brute

La donnée brute sert de référence.

Si on l'écrase trop tôt :

```text
erreur de nettoyage
↓
source originale perdue
↓
difficile de revenir en arrière
```

On préfère :

```text
RAW
↓
CLEAN
↓
MART / ANALYTICS
```

Cela améliore :

- auditabilité ;
- reproductibilité ;
- débogage ;
- maintenance.

---

# ⚡ 106. BigQuery est columnar : intuition essentielle

BigQuery stocke et lit efficacement les données par colonnes pour les usages analytiques.

Intuition :

Table :

```text
id | name | city | revenue | date | ...
```

Si la requête demande seulement :

```sql
SELECT
  revenue
FROM sales;
```

le moteur peut se concentrer sur la colonne utile.

C'est l'une des raisons pour lesquelles :

```sql
SELECT *
```

est souvent inutilement large.

---

# 💰 107. Coût BigQuery : ne mémorise pas un prix, mémorise le modèle

Les tarifs exacts peuvent évoluer.

Le bon modèle mental durable est :

```text
BigQuery peut facturer selon :
- capacité de calcul réservée / consommée
ou
- volume de données traité selon le mode choisi
```

Pour le Data Analyst débutant, le réflexe pratique est :

```text
combien de données ma requête va-t-elle lire ?
```

et non :

```text
combien de lignes vais-je afficher ?
```

---

# 🧠 108. `LIMIT 10` n'est pas une optimisation universelle

Cette confusion mérite d'être répétée.

```sql
SELECT *
FROM big_table
LIMIT 10;
```

ne signifie pas nécessairement :

```text
je ne paie / traite que 10 lignes
```

Le moteur doit souvent lire les colonnes nécessaires avant de savoir quels résultats produire.

Pour explorer :

```text
Preview
```

Pour optimiser :

```text
projection de colonnes
partition pruning
bons filtres
bonne modélisation
```

---

# 🧰 109. Mini cheat sheet — SQL de base

## Sélectionner toutes les colonnes

```sql
SELECT
  *
FROM table_name;
```

---

## Sélectionner certaines colonnes

```sql
SELECT
  column_1,
  column_2
FROM table_name;
```

---

## Valeurs distinctes

```sql
SELECT DISTINCT
  column_name
FROM table_name;
```

---

## Alias

```sql
SELECT
  column_name AS new_name
FROM table_name;
```

---

## Filtre

```sql
SELECT
  *
FROM table_name
WHERE condition;
```

---

## Plusieurs conditions

```sql
WHERE condition_1
  AND condition_2
```

```sql
WHERE condition_1
   OR condition_2
```

---

## Liste

```sql
WHERE column_name IN ('A', 'B', 'C')
```

---

## Recherche texte

```sql
WHERE column_name LIKE 'A%'
```

---

## NULL

```sql
WHERE column_name IS NULL
```

---

## Tri

```sql
ORDER BY column_name DESC
```

---

## Limite

```sql
LIMIT 10
```

---

## IF

```sql
IF(condition, value_true, value_false)
```

---

## CASE

```sql
CASE
  WHEN condition THEN result
  ELSE result
END
```

---

## CAST

```sql
CAST(value AS INT64)
```

---

## SAFE_CAST

```sql
SAFE_CAST(value AS NUMERIC)
```

---

# 🧭 110. Arbre de décision — quel outil utiliser ?

```text
Je veux choisir des colonnes
→ SELECT
```

```text
Je veux choisir des lignes
→ WHERE
```

```text
Je veux chercher un motif textuel simple
→ LIKE
```

```text
Je veux tester plusieurs valeurs possibles
→ IN
```

```text
Je veux gérer l'absence de valeur
→ IS NULL / IS NOT NULL
```

```text
Je veux créer deux résultats possibles
→ IF
```

```text
Je veux créer plusieurs catégories
→ CASE WHEN
```

```text
Je veux convertir le type
→ CAST
```

```text
Je veux convertir sans faire échouer la requête sur certaines valeurs invalides
→ SAFE_CAST
```

```text
Je veux trier
→ ORDER BY
```

```text
Je veux seulement les N premiers résultats après le tri
→ LIMIT
```

---

# 🧭 111. Arbre de décision — avant d'écrire une requête

```text
Quelle question métier ?
        ↓
Quelle table contient l'information ?
        ↓
1 ligne = quoi dans cette table ?
        ↓
Quel est le type des colonnes ?
        ↓
Quelles colonnes ai-je réellement besoin de lire ?
        ↓
Quels filtres appliquer ?
        ↓
Ai-je besoin de transformer / segmenter ?
        ↓
Ai-je besoin de trier ?
        ↓
Ai-je besoin de limiter l'affichage ?
        ↓
Comment vais-je vérifier le résultat ?
```

---

# ✅ 112. Checklist avant d'exécuter une requête

- [ ] Je sais dans quel **project** je travaille.
- [ ] Je sais dans quel **dataset** se trouve ma table.
- [ ] J'ai vérifié le **schema**.
- [ ] Je sais ce que représente **une ligne**.
- [ ] J'ai identifié la ou les clés importantes.
- [ ] Je connais les types des colonnes utilisées.
- [ ] J'évite `SELECT *` si je n'en ai pas besoin.
- [ ] Mes chaînes de caractères sont correctement délimitées.
- [ ] Mes conditions `AND` / `OR` sont explicites.
- [ ] Mes `NULL` sont gérés correctement.
- [ ] Je regarde le volume estimé si la table est grosse.
- [ ] Je comprends ce que la requête doit retourner avant de cliquer sur Run.

---

# ✅ 113. Checklist après exécution

- [ ] Le nombre de lignes paraît-il plausible ?
- [ ] Les colonnes ont-elles le type attendu ?
- [ ] Les valeurs semblent-elles cohérentes ?
- [ ] Les `NULL` sont-ils attendus ?
- [ ] Le tri correspond-il à mon intention ?
- [ ] Mon `DISTINCT` a-t-il réellement supprimé ce que je pensais ?
- [ ] Les catégories créées par `CASE` couvrent-elles tous les cas ?
- [ ] Ai-je involontairement perdu des lignes ?
- [ ] La requête répond-elle à la question métier ?
- [ ] Le résultat doit-il rester temporaire ou être matérialisé ?

---

# 🎯 114. Les 15 réflexes à ancrer dès ce premier cours

1. **Toujours savoir ce qu'une ligne représente.**
2. **Lire le schema avant d'écrire la requête.**
3. **Comprendre les Primary Keys et Foreign Keys.**
4. **Consulter l'ERD avant les jointures.**
5. **Sélectionner les colonnes utiles plutôt que `*`.**
6. **Utiliser `WHERE` pour filtrer des lignes.**
7. **Utiliser des parenthèses avec `AND` / `OR` dès que la logique est complexe.**
8. **Utiliser `IN` pour une liste de valeurs.**
9. **Tester `NULL` avec `IS NULL`.**
10. **Utiliser `CASE` pour créer des catégories.**
11. **Vérifier les types avant d'utiliser des fonctions.**
12. **Utiliser `SAFE_CAST` comme outil de contrôle, pas comme cache-misère.**
13. **Ne pas supposer que `LIMIT` réduit automatiquement la donnée scannée.**
14. **Ne pas considérer un résultat correct visuellement comme une preuve suffisante.**
15. **Toujours distinguer syntaxe correcte, donnée correcte et logique métier correcte.**

---

# 🧠 115. Le modèle mental final de ce chapitre

```text
                    ┌─────────────────────────────┐
                    │        QUESTION MÉTIER      │
                    └──────────────┬──────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │       MODÈLE DE DONNÉES     │
                    │ ERD / PK / FK / cardinalité │
                    └──────────────┬──────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │          BIGQUERY           │
                    │ Project → Dataset → Table   │
                    └──────────────┬──────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │         GRANULARITÉ         │
                    │      1 ligne = quoi ?       │
                    └──────────────┬──────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │          TYPES              │
                    │ STRING / INT / DATE / ...   │
                    └──────────────┬──────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │           SQL               │
                    │ SELECT / FROM / WHERE       │
                    │ CASE / ORDER BY / LIMIT     │
                    └──────────────┬──────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │         CONTRÔLES           │
                    │ lignes / NULL / types / coût│
                    └──────────────┬──────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │       RÉSULTAT FIABLE       │
                    └─────────────────────────────┘
```

---

# 🏁 116. Résumé ultra-condensé

## Base relationnelle

```text
plusieurs tables
+
relations entre les tables
+
clés
```

---

## Primary Key

```text
identifie une ligne de manière unique
```

---

## Foreign Key

```text
référence une autre entité / table
```

---

## ERD

```text
carte du modèle de données
```

---

## Cardinalité

```text
1:1
1:N
N:N
+
optionalité 0 / 1 / plusieurs
```

---

## BigQuery

```text
Project
→ Dataset
→ Table
```

---

## `SELECT`

```text
quelles valeurs produire ?
```

---

## `FROM`

```text
d'où viennent les lignes ?
```

---

## `WHERE`

```text
quelles lignes conserver ?
```

---

## `ORDER BY`

```text
dans quel ordre ?
```

---

## `LIMIT`

```text
combien de lignes retourner ?
```

---

## `CASE WHEN`

```text
créer une logique conditionnelle
```

---

## `CAST`

```text
changer explicitement de type
```

---

## `SAFE_CAST`

```text
conversion tolérante aux erreurs d'exécution
→ peut produire NULL
```

---

## Réflexe principal

```text
Avant le SQL :
comprendre la donnée.

Après le SQL :
tester le résultat.
```

---

# 📌 117. Passerelle vers les prochains chapitres

Ce chapitre pose les fondations.

La suite du Brocode approfondira progressivement :

```text
Introduction SQL
     ↓
Aggregations + String + Date & Time
     ↓
JOINs + Testing
     ↓
CTEs + Subqueries + UNION
     ↓
UDFs + Window Functions
```

Les concepts appris ici continueront d'apparaître partout :

```text
granularité
types
ordre des clauses
NULL
clés
cardinalité
lisibilité
contrôle des résultats
```

Ils ne sont donc pas « seulement les bases ».

Ils constituent le **socle de presque tout le SQL analytique**.

---

# 📚 118. Notes de validation technique — BigQuery / GoogleSQL

Pour faire de ce chapitre une référence durable, plusieurs points du cours ont été volontairement reformulés ou précisés :

- `Structured Query Language` est le nom complet de SQL.
- BigQuery est avant tout une plateforme analytique / data warehouse, même si les concepts relationnels restent fondamentaux.
- Les contraintes de Primary Key / Foreign Key BigQuery existent mais ne doivent pas être considérées comme des contraintes automatiquement appliquées à la donnée.
- `SELECT *` doit être évité lorsqu'on n'a pas besoin de toutes les colonnes.
- `LIMIT` ne réduit pas automatiquement la quantité de données lue par une requête.
- BigQuery peut fournir une estimation des bytes traités avant exécution.
- Les résultats de requêtes peuvent être mis en cache dans certaines conditions.
- `CAST` peut échouer ; `SAFE_CAST` remplace certains échecs d'exécution par `NULL`.
- Le type booléen BigQuery de référence est `BOOL`.
- L'ordre logique d'évaluation peut différer de l'ordre d'écriture ; les chapitres avancés ajouteront notamment `WINDOW` et `QUALIFY`.

Ces précisions ne changent pas les objectifs pédagogiques du cours : elles rendent simplement le chapitre plus robuste comme document de référence long terme.
