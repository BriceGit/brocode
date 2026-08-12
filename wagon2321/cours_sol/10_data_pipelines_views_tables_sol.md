---
title: "Data Pipelines, Views, Tables & BigQuery Performance"
aliases:
  - "Data Pipelines"
  - "BigQuery Performance"
  - "Tables Views Materialized Views"
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 10
date: 2026-07-17
language: "SQL"
database: "BigQuery / GoogleSQL"
topics:
  - "Data Pipelines"
  - "BigQuery"
  - "Data Architecture"
  - "Performance"
  - "Data Modeling"
tags:
  - brocode
  - wagon2321/cours
  - data-pipelines
  - bigquery
  - data-architecture
  - performance
---

# 📝 10 — Data Pipelines, Views, Tables & BigQuery Performance

> [!info] Navigation Brocode
> **← Précédent :** [[09_udf_window_functions_sol|09 — SQL · UDFs & Window Functions]] · **Suivant → :** [[12_git_versioning_github_collaboration_sol|12 — Git · Versioning, GitHub & Collaboration]]
>
> [!tip] Navigation Obsidian
> Utilise l’**Outline** pour parcourir les sections, `Cmd/Ctrl + O` pour le Quick Switcher et les **backlinks** pour retrouver les connexions entre notes.

---

> [!abstract] Objectif du chapitre
> **Objectif du chapitre**
>
> Ce chapitre n'est pas un chapitre de syntaxe SQL au sens strict.
>
> Il répond à une question plus large :
>
> > **Que devient une requête SQL lorsqu'elle doit faire partie d'un vrai système de données ?**
>
> Jusqu'ici, on sait écrire des requêtes permettant de :
>
> - nettoyer ;
> - agréger ;
> - joindre ;
> - transformer ;
> - calculer des métriques.
>
> Mais en entreprise, une analyse n'est pas simplement :
>
> ```text
> un fichier
> ↓
> une requête
> ↓
> un résultat
> ```
>
> Elle appartient généralement à une chaîne :
>
> ```text
> systèmes sources
>       ↓
> ingestion
>       ↓
> données brutes
>       ↓
> nettoyage
>       ↓
> enrichissement
>       ↓
> modélisation
>       ↓
> tables métier
>       ↓
> dashboards / analyses / ML
> ```
>
> Cette chaîne est un **data pipeline**.
>
> Le but de ce chapitre est donc de construire un modèle mental durable reliant :
>
> ```text
> SQL
> +
> stockage
> +
> performance
> +
> fraîcheur
> +
> coûts
> +
> dépendances
> +
> production
> ```
>
> Le chapitre reprend le cours Le Wagon, mais plusieurs points ont été précisés ou corrigés lorsque les simplifications pédagogiques du support devenaient techniquement ambiguës.

---

## 🧭 0. Vue d'ensemble du chapitre

Les grandes notions sont liées :

```text
                    DATA SOURCES
                        │
                        ▼
                ┌───────────────┐
                │   INGESTION   │
                └───────┬───────┘
                        │
                        ▼
                ┌───────────────┐
                │    BRONZE     │
                │ raw / source  │
                └───────┬───────┘
                        │
                        ▼
             nettoyage / typage / tests
                        │
                        ▼
                ┌───────────────┐
                │    SILVER     │
                │ clean / prep  │
                └───────┬───────┘
                        │
                        ▼
              joins / agrégations / KPI
                        │
                        ▼
                ┌───────────────┐
                │     GOLD      │
                │ business data │
                └───────┬───────┘
                        │
                        ▼
        dashboards / analysts / ML / apps
```

Autour de ce flux se trouvent :

```text
orchestration
observability
data lineage
permissions
performance
cost control
```

---

## 🏭 1. Qu'est-ce qu'un data pipeline ?

Un **data pipeline** est une succession coordonnée d'étapes qui permettent de faire circuler et transformer les données entre une source et une destination.

Exemple :

```text
CRM Salesforce
    ↓
extraction
    ↓
BigQuery raw
    ↓
nettoyage SQL
    ↓
table customers_clean
    ↓
jointure avec orders
    ↓
table customer_metrics
    ↓
Power BI
```

Un pipeline ne se limite donc pas à la transformation.

Il comprend potentiellement :

```text
Extraction
Load / ingestion
Transformation
Validation
Stockage
Publication
Orchestration
Monitoring
```

> 💡 **Correction Brocode**
>
> Une slide du cours associait fortement « pipeline » à la transformation.
>
> C'est utile pédagogiquement, mais trop restrictif.
>
> Le pipeline est **le flux complet**. La transformation n'en est qu'une partie.

---

## 🎯 2. Pourquoi construire un pipeline ?

Parce que la donnée source est rarement directement adaptée aux usages analytiques.

Une source peut contenir :

```text
doublons
NULL
types incorrects
noms peu lisibles
colonnes techniques
plusieurs granularités
plusieurs systèmes
données historiques
formats hétérogènes
```

Un dashboard, lui, attend idéalement :

```text
des métriques fiables
des dimensions propres
des relations compréhensibles
des temps de réponse raisonnables
des données actualisées
```

Le pipeline fait le lien.

---

## 🏎 3. La métaphore de la Ferrari

Le cours utilise une bonne métaphore :

```text
dashboard = Ferrari
données   = carburant
```

On peut avoir :

- un dashboard magnifique ;
- des animations ;
- des visualisations sophistiquées ;
- des KPI impressionnants.

Mais si les données sont incorrectes :

```text
garbage in
↓
garbage out
```

La qualité du reporting est limitée par la qualité du pipeline en amont.

---

## 🔁 4. Pipeline ≠ requête SQL unique

Un débutant peut être tenté de faire :

```sql
WITH ...
SELECT ...
FROM ...
JOIN ...
WHERE ...
GROUP BY ...
...
```

avec plusieurs centaines de lignes de SQL dans une seule requête.

Cela peut fonctionner.

Mais en production, on préfère souvent décomposer.

Exemple :

```text
raw_orders
   ↓
clean_orders
   ↓
orders_enriched
   ↓
daily_orders
   ↓
sales_dashboard
```

Pourquoi ?

Parce que cela facilite :

```text
compréhension
debug
tests
réutilisation
lineage
maintenance
performance
```

---

## 🧩 5. Penser en étapes

Un pipeline est beaucoup plus simple à raisonner lorsque chaque étape répond à une question précise.

Exemple :

```text
Étape 1
→ rendre les types corrects

Étape 2
→ dédupliquer

Étape 3
→ ajouter les informations client

Étape 4
→ calculer les ventes par commande

Étape 5
→ produire les KPI journaliers
```

Chaque étape crée un contrat implicite :

```text
entrée attendue
↓
transformation
↓
sortie garantie
```

---

## 🧪 6. Les transformations classiques

Le cours identifie quatre grandes familles.

### Nettoyage

```text
doublons
NULL
caractères parasites
formats incohérents
```

Exemple :

```sql
SELECT DISTINCT
  order_id,
  customer_id,
  SAFE_CAST(order_date AS DATE) AS order_date
FROM raw_orders;
```

---

### Enrichissement

Ajouter ou restructurer de l'information.

Exemples :

```text
CAST
CASE WHEN
EXTRACT
SPLIT
REGEXP_EXTRACT
nouveaux indicateurs
```

---

### Agrégation

Changer de granularité.

```sql
SELECT
  order_id,
  SUM(turnover) AS order_turnover
FROM sales
GROUP BY order_id;
```

---

### Jointure

Rassembler plusieurs entités.

```sql
SELECT
  o.order_id,
  o.customer_id,
  c.country
FROM orders AS o
LEFT JOIN customers AS c
  USING (customer_id);
```

---

## ⚠️ 7. Ne pas être dogmatique sur l'ordre

Le formateur insiste sur un point très important :

> Les étapes sont des **patterns**, pas des lois universelles.

On peut montrer :

```text
clean
↓
enrich
↓
aggregate
↓
join
```

mais dans un vrai pipeline :

```text
clean
↓
join
↓
enrich
↓
aggregate
```

peut être parfaitement logique.

Ou :

```text
aggregate
↓
join
```

peut être nécessaire pour préserver la granularité.

Le bon ordre dépend :

```text
de la question métier
de la granularité
du volume
des sources
des coûts
des contraintes techniques
```

---

## 🏅 8. Medallion Architecture

Le cours évoque explicitement un modèle très répandu :

```text
Bronze
Silver
Gold
```

Il est souvent appelé :

```text
Medallion Architecture
```

Il ne s'agit pas d'une norme obligatoire.

C'est un **modèle conceptuel** permettant de séparer les niveaux de transformation.

---

## 🥉 9. Bronze — la donnée brute maîtrisée

La couche Bronze contient généralement une copie proche de la source.

Objectif :

```text
préserver ce qui a été reçu
```

Exemples :

```text
CRM export brut
API response
CSV ingéré
copie d'une table opérationnelle
events web
transactions brutes
```

On transforme peu.

On cherche surtout à conserver :

```text
traçabilité
historique
reproductibilité
```

---

## 🥈 10. Silver — la donnée propre et exploitable

Silver contient des données :

```text
nettoyées
typées
dédupliquées
standardisées
validées
```

Exemple :

```text
bronze.orders_raw
        ↓
silver.orders_clean
```

Transformations possibles :

```sql
SAFE_CAST()
LOWER()
TRIM()
REGEXP_REPLACE()
ROW_NUMBER() de déduplication
tests de clés
```

La donnée Silver n'est pas forcément encore « métier ».

Elle est surtout **fiable et structurée**.

---

## 🥇 11. Gold — la donnée métier

Gold contient des objets directement conçus pour la consommation.

Exemples :

```text
sales_daily
customer_360
marketing_funnel
finance_monthly
churn_features
```

Ils peuvent contenir :

```text
KPI
agrégations
dimensions
jointures
métriques pré-calculées
```

L'objectif n'est plus de représenter fidèlement le système source.

L'objectif est :

```text
répondre efficacement aux besoins métier
```

---

## 🔄 12. Bronze / Silver / Gold n'est pas forcément trois bases

Il faut éviter une lecture trop littérale.

Une architecture peut matérialiser :

```text
dataset_bronze
dataset_silver
dataset_gold
```

Mais elle pourrait également utiliser :

```text
schemas
datasets
tables
views
dbt layers
naming conventions
```

Le principe important est la **séparation logique des responsabilités**.

---

## 🧠 13. L'idée centrale du Medallion

```text
Bronze
→ qu'avons-nous reçu ?

Silver
→ pouvons-nous faire confiance à cette donnée ?

Gold
→ comment le métier veut-il la consommer ?
```

---

## 🧬 14. ETL vs ELT

Deux architectures doivent être distinguées.

### ETL

```text
Extract
↓
Transform
↓
Load
```

La donnée est transformée avant d'être chargée dans la plateforme analytique finale.

---

### ELT

```text
Extract
↓
Load
↓
Transform
```

On charge d'abord la donnée dans le warehouse, puis on utilise sa puissance de calcul pour transformer.

Avec des plateformes cloud analytiques comme BigQuery, l'ELT est très fréquent.

Exemple :

```text
HubSpot
↓
Fivetran
↓
BigQuery raw
↓
SQL / dbt
↓
marts
```

---

## 💡 15. Pourquoi ELT est devenu si fréquent

Les data warehouses modernes disposent de beaucoup de puissance de calcul.

Plutôt que :

```text
transformer tout avant chargement
```

on peut :

```text
charger rapidement
↓
conserver la donnée brute
↓
transformer dans le warehouse
```

Avantages :

