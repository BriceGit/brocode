# 📝 #22 — Power BI (1/3) : présentation, Power Query, Data Model & dashboard design

**Date** : 04 août 2026
**Thème** : Présentation Power BI (licences, pipeline, objets), Power Query (ETL, transformations, combinaison de données), Data Model / Star Schema, bonnes pratiques de dashboard design, panorama des graphiques, formatage, interactivité & navigation
**Compréhension (1→5)** : ⭐⭐⭐⭐

---

## 🎯 Contexte de la session

- Premier jour du module Power BI (module annoncé sur trois jours) — les trois cours précédents portaient sur Looker Studio ([#19](19-looker-studio-1.md), [#20](20-looker-studio-2.md), [#21](21-looker-studio-3-data-storytelling.md))
- Session très dense, presque deux cours en un : théorie (positionnement, licences, pipeline, objets) **et** pratique complète (Power Query, Data Model, création de graphiques, formatage, interactivité, navigation) — la suite du module doit approfondir le DAX et le Star Schema
- Power BI utilisé via Parallels sur Mac (pas de version native Mac)
- Se termine par une session de critique de dashboards réels, sur le même format pédagogique que celle déjà vue en Looker Studio ([#21](21-looker-studio-3-data-storytelling.md)) — bon comparatif : les erreurs relevées sont indépendantes de l'outil

---

## 🖥️ Power BI — présentation & positionnement

- Outil de **visualisation de données** intégré à la suite Microsoft : prépare la donnée (ETL), l'explore, la visualise et partage des dashboards
- Positionné **leader du marché en 2024** (face à Google, Oracle, Salesforce/Tableau) — différenciateur clé : intégration de **Copilot** (IA), réservée aux licences Pro/Premium
- Face à Excel : la BI permet de gérer de plus gros volumes et surtout d'**automatiser** la chaîne source → dashboard, ce qu'Excel ne permet pas nativement

### Licences

| Licence | Ce qu'elle permet |
|---|---|
| **Gratuite** | Téléchargement PC uniquement (pas de version Mac native) |
| **Pro** | Licence par poste, partage via Power BI Service — uniquement entre personnes elles-mêmes licenciées Pro |
| **Premium** | Partage de dashboards à n'importe qui, licencié ou non — indispensable par exemple pour un COMEX |

💡 Retour d'expérience du formateur : un dashboard construit pour un client a dû passer de Pro à Premium le jour où il a fallu le partager au CEO, qui n'avait pas de licence Power BI.

---

## 🔗 Pipeline Power BI

**Sources de données → Power Query (ETL) → Star Schema (modèle relationnel) → DAX (mesures) → Visualisation**

Deux langages à connaître, aucun n'est un prérequis pour démarrer :
- **Langage M** : géré par l'interface Power Query, pilote les transformations
- **DAX (Data Analysis eXpressions)** : champs calculés et mesures, approfondi lors d'une prochaine session

### Objets Power BI

| Objet | Définition |
|---|---|
| **Report** | Une ou plusieurs pages de visualisations interconnectées, issues d'un même dataset — c'est l'usage principal en formation |
| **Dashboard** | Page unique dans le Power BI Service, composée de tuiles (graphiques isolés créés au préalable) provenant de sources variées, à but d'overview |
| **Semantic Model (couche sémantique)** | Collection de données importées/connectées — anciennement "Dataset" — associable à plusieurs workspaces, reports et dashboards |
| **Workspace** | Espace de centralisation des reports, dashboards et couches sémantiques dans le Power BI Service |

📌 Nuance à retenir : un *report* peut être associé à plusieurs *dashboards*, alors qu'un *dashboard* combine des tuiles pouvant venir de plusieurs sources différentes.

---

## 🧹 Power Query — l'ETL intégré

Interface séparée de Power BI Desktop (accessible via *Transformer les données*), où chaque transformation s'enregistre comme une **étape appliquée** — historique modifiable, réordonnable, renommable (recommandé pour la lisibilité).

⚠️ **Fermer et appliquer** valide les modifications ; **Fermer** seul les annule entièrement.

### Import
- Nombreux connecteurs : fichiers plats (xlsx, csv, json), bases SQL (SQL Server, MySQL, PostgreSQL, BigQuery, Redshift, Snowflake), SAP, Salesforce, APIs, web scraping
- ⚠️ Par défaut, l'aperçu ne charge que les **1000 premières lignes** — même logique que le `LIMIT` implicite déjà vu en SQL. Décocher l'option en bas de fenêtre pour charger l'intégralité du dataset

### Nettoyage — transformations courantes
| Action | Usage |
|---|---|
| Promouvoir la 1ère ligne en en-têtes | Corrige les colonnes nommées "Colonne1", "Colonne2"... quand l'import ne détecte pas l'en-tête |
| Changer le type/format | Texte, nombre décimal, date, latitude/longitude, booléen |
| Remplacer des valeurs | Ex. remplacer les points par des virgules pour des décimales mal importées d'un CSV |
| **NULL vs Erreur** | NULL = valeur vide (comme en SQL) ; Erreur = échec de calcul, marqué explicitement "Error" dans la cellule |
| Fill down / Fill up | Propage la dernière valeur non vide vers le bas ou le haut |
| Fractionner une colonne (Split) | Par délimiteur, nombre de caractères ou position |
| Extraire des caractères (Extract) | Longueur, premiers/derniers caractères, texte avant/après/entre délimiteurs |
| Dupliquer une colonne | Clic droit ou onglet dédié |

💡 Piège concret rencontré en session : une colonne de prix importée en texte à cause d'un point décimal non reconnu. Réflexe à deux étapes : remplacer d'abord le point par une virgule, **puis seulement** changer le type en décimal — l'ordre compte, et l'historique des étapes appliquées permet de réordonner sans tout refaire si l'erreur est repérée après coup.

### Enrichissement
- **Colonne personnalisée (Custom column)** : nouvelle colonne calculée à partir d'autres colonnes — ex. `TotalPrice = [Total products] * [Product Price]`
- **Colonne conditionnelle** : équivalent du `CASE WHEN` SQL / du champ calculé conditionnel déjà vu en Looker ([#20](20-looker-studio-2.md)) — ex. segmentation Small/Medium/Big Meal selon la quantité
  - ⚠️ Même piège que pour un `CASE WHEN` : si les conditions comparent des nombres, les trier de la plus haute à la plus basse pour éviter qu'une condition large n'écrase les suivantes
- **Colonne indexée (Index)** : incrémentale (1, 2, 3...), utile pour générer une clé primaire
- **Column from Examples** : déconseillée hors licence Premium — repose sur Copilot pour être vraiment fiable, sinon résultats peu robustes

### Combinaison de données
| Power Query | Équivalent SQL | Effet |
|---|---|---|
| **Merge (Fusionner)** | `JOIN` | Rapatrie des colonnes d'une autre table via une clé commune (Left/Right/Inner/Full Outer) |
| **Append (Ajouter)** | `UNION` | Empile des tables ayant les mêmes colonnes (même nom, même type) |

⚠️ Deux pièges rencontrés en session sur l'Append :
- Un **nom de colonne différent** entre les deux tables génère des valeurs NULL silencieuses (ex. `ItemName` vs `ItemName.1`) — toujours revérifier les noms de colonnes avant de fusionner/ajouter
- **L'ordre d'exécution des étapes compte** : des colonnes calculées créées dans une requête source *avant* l'Append (ex. `Total Price`, `Meal Size Category`) ne se propagent pas automatiquement aux lignes provenant de l'autre table — ces colonnes ressortent en NULL pour cette table tant que la transformation n'est pas reproduite sur toutes les sources, ou refaite après l'Append

💡 **Duplicate vs Reference**, deux façons de copier une requête : *Duplicate* copie la requête entière avec toutes ses étapes ; *Reference* crée une nouvelle requête qui ne fait que pointer vers la requête d'origine (une seule étape : "source = requête d'origine") — utile pour garder une base propre inchangée tout en créant des dérivés dessus.

### Limites de Power Query
- **Trop de transformations dans Power Query ralentit le dashboard** — chaque étape appliquée rallonge le temps de chargement. Un dashboard lent est pire qu'un dashboard mal habillé
- Les transformations restent **locales au fichier** : impossible de les renvoyer vers le Data Warehouse ou de les réutiliser telles quelles dans un autre dashboard (sauf à rapatrier le modèle sémantique complet depuis le Power BI Service, sans pouvoir le remodifier)
- 📌 Principe transversal déjà noté sur les champs calculés Looker ([#20](20-looker-studio-2.md)) : **faire un maximum de transformations en amont dans le Data Warehouse**, réserver Power Query aux ajustements spécifiques et non réutilisables ailleurs

---

## 🔀 Data Model (Star Schema)

- Les relations entre tables se configurent dans l'onglet dédié du Data Model (icône dédiée dans la barre latérale)
- 💡 Point à bien comprendre : **une relation ne crée pas de nouvelle table jointe** — elle indique simplement à Power BI que deux tables sont liées par une clé, pour que le moteur sache faire circuler les filtres entre elles
- Paramètres d'une relation : cardinalité (ex. *Many to one*), **sens de filtrage croisé** (Single ou Both), activation/désactivation de la relation
- Si deux tables combinées par Merge ne sont pas fusionnées proprement dans une nouvelle table, Power BI peut détecter une cardinalité *many-to-many* — situation à éviter, approfondie lors d'une prochaine session

---

## 🎨 Concevoir un dashboard — 6 bonnes pratiques (Designing Dashboards Best Practices)

Reprend et complète les fondamentaux déjà vus en dataviz ([#21](21-looker-studio-3-data-storytelling.md)), organisés ici par le formateur en 6 blocs :

1. **Dashboard Type & Audience** — Quel type de dashboard (C-level, Operational, Analytics) ? Qui est l'audience, quelles métriques l'aident à décider ?
2. **One-Screen Storytelling** — Éviter le scroll, limiter le nombre de visuels à l'essentiel (**idéalement moins de 8**, slicers compris — un slicer reste un objet connecté à la donnée)
3. **Pixel Real Estate** — Reprend le Z-pattern déjà vu en dataviz (#21) : titres, infos clés et slicers dans les zones hautes et gauche de l'écran ; structurer l'information en sections visuelles
4. **Adequate Visuals** — Choisir le visuel qui sert le message, pas le plus "fancy" ; ne pas varier les graphiques juste pour varier
5. **Design Patterns & Style** — Cohérence des formats, couleurs et styles sur tout le dashboard
6. **Non-Data to Ink Ratio** — Le pendant du Data Ink Ratio (#21), formulé à l'envers : éviter fonds colorés, animations et styles décoratifs qui ne servent pas la donnée

📌 La règle des 30 secondes reste valable ici : si un graphique demande plus de temps à comprendre, il manque un titre, une annotation, ou c'est le mauvais type de graphique.

---

## 📊 Panorama des graphiques Power BI

| Graphique | Cas d'usage | Pros | Cons |
|---|---|---|---|
| **Line chart / Time series** | Évolution dans le temps (ex. commandes par année) | Observation des changements, adapté aux taux | Illisible avec trop de lignes sur le même graphique |
| **Bar chart** | Comparaison entre catégories (ex. saisonnalité mensuelle par année) | Comparaison facile entre catégories, existe en vertical | Illisible si trop de catégories ou noms trop longs ; ne permet pas de comparer dans le temps |
| **Area chart** | Tendance globale + répartition dans le temps (ex. répartition small/medium/big meal par mois) | Bonne lecture de la tendance globale, relie une répartition à une dimension temporelle | Lecture difficile pour une seule catégorie ; pas de comparaison de proportions sans version "Stacked Percent" |
| **Pie / Donut chart** | Répartition en % (ex. répartition small/medium/big meal) | Composition facile à lire si peu de catégories | Pas de lecture dans le temps ; le label en % est quasi indispensable pour estimer les volumes |
| **Table** | Liste détaillée (ex. commandes avec date) | Peut intégrer des éléments graphiques | Lisible seulement si le nombre d'éléments est limité |
| **Matrix (TCD)** | Croisement de dimensions (ex. commandes par année et par mois) | Hiérarchies multiples, affichage en lignes/colonnes, éléments graphiques intégrables | Lisible seulement si le volume de données est limité |
| **Treemap** | Comparaison de volumes par catégorie (ex. produit le plus vendu) | Facile à lire | Illisible avec trop de catégories ou noms longs ; pas de lecture dans le temps |
| **KPI / Scorecard** | Mettre en avant un indicateur clé (ex. nombre de commandes depuis l'ouverture) | Fort effet de mise en avant | Aucune possibilité d'analyse en l'état seul |
| **Geomap** | Répartition géographique (ex. commandes par ville) | Très lisible visuellement, bon pour une étendue de valeurs | Prend beaucoup de place à l'écran, mal centré si mal paramétré |

### Focus — les 3 types de scorecards
1. **Basique** : une valeur unique agrégée (ex. somme du total price)
2. **Indicateur de tendance** : nécessite un **axe de tendance** (ex. le mois) et une **cible calculée en DAX** (comparaison à une valeur n-1 ou un objectif) pour afficher une variance positive/négative — sans cible correctement calculée, le pourcentage affiché n'a pas de sens
3. **Bandeau multi-KPI** : plusieurs scorecards alignées côte à côte pour une vue d'ensemble cohérente

### Focus — les cartes (Geomap)
- Deux types disponibles : **Choropleth** et **ArcGIS** (un troisième type, ArcGIS pour Power BI, existait avant et a depuis été retiré)
- Deux façons de localiser : noms/adresses (résolus automatiquement via Bing) ou latitude/longitude directement
- ⚠️ Les visuels de carte doivent être **activés manuellement** : *Fichier > Options et paramètres > Options > Sécurité*, cocher ArcGIS et cartes remplies, puis redémarrer l'application

### Réflexe à chaque métrique posée
📌 Avant toute chose, se demander : **quelle fonction d'agrégation ?** (Somme par défaut, mais Moyenne / Count / Count distinct / écart-type selon le cas) — erreur fréquente relevée par le formateur : poser une métrique sans vérifier ni modifier son agrégation.

---

## 🖌️ Formatage

- Panneau **Mettre en forme ce visuel**, deux blocs :
  - **Général** : titre, sous-titre, fond
  - **Objet visuel** : libellés, axes, étiquettes de données, points, couleurs de ligne...
- **Barre de recherche** dans le panneau de formatage pour retrouver rapidement une option précise plutôt que de fouiller les menus
- **Mise en forme conditionnelle** (barres de données, jeux de couleurs, icônes) disponible sur tables et matrices, dans *Objet visuel > Élément de cellule*
- **Thèmes** personnalisables et réutilisables, pour respecter une charte graphique d'entreprise
- Aligner/distribuer les visuels et reproduire la mise en forme entre graphiques via le menu *Format*

---

## 🖱️ Interactivité

- **Grouping, similarité et proximité** des filtres et visuels comptent dans la lisibilité — penser le dashboard comme un site web navigué : masquer certaines pages, utiliser les bookmarks pour une navigation rapide
- **Slicers** : équivalent visuel et manipulable par l'utilisateur des filtres — préférables aux filtres du panneau, paramétrés en amont par le développeur et pas nécessairement visibles pour l'utilisateur final. Plusieurs formats disponibles : liste à cocher, menu déroulant, vignettes, curseur de plage
- **Synchronisation des slicers entre pages** (*Affichage > Synchroniser les segments*) : un slicer peut être visible sur certaines pages et actif (synchronisé) sur d'autres, ce qui évite de le dupliquer page par page
- **Modifier les interactions** (*Format > Modifier les interactions*) : par défaut, tous les graphiques d'une même page sont liés — cette option permet de désactiver le cross-filtering entre un slicer/graphique précis et un autre, par exemple pour garder un KPI global fixe pendant qu'un tableau se filtre dynamiquement (même logique que le cross-filtering déjà vu en Looker, [#20](20-looker-studio-2.md))
- **Tooltips** : disponibles sur presque tous les graphiques, affichent des valeurs secondaires au survol sans surcharger le visuel de base
- **Drill-down** : automatique sur une hiérarchie de dates (Année/Trimestre/Mois/Jour) si la colonne est bien typée en date, ou sur une hiérarchie personnalisée créée à la demande (clic droit sur un champ dans le panneau Données → *Create hierarchy*, ex. Catégorie/Sous-catégorie, Région/Pays/Ville)
- Veiller à ce que les **visuels restent performants** — trop de visuels lourds sur une page ralentit autant l'expérience qu'un excès de transformations Power Query

---

## 🧭 Fonctionnalités de navigation

| Fonctionnalité | Usage |
|---|---|
| **Bookmarks (signets)** | Figent un état filtré du dashboard (comme un "screenshot" des filtres/slicers/tri actifs) — utile pour préparer des vues différenciées par profil utilisateur |
| **Boutons** | Actions prédéfinies (flèche précédente/suivante, reset des segments, retour, appliquer/effacer tous les segments...) ou personnalisées |
| **Drillthrough** | *Mentionné en session, approfondi lors d'une prochaine journée du module* |
| **Page Navigation** | Navigation entre pages façon site web |
| **Focus Mode** | Affiche un visuel unique en plein écran pour une meilleure lisibilité — combinable avec la **présentation plein écran** via le Power BI Service |

💡 Cas d'usage concret travaillé en session : créer un bookmark "Oxford" (slicer figé sur Oxford) et un bookmark "Londres", chacun associé à un bouton — pour envoyer à chaque commercial une vue pré-filtrée sur sa zone sans lui laisser la possibilité de changer de filtre. Alternative écartée ici : restreindre l'accès par adresse e-mail, fonctionnalité réservée aux licences payantes.

📌 Les **images et formes** peuvent recevoir les mêmes actions que les boutons (navigation vers une page, lien externe, signet...) — de quoi construire une expérience de dashboard proche d'un site web.

⚠️ Limite de la licence gratuite : **pas de collaboration simultanée** sur un même fichier `.pbix`. Contournement en formation : travailler à deux sur le même ordinateur, ou s'échanger le fichier et fusionner le travail à la main — la licence Pro est la seule vraie réponse à cette limite.

---

## 🔍 Session de critique de dashboards (mauvaises pratiques observées)

Même exercice pédagogique que celui déjà vu en Looker Studio ([#21](21-looker-studio-3-data-storytelling.md)) — analyse collective de dashboards réels pour repérer les erreurs.

### Graphiques
- **Donut avec trop de dimensions** : illisible, une valeur écrase toutes les autres — à réserver à un nombre de catégories réduit
- **Cartes mal dimensionnées** : prennent trop de place à l'écran par rapport à l'information réellement apportée
- **Bar chart préféré au donut** dès qu'il faut comparer plus de quelques catégories entre elles
- **Waterfall chart** : utilisé en finance pour visualiser des variances par rapport à un plan (ex. budget) — valeurs négatives en rouge, positives en vert ; penser à ajuster l'échelle (ne pas nécessairement partir de zéro) pour mieux visualiser une variance qui reste faible en proportion
- **Table sans mise en forme conditionnelle** : n'apporte aucune information exploitable en l'état

### Axes et lisibilité
- Étiquettes à 45° à proscrire — préférer les barres horizontales pour les catégories/produits/pays, verticales pour les temporalités
- **Piège du drill-down / de l'échelle** : afficher une donnée au niveau jour sur une temporalité de plusieurs années génère un graphique plat et illisible — toujours vérifier le niveau de granularité affiché par défaut

### Couleurs et légendes
- Deux catégories différentes partageant la même couleur = interdit, l'œil ne peut plus les distinguer
- Légende absente ou tronquée = information perdue pour l'utilisateur
- Convention à respecter : valeurs négatives en rouge, positives en vert

### KPIs
- **Toujours en haut à gauche**, en bandeau horizontal — jamais au centre
- **Devise systématique** pour tout ce qui touche aux ventes/profits
- **Toujours une dimension de comparaison** (n-1, mois précédent...) : un chiffre seul ne dit pas s'il est bon ou mauvais — même principe que "un scorecard seul ne veut rien dire" déjà noté en [#21](21-looker-studio-3-data-storytelling.md)

### Slicers
- Placement conventionnel : **à gauche ou en bandeau en haut**, jamais à droite ni en bas
- Un mauvais filtre de temporalité peut fausser silencieusement tout un graphique

### Qualité des données et métriques
- Une valeur "cumulative" doit être strictement croissante — une courbe plate malgré un intitulé "cumulatif" trahit une erreur d'agrégation ou de champ calculé
- Un graphique plat est presque toujours un problème de filtre de temporalité ou de métrique mal choisie, rarement un vrai signal métier

---

## 🎯 Points clés pour les entretiens

- Savoir expliquer le pipeline Power BI (**Sources → Power Query → Star Schema → DAX → Visualisation**) et le rôle de chaque brique — bonne réponse structurée pour "comment fonctionne un outil de BI ?"
- Argumenter la différence **Merge (JOIN) vs Append (UNION)** avec un exemple concret de piège (nommage de colonnes, ordre d'exécution des étapes) — montre une compréhension du *pourquoi*, pas seulement du *comment cliquer*
- Justifier pourquoi les transformations lourdes doivent se faire **en amont dans le Data Warehouse plutôt que dans Power Query** — bon exemple de raisonnement architecture/performance
- Savoir citer la règle des KPIs (haut à gauche, devise, comparaison temporelle) et la relier au Z-pattern — connecte directement dataviz ([#21](21-looker-studio-3-data-storytelling.md)) et outil (#22)
- Expliquer la nuance entre une relation dans le Data Model et une jointure classique (« une relation ne crée pas de nouvelle table, elle indique juste à l'outil comment les tables sont liées ») — distingue un candidat qui a juste cliqué d'un candidat qui comprend le moteur sous-jacent

---

## 🔗 Liens avec d'autres notions

- Le triptyque **axe X / axe Y / légende** de Power BI recouvre le même concept que **Dimension / Metric** vu en Looker ([#19](19-looker-studio-1.md)) — vocabulaire différent, logique identique
- Le réflexe "vérifier la fonction d'agrégation à chaque métrique posée" est le pendant Power BI du principe **aggregate before divide** déjà noté en BigQuery/dbt/Looker — une somme par défaut mal vérifiée peut fausser un calcul
- **Merge / Append** reprennent exactement `JOIN` / `UNION` vus en SQL — la logique de clé de jointure et le risque de duplication de lignes sont transférables tels quels
- La **colonne conditionnelle** de Power Query est le même outil que le `CASE WHEN` SQL et le champ calculé conditionnel de Looker ([#20](20-looker-studio-2.md)) — troisième environnement différent, même raisonnement de conditions ordonnées
- Les bonnes pratiques de dashboard design (Z-pattern, Data Ink Ratio, règle des 30 secondes, "un scorecard seul ne veut rien dire") sont une application directe du chapitre théorique Data Storytelling ([#21](21-looker-studio-3-data-storytelling.md)) — Power BI ne change pas les principes, seulement l'outil pour les appliquer
- La session de critique de dashboards suit le même format pédagogique que celle déjà vue en Looker Studio (#21) : les erreurs relevées (couleurs dupliquées, absence de légende, KPI mal placé) sont **indépendantes de l'outil** — un bon réflexe dataviz transcende Looker et Power BI

---

## ✅ Actions post-session

- [ ] Activer les visuels de carte : *Fichier > Options et paramètres > Options > Sécurité* → cocher ArcGIS et cartes remplies, puis redémarrer l'application
- [ ] Réaliser l'exercice du vendredi : mettre les valeurs en euros dans Power BI (onglet Affichage de table)
- [ ] Travail en binôme : partager le fichier `.pbix` entre coéquipiers (pas de collaboration simultanée en licence gratuite)
- [ ] Soigner l'alignement et la distribution des graphiques dès le prochain projet — critère explicitement annoncé comme exigé
- [ ] Pratiquer les exercices Power BI de l'après-midi

---

## ❓ Questions / Points flous

- [ ]
- [ ]

---

*Chapitre 1/3 sur Power BI — DAX, Star Schema approfondi (cardinalités many-to-many) et Drillthrough feront l'objet de chapitres séparés.*
