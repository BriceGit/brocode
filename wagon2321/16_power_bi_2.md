# 📝 #23 — Power BI (2/3) : DAX, Star Schema & Time Intelligence

**Date** : 05 août 2026
**Thème** : DAX (types, opérateurs, fonctions), Star Schema (tables de faits/dimensions), colonne calculée vs mesure, fonctions table (FILTER/ALL/DISTINCT/RELATED), Filter Context & CALCULATE, Time Intelligence, bonnes pratiques d'écriture DAX
**Compréhension (1→5)** : ⭐⭐⭐⭐

---

## 🎯 Contexte de la session

- Deuxième jour du module Power BI (sur trois) — suite directe du [#22](22-power-bi-1.md), centrée cette fois sur le **DAX** et le **Star Schema**
- Session technique et dense, présentée par le formateur comme la vraie porte d'entrée vers un usage avancé de Power BI — le Star Schema fait explicitement partie du programme du certificat **PL-300**
- Beaucoup de contenu transférable depuis SQL et Looker Studio : le DAX est décrit comme "à mi-chemin entre les formules Excel et le SQL"

---

## 🧮 Qu'est-ce que le DAX ?

- **DAX (Data Analysis eXpressions)** : langage de programmation utilisé par Power Pivot (Excel), Power BI et SSAS Tabular
- Ressemble aux formules Excel en apparence, mais reste plus complexe en pratique dès qu'on sort des cas basiques
- Permet de créer des calculs personnalisés, d'agréger des valeurs, de faire de l'analyse temporelle, et de créer des **colonnes calculées** et des **mesures** dynamiques
- Ressource de référence citée en session : le *DAX Guide* (documentation non officielle mais très complète, syntaxe + exemples pour chaque fonction) — même réflexe qu'avec SQL ou Looker : apprendre à lire la doc plutôt que tout mémoriser

---

## ⭐ Star Schema

Le Star Schema modélise les relations entre tables — équivalent Power BI de l'ERD déjà vu en SQL (#5), mais avec une contrainte de circulation de la donnée plus stricte.

### Deux catégories de tables

| | Table de dimension | Table de faits |
|---|---|---|
| **Rôle** | Stocke les entités métier | Stocke les événements/observations |
| **Structure** | Colonne clé + colonnes descriptives (texte), pour filtrer/grouper | Colonnes clés de dimension + colonnes numériques agrégeables |
| **Volume** | Généralement peu de lignes | Peut contenir énormément de lignes |
| **Rôle en requête** | Filtrer et grouper | Résumer/agréger |
| **Exemples** | Clients, localisations, produits, dates | Commandes, lignes de commande, mouvements de stock |

### Règles de construction
- Les relations vont **toujours** de la dimension vers la table de faits (cardinalité *one-to-many*), jamais l'inverse — même logique de clé primaire/étrangère qu'un ERD SQL, mais avec un sens de circulation imposé
- Le Star Schema **ne se construit pas nativement** : il faut créer les tables de faits/dimensions manuellement (via *Entrer des données*, ou via DAX avec `DISTINCT` pour générer une table de correspondance)
- Il existe aussi le **Snowflake Schema** : une dimension peut elle-même être connectée à une autre dimension (ex. Produit connecté à Stock, qui n'est jamais connecté directement aux Ventes) — utile quand deux tables de faits n'ont pas de clé de jointure directe et qu'il faut un "chemin de traverse" pour les relier

### Pourquoi préférer le Star Schema à un modèle plus libre
- **Facile à comprendre** : dimensions pour filtrer/grouper, faits pour résumer — pas d'ambiguïté de relations complexes
- **Rapide** : les moteurs Power BI sont optimisés pour ce schéma précis
- **Modélisation propre** : nombres dans la table de faits, texte dans les dimensions
- **DAX plus simple à écrire** : moins de risques d'introduire une erreur de calcul
- 💡 Présenté comme **l'option par défaut à privilégier**, sauf cas particulier justifiant un Snowflake

⚠️ Un Star Schema mal construit fausse silencieusement les calculs : ce n'est pas toujours la formule DAX qui est en cause, c'est parfois juste le type de relation entre les tables qui empêche le calcul de circuler correctement.

---

## 🔤 DAX — types, opérateurs, fonctions

### Types de données principales
String, Whole number, Decimal number, Boolean, Date/Time, Currency — mêmes familles que celles déjà vues en SQL/Power Query.

### Opérateurs

| Arithmétiques | Comparaison | Logiques | Concaténation texte |
|---|---|---|---|
| `+` `-` `*` `/` `^` | `=` `==` `>` `>=` `<>` | `&&` `\|\|` `IN` | `&` |

⚠️ Préférer la fonction `DIVIDE()` au simple `/` — même réflexe que `SAFE_DIVIDE` en BigQuery : ça protège d'une division par zéro sans faire planter le calcul.

### Panorama des fonctions DAX (non exhaustif)

| Type | Exemple | Description |
|---|---|---|
| Text | `CONCATENATE(<TEXT1>, <TEXT2>)` | Joint deux chaînes de texte |
| Information | `ISNUMBER(<VALUE>)` | Teste si une valeur est un nombre |
| Logical | `IF(<Test>, <SiVrai>, <SiFaux>)` | Condition classique |
| Math | `ROUND(<Number>, <Digits>)` | Arrondit à N décimales |
| Stats | `STDEV.P(<ColumnName>)` | Écart-type sur une population |
| Filter | `FILTER(<table>, <FilterExpression>)` | Retourne une table filtrée |
| Date/Time | `DATEDIFF(<Date1>, <Date2>, <Interval>)` | Nombre d'unités entre deux dates |
| Aggregation | `COUNT(<ColumnName>)` | Compte les lignes non vides |
| Financial | `NOMINAL(<Effect_rate>, <Nperiods>)` | Taux d'intérêt nominal annuel |

---

## 📌 Colonne calculée vs Mesure

C'est la distinction centrale de la session — savoir laquelle utiliser quand est probablement le point le plus testé en entretien sur Power BI.

| | Colonne calculée | Mesure |
|---|---|---|
| **Dynamique/Statique** | Statique | Dynamique |
| **Convention de nommage** | `Table[Colonne]` | `[Mesure]` |
| **Appartient à une table** | Oui | Non |
| **Usage** | Slicer, filtre | Calculer un %, un ratio, une agrégation |
| **Ressource consommée** | Mémoire (alourdit la table au chargement) | CPU (recalculée à l'affichage) |

- **Colonne calculée** : formule évaluée **ligne par ligne**, calculée pendant le chargement des données, valeur **figée** — elle ne réagit pas aux filtres/interactions du dashboard
  - Ex. `Total Price = Orders[Quantity] * Orders[Product Price]`
- **Mesure** : formule retournant un **résultat unique/agrégé**, évaluée **dynamiquement** dans le contexte du visuel où elle est utilisée — elle réagit aux filtres, groupements et interactions
  - Ex. `Sales = SUM(Orders[Total Price])`
  - 💡 Une mesure n'existe **physiquement nulle part** : impossible de la glisser-déposer depuis le panneau Données comme une colonne classique, elle n'apparaît que dans un visuel qui l'utilise

### Comment trancher
- Si l'information doit servir de **filtre/segment** → colonne calculée (une mesure ne peut pas être utilisée dans un slicer)
- Si c'est un **ratio ou un calcul agrégé** → mesure (un ratio ne se calcule jamais ligne par ligne)
- Si la valeur est **fréquemment réutilisée** ailleurs → envisager de la calculer directement en amont, dans le Data Warehouse
- 📌 Rappel du réflexe déjà noté en Power Query (#22) : une colonne calculée en Power BI alourdit le dataset comme une transformation Power Query alourdit le temps de chargement — deux façons différentes de payer un "coût de performance" pour un même type de confort

### Bonne pratique — Measure Table
Créer une table dédiée (via *Entrer des données*) pour centraliser **toutes** les mesures, peu importe leur table de rattachement d'origine. Les mesures peuvent être imbriquées les unes dans les autres ("poupée russe") pour construire des calculs de plus en plus précis sans réécrire la formule complète à chaque fois.

---

## Σ Fonctions d'agrégation & itérateurs

### Fonctions d'agrégation classiques
`SUM`, `AVERAGE`, `MIN`, `MAX`, `COUNT` — ⚠️ n'agrègent **qu'une seule colonne** à la fois.

```
Sales = SUM(Orders[Total Price])                             ✅
Sales = SUM(Orders[Product Price] * Orders[Quantity])         ❌ impossible
```

### Fonctions "X" (itérateurs)
`SUMX`, `AVERAGEX`, `MINX`, `MAXX`, `COUNTX` — permettent de calculer une expression qui combine **plusieurs colonnes**, en itérant ligne par ligne.

```
Sales = SUMX(Orders, Orders[Product Price] * Orders[Quantity])   ✅
```

- Deux paramètres : la **table** à parcourir, puis la **formule** à exécuter sur chaque ligne
- Fonctionnement : calcule d'abord `Product Price × Quantity` pour *chaque ligne* (comme une colonne virtuelle en mémoire), puis **somme** l'ensemble des résultats — mêmes maths qu'une colonne Excel `=A2*B2` suivie d'un `SUM()` sur toute la colonne
- 📌 Réflexe à avoir : dès qu'un calcul combine plusieurs colonnes dans une agrégation, il faut une fonction en `X`

---

## 🗂️ Fonctions Table (retournent une nouvelle table)

`FILTER`, `ALL`, `VALUES`, `DISTINCT` — permettent de filtrer, joindre, résumer et transformer les données ; leur résultat est généralement réutilisé à l'intérieur d'une autre fonction (souvent un itérateur X).

### FILTER
`FILTER(<Table>, <FilterOperation>)` — retourne une table réduite aux lignes où la condition est vraie ; s'utilise typiquement imbriquée dans un itérateur X.
```
Sales Expensive Products =
SUMX(
    FILTER(Orders, Orders[Product Price] > 5),
    Orders[Total Price]
)
```

### ALL
`ALL(<Table>)` — supprime tout filtre. Utile pour répéter une valeur totale sur chaque ligne d'un tableau (base de calcul pour des proportions).
```
All Sales = SUMX(ALL(Orders), Orders[Total Price])
```
→ dans un tableau ventilé par Localisation ou par type de repas, `All Sales` affiche **le même total** sur chaque ligne, quel que soit le groupement.

### DISTINCT
`DISTINCT(<ColumnOrTable>)` — retourne une table à une colonne contenant les valeurs uniques (ou une combinaison unique de plusieurs colonnes).
```
NumOfProducts = COUNTROWS(DISTINCT(Orders[Item Name]))
```
- 💡 Utile pour un diagnostic rapide : 253 produits distincts au global, mais 249 à Londres et 251 à Oxford → révèle qu'il existe des produits vendus dans une seule des deux villes
- Peut aussi servir à créer une **table calculée** (une table de correspondance) pour bâtir une dimension quand il n'existe pas de clé de jointure naturelle :
```
Unique Products = DISTINCT(Orders[Item Name])
```

### RELATED
`RELATED(<ColumnName>)` — retourne une valeur d'une autre table **via une relation déjà existante** dans le Star Schema. Sans relation construite au préalable, la formule ne fonctionne pas.
```
Margin =
SUMX(
    Orders,
    Orders[Total Price] - Orders[Quantity] * PurchasePrice[Purchase Price]
)                                                                    ❌

Margin =
SUMX(
    Orders,
    Orders[Total Price] - Orders[Quantity] * RELATED(PurchasePrice[Purchase Price])
)                                                                    ✅
```
📌 `RELATED` est le pendant DAX du `Merge` vu en Power Query (#22) : `Merge` rapatrie physiquement une colonne dans une nouvelle table, `RELATED` va chercher la valeur à la volée via la relation du Data Model, sans dupliquer la donnée.

---

## 🎯 Filter Context & CALCULATE

### Filter Context
L'ensemble des filtres/slicers actifs qui s'appliquent à la donnée à un instant donné — chaque cellule d'un visuel Power BI est déjà, naturellement, filtrée à plusieurs niveaux (slicer, groupement en ligne/colonne, position dans le tableau). Une expression DAX prend en compte ce contexte pour déterminer quelles lignes sont incluses ou exclues du calcul.

> Exemple : une valeur de 1 493,45 € dans une cellule "Aloo Gobi / 2020" avec un slicer sur Londres est en réalité le résultat de **trois filtres empilés naturellement** : `Item Name = Aloo Gobi`, `Order Date year = 2020`, `Localization = London`.

### CALCULATE — la fonction centrale du DAX
`CALCULATE(<Expression>, <Filter>...)` — évalue une expression (généralement une mesure) dans un contexte **modifié par des filtres**, indépendamment du contexte filtre naturel de la page/du visuel.

#### CALCULATE + ALL : deux comportements distincts
| Formule | Effet |
|---|---|
| `SUMX(ALL(Orders), Orders[Total Price])` | Supprime **tous** les filtres → même valeur répétée partout, peu importe l'année, le produit ou la localisation |
| `CALCULATE([Sales], ALL(Orders[Item Name]))` | Supprime **uniquement** le filtre sur Item Name → les filtres Année et Localisation restent actifs |

💡 Cas d'usage clé : calculer une **contribution en %** correctement.
```
Product Sales Contribution =
DIVIDE(
    [Sales],
    [All Products Sales],
    BLANK()
)
```
En divisant par une mesure où seul le filtre Item Name est neutralisé (pas Année ni Localisation), chaque total de colonne est **correctement calculé** — et non pas faussé par une moyenne ou une somme des contributions annuelles, piège classique quand on divise par un total mal contextualisé.

#### CALCULATE + FILTER : ajouter un filtre vs remplacer un filtre
Deux syntaxes qui se ressemblent mais se comportent différemment :

| `CALCULATE([Sales], FILTER(Orders[Localization] = "London"))` | `CALCULATE([Sales], Orders[Localization] = "London")` |
|---|---|
| **Ajoute** un filtre Londres **en plus** des filtres déjà actifs | **Remplace** le filtre existant sur Localisation par Londres |
| Si un slicer sélectionne Oxford → résultat **vide** (Oxford ET Londres impossible en même temps) | Si un slicer sélectionne Oxford → résultat **quand même celui de Londres** (le slicer est ignoré sur cette colonne) |

⚠️ Piège d'expérience utilisateur à anticiper : la deuxième syntaxe peut dérouter l'utilisateur qui change un slicer sans voir le chiffre bouger, parce que le filtre du slicer est silencieusement écrasé par celui codé en dur dans la mesure.

---

## 📅 Fonctions Date/Time & Time Intelligence

### Fonctions d'extraction
`DATE`, `DATEVALUE`, `YEAR`, `MONTH`, `DAY`, `HOUR`, `MINUTE`, `SECOND`, `TODAY`... — extraient un composant d'une date/heure pour construire des calculs ou des périodes personnalisées.
```
Year = YEAR(Orders[Order Date])
```

### Time Intelligence — calculs comparatifs de période
`TOTALYTD`, `TOTALMTD`, `TOTALQTD`, `PREVIOUSMONTH`, `SAMEPERIODLASTYEAR`, `DATEADD`... — permettent de calculer des cumuls, des N-1, des moyennes glissantes, sans la complexité qu'aurait exigée le même calcul en SQL (sous-requête ou fenêtrage `OVER`/`PARTITION BY`).

```
Sales YTD = TOTALYTD([Sales], Orders[Order Date].[Date])

-- équivalent à :
Sales YTD =
CALCULATE(
    [Sales],
    DATESYTD(Orders[Order Date].[Date])
)
```

```
Sales SPLY =
CALCULATE(
    [Sales],
    SAMEPERIODLASTYEAR(Orders[Order Date].[Date])
)
```

💡 Conseil du formateur : utiliser systématiquement `.[Date]` (le point suivi de "Date") comme référence temporelle plutôt qu'une temporalité précise (année, mois...) — `.[Date]` embarque toute la hiérarchie et s'adapte automatiquement au niveau de granularité affiché dans le graphique, sauf besoin très spécifique d'une temporalité fixe.

### Application concrète travaillée en exercice

| Mesure | Résultat | Répond à |
|---|---|---|
| `Sales Last Year` | Montant (€) | Quel était le total à la même période l'an dernier ? |
| `Sales YOY Growth` | Pourcentage | De combien ai-je progressé vs l'an dernier ? |

```
Sales Last Year =
CALCULATE(
    [Total Sales],
    SAMEPERIODLASTYEAR('Date'[Date])
)

Sales YOY Growth =
DIVIDE(
    [Total Sales] - [Sales Last Year],
    [Sales Last Year]
)
```
`Sales YOY Growth` **réutilise** `Sales Last Year` plutôt que de refaire `SAMEPERIODLASTYEAR` — illustration directe du principe "mesure dans une mesure" pour éviter de dupliquer la logique.

⚠️ **Prérequis technique à vérifier si `SAMEPERIODLASTYEAR` renvoie des résultats faux ou vides** : la table `Date` doit être marquée comme **table de dates** (*Mark as Date Table*) et contenir une colonne continue, sans trou. Sans cela, les fonctions Time Intelligence ne peuvent pas fiabiliser le décalage d'un an.

---

## ⚡ Quick Measures

Panneau guidé (*Nouvelle mesure rapide*) qui génère automatiquement une formule DAX à partir d'un calcul sélectionné dans une liste (moyenne par catégorie, valeur filtrée, écart par rapport à une valeur filtrée...). Sur licence Premium, des suggestions **Copilot** viennent s'ajouter au panneau classique.

💡 "Ne pas réinventer la roue" pour les calculs basiques — mais toujours **comprendre le code généré avant de l'utiliser tel quel**, pour pouvoir le débugger ou l'adapter.

---

## 🧹 Bonnes pratiques d'écriture DAX

- **Indenter le code DAX**, surtout dès qu'une formule imbrique plusieurs fonctions (`SUMX` + `FILTER`, `CALCULATE` + plusieurs filtres...) — la lisibilité se dégrade vite en écriture "sur une seule ligne"
- **Découper les calculs complexes** plutôt que d'écrire une seule formule à rallonge, deux options :
  - Référencer une mesure existante dans une autre mesure (`Sales Year-on-year Growth` réutilise `[Sales SPLY]`)
  - Utiliser `VAR ... RETURN` pour stocker un résultat intermédiaire dans une variable **locale à la mesure**, sans créer de mesure séparée si ce calcul intermédiaire n'a pas vocation à être réutilisé ailleurs

```
Sales Year-on-year Growth =
VAR SalesLastYear =
    CALCULATE(
        [Sales],
        SAMEPERIODLASTYEAR(Orders[Order Date].[Date])
    )
RETURN
    DIVIDE([Sales] - SalesLastYear, [Sales])
```

---

## 🎯 Points clés pour les entretiens

- Savoir trancher **colonne calculée vs mesure** avec un critère concret (slicer → colonne ; ratio → mesure) plutôt qu'une définition abstraite — c'est la question la plus probable sur ce chapitre
- Expliquer ce que fait réellement `CALCULATE` : "il évalue une expression dans un contexte de filtre modifié" — pas une histoire de somme/division, une histoire de **contexte**
- Savoir illustrer la différence entre `ALL` en argument de `CALCULATE` (retire un filtre précis, garde les autres) et `ALL` en argument direct d'un itérateur (retire tous les filtres) — nuance fine mais révélatrice d'une vraie compréhension
- Justifier pourquoi une relation Star Schema mal construite peut fausser un calcul DAX en apparence correct — relie modélisation et fiabilité des chiffres
- Pouvoir donner un exemple concret de N-1/YoY en DAX (`SAMEPERIODLASTYEAR` + `DIVIDE`) et le comparer à la lourdeur de l'équivalent SQL (sous-requête ou fenêtrage)

---

## 🔗 Liens avec d'autres notions

- Le Star Schema reprend directement la logique d'**ERD et de clés primaires/étrangères** vue en SQL (#5), avec une contrainte supplémentaire : le sens de circulation dimension → fait, toujours
- `DIVIDE()` plutôt que `/` reprend exactement le réflexe **`SAFE_DIVIDE`** déjà noté en BigQuery — même famille de prudence contre la division par zéro
- `RELATED` (DAX) est le pendant du `Merge` (Power Query, #22) : deux façons différentes de faire circuler une info entre tables, l'une matérialise une nouvelle colonne, l'autre interroge la relation à la volée
- Le coût de performance colonne calculée (mémoire, au chargement) vs mesure (CPU, à l'affichage) fait écho au même arbitrage déjà noté sur les transformations Power Query : **faire porter le coût le plus tôt possible dans le pipeline** quand c'est réutilisable, sinon garder le calcul dynamique
- `FILTER`, `ALL`, `DISTINCT` sont les pendants DAX de `WHERE`, de la suppression de `GROUP BY`, et de `DISTINCT` déjà vus en SQL (#6) — même vocabulaire logique, syntaxe différente
- Le principe "diviser par un total mal contextualisé fausse un pourcentage" est le même risque que celui déjà noté sur les scorecards Power BI (#22) : un chiffre agrégé sans le bon contexte de filtre raconte une fausse histoire

---


*Chapitre 2/3 sur Power BI — suite du [#22](22-power-bi-1.md). Le troisième volet du module abordera probablement le Drillthrough et des cas pratiques Star Schema plus avancés (many-to-many).*