```text
rejouer les transformations
conserver l'historique
simplifier l'ingestion
centraliser le SQL
```

---

## ⏱ 16. Batch vs streaming

Autre dimension d'un pipeline :

### Batch

```text
toutes les nuits
toutes les heures
tous les jours
```

On traite un lot.

Exemple :

```text
02:00
↓
sync CRM
↓
transform
↓
refresh dashboard
```

---

### Streaming / near real-time

La donnée arrive continuellement.

Exemple :

```text
click
↓
event
↓
stream
↓
warehouse
↓
dashboard quasi temps réel
```

Le besoin métier détermine le niveau de fraîcheur nécessaire.

---

## 🧠 17. « Temps réel » coûte cher

Une erreur classique consiste à demander :

```text
tout en temps réel
```

sans raison métier.

Plus la fréquence augmente :

```text
plus de jobs
plus de compute
plus de complexité
plus de monitoring
plus de risques de concurrence
```

Question à poser :

> **Quelle fraîcheur est réellement utile ?**

Exemple :

```text
fraude bancaire
→ secondes / minutes

reporting mensuel
→ temps réel inutile
```

---

## 🏗 18. OLTP vs OLAP

Cette distinction est centrale dans le cours.

### OLTP

```text
Online Transaction Processing
```

Optimisé pour les opérations transactionnelles.

Exemples :

```text
paiement
commande
modification d'adresse
retrait bancaire
CRM
ERP
```

---

### OLAP

```text
Online Analytical Processing
```

Optimisé pour l'analyse.

Exemples :

```text
SUM
AVG
GROUP BY
analyses historiques
dashboard
modèles métier
```

---

## ⚠️ 19. OLTP / OLAP : ne pas réduire la définition à « lignes vs colonnes »

Le cours utilise l'opposition :

```text
OLTP = row-oriented
OLAP = column-oriented
```

C'est une excellente intuition pédagogique, mais ce n'est pas la définition.

OLTP et OLAP décrivent d'abord **des types de workloads**.

Dans la pratique :

```text
beaucoup de systèmes OLTP
→ row stores

beaucoup de warehouses OLAP modernes
→ columnar storage
```

Mais ce lien n'est pas une règle absolue.

> 💡 BigQuery, lui, utilise bien une architecture de stockage colonnaire adaptée aux workloads analytiques.

---

## 🏦 20. Exemple OLTP : système bancaire

Une transaction :

```text
Compte A
↓
-100 €
```

et :

```text
Compte B
↓
+100 €
```

doit être :

```text
rapide
cohérente
fiable
```

Le système n'est pas conçu prioritairement pour calculer :

```text
AVG(transaction_amount)
par mois
par agence
sur 10 ans
```

---

## 📊 21. Exemple OLAP

Le warehouse peut stocker une table :

```text
fact_transactions
```

avec :

```text
transaction_id
date
customer_id
account_id
amount
channel
country
```

Et permettre :

```sql
SELECT
  DATE_TRUNC(transaction_date, MONTH) AS month,
  SUM(amount) AS total_amount
FROM fact_transactions
GROUP BY month;
```

C'est un workload analytique.

---

## 🚨 22. Pourquoi ne pas faire le dashboard directement sur l'OLTP ?

Deux problèmes.

## 1. Performance

Le système source est optimisé pour servir les opérations métier.

Une requête analytique lourde peut être inefficace.

---

## 2. Concurrence

Même si la requête fonctionne, elle peut consommer des ressources utiles aux transactions.

Exemple :

```text
client en caisse
+
dashboard exécutant 15 grosses agrégations
```

Ce n'est pas la priorité du système opérationnel.

---

## 🎯 23. Première question lorsqu'un dashboard est extrêmement lent

Le formateur propose un excellent réflexe :

> **Est-ce qu'on requête directement le système de production ?**

Ce n'est pas toujours la cause.

Mais c'est une très bonne hypothèse à vérifier.

---

## 📚 24. Normalisation — côté transactionnel

La normalisation vise notamment à éviter la répétition inutile.

Exemple :

```text
customers
customer_id | name
```

```text
orders
order_id | customer_id
```

On ne répète pas :

```text
name
```

dans chaque commande.

Avantages :

```text
cohérence
moins de duplication
mises à jour facilitées
```

---

## 🧱 25. Dénormalisation — côté analytique

Dans un warehouse analytique, on peut accepter de répéter certaines informations.

Exemple :

```text
sales_model
────────────────────────
order_id
date
customer_id
customer_country
product_id
product_category
turnover
margin
```

La colonne :

```text
customer_country
```

peut être répétée sur de nombreuses lignes.

Pourquoi ?

Parce que cela peut simplifier et accélérer les requêtes.

---

## ⚠️ 26. Dénormalisé ne veut pas dire « tout dupliquer au hasard »

Une table analytique doit rester :

```text
compréhensible
cohérente
documentée
testable
```

La dénormalisation est un choix d'architecture.

Pas une permission pour créer :

```text
une énorme table incontrôlable
```

---

## 💼 27. Data Modeling = orienter la donnée vers le métier

Les systèmes sources sont structurés pour faire fonctionner l'entreprise.

Les data models sont structurés pour **comprendre l'entreprise**.

Exemple source :

```text
customers
orders
sales
products
shipping
```

Exemple modèle métier :

```text
customer_360
orders_model
sales_model
finance_kpis
```

---

## 🧠 28. Le changement de perspective

Système opérationnel :

```text
Comment enregistrer une commande correctement ?
```

Modèle analytique :

```text
Comment mesurer les commandes facilement ?
```

Ce sont deux objectifs différents.

---

## 🧮 29. Pré-calculer certaines métriques

Supposons que chaque dashboard calcule :

```sql
SUM(turnover)
GROUP BY order_id
```

à chaque ouverture.

Si le calcul est lourd et répété :

```text
calcul identique
×
100 utilisateurs
×
plusieurs refresh
```

il peut être préférable de matérialiser :

```text
orders_model.order_turnover
```

Le stockage coûte quelque chose.

Mais on économise potentiellement beaucoup de compute.

---

## ⚖️ 30. Le triangle Performance — Freshness — Cost

Une grande partie du chapitre peut se résumer à un arbitrage :

```text
                 FRAÎCHEUR
                    ▲
                   / \
                  /   \
                 /     \
                /       \
               /         \
      PERFORMANCE ─────── COÛT
```

Exemple :

```text
logical view
→ très fraîche
→ compute répété

table matérialisée
→ rapide
→ nécessite refresh

materialized view
→ compromis géré par BigQuery
```

Il n'existe pas un choix universellement meilleur.

---

## 🗄 31. Data Warehouse

Un **Data Warehouse** est une plateforme destinée principalement à stocker et analyser des données structurées pour les besoins décisionnels.

Exemples de technologies :

```text
BigQuery
Snowflake
Amazon Redshift
Azure Synapse
```

Dans ce chapitre, BigQuery est l'environnement principal.

---

## 🌊 32. Data Lake — aperçu

Un **Data Lake** stocke souvent des données plus brutes et plus hétérogènes.

Exemples :

```text
CSV
JSON
Parquet
logs
images
events
```

stockés sur :

```text
object storage
```

Exemples :

```text
Google Cloud Storage
Amazon S3
Azure Data Lake Storage
```

---

## 🧊 33. Lakehouse — aperçu

Le terme **Lakehouse** décrit des architectures cherchant à combiner :

```text
flexibilité d'un data lake
+
fonctionnalités analytiques d'un warehouse
```

Ce n'est pas nécessaire pour écrire du SQL dans le bootcamp.

Mais il est utile de reconnaître le terme.

---

## ☁️ 34. Une data platform = stockage + compute

Le cours insiste sur deux composants.

```text
STORAGE
→ où sont les données ?
```

```text
COMPUTE / PROCESSING
→ avec quelle puissance les calculs sont-ils exécutés ?
```

Dans le cloud, ces deux dimensions peuvent être facturées et dimensionnées séparément selon la plateforme.

---

## 🧠 35. Pourquoi cette séparation est importante

Une table peut rester stockée :

```text
24h / 24
```

mais n'être interrogée que :

```text
3 fois par jour
```

Le stockage et le calcul n'ont donc pas le même profil d'utilisation.

Cette séparation permet :

```text
scale
optimisation des coûts
workloads indépendants
```

---

## 💰 36. Le stockage est-il toujours « moins cher » que le compute ?

Le cours donne ce principe :

```text
storage << processing
```

Comme intuition, c'est très utile.

Mais il ne faut pas le transformer en loi universelle.

La bonne idée est :

> **Répéter un calcul lourd des centaines de fois peut coûter davantage que stocker un résultat intermédiaire réutilisable.**

Il faut comparer :

```text
volume de stockage
+
fréquence des requêtes
+
volume scanné
+
fréquence de refresh
+
modèle de pricing
```

---

## 🧱 37. Les objets BigQuery à connaître

Pour ce chapitre :

```text
TABLE
VIEW
MATERIALIZED VIEW
CTE
SAVED QUERY
TEMP TABLE
ROUTINE
```

Ils ne représentent pas la même chose.

---

## 📦 38. Table

Une table contient des données matérialisées.

Conceptuellement :

```text
SQL
↓
calcul
↓
résultat écrit
↓
stockage
```

Ensuite :

```sql
SELECT
  order_id,
  turnover
FROM analytics.orders_model;
```

lit des valeurs déjà enregistrées.

---

## ⚡ 39. Pourquoi une table peut être rapide

Supposons que la construction ait demandé :

```text
3 JOINs
2 GROUP BY
plusieurs CASE
10 secondes
```

Si le résultat est stocké dans une table :

```text
dashboard
↓
SELECT quelques colonnes
↓
table pré-calculée
```

On ne rejoue pas nécessairement toute la chaîne source à chaque lecture.

---

## 🧊 40. Inconvénient d'une table : la fraîcheur

La table contient le résultat :

```text
au moment où elle a été créée / mise à jour
```

Si les sources changent :

```text
source = 10:05
table = état calculé à 09:00
```

la table n'est plus parfaitement fraîche.

Il faut une stratégie de refresh.

---

## 👁 41. Logical View — définition

Dans BigQuery, une **logical view** est une table virtuelle définie par SQL.

Elle stocke essentiellement :

```text
la logique de requête
```

et non les résultats matérialisés de la requête.

Exemple :

```sql
CREATE VIEW analytics.fr_orders AS
SELECT
  order_id,
  customer_id,
  turnover
FROM raw.orders
WHERE country = 'FR';
```

Ensuite :

```sql
SELECT
  *
FROM analytics.fr_orders;
```

---

## 🔁 42. Ce qui se passe lorsqu'on interroge une view

La vue ressemble à une table pour l'utilisateur.

Mais conceptuellement :

```text
SELECT ...
FROM view
     │
     ▼
BigQuery développe la définition
     │
     ▼
lit les tables sources
     │
     ▼
exécute la logique
```

La requête définissant la logical view est réévaluée lors de son interrogation.

---

## ✅ 43. Avantages d'une view

### Réutilisation

Une logique complexe peut être écrite une seule fois.

---

### Abstraction

L'utilisateur voit :

```text
customer_metrics
```

sans connaître tous les joins internes.

---

### Fraîcheur

La vue lit ses sources au moment où elle est interrogée.

---

### Sécurité

On peut exposer un sous-ensemble de données sans donner nécessairement un accès direct à toutes les tables sources.

---

## ⚠️ 44. Inconvénients d'une view

Si la vue contient :

```text
gros JOIN
+
agrégations
+
fonctions complexes
+
tables volumineuses
```

