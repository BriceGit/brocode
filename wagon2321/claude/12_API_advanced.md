# 📝 #16 - API advanced

**Date : 27 juillet 2026**

**Thème :** Data Warehousing moderne — de la base transactionnelle à la plateforme data (ELT, CDC, Fivetran)


---

### 💡 **Ce que j'ai retenu**

## 🏛️ Modern Data Platform — l'objectif général

Le fil rouge du chapitre : centraliser toute la donnée de l'entreprise (IT, business, outils tiers) en un seul endroit fiable, pour permettre analyse, reporting et activation cross-équipes.

**Bénéfices d'une donnée centralisée** : unicité de l'info (pas de doublons), fiabilité, visibilité partagée entre équipes, accès facilité → gains de temps, gains de productivité, meilleure agilité, aide à la décision, travail cross-fonctionnel, monitoring business.

**Comparatif des entrepôts cloud (tous OLAP, orientés colonne) :**

| Outil | Cloud supporté | Hébergement | Coût |
|---|---|---|---|
| **Amazon Redshift** | AWS uniquement | Pré-2020 vs RA3 (clusters) | Selon taille/nb clusters |
| **Snowflake** | AWS / Azure / GCP | Compute units dédiés | Selon nb d'unités |
| **Google BigQuery** | GCP uniquement | Serverless | On-demand ou flat-rate (slots réservés) |
| **Azure Synapse** | Microsoft uniquement | Serverless + dédié | Mixte |

