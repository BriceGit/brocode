# 📝 #21 — Data Storytelling & bonnes pratiques dataviz (journée projet)

**Date** : 03 août 2026
**Thème** : Rôle du data storytelling, choix des graphiques, psychologie UX/UI, EDA, construction de KPIs avec le métier, orchestration de pages Looker
**Compréhension (1→5)** : ⭐⭐⭐

---

## 🎯 Contexte de la session

- Journée projet, pas un cours classique — un mini-cours théorique le matin, puis après-midi/soir consacrés à un dashboard sur des données Airbnb
- Pas de captures d'écran cette fois : contenu volontairement léger, mais **complémentaire** des chapitres [#19](19-looker-studio-1.md) (fondamentaux Looker Studio) et [#20](20-looker-studio-2.md) (fonctionnalités avancées)
- Différence de focus : #19/#20 couvraient le *comment* (l'outil), cette session couvre le *pourquoi* — la psychologie derrière un bon dashboard et la méthode pour construire des KPIs fiables avec le métier

---

## 🧭 Rôle du Data Analyst et Data Storytelling

- Pipeline rappelé : **raw data → ELT → Data Warehouse → transformation (dbt/SQL) → Gold data → outils de visualisation**
- Deux cas d'usage pour un Data Analyst face au business :
  - **Le dashboard** : piloter un scope métier au quotidien (KPIs récurrents)
  - **L'analyse ad hoc** : répondre à une problématique précise (ex. pourquoi le CA baisse ce mois-ci)
- **Data Storytelling** = dataviz (bons graphiques) **+** techniques narratives, pour communiquer insights/tendances/patterns et influencer une décision
- 📌 Point clé : ne jamais s'arrêter à *décrire* une courbe ("elle descend"). L'objectif final est toujours une **recommandation actionnable** ("elle descend à cause de X, on recommande Y")

---

## 📊 Choisir le bon graphique — déclinaison concrète