alors chaque interrogation peut déclencher un calcul significatif.

Conséquences possibles :

```text
latence
compute
coût
```

---

## 🔐 45. Authorized Views — le terme BigQuery

Le cours parle de « Secure Views » dans un exemple SaaS.

Dans BigQuery, le terme officiel à retenir est surtout :

```text
Authorized View
```

Une Authorized View permet de donner accès au résultat d'une vue sans donner accès directement aux datasets / tables sources correspondants.

Exemple multi-tenant :

```text
table complète
company_id
────────────────
A
A
B
B
C
```

Vue client A :

```sql
SELECT
  ...
FROM source
WHERE company_id = 'A';
```

Le client A reçoit l'accès à la vue autorisée, pas à toute la table source.

---

## 🏢 46. Cas SaaS multi-tenant

Le cours mentionne un cas avec des milliers de vues.

Pattern :

```text
table partagée multi-client
        ↓
filtre tenant_id
        ↓
view spécifique
        ↓
droits spécifiques
```

C'est un bon exemple montrant qu'une view peut servir autant à :

```text
sécuriser
```

qu'à :

```text
transformer
```

---

## 🧱 47. Materialized View

Une **materialized view** est différente d'une logical view.

Elle conserve des résultats précalculés afin d'éviter de refaire une partie du travail à chaque requête.

Conceptuellement :

```text
base tables
    ↓
pré-calcul
    ↓
résultats stockés / maintenus
    ↓
materialized view
```

---

## ⚠️ 48. Une Materialized View n'est pas simplement « une table stable »

C'est une simplification entendue dans le cours.

Une materialized view :

```text
reste définie par une requête
+
stocke / maintient des résultats précalculés
+
dispose d'un mécanisme de refresh
+
peut être exploitée automatiquement par l'optimiseur
```

Ce n'est donc ni :

```text
une logical view
```

ni exactement :

```text
une table créée manuellement
```

---

## 🚀 49. Cas d'usage Materialized View

Très utile lorsque :

```text
les mêmes agrégations sont demandées souvent
+
les tables sources sont volumineuses
+
la latence importe
```

Exemple :

```text
daily_active_users
sales_by_day
transactions_by_country
```

---

## 🧠 50. Table vs View vs Materialized View

| Objet | Données matérialisées ? | Fraîcheur | Compute à la lecture | Usage typique |
|---|---:|---|---|---|
| Table | Oui | dépend du refresh | faible à variable | modèles métier, snapshots |
| Logical View | Non | très fraîche | peut être élevé | abstraction, logique réutilisable, sécurité |
| Materialized View | Partiellement / précalculée | maintenue | souvent réduit | accélération de requêtes répétitives |

---

## 🧩 51. CTE — Common Table Expression

Une CTE existe dans une requête.

```sql
WITH clean_orders AS (
  SELECT
    order_id,
    SAFE_CAST(order_date AS DATE) AS order_date
  FROM raw_orders
)

SELECT
  *
FROM clean_orders;
```

La CTE aide à :

```text
structurer
nommer une étape
rendre le SQL lisible
```

---

## ⚠️ 52. CTE ≠ objet persistant

Une CTE :

```text
n'apparaît pas comme une table dans le dataset
```

Elle existe seulement dans le contexte de la requête.

On ne peut pas faire demain :

```sql
SELECT *
FROM clean_orders;
```

si `clean_orders` était uniquement une CTE d'une ancienne requête.

---

## ⚠️ 53. CTE ≠ « forcément stockée en mémoire »

Le cours décrit la CTE comme quelque chose d'actif « en mémoire ».

C'est une simplification.

Dans BigQuery :

```text
CTE = construction logique de requête
```

Le moteur peut :

```text
l'inliner
la recalculer
optimiser son exécution
```

Une CTE n'est pas automatiquement matérialisée comme une table intermédiaire réutilisée.

> 💡 **Règle :**
>
> Utiliser une CTE pour la **lisibilité**, pas comme garantie de performance.

---

## 💾 54. Saved Query

Une Saved Query est essentiellement :

```text
du SQL enregistré
```

On peut :

```text
ouvrir
modifier
exécuter
partager selon les outils
```

Mais une Saved Query n'est pas une table virtuelle.

On ne fait pas :

```sql
SELECT *
FROM my_saved_query;
```

comme on le ferait sur une view.

---

## 🧪 55. Temporary Table

Une temporary table matérialise temporairement un résultat dans le contexte d'une session ou d'un script.

Exemple conceptuel :

```sql
CREATE TEMP TABLE clean_orders AS
SELECT
  ...
FROM raw_orders;
```

Elle peut être utile dans :

```text
scripts
pipelines complexes
debug
réutilisation intermédiaire
```

Elle n'est pas destinée à devenir un objet analytique permanent.

---

## 🧰 56. Routine — Function / Stored Procedure

BigQuery peut également contenir des routines.

Exemples :

```text
UDF
Stored Procedure
```

Elles encapsulent de la logique.

Cela complète le modèle :

```text
table
view
materialized view
routine
```

Mais BigQuery contient encore d'autres types d'objets.

> 💡 Ne pas retenir « il existe exactement quatre objets ».

---

## 🧠 57. Comparaison complète

| Concept | Persistant ? | Contient les données ? | Interrogeable comme table ? | But |
|---|---:|---:|---:|---|
| Table | ✅ | ✅ | ✅ | stockage |
| View | ✅ | ❌ | ✅ | logique réutilisable |
| Materialized View | ✅ | partiellement | ✅ | accélération |
| CTE | ❌ | ❌ | dans la requête | lisibilité / étape |
| Saved Query | ✅ comme code | ❌ | ❌ | réutiliser du SQL |
| Temp Table | temporaire | ✅ | ✅ pendant sa vie | étape matérialisée |
| UDF | ✅ possible | ❌ | ❌ comme table | fonction |
| Stored Procedure | ✅ | ❌ | ❌ comme table | procédure / orchestration |

---

## 🧭 58. Arbre de décision : Table ou View ?

```text
Ai-je besoin du résultat toujours très frais ?
│
├── Oui
│    │
│    └── La logique est-elle raisonnablement légère ?
│          ├── Oui → View candidate
│          └── Non → Materialized View / autre design
│
└── Non
     │
     └── Le résultat est-il réutilisé souvent ?
           ├── Oui → Table candidate
           └── Non → View ou calcul ad hoc
```

Puis considérer :

```text
permissions
coûts
latence
maintenance
```

---

## 🔀 59. Mixer Views et Tables

Le cours insiste sur un bon point :

> **On n'a pas besoin de choisir un seul objet pour tout le pipeline.**

Exemple :

```text
raw table
   ↓
cleaning view
   ↓
materialized table
   ↓
business view
   ↓
Power BI
```

Chaque objet répond à une contrainte différente.

---

## 🔁 60. Exemple de pipeline mixte

```text
raw.events
   │
   ├─► view: valid_events
   │       │
   │       ▼
   │   filtre + typage
   │
   ▼
table: daily_events
   │
   ▼
view: marketing_kpis
   │
   ▼
Looker / Power BI
```

---

## ⚡ 61. Pourquoi matérialiser une étape intermédiaire ?

Supposons une logique qui prend :

```text
20 secondes
```

et qui est utilisée par :

```text
15 dashboards
```

Plutôt que recalculer :

```text
20 sec × N requêtes
```

on peut :

```text
calculer une fois
↓
écrire une table
↓
requêter le résultat réduit
```

C'est un pattern classique.

---

## 🧠 62. Quand NE PAS matérialiser

Matérialiser chaque micro-étape crée :

```text
beaucoup de tables
beaucoup de stockage
beaucoup de dépendances
beaucoup de jobs
beaucoup de maintenance
```

Il faut donc trouver un équilibre.

Matérialiser lorsqu'il existe une raison :

```text
performance
réutilisation
audit
frontière métier
debug
sécurité
```

---

## 💰 63. BigQuery — modèles de pricing compute

Le cours parle de :

```text
pay-as-you-go
vs
flat pricing
```

La terminologie BigQuery moderne est plus précise.

BigQuery propose notamment :

```text
On-demand pricing
→ basé sur les bytes traités

Capacity pricing
→ basé sur des slots / slot-hours
```

Le modèle capacity peut lui-même utiliser :

```text
autoscaling
commitments
```

Il ne faut donc plus résumer BigQuery à un seul modèle de facturation.

---

## 🧠 64. À retenir sur le pricing

Ne mémoriser ni un prix fixe ni un chiffre de cours.

Les tarifs évoluent.

Retenir plutôt :

```text
storage cost
+
compute cost
+
data transfer éventuel
```

et savoir consulter les informations du job.

---

## 📏 65. On-demand BigQuery : logique des bytes processed

En mode on-demand :

```text
plus de données lues
→ plus de bytes processed
→ coût potentiel plus élevé
```

BigQuery étant columnar, les colonnes sélectionnées comptent.

---

## ⭐ 66. Pourquoi éviter `SELECT *`

```sql
SELECT *
FROM huge_table;
```

demande toutes les colonnes visibles.

Si la table possède :

```text
100 colonnes
```

alors BigQuery peut devoir lire beaucoup plus de données que nécessaire.

Préférer :

```sql
SELECT
  order_id,
  turnover
FROM huge_table;
```

---

## ✂️ 67. `SELECT * EXCEPT`

BigQuery permet :

```sql
SELECT
  * EXCEPT (large_json_column, raw_payload)
FROM events;
```

Cela reste parfois utile lorsqu'on veut :

```text
presque toutes les colonnes
```

mais exclure quelques colonnes très lourdes.

---

## 🚫 68. `LIMIT` ne protège pas automatiquement le coût

Cette requête :

```sql
SELECT *
FROM huge_table
LIMIT 10;
```

retourne seulement dix lignes.

Mais sur une table non clusterisée :

```text
LIMIT
```

ne réduit pas nécessairement la quantité de données lue.

C'est un piège très important.

---

## 🧠 69. Rows returned ≠ bytes processed

Il faut séparer :

```text
combien de lignes je vois
```

et :

```text
combien de données le moteur a dû lire
```

Exemple :

```text
résultat : 10 lignes
bytes processed : 500 GB
```

est parfaitement possible.

---

## 👀 70. Pour explorer une table : utiliser Preview

Si l'objectif est simplement :

```text
voir quelques lignes
```

utiliser l'onglet Preview est souvent préférable à :

```sql
SELECT *
FROM table
LIMIT 100;
```

BigQuery documente explicitement cette bonne pratique.

---

## 🧮 71. Le type des colonnes influence leur taille

Les colonnes ne consomment pas toutes le même nombre de bytes logiques.

Exemple conceptuel :

```text
INT64
STRING
NUMERIC
JSON
```

n'ont pas le même coût de représentation.

Donc :

```text
nombre de colonnes
+
type
+
volume
```

influencent la quantité lue.

---

## 🗃 72. Query Cache

BigQuery peut réutiliser le résultat de certaines requêtes.

Conceptuellement :

```text
query A
↓
résultat calculé
↓
cache
```

Puis :

```text
query A identique
↓
cache compatible
↓
résultat réutilisé
```

Les requêtes servies depuis le cache ne sont pas facturées comme une nouvelle lecture de données en on-demand.

---

## ⚠️ 73. Le cache n'est pas une stratégie de pipeline

Le cache est une optimisation.

Il ne remplace pas :

```text
une table
une view
un refresh
une orchestration
```

Ne jamais concevoir un pipeline en supposant :

```text
« de toute façon ce sera caché »
```

---

