# 📝 #20 — Looker Studio (2/2) : mise en forme, fonctionnalités avancées & bonnes pratiques

**Date** : 31 juillet 2026
**Thème** : Habillage de dashboard, style des graphiques, breakdown, drill-down, métriques optionnelles, cross-filtering, champs calculés, gestion des sources, partage & gouvernance
**Compréhension (1→5)** : ⭐⭐⭐⭐

---

## 🎯 Contexte de la session

- Suite directe du [chapitre #19](19-looker-studio-1.md) — session plus longue, beaucoup plus orientée **pratique et interface**
- La démo est regroupée en fin de session (plutôt que dispersée) pour gagner du temps
- Objectif de la journée : enchaîner sur un challenge pratique de 7 exercices (formatage de graphiques, breakdown, drill-down, métriques optionnelles, export de données)

---

## 🖼️ Habiller un dashboard

- Au-delà des graphiques eux-mêmes, Looker Studio permet d'ajouter des éléments de mise en page classiques (comme sur Word ou PowerPoint) : **formes, flèches, zones de texte, images**
- Usages concrets : construire un menu de navigation latéral entre les pages, structurer visuellement un dashboard, masquer temporairement une page pas encore terminée en mode vue
- **Gestion des pages** via le menu dédié (numéro de page cliquable) : réorganiser, dupliquer, supprimer, créer une page vide ou dupliquée
- ⚠️ **Travail collaboratif** : ne jamais éditer la même slide à deux en simultané → dupliquer la slide, travailler chacun de son côté, puis réagencer/fusionner ensuite

---

## 📊 Un bon graphique : les fondamentaux du style

### Les 2 questions de validation

Un bon graphique doit être **compris en 5 à 10 secondes**, sans connaissance préalable du sujet. Deux questions pour le valider avant de le considérer terminé :

1. **Peut-on le comprendre sans connaissance préalable ?**
2. **Le graphique raconte-t-il vraiment quelque chose ?** (il doit répondre à une question, pas juste afficher de la donnée)

💡 Test terrain : montrer le graphique à quelqu'un qui ne connaît pas le sujet et chronométrer le temps qu'il met à en tirer une conclusion.

### Checklist de mise en forme

| Élément | Bonne pratique |
|---|---|
| **Titre** | Toujours présent, doit annoncer le message du graphique |
| **Axes** | Titres clairs sur chaque axe |
| **Échelle** | Ni trop écrasée (perte de lisibilité), ni trop zoomée (exagère les variations) |
| **Axe double (Y gauche/droite)** | À utiliser quand 2 métriques ont des échelles très différentes (ex : CA en K€ + taux en %) |
| **Ligne de référence** | Utile pour matérialiser un objectif à atteindre (ex : objectif commercial d'une équipe) |
| **Couleurs** | Cohérence : la même dimension garde la même couleur sur tous les graphiques d'un dashboard |
| **Mise en forme** | Cohérence : même style (police, taille, légende) reproduit sur tous les graphiques d'un même dashboard |
| **Densité d'info** | Ni trop peu (multiplie inutilement le nombre de graphiques), ni trop (noie le message) |
| **Police** | Taille suffisante pour rester lisible une fois les labels affichés |
| **Camembert / donut** | Curseur dédié pour régler l'épaisseur de l'anneau |

- Sens horizontal : plutôt pour les séries temporelles ; sens vertical (barres horizontales) : plutôt pour un classement (ranking)
- Le style se configure **par série** : un menu permet de choisir si la modification s'applique à *toutes* les séries ou à *une seule*

---

## 🔎 Analyser plusieurs dimensions, granularités et métriques

Trois fonctionnalités répondent chacune au même dilemme : trop peu d'infos vs. trop de graphiques.

### Breakdown — ajouter une dimension de ventilation

**Problème type** : afficher le CA par mois *et* par canal d'acquisition, avec une seule métrique.

| Option | Résultat |
|---|---|
| ❌ Un sélecteur/filtre par canal | Pas assez d'indicateurs — un seul canal visible à la fois |
| ❌ Un graphique par canal | Trop de graphiques — comparaison difficile |
| ✅ **Breakdown** | Dimension de ventilation ajoutée directement sur le graphique — tous les canaux affichés ensemble |

- Disponible surtout sur les graphiques à **une seule métrique** : séries temporelles, colonnes, aires empilées, barres
- Le nombre de séries affichées est réglable (limite recommandée : **5 catégories max**, au-delà ça devient illisible) ; un tri (top N) permet de ne garder que les catégories les plus significatives
- **100% stacking** : bascule la lecture du volume (combien) vers la **répartition relative dans le temps** (est-ce qu'un canal gagne ou perd du poids ?) — deux lectures différentes du même breakdown

### Drill-down — naviguer entre niveaux de granularité

**Problème type** : afficher CA et coûts par trimestre, mois *et* jour à la fois.

| Option | Résultat |
|---|---|
| ❌ Un sélecteur de plage de dates unique | Pas assez d'indicateurs — un seul niveau de granularité visible |
| ❌ Un graphique par niveau (trimestre / mois / jour) | Trop de graphiques — le niveau jour devient illisible |
| ✅ **Drill-down** | Flèches ↑↓ dans la barre d'options du graphique pour changer de niveau à la demande |

- Fonctionne principalement sur les **dates** (jour → semaine → mois → trimestre → année), mais aussi sur des **hiérarchies de catégories** (ex : retail — rayon → sous-catégorie → produit)
- Disponible sur la plupart des types de graphiques : séries temporelles, colonnes, barres, aires empilées, tables, camemberts
- Il est possible d'afficher **plusieurs métriques** simultanément en drill-down (pas limité à une seule)
- ⚠️ Le niveau affiché **par défaut** doit rester lisible : un défaut au jour peut vite devenir illisible sur une longue période
- N'activer la barre d'options que si le drill-down est réellement utilisé — sinon c'est un élément d'interface en trop

### Métriques optionnelles — afficher à la demande

Permet d'ajouter des métriques sans les afficher en permanence, pour ne pas surcharger un graphique qui a déjà 2-3 métriques actives.

- Accessible via un bouton dédié dans la barre d'options du graphique, en mode édition comme en mode lecture
- La barre peut être configurée pour s'afficher **au survol** ou **en permanence** ("always show")
- Peu pertinent sur les scorecards (mieux vaut multiplier les scorecards) et les camemberts

💡 **Point à retenir** : le sélecteur change de comportement selon le contexte du graphique.
- **Sans dimension de breakdown active** → cases à cocher (☑️), plusieurs métriques peuvent être affichées en même temps (chacune a sa propre série/couleur)
- **Avec une dimension de breakdown déjà active** → boutons radio (🔘), une seule métrique à la fois — la couleur est déjà utilisée pour coder la dimension de breakdown, donc combiner plusieurs métriques rendrait le graphique illisible

### Cross-filtering — sélection interactive entre graphiques

- Une fois activé, sélectionner une zone sur un graphique **filtre automatiquement** tous les autres graphiques utilisant la même source de données
- Se désactive **graphique par graphique** : utile pour garder un scorecard global fixe (ex : CA total) pendant qu'un autre graphique se filtre dynamiquement sur la sélection
- Pour revenir à la vue par défaut : re-cliquer sur la sélection, ou recharger la page en dernier recours

---

## 🧮 Champs calculés

Permettent de créer une nouvelle colonne/KPI **directement dans Looker Studio**, sans toucher à la table source. Trois cas d'usage.

### 1. Nouvelle dimension (recatégorisation)

Utile pour regrouper une valeur textuelle en catégories métier, via `CASE WHEN` :

```
CASE
  WHEN CONTAINS_TEXT(journey_name, "%panier_abandonne%") THEN "abandoned_basket"
  WHEN CONTAINS_TEXT(journey_name, "%back_in_stock%") THEN "back_in_stock"
  WHEN CONTAINS_TEXT(journey_name, "%nl%") THEN "newsletter"
  ELSE NULL
END
```
→ Nouveau champ `mail_type`, généré à partir de la colonne `journey_name`.

### 2. Nouvelle métrique standard

Un calcul simple (ex : une marge) ajouté à la demande sans repasser par la table source.

### 3. Nouvelle métrique de ratio agrégé — ⚠️ le piège classique

**Question** : comment calculer un taux de conversion global à partir de plusieurs lignes (ex : plusieurs jours) ?

| date_date | nb_sessions | nb_transaction |
|---|---|---|
| 2022-10-01 | 100 | 1 |
| 2022-10-02 | 200 | 5 |

- **❌ Diviser puis moyenner** (moyenne des taux journaliers) : (1 % + 2,5 %) / 2 = **1,75 %** → une moyenne de moyennes, qui donne le même poids à un jour à 100 sessions qu'à un jour à 200
- **✅ Agréger puis diviser** : SUM(transactions) / SUM(sessions) = 6 / 300 = **2 %** → le résultat correct, qui respecte le poids réel de chaque jour

```
SUM(nb_transaction) / SUM(nb_sessions)
```
→ Nouveau champ `% conversion`

📌 Cette règle **« toujours agréger avant de diviser »** rejoint directement le réflexe déjà noté côté dbt/BigQuery (`SAFE_DIVIDE`, ne jamais arrondir une colonne intermédiaire) : dans les deux cas, l'erreur vient du fait de calculer ligne par ligne avant d'agréger plutôt qu'après.

### Où mettre le champ calculé ?

| Cas | Où le créer |
|---|---|
| KPI utilisé **une seule fois**, ponctuellement | Champ calculé dans Looker Studio |
| KPI utilisé **souvent**, sur plusieurs graphiques/dashboards | Le pousser dans la table source (dbt/SQL) — évite de le recréer à chaque fois et centralise la logique |

---

## 🗄️ Gestion des sources de données

### Ajouter et connecter une source

- Se fait via *Gérer les sources* → choisir un connecteur
- **BigQuery recommandé** pour la latence (le plus performant) ; les connecteurs CSV / Google Sheets fonctionnent mais sont plus lents
- Les **connecteurs partenaires** (ex : Google Ads) sont parfois moins fiables — les champs peuvent ne pas correspondre exactement à la donnée source → toujours vérifier la cohérence après connexion

### Connexion directe (source → BI) vs. passage par la data platform

Un point de pratique métier utile :
- **Analyse ponctuelle et ciblée** (ex : investiguer un chiffre bizarre repéré dans un résultat) → on peut connecter l'outil source directement à la BI, sans repasser par une plateforme de données
- **Rapport récurrent ou combinant plusieurs sources** → mieux vaut transformer la donnée en amont (SQL/dbt) et n'envoyer que la table finale à la BI, sinon la logique de transformation se retrouve dupliquée dans chaque dashboard

*(Ce choix rejoint la logique déjà notée sur les jointures en amont vs. Blend Data : résoudre la complexité dans le pipeline de données plutôt que dans l'outil de restitution, dès que l'usage devient récurrent.)*

### Éditer les champs d'une source

Modifiable directement sur la source (bouton *Edit*) :
- **Renommer** un champ (nom d'affichage, indépendant du nom réel en base)
- **Changer le type de donnée** (ex : Number → Currency, avec choix de la devise)
- **Changer la fonction d'agrégation par défaut** : None, Sum, Average, Count, Count Distinct, Min, Max, Median, Standard deviation, Variance

⚠️ **Portée de la modification** :
- Modifier **au niveau de la source** (dans *Gérer les sources*) → impacte **tous les graphiques** qui l'utilisent, en une seule opération
- Modifier **au niveau d'un graphique** → n'impacte que ce graphique précis

→ Pour un changement qui doit s'appliquer partout, toujours passer par la source globale : le faire graphique par graphique sur un dashboard qui en a 10 devient vite une perte de temps considérable.

### Rafraîchir et synchroniser

- Si la table source (ex : BigQuery) évolue, deux options : **rééditer la connexion** (ré-authentifier) ou utiliser le bouton **Refresh Fields**, qui compare l'état actuel de la source avec ce que Looker Studio connaît et propose d'ajouter les nouveaux champs détectés
- **Fraîcheur des données** configurable : entre 15 minutes et 12h, avec un minimum possible de 5 minutes en custom
- Une source peut être marquée **réutilisable** : elle apparaît directement dans la liste des sources disponibles pour un autre rapport, sans avoir à la rechercher à nouveau dans BigQuery

### ⚠️ Piège : changer la source d'un graphique existant

En basculant un graphique d'une source vers une autre (ex : passer d'une table `orders` à une table `sales`), Looker Studio tente de réassigner automatiquement les dimensions/métriques par correspondance de nom. Si les noms de colonnes ne correspondent pas exactement entre les deux sources, il **réassigne au hasard** une colonne de remplacement — silencieusement, sans erreur visible. Réflexe : toujours revérifier les champs du graphique après un changement de source.

---

## 📤 Partage, export & gouvernance

### Partage par lien (query porting)

- Le lien de partage peut inclure les **filtres actifs au moment du partage** (case *"Link to your current report view"*)
- Cas d'usage type : filtrer un dashboard sur les performances d'un commercial précis, puis envoyer le lien filtré directement à cette personne — elle n'a rien à reconfigurer
- Le lien partagé crée une **copie figée de la vue filtrée** : si les filtres du rapport d'origine changent ensuite, le lien déjà envoyé reste sur sa vue initiale (dissocié)

### Export PDF

- Sélection des pages à exporter, options supplémentaires : ignorer la couleur de fond personnalisée, ajouter un lien de retour vers le rapport, **protéger par mot de passe**
- Deux enjeux distincts à retenir :
  - **Sécurité des données** → mot de passe sur le PDF
  - **Fraîcheur** → un PDF est figé dans le temps ; pour une donnée toujours à jour, préférer le **lien vers le rapport en ligne** plutôt que le téléchargement

### Export de données d'un graphique

Possible graphique par graphique, utile pour vérifier ponctuellement la donnée sous-jacente en cas de doute, sans repasser par la table source.

### Gouvernance des accès

- Gérable au niveau du **rapport** (qui peut voir/éditer le dashboard) et au niveau de la **source de données** (restreindre l'accès à certaines sources à certaines personnes — utile sur un dashboard partagé entre plusieurs équipes qui n'ont pas toutes le même niveau d'accès à la donnée)
- Ne donner les droits d'**édition** qu'aux personnes qui en ont réellement besoin ; le reste en lecture seule

### Documenter ses dashboards

Avoir une vue récapitulative de tous ses dashboards apporte 4 bénéfices :

| Bénéfice | En pratique |
|---|---|
| **Accessibilité** | Accès facile et centralisé à tous les dashboards existants |
| **Compréhension** | Une description claire de l'objet de chaque dashboard |
| **Gouvernance** | Un référent identifié pour chaque dashboard (qui contacter en cas de problème) |
| **Travail transverse** | Partage de connaissance entre équipes, évite de recréer un dashboard qui existe déjà ailleurs |

### Storytelling

Présenté comme **aussi déterminant que la qualité de la donnée et le soin visuel** : une présentation mal racontée peut faire perdre toute la crédibilité d'un travail d'analyse par ailleurs solide. Ça se prépare en amont, pas dans l'instant.

### Graphiques communautaires

Au-delà des types de graphiques disponibles par défaut, Looker Studio propose des **graphiques communautaires** (ressources tierces) pour des visualisations plus spécifiques non couvertes nativement.

---

## 🎯 Points clés pour les entretiens

- Le principe **« agréger d'abord, diviser ensuite »** pour tout ratio/taux — un classique à savoir justifier, transférable à SQL/dbt (`SAFE_DIVIDE`, colonnes intermédiaires non arrondies)
- Savoir distinguer **breakdown** (ventiler une dimension supplémentaire sur un même graphique) et **drill-down** (naviguer entre niveaux de granularité d'une même dimension) — deux réponses différentes au même problème de "trop de graphiques ou pas assez d'infos"
- La règle de portée **source globale vs. graphique local** pour une modification de champ — bon réflexe à mentionner pour montrer une compréhension de la maintenabilité d'un dashboard à l'échelle
- Le choix **connexion directe vs. passage par la data platform** selon qu'il s'agit d'une analyse ponctuelle ou d'un rapport récurrent

---

## 🔗 Liens avec d'autres notions

- Le réflexe *« agréger avant de diviser »* est le même principe déjà noté côté BigQuery/dbt : `SAFE_DIVIDE` et le fait de ne jamais arrondir une colonne intermédiaire utilisée en entrée d'un calcul — même erreur de fond (perte de précision par calcul prématuré ligne par ligne), deux syntaxes différentes
- La discussion connexion directe vs. data platform complète le point déjà noté sur les **jointures en amont vs. Blend Data** (#19) : dans les deux cas, la recommandation est de résoudre la complexité de transformation dans le pipeline de données plutôt que dans l'outil de restitution, dès qu'un usage devient récurrent
- Le duo **breakdown / drill-down** vient enrichir le triptyque Dimension/Metric déjà vu en #19 : ce sont deux façons différentes de manipuler la dimension affichée sur un graphique, sans en changer la nature

---

## ✅ Actions post-session

- [ ] Réaliser les 7 premiers exercices du challenge : formatage de graphiques, breakdown, drill-down, métriques optionnelles, export de données
- [ ] Réserver au moins 1,5 jour dédié à l'entraînement de la présentation orale dans le cadre du projet de deux semaines

---

## ❓ Questions / Points flous

- [ ]
- [ ]

---

*Chapitre 2/2 sur Looker Studio — suite directe du [#19 — fondamentaux de la dataviz](19-looker-studio-1.md).*
