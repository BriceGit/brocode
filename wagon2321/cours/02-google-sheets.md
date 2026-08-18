---
title: "Google Sheets — Import, nettoyage, jointures & agrégation"
aliases:
  - "Google Sheets"
  - "VLOOKUP vs XLOOKUP"
  - "IMPORTRANGE"
  - "Tableau croisé dynamique"
  - "FILTER et QUERY"
  - "Les 7 étapes de l'analyse de données"
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 2
date: 2026-07-07
language: "Formules Google Sheets"
database: "n/a — tableur (Google Sheets / Excel)"
topics:
  - "Google Sheets"
  - "Excel"
  - "Data Cleaning"
  - "Lookup Functions"
  - "Pivot Table"
  - "QUERY"
  - "Dates"
  - "Regex"
  - "Data Analysis Workflow"
tags:
  - brocode
  - wagon2321/cours
  - google-sheets
  - tableur
  - data-cleaning
---

# 02 - Google Sheets

> Première vraie journée technique du bootcamp. Deux couches : la **théorie du métier** (les 7 étapes d'une analyse de données, qui structureront tout le reste du cursus) puis la **boîte à outils tableur** (import, nettoyage, jointure, agrégation, filtrage). Presque toutes les formules vues ici ont un équivalent 1:1 en SQL, puis en pandas, puis en DAX — c'est le socle mental, pas juste du Google Sheets.

**Date :** 7 juillet 2026
**Format :** cours du matin + challenge l'après-midi + récap sans ordinateur à 17h · promo de 8 personnes
**Intervenant :** formateur Le Wagon, ex-**growth data analyst** en start-up (background no-code, a appris le code au Wagon)

> [!warning] Note de reconstitution
> Chapitre rédigé **rétroactivement**, à partir du seul transcript audio — **aucune capture d'écran** de cette session. Les formules ci-dessous sont **reconstruites** à partir de la description orale : elles sont syntaxiquement correctes, mais les noms de colonnes/plages sont des exemples génériques, pas ceux du fichier d'exercice. À recroiser avec la cheat sheet du cours si besoin.

---

## 🎯 TL;DR

- **7 étapes** d'une analyse : besoin → data nécessaire → type d'analyse → exploration → **nettoyage (>50% du temps)** → transformation/KPI → restitution. Et c'est **itératif**, jamais linéaire.
- **Sheets ≈ Excel à 95%** — ne jamais s'auto-censurer sur une offre à cause de la stack. Ce qui compte c'est la logique, pas le nom de l'outil.
- **Limite de Sheets** : ça rame dès 50–100k lignes. Au-delà → BigQuery/SQL.
- **Importer** : `IMPORTRANGE` (autre Sheet) et `IMPORTDATA` (CSV en ligne) → toujours cibler des **colonnes entières** (`A:E`), jamais une plage figée (`A1:E35`).
- **Jointure** : `VLOOKUP` / `XLOOKUP` / `INDEX+MATCH` = le `LEFT JOIN` du tableur. Retourne **la première occurrence** trouvée, sans prévenir.
- **Agréger** : tableau croisé dynamique = `GROUP BY`. Piège du groupement par mois sans l'année.
- **Filtrer** : filtre manuel (exploration) vs `FILTER` (dynamique, dashboard) vs `QUERY` (SQL-like).
- Deux principes découverts ici qui reviendront **tout le cursus** : *ne jamais copier une formule depuis un traitement de texte* (guillemets typographiques) et *agréger avant de diviser*.

---

## 🧭 Sommaire

- [[#🧠 1. Les 7 étapes d'une analyse de données]]
- [[#🧰 2. Positionnement des outils — Sheets, Excel, BigQuery]]
- [[#📥 3. Importer de la donnée]]
- [[#🧼 4. Nettoyer du texte]]
- [[#📅 5. Travailler les dates]]
- [[#🔗 6. Les jointures — VLOOKUP, XLOOKUP, INDEX+MATCH]]
- [[#🧮 7. ARRAYFORMULA — appliquer une formule à toute une colonne]]
- [[#📊 8. Agréger — le tableau croisé dynamique]]
- [[#🔎 9. Filtrer — manuel, FILTER, UNIQUE, QUERY]]
- [[#📈 10. Graphiques]]
- [[#⚠️ 11. Pièges et bonnes pratiques]]
- [[#🇫🇷 12. Noms de fonctions FR / EN]]
- [[#🔮 13. Ce que chaque formule devient plus tard dans le cursus]]
- [[#🩹 14. Corrections apportées au support source]]
- [[#💼 15. Interview prep]]
- [[#✅ 16. Actions post-session]]

---

## 🧠 1. Les 7 étapes d'une analyse de données

C'est la partie la plus durable de la session : ces 7 étapes sont le squelette de tout le métier, indépendamment de l'outil.

| # | Étape | Ce que ça veut dire concrètement |
|---|---|---|
| 1 | **Comprendre le besoin** | Recueillir l'attente de l'équipe métier **avant** de toucher la donnée. Partir de la finalité et reconstruire le chemin à l'envers. Ne jamais inventer le besoin à leur place. |
| 2 | **Identifier la donnée nécessaire** | Quels KPI ? Où vit la donnée ? Selon l'entreprise, ce n'est pas forcément toi qui la récupères — une autre équipe peut te la mettre à disposition. |
| 3 | **Choisir le type d'analyse** | **Récurrente** (dashboard utilisé au quotidien, vision long terme) vs **one-shot** (« on a fait un très bon / très mauvais mois, pourquoi ? ») |
| 4 | **Explorer la donnée** | Phase lente au début, quasi instantanée quand tu connais les tables par cœur. C'est le capital que tu construis en restant dans une boîte. |
| 5 | **Nettoyer** | **Souvent >50% du temps de travail.** Dépend de la qualité de la donnée — mauvaise dans les petites boîtes *comme* dans les grosses. |
| 6 | **Transformer & calculer les KPI** | Nouvelles colonnes, agrégations, calculs. |
| 7 | **Restituer & recommander** | Support **visuel** obligatoire. Balancer des chiffres bruts à une équipe métier ne fonctionne pas — il faut un objet visuel qui porte la recommandation. |

> [!important] Le processus est itératif, pas linéaire
> Le retour de l'équipe métier te renvoie systématiquement à une étape précédente : un chiffre qui paraît faux → retour au **nettoyage** ; une question nouvelle sur une campagne → retour à l'**exploration**. C'est une boucle, pas un tunnel.

**Les cas d'usage classiques** (ils reviennent partout, quel que soit le secteur) : mesurer la performance d'une entreprise, comparer deux versions d'un même dispositif (A/B), comprendre un facteur de succès ou d'échec.

**Sur les KPI métier** : chaque service (commercial, logistique, marketing, support…) a ses propres indicateurs. Ce n'est **pas** un prérequis à maîtriser avant d'être embauché — ça s'apprend sur le terrain. En revanche, se renseigner sur les KPI du service **au moment de postuler** est un vrai différenciateur en entretien.

---

## 🧰 2. Positionnement des outils — Sheets, Excel, BigQuery

| Outil | Terrain | À retenir |
|---|---|---|
| **Google Sheets** | Startups, PME, équipes agiles | Suffit pour faire **les 7 étapes de bout en bout** sur des volumes raisonnables |
| **Excel** | Grandes entreprises (banque, industrie, finance) | **~95% des fonctionnalités communes** avec Sheets |
| **SQL** | Nettoyage et requêtage sérieux | Là où on détecte vraiment les valeurs aberrantes, les doublons, les incohérences |
| **BigQuery** | Millions → milliards de lignes | Vu en fin de semaine / semaine suivante → [[Data Pipelines, Views & Tables]] |

> [!tip] Le conseil carrière du formateur
> **Ne jamais se bloquer sur la stack.** Voir un outil inconnu dans une offre n'est pas un motif de ne pas postuler. La bonne formulation mentale (et en entretien) : *« je maîtrise un outil équivalent, je suis capable de prendre celui-ci en main. »*

**La limite dure de Google Sheets** : au-delà de **50 000–100 000 lignes** sur une feuille, ça devient lent, puis inutilisable. Pour des millions de lignes, ce n'est simplement pas le bon outil.

> [!note] Précision ajoutée
> Le plafond **technique** de Google Sheets est de **10 millions de cellules** par classeur (et 18 278 colonnes, soit jusqu'à ZZZ). Mais le plafond **pratique** — celui où les formules mettent 10 secondes à recalculer — est très en dessous : c'est bien 50–100k lignes le vrai seuil de bascule vers une base de données. Ne jamais citer le chiffre de 10M comme une capacité réelle.

---

## 📥 3. Importer de la donnée

### 3.1 `IMPORTRANGE` — récupérer une plage depuis un autre Google Sheet

```
=IMPORTRANGE("URL_du_document_source", "NomDeLOnglet!A:E")
```

- **Argument 1** : l'URL complète du document source (entre guillemets)
- **Argument 2** : `"Onglet!Plage"` — **une seule chaîne**, les deux collés par un `!`

**La règle d'or : sélectionner des colonnes entières, pas une plage figée.**

```
❌ "MajorLeagueBoard!A1:E35"   → les nouvelles lignes n'apparaîtront jamais
✅ "MajorLeagueBoard!A:E"      → toute nouvelle ligne est reprise automatiquement
```

C'est le réflexe central de la journée : **toujours écrire une formule qui absorbe la donnée future sans intervention manuelle.**

**Limite de cette règle** : elle protège contre les nouvelles **lignes**, pas contre les nouvelles **colonnes**. Si une colonne `F` apparaît dans la source, il faudra éditer la formule à la main.

**Contraintes à connaître :**

| Contrainte | Détail |
|---|---|
| **Plage en lecture seule** | Le tableau importé ne se modifie pas. Pour le retoucher : copier → **collage spécial > valeurs uniquement** dans un autre onglet. |
| **La zone d'accueil doit être vide** | Une seule cellule occupée dans la zone de sortie et la formule renvoie `#REF!` (« Le résultat n'a pas été développé »). |
| **Rafraîchissement périodique** | Pas de temps réel : Sheets réinterroge la source à intervalle régulier (**~30 min** pour `IMPORTRANGE`, ~1 h pour les autres fonctions `IMPORT*`). |
| **Colonnes masquées** | Masquer une colonne dans la source **ne la masque pas** dans le doc importé. `A:E` reste `A:E`, masquage inclus. La question posée en séance a été tranchée là-dessus. |
| **Autorisation** ⚠️ | *(non mentionné en séance)* Au tout premier appel, la formule renvoie `#REF!` avec un bouton **« Autoriser l'accès »** à cliquer. Tant qu'on n'a pas cliqué, la formule semble cassée sans l'être. |

> [!warning] Point gouvernance à connaître
> Une fois l'accès autorisé, **toute personne ayant accès au doc de destination voit la donnée importée**, même sans droits sur le doc source. `IMPORTRANGE` est donc un vecteur de fuite de données silencieux. À garder en tête en environnement bancaire.

### 3.2 `IMPORTDATA` — récupérer un CSV depuis une URL

```
=IMPORTDATA("https://exemple.com/export.csv", ",")
```

- **Argument 2 = le délimiteur.** CSV = *comma separated values* → une virgule. Sans cette précision, tout peut atterrir dans une seule colonne.
- Utile quand la donnée est exposée en ligne (open data, export automatique d'un outil). Sinon, télécharger + importer manuellement fait le job.

### 3.3 Quand tout arrive dans la colonne A

Symptôme classique du copier-coller de CSV. Solution : **Données > Diviser le texte en colonnes** (*Split text to columns*), puis choisir le séparateur.

---

## 🧼 4. Nettoyer du texte

### 4.1 `SUBSTITUTE` — remplacer une chaîne par une autre (ou par rien)

```
=SUBSTITUTE(A2, " UTC", "")
```

Lecture : *dans A2, si tu trouves « espace + UTC », remplace-le par rien du tout* (`""` = chaîne vide).

**Quand c'est le bon outil** : peu de cas distincts à traiter. Si tu as `UTC`, `UVC`, `UGC`… et 300 variantes possibles, écrire 300 `SUBSTITUTE` imbriqués est ingérable → passer au regex.

**Imbrication pour plusieurs critères** (l'exemple de fin de session : nettoyer les formes juridiques dans des noms d'entreprise) :

```
=SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(A2, " LLC", ""), " GmbH", ""), " Inc", "")
```

Ça tient pour 3 critères. Pour 200, c'est mort.

> [!bug] `SUBSTITUTE` est sensible à la casse
> *(non dit en séance)* `SUBSTITUTE(A2, " llc", "")` ne trouvera pas `" LLC"`. Pour du nettoyage case-insensitive, il faut passer par regex avec le préfixe `(?i)`.

### 4.2 `LEFT` / `RIGHT` + `LEN` — couper par la longueur

Le cas vu en cours : une colonne de timestamps du type `2026-07-07 14:32:05 UTC` — **23 caractères**, dont les **4 derniers** (` UTC`) sont à virer.

```
❌ =LEFT(A2, 19)          → figé : casse si le format varie d'un caractère
✅ =LEFT(A2, LEN(A2)-4)   → dynamique : « tout sauf les 4 derniers »
```

**C'est le principe à retenir** : `LEFT`/`RIGHT` attendent un **nombre de caractères à garder**. Combiner avec `LEN()` transforme un « garde 19 caractères » figé en « enlève les 4 derniers » robuste.

### 4.3 Les fonctions REGEX

| Fonction | Rôle | Comportement en cas de non-match |
|---|---|---|
| `REGEXCONTAINS(texte, motif)` | Test booléen : le motif est-il présent ? | `FALSE` (propre) |
| `REGEXEXTRACT(texte, motif)` | **Extrait** la portion qui matche | ⚠️ **`#N/A`** — casse la colonne |
| `REGEXREPLACE(texte, motif, remplacement)` | **Remplace** ce qui matche | Renvoie le texte inchangé (propre) |

**Le cas des formes juridiques, fait proprement :**

```
=TRIM(REGEXREPLACE(A2, "\s+(LLC|GmbH|Inc\.?|Ltd\.?|SARL|SA)$", ""))
```

- `\s+` = un ou plusieurs espaces · `(A|B|C)` = « l'un de ces trois » · `$` = ancré en fin de chaîne (évite de mutiler `SA Coiffure`)
- `TRIM()` en enveloppe pour nettoyer les espaces résiduels
- Une seule formule pour 3 critères… ou pour 200. C'est ça qui scale.

> [!warning] Attention aux faux positifs
> Point soulevé en séance : chercher une chaîne courte dans un nom d'entreprise peut matcher des entreprises qui la contiennent légitimement. D'où l'ancre `$` et l'espace obligatoire devant.

**Syntaxe regex** : Google Sheets utilise **RE2** (la bibliothèque de Google), pas PCRE. 95% identique pour l'usage courant, mais pas de lookahead/lookbehind.

### 4.4 Concaténer — `CONCATENATE` ou `&`

```
=CONCATENATE(A2, "_", B2)
=A2 & "_" & B2            ← même résultat, plus court
```

> [!important] Règle data : l'underscore, jamais l'espace
> Le séparateur de référence en data est `_`. **Jamais d'espace**, jamais de caractère accentué, jamais de tiret dans une clé technique. Cette convention te suivra en SQL (`customer_id`), en Python (`snake_case`), en dbt (`stg_orders`).

---

## 📅 5. Travailler les dates

### 5.1 Le numéro de série — pourquoi une date s'affiche en nombre

Une date, pour un tableur, c'est un **nombre** : le nombre de jours écoulés depuis le **30 décembre 1899**. La partie décimale encode l'heure (`0,5` = midi).

Quand une formule renvoie `45845` au lieu d'une date, **rien n'est cassé** : c'est le numéro de série brut. Il suffit de reformater la cellule en *Format > Nombre > Date*. C'est exactement ce qui a troublé la salle en séance.

### 5.2 Convertir du texte en vraie date

| Fonction | Usage |
|---|---|
| `DATEVALUE(texte)` | Texte → numéro de série de date (`"2026-07-07"` → `46...`) |
| `VALUE(texte)` | Texte → nombre, plus générale. Sur une date bien formée, résultat quasi identique |

Le test décisif : **une vraie date s'aligne à droite** dans la cellule, un texte s'aligne à gauche. Réflexe de vérification en 1 seconde.

### 5.3 `DATEDIF` — écart entre deux dates

```
=DATEDIF(date_debut, date_fin, "D")
```

| Unité | Résultat |
|---|---|
| `"Y"` | années complètes |
| `"M"` | mois complets |
| `"D"` | jours |
| `"MD"` | jours, en ignorant mois et années |
| `"YM"` | mois, en ignorant les années |
| `"YD"` | jours, en ignorant les années |

> [!check] Action item du cours résolue
> L'action item disait : *« aller voir la doc Google pour les unités de DATEDIF (semaines, trimestres…) »*. **Réponse : elles n'existent pas.** La liste ci-dessus est exhaustive — pas d'unité semaine, pas d'unité trimestre. L'intuition du formateur en séance était juste.
>
> Les contournements :
> ```
> Semaines écoulées   =INT((B2-A2)/7)
> N° de trimestre     =ROUNDUP(MONTH(A2)/3)
> Écart en trimestres =(YEAR(B2)-YEAR(A2))*4 + ROUNDUP(MONTH(B2)/3) - ROUNDUP(MONTH(A2)/3)
> ```

> [!bug] `DATEDIF` est une fonction fantôme
> Héritée de Lotus 1-2-3, conservée pour compatibilité : elle **n'apparaît pas dans l'autocomplétion** de Sheets ni d'Excel, et n'a pas d'aide contextuelle. Il faut la taper en aveugle. Ce n'est pas un bug de ton tableur.
>
> Pour un simple écart en jours, la soustraction directe `=B2-A2` fait le même travail et est plus lisible.

### 5.4 Extraire des composantes — `YEAR` / `MONTH` / `DAY` / `WEEKNUM`

```
=YEAR(A2)      → 2026
=MONTH(A2)     → 7
=WEEKNUM(A2)   → 28
```

**L'usage qui compte** : rendre un rapport dynamique. Combiner `WEEKNUM(TODAY())` avec un filtre pour construire un dashboard « semaine en cours » qui se met à jour tout seul, sans jamais rééditer la formule.

```
=FILTER(A2:F, WEEKNUM(A2:A) = WEEKNUM(TODAY()), YEAR(A2:A) = YEAR(TODAY()))
```

> [!warning] Le `WEEKNUM` seul ne suffit pas sur plusieurs années
> Signalé en séance : filtrer sur la semaine 29 sans contrainte d'année ramène la semaine 29 de **toutes** les années présentes dans la donnée. D'où la seconde condition sur `YEAR`.
>
> C'est **exactement le même piège** que le groupement par mois dans un tableau croisé ([[#8.3 Le piège du groupement par date]]) et que la Calendar table en Power BI. Trois occurrences du même problème dans trois outils différents.

---

## 🔗 6. Les jointures — VLOOKUP, XLOOKUP, INDEX+MATCH

### 6.1 Le concept : la clé de jointure

Deux tables distinctes, **une colonne en commun** (l'ID client, le nom de la ville…) : c'est la **clé de jointure**. Elle permet d'aller chercher dans la table B une information manquante dans la table A.

> [!quote] Ce que dit le formateur
> C'est **la même logique en SQL**. Comprendre ce mécanisme dans Sheets, c'est avoir déjà compris le `LEFT JOIN`. C'est la fonction la plus importante de la journée.

### 6.2 `VLOOKUP`

```
=VLOOKUP(clé_recherchée, plage, n°_colonne, FALSE)
=VLOOKUP($A2, $H:$K, 3, FALSE)
```

| Argument | Rôle |
|---|---|
| 1 · `search_key` | **Une seule cellule** — la valeur à retrouver |
| 2 · `range` | La plage de recherche. **La clé doit être dans sa première colonne** |
| 3 · `index` | Le **numéro** de la colonne à ramener, compté depuis le début de la plage |
| 4 · `is_sorted` | `FALSE` = correspondance exacte. **Toujours mettre `FALSE`.** |

**Trois pièges vus en séance :**

1. **Première occurrence uniquement.** Si la clé apparaît plusieurs fois dans la table de référence, `VLOOKUP` renvoie la première trouvée et s'arrête. Silencieusement. Sur une clé non unique, le résultat est faux sans le dire.
2. **Colonnes homonymes.** Une colonne `id` d'un côté, une colonne `id` de l'autre, qui ne contiennent pas la même chose (`order_id` vs `customer_id`). Toujours vérifier que les deux colonnes portent bien la **même sémantique**, pas juste le même nom.
3. **Verrouiller avec `$`** pour pouvoir étirer la formule. `$H:$K` bloque la plage horizontalement, `$A2` bloque la colonne de la clé mais laisse la ligne bouger. Raccourci : **F4** cycle entre les modes de verrouillage.

**Gérer les non-correspondances :**

```
=IFERROR(VLOOKUP($A2, $H:$K, 3, FALSE), "")
```

`VLOOKUP` renvoie `#N/A` quand il ne trouve rien. `IFERROR` transforme ça en cellule vide, ce qui garde la colonne propre et exploitable pour la suite.

> [!bug] Correction sur le support source
> Le résumé Notion indique que le **« 3e argument optionnel (guillemets vides) »** de `VLOOKUP` gère le cas « valeur non trouvée ». **C'est faux.** Le 3e argument de `VLOOKUP` est obligatoire (l'index de colonne) et le 4e est `is_sorted`. `VLOOKUP` **n'a aucun argument de repli**. Ce qui a été vu à l'écran est soit un `IFERROR(...,"")` en enveloppe, soit le 4e argument de `XLOOKUP`. → voir [[#🩹 14. Corrections apportées au support source]]

### 6.3 `XLOOKUP` — la version moderne

```
=XLOOKUP(clé, colonne_de_recherche, colonne_de_retour, "Non trouvé")
=XLOOKUP($A2, $H:$H, $K:$K, "")
```

| | `VLOOKUP` | `XLOOKUP` |
|---|---|---|
| **Direction** | Uniquement vers la droite ; la clé doit être en 1re colonne | Les deux sens — la colonne de retour peut être **à gauche** |
| **Colonne cible** | Un **numéro** à compter à la main | La **colonne** directement |
| **Insertion d'une colonne** | 💥 le numéro devient faux, la formule casse **silencieusement** | ✅ reste valide |
| **Correspondance** | Approximative par défaut → penser à `FALSE` | **Exacte par défaut** |
| **Valeur si absent** | Aucune → besoin de `IFERROR` | 4e argument intégré |

**Verdict** : dès que tu as le choix, `XLOOKUP`. Mais `VLOOKUP` reste omniprésent (tutos, fichiers hérités, collègues) — il faut savoir **lire** les deux.

> [!tip] Nuance importante pour le marché bancaire
> `XLOOKUP` est arrivé tard : **Excel 365 uniquement** (pas Excel 2019 et antérieurs), et dans Google Sheets depuis **2024**. Beaucoup de banques tournent encore sur des versions figées d'Excel. Si tu dois livrer un fichier qui marche **partout**, la combinaison universelle reste `INDEX + MATCH`.

### 6.4 `INDEX` + `MATCH` — l'alternative universelle

```
=INDEX(colonne_à_ramener, MATCH(clé, colonne_de_recherche, 0))
=INDEX($K:$K, MATCH($A2, $H:$H, 0))
```

Lecture, de l'intérieur vers l'extérieur :
1. `MATCH` trouve **la position** (le n° de ligne) de la clé dans la colonne de recherche
2. `INDEX` va chercher **la valeur** à cette position dans la colonne de retour

> [!important] Le `0` de `MATCH` n'est pas optionnel
> Le 3e argument de `MATCH` vaut **1 par défaut** = correspondance approximative sur une plage **triée**. Sur une plage non triée, ça renvoie n'importe quoi, sans erreur. **Toujours écrire le `0`.** C'est le pendant exact du `FALSE` de `VLOOKUP`.

Le formateur a bien noté que la logique est « un peu inversée » par rapport à `VLOOKUP` : ici on donne d'abord **quoi ramener**, ensuite **où chercher**.

---

## 🧮 7. ARRAYFORMULA — appliquer une formule à toute une colonne

Au lieu d'écrire la formule dans `J2` puis de l'étirer sur 10 000 lignes :

```
=ARRAYFORMULA(VLOOKUP(A2:A, H:K, 3, FALSE))
```

On passe une **plage** (`A2:A`) là où on passait une cellule (`A2`). Une seule formule, dans une seule cellule, qui remplit toute la colonne.

**Ce que ça change concrètement :**
- Le fichier reste léger (1 formule au lieu de 10 000)
- Les **nouvelles lignes sont couvertes automatiquement** — plus besoin de réétirer
- Une seule cellule à corriger en cas d'erreur

**Raccourci** : taper la formule sans `ARRAYFORMULA` puis **Ctrl+Shift+Entrée** — Sheets l'enveloppe tout seul.

**Gérer l'en-tête** (sinon la ligne 1 sort du calcul en erreur) :

```
=ARRAYFORMULA(IF(ROW(A:A)=1, "Catégorie", IF(A:A="", "", VLOOKUP(A:A, H:K, 3, FALSE))))
```

> [!note] C'est la même idée que la vectorisation
> `ARRAYFORMULA` : une opération, une colonne entière. C'est exactement le raisonnement de `df["col"] * 2` en pandas, ou d'une colonne calculée en SQL. Sortir de la logique « cellule par cellule » ici, c'est se préparer à tout le reste du cursus.

---

## 📊 8. Agréger — le tableau croisé dynamique

*Pivot Table en anglais, TCD en français.*

### 8.1 Le principe

Prendre une table détaillée (une ligne = un client, une commande…) et la **replier** selon un ou plusieurs critères.

Sur une table `customer_id | date | source | produits_achetés` :

| Agréger par | Donne |
|---|---|
| `date` | Nombre de nouveaux clients par jour + somme des produits achetés par jour |
| `source` | Volume et nombre de clients par canal d'acquisition |
| `date` + `source` | Le croisement des deux |

Un même tableau peut nourrir **5 pivots différents** selon la question posée. C'est un outil d'exploration, pas un livrable.

### 8.2 Les fonctions d'agrégation

| Fonction | Compte / calcule quoi |
|---|---|
| `COUNT` | Uniquement les valeurs **numériques** |
| `COUNTA` | Toutes les valeurs **non vides**, texte inclus |
| `SUM` | Somme |
| `AVERAGE` | Moyenne |
| `MAX` / `MIN` | Extrêmes |

> [!warning] `COUNT` sur une colonne de texte renvoie 0
> Le piège le plus classique du TCD. Pour compter des IDs stockés en texte, des emails, des noms de villes → **`COUNTA`**.

**L'ordre des champs compte** : mettre `source` avant `date` en ligne ne produit pas la même lecture que `date` avant `source`. Le premier champ définit le regroupement principal.

### 8.3 Le piège du groupement par date

Sheets propose de grouper une colonne date par jour, mois, trimestre, année…

> [!danger] Toujours choisir `year-month` ou `year-quarter`
> Grouper par **mois seul** fusionne janvier 2025 + janvier 2026 + janvier 2027 dans la même ligne. Sur un seul millésime de données, ça ne se voit pas. Le jour où deux ans de données arrivent, tous les chiffres deviennent faux — **sans aucune erreur affichée**.
>
> Même piège, trois outils : ici, en SQL (`GROUP BY EXTRACT(MONTH FROM d)` sans l'année) et en Power BI (colonne Mois sans Calendar table). → voir [[#5.4 Extraire des composantes — YEAR / MONTH / DAY / WEEKNUM]]

Exception légitime : l'analyse de **saisonnalité**, où on veut justement empiler tous les mois de janvier ensemble. Mais c'est un choix explicite, pas un défaut.

### 8.4 Les champs calculés

Un champ calculé permet de créer une colonne dérivée dans le pivot (un ratio, un panier moyen…).

**Deux points de vigilance :**

1. **Le format d'affichage.** Un ratio sorti en champ calculé s'affiche en nombre brut. Il faut passer par *Format > Nombre > Format personnalisé* pour obtenir un pourcentage lisible.
2. **Le conseil du formateur : calculer le ratio en dehors du pivot**, dans une colonne à côté, plutôt que dans le champ calculé. Plus lisible, plus contrôlable, moins de surprises.

> [!important] 🧠 Brocode-worthy — agréger AVANT de diviser
> Un ratio agrégé n'est **jamais** la moyenne des ratios de chaque ligne :
> ```
> ✅ SUM(revenu) / SUM(commandes)        → le vrai panier moyen
> ❌ AVERAGE(revenu / commandes)          → une moyenne de moyennes, faux
> ```
> C'est la **première apparition dans le cursus** d'un principe qui reviendra en SQL, dans dbt, dans Looker Studio et en DAX. Vu de loin en session 2, il coûtera cher plus tard s'il n'est pas ancré maintenant.

### 8.5 Où le poser

*Insertion > Tableau croisé dynamique* → nouvelle feuille (recommandé) ou onglet existant. Ne jamais poser un pivot au milieu de la donnée source.

---

## 🔎 9. Filtrer — manuel, FILTER, UNIQUE, QUERY

### 9.1 Le filtre manuel (l'entonnoir)

*Données > Créer un filtre.* Pour **explorer** : retrouver un client, vérifier une valeur, se faire une idée de la distribution.

> [!note] Filtre vs vue filtrée
> Un filtre classique modifie l'affichage **pour tout le monde**. Sur un doc partagé, préférer *Données > Vues filtrées* : ta vue n'affecte personne d'autre. Point important dès qu'on touche à une donnée source utilisée par d'autres.

Le principe général énoncé en séance : **la donnée source ne se modifie pas.** On travaille à côté, jamais dessus.

### 9.2 `FILTER` — le filtre en formule

```
=FILTER(plage, condition1, [condition2], ...)
=FILTER(A2:F, C2:C="Paris", D2:D="english")
```

Le résultat s'affiche **ailleurs** (autre onglet, autre zone) et se recalcule tout seul quand la donnée source change.

| Besoin | Syntaxe |
|---|---|
| ET (toutes les conditions) | conditions séparées par des virgules |
| OU | `=FILTER(A2:F, (C2:C="Paris") + (C2:C="Lyon"))` — le `+` fait le OU |
| Aucun résultat | ⚠️ renvoie `#N/A` → envelopper dans `IFERROR(..., "")` |

**Le vrai intérêt : le critère dynamique.** Au lieu d'écrire `"Paris"` en dur, référencer une cellule qui contient une **liste déroulante** (*Données > Validation des données*) :

```
=FILTER(A2:F, C2:C = $H$1)
```

L'utilisateur choisit dans le menu → la table filtrée se met à jour → **et les graphiques et pivots branchés dessus suivent**. C'est comme ça qu'on construit un dashboard interactif en Sheets. L'exemple de la séance : un sélecteur de type d'email (Gmail / Yahoo) qui rejoue toute l'analyse.

### 9.3 `UNIQUE` — les valeurs distinctes

```
=UNIQUE(C2:C)
```

Réflexe d'exploration à faire quasi systématiquement à l'ouverture d'un dataset : *qu'est-ce qu'il y a vraiment dans cette colonne ?* C'est comme ça qu'on repère `Paris`, `paris`, `PARIS ` et `Prais` — les quatre variantes qui vont ruiner ton `GROUP BY`.

### 9.4 `QUERY` — du SQL dans une cellule

```
=QUERY(A1:F, "SELECT A, B, E WHERE C = 'EU' AND D = 'english'", 1)
```

- **Argument 1** : la plage
- **Argument 2** : la requête, en *Google Visualization API Query Language* (proche du SQL : `SELECT`, `WHERE`, `GROUP BY`, `ORDER BY`, `LIMIT`, `PIVOT`, `LABEL`)
- **Argument 3** : le nombre de lignes d'en-tête

**Les deux pièges de syntaxe :**

1. **Les valeurs texte vont entre guillemets simples**, les valeurs numériques sans rien :
   ```
   WHERE C = 'EU'        ✅ texte
   WHERE F > 100         ✅ nombre
   WHERE D >= date '2026-01-01'   ✅ date
   ```
   Les guillemets doubles sont déjà pris par la chaîne englobante — d'où les simples à l'intérieur.

2. **Les colonnes se désignent par leur lettre** (`A`, `B`, `C`) quand la plage est une plage de feuille — mais par `Col1`, `Col2`… quand la plage est le résultat d'une autre fonction (`IMPORTRANGE`, `FILTER`). Source d'erreur classique.

**Agréger directement :**

```
=QUERY(A1:F, "SELECT C, COUNT(A) GROUP BY C ORDER BY COUNT(A) DESC", 1)
```

> [!note] Positionnement de `QUERY`
> Le formateur l'a présentée rapidement et volontairement mise de côté : *« vous n'avez pas encore vu SQL, donc ça n'a pas beaucoup de sens de l'utiliser aujourd'hui »*. Elle prend tout son sens **après** le module SQL — c'est un excellent terrain d'entraînement une fois les clauses acquises.

---

## 📈 10. Graphiques

| Règle | Détail |
|---|---|
| **La règle des 5 secondes** | Si un graphique met plus de 5 secondes à être compris, il n'est pas bon. Point. |
| **Max 3 séries** | Au-delà, ça devient illisible. Deux graphiques valent mieux qu'un graphique surchargé. |
| **Unités mixtes** | Mélanger un taux (0 à 1) et un volume (0 à 500) écrase visuellement le taux → axe secondaire, ou deux graphiques |
| **Nettoyer les séries par défaut** | Sélectionner toute la donnée fait empiler toutes les colonnes, IDs compris. Réflexe : **tout supprimer**, puis ajouter uniquement la série voulue |
| **Modification série par série** | Chaque série a ses propres options (couleur, type, axe, étiquettes) |
| **Étiquettes de données** | À activer quand l'équipe métier veut lire les valeurs sans survoler |
| **Le test humain** | Montrer le graphique à quelqu'un de l'équipe **avant** de l'envoyer. S'il pose une question, c'est raté. |

Le vrai défi n'est pas conceptuel mais ergonomique : **savoir où sont les options** dans le panneau d'édition. Ça ne s'apprend qu'en pratiquant.

---

## ⚠️ 11. Pièges et bonnes pratiques

### 11.1 Les guillemets typographiques

> [!danger] 🧠 Brocode-worthy — le piège du copier-coller
> Copier une formule depuis un support de cours, une slide ou un traitement de texte remplace les guillemets droits `"` par des guillemets typographiques `"` `"`. La formule **échoue silencieusement** ou renvoie un résultat aberrant.
>
> **Le signal visuel** : dans la barre de formule, si le contenu entre guillemets s'affiche en **gris** au lieu d'être coloré, c'est mort.
>
> **Le fix** : retaper les guillemets à la main, ou faire transiter le texte par un éditeur en texte brut (Bloc-notes, TextEdit en mode brut) avant de coller.
>
> C'est **la même famille de problème** que les caractères invisibles dans DAX rencontrés bien plus tard en Power BI. Le réflexe « je fais transiter par un éditeur de texte brut » naît ici, en session 2.

### 11.2 Les couleurs de la barre de formule

Quand Sheets colore les arguments d'une fonction, c'est qu'il a **compris** la structure. Pas de couleur = un argument mal formé. C'est un debugger gratuit et instantané.

Astuce liée : cliquer sur le **nom de la fonction** dans l'infobulle affiche la syntaxe complète et le rôle de chaque argument, sans quitter la feuille.

### 11.3 Étirer une formule : le double-clic et sa limite

Double-cliquer sur la petite poignée carrée en bas à droite de la cellule étire la formule jusqu'en bas — instantané.

> [!warning] Le double-clic s'arrête au premier trou
> Il s'arrête à la première ligne vide détectée dans la colonne adjacente. Sur une donnée trouée, il ne descend pas jusqu'en bas et **rien ne le signale**.
>
> **Ce que recommande le formateur** : copier la formule et la **coller sur toute la colonne** plutôt que l'étirer. Plus fiable, et ça couvre aussi les lignes qui n'existent pas encore.

### 11.4 Le fil rouge de la journée : l'automatisation

> [!quote]
> Toujours chercher à rendre la formule dynamique, pour ne pas avoir à refaire des opérations manuelles toutes les semaines.

Trois déclinaisons vues dans la session : colonnes entières dans `IMPORTRANGE`, `WEEKNUM(TODAY())` dans les filtres, critères de `FILTER` branchés sur une liste déroulante.

### 11.5 Actualisation programmée

Sheets permet de programmer un rafraîchissement automatique des connecteurs de données (*Données > Actualisation des données*) : quotidien, hebdomadaire, ou un jour précis. Pertinent quand la donnée vient d'une source externe (CRM, outil de tracking).

### 11.6 Sur les formules : ne pas les apprendre par cœur

> [!quote] Position du formateur
> L'important n'est **pas** de connaître les formules par cœur, mais de savoir **quelle opération est possible** et comment retrouver la fonction. Une cheat sheet est fournie avec le cours. La doc Google est propre et complète.

Ce qui compte : *« je sais que ce type de nettoyage est faisable en une formule »*. Le nom exact, on le retrouve en 30 secondes.

---

## 🇫🇷 12. Noms de fonctions FR / EN

Point non traité en cours mais **directement utile pour le marché genevois** : en banque, Excel est souvent en français, et les formules aussi.

| Anglais | Français |
|---|---|
| `VLOOKUP` | `RECHERCHEV` |
| `XLOOKUP` | `RECHERCHEX` |
| `INDEX` / `MATCH` | `INDEX` / `EQUIV` |
| `FILTER` | `FILTRE` |
| `UNIQUE` | `UNIQUE` |
| `IFERROR` | `SIERREUR` |
| `SUBSTITUTE` | `SUBSTITUE` |
| `LEFT` / `RIGHT` / `LEN` | `GAUCHE` / `DROITE` / `NBCAR` |
| `CONCATENATE` | `CONCATENER` |
| `TRIM` | `SUPPRESPACE` |
| `VALUE` / `DATEVALUE` | `CNUM` / `DATEVAL` |
| `YEAR` / `MONTH` / `DAY` | `ANNEE` / `MOIS` / `JOUR` |
| `WEEKNUM` | `NO.SEMAINE` |
| `COUNT` / `COUNTA` | `NB` / `NBVAL` |
| `SUM` / `AVERAGE` | `SOMME` / `MOYENNE` |
| `DATEDIF` | `DATEDIF` *(identique)* |

> [!warning] Le séparateur d'arguments change aussi
> Locale **en_US** → virgule : `=VLOOKUP(A2, H:K, 3, FALSE)`
> Locale **fr_FR** → point-virgule : `=RECHERCHEV(A2; H:K; 3; FAUX)`
>
> C'est ce qui a causé les galères de changement de langue en fin de session. **Le bon réflexe pour le bootcamp** : passer le classeur en *Fichier > Paramètres > Anglais (États-Unis)* — toute la doc, tous les tutos et tout le cursus sont en anglais. Le changement peut demander de recharger l'onglet pour être pris en compte.

---

## 🔮 13. Ce que chaque formule devient plus tard dans le cursus

C'est la vraie valeur de cette session : rien de ce qui est vu ici ne sera jeté.

| Google Sheets | SQL / BigQuery | Python / pandas | Power BI |
|---|---|---|---|
| `VLOOKUP` / `XLOOKUP` / `INDEX+MATCH` | `LEFT JOIN` | `pd.merge(how="left")` | Relation + `RELATED()` |
| Tableau croisé dynamique | `GROUP BY` + agrégats | `.groupby().agg()` | Visuel Matrice + mesures DAX |
| `FILTER` | `WHERE` | masque booléen `df[df.x > 0]` | Filtres visuels / `FILTER()` |
| `QUERY` | la requête complète | `df.query()` | — |
| `IMPORTRANGE` / `IMPORTDATA` | vue, table externe | `pd.read_csv()` | Power Query |
| `SUBSTITUTE` / `REGEXREPLACE` | `REPLACE` / `REGEXP_REPLACE` | `.str.replace(regex=True)` | `Text.Replace` |
| `DATEDIF` | `DATE_DIFF()` | `(d2 - d1).dt.days` | `DATEDIFF()` |
| `YEAR` / `MONTH` / `WEEKNUM` | `EXTRACT(YEAR FROM d)` | `.dt.year` | Calendar table |
| `UNIQUE` | `SELECT DISTINCT` | `.unique()` | `DISTINCT()` |
| `ARRAYFORMULA` | vectorisation native | vectorisation pandas | colonne calculée |
| `COUNTA` | `COUNT(col)` | `.count()` | `COUNTA()` |
| `IFERROR` | `COALESCE` / `SAFE_DIVIDE` | `.fillna()` | `IFERROR()` |

> [!tip] Le point à retenir
> Passer de Sheets à SQL n'est pas un changement de logique, c'est un changement de **volumétrie et de syntaxe**. Toute la difficulté conceptuelle (jointure, agrégation, granularité) est déjà là, en session 2.

---

## 🩹 14. Corrections apportées au support source

| # | Ce que dit le support | Ce qui est correct |
|---|---|---|
| 1 | *« `VLOOKUP` : utiliser le 3e argument optionnel (guillemets vides) pour éviter les erreurs »* | ❌ Faux. `VLOOKUP(clé, plage, index, [is_sorted])` — le 3e argument est **obligatoire** (l'index de colonne), le 4e est `is_sorted`. Il **n'existe pas** d'argument de repli. Le comportement décrit correspond soit à `IFERROR(VLOOKUP(...), "")`, soit au 4e argument de `XLOOKUP`. |
| 2 | *« `REGEXEXTRACT` est la meilleure manière de nettoyer les suffixes »* | ⚠️ Mauvaise fonction. Pour **enlever** un motif, c'est `REGEXREPLACE`. `REGEXEXTRACT` *extrait* ce qui matche et renvoie `#N/A` en cas de non-match — ce qui explique exactement les « valeurs fausses » constatées à l'écran en fin de séance. |
| 3 | *Action item : « voir la doc pour les unités DATEDIF (semaines, trimestres) »* | ✅ Résolu : ces unités **n'existent pas**. Liste complète : `Y`, `M`, `D`, `MD`, `YM`, `YD`. Contournements donnés en [[#5.3 DATEDIF — écart entre deux dates]]. |
| 4 | Un résumé indique *« les graphiques n'ont pas été abordés aujourd'hui »*, un autre les détaille longuement | Contradiction interne du transcript (deux enregistrements distincts). La section graphiques a bien eu lieu — voir [[#📈 10. Graphiques]]. Ce qui a été reporté au lendemain, ce sont les **KPI**. |
| 5 | Le transcript mentionne des suffixes `RLC`, `GmbH`, `I` | Transcription approximative de `LLC`, `GmbH`, `Inc` — les trois formes juridiques standard (US, DE, US). |

---

## 💼 15. Interview prep

**Questions probables sur cette matière :**

| Question | Angle de réponse |
|---|---|
| *« Décrivez votre démarche face à une nouvelle demande d'analyse »* | Dérouler les 7 étapes, en insistant sur l'étape 1 (comprendre le besoin avant de toucher la donnée) et sur le caractère **itératif**. C'est ce qui distingue un analyste d'un exécutant de requêtes. |
| *« Différence entre VLOOKUP et XLOOKUP ? »* | Direction de recherche · numéro de colonne vs colonne directe · exact par défaut · gestion d'erreur intégrée. Puis la nuance qui fait la différence : *« mais je code en INDEX+MATCH quand je dois livrer un fichier compatible avec des versions d'Excel anciennes »*. |
| *« Quel est le plus gros poste de temps dans votre travail ? »* | Le nettoyage, **>50%**. Réponse honnête qui montre qu'on a une expérience réelle du terrain et pas juste une vision de tutoriel. |
| *« Quand quitte-t-on Excel pour une base de données ? »* | Volumétrie (50–100k lignes), besoin de versionning, multi-utilisateurs, traçabilité, automatisation. En banque, ajouter l'audit trail. |
| *« On travaille sur Excel, pas sur votre stack — ça vous pose un problème ? »* | *« Non — 95% des fonctionnalités sont communes, et la logique sous-jacente est la même. Ce que j'ai appris en Sheets, en SQL et en Power BI se transpose. »* |

> [!tip] Spécifique banque privée genevoise
> Excel reste **la lingua franca** en gestion de fortune et en middle office — souvent plus utilisé au quotidien que n'importe quel outil BI. Ne surtout pas présenter la maîtrise du tableur comme un acquis mineur : c'est un point d'entrée concret. Un profil qui sait faire un `INDEX+MATCH` propre **et** un `LEFT JOIN` en SQL est directement opérationnel. → voir la roadmap emploi du Project.

---

## ✅ 16. Actions post-session

- [ ] Récupérer et parcourir la **cheat sheet** fournie dans l'espace de cours
- [ ] Refaire les exercices du jour à blanc : `IMPORTRANGE`, `VLOOKUP`, tableau croisé dynamique
- [ ] Passer les classeurs du bootcamp en locale **en_US** une bonne fois pour toutes (fonctions + séparateur virgule)
- [ ] Rejouer le nettoyage des formes juridiques en `REGEXREPLACE` plutôt qu'en `SUBSTITUTE` imbriqués — c'est la version qui scale
- [ ] Refaire un `XLOOKUP` et un `INDEX+MATCH` sur le même problème pour ancrer les trois syntaxes
- [ ] S'entraîner aux graphiques en autonomie (le point le plus « ergonomique » de la session)

**Session suivante :** KPI + graphiques · **Session J+2 :** marketing & satisfaction client

---

## ❓ Questions ouvertes

- [x] ~~Bien vérifier la différence entre V et XLOOKUP~~ → traité en [[#6.3 XLOOKUP — la version moderne]]
- [x] ~~Unités disponibles pour DATEDIF~~ → traité en [[#5.3 DATEDIF — écart entre deux dates]]
- [ ] Est-ce que le `FILTER` dynamique avec liste déroulante tient la charge sur un vrai volume (10k+ lignes), ou est-ce qu'il faut basculer sur un TCD dès qu'on dépasse quelques milliers de lignes ?
- [ ] Programmation d'actualisation : jusqu'où ça va réellement sans passer par Apps Script ?

---

## 🔗 Liens

**Chapitres liés**
- [[10-data-pipelines-views-tables]] — volumétrie, quand quitter le tableur, architecture d'entrepôt
- Chapitres SQL — `LEFT JOIN`, `GROUP BY`, `WHERE` : les équivalents directs de `VLOOKUP`, du TCD et de `FILTER`

**Fiches-concept à créer / relier**
- [[Aggregate before divide]] — première apparition ici, dans les champs calculés du TCD
- [[Clé de jointure et cardinalité]] — le piège de la première occurrence
- [[Granularité d'une table]] — ce que le TCD manipule sans le nommer

**Ressources**
- Cheat sheet Le Wagon (espace de cours)
- Documentation Google Sheets — liste des fonctions