## 🧪 74. Dry Run / estimation

Avant d'exécuter une requête importante, BigQuery peut estimer le volume traité.

Modèle mental :

```text
écrire query
↓
estimation
↓
volume raisonnable ?
│
├── oui → run
└── non → optimiser
```

---

## 🛑 75. Maximum bytes billed

BigQuery permet également de définir une limite maximale de bytes facturables pour une requête.

Si la requête dépasse la limite :

```text
elle échoue
```

plutôt que de dépasser le budget prévu.

C'est un garde-fou utile.

---

## 🧱 76. Partitioning — idée générale

Une table partitionnée est divisée en segments logiques / physiques appelés :

```text
partitions
```

Exemple par date :

```text
orders
├── 2026-07-01
├── 2026-07-02
├── 2026-07-03
└── 2026-07-04
```

---

## 🔍 77. Pourquoi partitionner ?

Supposons :

```text
5 ans de données
```

mais la requête demande :

```text
le 10 juillet 2026
```

Sans organisation adaptée :

```text
grosse lecture potentielle
```

Avec partition pruning :

```text
BigQuery peut ignorer les partitions non pertinentes
```

---

## ✂️ 78. Partition pruning

Exemple :

```sql
SELECT
  order_id,
  turnover
FROM analytics.orders
WHERE order_date >= DATE '2026-07-01'
  AND order_date < DATE '2026-08-01';
```

Si :

```text
order_date
```

est la colonne de partitionnement et le filtre est éligible :

```text
BigQuery scanne uniquement les partitions nécessaires
```

---

## 🧠 79. Pourquoi le filtre de partition est si important

Partitionner une table n'apporte pas automatiquement un bénéfice à toutes les requêtes.

Il faut :

```text
filtrer sur la partition
```

Sinon :

```text
toutes les partitions peuvent être lues
```

---

## 📅 80. Les principaux types de partitioning BigQuery

BigQuery permet notamment :

```text
time-unit column partitioning
ingestion-time partitioning
integer-range partitioning
```

---

## 📆 81. Partitionnement sur une colonne DATE / TIMESTAMP / DATETIME

Exemple :

```text
order_date
```

Lorsque la ligne est écrite :

```text
BigQuery regarde la valeur de order_date
```

et la place dans la partition correspondante.

---

## ⏱ 82. Ingestion-time partitioning

Ici, le partitionnement dépend de :

```text
quand BigQuery a ingéré la ligne
```

et non nécessairement de la date métier de la ligne.

BigQuery expose alors des pseudo-colonnes comme :

```text
_PARTITIONTIME
_PARTITIONDATE
```

---

## 🔢 83. Integer-range partitioning

On peut également partitionner une table selon des plages d'entiers.

Exemple conceptuel :

```text
customer_id
0–999
1000–1999
2000–2999
```

Ce type est moins central dans les usages bootcamp.

---

## 🚨 84. Correction importante : late-arriving data

Le cours donne l'exemple :

```text
nous sommes le 5 septembre
↓
une ligne datée du 1er septembre arrive
↓
elle ne serait pas dans la bonne partition
```

Cette affirmation dépend du type de partitionnement.

### Si la table est partitionnée sur `order_date`

BigQuery place automatiquement la ligne dans la partition correspondant à :

```text
order_date = 2026-09-01
```

même si la ligne est chargée le 5 septembre.

---

### Si la table est partitionnée par ingestion time

Alors :

```text
ligne ingérée le 5
→ partition du 5
```

même si l'événement métier date du 1er.

> 💡 **Réflexe :**
>
> Toujours demander :
>
> ```text
> partitionnée par quelle valeur exactement ?
> ```

---

## ⚠️ 85. Partitioning ≠ classement manuel fragile

Le cours compare les partitions à une chambre d'enfant qui se désorganise.

L'intuition veut montrer qu'un mauvais design finit par devenir inefficace.

Mais techniquement, BigQuery gère ses partitions.

Une table partitionnée correctement sur une colonne de temps ne nécessite pas une reconstruction simplement parce que des données anciennes arrivent plus tard.

Les problèmes réels sont plutôt :

```text
mauvaise colonne de partition
trop de petites partitions
absence de filtre
skew
workflow de mises à jour inefficace
```

---

## 📏 86. Le seuil « 2 GB » n'est pas une règle BigQuery universelle

Le cours mentionne :

```text
partitioning recommandé > 2 GB
```

À ne pas apprendre comme une règle officielle.

La documentation BigQuery recommande plutôt de raisonner selon :

```text
taille des partitions
patterns de requêtes
besoin de cost estimation
nombre de partitions
```

Google indique notamment qu'un partitionnement produisant en moyenne des partitions très petites — environ **moins de 10 GB par partition** — peut être contre-productif.

---

## 🧠 87. Comment choisir une colonne de partition

Bonne candidate :

```text
colonne très souvent utilisée pour limiter la période
```

Exemples :

```text
order_date
transaction_date
event_date
created_at
```

Mais il faut réfléchir à la sémantique.

Exemple :

```text
created_at
≠
business_date
```

---

## ❓ 88. La question à poser avant de partitionner

> **Quels filtres les utilisateurs feront-ils le plus souvent ?**

Si 95 % des requêtes commencent par :

```sql
WHERE transaction_date BETWEEN ...
```

alors :

```text
transaction_date
```

est une candidate naturelle.

---

## 🧱 89. Require partition filter

BigQuery peut imposer qu'une requête utilise un filtre de partition.

Cela empêche :

```sql
SELECT *
FROM giant_partitioned_table;
```

sans restriction temporelle adaptée.

C'est un excellent garde-fou sur certaines tables.

---

## 🧩 90. Clustering — idée générale

Le clustering organise les blocs de stockage selon les valeurs de certaines colonnes.

Exemple :

```text
table partitionnée par date
↓
à l'intérieur de chaque partition :
customer_id organisé en blocs
```

---

## ⚠️ 91. Clustering ≠ « partitioning sur plusieurs colonnes »

Le cours résume le clustering comme l'équivalent du partitionnement avec plusieurs colonnes.

C'est utile comme intuition mais techniquement imprécis.

Partitioning :

```text
divise la table en partitions explicites
```

Clustering :

```text
organise les blocs de stockage selon des colonnes
```

BigQuery supporte jusqu'à plusieurs colonnes de clustering, avec un ordre important.

---

## 🧠 92. Exemple de clustering

Table :

```text
sales
```

clusterisée par :

```text
customer_id
```

Requête :

```sql
SELECT
  order_id,
  turnover
FROM sales
WHERE customer_id = 12345;
```

BigQuery peut éviter des blocs qui ne contiennent pas cette plage de valeurs.

---

## 📚 93. Plusieurs colonnes de clustering

Exemple :

```text
CLUSTER BY country, customer_id
```

L'ordre est important.

Les requêtes filtrant :

```text
country
```

ou :

```text
country + customer_id
```

peuvent bénéficier davantage du tri des blocs.

---

## 🔀 94. Partitioning + Clustering

Les deux peuvent être combinés.

Exemple :

```text
PARTITION BY order_date
CLUSTER BY customer_id, product_category
```

Architecture :

```text
2026-07-01
  ├── blocs customer A...
  └── blocs customer B...

2026-07-02
  ├── blocs customer A...
  └── blocs customer B...
```

---

## 🧭 95. Partitioning vs Clustering

| Question | Partitioning | Clustering |
|---|---|---|
| Segmente en partitions identifiables | ✅ | ❌ |
| Plusieurs colonnes | ❌ une colonne de partition | ✅ plusieurs colonnes |
| Cost estimate précis avant run | plus prévisible | moins précis |
| Pruning | partitions | blocs |
| Bon pour filtres temporels | excellent | possible |
| Se combine avec l'autre | ✅ | ✅ |

---

## 📏 96. Quand clustering devient intéressant

BigQuery indique que les tables / partitions supérieures à environ :

```text
64 MB
```

sont plus susceptibles de bénéficier du clustering.

Mais encore une fois :

```text
ce n'est pas un seuil métier absolu
```

Le pattern de requête compte énormément.

---

## 🔁 97. Automatic Reclustering

BigQuery maintient automatiquement le clustering en arrière-plan.

Lorsque de nouvelles données arrivent :

```text
BigQuery peut réorganiser les blocs
```

pour conserver les bénéfices du clustering.

Donc :

```text
on ne reclusterise pas manuellement après chaque insert
```

---

## 🛠 98. Exemple CREATE TABLE partitionnée + clusterisée

```sql
CREATE OR REPLACE TABLE analytics.sales_model
PARTITION BY order_date
CLUSTER BY customer_id, product_category
AS
SELECT
  order_date,
  order_id,
  customer_id,
  product_category,
  turnover,
  margin
FROM silver.sales;
```

---

## 💡 99. Le SQL peut donc définir l'architecture physique

Une requête n'est pas seulement :

```text
SELECT des données
```

Elle peut aussi créer un objet ayant des propriétés de stockage :

```text
partitioning
clustering
expiration
```

C'est la frontière entre :

```text
SQL analytique
```

et :

```text
data engineering / analytics engineering
```

qui commence à apparaître.

---

## 🧬 100. Data Lineage

Le **data lineage** décrit :

```text
d'où vient la donnée
↓
par quelles transformations elle passe
↓
où elle arrive
```

Exemple :

```text
CRM.customers
      │
      ▼
bronze.customers
      │
      ▼
silver.customers_clean
      │
      ├──────────────┐
      ▼              ▼
gold.customer_360  gold.marketing_segments
      │
      ▼
Power BI
```

---

## 🔎 101. Pourquoi le lineage est essentiel

Imagine qu'un CFO demande :

> Pourquoi le chiffre d'affaires du dashboard vaut 93,2 M€ ?

Sans lineage :

```text
« parce que le dashboard le dit »
```

Avec lineage :

```text
dashboard KPI
↓
gold.sales_monthly
↓
silver.sales_clean
↓
raw ERP transactions
↓
source SAP
```

On peut auditer le chiffre.

---

## 🐛 102. Data lineage et debugging

Si un KPI est faux :

```text
dashboard
↓
gold
↓
silver
↓
bronze
↓
source
```

On remonte progressivement.

Le lineage transforme :

```text
« le chiffre est faux »
```

en :

```text
« l'erreur apparaît entre Silver et Gold »
```

---

## 🕸 103. Lineage = dependency graph

On peut représenter le pipeline comme un graphe.

```text
A ──────► C ──────► E
 \
  └─────► D ──────► E

B ────────────────► E
```

Ici :

```text
E dépend de C, D et B
C dépend de A
D dépend de A
```

C'est un **graphe de dépendances**.

---

## ⚠️ 104. ERD ≠ Data Lineage

Ces deux diagrammes répondent à des questions différentes.

### ERD

```text
Quelles entités sont liées ?
```

Exemple :

```text
customers
1:N
orders
```

---

### Lineage

```text
Comment cette donnée a-t-elle été produite ?
```

Exemple :

```text
orders_raw
↓
orders_clean
↓
orders_model
```

---

## 📚 105. ERD vs Lineage

| | ERD | Data Lineage |
|---|---|---|
| Sujet | structure relationnelle | transformations |
| Montre PK/FK | souvent | pas nécessairement |
| Montre dépendances de pipeline | non | oui |
| Question | « comment les tables sont liées ? » | « d'où vient ce KPI ? » |

---

## 🗂 106. Catalog / Governance

Le cours mentionne les **Data Catalogs**.

Ils servent notamment à gérer :

```text
métadonnées
ownership
description
classification
search
lineage
```

