# DAX — Cheat Sheet

Antisèche DAX pour Power BI — fonctions courantes et syntaxes réelles, à consulter pendant l'écriture de mesures/colonnes calculées. Complète les chapitres `22-power-bi-1.md` et `23-power-bi-2.md` du wagon2321/ pour le contexte et les explications pédagogiques ; ce fichier est le lexique brut, sans narration.

---

## 🧭 Colonne calculée vs Mesure — rappel express

| | Colonne calculée | Mesure |
|---|---|---|
| Syntaxe | `Table[Colonne] = ...` | `[Mesure] = ...` |
| Calcul | Ligne par ligne, au chargement (statique) | Dynamique, à l'affichage |
| Utilisable en slicer/filtre | ✅ | ❌ |
| Coût | Mémoire (alourdit la table) | CPU (recalcul à chaque interaction) |
| Bon pour | Segmentation, filtre, clé | Ratios, %, agrégations |

---

## 🔢 Types & opérateurs

**Types principaux** : `String` · `Whole number` · `Decimal number` · `Boolean` · `Date/Time` · `Currency`

| Catégorie | Opérateurs |
|---|---|
| Arithmétiques | `+` `-` `*` `/` `^` |
| Comparaison | `=` `==` `>` `>=` `<` `<=` `<>` |
| Logiques | `&&` (AND) `\|\|` (OR) `IN` |
| Concaténation texte | `&` |

---

## Σ Agrégation simple (une seule colonne)

| Fonction | Syntaxe | Effet |
|---|---|---|
| `SUM` | `SUM(Table[Col])` | Somme |
| `AVERAGE` | `AVERAGE(Table[Col])` | Moyenne |
| `MIN` / `MAX` | `MIN(Table[Col])` | Min / Max |
| `COUNT` | `COUNT(Table[Col])` | Compte les lignes non vides |
| `COUNTA` | `COUNTA(Table[Col])` | Compte les lignes non vides, texte inclus |
| `COUNTBLANK` | `COUNTBLANK(Table[Col])` | Compte les lignes vides |
| `COUNTROWS` | `COUNTROWS(Table)` | Compte les lignes d'une table (pas d'argument colonne) |
| `DISTINCTCOUNT` | `DISTINCTCOUNT(Table[Col])` | Compte les valeurs distinctes |

⚠️ N'agrègent qu'**une seule colonne**. Impossible d'écrire `SUM(Orders[Prix] * Orders[Quantité])` → utiliser une fonction `X`.

---

## 🔁 Itérateurs "X" (agrégation multi-colonnes)

Pattern : `NOMX( <Table>, <Expression évaluée ligne par ligne> )`

| Fonction | Exemple |
|---|---|
| `SUMX` | `SUMX(Orders, Orders[Quantité] * Orders[Prix])` |
| `AVERAGEX` | `AVERAGEX(Orders, Orders[Quantité] * Orders[Prix])` |
| `MINX` / `MAXX` | `MAXX(Orders, Orders[Quantité] * Orders[Prix])` |
| `COUNTX` | `COUNTX(Orders, Orders[Prix])` |
| `RANKX` | `RANKX(ALL(Orders[Produit]), [Sales])` — classe une valeur au sein d'un ensemble |

💡 Réflexe : dès qu'un calcul combine plusieurs colonnes dans une agrégation → fonction en `X`.

---

## ➗ Division sécurisée

```
DIVIDE(<Numérateur>, <Dénominateur>, [<ValeurSiErreur>])

Marge % = DIVIDE([Marge], [Sales], 0)
```
Toujours préférer à `/` — protège nativement d'une division par zéro (équivalent DAX de `SAFE_DIVIDE` en BigQuery). Le 3ᵉ argument (optionnel) définit la valeur de repli, `BLANK()` par défaut.

---

## 🔀 Fonctions logiques

| Fonction | Syntaxe |
|---|---|
| `IF` | `IF(<Test>, <SiVrai>, <SiFaux>)` |
| `SWITCH` | `SWITCH(<Expression>, <Valeur1>, <Résultat1>, <Valeur2>, <Résultat2>, ..., <ParDéfaut>)` |
| `AND` / `OR` | `IF(AND(A>5, B<10), "OK", "KO")` — ou directement `&&` / `\|\|` |
| `IN` | `IF(Orders[Ville] IN {"London", "Oxford"}, "UK", "Autre")` |

```
Catégorie =
SWITCH(
    TRUE(),
    Orders[Quantité] > 10, "Extra Big Meal",
    Orders[Quantité] > 4,  "Big Meal",
    Orders[Quantité] > 2,  "Medium Meal",
    "Small Meal"
)
```
💡 `SWITCH(TRUE(), ...)` est l'équivalent DAX d'un `CASE WHEN` en cascade — souvent plus lisible qu'un empilement de `IF` imbriqués.

