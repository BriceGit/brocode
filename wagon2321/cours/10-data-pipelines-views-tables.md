---
title: "SQL — Data Pipelines, Views & Tables"
aliases:
  - "Data Pipelines"
  - "Views vs Tables vs CTEs"
  - "OLTP vs OLAP"
  - "Medallion Architecture"
  - "Partitioning & Clustering"
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 10
date: 2026-07-17
language: "SQL"
database: "BigQuery / GoogleSQL"
topics:
  - "SQL"
  - "BigQuery"
  - "Data Warehousing"
  - "Data Pipelines"
  - "Views"
  - "Tables"
  - "OLAP"
  - "OLTP"
  - "Partitioning"
  - "Data Modeling"
tags:
  - brocode
  - wagon2321/cours
---

# 10 - Data Pipelines, Views & Tables

**Date :** 17 juillet 2026
**Thème :** Data Pipelines, Views, Tables & architecture d'entrepôt de données — dernier cours SQL du module
**Intervenant :** formateur anglophone (Data Science / Data Engineering / Data Analytics), session longue (87 slides)

---

## 🎯 TL;DR

- **Table** = données stockées physiquement (rapide, figé) · **View** = requête sauvegardée, ré-exécutée à chaque appel (frais, mais payée à chaque fois) · **CTE** = bloc temporaire en mémoire, n'existe que pendant la requête — ce n'est **pas** un objet de base de données
- **OLTP** (lignes, transactionnel, ex. Salesforce) ≠ **OLAP** (colonnes, analytique, ex. BigQuery) : si un dashboard est lent, la première question est *"est-ce qu'on tape un système OLTP de prod ?"*
- Architecture **Medallion** : Bronze (brut) → Silver (nettoyé) → Gold (agrégé, prêt business)
- En BigQuery, le coût = **volume de données scanné**, pas le nombre de lignes retournées → `SELECT *` coûte cher, `LIMIT` ne réduit **pas** le coût
- **Partitioning** (1 seule colonne, souvent une date) et **Clustering** (plusieurs colonnes) réduisent le volume scanné donc le coût

---

## 🏗️ Architecture Medallion (Bronze / Silver / Gold)

Concept clé que le formateur regrette de ne pas voir nommé explicitement dans les slides — à connaître par cœur, très fréquent en entretien.

| Couche | Contenu | Objectif |
|---|---|---|
| 🥉 **Bronze** | Copie brute des données sources, sans transformation | Avoir une trace fidèle de la source |
| 🥈 **Silver** | Nettoyage, filtrage, compréhension des caractéristiques des données | Rendre la donnée fiable et exploitable |
| 🥇 **Gold** | Données enrichies, agrégées, modélisées | Consommation directe : dashboards, ML, KPIs |

À noter : des outils comme Power BI et Google Looker commencent à absorber une partie de la modélisation (couche Gold), ce qui brouille un peu la frontière traditionnelle Data Engineer / Data Analyst.

## 🔧 Transformation des données

> *"Un tableau de bord c'est une Ferrari, mais si on met de l'essence de mauvaise qualité dedans, ça ne roule pas"* — la donnée, c'est l'essence.