Sur Google Cloud, **Data Catalog est désormais remplacé par Dataplex Universal Catalog**.

C'est un exemple de notion qui évolue plus vite que SQL lui-même.

---

## 🧠 107. Metadata

La donnée :

```text
turnover = 12500
```

est une donnée.

Les métadonnées pourraient être :

```text
type = NUMERIC
description = Net revenue excl. VAT
owner = Finance Data
refresh = daily 06:00
source = ERP
PII = no
```

Un catalog gère ce type d'information.

---

## 🎼 108. Orchestration

L'orchestration coordonne l'exécution des étapes.

Pipeline :

```text
extract
↓
clean
↓
aggregate
↓
publish
```

Il faut garantir :

```text
l'ordre
les dépendances
la fréquence
les retries
les erreurs
```

---

## ⏰ 109. Scheduling ≠ Orchestration

### Scheduling

```text
exécuter cette tâche à 06:00
```

---

### Orchestration

```text
exécuter A
↓
si A réussit, lancer B et C
↓
quand B + C sont terminés, lancer D
↓
si C échoue, retry
↓
sinon alerte
```

L'orchestration est beaucoup plus riche.

---

## 🗓 110. BigQuery Scheduled Queries

BigQuery permet de planifier des requêtes récurrentes.

Exemple :

```text
Tous les jours 05:30 UTC
↓
CREATE OR REPLACE TABLE gold.daily_sales AS ...
```

Les scheduled queries BigQuery utilisent les mécanismes du BigQuery Data Transfer Service.

---

## 🧪 111. Exemple de Scheduled Query

SQL :

```sql
CREATE OR REPLACE TABLE gold.daily_sales AS
SELECT
  order_date,
  SUM(turnover) AS turnover
FROM silver.sales
GROUP BY order_date;
```

Puis :

```text
schedule
→ tous les jours
```

Le SQL reste le même.

C'est le système externe au SQL qui décide **quand** l'exécuter.

---

## 🔗 112. Dépendances

Supposons :

```text
silver.customers
```

doit exister avant :

```text
gold.customer_360
```

Si Gold s'exécute avant Silver :

```text
Gold peut utiliser des données anciennes
```

Un orchestrateur doit comprendre les dépendances.

---

## 🛠 113. Outils d'orchestration mentionnés

Le cours cite notamment :

```text
Airflow
dbt
Fivetran
scheduled tasks / queries
Stored Procedures
```

Attention :

ces outils n'ont pas tous exactement le même rôle.

---

## 🧩 114. dbt

dbt est principalement centré sur :

```text
transformations SQL
dépendances
tests
documentation
build
```

Il forme lui-même un graphe de modèles.

---

## 🌬 115. Airflow

Airflow est un orchestrateur généraliste.

Il définit des workflows sous forme de DAGs.

```text
task A
↓
task B
├─► task C
└─► task D
```

---

## 🚚 116. Fivetran

Fivetran est principalement un outil d'ingestion / EL.

Exemple :

```text
HubSpot
↓
Fivetran
↓
BigQuery raw
```

Il peut participer au pipeline mais ne remplace pas nécessairement toute l'orchestration analytique.

---

## 🧠 117. Choisir les outils selon les responsabilités

```text
Fivetran
→ déplacer / synchroniser la donnée
```

```text
dbt
→ transformer / tester / documenter
```

```text
Airflow
→ coordonner des workflows complexes
```

```text
BigQuery Scheduled Queries
→ planifier simplement du SQL récurrent
```

Les frontières peuvent se chevaucher.

---

## 👀 118. Observability

L'**observability** consiste à savoir si le pipeline fonctionne réellement.

Pas seulement :

```text
le job est vert
```

mais :

```text
les données sont-elles fraîches ?
le volume est-il normal ?
le schema a-t-il changé ?
les métriques sont-elles plausibles ?
```

---

## 📡 119. Les dimensions de l'observability

On peut surveiller :

```text
freshness
volume
schema
distribution
NULL
uniqueness
job duration
failure rate
cost
```

---

## 🐛 120. Pipeline « techniquement réussi » mais métier cassé

Exemple :

```text
job status = SUCCESS
```

mais :

```text
0 nouvelles lignes chargées
```

Le pipeline est techniquement terminé.

Mais la donnée est incorrecte.

D'où l'intérêt d'un contrôle :

```text
expected row count
```

---

## 🔢 121. Test de volume

```sql
SELECT
  COUNT(*) AS row_count
FROM silver.orders;
```

Puis comparer avec :

```text
historique
source
jour précédent
```

Une chute de 90 % peut déclencher une alerte.

---

## 🕳 122. Test de NULL

```sql
SELECT
  COUNTIF(customer_id IS NULL) AS null_customer_ids
FROM silver.orders;
```

Si `customer_id` devrait être obligatoire :

```text
0 attendu
```

---

## 🔑 123. Test d'unicité

```sql
SELECT
  order_id,
  COUNT(*) AS nb_rows
FROM gold.orders_model
GROUP BY order_id
HAVING COUNT(*) > 1;
```

Si :

```text
1 ligne = 1 commande
```

le résultat devrait être vide.

---

## 🧪 124. Test de conservation

Si un pipeline distribue ou agrège des montants :

```text
SUM avant
≈
SUM après
```

doit être vérifié lorsque la logique métier exige conservation.

Exemple :

```sql
SELECT
  SUM(turnover)
FROM source_sales;
```

vs :

```sql
SELECT
  SUM(turnover)
FROM final_sales;
```

---

## 🔁 125. Idempotency

Un pipeline **idempotent** peut être réexécuté sans créer d'effets indésirables.

Exemple problématique :

```text
run 1
→ append 1 000 lignes

run 2 identique
→ append encore les mêmes 1 000 lignes
```

Résultat :

```text
doublons
```

---

## ✅ 126. Exemple idempotent

```sql
CREATE OR REPLACE TABLE gold.daily_sales AS
SELECT
  ...
```

Pour le même état des sources :

```text
run 1
→ résultat X

run 2
→ résultat X
```

Pas :

```text
X + X
```

---

## 🧠 127. Pourquoi l'idempotency est essentielle

En production :

```text
jobs échouent
retries existent
replays existent
backfills existent
```

Si relancer un job casse la donnée :

```text
le pipeline est fragile
```

---

## 🔄 128. Full Refresh

Un full refresh reconstruit tout.

```text
source complète
↓
recalcul complet
↓
table finale remplacée
```

Avantages :

```text
simple
robuste
facile à comprendre
```

Inconvénient :

```text
coûteux sur gros volumes
```

---

## ➕ 129. Incremental Load

Un incremental load ne traite que :

```text
nouvelles données
ou
données modifiées
```

Exemple :

```text
MAX(updated_at) déjà chargé
↓
récupérer ce qui est plus récent
```

Avantages :

```text
moins de compute
plus rapide
```

Mais plus complexe.

---

## ⚠️ 130. Le piège des données modifiées tardivement

Si on charge uniquement :

```text
created_at > hier
```

mais qu'une ligne ancienne est modifiée aujourd'hui :

```text
elle peut être oubliée
```

D'où l'intérêt de comprendre :

```text
created_at
updated_at
business_date
ingestion_time
```

---

## 🔁 131. MERGE — aperçu

Pour un modèle incremental, on peut utiliser :

```sql
MERGE target AS t
USING source AS s
ON t.order_id = s.order_id
WHEN MATCHED THEN
  UPDATE SET ...
WHEN NOT MATCHED THEN
  INSERT (...);
```

Ce sujet appartient davantage aux chapitres Data Engineering / dbt avancés.

Mais il complète très bien le concept de pipeline.

---

## ⏪ 132. Backfill

Un **backfill** consiste à recalculer des périodes historiques.

Exemple :

```text
bug découvert sur le calcul de marge
↓
corriger SQL
↓
recalculer janvier → juillet
```

Un pipeline bien conçu doit pouvoir supporter ce type d'opération.

---

## 🧬 133. Schema evolution

Les sources changent.

Exemple :

```text
nouvelle colonne
colonne renommée
type modifié
champ supprimé
```

Un pipeline doit être capable de :

```text
détecter
supporter
ou échouer explicitement
```

plutôt que produire silencieusement un mauvais résultat.

---

## 🔍 134. Data Quality vs Observability

### Data Quality

```text
les données respectent-elles les règles ?
```

Exemple :

```text
order_id unique
turnover >= 0
country non NULL
```

---

### Observability

```text
le système se comporte-t-il normalement dans le temps ?
```

Exemple :

```text
refresh à l'heure
volume normal
durée stable
pas de schema drift
```

---

## 🧭 135. Data Lineage + Observability

Ensemble :

```text
quelque chose est cassé
↓
observability détecte
↓
lineage indique où chercher
↓
tests identifient la cause
```

C'est le cycle de debugging moderne.

---

## 🧑‍💻 136. Rôle du Data Analyst

Le cours fait une distinction intéressante.

Le Data Analyst peut :

```text
explorer
prototyper
construire un modèle
tester une logique
valider les KPI
```

Il n'est pas nécessairement responsable de toute l'industrialisation.

---

## 🏗 137. Rôle du Data Engineer

Le Data Engineer s'occupe souvent davantage de :

```text
ingestion
infrastructure
performance
orchestration
reliability
production
monitoring
```

Mais les frontières varient selon les entreprises.

---

## 🧱 138. Analytics Engineer — rôle intermédiaire

Une catégorie utile à connaître :

```text
Analytics Engineer
```

Souvent positionnée entre :

```text
Data Analyst
et
Data Engineer
```

Responsabilités fréquentes :

```text
SQL transformation
dbt
data modeling
tests
documentation
marts
```

---

## 🧠 139. Pourquoi un Data Analyst doit connaître les pipelines

Même sans gérer Airflow :

```text
l'analyst doit savoir d'où vient sa donnée
```

Sinon il ne peut pas bien répondre à :

```text
Pourquoi ce chiffre a changé ?
Quand est-il actualisé ?
Quelle table dois-je utiliser ?
Cette table est-elle Gold ou Raw ?
Puis-je faire confiance à ce KPI ?
```

---

## 🧭 140. Exemple end-to-end — e-commerce

Sources :

```text
Shopify
HubSpot
Google Ads
```

Pipeline :

```text
Shopify ───┐
           │
HubSpot ───┼──► ingestion ─► Bronze
           │                    │
Google Ads ┘                    ▼
                             Silver
                               │
                   ┌───────────┼───────────┐
                   ▼           ▼           ▼
              customers      orders       ads
                   └───────────┬───────────┘
                               ▼
                            Gold
                               │
             ┌─────────────────┼──────────────┐
             ▼                 ▼              ▼
         Power BI          Marketing       ML model
```

---

## 🧮 141. Exemple Silver

```sql
CREATE OR REPLACE TABLE silver.orders AS
SELECT
  CAST(order_id AS INT64) AS order_id,
  CAST(customer_id AS INT64) AS customer_id,
  DATE(order_timestamp) AS order_date,
  SAFE_CAST(turnover AS NUMERIC) AS turnover
FROM bronze.orders_raw
WHERE order_id IS NOT NULL;
```

---

## 🥇 142. Exemple Gold

```sql
CREATE OR REPLACE TABLE gold.daily_sales
PARTITION BY order_date
AS
SELECT
  order_date,
  COUNT(DISTINCT order_id) AS orders,
  SUM(turnover) AS turnover
FROM silver.orders
GROUP BY order_date;
```

---

## 👁 143. Exemple View métier

```sql
CREATE VIEW reporting.sales_last_90_days AS
SELECT
  order_date,
  orders,
  turnover
FROM gold.daily_sales
WHERE order_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY);
```