---

## 🗂️ Fonctions Table (retournent une table)

| Fonction | Syntaxe | Effet |
|---|---|---|
| `FILTER` | `FILTER(<Table>, <Condition>)` | Réduit une table aux lignes où la condition est vraie |
| `ALL` | `ALL(<Table ou Colonne>)` | Supprime tous les filtres (sur la table ou juste la colonne donnée) |
| `ALLEXCEPT` | `ALLEXCEPT(Table, Table[ColonneÀGarder])` | Supprime tous les filtres sauf ceux listés |
| `ALLSELECTED` | `ALLSELECTED(Table)` | Retire les filtres internes au visuel mais garde ceux venant de l'extérieur (slicers de page) |
| `VALUES` | `VALUES(Table[Col])` | Retourne les valeurs distinctes visibles dans le contexte de filtre actuel |
| `DISTINCT` | `DISTINCT(Table[Col])` | Retourne les valeurs distinctes, indépendamment du contexte de filtre |
| `RELATED` | `RELATED(AutreTable[Col])` | Va chercher une valeur dans une autre table via une relation **existante** |
| `RELATEDTABLE` | `RELATEDTABLE(AutreTable)` | Retourne toutes les lignes liées d'une autre table (sens 1-vers-plusieurs) |

```
Margin =
SUMX(
    Orders,
    Orders[Total Price] - Orders[Quantity] * RELATED(PurchasePrice[Purchase Price])
)
```

```
NumOfProducts = COUNTROWS(DISTINCT(Orders[Item Name]))
```

📌 `RELATED` exige une relation déjà construite dans le Data Model — sinon erreur ou résultat vide.

---

## 🎯 CALCULATE & contexte de filtre

```
CALCULATE(<Expression>, <Filtre1>, <Filtre2>, ...)
```
C'est **la** fonction pivot du DAX : elle réévalue une expression dans un contexte de filtre modifié.

| Pattern | Effet |
|---|---|
| `CALCULATE([Sales], ALL(Orders))` | Supprime tous les filtres sur la table |
| `CALCULATE([Sales], ALL(Orders[Item Name]))` | Supprime uniquement le filtre sur cette colonne |
| `CALCULATE([Sales], Orders[Localization] = "London")` | **Remplace** le filtre existant sur Localization |
| `CALCULATE([Sales], FILTER(Orders, Orders[Localization] = "London"))` | **Ajoute** un filtre Londres en plus des filtres déjà actifs |

```
-- Contribution % correctement calculée (total par item, pas par moyenne de %)
Product Sales Contribution =
DIVIDE(
    [Sales],
    CALCULATE([Sales], ALL(Orders[Item Name])),
    BLANK()
)
```

⚠️ `CALCULATE([X], Col = "valeur")` remplace silencieusement un slicer sur `Col` — l'utilisateur peut changer le filtre sans voir le chiffre bouger. Utiliser `FILTER(...)` explicitement si l'intention est d'**ajouter** une condition plutôt que de l'imposer.

---

## 📅 Date & Time — extraction

| Fonction | Exemple |
|---|---|
| `YEAR` / `MONTH` / `DAY` | `YEAR(Orders[Order Date])` |
| `HOUR` / `MINUTE` / `SECOND` | `HOUR(Orders[Order Date])` |
| `DATE` | `DATE(2026, 8, 5)` |
| `DATEVALUE` | `DATEVALUE("05/08/2026")` — convertit un texte en date |
| `TODAY` / `NOW` | `TODAY()` (date seule) / `NOW()` (date + heure) |
| `WEEKDAY` | `WEEKDAY(Orders[Order Date], 2)` — jour de semaine (2 = lundi=1) |
| `EOMONTH` | `EOMONTH(Orders[Order Date], 0)` — dernier jour du mois |
| `DATEDIFF` | `DATEDIFF(Date1, Date2, DAY)` — nombre d'unités entre deux dates |

---

## ⏱️ Time Intelligence — calculs comparatifs

⚠️ Prérequis : la table Date doit être **Mark as Date Table**, avec une colonne continue sans trou — sinon résultats faux ou vides.

💡 Toujours passer `.[Date]` (le point + "Date") en argument temporalité plutôt qu'un niveau fixe (année, mois) : `.[Date]` embarque toute la hiérarchie et s'adapte au niveau affiché dans le visuel.

