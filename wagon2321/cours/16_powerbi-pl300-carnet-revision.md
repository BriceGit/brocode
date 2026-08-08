# 📊 Power BI — Carnet de révision PL-300

**Objectif** : socle théorique structuré comme l'examen officiel, confronté aux 3 jours Wagon réellement suivis ([#22](22-power-bi-1.md), [#23](23-power-bi-2.md), [#24](24-power-bi-3.md)).
**Source** : Skills Measured officiel Microsoft, version en vigueur depuis le 20/04/2026.
**Statut examen** : score de passage 700/1000 · validité 1 an · renouvelable gratuitement en ligne.

> 🧭 Ce carnet suit exactement les 4 blocs et sous-blocs de l'examen. `✅ (#NN)` = couvert en cours et renvoie au chapitre brocode concerné. `🔴` = notion absente des 3 jours et prioritaire à combler. `🟡` = absente mais secondaire. `⚪` = absente et marginale en poids d'examen.

---

## 🧭 Bilan express après les 3 jours Wagon

| Bloc | Poids exam | Couverture Wagon |
|---|---|---|
| 1. Prepare the data | 25–30% | Bonne — Power Query solide, quelques trous ciblés |
| 2. Model the data | 25–30% | Correcte — Star Schema + DAX de base, mais table de calendrier et optimisation absentes |
| 3. Visualize and analyze | 25–30% | Partielle — bon socle visuels/interactivité, **Drillthrough jamais construit**, tout le bloc "patterns & IA" absent |
| 4. Manage and secure | 15–20% | Correcte — gouvernance/RLS bien posés, détails d'administration absents |

**Estimation globale : ~55–60% du référentiel couvert.** Base solide pour comprendre l'examen, pas encore suffisante pour le passer sereinement.

---

## 🧹 Bloc 1 — Prepare the data (25–30%)