Le dashboard n'a besoin de connaître que :

```text
reporting.sales_last_90_days
```

---

## 🔒 144. Exemple View de sécurité

```sql
CREATE VIEW client_views.company_42_sales AS
SELECT
  order_date,
  turnover
FROM gold.sales
WHERE company_id = 42;
```

Puis accès contrôlé sur cette vue.

---

## ⚙️ 145. Exemple de refresh quotidien

```text
02:00 ingestion sources
↓
02:20 bronze terminé
↓
02:25 Silver
↓
02:40 Gold
↓
03:00 reporting ready
```

Le dashboard à 08:00 consomme donc les données de la nuit.

---

## 🧠 146. SLA / SLO de fraîcheur — aperçu

Un pipeline professionnel peut définir :

```text
Données disponibles avant 07:00
```

ou :

```text
retard maximum : 30 minutes
```

Ce type de contrat permet de mesurer :

```text
reliability
```

---

## 🛑 147. Anti-pattern : dashboard directement sur 20 tables Raw

```text
Power BI
↓
gros JOINs
↓
raw tables
```

Risques :

```text
logique métier dupliquée
performance variable
coût élevé
difficile à tester
difficile à tracer
```

Préférer souvent :

```text
Gold model
↓
BI
```

---

## 🛑 148. Anti-pattern : chaîne de views très profonde

Exemple :

```text
view A
↓
view B
↓
view C
↓
view D
↓
view E
```

Cela peut :

```text
masquer énormément de logique
complexifier le lineage
recalculer beaucoup de sources
rendre le debugging difficile
```

Une matérialisation intermédiaire peut devenir utile.

---

## 🛑 149. Anti-pattern : matérialiser chaque ligne de SQL

Inversement :

```text
table_step_1
table_step_2
table_step_3
...
table_step_29
```

crée une explosion d'objets.

La bonne architecture est un compromis.

---

## 🛑 150. Anti-pattern : `SELECT *` dans les modèles finaux

Dans un pipeline durable :

```sql
SELECT *
```

peut créer des surprises si la source ajoute une colonne.

Exemple :

```text
nouvelle colonne sensible
↓
SELECT *
↓
elle apparaît dans Gold
↓
elle arrive dans le dashboard
```

Préférer les colonnes explicites dans les modèles critiques.

---

## 🛑 151. Anti-pattern : choisir la partition sans connaître les requêtes

Partitionner par :

```text
created_at
```

alors que toutes les requêtes filtrent :

```text
business_date
```

peut réduire fortement l'intérêt du partitionnement.

Architecture physique et usage doivent être alignés.

---

## 🧪 152. Pattern de debugging d'un pipeline

Lorsqu'un résultat est faux :

```text
1. vérifier le Gold
2. vérifier le Silver
3. vérifier le Bronze
4. vérifier la source
```

À chaque étape :

```text
row count
SUM
distinct keys
NULL
dates
```

---

## 🧪 153. Comparaison étape par étape

Exemple :

```sql
SELECT
  COUNT(*) AS rows,
  COUNT(DISTINCT order_id) AS orders,
  SUM(turnover) AS turnover
FROM bronze.sales;
```

Puis même requête sur :

```text
silver.sales
gold.sales
```

Cela permet de voir :

```text
où une métrique diverge
```

---

## 🎯 154. Pattern de validation de pipeline

Avant production :

```text
Source total
↓
Raw total
↓
Clean total
↓
Model total
```

Documenter les différences attendues.

Exemple :

```text
Raw: 1 000 000 lignes
Silver: 995 000 lignes
```

Pourquoi ?

```text
5 000 doublons supprimés
```

La différence devient explicable.

---

## 🧠 155. Question fondamentale : matérialiser ou calculer à la volée ?

```text
calcul fréquent ?
volume important ?
résultat réutilisé ?
latence importante ?
fraîcheur nécessaire ?
```

Ces questions déterminent :

```text
table
view
materialized view
```

---

## 📊 156. Matrice décisionnelle

| Situation | Option probable |
|---|---|
| logique légère + fraîcheur maximale | View |
| calcul lourd + usage fréquent | Table |
| agrégation répétée + compatible | Materialized View |
| logique uniquement dans une requête | CTE |
| expérimentation / script | Temp Table |
| SQL à réouvrir manuellement | Saved Query |

---

## 🧠 157. Question fondamentale : full refresh ou incremental ?

```text
petite table ?
↓
full refresh souvent suffisant

table énorme ?
↓
incremental à envisager
```

Mais :

```text
simplicité
```

a une valeur.

Un incremental mal construit peut produire des erreurs plus graves que le coût d'un full refresh.

---

## 🧠 158. Question fondamentale : fréquence de refresh

```text
Le business a-t-il besoin :
- du temps réel ?
- de 15 min ?
- d'une heure ?
- quotidien ?
- hebdomadaire ?
```

La fréquence doit venir du besoin.

Pas de la possibilité technique.

---

## 🧠 159. Question fondamentale : qui consomme la table ?

```text
Data Analyst
BI
Machine Learning
Finance
Marketing
client externe
API
```

La structure Gold peut être différente selon le consommateur.

---

## 🔐 160. Pipeline et permissions

Une bonne architecture permet aussi de séparer :

```text
Raw
→ accès Data Engineering

Silver
→ accès Data Team

Gold
→ accès Analytics / BI

Authorized Views
→ accès externe limité
```

Le pipeline devient une frontière de sécurité.

---

## 🧠 161. Freshness vs correctness

Une donnée :

```text
mise à jour il y a 5 minutes
```

mais incorrecte n'est pas utile.

À l'inverse :

```text
parfaitement correcte
mais âgée de 3 semaines
```

peut être inutilisable.

Deux dimensions :

```text
freshness
+
quality
```

---

## 🧮 162. Freshness test

Exemple :

```sql
SELECT
  MAX(updated_at) AS latest_update
FROM gold.orders;
```

Puis comparer à :

```text
heure actuelle
```

---

## ⏳ 163. Latency de pipeline

On peut mesurer :

```text
source event time
↓
available in Gold
```

Différence :

```text
pipeline latency
```

Exemple :

```text
transaction : 10:00
Gold disponible : 10:17
latency = 17 min
```

---

## 💰 164. Coût total d'une architecture

Ne regarder que :

```text
storage
```

ou :

```text
query cost
```

isolément est insuffisant.

Coût global :

```text
storage
+
compute
+
orchestration
+
ingestion
+
network
+
maintenance humaine
```

---

## 🧠 165. Performance ≠ seulement durée de requête

Une architecture performante est aussi :

```text
prévisible
scalable
fiable
maintenable
```

Une query de 2 secondes mais impossible à comprendre peut être pire qu'une query de 4 secondes bien structurée.

---

## 🏛 166. Data Governance — aperçu

Une plateforme mature doit également répondre à :

```text
Qui possède cette donnée ?
Qui peut la voir ?
Que signifie-t-elle ?
Combien de temps la garde-t-on ?
Contient-elle de la PII ?
```

Le pipeline n'est qu'une partie de cette gouvernance.

---

## 🧠 167. Data Contract — aperçu

Un **data contract** formalise ce qu'une source promet.

Exemple :

```text
order_id
→ INT64
→ non NULL
→ unique

order_date
→ DATE
→ obligatoire
```

Si la source change :

```text
le contrat est violé
```

C'est une manière moderne de sécuriser les pipelines.

---

## 🔄 168. Data lineage manuel vs automatique

Petit pipeline :

```text
documentation Markdown
+
diagramme
```

peut suffire.

Grande plateforme :

```text
lineage automatique
catalog
metadata APIs
```

devient beaucoup plus utile.

BigQuery / Dataplex peuvent enregistrer du lineage pour différents jobs.

---

## 🧠 169. Query lineage

Exemple :

```sql
CREATE TABLE gold.sales AS
SELECT ...
FROM silver.sales;
```

Le système peut identifier :

```text
silver.sales
→ gold.sales
```

Cette relation est exactement ce qui alimente un graphe de lineage.

---

## 📉 170. Partition pruning et coût

Exemple :

Table :

```text
365 partitions quotidiennes
```

Requête :

```sql
WHERE order_date = DATE '2026-07-17'
```

BigQuery peut ignorer :

```text
364 partitions
```

Ce mécanisme réduit :

```text
bytes scanned
```

et donc potentiellement :

```text
latence + coût
```

---

## ⚠️ 171. Écrire un filtre compatible avec le pruning

Le moteur doit pouvoir identifier les partitions utiles.

Préférer une condition directe :

```sql
WHERE order_date >= DATE '2026-07-01'
  AND order_date < DATE '2026-08-01'
```

plutôt que des transformations inutilement complexes sur la colonne de partition.

---

## 🧪 172. Vérifier le pruning

Ne pas supposer.

Comparer l'estimation de bytes :

```text
query sans filtre
vs
query avec filtre de partition
```

C'est une excellente expérience à faire dans BigQuery.

---

## 🔬 173. Expérience BigQuery recommandée

### Query A

```sql
SELECT
  order_id,
  turnover
FROM big_table;
```

Noter :

```text
bytes processed
```

---

### Query B

```sql
SELECT
  order_id
FROM big_table;
```

Comparer.

---

### Query C

```sql
SELECT
  order_id
FROM big_table
WHERE partition_date = DATE '2026-07-17';
```

Comparer encore.

Cette expérience rend concrète la logique de stockage colonnaire + partition pruning.

---

## 🧪 174. Expérience View vs Table

Créer une logique lourde :

```sql
SELECT
  customer_id,
  SUM(turnover)
FROM sales
GROUP BY customer_id;
```

Version :

```text
View
```

et version :

```text
Table
```

Puis comparer :

```text
query duration
bytes processed
job details
```

C'est exactement le type de challenge pédagogique décrit dans le cours.

---

## 🧠 175. Attention au cache pendant les comparaisons

Si on exécute deux fois la même requête :

```text
la seconde peut utiliser le cache
```

Donc une comparaison naïve de performance peut être trompeuse.

Lors d'un benchmark :

```text
comprendre les job details
```

est indispensable.

---

## 🧠 176. Performance : toujours mesurer

Éviter :

```text
« une view est toujours lente »
```

ou :

```text
« une table est toujours meilleure »
```

Mesurer :

```text
latence
bytes
fréquence
coût
freshness
```

---

## 🧠 177. L'optimiseur BigQuery existe

SQL est déclaratif.

On exprime :

```text
ce qu'on veut
```

BigQuery décide en grande partie :

```text
comment l'exécuter
```

Donc une représentation pédagogique du pipeline physique reste une approximation.

---

## 🚦 178. Pipeline states

On peut donner à chaque étape un état :

```text
not started
running
success
failed
skipped
```

Un orchestrateur peut alors décider :

```text
si parent failed
→ ne pas lancer enfant
```

---

## 🔁 179. Retry

Une API peut échouer temporairement.

Pattern :

```text
attempt 1
↓ fail
wait
↓
attempt 2
↓ success
```

C'est différent d'une erreur SQL déterministe.

Un orchestrateur doit savoir gérer les deux.

---

## 🚨 180. Alerting

Si une étape critique échoue :

```text
Slack
email
PagerDuty
ticket
```

peut être déclenché.

L'observability n'a de valeur que si quelqu'un peut agir.

---

## 🧠 181. Dependency freshness

Même si :

```text
Gold refresh = success
```

si Silver n'avait pas été mis à jour :

```text
Gold peut être techniquement correct
mais basé sur de vieilles données
```

