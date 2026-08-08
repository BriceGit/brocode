# 📝 #19 — Looker Studio (1/2) : fondamentaux de la dataviz

**Date** : 30 juillet 2026
**Thème** : BI & data visualisation — concepts, prise en main de Looker Studio, choix de chart type, filtres, bonnes pratiques de design
**Compréhension (1→5)** : ⭐⭐⭐⭐

---

## 🎯 Contexte du module

- Nouveau module dédié à la **visualisation de données / dashboarding** — moins de code, mais tout aussi important : sans restitution visuelle, une analyse ne sert à rien
- **BI (Business Intelligence)** = tout ce qui a été vu jusqu'ici dans le bootcamp (collecte, transformation, analyse) **+ la restitution visuelle**
- Programme : **Looker Studio aujourd'hui**, puis **Power BI dans 3 jours** — deux outils différents pour comparer les approches
- Un outil de visualisation transforme une donnée brute (ex : une table BigQuery) en quelque chose d'**actionnable pour des profils non-techniques**

---

## 🧭 Types de dashboards / cas d'usage

| Type | Objectif | Fréquence / niveau de détail typique |
|---|---|---|
| **Reporting** | Bilan d'une campagne ou d'une période terminée | Périodique (semaine/mois/trimestre) |
| **Monitoring** | Suivi en temps réel ou périodique des KPIs, surveiller des seuils | Souvent quotidien pour les opérationnels |
| **Optimisation** | Comparer des campagnes A/B testing, analyser des comportements différenciés | Ponctuel, orienté itération |
| **Analyse ad hoc** | Investigation ponctuelle sur un événement précis (ex : gros drop de CA un jour donné) | One-shot, très détaillé |
| **Decision support** | Études de marché, expansion business, lancement produit | Plus global, moins fréquent |

💡 Le type de dashboard détermine directement le **niveau de détail** et la **fréquence** : un dashboard de monitoring sera précis et rafraîchi au jour le jour, un dashboard de decision support sera plus large et global.

---

## 🏢 Qui utilise la BI ?

La BI est utile à **tous les niveaux** de l'entreprise, mais le besoin change avec la hiérarchie :