*(+ options on-premise pour mémoire : Trino, Hive, Pinot — auto-hébergées, coût dépendant de l'infra)*

👉 Rappel du dernier cours : Snowflake reste l'outil recommandé en prod, BigQuery est top pour apprendre mais plus limité en prod.

---

## 🔄 ETL → ELT : le changement de paradigme

| | **ETL** (ancien) | **ELT** (moderne) |
|---|---|---|
| Base cible | OLTP — orientée ligne | OLAP — orientée colonne |
| Connexion | Custom, développée par un Data Engineer, transform inclus | Standardisée, outils simples |
| Stockage | Cher, peu de formats | Cheap, beaucoup de formats |
| Traitement | Lent, petits datasets | Très rapide, gros datasets |
| Outils | Hadoop/Spark (Extract+Transform) → MySQL/PostgreSQL (Load) | Fivetran/Airbyte (Extract+Load) → BigQuery/Snowflake + **dbt** (Transform) |

✅ Avantage ETL : centralisé, simple, complet.
❌ Inconvénient : RGPD compliqué, transformations très complexes à faire pré-chargement.

➡️ **La bascule clé** : dans l'ETL le Transform se fait avant le Load (on charge une donnée déjà propre) ; dans l'ELT on charge tout brut d'abord, puis dbt transforme *dans* l'entrepôt. C'est ce qui permet le côté "rapide, gros volumes".

---

## 🔀 Les 3 types de flux de données

| Flux | Équipe | Cas d'usage | Caractéristiques | Outils |
|---|---|---|---|---|
| **Tools → Tools** | Business | Tâches simples et indépendantes, synchro d'outils, faible dispo IT/Data | Trigger temps réel, pas de centralisation, transforms simples | Zapier, Make, n8n.io |
| **Tools → Data platform** | Data | Centralisation (single source of truth), enrichissement, reporting, ML | Batch (colonne), centralisation, pas de transform, schéma conservé | Stitch, Fivetran, Airbyte, Airflow, Kafka |
| **Tools → IT platform** | IT | Gestion de l'activité transactionnelle (OLTP) | Caractéristiques IT | Outils IT internes |

**Comparatif des outils Tools→Tools / Tools→Data** (complexité, volume, fraîcheur, prix) :
- **Zapier / n8n.io / Make** : Business Analyst, complexité/volume faibles, temps réel (trigger), 0-600€/mois selon plan
- **Whaly** : couvre les deux flux (Tools→Tools et →Data), Business + Data Analyst, batch, ≥450€/mois
- **Stitch / Fivetran** : Data Analyst + Analytics Engineer, batch, 60-2500€/mois selon volume
- **Airbyte** : Analytics Engineer + Data Engineer, cloud payant ou open source (coût interne)
- **Airflow / Kafka** : Data Engineer/Data Ops, batch (Airflow) ou temps réel (Kafka), open source mais coût de serveurs/équipe

👉 Logique générale : plus on descend vers l'IT/Data Engineering, plus la volumétrie et la complexité gérable augmentent, mais moins c'est "plug-and-play".

---

## 📊 State Table vs Event Table

Concept central du chapitre — le choix de format de table détermine ce qu'on peut analyser derrière.

| | **State Table** | **Event Table** |
|---|---|---|
| Rôle | Vue claire de l'état **actuel** | Stocke **tous** les changements |
| Synchro | Update/modification de ligne | Statique — append incrémental, jamais de modif |
| Clarté | Vue nette du présent | Mélange de tous les états passés + présent |
| Info | Perte d'info sur les états précédents | Info complète, aucune perte |

**Exemple colis (shipping_id)** :
- State table : `shipping_id | status` → une ligne = état courant du colis
- Event table : `id | shipping_id | status | timestamp` → une ligne par changement de statut

**Grille de décision — quel format pour quel besoin ?**

| Besoin analytique | State table | State + historisation | State + CDC (log/trigger) | Event table |
|---|---|---|---|---|
| Analyse de l'état courant | ✅ | ✅ | ✅ | ✅ |
| Évolution dans le temps | ❌ | ✅ ⚠️ (risque de perte si bug d'historisation) | ✅ | ✅ |
| Analyse détaillée (funnel, delay, etc.) | ❌ | ❌ | ✅ | ✅ |

⚠️ Point important : les event tables ne sont pas toujours disponibles à la source — d'où l'intérêt du CDC pour en générer une à partir d'une state table.

**Exemples concrets (e-commerce)** :
- *Funnel d'acquisition* (cart_id) : state table suffit pour monitorer + relancer les paniers abandonnés ; event table nécessaire pour analyser le drop-off et le temps entre chaque étape (ex : 180min entre add-to-cart et address, 62% de drop-off).
- *Shipping tracking* (shipping_id) : state table pour voir les commandes en cours ; event table pour calculer le taux de retard et le temps moyen par étape.
- *Catalogue produit / base clients* : nécessite historisation par date pour suivre l'évolution (prix, promo, segment client) et détecter des tendances/dégroissance — risque de perte de données si bug d'historisation un jour donné.

---

## 🔧 Méthodes de transfert de données (Data Transfer Methods)

Deux axes à retenir : **temporalité** (batch vs temps réel) et **exhaustivité** (full refresh vs incrémental).

| Méthode | Principe | Update | Charge serveur | Format transfert |
|---|---|---|---|---|
| **1. Table dump** | Copier/coller : réplication complète régulière, écrase l'ancienne version | Batch | Lourde (full refresh) | Event→Event ✅ / State→State ⚠️ perte |
| **2. Table differencing** | Compare source et cible, ne transfère que les diffs | Batch | Lourde (semi full refresh) | Event→Event ✅ / State→State ⚠️ perte |
| **3. Timestamp tracking** | Colonne `updated_at`, ne remonte que les lignes modifiées depuis la dernière synchro | Batch | Légère (incrémental) — ⚠️ suppression difficile à tracker | Event→Event ✅ / State→State ⚠️ perte |
| **4. Log-based CDC** | Un logbook enregistre chaque modif source → transformée en ligne d'event table à destination | Temps réel ou batch | Légère (incrémental) | State→Event ✅ sans perte |
| **5. Trigger-based CDC** | Chaque modif déclenche un trigger qui ajoute une ligne à destination | Temps réel | Légère (incrémental) | State→Event ✅ sans perte |

👉 Les 3 premières méthodes perdent l'historique quand la source est une state table (elles ne captent que le dernier état). Seul le CDC (log ou trigger) permet de reconstruire une event table sans perte à partir d'une source en state table — mais c'est complexe à mettre en place et pas toujours possible.

**Grille de décision mise à jour (avec CDC) :**

| Besoin | State table | State + historisation | State + CDC | Event table |
|---|---|---|---|---|
| État courant | ✅ | ✅ | ✅ | ✅ |
| Évolution dans le temps | ❌ | ✅ ⚠️ | ✅ | ✅ |
| Analyse détaillée | ❌ | ❌ | ✅ | ✅ |

**Compatibilité méthode de transfert × protocole :**

| Protocole | Update | Table dump | Table diff. | Timestamp tracking | Log CDC | Trigger CDC |
|---|---|---|---|---|---|---|
| **FTP(S)** | Batch | ✅ | ✅ | ✅ | ✅ | ❌ |
| **API** | Batch | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Webhook** | Temps réel | ✅ | ✅ | ✅ | ✅ | ✅ |

👉 Le trigger CDC nécessite du temps réel → seul le Webhook le permet.

---

## 📦 Résumé — les 6 méthodes de collecte de données

1. **Change Data Capture** → streaming des changements incrémentaux depuis une base, en temps réel
2. **Log File Collection** → collecte/parsing des logs générés par apps, serveurs, systèmes
3. **Event Tracking** → collecte des actions/événements sur pages et apps
4. **No-code Data Collection** → automatise les tâches de collecte manuelle
5. **Custom API Integrations** → scripts/applis sur-mesure pour requêter des APIs
6. **ETL/ELT via plateformes d'intégration** → connecteurs pré-construits vers de multiples sources (Fivetran, Airbyte...)

---

## 🐟 Fivetran — spécificités pratiques (démo prof)

- **Data centralization** : un flow = synchro entre une **source** (Server, ex. base/fichiers/apps/events) et une **destination** (Client, ex. BigQuery/Snowflake/Redshift/MySQL/PostgreSQL).
- **Conservation du schéma** : Fivetran détecte automatiquement les types de colonnes à la source (float, int, string, date...) et les préserve à l'identique dans l'entrepôt cible — vérifié en comparant colonne par colonne source vs BigQuery.
- **Sécurité / privacy** : possibilité de bloquer ou hacher (hashing) certaines colonnes sensibles (ex. emails, données médicales) avant chargement — pertinent surtout en secteurs réglementés (médical, et bancaire par extension).
- **Gestion des changements de schéma** : si une colonne source change de type, Fivetran peut soit tout autoriser, autoriser certaines colonnes, soit tout bloquer (comportement par défaut recommandé) → oblige les équipes tech à corriger la source avant de débloquer.
- **Colonne `_fivetran_synced` (timestamp)** : indique la dernière synchro de chaque ligne — essentiel pour détecter une synchro cassée (cas vécu : données "bizarres" car pas resynchronisées depuis un mois, faute d'alerte configurée).
- **Coût de requête visible** : Fivetran affiche le coût de calcul de chaque synchro.
- **Filtrage à la source** : possibilité de filtrer la donnée avant chargement (ex. séparer flux clients UE vs US pour respecter des normes différentes).

---

### ❓ Questions / Points flous

- [ ] Comment configurer la clé primaire dans Fivetran quand elle n'est pas bien détectée automatiquement (colonne ajoutée par défaut) ?
- [ ] Approfondir la mise en place d'alertes de synchro pour éviter le cas vécu par le prof (1 mois sans sync détecté)

### 🔗 Liens avec d'autres notions

- Rejoint directement le chapitre dbt (staging/intermediate/marts ≈ Bronze/Silver/Gold, OLTP vs OLAP déjà vu) : ce chapitre complète en amont — **comment** la donnée brute arrive dans l'entrepôt avant que dbt la transforme.
- Pertinent pour le portfolio banking : le choix state vs event table + méthode de transfert est un bon sujet à mentionner en entretien pour montrer la compréhension des trade-offs data engineering, même côté Data Analyst.

### ✅ Actions post-session

- [ ] Terminer la synchro Fivetran → BigQuery en cours de résolution (permissions)
- [ ] Vérifier si une alerte de synchro peut être configurée dans Fivetran (feature à explorer)