Il faut surveiller les dépendances.

---

## 🕒 182. Scheduling en UTC

Les plateformes cloud planifient souvent en UTC ou convertissent les horaires.

Important avec :

```text
heure d'été
DST
fuseaux
```

Pour les Scheduled Queries BigQuery, la configuration est convertie en UTC.

---

## 🧠 183. Timezone et pipelines

Exemple :

```text
« ventes du jour »
```

peut signifier :

```text
jour UTC
ou
jour Europe/Paris
ou
jour America/New_York
```

Les partitions et KPI doivent partager la même définition temporelle.

---

## 📚 184. Naming convention

Une architecture claire peut utiliser :

```text
bronze_
silver_
gold_
```

ou datasets :

```text
raw
staging
marts
```

Exemple dbt :

```text
sources
staging
intermediate
marts
```

La taxonomie compte moins que :

```text
cohérence + documentation
```

---

## 🧠 185. Bronze/Silver/Gold vs staging/marts

Correspondance approximative :

```text
Bronze
≈ raw / sources

Silver
≈ staging / intermediate

Gold
≈ marts / business models
```

Mais ce n'est pas une équivalence universelle.

---

## 🧩 186. Un pipeline peut contenir des branches

Ce n'est pas forcément :

```text
A → B → C → D
```

Mais :

```text
           ┌─► marketing_mart
raw ─► clean
           ├─► finance_mart
           └─► ml_features
```

Le graphe devient central.

---

## 🔁 187. Réutiliser une même étape

Une bonne table Silver :

```text
customers_clean
```

peut servir à :

```text
marketing
finance
CRM analytics
ML
```

Cela évite de réimplémenter le nettoyage plusieurs fois.

---

## 🛑 188. Metric duplication

Si plusieurs dashboards recalculent chacun :

```text
revenue
```

avec des règles différentes :

```text
Finance revenue ≠ Marketing revenue
```

Créer un modèle Gold partagé permet d'établir :

```text
single source of truth
```

---

## 🏆 189. Gold comme couche sémantique simplifiée

Un bon Gold doit permettre à un analyste de poser :

```sql
SELECT
  month,
  revenue
FROM finance_monthly;
```

plutôt que refaire :

```text
7 JOIN
5 CASE
3 exclusions
2 agrégations
```

à chaque requête.

---

## 🧠 190. Mais attention à la « single source of truth »

Le même concept peut avoir plusieurs définitions légitimes.

Exemple :

```text
Revenue Finance
Revenue Sales
Revenue Accounting
```

Le modèle doit documenter la définition.

Pas simplement appeler une colonne :

```text
revenue
```

et supposer que tout le monde est d'accord.

---

## 📝 191. Documentation minimale d'un modèle Gold

Pour chaque table :

```text
objectif
granularité
primary key logique
sources
refresh
owner
métriques
dimensions
tests
```

Exemple :

```text
Table: gold.orders
Grain: 1 row = 1 order
Refresh: daily 05:00 UTC
Key: order_id
Source: silver.orders + silver.customers
```

---

## 🧠 192. La granularité reste centrale

Pipeline ou pas, toujours demander :

```text
1 ligne = quoi ?
```

Bronze :

```text
1 ligne = event brut
```

Silver :

```text
1 ligne = order cleaned
```

Gold :

```text
1 ligne = customer-month
```

Changer de grain est une transformation majeure.

---

## ⚠️ 193. Pipeline et JOINs

Le chapitre Joins reste directement lié.

Si :

```text
sales = grain product/order
```

et :

```text
logistics = grain order
```

une jointure directe peut dupliquer :

```text
logistics_cost
```

Le pipeline doit souvent :

```text
agréger avant join
```

ou redistribuer correctement la métrique.

---

## 🧠 194. Pipeline et Window Functions

Une Window Function peut être utilisée dans Silver/Gold pour :

```text
déduplication
ranking
distribution
latest record
```

Exemple :

```sql
ROW_NUMBER() OVER (
  PARTITION BY customer_id
  ORDER BY updated_at DESC
)
```

permet d'identifier la dernière version d'un client.

---

## 🧠 195. Pipeline et Date Functions

Dates essentielles pour :

```text
partitioning
incremental loads
freshness
daily models
backfills
```

Les fonctions Date & Time ne sont donc pas seulement des fonctions analytiques.

Elles participent directement à l'architecture.

---

## 🧠 196. Pipeline et dbt

Les notions de ce chapitre seront réutilisées directement dans dbt :

```text
models
materializations
ref()
sources
tests
DAG
incremental
snapshots
```

dbt formalise beaucoup des idées vues ici.

---

## 🧭 197. Table vs View dans dbt — passerelle

Conceptuellement :

```text
{{ config(materialized='view') }}
```

ou :

```text
{{ config(materialized='table') }}
```

réutilisent précisément l'arbitrage :

```text
freshness
performance
storage
compute
```

---

## 🧠 198. Le rôle de `ref()` — passerelle

Dans dbt :

```text
ref('stg_orders')
```

exprime une dépendance.

Cela permet de construire :

```text
data lineage
+
DAG
```

automatiquement.

Ce chapitre prépare donc directement à comprendre dbt.

---

## 🧠 199. Le mot « pipeline » peut désigner plusieurs niveaux

Selon le contexte :

```text
pipeline ingestion
pipeline transformation
pipeline ML
pipeline BI
pipeline complet
```

Toujours demander :

```text
où commence-t-il ?
où finit-il ?
```

---

## 🧪 200. Exemple de design complet

```text
SOURCE
ERP orders
   │
   ▼
INGESTION
Fivetran
   │
   ▼
BRONZE
raw.orders
   │
   ▼
SILVER
stg_orders
- cast
- dedupe
- null handling
   │
   ├───────────────┐
   │               │
   ▼               ▼
stg_customers    stg_products
   │               │
   └──────┬────────┘
          ▼
GOLD
fct_orders
dim_customer
dim_product
          │
          ▼
REPORTING
Power BI
```

---

## 🧠 201. Où placer les tests ?

Partout où un contrat important existe.

```text
Raw → Silver
```

tests :

```text
type
NULL
uniqueness
```

```text
Silver → Gold
```

tests :

```text
grain
metric conservation
relationships
```

```text
Gold → BI
```

tests :

```text
freshness
KPI plausibility
```

---

## 🔎 202. Où placer le lineage ?

Le lineage n'est pas une étape.

Il est la **description transversale** de toutes les étapes.

```text
          lineage
┌───────────────────────────────┐
source → bronze → silver → gold → BI
└───────────────────────────────┘
```

---

## 👀 203. Où placer l'observability ?

Même logique.

```text
source
  ↓   ◄ monitoring
bronze
  ↓   ◄ monitoring
silver
  ↓   ◄ monitoring
gold
  ↓   ◄ monitoring
BI
```

---

## 🎼 204. Où placer l'orchestration ?

L'orchestration pilote le graphe.

```text
                ORCHESTRATOR
                     │
      ┌──────────────┼──────────────┐
      ▼              ▼              ▼
 ingestion       transformations   tests
      │              │              │
      └──────────────┴──────────────┘
                     │
                     ▼
                  publish
```

---

## 📊 205. Où placer Power BI / Looker ?

Ils sont généralement :

```text
consommateurs
```

du pipeline.

Leur rôle principal n'est pas :

```text
réparer une donnée source incorrecte
```

Même si les BI tools peuvent eux-mêmes faire de la modélisation et des transformations.

---

## ⚖️ 206. Transformation dans BI ou dans Warehouse ?

Possible :

```text
Power BI
→ Power Query / DAX
```

Mais si plusieurs consommateurs ont besoin de la même logique :

```text
warehouse / dbt
```

est souvent plus central et réutilisable.

Question :

> Cette règle métier doit-elle exister une seule fois ou dans chaque dashboard ?

---

## 🧠 207. Push-down de logique

Lorsque possible, exécuter certaines transformations dans le warehouse peut permettre :

```text
centralisation
scalabilité
réutilisation
```

Mais cela dépend de :

```text
latence
coûts
ownership
outils
```

Encore une fois : pas de dogme.

---

## 🧰 208. Cheat sheet — concepts

```text
Data Pipeline
→ chaîne de déplacement / transformation des données

ETL
→ Extract → Transform → Load

ELT
→ Extract → Load → Transform

Bronze
→ brut

Silver
→ propre

Gold
→ métier

OLTP
→ transactionnel

OLAP
→ analytique

Data Warehouse
→ plateforme analytique

Data Lineage
→ provenance + transformations

Orchestration
→ coordination des tâches

Observability
→ savoir si le pipeline fonctionne correctement
```

---

## 🧰 209. Cheat sheet — objets

```text
Table
→ données matérialisées

View
→ SQL persistant, données non matérialisées

Materialized View
→ résultats précalculés / maintenus

CTE
→ étape logique temporaire dans une query

Saved Query
→ code SQL enregistré

Temporary Table
→ données matérialisées temporairement
```

---

## 🧰 210. Cheat sheet — performance BigQuery

```text
éviter SELECT *
sélectionner les colonnes nécessaires
Preview pour explorer
LIMIT ≠ garantie de réduction des bytes
utiliser les filtres de partition
partitionner les grosses tables adaptées
clusteriser selon les patterns de filtres
regarder bytes processed
utiliser dry run
comprendre le cache
matérialiser les calculs lourds réutilisés
```

---

## 🧰 211. Cheat sheet — partitioning

```text
PARTITION BY
→ une colonne / logique de partition

partition pruning
→ ignorer les partitions inutiles

time-unit partitioning
→ selon valeur DATE/TIMESTAMP/DATETIME

ingestion-time
→ selon moment d'arrivée

integer-range
→ selon plages d'entiers
```

---

## 🧰 212. Cheat sheet — clustering

```text
CLUSTER BY
→ organise les blocs

plusieurs colonnes possibles
ordre des colonnes important
compatible avec partitioning
automatic reclustering BigQuery
```

---

## 🧠 213. Questions à se poser avant de créer une table

```text
Quel est le grain ?
Quelle est la clé ?
Qui la consomme ?
À quelle fréquence ?
Quelle fraîcheur ?
Combien de données ?
Quels filtres fréquents ?
Partition ?
Cluster ?
Quels tests ?
Qui en est owner ?
```

---

## 🧠 214. Questions à se poser avant de créer une view

```text
La logique est-elle réutilisée ?
La freshness est-elle importante ?
Le coût de recalcul est-il acceptable ?
La latence est-elle acceptable ?
Ai-je besoin d'une couche de sécurité ?
La logique doit-elle être cachée aux consommateurs ?
```

---

## 🧠 215. Questions à se poser avant de matérialiser

```text
Combien de fois ce calcul est-il exécuté ?
Le résultat change-t-il souvent ?
Combien coûte son recalcul ?
Quelle latence est tolérable ?
Puis-je orchestrer son refresh ?
```

---

## 🧠 216. Questions à se poser avant de partitionner

```text
La table est-elle suffisamment volumineuse ?
Quelle colonne est utilisée dans les filtres ?
Les partitions seront-elles suffisamment grosses ?
Les dates sont-elles métier ou ingestion ?
Ai-je besoin d'estimer les coûts avant run ?
```

---

## 🧠 217. Questions à se poser avant de clusteriser

```text
Quelles colonnes sont souvent filtrées ?
Ont-elles une forte cardinalité utile ?
Quel est l'ordre des filtres ?
Puis-je combiner avec une partition ?
```

---

## ✅ 218. Checklist Pipeline — conception