Étapes classiques (à ne pas suivre de façon dogmatique — s'adapter au contexte) :

1. **Nettoyage** : doublons, caractères spéciaux, valeurs nulles
2. **Enrichissement** : changement de types, éclatement de colonnes
3. **Agrégations** : `GROUP BY`, `SUM`, `AVG`, `COUNT`
4. **Joins** : fusion de tables

⚠️ Point de vigilance du formateur : le pipeline ne se limite pas à la transformation — il englobe aussi l'extraction et le chargement (ETL/ELT dans son ensemble), pas juste l'étape du milieu.

---

## 🗂️ Views vs Tables vs CTEs

Le cœur technique de la session.

| | **Table** | **View** | **CTE** | **Materialized View** |
|---|---|---|---|---|
| Stockage physique | ✅ oui | ❌ non (relit la source) | ❌ non (mémoire, le temps de la requête) | ✅ oui (stable) |
| Objet enregistré en base | ✅ | ✅ | ❌ *(pas un objet de BDD)* | ✅ |
| Fraîcheur des données | Figée jusqu'au prochain chargement | Toujours à jour (ré-exécute le SQL à chaque appel) | Toujours à jour | Dépend du cycle de rafraîchissement |
| Coût / vitesse | Rapide, pré-calculé | Payée à **chaque** appel, peut être lente si jointures/agrégations complexes | Payée à chaque exécution de la requête globale | Rapide, pas de processing tant que la source ne change pas |
| Cas d'usage clé | Donnée prête à consommer | Gérer des **permissions** (accès à la vue sans exposer la table source), couche d'abstraction | Simplifier une requête complexe, usage ponctuel | Concilier fraîcheur + performance |

- Exemple concret cité en cours : gestion de **5 000 Secure Views** pour des clients SaaS multi-tenant (chaque client accède à sa vue, jamais à la table source)
- **Save Query** : requête enregistrée exécutable, mais pas requêtable via un `SELECT` par-dessus — à distinguer d'une View
- Objets possibles dans une base de données : **Table, View, Function/Stored Procedure** — le CTE n'en fait pas partie
- Pattern courant en pipeline : **mixer les deux** — une View intermédiaire pour prototyper, puis matérialiser le résultat dans une Table une fois stabilisé, pour gagner en performance

🔗 Voir [[08-sql-cte-subqueries-union]] pour la mécanique des CTE en détail.

---

## ⚖️ OLTP vs OLAP

| | **OLTP** (Online Transaction Processing) | **OLAP** (Online Analytical Processing) |
|---|---|---|
| Orientation | Lignes | Colonnes |
| Usage | Transactions rapides, temps réel | Lectures massives, agrégations, analyse |
| Exemples | Salesforce (CRM), SAP, systèmes bancaires | BigQuery, Data Warehouse |
| Doublons | Évités (normalisation) | Tolérés (dénormalisation acceptée — stockage peu cher) |
| Qui l'utilise | Applications métier / production | Data Team |

- **Le rôle du pipeline** : extraire les données des systèmes OLTP pour les transformer côté OLAP, sans surcharger les systèmes de production
- 🎯 **Réflexe à avoir** : dashboard lent → premier réflexe = vérifier si on tape directement un système OLTP de prod au lieu de passer par l'OLAP
- Les deux peuvent coexister sur des cas métier complexes ; tendance marché : **Databricks** propose désormais une solution combinant les deux

---

## 🧭 Data Lineage (traçabilité)

- Tracer l'**origine et les transformations** d'une donnée, de la source jusqu'à la destination — un vrai **graphe de dépendances** entre les objets du pipeline
- Essentiel pour : justifier un chiffre à un CFO, ou diagnostiquer un problème dans un dashboard
- Les **Data Catalogs** outillent ce travail, mais un pipeline bien construit (nommage clair, documentation) permet déjà de tracer manuellement

## 🧩 Data Modeling

- Construire des modèles **orientés métier** (finance, marketing, RH…) à partir de données sources éparpillées — ex. un modèle `Orders` ou `Sales` qui consolide plusieurs tables sources pour des requêtes simples et rapides
- La **dénormalisation est acceptée** en OLAP : on tolère la redondance pour la performance (contrairement à OLTP)
- Distinction de rôle utile en entretien : le **Data Analyst explore et prototype**, le **Data Engineer met en production**

## 🔄 Orchestration

- Objectif : **planifier et coordonner** l'exécution des étapes du pipeline pour garder les données à jour (mise à jour régulière, gestion des erreurs, ordre d'exécution)
- Outils cités : **dbt**, **Airflow**, **Fivetran**, tâches planifiées via Stored Procedures
- Concept lié : l'**observabilité** — surveiller le volume de données et détecter les erreurs dans le pipeline

🔗 Voir [[09_dbt_intro]] et [[10_dbt_advanced_warehousing]] pour la suite logique côté outillage.

---

## 💰 Data Platform, coûts & pricing

Une Data Platform = **stockage** + **processing**. Fournisseurs cités : Google Cloud (BigQuery), Amazon (Redshift), Microsoft (Azure), Snowflake.

### Stockage vs Processing

- Le **stockage est bien moins cher** que le processing → toujours favoriser le stockage pour réduire le processing quand c'est possible
- **Materialized View** (stable, sur disque) : pas de processing tant que la donnée source ne change pas
- **View classique** : processing facturé à **chaque** requête, même si rien n'a changé depuis le dernier appel

### Modèles de pricing

| | **Pay as you go** | **Flat pricing** |
|---|---|---|
| Principe | Facturé selon la consommation réelle (ex. 50 Go stockés = facturé 50 Go) | Capacité réservée à l'avance, utilisée ou non (ex. 2 serveurs réservés, même sous-utilisés) |
| Dominance marché cloud | 90–98 % | Minoritaire |
| Avantage | Scalabilité instantanée, sans action manuelle | Coût prévisible si l'usage est stable et élevé |

⚠️ Correction apportée en session : **BigQuery est pay as you go** — une slide indiquant Redshift en flat pricing était probablement erronée (à vérifier si besoin).

---

## ✂️ Bonnes pratiques BigQuery — coût des requêtes

Section très actionnable, à appliquer direct sur les challenges :