| Fonction | Syntaxe |
|---|---|
| `TOTALYTD` | `TOTALYTD([Sales], Orders[Order Date].[Date])` |
| `TOTALMTD` / `TOTALQTD` | `TOTALMTD([Sales], Orders[Order Date].[Date])` |
| `SAMEPERIODLASTYEAR` | `CALCULATE([Sales], SAMEPERIODLASTYEAR(Orders[Order Date].[Date]))` |
| `PREVIOUSMONTH` | `CALCULATE([Sales], PREVIOUSMONTH(Orders[Order Date].[Date]))` |
| `PREVIOUSYEAR` | `CALCULATE([Sales], PREVIOUSYEAR(Orders[Order Date].[Date]))` |
| `DATEADD` | `CALCULATE([Sales], DATEADD(Orders[Order Date].[Date], -1, YEAR))` — plus flexible que SAMEPERIODLASTYEAR (mois/trimestre/année au choix) |
| `PARALLELPERIOD` | `CALCULATE([Sales], PARALLELPERIOD(Orders[Order Date].[Date], -1, MONTH))` |
| `DATESYTD` | Utilisé en interne par `TOTALYTD` — `CALCULATE([Sales], DATESYTD(Orders[Order Date].[Date]))` fait la même chose |
| `FIRSTDATE` / `LASTDATE` | `LASTDATE(Orders[Order Date].[Date])` — première/dernière date du contexte courant |

```
-- N-1 et croissance YoY, pattern complet
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

---

## 🔤 Fonctions texte

| Fonction | Exemple |
|---|---|
| `CONCATENATE` / `&` | `Orders[Prénom] & " " & Orders[Nom]` |
| `CONCATENATEX` | `CONCATENATEX(Orders, Orders[Item Name], ", ")` — concatène les valeurs d'une table |
| `LEFT` / `RIGHT` | `LEFT(Orders[Code], 3)` |
| `MID` | `MID(Orders[Code], 2, 4)` |
| `LEN` | `LEN(Orders[Item Name])` |
| `UPPER` / `LOWER` | `UPPER(Orders[Item Name])` |
| `TRIM` | `TRIM(Orders[Item Name])` |
| `SUBSTITUTE` | `SUBSTITUTE(Orders[Item Name], ".", ",")` |
| `FORMAT` | `FORMAT(Orders[Order Date], "DD/MM/YYYY")` |

---

## 🧮 VAR / RETURN — calculs intermédiaires

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
Évite de créer une mesure séparée pour un résultat intermédiaire qui ne sera pas réutilisé ailleurs. Plusieurs `VAR` possibles avant un seul `RETURN` final.

---

## 🔎 Fonctions utiles pour diagnostiquer un contexte

| Fonction | Effet |
|---|---|
| `HASONEVALUE(Table[Col])` | `TRUE` si le contexte de filtre ne contient qu'une seule valeur pour cette colonne — utile avant d'afficher une valeur qui n'a de sens qu'au singulier |
| `ISFILTERED(Table[Col])` | `TRUE` si la colonne est activement filtrée |
| `SELECTEDVALUE(Table[Col], <ValeurParDéfaut>)` | Retourne la valeur sélectionnée si une seule, sinon la valeur par défaut — souvent préférable à `VALUES` + `IF(HASONEVALUE...)` |
| `LOOKUPVALUE(TableCible[ColRetour], TableCible[ColClé], ValeurClé)` | Récupère une valeur dans une autre table sans relation existante (contrairement à `RELATED`) |
| `TOPN(<N>, <Table>, <Expression>, [ordre])` | Retourne les N premières lignes selon un critère de tri |

---

## ⚠️ Pièges classiques

- `SUM` sur une multiplication de colonnes → ne fonctionne pas, il faut `SUMX`
- `/` sans protection → erreur si le dénominateur est 0, préférer `DIVIDE`
- `RELATED` sans relation construite dans le Data Model → erreur ou vide ; utiliser `LOOKUPVALUE` si vraiment aucune relation ne peut exister
- Colonne calculée utilisée là où une mesure était nécessaire (ex. un ratio) → résultat calculé ligne par ligne, pas au bon niveau d'agrégation
- Mesure qu'on tente de glisser dans un slicer → impossible, une mesure n'a pas d'existence physique dans une table
- `CALCULATE(..., Col = "valeur")` qui écrase silencieusement un slicer → préférer `FILTER(...)` si l'intention est d'ajouter une condition, pas de la remplacer
- `SAMEPERIODLASTYEAR` / autres Time Intelligence qui renvoient du vide → vérifier que la table Date est bien *Mark as Date Table*, colonne continue sans trou

---

*Pour la doc complète de chaque fonction (syntaxe exhaustive + exemples) : DAX Guide (documentation non officielle, citée en cours #23).*