- [ ] Je connais les systèmes sources.
- [ ] Je sais ce qu'une ligne représente dans chaque source.
- [ ] Je sais où commence et où finit le pipeline.
- [ ] Je distingue Bronze / Silver / Gold ou leur équivalent.
- [ ] Chaque transformation a un objectif clair.
- [ ] Les dépendances sont explicites.
- [ ] Les clés sont testées.
- [ ] Les métriques critiques sont contrôlées.
- [ ] La fraîcheur attendue est définie.
- [ ] Le mode full / incremental est choisi.
- [ ] Le pipeline est rejouable.
- [ ] Les erreurs peuvent être détectées.
- [ ] Le lineage est compréhensible.

---

## ✅ 219. Checklist BigQuery — coût & performance

- [ ] Je n'utilise pas `SELECT *` inutilement.
- [ ] Je regarde les bytes estimés.
- [ ] Je ne considère pas `LIMIT` comme contrôle de coût.
- [ ] Je filtre sur la colonne de partition quand c'est pertinent.
- [ ] Je comprends le type de partitioning.
- [ ] Je sais quelles colonnes sont clusterisées.
- [ ] Je comprends si une view recalculera une grosse logique.
- [ ] Je matérialise les calculs lourds quand cela apporte une vraie valeur.
- [ ] Je tiens compte du cache lors des benchmarks.
- [ ] Je distingue stockage et compute.

---

## 🎤 220. Questions d'entretien — niveau Junior Data Analyst

### Qu'est-ce qu'un data pipeline ?

Réponse :

> Une chaîne d'étapes permettant de déplacer, transformer, contrôler et publier des données depuis des systèmes sources jusqu'à des consommateurs comme un dashboard ou un modèle analytique.

---

### Différence entre ETL et ELT ?

```text
ETL
→ transformation avant chargement final

ELT
→ chargement dans le warehouse puis transformation
```

---

### Différence entre Table et View ?

> Une table matérialise les données, alors qu'une logical view stocke une requête et réévalue sa logique lorsqu'on l'interroge.

---

### Pourquoi une table peut-elle être plus rapide qu'une view ?

> Parce que les transformations ont déjà été calculées et matérialisées, alors qu'une view peut devoir relire ses sources et réexécuter sa logique.

---

### Pourquoi utiliser une view ?

```text
réutilisation
abstraction
fraîcheur
sécurité
```

---

## 🎤 221. Questions d'entretien — OLTP / OLAP

### OLTP ?

```text
transactionnel
beaucoup de petites opérations
writes rapides
applications métier
```

### OLAP ?

```text
analytique
lectures volumineuses
agrégations
historique
BI
```

---

## 🎤 222. Questions d'entretien — Partitioning

### Qu'est-ce que le partitioning ?

> Une manière de segmenter une table en partitions selon une clé comme une date afin que BigQuery puisse ignorer les partitions inutiles lors de requêtes compatibles.

---

### Pourquoi cela réduit-il les coûts ?

Parce que :

```text
moins de données scannées
```

peut signifier :

```text
moins de bytes processed
```

en on-demand.

---

## 🎤 223. Questions d'entretien — Clustering

### Différence avec partitioning ?

> Le partitioning crée des partitions explicites selon une seule clé de partitionnement, tandis que le clustering organise les blocs de stockage selon plusieurs colonnes possibles afin de faciliter le block pruning.

---

## 🎤 224. Questions d'entretien — Lineage

### Qu'est-ce que le data lineage ?

> La capacité à retracer l'origine d'une donnée, les transformations qu'elle a subies et les objets qui en dépendent.

---

## 🎤 225. Questions d'entretien — Orchestration

### Scheduling vs orchestration ?

> Scheduling signifie principalement « quand lancer une tâche ». L'orchestration gère également l'ordre, les dépendances, les conditions, les retries et les erreurs entre plusieurs tâches.

---

## 🎤 226. Questions d'entretien — Observability

> L'observability consiste à surveiller non seulement si les jobs s'exécutent, mais aussi la fraîcheur, les volumes, les schémas, les anomalies et la qualité globale du pipeline.

---

## 🎤 227. Question piège : `LIMIT 10` réduit-il le coût BigQuery ?

Réponse :

> Pas comme règle générale. Sur une table non clusterisée, `LIMIT` limite le nombre de lignes retournées mais ne réduit pas le volume lu pour les colonnes demandées. Il ne faut donc pas utiliser `LIMIT` comme contrôle de coût.

---

## 🎤 228. Question piège : une CTE est-elle matérialisée en mémoire ?

Réponse :

> Non, pas nécessairement. Une CTE est avant tout une construction logique de requête. BigQuery peut l'inliner ou la réévaluer selon les choix de l'optimiseur.

---

## 🎤 229. Question piège : une ligne ancienne chargée aujourd'hui va-t-elle dans la mauvaise partition ?

Réponse :

> Cela dépend du type de partitioning. Si la table est partitionnée sur une colonne métier de type DATE/TIMESTAMP/DATETIME, BigQuery place la ligne selon cette valeur. Si elle est partitionnée par ingestion time, la partition dépend du moment de chargement.

---

## 🧠 230. Les dix idées à retenir absolument

1. **Un pipeline est plus qu'une transformation SQL.**
2. **Bronze / Silver / Gold séparent les niveaux de maturité de la donnée.**
3. **OLTP sert les transactions ; OLAP sert l'analyse.**
4. **Une Table stocke le résultat ; une View stocke principalement la logique.**
5. **Freshness, performance et coût sont en tension.**
6. **Le lineage explique d'où vient un KPI.**
7. **L'orchestration garantit l'ordre et la répétition des tâches.**
8. **`SELECT *` peut être coûteux dans BigQuery.**
9. **Partitioning et clustering servent à éviter des lectures inutiles.**
10. **Un pipeline fiable doit être testable, observable et rejouable.**

---

## 🔎 231. Corrections / précisions Brocode par rapport au cours

Cette section est volontairement explicite afin de ne pas mémoriser des simplifications pédagogiques comme des vérités techniques.

### Pipeline

Le pipeline ne correspond pas uniquement à :

```text
Transform
```

Il peut englober extraction, chargement, transformation, tests, publication et orchestration.

---

### OLTP / OLAP

```text
OLTP = row-oriented
OLAP = column-oriented
```

est une intuition courante, pas la définition.

Les termes décrivent d'abord des workloads.

---

### Views

Une logical view BigQuery :

```text
stocke la logique SQL
```

et sa requête est exécutée lorsque la view est interrogée.

---

### Authorized Views

Le terme BigQuery à retenir pour partager un sous-ensemble de données avec accès indirect aux sources est :

```text
Authorized View
```

---

### CTE

Une CTE n'est pas garantie :

```text
stockée en mémoire
```

ni :

```text
matérialisée une fois
```

BigQuery peut la réévaluer.

---

### Materialized View

Ce n'est pas simplement une « table stable ».

C'est une vue précalculée et maintenue selon des mécanismes BigQuery.

---

### Pricing BigQuery

BigQuery dispose aujourd'hui de modèles :

```text
on-demand
capacity-based
```

La vieille opposition « pay-as-you-go vs flat pricing » ne décrit plus suffisamment le produit.

---

### `LIMIT`

`LIMIT` :

```text
limite les lignes retournées
```

mais ne réduit pas automatiquement les bytes lus.

---

### Partitioning

Le seuil :

```text
> 2 GB
```

ne doit pas être mémorisé comme règle officielle.

La documentation recommande de raisonner selon la taille moyenne des partitions, la distribution et les workloads.

---

### Late-arriving rows

Une ligne datée du 1er mais chargée le 5 va bien dans la partition du 1er lorsque la table est partitionnée sur cette colonne de date métier.

La logique diffère avec ingestion-time partitioning.

---

### Clustering

Clustering n'est pas simplement :

```text
partitioning avec plusieurs colonnes
```

Il organise les blocs de stockage selon plusieurs colonnes possibles.

---

### « partitions qui se désorganisent »

BigQuery gère les partitions et effectue notamment un reclustering automatique pour les tables clusterisées.

Le vrai enjeu est surtout :

```text
mauvaise stratégie
petites partitions
mauvais filtre
skew
```

---

### Data Catalog

Google Cloud a remplacé l'ancien Data Catalog par :

```text
Dataplex Universal Catalog
```

Les concepts de catalog, metadata et lineage restent les mêmes.

---

## 🔗 232. Liens avec les autres chapitres Brocode

```text
Intro SQL
→ modèle relationnel, BigQuery, coûts
```

```text
Joins & Testing
→ granularité, duplication, validation
```

```text
CTEs & Subqueries
→ décomposer les transformations
```

```text
Window Functions
→ déduplication et calculs analytiques
```

```text
Date & Time
→ partitions, incremental, freshness
```

```text
dbt
→ matérialise concrètement DAG + models + tests + lineage
```

Ce chapitre constitue donc la passerelle entre :

```text
savoir écrire du SQL
```

et :

```text
savoir comprendre une plateforme data
```

---

## 📚 233. Sources officielles de vérification technique

Le contenu principal vient du cours Le Wagon et de sa transcription.

Les précisions techniques ont été vérifiées dans la documentation officielle BigQuery / Google Cloud, notamment :

- BigQuery — Logical Views  
  https://cloud.google.com/bigquery/docs/views-intro

- BigQuery — Logical vs Materialized Views  
  https://cloud.google.com/bigquery/docs/logical-materialized-view-overview

- BigQuery — Materialized Views  
  https://cloud.google.com/bigquery/docs/materialized-views-intro

- BigQuery — Pricing  
  https://cloud.google.com/bigquery/pricing

- BigQuery — Query cost best practices  
  https://cloud.google.com/bigquery/docs/best-practices-costs

- BigQuery — Query computation best practices  
  https://cloud.google.com/bigquery/docs/best-practices-performance-compute

- BigQuery — Partitioned Tables  
  https://cloud.google.com/bigquery/docs/partitioned-tables

- BigQuery — Querying Partitioned Tables  
  https://cloud.google.com/bigquery/docs/querying-partitioned-tables

- BigQuery — Clustered Tables  
  https://cloud.google.com/bigquery/docs/clustered-tables

- BigQuery — Scheduled Queries  
  https://cloud.google.com/bigquery/docs/scheduling-queries

- Google Cloud / Dataplex — Data Lineage  
  https://cloud.google.com/data-catalog/docs/how-to/track-lineage

---

## 🏁 234. Résumé final

Le SQL vu précédemment apprend à faire :

```text
SELECT
JOIN
GROUP BY
CASE
Window Functions
```

Ce chapitre ajoute une nouvelle dimension :

```text
Quand ce SQL doit tourner demain,
puis après-demain,
puis tous les jours,
pour plusieurs utilisateurs,
sur des milliards de lignes,
sans perdre la qualité,
sans exploser les coûts,
comment l'organiser ?
```

La réponse est :

```text
DATA PIPELINE
```

Le pipeline organise :

```text
les sources
↓
les transformations
↓
les objets
↓
les dépendances
↓
les refresh
↓
les tests
↓
les consommateurs
```

Et les choix :

```text
Table
vs
View
vs
Materialized View

OLTP
vs
OLAP

Full
vs
Incremental

Partitioning
vs
Clustering
```

ne sont pas des choix isolés.

Ils répondent tous au même problème :

> **Transformer une donnée brute en une donnée fiable, rapide, explicable, disponible et économiquement soutenable.**

C'est exactement le moment où l'on quitte progressivement :

```text
« j'écris une requête SQL »
```

pour commencer à raisonner :

```text
« je construis un système analytique »
```