### 1.1 Get or connect to data
- [x] Se connecter à une source (fichiers, bases SQL, API, web scraping) ✅ (#22)
- [ ] 🔴 Distinguer **Import / DirectQuery / DirectLake** — les 3 jours n'ont utilisé qu'Import ; c'est pourtant une question quasi garantie à l'examen
  - `Import` : données copiées dans le modèle, rapide à l'usage, nécessite un refresh
  - `DirectQuery` : interroge la source en temps réel à chaque interaction, toujours à jour mais dépendant de la perf de la source
  - `DirectLake` : mode Fabric récent, lit directement les fichiers Delta/Parquet — combine vitesse de l'Import et fraîcheur du DirectQuery
- [ ] 🟡 Paramètres Power Query (variables réutilisables, ex. chemin de fichier ou date de référence)
- [ ] 🟡 Credentials & privacy levels (Public/Organisational/Private) — impacte le mashup entre sources

### 1.2 Profile and clean the data
- [x] Nettoyage de base (types, remplacement de valeurs, NULL vs Erreur, fill down/up) ✅ (#22)
- [ ] 🔴 **Data profiling** (ruban *View*) : *Column quality* (% valide/erreur/vide), *Column distribution* (valeurs distinctes/uniques), *Column profile* (stats détaillées) — jamais activé en cours, outil pourtant central pour "profiler" une donnée avant de la nettoyer
- [x] Résolution d'erreurs d'import (colonnes en `Error`) ✅ (#22)

### 1.3 Transform and load the data
- [x] Types de colonnes, colonnes calculées/conditionnelles, split/extract ✅ (#22)
- [x] Merge / Append (= JOIN / UNION) ✅ (#22)
- [x] Duplicate vs Reference ✅ (#22)
- [x] Tables de faits/dimensions (construction manuelle du Star Schema) ✅ (#23)
- [x] Clés pour les relations ✅ (#22, #23)
- [ ] 🟡 Group by / agrégation de lignes dans Power Query (pas juste en DAX)
- [ ] 🟡 Pivot / Unpivot / Transpose — juste effleurés, jamais pratiqués
- [ ] ⚪ Conversion de données semi-structurées (JSON) en table
- [ ] 🟡 Configuration du chargement (*Enable load*, connexion seule sans chargement en mémoire)

---

## 🔗 Bloc 2 — Model the data (25–30%)

### 2.1 Design and implement a data model
- [x] Star Schema, relations dimension → fait, Snowflake Schema ✅ (#23)
- [x] Cardinalité et sens de filtrage croisé (aperçu) ✅ (#22)
- [ ] 🔴 **Table de calendrier propre** : `CALENDAR(MIN(...), MAX(...))` + *Mark as Date Table* — jamais construite en pratique alors que c'est un prérequis technique explicite pour fiabiliser `SAMEPERIODLASTYEAR` et consorts (déjà repéré comme point flou en amont)
- [ ] 🟡 Dimensions à rôles multiples (*role-playing dimensions* — ex. une seule table Date utilisée pour date de commande ET date de livraison)
- [x] Cas d'usage colonne calculée vs table calculée ✅ (#23)

### 2.2 Create model calculations by using DAX
- [x] Mesures d'agrégation simple, itérateurs X ✅ (#23)
- [x] CALCULATE (avec ALL, avec FILTER) ✅ (#23)
- [x] Time Intelligence (TOTALYTD, SAMEPERIODLASTYEAR, DATEADD...) ✅ (#23)
- [x] Fonctions statistiques de base ✅ (#23)
- [x] Quick measures ✅ (#23)
- [x] Tables/colonnes calculées ✅ (#22, #23)
- [ ] 🟡 Mesures semi-additives (agrégeables sur certaines dimensions mais pas toutes, ex. un solde de stock qu'on ne peut pas sommer dans le temps)
- [ ] 🔴 **Groupes de calcul** (*calculation groups*) — notion avancée jamais abordée, permet de factoriser des variantes de mesures (ex. YTD/MTD/QTD appliquées à n'importe quelle mesure sans dupliquer le code)

### 2.3 Optimize model performance
- [ ] 🔴 **Performance Analyzer** et **DAX query view** — jamais ouverts en cours, outils de diagnostic pourtant centraux pour l'examen (repérer une mesure/relation/visuel qui rame)
- [ ] 🟡 Suppression des lignes/colonnes inutiles pour alléger le modèle
- [ ] 🟡 Réduction de granularité pour améliorer la performance

---

## 📊 Bloc 3 — Visualize and analyze the data (25–30%)

### 3.1 Create reports
- [x] Choix du visuel adapté, panorama des graphiques ✅ (#22)
- [x] Formatage, mise en forme conditionnelle ✅ (#22)
- [x] Slicing/filtering (slicers) ✅ (#22)
- [ ] 🟡 Thèmes personnalisés appliqués en pratique (juste mentionnés)
- [ ] ⚪ Narrative visual / suggestion de page via Copilot (nécessite licence Premium, difficile à pratiquer sans)
- [ ] ⚪ Reports paginés (*paginated reports*)
- [ ] 🟡 Calculs visuels en DAX (*visual calculations*, notion récente distincte des mesures classiques)

### 3.2 Enhance reports for usability and storytelling
- [x] Bookmarks, boutons, navigation entre pages ✅ (#22)
- [x] Tooltips personnalisés ✅ (#22)
- [x] Edit interactions, sync slicers ✅ (#22)
- [ ] 🔴 **Drillthrough** — mentionné à 3 reprises sur les 3 jours, jamais construit ; sous-objectif explicite de l'examen (pages, filtres, boutons de drillthrough)
- [ ] 🟡 Selection pane (grouper/superposer des visuels)
- [ ] ⚪ Réglages d'export, design mobile, accessibilité
- [ ] ⚪ Actualisation automatique de page
- [ ] ⚪ Personnalisation (*personalize visuals*)

### 3.3 Identify patterns and trends
- [ ] 🟡 Fonction *Analyze* (ex. "Explain the increase/decrease")
- [ ] 🟡 Grouping, binning, clustering
- [ ] ⚪ Visuels IA (*Key Influencers*, *Decomposition Tree*, Q&A) — nécessitent souvent Premium/Copilot
- [ ] 🟡 Lignes de référence, barres d'erreur, forecasting
- [ ] 🟡 Détection d'outliers/anomalies

---

## 🔐 Bloc 4 — Manage and secure Power BI (15–20%)

### 4.1 Create and manage workspaces and assets
- [x] Création/configuration de workspace, rôles (Admin/Member/Contributeur/Viewer) ✅ (#24)
- [x] Apps (setup, contenu, audience) ✅ (#24)
- [x] Publication, Report vs Dashboard ✅ (#24)
- [ ] 🟡 Passerelle de données (*gateway*) pour sources on-premise
- [ ] 🟡 Configuration de l'actualisation planifiée (*scheduled refresh*)
- [ ] ⚪ Abonnements et alertes de données (*subscriptions & data alerts*)
- [ ] ⚪ Certification/promotion de contenu

### 4.2 Secure and govern Power BI items
- [x] Attribution des rôles de workspace ✅ (#24)
- [x] Row-Level Security : règles (Desktop) + assignation par email (Service) ✅ (#24)
- [x] Notion d'Object-Level Security (via outil externe type Tabular Editor) ✅ (#24)
- [ ] 🟡 Accès au niveau item (*item-level access*) distinct de l'accès workspace
- [ ] 🟡 Assignation RLS par **groupe** plutôt que par individu
- [ ] ⚪ Sensitivity labels (Microsoft Purview)

---

## 🎯 Priorités de révision autonome (classées)

1. 🔴 **Drillthrough** — le plus gros trou, mentionné mais jamais pratiqué. À construire soi-même sur un dataset perso (ex. page détail produit accessible en clic-droit depuis un graphique de synthèse).
2. 🔴 **Table de calendrier + Mark as Date Table** — prérequis technique déjà identifié comme flou, à fiabiliser avant tout usage sérieux de Time Intelligence.
3. 🔴 **Import vs DirectQuery vs DirectLake** — pure théorie à lire (Microsoft Learn), pas besoin d'un gros dataset pour la comprendre.
4. 🔴 **Data profiling** (Column quality/distribution/profile) — 10 minutes de pratique suffisent, juste jamais montré en cours.
5. 🔴 **Performance Analyzer / DAX query view** — à ouvrir une fois sur un dashboard existant pour voir le format des résultats.
6. 🔴 **Calculation groups** — plus avancé, à review en dernier parmi les priorités hautes.
7. 🟡 Le reste du Bloc 3.3 (patterns/IA) et les détails d'administration du Bloc 4 — peuvent s'apprendre en lisant la doc sans forcément pratiquer, poids d'examen plus faible par item.

---

## 📎 Ressources officielles

- Study guide officiel (skills measured à jour) : `learn.microsoft.com/credentials/certifications/resources/study-guides/pl-300`
- Practice assessment gratuite officielle : accessible depuis la page de certification PL-300 sur Microsoft Learn
- Parcours d'apprentissage gratuit Microsoft Learn (self-paced) : lié depuis la même page

---

## 📝 Journal des sessions

| Date | Session | Notes / blocages |
|---|---|---|
| 04/08/2026 | Jour 1 Wagon — [#22](22-power-bi-1.md) : présentation, Power Query, Data Model, dashboard design | Session dense, bon socle Power Query + Star Schema. Aucun Drillthrough abordé. |
| 05/08/2026 | Jour 2 Wagon — [#23](23-power-bi-2.md) : DAX, Star Schema, Filter Context/CALCULATE, Time Intelligence | Cœur du DAX bien posé (CALCULATE, itérateurs, Time Intelligence). Pas de table de calendrier dédiée construite — les mesures s'appuient directement sur la colonne date de la table de faits. |
| 06/08/2026 | Jour 3 Wagon — [#24](24-power-bi-3.md) : gouvernance, sécurité, partage, Apps (journée projet) | Bonne couverture RLS/OLS/Workspaces. Rien sur les gateways, l'actualisation planifiée ni les sensitivity labels. |

*(à densifier au fil de la révision autonome — noter les blocages DAX/config rencontrés en pratiquant les points 🔴 ci-dessus)*