- ❌ **Éviter `SELECT *`** en dehors de la phase d'exploration : BigQuery facture au **volume de données scanné**, pas au nombre de lignes retournées — `SELECT *` scanne toutes les colonnes même inutiles
- ❌ **`LIMIT` ne réduit pas le coût** : il limite uniquement l'affichage, le scan (donc la facturation) a déjà eu lieu en amont
- ✅ Ne sélectionner que les **colonnes nécessaires** — le coût dépend aussi du `data type` de chaque colonne (string, integer, float...), et les tables analytiques sont souvent très larges avec beaucoup de colonnes redondantes
- ✅ BigQuery a un système de **cache** : requête identique déjà exécutée → résultat réutilisé, pas de frais supplémentaires
- 💡 Point mentionné en session : il existe un minimum de facturation par requête, indépendant du volume réellement traité — encore une raison de ne pas negliger le choix des colonnes même sur des scans modestes

## 🗃️ Partitioning & Clustering

| | **Partitioning** | **Clustering** |
|---|---|---|
| Nombre de colonnes | **1 seule** | Plusieurs |
| Mécanique | Découpe physiquement la table en sous-groupes (souvent par date) | Trie physiquement les données sur les colonnes choisies |
| Bénéfice | Un `SELECT` filtré ne scanne que la partition concernée → moins de volume, moins de coût | Réduit le volume scanné sur des filtres multi-colonnes |
| Recommandé à partir de | ~2 Go | — |
| Piège à connaître | Une ligne avec une date ancienne arrivant tardivement peut atterrir dans la mauvaise partition (dérive dans le temps, nécessite parfois une reconstruction) | — |
| Qui s'en occupe en pratique | Souvent le Data Engineer | Souvent le Data Engineer |

- Snowflake propose du **micro-partitioning automatique** (pas besoin de le configurer à la main)
- En tant que Data Analyst : pas forcément à configurer soi-même, mais essentiel à **comprendre** pour lire un schéma et anticiper le comportement d'une requête

---

## 🎤 Prep entretien

| Question probable | Réponse clé |
|---|---|
| Différence Table / View / CTE ? | Table = stockage physique ; View = requête sauvegardée ré-exécutée à chaque appel, pas de stockage ; CTE = bloc temporaire en mémoire, pas un objet de base de données |
| Quand préférer une View à une Table ? | Quand la fraîcheur prime sur la vitesse, ou pour gérer des permissions sans exposer la table source |
| OLTP vs OLAP, exemple concret ? | OLTP = Salesforce/CRM, lignes, transactionnel ; OLAP = BigQuery/Data Warehouse, colonnes, analytique. On ne requête jamais un OLTP de prod pour un dashboard |
| Pourquoi un dashboard est lent, premier réflexe ? | Vérifier si on tape directement un système OLTP de production au lieu de passer par l'OLAP |
| C'est quoi l'architecture Medallion ? | Bronze (brut) → Silver (nettoyé/typé) → Gold (agrégé, prêt pour la consommation business) |
| Pourquoi éviter `SELECT *` en BigQuery ? | Facturation au volume scanné, pas au nombre de lignes — `SELECT *` scanne des colonnes inutiles |
| `LIMIT` réduit-il le coût d'une requête BigQuery ? | Non — le scan (donc le coût) est déjà effectué avant l'application du `LIMIT` |
| Partitioning vs Clustering ? | Partitioning = découpage physique sur 1 colonne (souvent date) ; Clustering = tri physique sur plusieurs colonnes |
| C'est quoi le Data Lineage et pourquoi c'est important ? | Traçabilité de la donnée source → destination ; essentiel pour justifier un chiffre ou débugger un dashboard |
| Rôle Data Analyst vs Data Engineer sur le Data Modeling ? | L'Analyst explore et prototype le modèle, l'Engineer le met en production et le maintient |

---

## ✅ Actions post-session

- [ ] Compléter les challenges sur les joins et les agrégations (pré-requis de cette session)
- [ ] Réaliser les challenges BigQuery sur les views et les tables (comparaison de performances)
- [ ] Réaliser le challenge sur la tâche planifiée (*scheduled task*)
- [ ] Revoir les slides sur les avantages/désavantages des différents modèles de Data Platform
- [ ] Pratique ciblée recommandée *(auto-évaluation compréhension de la session : 2/5 — sujet plus conceptuel que la syntaxe pure, à ancrer avec des exemples concrets sur un vrai projet)*

## ❓ Questions ouvertes

- [ ] Le pricing exact de Redshift (flat vs pay as you go) a été signalé comme possiblement erroné en slide — à vérifier si le sujet revient en entretien
- [ ] Clustering a été survolé rapidement — approfondir la syntaxe BigQuery (`CLUSTER BY`) et les cas où le combiner avec un partitioning

## 🔗 Liens avec d'autres chapitres

- [[05_intro_sql_bigquerry]] — lien identifié en session (bases SQL/BigQuery)
- [[08-sql-cte-subqueries-union]] — mécanique des CTE, en contraste avec Views/Tables ici
- [[09-window-functions]] — même logique coût/performance BigQuery (`SELECT` ciblé, granularité)
- [[09_dbt_intro]] / [[10_dbt_advanced_warehousing]] — l'outillage d'orchestration mentionné (dbt) prend le relai à partir d'ici