| Niveau | Rôles | Besoin dominant |
|---|---|---|
| Investors & shareholders | — | Reporting (mensuel/trimestriel/annuel) |
| Executive board | CEO, board members | Decisions, Monitoring |
| Team managers | CFO, CMO, COO, Purchasing director, Head of cust. service, CRM Manager | Analyse ciblée sur un sujet précis, monitoring (semaine plutôt que jour), études de marché |
| Operational teams | Finance, Marketing, Sales, Production, CRM, Purchase, Shipping, Customer service | Monitoring quotidien, optimisation (résultats d'AB testing) |

👉 Plus on monte dans la hiérarchie, plus le besoin penche vers le **reporting synthétique et la décision** ; plus on descend, plus c'est du **monitoring et de l'optimisation opérationnelle au quotidien**.

---

## ✅ Pourquoi un outil de BI dédié — Requirements

Même logique que pour un data warehouse dédié type BigQuery : centraliser, fiabiliser, sécuriser. Un bon outil de BI doit être :

- **Reliable** (fiable)
- **Multi-sources** (connecte plusieurs origines de données, pas seulement celles du même écosystème)
- **In-depth** (permet d'aller dans le détail)
- **Clear & Visual** (lisible)
- **Interactive** (boutons, slicers pour que le lecteur explore lui-même)
- **Low latency** (rapide)
- **Controlled access** (droits d'accès maîtrisés — qui peut lire, qui peut éditer)
- **Up-to-date** — à la fois la donnée **et l'outil lui-même**, qui doit suivre les évolutions du marché (nouvelles sources, IA...)

---

## 🛠️ Panorama des outils du marché

| Outil | Type | Remarques |
|---|---|---|
| **Looker Studio** | Gratuit | Ex-Google Data Studio (renommé plusieurs fois : Data Studio → Looker Studio) ; écosystème Google |
| **Looker** | Payant | Version "pro" de Looker Studio, permet du code (LookML/SQL directement) |
| **Power BI** | Microsoft | Vu dans 3 jours en comparaison |
| **Metabase** | Open source | Alternative gratuite hors écosystème Google/Microsoft |
| **Tableau** | Payant | Un des historiques du marché |
| **Superset** | Open source | Alternative technique |

**Pourquoi Looker Studio pour démarrer :**
- Facilité d'utilisation, intégré à l'écosystème Google (connexion directe avec BigQuery, Sheets, GA4...)
- Accès en ligne, **rien à installer**
- Collaboration simple (partage façon Google Docs, droits éditeur/lecteur)
- Gratuit, donc bon point d'entrée avant d'aller vers des outils plus poussés (Looker, Power BI)

---

## 🖱️ Interface Looker Studio — les bases

- **Mode édition vs mode vue** : bouton en haut à droite. En mode vue, aucune modification possible — pratique pour donner accès à des lecteurs sans risque qu'ils cassent quelque chose.
- **Partage** : comme un Google Doc — lien ou email, droits **éditeur** ou **lecteur**.
- **Éléments disponibles** : texte, images, formes, graphiques (les graphiques incluent aussi les filtres).
- **Gestion des pages** :
  - Page Settings → style (dimensions en pixels, mode portrait/paysage), background, thème de couleurs
  - Possibilité de créer des **sections** et d'y drag & drop des pages pour structurer la navigation (utile pour les lecteurs du rapport)
- Vocabulaire "front-end / back-end" (moins utilisé qu'en dev, mais on le rencontre) : le **back-end** = data sources et connexions, le **front-end** = la partie visuelle (graphiques, structuration).

---

## 📖 Dimensions, Measures, Metrics, KPIs — glossaire

*Dans un monde parfait, voici la distinction théorique :*

| Terme | Définition | Exemples |
|---|---|---|
| **Dimension** | Information permettant de **contextualiser** une measure/metric/KPI — segmentation, catégorisation | Date, canal de connexion, device, transporteur |
| **Measure** | La **valeur brute** de quelque chose — presque toujours un nombre | Nombre de téléchargements d'app, dépenses |
| **Metric** | Information **dérivée** d'une ou plusieurs measure(s) | Budget, nombre de nouveaux clients |
| **KPI** | Une **metric dédiée à un objectif plus large** de l'entreprise (performance d'une action/phénomène clé) | CAC (Customer Acquisition Cost) |

⚠️ **Nuance pratique importante** : dans l'interface Looker Studio elle-même, cette distinction fine **n'existe pas** — tout est regroupé sous le terme générique **"Metric"**. La théorie sert à structurer ta réflexion (et utile en entretien), mais au moment de créer un graphique, l'outil ne te demandera qu'une "Dimension" et une ou plusieurs "Metric(s)", sans plus de nuance.

### Règle mnémotechnique pour identifier dimension vs metric

> **Metrics = ce que je veux voir**
> **Dimensions = comment je veux le voir**

| Demande | Metric(s) | Dimension(s) |
|---|---|---|
| "Je veux voir le nombre de nouveaux users **par semaine**" | Nombre de nouveaux users | Semaine |
| "Je veux voir mon budget **réparti par canal**" | Budget | Canal |
| "Je veux voir, **pour chaque type de device**, le nombre de téléchargements et le CAC" | 2 metrics : téléchargements + CAC | 1 dimension : device |
| "Je veux voir **l'évolution dans le temps** du nombre de connexions **par canal**" | Nombre de connexions | 2 dimensions : temps + canal (= un **breakdown**) |

💡 Un **breakdown** = ajouter une 2ᵉ dimension à un graphique pour décomposer davantage l'info déjà affichée (ex : évolution dans le temps, décomposée par canal).

---

## 📊 Créer un graphique dans Looker Studio

- Deux façons d'ajouter un graphique : bouton direct dans la barre d'outils, ou menu **Insert**
- Une fois le graphique posé, un panneau de propriétés s'ouvre à droite avec 2 onglets :
  - **Setup** : source de données, Dimension(s), Metric(s), filtres, tri
  - **Style** : couleurs, axes, titres, légendes
- **Dimension par défaut** : Looker Studio propose une dimension par défaut à la création (pas toujours pertinente — à ajuster)
- **Agrégation d'une metric** : modifiable via la petite icône crayon (somme, moyenne, comptage...), avec option de renommer le libellé affiché dans la légende
- **Changer de type de graphique sans tout recréer** : onglet **Chart Type** en haut du panneau (à côté de Setup/Style) — permet de passer d'un bar chart à un stacked bar chart par exemple, sans perdre le paramétrage
- **Cross-filtering** : activé **par défaut**. Cliquer sur un élément d'un graphique filtre automatiquement les autres graphiques de la page (interaction). Bouton **Reset** en haut à droite du dashboard pour annuler un filtrage accidentel.
- **Groups (Ctrl+G)** : sélectionner plusieurs graphiques (Ctrl+clic) et les grouper permet :
  - D'isoler les interactions de cross-filtering à ce sous-ensemble uniquement (les autres graphiques hors groupe ne sont pas affectés)
  - D'appliquer un **filtre dédié au groupe entier**, via un panneau de propriétés spécifique au groupe

---

## 📈 Choisir son Chart Type

**Question de départ : qu'est-ce que je veux montrer ?**

```
Valeurs exactes uniquement → Scorecard / Table
Sinon, quatre grandes questions :
  1. Comment les données sont-elles distribuées ?        → Distribution
  2. De quoi sont faites les données (en %) ?             → Composition
  3. Comment les valeurs sont-elles liées entre elles ?    → Relation / corrélation
  4. Comment les valeurs se comparent-elles ?              → Comparaison (valeurs absolues)
```

💡 Ce petit arbre de décision est une version simplifiée d'un framework connu en dataviz. Ressource complémentaire recommandée en session : **[from-data-to-viz.com](https://www.data-to-viz.com)** — arbre de décision détaillé selon le type de donnée (numérique, catégorique, géographique...), avec exemples de code Python pour chaque chart.

### 1️⃣ Valeurs exactes → Scorecard & Table

| Chart | Usage |
|---|---|
| **Scorecard** | Mettre en avant **1 seul indicateur**, avec option d'afficher l'évolution vs la période précédente |
| **Table** | Mettre en avant **plusieurs indicateurs** en parallèle |

⚠️ Usage des tables à limiter à des cas précis (ex : liste exhaustive nécessaire) — une table surchargée de lignes est souvent moins lisible qu'un top 10. On peut aussi y ajouter des mini bar charts intégrés par colonne pour l'aide à la lecture.

### 2️⃣ Distribution

- **Objectif** : identifier rapidement comment les données sont réparties
- ⚠️ **Attention à la largeur des buckets** : un histogramme "brut" (une barre par valeur exacte, ex : chaque prix individuel) est souvent illisible et n'a aucun sens visuellement → regrouper en tranches (ex : prix de 0-19, 20-39, 40-59...) rend le pattern lisible
- Charts : **Line Histogram** (brut, à éviter) → **Column chart / Column Histogram** (par tranches, recommandé)

### 3️⃣ Composition en % / proportion

| Cas | Chart | Contrainte |
|---|---|---|
| **1 dimension** | Pie chart / Donut chart | Uniquement 1 dimension, **pas de variation dans le temps** |
| **2 dimensions** | Stacked column chart / 100% Stacked column chart | Pas de variation dans le temps, peu de labels lisibles |
| **1 dimension dans le temps** | Stacked area chart / 100% Stacked column (dans le temps) | Peu de labels lisibles |

⚠️ **Pièges à connaître (venant directement de la critique d'exemples en session) :**
- **Pie/donut chart** : peu pertinent si trop de catégories (>5-6), si les catégories sont trop équilibrées (ex : 50/50 ou 33/33/33 — aucune lecture utile), ou si une catégorie écrase toutes les autres (ex : 3 petites catégories + "Others" à 81% — regarder plutôt un tableau)
- **Stacked bar chart en %** : masque les valeurs absolues. Exemple concret vu en session : 5 canaux affichés à ~20% chacun en %, alors qu'en absolu un seul canal (Display) représentait 100k de trafic contre 10 pour les autres — **toujours garder une référence à la valeur absolue** quelque part quand on montre du %
- **Stacked area chart avec trop de catégories** : l'exemple vu (device × pays, ~15 combinaisons) devient illisible dès qu'il y a trop de sous-catégories **et** que les couleurs sont trop proches (ex : plusieurs nuances de bleu très proches, impossible de distinguer laquelle est laquelle) — mieux vaut filtrer/simplifier en amont (ex : un chart par pays) que d'essayer de tout caser dans un seul graphique

### 4️⃣ Relation & corrélation entre valeurs

| Chart | Usage |
|---|---|
| **Scatter plot** | Visualiser la corrélation entre **2 variables** (ex : plus une commande est élevée, plus le chiffre d'affaires total augmente) |
| **Table avec heatmap** | Identifier des variations/corrélations sur **plusieurs variables** à la fois via un code couleur |

### 5️⃣ Comparaison de valeurs (absolues)

| Cas | Chart |
|---|---|
| 1 ou 2 dimensions, sans le temps | **Column / Bar chart**, avec breakdown optionnel par sous-catégorie |
| Dans le temps | **Time series / Line chart** (dédié quand le temps est en abscisse), avec breakdown optionnel |
| Dans le temps, avec emphase sur la valeur exacte par période | **Time series / Column chart**, avec breakdown optionnel |
| Géographiquement | **Map choropleth** (couleur = intensité par zone) ou **Bubble map** (taille de bulle = valeur) |

⚠️ Pour les maps : toujours se demander si la carte **apporte vraiment une info** au discours (parfois une simple catégorisation par grande zone — Amérique du Nord, Europe... — est plus lisible qu'une carte avec beaucoup de zones vides sans donnée). Toujours prévoir une **légende** avec l'échelle, sinon impossible de savoir ce que représentent les couleurs.

---

## 🔎 Filtrage dans Looker Studio

Le filtrage est possible à **4 niveaux hiérarchiques**, du plus restreint au plus large — les filtres s'héritent entre eux :

| Niveau | Portée | Comment |
|---|---|---|
| **Chart** | Un seul graphique | Dans le panneau Setup du graphique, section Filter |
| **Group** | Tous les graphiques d'un groupe (Ctrl+G) | Panneau de propriétés du groupe |
| **Page** | Tous les graphiques de la page | Add a control → Advanced filter, ou filtre appliqué à la page |
| **Report** | Toutes les pages du rapport | Clic droit sur un contrôle → **"Make report-level"** |

- Un filtre peut être **visible** (contrôle interactif que le lecteur peut manipuler, ex : dropdown) ou **invisible** (appliqué silencieusement, non modifiable par le lecteur)
- Gestion centralisée de tous les filtres existants via **Resources (Ressources) > Manage Filters**

### Créer un filtre (Create Filter)

Étapes :
1. **Nommer** le filtre
2. Définir la **data source** sur laquelle il s'applique
3. Choisir le **type** : Include ou Exclude
4. Définir le **champ** concerné
5. Définir la **condition** (ex : `Is Null`)
6. Ajouter des conditions **AND/OR** si besoin

*Exemple concret : filtre "No-Geoloc" → Exclude où `city` Is Null (retire les lignes sans ville renseignée).*

---

## 🎛️ Contrôles interactifs

3 types principaux de contrôles ajoutables via "Add a control" :

| Contrôle | Usage |
|---|---|
| **Dropdown (Drop-down list)** | Filtre par catégorie (ex : transporteur, segment client) — on associe simplement la colonne au "control field" |
| **Date Range Control** | Filtre temporel — ⚠️ **ne fonctionne que si les graphiques concernés ont une Date Range Dimension configurée** (voir section Date ci-dessous). Sans ça, le contrôle ne fait rien silencieusement. |
| **Slicer** | Filtre sur une **plage de valeurs numériques** (ex : plage de prix) |

💡 Certains graphiques peuvent eux-mêmes servir de filtre intuitif sans contrôle dédié (ex : cliquer sur une catégorie d'un tree map filtre le reste du dashboard via le cross-filtering) — à évaluer selon la structure voulue.

---

## 🗂️ Sources de données

- Gestion centralisée via **Resources > Manage Data Sources**
- On peut ajouter de nombreux connecteurs, **pas uniquement Google** (BigQuery, Sheets, GA4, mais aussi de très nombreux connecteurs tiers)
- Une source marquée **"reusable"** peut être partagée entre plusieurs rapports Looker Studio différents
- Possibilité de modifier certains paramètres d'une source directement dans Looker Studio : agrégation par défaut d'un champ, renommage — pratique pour gagner du temps si un champ est très utilisé, plutôt que de le reconfigurer à chaque graphique
- **Blend Data** : option de jointure entre plusieurs sources directement dans Looker Studio — à utiliser avec parcimonie, **préférer faire la jointure en amont** (dans le warehouse / dbt) quand c'est possible, plus robuste et plus performant

---

## 📅 Gérer la date : Date Range Dimension

La gestion de la date est **centrale** en BI, pour 4 raisons :
- **Period selection** — filtrer sur une période spécifique
- **Trend** — analyser l'évolution dans le temps
- **Reporting régulier** — quotidien, hebdo, mensuel, annuel
- **Period comparison** — comparer une période à une autre

### Ce qu'est la Date Range Dimension

Un champ distinct de la **Dimension** utilisée pour l'affichage du chart :
- **Date Range Dimension** = indique **quel champ (au format DATE)** associer à la dimension temporelle du chart — c'est ce champ que Looker Studio utilise pour filtrer quand un **Date Range Control** est actif sur la page
- **Dimension** = le champ réellement affiché à l'écran (ex : `date_date (Year Month)`), qui peut être une version reformatée/agrégée de la date
- Les deux peuvent pointer vers la même colonne source, avec un formatage différent pour l'affichage

⚠️ **Piège classique** : si un Date Range Control est posé sur la page mais qu'un graphique n'a pas sa Date Range Dimension configurée, le filtre de dates **ne fait tout simplement rien sur ce graphique** — sans message d'erreur. Toujours vérifier que chaque chart temporel a bien ce champ renseigné.

### Comparaison de dates (date comparison)

Fonctionnalité additionnelle dans le Setup d'un graphique temporel : activer **"date de comparaison"** génère automatiquement une **2ᵉ ligne** représentant la période précédente (ex : période comparée = mois précédent), qui **s'ajuste dynamiquement** si on change la plage de dates sélectionnée. Pratique pour du reporting période vs période sans dupliquer manuellement un graphique.

---

## 🎚️ Metric Sliders

Permet de **filtrer sur une plage de valeurs** d'une metric directement depuis un chart (ex : table), via des sliders interactifs.

- Activable dans le panneau Setup du chart : toggle **"Metric sliders"**
- Un slider apparaît par metric affichée dans le chart (ex : turnover, cost, ROAS), bornes ajustables par l'utilisateur final du dashboard
- Usage typique : laisser un lecteur explorer lui-même une table en filtrant dynamiquement, sans devoir demander une modification du rapport

---

## 🧩 Fonctionnalités additionnelles utiles

- **Theme & Layout** : les options de couleurs/grille par défaut d'un rapport se configurent ici (déplacé récemment depuis le Style d'un graphique individuel) — permet de définir un thème cohérent pour tout le rapport en un seul endroit
- **Copier-coller un style de graphique** : sélectionner un graphique déjà stylé (Ctrl+C), clic droit sur le graphique cible → **Paste style** — évite de reconfigurer manuellement couleurs/police/axes sur chaque nouveau graphique
- **Graphiques communautaires** : bibliothèque de charts additionnels (ex : sunburst) accessible à côté du menu d'ajout de graphique standard — ⚠️ peuvent avoir des bugs d'affichage sur les couleurs, à réserver aux cas où le chart natif ne suffit vraiment pas
- ⚠️ **Copier-coller un bloc contenant un filtre/segment** : comportement parfois imprévisible (le filtre copié peut ne pas s'appliquer correctement aux nouveaux éléments) — il est recommandé de **recréer le filtre plutôt que de le copier-coller**

---

## 🎨 Bonnes pratiques de design de dashboard

*Synthèse d'une session de critique collective de dashboards réels — très riche en retours concrets.*

### Structure générale recommandée
- **KPIs en haut** (scorecards), **2-3 graphiques explicatifs** en dessous, navigation claire (souvent à gauche)
- **3-4 éléments maximum par page** — au-delà, la lecture devient difficile (contre-exemple vu : un dashboard à 13 éléments graphiques sans cohérence de couleur ni ordre de lecture, totalement illisible)
- Pour des besoins multi-équipes : **ne pas tout entasser sur une seule page**. Préférer un filtre par équipe, ou des pages séparées — chaque équipe n'a besoin de voir que ses propres données.

### Hiérarchie visuelle
- Toujours identifier **l'information principale** et la placer **en haut à gauche** (sens de lecture naturel)
- Éviter les dashboards où "tout se vaut" — sans hiérarchie claire, le lecteur ne sait pas où regarder en premier ni quel est le KPI star
- Trier les données par la valeur qu'on veut mettre en avant (ex : un tableau non trié par importance perd en clarté)

### Légendes et titres
- **Indispensables** — sans titre ni légende, un graphique devient un ensemble de formes non interprétables (démonstration extrême en session : un dashboard "caricatural" fait uniquement de formes colorées sans aucun label, impossible à lire malgré une structure visuelle correcte)
- Un axe sans titre d'échelle (ex : "est-ce que c'est en dollars, en euros ?") est un défaut fréquent à corriger

### Couleurs
- **Limiter la palette**, assurer le **contraste**, maintenir la **cohérence** entre graphiques (une couleur = toujours la même signification sur tout le dashboard)
- Éviter : fonds orange, effets 3D/reflets sur les pie charts, couleurs assignées sans logique (ex : une couleur par pays sur une carte sans rapport avec la donnée réelle affichée)
- **Convention culturelle à connaître** : en contexte européen, vert = positif / rouge = négatif — mais c'est **l'inverse en Chine** (rouge = positif/chance, vert = négatif). Toujours adapter la palette au public cible du dashboard.
- Logique d'intensité : plus une valeur est élevée, plus la couleur devrait en général être foncée (ou l'inverse, mais **de façon cohérente et expliquée par une légende**) — un dégradé sans échelle visible est inutilisable.

### Pie charts
- Toujours afficher les **pourcentages ou labels de données** directement sur le chart
- Aucun effet visuel (3D, reflet) — purement décoratif et nuit à la lecture

### Cartes géographiques
- Se demander si la carte **apporte vraiment une valeur** au discours, ou si une simple catégorisation (par région/continent) serait plus lisible
- Prévoir une **légende avec échelle**
- Éviter les grandes zones vides (pays non couverts par la donnée) qui donnent une impression de carte "à trous" peu professionnelle

### Tableaux
- Préférer un **top 10** à une liste exhaustive de toutes les lignes — se demander si chaque ligne individuelle apporte une info utile au lecteur, ou si un focus resserré serait suffisant

---

## 📦 Livrable d'un dashboard Looker Studio

- Le livrable est un **lien Looker Studio en mode visualisation** (mode vue) — pas de fichier physique interactif type "PDF avec filtres jouables"
- Un dashboard peut être présenté directement depuis Looker Studio en **mode présentation**, avec les données chargées **en direct** (live) — utile pour une présentation client/board sans dépendre d'un export figé

---

## 🎯 Points clés pour les entretiens

- **BI = collecte + transformation + analyse + restitution visuelle** — la dataviz n'est qu'une brique du processus BI global
- Les **5 types de dashboards** (Reporting, Monitoring, Optimisation, Analyse ad hoc, Decision support) — bon framework pour structurer une réponse "à quoi sert un dashboard ?"
- La règle **"Metrics = what, Dimensions = how"** pour décomposer une demande business en spec technique
- Le framework de choix de chart : **distribution / composition / relation / comparaison** — savoir justifier pourquoi tel chart plutôt qu'un autre (ex : pas de pie chart si variation dans le temps, pas de % sans référence à la valeur absolue)
- Distinguer **Date Range Dimension** (filtrage/plage de dates) et **Dimension** (affichage) — piège classique de configuration
- **Sensibilité culturelle des couleurs** (vert/rouge Europe vs Chine) — bon exemple concret à citer pour montrer une compréhension fine du design de dashboard orienté utilisateur final
- Le **livrable d'un dashboard BI est un lien vivant**, pas un fichier statique — contrairement à un rapport PDF classique

---

## 🔗 Liens avec d'autres notions

- Le triptyque **Dimension / Metric** rappelle directement le vocabulaire vu pour GTM (#17) — "Dimension" en BI ≈ "Property" côté tracking, même logique de contextualisation d'une valeur
- Le choix du chart type rejoint la logique du **KPI Framework** vue au chapitre tracking (#17) : une fois le KPI et sa formule définis, le chart type découle de "qu'est-ce que je veux montrer avec ce KPI"
- La prudence sur les **jointures en amont plutôt que le Blend Data** dans Looker Studio fait écho à la même logique dbt : préférer résoudre la complexité dans le pipeline de données plutôt que dans l'outil de restitution

---

## ✅ Actions post-session

- [ ] Copier le template Looker Studio fourni pour les challenges (trois petits points > "Make a copy")
- [ ] Reconnecter les sources de données après copie, **dans l'ordre d'origine** (ex : CIRCLE_RETURN puis GW16 — l'ordre inversé fausse les graphiques)
- [ ] Explorer l'outil à travers les questions du premier challenge
- [ ] Préparer la session du lendemain sur les **champs calculés**
- [ ] Lire le support sur la structuration de dashboard (storytelling) avant la session du matin
- [ ] S'inspirer des exemples de dashboards (restaurants, séries) montrés en session pour le projet

---

## ❓ Questions / Points flous

- [ ]
- [ ]

---

*Chapitre 1/2 sur Looker Studio — la suite (champs calculés, partie pratique approfondie) fera l'objet d'un chapitre séparé (#20 probablement).*