Le framework **distribution / composition / relation / comparaison** vu au [#19](19-looker-studio-1.md) se traduit ici en choix pratiques :

| Type de graphique | Cas d'usage |
|---|---|
| **Bar chart** | Comparaison entre catégories |
| **Line chart / Time series** | Évolution d'une valeur à travers le temps (ex. CA) |
| **Donut / Camembert** | Répartition en % — **5 tranches maximum** pour rester lisible |
| **Scatterplot** | Influence d'une variable sur une autre (corrélation positive, négative, ou absence de corrélation) |
| **Graphique combiné (barre + ligne)** | Deux variables à échelles différentes, avec **axe gauche + axe droit** |

Règle transversale : **un graphique = un message**. Un graphique qui veut tout montrer ne montre plus rien.

### Ressources pour la culture graphique

- **[datavizproject.com](http://datavizproject.com)** : catalogue de graphiques avec description, cas d'usage, exemples
- **Ataviz (Plotly)** : catalogue orienté Python, avec code prêt à l'emploi (utile une fois sur `sklearn`/Python) — ex. histogramme + ligne de tendance (KDE)
- **Cheat-sheets** : pour retrouver rapidement le bon graphique selon le type de données (distribution, évolution, relation, comparaison)
- **The Economist** : référence de culture graphique — surtout lignes et barres, titres explicatifs, sous-titres, annotations contextuelles, couleurs sobres

---

## 🎨 Bonnes pratiques de conception graphique

- Un graphique doit être compris en **30 secondes maximum** — au-delà, le message est brouillé
- Les 5 éléments essentiels : **bon titre, bonne légende, bonnes couleurs, bonne échelle, annotations si nécessaire**
- Deux variables d'échelles différentes (ex. valeur absolue + pourcentage) → **toujours** un axe gauche et un axe droit, jamais un seul axe partagé
- Ne jamais mélanger des variables de nature différente dans un même bar chart
- Utiliser la **couleur** pour guider l'œil vers l'essentiel (ex. top 3 en couleur, le reste grisé) plutôt que pour décorer
- Outils : **Adobe Express** (accessible sans compte) et **Coolors** (visualiseur de répartition de palette)

---

## 🧠 UX/UI et psychologie de l'utilisateur

- Concevoir un dashboard est avant tout une question de **psychologie** : se mettre à la place de l'utilisateur pour minimiser les frictions de compréhension
- L'œil scanne une page selon deux patterns établis :
  - **F-pattern** → interfaces portrait / mobile
  - **Z-pattern** → interfaces web / paysage
- Respecter les conventions de navigation web existantes (logo en haut à gauche, call-to-action en haut à droite) plutôt que de réinventer une logique propre
- Exemple cité en session : **Carrefour possède plus de dashboards que d'employés** — des dashboards créés mais jamais adoptés parce que l'UX ne facilitait pas la prise en main, ce qui a poussé les équipes à retourner à leurs habitudes (CSV, Excel)

### Le Data Ink Ratio

- Principe : supprimer tout élément graphique superflu (grilles inutiles, axes redondants, couleurs décoratives) pour ne garder que l'essentiel
- 💡 Anecdote de contexte (ajoutée par rapport au transcript) : ce ratio existe depuis l'époque des **statisticiens**, qui précédaient historiquement le métier de data analyst — au XIXe siècle, les grands groupes (souvent des banques) et les États faisaient appel à eux pour le recensement et les grandes analyses. L'encre coûtait cher, d'où la discipline de minimiser ce qui était imprimé
- Le ratio a survécu à l'ère de l'impression : la justification a changé (ce n'est plus une question de coût d'encre) mais l'effet reste le même — **moins d'éléments superflus = accès plus rapide à l'information**, ce qui est exactement le même principe que le highlighting top 3 / reste grisé vu plus haut

---

## 🔬 EDA, données micro/macro & recommandations

- **EDA (Exploratory Data Analysis)** : chaque graphique répond à une hypothèse, et une hypothèse en amène une autre — jusqu'à répondre à la problématique de départ. Différent d'un dashboard, où les KPIs sont déjà définis par le métier et à reproduire
- Distinguer deux environnements de données :
  - **Micro** : interne à l'entreprise (bases de données, outils propres)
  - **Macro** : externe à l'entreprise (saisonnalité, vacances scolaires, COVID, campagnes marketing concurrentes...)
- Les données macro influencent fortement les données micro — exemple donné : un drop de CA en juillet expliqué par la période estivale, des pics au Q1 expliqués par des campagnes marketing internes
- 📌 Un scorecard seul ne veut rien dire sans point de comparaison (mois précédent, objectif...) — 70 000 nouveaux utilisateurs est positif si le mois d'avant il y en avait 50 000, négatif si le mois d'avant il y en avait 100 000

---

## 🎯 Adapter l'analyse à l'audience

| Audience | Ce qu'elle attend |
|---|---|
| **Investisseurs / COMEX** | Vue d'ensemble, état des lieux |
| **Top managers** | Recommandations, aide à la prise de décision |
| **Team managers** | Monitoring des équipes opérationnelles |
| **Équipes opérationnelles** | Suivi des ressources au quotidien |

- Tenir compte de la **proximité de l'audience avec la data** : une audience déjà habituée aux dashboards peut recevoir des graphiques plus élaborés
- Temps de construction : un **dashboard** prend une semaine à un mois (allers-retours avec les équipes) ; un **reporting ad hoc** est plus rapide

---

## 🧩 Construire le brief et les KPIs avec le métier

- Poser un maximum de questions pour comprendre le besoin réel — souvent différent du besoin exprimé au départ
- Pour chaque KPI, valider avec l'équipe métier : **mode de calcul, source de la donnée, période de référence, définition précise**
- Exemple concret donné en session : calculer "la marge" du Q1 nécessite de clarifier si c'est la marge **nette ou brute** (coûts pris en compte différents), si elle est calculée à l'émission de facture ou à la réception du paiement, et sur quels délais (30/60/90 jours en B2B)
- Construire le KPI de façon **incrémentale** : partir d'un calcul basique, puis l'affiner au fur et à mesure des retours métier, plutôt que de vouloir la version finale dès le départ

---

## 🗂️ Orchestration des pages dans Looker Studio *(spécifique outil)*

- Créer **une page par idée/scope** plutôt qu'un one-page surchargé — chaque page doit avoir un titre et des graphiques cohérents entre eux
- Dans *Thème et mise en page* : choisir le format (16/9, portrait/paysage — utile si le dashboard est pensé pour mobile) et gérer les pages depuis l'onglet **Propriétés**
- Utiliser des **gabarits** et segmenter visuellement (fond de couleur, encarts) pour aider l'œil à compartimenter l'information — le créateur connaît son dashboard par cœur, l'utilisateur final non
- Prévoir systématiquement une **page de recommandations** et une **page de conclusion**
- ✅ Réflexe de validation : répéter sa présentation devant quelqu'un qui n'a aucune connaissance du sujet — si cette personne ne comprend pas, c'est le graphique ou l'explication qu'il faut retravailler, pas l'audience

---

## 🎯 Points clés pour les entretiens

- Savoir formuler la définition du **Data Storytelling** : dataviz + narration, avec pour objectif final une recommandation, pas une simple description
- Le **Data Ink Ratio** est une bonne réponse de culture générale pour une question UX en entretien — pouvoir en expliquer l'origine historique (statisticiens, coût de l'encre) montre une compréhension du *pourquoi*, pas juste du *quoi*
- Savoir illustrer la distinction **données micro vs macro** avec un exemple concret (saisonnalité, COVID) — bon réflexe pour répondre à "comment expliquer une anomalie dans la donnée"
- Adapter le **niveau de recommandation à l'audience** (COMEX vs team manager) est un point souvent testé en entretien pour évaluer le sens business, pas que la technique
- Savoir raconter la **méthode de validation d'un KPI avec le métier** (aller-retours, définition précise, construction incrémentale) plutôt que d'annoncer un chiffre : c'est un bon exemple STAR pour "comment garantis-tu la fiabilité de tes chiffres ?"

---

## 🔗 Liens avec d'autres notions

- Le framework de choix de graphique (distribution/composition/relation/comparaison) vu au [#19](19-looker-studio-1.md) trouve ici son application concrète, type de graphique par type de graphique
- L'importance du storytelling avait déjà été flaggée en clôture du [#20](20-looker-studio-2.md) ("aussi déterminant que la qualité de la donnée et le soin visuel") — cette session en donne le cadre théorique complet
- La méthode de validation des KPIs avec le métier (définition, source, période) rejoint directement la logique déjà vue en SQL sur les `CASE WHEN` de segmentation métier — même exigence de clarifier la règle de gestion avant de coder quoi que ce soit
- Le réflexe "un scorecard seul ne veut rien dire sans comparaison" est le pendant dataviz du principe **aggregate before divide / conservation tests** déjà noté en BigQuery/dbt/DAX : dans les deux cas, un chiffre isolé ou mal contextualisé peut raconter une histoire fausse
- Fait écho à la rétrospective personnelle notée sur le projet RFM : la méthodologie et sa présentation comptent autant que le résultat lui-même


---

*Chapitre complémentaire aux [#19](19-looker-studio-1.md) et [#20](20-looker-studio-2.md) — journée projet, contenu théorique volontairement condensé, à enrichir si des points reviennent en session ultérieure.*
