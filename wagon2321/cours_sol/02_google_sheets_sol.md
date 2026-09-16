---
title: "Google Sheets — Importer, nettoyer, enrichir et analyser des données"
aliases:
  - "Google Sheets — Premier cours"
  - "Google Sheets — Import, nettoyage et agrégation"
  - "VLOOKUP, XLOOKUP et tableaux croisés dynamiques"
type: course
status: active
course: "Le Wagon — Data Analytics"
batch: 2321
session: 2
date: 2026-07-07
course_date: 2026-07-07
language: fr
database: "Google Sheets"
code_language: "Formules Google Sheets"
course_id: google-sheets
role_version: reference
brocode_version: v2
version: SOL
updated: 2026-09-08
technical_review_date: 2026-09-08
modeles_ia:
  - '[[modeles-ia/ChatGPT Sol]]'
attribution: confirmee
variantes:
  - '[[wagon2321/cours/02-google-sheets]]'
topics:
  - Google Sheets
  - Data Analysis Workflow
  - Data Cleaning
  - Dates
  - Lookup Functions
  - Pivot Tables
  - FILTER
  - QUERY
  - ARRAYFORMULA
  - Regex
tags:
  - brocode
  - wagon2321/cours
  - google-sheets
  - data-cleaning
---

# 📝 02 — Google Sheets · Importer, nettoyer, enrichir et analyser

> [!info] Repères Brocode
> **Rédaction :** [[modeles-ia/ChatGPT Sol|ChatGPT Sol]] · **Version SOL :** référence
> **Index :** [[navigation/Cours|Cours du Brocode]]
> **Autre version conservée :** [[wagon2321/cours/02-google-sheets|02 — Google Sheets · Claude Sonnet]]

> [!info] Navigation pédagogique
> **Pour approfondir ensuite :** [[wagon2321/cours_sol/05_intro_sql_relational_databases_bigquery_sol|SQL et bases relationnelles]] · [[wagon2321/cours_sol/06_sql_aggregation_string_date_time_functions_sol|Agrégation, texte et dates en SQL]] · [[wagon2321/cours_sol/07_joins_and_testing_sol|JOINs et contrôles]]
> **Deuxième cours Google Sheets :** lien à ajouter lorsque son fichier SOL sera disponible. Son contenu n’est pas présumé ici.

> [!abstract] Objectif du chapitre
> Construire une analyse que l’on peut relire et actualiser : comprendre la demande, importer des données, reconnaître leurs types, nettoyer sans perdre l’original, enrichir par une clé fiable, filtrer, agréger et présenter des résultats dont on sait expliquer le calcul.

## 🧭 0. Périmètre et mode d’emploi

### 0.1 Ce qui a été fourni

**Cours source.** Le ZIP `02_google_sheet.zip` contient un export Markdown du cours **#2 — Google Sheet, daté du 7 juillet 2026** : notes personnelles, trois blocs de résumé et leurs transcriptions. Il ne contient **ni slides, ni captures d’écran, ni classeur d’exercice**.

Le support couvre les sept étapes de l’analyse, les imports, le nettoyage, les dates, les recherches, les tableaux croisés dynamiques, FILTER, un aperçu de QUERY et des graphiques. Le retour de fin de journée ajoute ARRAYFORMULA et les expressions régulières.

Un résumé affirme que les graphiques n’ont pas été abordés, alors qu’une autre séquence les explique. Ce chapitre retient **les principes effectivement présents dans la transcription**, sans reconstruire une démonstration visuelle absente. Les KPI métiers et la suite du parcours seront reliés après réception du deuxième cours.

### 0.2 Les trois marqueurs de confiance

| Marqueur | Signification |
| --- | --- |
| **Cours source** | Idée ou opération présente dans les notes ou la transcription, reformulée |
| **Complément Brocode** | Explication, méthode ou exemple ajouté pour rendre le chapitre autonome |
| **Correction Brocode** | Rectification d’une erreur ou d’un raccourci technique du support |

Les données du fil rouge sont **synthétiques**. Elles permettent de refaire les opérations sans prétendre reproduire les résultats des challenges originaux.

### 0.3 Convention des formules

Les formules de référence utilisent les **noms anglais et la virgule comme séparateur d’arguments**. Elles sont écrites pour une feuille configurée en locale **États-Unis**, avec les noms de fonctions anglais. Cela rend les exemples homogènes ; ce n’est pas une obligation pour travailler en France.

Sur une feuille de locale française utilisant les noms anglais, la même formule peut nécessiter des **points-virgules**. Voir la section 2 avant de copier des formules. Les chaînes de QUERY et les motifs regex ont leur propre syntaxe : on ne remplace pas aveuglément toutes les virgules dans tout le texte.

Les blocs `text` contiennent des formules à coller dans Sheets, sans les délimiteurs Markdown. Les lettres de colonnes sont définies dans le contexte de chaque exemple.

### 0.4 Parcours de lecture

- **Comprendre avant de calculer :** sections 1 à 3.
- **Importer et préparer les données :** sections 4 à 7.
- **Enrichir, filtrer et agréger :** sections 8 à 12.
- **Restituer et fiabiliser :** sections 13 à 15.
- **Refaire un projet complet :** section 16.
- **Retrouver une formule, réviser et vérifier une correction :** sections 17 à 20.

---

## 🎯 1. Les sept étapes de l’analyse de données

### 1.1 Partir de la décision, pas de la formule

**Cours source.** Une demande métier doit être comprise avant de manipuler les données. Le point de départ n’est pas « quel graphique puis-je faire ? », mais « quelle question ce graphique aidera-t-il à traiter ? ».

| Étape | Question à poser | Livrable utile |
| --- | --- | --- |
| 1. Comprendre le besoin | Qui veut décider quoi, et à quelle échéance ? | Question reformulée et critères de réussite |
| 2. Identifier les données | Quelles informations permettent de répondre ? Où sont-elles ? | Sources, colonnes et accès nécessaires |
| 3. Choisir le type d’analyse | Besoin ponctuel ou suivi récurrent ? | Périmètre, fréquence et profondeur |
| 4. Explorer | Que représente une ligne ? Que contient chaque colonne ? | Grain, types, volumes et premières anomalies |
| 5. Nettoyer | Qu’est-ce qui empêche un calcul fiable ? | Règles de nettoyage documentées |
| 6. Transformer et calculer | Quels regroupements et mesures répondent au besoin ? | Table enrichie et résultats contrôlés |
| 7. Restituer et recommander | Que doit retenir et faire le destinataire ? | Tableau ou graphique lisible, conclusion et limites |

**Complément Brocode.** Une bonne reformulation pourrait être : « Comparer le montant des commandes enregistrées par canal d’acquisition pour juillet 2026, afin d’identifier les segments à investiguer. » Elle précise une mesure, un périmètre et une intention. Elle ne prétend pas encore calculer la rentabilité : il manquerait les coûts.

### 1.2 Analyse ponctuelle et analyse récurrente

Une analyse **one-shot** répond à une question circonscrite : pourquoi le résultat d’une campagne a-t-il changé ? On peut figer un extrait, à condition de dater l’analyse et de garder la source.

Une analyse **récurrente** doit continuer à fonctionner quand les données changent. Il faut prévoir les nouvelles lignes, les nouvelles catégories, l’actualisation de la source et la personne qui traite les erreurs. Un tableau qui fonctionne uniquement sur les 35 lignes de la démonstration n’est pas encore un dispositif récurrent.

### 1.3 Un processus itératif

```mermaid
flowchart LR
    A[Besoin métier] --> B[Sources et exploration]
    B --> C[Nettoyage]
    C --> D[Calculs et contrôles]
    D --> E[Restitution]
    E --> A
    D --> B
```

Une anomalie dans un total peut révéler une mauvaise clé de recherche. Une discussion sur le graphique peut révéler que le KPI demandé était mal défini. Revenir en arrière est une partie normale du travail.

> [!note] Correction Brocode — les chiffres oraux ne sont pas des lois
> Le formateur indique que le nettoyage peut prendre plus de 50 % du travail. C’est un repère d’expérience, pas un pourcentage universel à répéter en entretien. De même, le chiffre de « 95 % de fonctions communes entre Excel et Sheets » ne repose pas sur une mesure fournie. Les concepts se transfèrent largement ; les syntaxes et fonctionnalités doivent être vérifiées.

### 1.4 Une recommandation ne découle pas automatiquement d’un classement

Un canal avec davantage de ventes n’est pas nécessairement plus rentable. Une ville qui achète davantage peut simplement contenir davantage de clients. Une variation observée ne démontre pas sa cause.

Séparer dans la restitution : **ce que les données montrent**, **l’interprétation proposée**, **les informations manquantes** et **l’action raisonnable**. Ce réflexe sera utile bien au-delà du tableur.

---

## 🧰 2. Comprendre le tableur et ses paramètres

### 2.1 Classeur, onglet, cellule et plage

| Terme | Exemple | Sens |
| --- | --- | --- |
| Classeur | Un document Google Sheets | Contient plusieurs onglets |
| Onglet | `Raw_Orders` | Feuille à l’intérieur du classeur |
| Cellule | `C2` | Colonne C, ligne 2 |
| Plage fermée | `A2:D1000` | Rectangle borné |
| Plage ouverte | `A2:D` | Colonnes A à D à partir de la ligne 2 |
| Colonne entière | `A:A` | Inclut aussi l’en-tête et les lignes vides |
| Référence à un onglet | `Raw_Orders!A2` | Cellule A2 de cet onglet |
| Nom d’onglet avec espaces | `'Raw Orders'!A2` | Apostrophes autour du nom d’onglet |

Les colonnes d’une table portent des **noms métier** en première ligne. Les lettres A, B, C sont des coordonnées, pas une définition du sens des données.

### 2.2 Valeur, formule et format d’affichage

Une cellule peut contenir une valeur saisie ou une formule qui calcule une valeur. Son format détermine l’affichage.

- `0.25` affiché en pourcentage devient `25 %`.
- `25` affiché en pourcentage devient `2 500 %`.
- Une valeur de date peut apparaître comme un numéro si le format est numérique.
- Mettre un texte au format monétaire ne garantit pas qu’il devient un nombre.

**Complément Brocode.** Pour enquêter sur une cellule A2 :

```text
=ISNUMBER(A2)
=ISTEXT(A2)
=ISBLANK(A2)
```

Ces tests répondent à des questions différentes. Une formule retournant `""` affiche du vide, mais la cellule contient toujours une formule ; `ISBLANK` ne doit pas être interprété comme « rien ne se voit ».

### 2.3 Langue, locale et fuseau horaire : trois réglages différents

**Correction Brocode.** Passer le pays à États-Unis ne traduit pas à lui seul toute l’interface en anglais.

| Réglage | Effet principal |
| --- | --- |
| Langue du compte / de l’interface | Libellés des menus et aides |
| Langue des fonctions | Noms anglais ou localisés des fonctions |
| Locale du classeur | Conventions de dates, nombres et monnaie ; séparateurs des formules |
| Fuseau horaire du classeur | Référence temporelle du document, notamment pour les fonctions liées à la date courante |

Dans **Fichier → Paramètres**, examiner la locale et le fuseau ; l’option **Toujours utiliser les noms de fonctions en anglais** permet de conserver les noms des exemples. Ces réglages concernent le classeur partagé. Référence : [paramètres de localisation et de calcul](https://support.google.com/docs/answer/58515?hl=en).

Même fonction, deux contextes :

```text
=VLOOKUP(B2,Ref_Customers!$A$2:$C$1000,2,FALSE)
```

```text
=VLOOKUP(B2;Ref_Customers!$A$2:$C$1000;2;FALSE)
```

La seconde correspond à une locale utilisant le point-virgule **avec noms anglais conservés**. Avec noms français, `VLOOKUP` devient `RECHERCHEV` et `FALSE` devient `FAUX`.

### 2.4 Le piège des dates ambiguës

`07/08/2026` peut désigner le 7 août ou le 8 juillet. Une conversion réussie peut donc être **sémantiquement fausse**.

Pour écrire une date dans une formule de manière explicite :

```text
=DATE(2026,8,7)
```

Pour importer, connaître le format source avant de choisir les paramètres. Changer la locale après qu’une date a été mal interprétée ne restaure pas magiquement l’intention initiale. Comparer avec le texte brut, puis réimporter ou reconstruire correctement.

### 2.5 Lire les erreurs avant de les masquer

| Erreur ou symptôme | Piste prioritaire |
| --- | --- |
| Erreur d’analyse de formule | Séparateurs, guillemets, parenthèses, nom de fonction |
| `#N/A` | Recherche sans correspondance, FILTER sans résultat, extraction sans motif trouvé |
| `#REF!` | Référence invalide, résultat matriciel bloqué ou accès à autoriser, selon le message |
| `#VALUE!` | Type de donnée ou argument inadapté |
| `#DIV/0!` | Dénominateur égal à zéro ou absence de données dans certaines opérations |
| Résultat plausible mais faux | Mauvais grain, recherche approximative, date inversée, donnée oubliée |

> [!warning] Correction Brocode — les couleurs ne valident pas le calcul
> La coloration aide à repérer les références ; elle ne prouve ni la validité du résultat ni la bonne interprétation des arguments. Les espaces entre arguments ne sont pas nécessaires au moteur. Les guillemets typographiques `“ ”` peuvent provoquer une erreur de syntaxe : utiliser les guillemets droits `"` dans les formules.

---

## 🗂️ 3. Structurer la donnée avant de l’enrichir

### 3.1 Le grain : que représente une ligne ?

**Complément Brocode.** Le grain est la définition d’une ligne : une commande, un client, une ligne de commande, une visite, un jour par campagne… Sans cette définition, on ne sait pas ce que l’on compte.

Dans une table **une ligne par commande**, un client peut apparaître plusieurs fois. `COUNTA(customer_id)` compte alors des occurrences de clients dans les commandes, pas nécessairement des clients distincts.

Dans une table **une ligne par ligne produit**, `COUNTA(order_id)` ne compte plus les commandes. Une commande de trois produits peut y apparaître trois fois.

Voir [[codex/sheet/Granularité d'une table|Granularité d’une table]].

### 3.2 Une table exploitable

- Une ligne d’en-têtes, avec des noms uniques et explicites.
- Une colonne par information, avec une unité connue.
- Une ligne par observation au grain annoncé.
- Aucun sous-total manuel au milieu des données.
- Pas de cellules fusionnées dans la plage analytique.
- Des colonnes de types cohérents : une date dans la colonne date, un montant dans la colonne montant.

La mise en forme vient ensuite. Une cellule verte ou une colonne masquée ne constitue pas une règle de protection ni une indication fiable de provenance.

### 3.3 Séparer source, transformations et restitution

```text
Raw_Orders + référentiels
           ↓
      Clean_Orders
           ↓
   filtres / agrégations
           ↓
       Dashboard
```

Conserver le brut permet d’expliquer une transformation. Une colonne `company_clean` à côté de `company_raw` permet de comparer ; remplacer directement tous les noms d’origine supprime cette possibilité.

Un onglet `README` peut préciser les sources, le grain, les unités, la dernière vérification, les règles de calcul et la personne responsable. Un onglet `Params` contient les critères à modifier sans toucher aux formules.

### 3.4 Nommer proprement, sans dogme

**Cours source.** L’underscore est recommandé pour les noms techniques. **Correction Brocode.** Les espaces ne sont pas interdits partout : `company_clean` facilite une formule, tandis que « Montant des commandes (€) » convient à un graphique.

La cohérence des noms sert la compréhension. Elle ne remplace pas le contrôle des données.

---

## 📥 4. Importer : distinguer copie, lien et actualisation

### 4.1 Trois besoins différents

| Besoin | Méthode | Conséquence |
| --- | --- | --- |
| Analyser un extrait figé | Import CSV ou collage de valeurs | Snapshot à dater ; ne suit pas la source |
| Lire une plage d’un autre Google Sheets | `IMPORTRANGE` | Dépend de la source, des accès et des mises à jour |
| Lire un fichier CSV/TSV accessible par URL | `IMPORTDATA` | Dépend du contenu distant et de son accessibilité |

Un lien vers une page web affichant un fichier n’est pas toujours une URL qui sert directement le CSV. Une session navigateur connectée ne garantit pas que la fonction pourra accéder à la ressource.

### 4.2 `IMPORTRANGE` : deux arguments

```text
=IMPORTRANGE("URL_DU_CLASSEUR_SOURCE","Raw_Orders!A:H")
```

Le premier argument identifie le document ; le deuxième est une chaîne unique décrivant **onglet + `!` + plage**.

Avec un nom d’onglet contenant des espaces :

```text
=IMPORTRANGE("URL_DU_CLASSEUR_SOURCE","'Raw Orders'!A:H")
```

`URL_DU_CLASSEUR_SOURCE` est un placeholder à remplacer par un document auquel on a accès. Pour un autre onglet du **même** classeur, une référence locale suffit généralement ; inutile d’ajouter un import réseau.

### 4.3 Autoriser et laisser le résultat se déployer

**Complément Brocode.** Au premier lien entre deux documents, Sheets peut demander d’**autoriser l’accès**. Lire le message de `#REF!` avant de corriger la syntaxe.

L’import occupe un rectangle de cellules à partir de la cellule contenant la formule. Une valeur, une formule apparemment vide ou une cellule fusionnée dans ce rectangle peut empêcher le déploiement. Réserver un onglet d’accueil suffisamment grand.

Le résultat ne se modifie pas cellule par cellule comme une saisie manuelle. Pour transformer de façon maintenable, calculer dans un autre espace à partir du résultat importé. Pour une copie indépendante, faire **Collage spécial → Valeurs uniquement** et accepter qu’elle ne suivra plus la source.

### 4.4 Plage ouverte ou bornée ?

**Cours source.** `A1:H35` oublie la ligne 36 ; `A:H` inclut les lignes ultérieures du document source.

**Complément Brocode.** Une plage ouverte peut aussi transférer et recalculer beaucoup de cellules inutiles. Une plage bornée telle que `A1:H10000` est raisonnable si sa capacité est surveillée et adaptée avant saturation. On cherche une couverture explicite des données futures, avec un coût maîtrisé.

Ajouter des colonnes à droite ne les inclut pas si la plage s’arrête à H. Et une référence de plage encodée dans du texte mérite une vérification après réorganisation des colonnes de la source.

### 4.5 Délais et partage

`IMPORTRANGE` n’est pas une garantie de temps réel. La documentation spécifique décrit une vérification horaire lorsque le document est ouvert ; la page générale des paramètres mentionne 30 minutes. Ces indications ne constituent pas un engagement de synchronisation à la minute près. Les dépendances et la taille de la source peuvent retarder le résultat.

L’accès accordé relie les documents : les éditeurs de la destination peuvent utiliser l’autorisation pour importer d’autres parties de la source. Masquer une colonne ne retire ni sa valeur ni les droits d’accès. Choisir un fichier source adapté aux destinataires. Références : [IMPORTRANGE](https://support.google.com/docs/answer/3093340?hl=en), [paramètres de calcul](https://support.google.com/docs/answer/58515?hl=en).

> [!tip] Éviter les chaînes d’imports
> Si A alimente B, qui alimente C, une investigation doit suivre plusieurs étapes. Quand c’est possible, regrouper l’import dans un onglet clair et réutiliser des références locales. Pour un volume important, préparer la donnée utile en amont plutôt que multiplier les imports identiques.

### 4.6 `IMPORTDATA` : CSV ou TSV distant

La syntaxe de référence publiée par Google est :

```text
=IMPORTDATA("https://example.com/data.csv")
```

Cette URL est illustrative. Elle doit être remplacée par une URL réelle servant des données CSV ou TSV accessibles à la fonction.

> [!warning] Correction Brocode — ne pas transformer un argument non documenté en prérequis
> Le support évoque un délimiteur ajouté à `IMPORTDATA`. La documentation officielle consultée publie `IMPORTDATA(url)`, avec un seul argument. On retient cette signature pour le cours de référence, sans affirmer que toutes les formes supplémentaires observées dans certaines interfaces sont impossibles. Pour un fichier à séparateur particulier, utiliser une importation dont le séparateur peut être choisi explicitement.

Référence : [IMPORTDATA](https://support.google.com/docs/answer/3093335?hl=en).

### 4.7 Quand un CSV arrive dans une seule colonne

Un CSV est un format texte ; les champs peuvent contenir des séparateurs protégés par des guillemets. L’extension `.csv` ne suffit pas à garantir le caractère séparateur utilisé dans tous les exports.

Pour un vrai fichier, préférer **Fichier → Importer** et vérifier les options de séparateur et de conversion. **Données → Diviser le texte en colonnes** est utile pour du texte simple déjà collé, mais une découpe naïve peut mal traiter un nom contenant une virgule.

Contrôler immédiatement : nombre de colonnes, en-têtes, quelques dates ambiguës, montants décimaux, accents et identifiants avec zéros initiaux. Un identifiant `00123` n’est pas nécessairement le nombre `123`.

---

## 🧼 5. Nettoyer du texte sans changer son sens

### 5.1 `SUBSTITUTE` : remplacer une chaîne précise

```text
=SUBSTITUTE(A2," UTC","")
```

Si A2 contient `2026-07-07 14:32:05 UTC`, le résultat est le texte `2026-07-07 14:32:05`. L’espace appartient au motif supprimé. `""` signifie une chaîne vide ; `" "` contient un espace.

Signature :

```text
=SUBSTITUTE(text_to_search,search_for,replace_with,[occurrence_number])
```

Sans numéro d’occurrence, les occurrences correspondantes sont remplacées. La recherche est sensible à la casse. Cette fonction convient à une règle précise et stable, pas à une liste infinie de cas particuliers.

> [!warning] Correction Brocode — enlever « UTC » ne convertit pas un fuseau
> On a modifié un texte, pas transformé une heure UTC en heure de Paris. Ne pas ajouter mécaniquement une ou deux heures à tout l’historique : les changements saisonniers compliquent la conversion. Dans l’atelier, on conserve explicitement le jour **UTC** de la commande.

### 5.2 `LEFT`, `RIGHT` et `LEN`

| Formule | Intention |
| --- | --- |
| `=LEFT(A2,10)` | Garder les dix premiers caractères |
| `=RIGHT(A2,3)` | Garder les trois derniers caractères |
| `=LEN(A2)` | Compter les caractères, espaces compris |
| `=LEFT(A2,LEN(A2)-4)` | Retirer les quatre derniers caractères |

Le timestamp d’exemple contient **23 caractères** : 19 pour `YYYY-MM-DD hh:mm:ss`, puis espace + `UTC`. La dernière formule fonctionne si toutes les valeurs respectent ce contrat.

Si A2 vaut seulement `Acme`, la même formule retire tout. Si la valeur est plus courte, on peut obtenir un argument négatif. Avant de généraliser une découpe, vérifier longueur et suffixe sur les lignes réelles.

**Complément Brocode.** Pour ne retirer le suffixe que lorsqu’il est présent :

```text
=IF(RIGHT(A2,4)=" UTC",LEFT(A2,LEN(A2)-4),A2)
```

### 5.3 Normaliser les espaces et la casse

**Complément Brocode.** Des valeurs visuellement identiques peuvent différer à cause d’un espace final, d’un espace insécable ou de la casse.

```text
=TRIM(A2)
=LOWER(A2)
=UPPER(A2)
```

`TRIM` supprime les espaces ordinaires excédentaires ; il ne résout pas tous les caractères invisibles. Pour un espace insécable connu :

```text
=TRIM(SUBSTITUTE(A2,CHAR(160)," "))
```

Normaliser un email en minuscules peut être un choix analytique utile, mais transformer systématiquement tous les identifiants en minuscules peut supprimer une distinction voulue. La règle dépend du contrat de la donnée.

### 5.4 Noms d’entreprises et formes juridiques

**Cours source.** La fin de séance cherche à enlever plusieurs formes juridiques dans des noms. La transcription les déforme ; l’exemple suivant utilise **LLC, GmbH et Inc** comme cas pédagogiques explicites.

```text
=SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(A2," LLC","")," GmbH","")," Inc","")
```

Cette formule est facile à lire avec trois remplacements, mais elle peut retirer le motif **au milieu** d’un nom. Une entreprise dont le nom contient ` Inc` sans que ce soit le suffixe juridique peut être altérée.

Avant de choisir cette règle, décider : suppression seulement en fin ? casse ignorée ? point final autorisé ? suffixe inconnu conservé ? Le problème est d’abord un contrat de nettoyage. La section 14 propose un motif borné à la fin du texte.

### 5.5 Rechercher/remplacer manuellement ou écrire une formule ?

Un remplacement manuel peut suffire pour une correction ponctuelle contrôlée. Une formule garde la transformation visible et réapplicable aux nouvelles lignes.

Dans les deux cas, limiter la portée, vérifier des exemples avant/après et conserver la source. Une suite de remplacements réussis techniquement peut détruire un identifiant ou un nom valide.

---
## 🔗 6. Concaténer : assembler n’est pas identifier

### 6.1 Deux syntaxes équivalentes pour un cas simple

Si A2 contient `Paris` et B2 `organic` :

```text
=A2&"_"&B2
=CONCATENATE(A2,"_",B2)
```

Résultat : `Paris_organic`. Les références sont hors guillemets ; le séparateur littéral est entre guillemets.

Pour un texte destiné au lecteur :

```text
="Ville : "&A2&" — Canal : "&B2
```

Les espaces sont ici utiles à la lecture.

### 6.2 Attention aux dates et aux nombres

Concaténer une date peut afficher son numéro sous-jacent. Pour un libellé maîtrisé :

```text
="Commandes du "&TEXT(C2,"yyyy-mm-dd")
```

`TEXT` produit une chaîne destinée à l’affichage. Pour calculer ou trier chronologiquement, conserver aussi la date numérique d’origine.

### 6.3 Une clé concaténée peut entrer en collision

Sans séparateur, `1` + `23` et `12` + `3` donnent tous les deux `123`. Avec underscore, `a_b` + `c` et `a` + `b_c` donnent tous les deux `a_b_c`.

**Complément Brocode.** Une concaténation est pratique pour un libellé ou une clé sous un contrat maîtrisé. Elle ne prouve jamais à elle seule l’unicité. Si le grain dépend de plusieurs colonnes, contrôler la combinaison et sa gestion des valeurs absentes.

---

## 📅 7. Dates : convertir, extraire, comparer

### 7.1 Une date est une valeur, son écriture est un format

**Cours source.** Google Sheets représente les dates par des nombres ; la partie fractionnaire peut représenter une heure. Le passage à un affichage numérique n’est donc pas forcément une perte de date.

**Complément Brocode.** Pour un timestamp numérique, `0.5` jour correspond à 12 heures. Deux timestamps séparés d’une heure diffèrent d’environ `1/24`. Une soustraction de timestamps peut donc produire des décimales.

Trois états à distinguer :

| État | Exemple | Action |
| --- | --- | --- |
| Texte ressemblant à une date | `2026-07-07 14:32:05 UTC` | Parser selon un contrat connu |
| Date/heure numérique | Valeur reconnue par Sheets | Calculer ; choisir le format d’affichage |
| Date affichée sans heure | `07/07/2026` | Vérifier si une heure reste présente sous l’affichage |

Masquer l’heure avec un format ne la supprime pas. Un regroupement peut séparer deux instants du même jour si l’on n’a pas réellement ramené la valeur au grain journalier.

### 7.2 `DATEVALUE` et `VALUE` ne sont pas interchangeables

Pour un texte de date compris par la locale :

```text
=DATEVALUE("2026-07-07")
```

Le résultat représente une date entière. Appliquer un format Date pour le lire comme tel. `DATEVALUE` attend du texte ; l’appliquer à une cellule contenant déjà une date numérique peut donner une erreur.

Pour un texte représentant un nombre, une date ou une heure dans un format reconnu :

```text
=VALUE("123.45")
=VALUE("2026-07-07 12:00:00")
```

Dans la locale des exemples, la deuxième formule conserve la composante horaire. Les formats reconnus dépendent du contexte ; tester une valeur représentative avant de convertir une colonne entière. Références : [DATEVALUE](https://support.google.com/docs/answer/3093039?hl=en), [VALUE](https://support.google.com/docs/answer/3094220?hl=en).

### 7.3 Parser un timestamp au contrat connu

Pour A2 au format exact `YYYY-MM-DD hh:mm:ss UTC`, deux besoins :

**Conserver date et heure, sans conversion de fuseau :**

```text
=VALUE(SUBSTITUTE(A2," UTC",""))
```

Cette version dépend de la reconnaissance du texte par la locale.

**Extraire explicitement le jour UTC, indépendamment de l’ordre jour/mois local :**

```text
=DATE(VALUE(LEFT(A2,4)),VALUE(MID(A2,6,2)),VALUE(MID(A2,9,2)))
```

`MID(texte,début,longueur)` prélève ici mois et jour aux positions prévues. La formule n’analyse pas un timestamp arbitraire ; elle suppose le format annoncé.

> [!warning] Complément Brocode — une construction de date n’est pas une validation complète
> `DATE` peut normaliser des composantes hors plage. Pour des entrées incertaines, comparer par exemple `TEXT(date_calculee,"yyyy-mm-dd")` à `LEFT(texte_source,10)` après vérification du format attendu. Un texte invalide doit être signalé, pas automatiquement transformé en une autre date plausible.

### 7.4 Différence de dates et `DATEDIF`

Si B2 et C2 sont deux dates sans heure :

```text
=C2-B2
=DATEDIF(B2,C2,"D")
```

La soustraction mesure un écart en jours. `DATEDIF` sert aussi aux années et mois **complets**. Elle suppose une date de début non postérieure à la date de fin.

| Unité | Résultat |
| --- | --- |
| `"D"` | Nombre de jours |
| `"M"` | Nombre de mois complets |
| `"Y"` | Nombre d’années complètes |
| `"YM"` | Mois complets restants après retrait des années complètes |
| `"MD"` | Jours restants après retrait des mois complets |
| `"YD"` | Écart en jours sans compter les années entières |

**Correction Brocode.** Il n’existe pas d’unité `"W"` ou `"Q"` pour demander directement semaines ou trimestres à `DATEDIF`. Référence : [DATEDIF](https://support.google.com/docs/answer/6055612?hl=en).

Pour des dates sans heure et un écart positif, compter les périodes de sept jours complètes :

```text
=INT((C2-B2)/7)
```

Ce n’est pas le nombre de changements de semaine calendaire. De même, « trois mois complets » et « passage à un trimestre suivant » sont deux notions différentes.

**Exemples à refaire :**

```text
=DATEDIF(DATE(2026,7,6),DATE(2026,7,8),"D")
=DATEDIF(DATE(2026,1,31),DATE(2026,2,28),"M")
```

Résultats attendus : **2 jours**, puis **0 mois complet** selon cette règle de décompte. Pour le métier, vérifier si cette convention correspond bien au besoin, notamment aux fins de mois.

### 7.5 Extraire année, mois et jour

```text
=YEAR(A2)
=MONTH(A2)
=DAY(A2)
```

Ces fonctions attendent une date utilisable. `MONTH` retourne un numéro de mois, pas une clé temporelle complète : janvier 2025 et janvier 2026 ont tous les deux le numéro 1.

Pour une clé mensuelle conservant une vraie date :

```text
=DATE(YEAR(A2),MONTH(A2),1)
```

Afficher cette colonne en `yyyy-mm`. Le format reste lisible, et les valeurs se trient chronologiquement. Pour un libellé uniquement, `TEXT(A2,"yyyy-mm")` est possible mais produit du texte.

### 7.6 Semaines : préciser la convention

**Cours source.** `WEEKNUM` permet d’extraire un numéro de semaine pour des analyses récurrentes.

```text
=WEEKNUM(A2,2)
=ISOWEEKNUM(A2)
```

Ces deux expressions ne sont pas synonymes. Le type `2` de WEEKNUM utilise une semaine commençant lundi, mais pas nécessairement la règle ISO de numérotation. `ISOWEEKNUM` applique la convention ISO, dont la semaine 1 contient le premier jeudi de l’année. Référence : [ISOWEEKNUM](https://support.google.com/docs/answer/7368793?hl=en).

Le **1er janvier 2021** appartient à la semaine ISO **53 de 2020**. Associer aveuglément `YEAR(date)` et `ISOWEEKNUM(date)` produit alors une clé erronée.

**Complément Brocode.** Pour regrouper par semaines du lundi au dimanche, une clé simple est la date du lundi :

```text
=INT(A2)-WEEKDAY(INT(A2),2)+1
```

Cette clé traverse le changement d’année sans ambiguïté. `INT` retire ici l’heure sur les dates contemporaines de l’exercice.

### 7.7 Filtrer la semaine en cours sans mélanger les années

Dans `Params!B2`, calculer le lundi de la semaine courante :

```text
=TODAY()-WEEKDAY(TODAY(),2)+1
```

Une date appartient à cette semaine si elle est **supérieure ou égale à B2 et strictement inférieure à B2 + 7**. Ce filtre fonctionne aussi sur des timestamps, contrairement à une égalité avec une date de minuit.

Pour une analyse historique reproductible, remplacer `TODAY()` par une date d’analyse fixe stockée dans les paramètres. Une formule dynamique est utile pour le suivi courant, mais fait évoluer les résultats avec le temps.

---

## 🔎 8. Recherches : enrichir une table grâce à une clé

### 8.1 Le problème commun à toutes les fonctions

**Cours source.** On dispose d’une table principale et d’un référentiel qui contient une information à ramener.

```text
Commande 101 → client C001 → source d’acquisition organic
```

La clé partagée doit désigner **la même entité**. Deux colonnes nommées `id` peuvent être un identifiant de commande et un identifiant de client : leur nom semblable ne justifie pas une recherche.

Pour les exemples, `Ref_Customers` contient :

| A : customer_id | B : acquisition_source | C : country |
| --- | --- | --- |
| C001 | organic | FR |
| C002 | paid | FR |
| C003 | organic | FR |
| C004 | paid | FR |

La table principale contient `customer_id` en B. La colonne de recherche du référentiel doit être unique si chaque client est supposé avoir une seule ligne.

### 8.2 `VLOOKUP` : comprendre les quatre arguments

```text
=VLOOKUP(B2,Ref_Customers!$A$2:$C$1000,2,FALSE)
```

Lecture de cet exemple : chercher le client de B2 dans la **première colonne de la plage A2:C1000**, puis retourner la **deuxième colonne de cette plage**, avec une correspondance exacte.

Le `2` ne signifie pas « colonne B du classeur » en général. Dans une plage D:F, `2` désignerait E.

> [!warning] Correction Brocode — aucun argument de repli dans VLOOKUP
> Le troisième argument est l’index de colonne, obligatoire. Le quatrième indique le mode de recherche. Ajouter `""` comme prétendue valeur de remplacement dans ces positions ne gère pas correctement l’absence de correspondance.

Référence : [VLOOKUP](https://support.google.com/docs/answer/3093318?hl=en).

### 8.3 Exact et approximatif : un choix de sens

Pour une clé de client ou de commande, utiliser `FALSE`. Une clé inexistante doit être identifiée comme absente, pas remplacée par une clé voisine.

Sans quatrième argument, VLOOKUP utilise le mode approximatif. Celui-ci suppose une table de seuils triée de façon adaptée et répond à un autre besoin : affecter une tranche, par exemple. Une recherche approximative n’est pas une recherche textuelle « à peu près ressemblante ».

**Complément Brocode.** Pour des montants et des seuils 0, 100, 500, une recherche de tranche peut être pertinente. Pour `customer_id`, elle peut associer un mauvais client sans produire d’erreur visible. Le mode exact doit donc faire partie de la lecture systématique d’une formule de rapprochement.

### 8.4 Une valeur absente n’efface pas la ligne

VLOOKUP exact sans correspondance retourne `#N/A`. Pour afficher un diagnostic plus lisible :

```text
=IFNA(VLOOKUP(B2,Ref_Customers!$A$2:$C$1000,2,FALSE),"Non trouvé")
```

`IFNA` ne remplace que l’erreur `#N/A`. `IFERROR` intercepte aussi d’autres erreurs et peut donc masquer une plage cassée ou un argument incorrect. Référence : [IFNA](https://support.google.com/docs/answer/9365944?hl=en).

**Correction Brocode.** La ligne de commande est toujours là, même si la cellule enrichie est vide ou en erreur. La supprimer ou l’exclure d’un calcul est une décision supplémentaire. Dans un suivi de couverture, `Non trouvé` est souvent plus utile que `""`.

### 8.5 `XLOOKUP` : séparer recherche et résultat

```text
=XLOOKUP(B2,Ref_Customers!$A$2:$A$1000,Ref_Customers!$B$2:$B$1000,"Non trouvé",0)
```

On désigne directement la plage de clés et la plage de résultat. Elles doivent être alignées et de dimensions compatibles. Le mode `0` indique l’exact ; il est aussi le défaut.

La colonne renvoyée peut se trouver à gauche de la clé. L’appel évite un index de colonne saisi en dur ; il résiste mieux à certaines insertions de colonnes. Il faut tout de même vérifier le résultat après une réorganisation du référentiel.

Signature complète :

```text
=XLOOKUP(search_key,lookup_range,result_range,[missing_value],[match_mode],[search_mode])
```

Le dernier argument permet notamment une recherche de la première vers la dernière ligne (`1`, défaut) ou dans l’autre sens (`-1`). Choisir la dernière occurrence ne démontre pas qu’elle est la bonne version métier. Référence : [XLOOKUP](https://support.google.com/docs/answer/12405947?hl=en).

### 8.6 `INDEX` + `MATCH` : position, puis valeur

```text
=INDEX(Ref_Customers!$B$2:$B$1000,MATCH(B2,Ref_Customers!$A$2:$A$1000,0))
```

`MATCH(...,0)` recherche exactement la clé et retourne sa **position dans la plage**, pas nécessairement le numéro de ligne de l’onglet. `INDEX` récupère cette position dans la plage de résultat.

Si C003 est le troisième élément de A2:A1000, MATCH retourne `3`, et INDEX lit le troisième élément de B2:B1000, soit B4.

Pour le même traitement d’absence :

```text
=IFNA(INDEX(Ref_Customers!$B$2:$B$1000,MATCH(B2,Ref_Customers!$A$2:$A$1000,0)),"Non trouvé")
```

Le `0` de MATCH est important : ne pas compter sur un défaut adapté aux clés exactes. Références : [MATCH](https://support.google.com/docs/answer/3093378?hl=en), [INDEX](https://support.google.com/docs/answer/3098242?hl=en).

### 8.7 Choisir et comprendre les limites

| Fonction | Atout | Vigilance |
| --- | --- | --- |
| VLOOKUP | Lecture fréquente dans les fichiers existants | Première colonne de la plage ; index numérique ; exact à préciser |
| XLOOKUP | Plages explicites, résultat à gauche possible, repli intégré | Alignement des plages ; doublons non résolus par magie |
| INDEX + MATCH | Sépare position et valeur ; flexible | Deux fonctions à lire ; mode exact et alignement |

Les trois répondent à la recherche **d’une correspondance retenue**. Elles ne somment pas toutes les commandes d’un client. Pour ramener toutes ses lignes, utiliser FILTER ; pour sommer, utiliser une agrégation.

### 8.8 Les doublons du référentiel : une erreur silencieuse possible

**Cours source.** La recherche dans l’ordre courant s’arrête à la première correspondance retenue. Si C001 apparaît deux fois avec `organic` puis `paid`, obtenir `organic` ne prouve pas que le référentiel est correct.

**Complément Brocode.** Dans une colonne de contrôle de la table principale :

```text
=IF(B2="","",COUNTIF(Ref_Customers!$A$2:$A$1000,B2))
```

| Résultat | Interprétation |
| --- | --- |
| 0 | Aucune correspondance |
| 1 | Une correspondance, conforme au contrat plusieurs-vers-un |
| Plus de 1 | Ambiguïté dans le référentiel |

Contrôler aussi les blancs et les types de clés. Le texte `00123`, le nombre `123` et un texte contenant un espace final ne doivent pas être rapprochés sans décider de la normalisation correcte.

### 8.9 Le lien avec une jointure SQL

La logique ressemble à un enrichissement par clé, mais un **LEFT JOIN SQL peut multiplier les lignes** si le référentiel contient plusieurs correspondances. Une recherche scalaire peut au contraire masquer le doublon en ne renvoyant qu’une valeur.

La compétence transférable est donc : comprendre la clé, la cardinalité et le grain, puis contrôler la sortie. Ce n’est pas une équivalence parfaite de comportement. Voir [[codex/sheet/Clé de jointure et cardinalité|Clé de jointure et cardinalité]] et [[wagon2321/cours_sol/07_joins_and_testing_sol|JOINs & Testing]].

---

## 📌 9. Références et recopie : ce qui bouge, ce qui reste

### 9.1 Les quatre formes d’une référence

| Référence | Recopie à droite | Recopie vers le bas | Usage |
| --- | --- | --- | --- |
| `A2` | `B2` | `A3` | Référence relative |
| `$A$2` | `$A$2` | `$A$2` | Paramètre fixe |
| `$A2` | `$A2` | `$A3` | Colonne fixe, ligne mobile |
| `A$2` | `B$2` | `A$2` | Ligne fixe, colonne mobile |

Le `$` ne protège pas la cellule contre une modification humaine. Il contrôle le déplacement de la référence lors de la copie de la formule.

### 9.2 Une recherche recopiable

```text
=IFNA(VLOOKUP($B2,Ref_Customers!$A$2:$C$1000,2,FALSE),"Non trouvé")
```

En recopiant vers le bas, `$B2` devient `$B3`, tandis que le référentiel reste fixe. Sans verrouillage des bornes, A2:C1000 pourrait devenir A3:C1001, puis A4:C1002 : des clés situées en haut disparaîtraient progressivement de la recherche.

**Correction Brocode.** Le nombre littéral `2` ne devient pas `3` quand on tire la formule vers la droite. Pour plusieurs champs, modifier l’index explicitement ou employer une stratégie de références conçue pour ce déplacement.

### 9.3 Le double-clic ne garantit pas les futures lignes

**Cours source.** La poignée de recopie accélère l’application d’une formule. Le double-clic se base sur les données environnantes ; vérifier la dernière ligne effectivement couverte, notamment en présence de trous.

Copier jusqu’à la ligne 1000 couvre les cellules existantes sélectionnées. Cela ne garantit pas que toutes les lignes ajoutées au-delà hériteront correctement de la formule. Une solution maintenable exige une règle d’extension ou une formule matricielle adaptée.

### 9.4 `ARRAYFORMULA` : calculer sur une plage

**Cours source.** Remplacer une référence unique par une plage permet, pour les opérations compatibles, d’appliquer la logique à plusieurs lignes.

Si A contient la clé, E la quantité et F le prix unitaire :

```text
=ARRAYFORMULA(IF(A2:A1000="","",E2:E1000*F2:F1000))
```

Déposer la formule une seule fois en haut d’une colonne vide. Elle calcule quantité × prix sur les lignes renseignées. Les trois plages ont la même hauteur.

Pour une recherche vectorisée :

```text
=ARRAYFORMULA(IF(B2:B1000="","",IFNA(VLOOKUP(B2:B1000,Ref_Customers!$A$2:$C$1000,2,FALSE),"Non trouvé")))
```

> [!note] Correction Brocode — ARRAYFORMULA n’est pas un bouton universel
> Toutes les fonctions ne deviennent pas automatiquement des traitements ligne par ligne simplement parce qu’on les entoure d’ARRAYFORMULA. Certaines, comme FILTER, renvoient déjà un tableau. Tester le comportement de l’opération utilisée, et ne pas empiler une formule matricielle sur des cellules déjà remplies.

Référence : [ARRAYFORMULA](https://support.google.com/docs/answer/3093275?hl=en).

### 9.5 Vide calculé et compteurs

Le garde-fou `IF(A2:A1000="","",...)` évite de produire des calculs parasites sur les lignes sans clé. Mais les cellules résultant en `""` ne doivent pas être assimilées sans vérification à des cellules matériellement vides.

Pour compter une population, utiliser une clé maîtrisée et un filtre explicite sur les lignes utiles. Ne pas compter une colonne préremplie de formules avec COUNTA en supposant que seuls les résultats visibles seront pris en compte.

---
## 🎛️ 10. Filtrer : trois mécanismes à distinguer

### 10.1 Filtre d’interface, vue filtrée et fonction FILTER

| Mécanisme | Résultat | Usage |
| --- | --- | --- |
| Filtre dans l’interface | Masque des lignes dans l’affichage du tableau | Exploration rapide |
| Vue filtrée | Vue enregistrée ou temporaire pour une exploration particulière | Travailler avec des critères sans imposer la même vue à tous |
| `FILTER(...)` | Produit un nouveau tableau à partir de conditions | Alimenter une analyse dérivée et dynamique |

**Correction Brocode.** Le filtre ordinaire n’est pas nécessairement privé. Les vues filtrées sont le mécanisme prévu pour des lectures différentes simultanées. Et masquer des lignes ne les supprime pas de la source : un `SUM` ordinaire sur la plage ne devient pas automatiquement une somme des seules lignes visibles. Référence : [filtres et vues filtrées](https://support.google.com/docs/answer/3540681?hl=en).

### 10.2 Repères du fil rouge utilisé ci-dessous

La section 16 construit entièrement `Clean_Orders`. Les colonnes utiles aux exemples sont :

| Colonne | Contenu |
| --- | --- |
| A | `order_id`, une commande par ligne |
| B | `customer_id` |
| D | `city` |
| E | `quantity` |
| I | `order_date_utc`, date numérique sans heure |
| K | `month_start`, date du premier jour du mois |
| L | `week_start`, date du lundi |
| M | `acquisition_source` |
| O | `revenue_eur`, quantité × prix de cet exercice |
| Q | `email_domain` |

Les données occupent les lignes 2 à 7 au départ ; les formules prévoient jusqu’à 1000. Les exemples FILTER sont à placer dans un onglet de sortie libre, avec les en-têtes copiés séparément sur sa première ligne.

### 10.3 Une condition, puis plusieurs conditions

```text
=FILTER(Clean_Orders!A2:S1000,Clean_Orders!A2:A1000<>"",Clean_Orders!D2:D1000="Paris")
```

La première condition élimine les lignes sans clé ; la deuxième retient Paris. Les différentes conditions séparées par des virgules sont combinées par un **ET**.

```text
=FILTER(Clean_Orders!A2:S1000,Clean_Orders!A2:A1000<>"",Clean_Orders!D2:D1000="Paris",Clean_Orders!M2:M1000="organic")
```

Chaque ligne doit ici être renseignée, appartenir à Paris et avoir le canal organic.

**Complément Brocode.** Pour Paris **OU** Lyon :

```text
=FILTER(Clean_Orders!A2:S1000,Clean_Orders!A2:A1000<>"",((Clean_Orders!D2:D1000="Paris")+(Clean_Orders!D2:D1000="Lyon"))>0)
```

La somme des deux comparaisons permet de tester si au moins une condition est vraie. Les parenthèses rendent le raisonnement explicite.

### 10.4 Critères dynamiques

Dans `Params!B3`, écrire le canal souhaité ; dans `Params!B4`, la ville. On peut ensuite remplacer les constantes :

```text
=FILTER(Clean_Orders!A2:S1000,Clean_Orders!A2:A1000<>"",Clean_Orders!M2:M1000=Params!$B$3,Clean_Orders!D2:D1000=Params!$B$4)
```

**Cours source.** Brancher la condition sur une cellule permet de faire varier une analyse sans réécrire sa formule. Une liste déroulante peut limiter les erreurs de saisie.

**Complément Brocode.** Pour créer une liste de canaux existants dans une zone dédiée :

```text
=SORT(UNIQUE(FILTER(Clean_Orders!M2:M1000,Clean_Orders!A2:A1000<>"")))
```

Utiliser ensuite cette plage comme source d’une liste déroulante via la validation des données. Cette liste décrit les valeurs présentes, pas forcément toutes les catégories possibles du métier.

### 10.5 Filtrer une période

Avec `Params!B2` contenant un lundi :

```text
=FILTER(Clean_Orders!A2:S1000,Clean_Orders!A2:A1000<>"",Clean_Orders!I2:I1000>=Params!$B$2,Clean_Orders!I2:I1000<Params!$B$2+7)
```

La borne de fin exclusive évite d’oublier les heures du dernier jour si la colonne contient plus tard des timestamps. La même logique s’applique à un mois : début inclus, début du mois suivant exclu.

### 10.6 Aucun résultat et dimensions incompatibles

FILTER sans ligne correspondante retourne `#N/A`. Pour une restitution isolée, on peut afficher un message :

```text
=IFNA(FILTER(Clean_Orders!A2:S1000,Clean_Orders!A2:A1000<>"",Clean_Orders!D2:D1000="Bordeaux"),"Aucune ligne")
```

Ce résultat est alors une cellule de texte, pas un tableau vide de 19 colonnes. Si un TCD ou QUERY dépend de cette sortie, prévoir le cas vide sans introduire le message dans les données métier. Et IFNA peut aussi masquer un `#N/A` déjà présent dans la chaîne : inspecter la formule sans repli pendant le diagnostic.

La plage filtrée et chaque condition doivent avoir des longueurs compatibles. `A2:S1000` et `D:D` ne démarrent pas au même endroit et n’ont pas la même hauteur. Référence : [FILTER](https://support.google.com/docs/answer/3093197?hl=en).

---

## 📊 11. Tableaux croisés dynamiques : choisir une agrégation correcte

### 11.1 Ce qu’un TCD transforme

**Cours source.** Le tableau croisé dynamique, ou **pivot table**, synthétise une table selon une ou plusieurs dimensions.

Avant : une ligne par commande. Après regroupement par canal : une ligne par canal. On a changé le grain.

| Élément du TCD | Question |
| --- | --- |
| Lignes | Quels groupes afficher verticalement ? |
| Colonnes | Quelle deuxième dimension déplier horizontalement ? |
| Valeurs | Quelles mesures et quelles agrégations calculer ? |
| Filtres | Quelle population inclure ? |

Le TCD ne découvre pas tout seul que les nombres de la colonne `order_id` sont des identifiants à compter plutôt que des quantités à sommer.

### 11.2 Construire un premier TCD

1. Vérifier les en-têtes et la plage source de `Clean_Orders`.
2. Sélectionner `Clean_Orders!A1:S1000`.
3. Utiliser **Insertion → Tableau croisé dynamique** et une nouvelle feuille.
4. Ajouter `acquisition_source` dans **Lignes**.
5. Ajouter `order_id` dans **Valeurs**, résumé par **COUNT** pour les identifiants numériques de l’exercice.
6. Ajouter `revenue_eur` dans **Valeurs**, résumé par **SUM**.
7. Ajouter un filtre pour ne garder que les `order_id` renseignés si une catégorie vide apparaît.

Renommer l’onglet `Pivot_Channel` et les mesures de manière lisible. Les libellés de l’interface peuvent être traduits. Référence : [créer et utiliser un TCD](https://support.google.com/docs/answer/1272900?hl=en).

### 11.3 COUNT, COUNTA, somme et moyenne

| Agrégat | Ce qu’il fait | Risque courant |
| --- | --- | --- |
| COUNT | Compte les valeurs numériques | Ignore les identifiants texte |
| COUNTA | Compte les valeurs non vides au sens de la fonction | Ne compte pas les entités distinctes ; peut compter du vide calculé |
| SUM | Additionne les valeurs numériques | Additionner un identifiant n’a généralement pas de sens |
| AVERAGE | Moyenne des valeurs numériques | Ignore les absences plutôt que de les traiter comme zéro |
| MIN / MAX | Valeur extrême | Un maximum n’est pas une moyenne ni une somme |

Une date numérique peut être comptée par COUNT. Une valeur `"100"` restée en texte peut ne pas participer à une somme comme prévu. Vérifier le type avant de changer d’agrégateur pour « faire marcher » le TCD.

### 11.4 Commandes et clients distincts

Dans le fil rouge, C001 a deux commandes. On a six commandes mais cinq identifiants clients distincts présents, dont C999 absent du référentiel.

Pour compter les identifiants clients distincts présents dans les commandes :

```text
=COUNTUNIQUE(FILTER(Clean_Orders!B2:B1000,Clean_Orders!A2:A1000<>"",Clean_Orders!B2:B1000<>""))
```

Ce résultat ne signifie pas automatiquement « cinq clients validés » ou « cinq nouveaux clients ». Ce sont cinq clés distinctes dans cette population. La création d’un client, son activité et sa présence dans le référentiel sont des définitions différentes.

### 11.5 Temps : ne pas fusionner tous les mois de janvier

**Cours source.** Les options année-mois ou année-trimestre évitent de mélanger des années différentes. Un regroupement par mois seul peut être souhaité pour étudier une saisonnalité, mais doit être annoncé comme tel.

**Complément Brocode.** La colonne `month_start` de l’atelier contient le premier jour de chaque mois. La placer en lignes, avec un format `yyyy-mm`, fournit une clé chronologique explicite et facile à vérifier.

Pour une analyse par canal puis par mois, l’ordre des champs en lignes détermine la hiérarchie de lecture. La mesure reste la même si le périmètre est identique, mais sa présentation peut aider ou gêner la décision.

### 11.6 Ratios : agréger avant de diviser

Supposons deux campagnes, uniquement pour illustrer la pondération :

| Campagne | Conversions | Visites | Taux |
| --- | --- | --- | --- |
| A | 10 | 100 | 10 % |
| B | 20 | 1 000 | 2 % |

La moyenne simple des taux vaut 6 %. Le taux global vaut :

```text
=(10+20)/(100+1000)
```

Soit environ **2,73 %**. Chaque visite a le même poids dans le taux global ; chaque campagne a le même poids dans la moyenne simple. Ce ne sont pas les mêmes questions.

Voir [[codex/sheet/Aggregate before divide|Aggregate before divide]]. Les définitions de KPI seront approfondies avec le deuxième cours ; ici, le point est de choisir le bon calcul.

### 11.7 Champs calculés et option Custom

**Cours source.** Un champ calculé permet de construire un ratio dans le TCD.

**Complément Brocode.** Pour notre grain commande et notre clé numérique obligatoire, un montant moyen par commande peut s’écrire dans un champ calculé :

```text
=SUM(revenue_eur)/COUNT(order_id)
```

Choisir **Custom / Personnalisé** comme mode de synthèse pour cette formule agrégée. Le calcul doit utiliser les noms exacts des champs source.

> [!warning] Correction Brocode — Custom n’est pas le format Pourcentage
> Le mode **Custom** détermine la façon de calculer le champ. Le **format numérique** détermine son affichage. Un ratio correct peut être affiché en nombre ou en pourcentage ; changer le format ne répare pas une moyenne de ratios incorrecte.

Pour commencer, une division à côté de deux totaux connus est parfois plus facile à vérifier. Si le TCD change de structure, les références positionnelles peuvent devenir fragiles ; contrôler leur stabilité. Le cours ne développe pas ici toute la syntaxe de GETPIVOTDATA.

### 11.8 Zéro, inconnu et division impossible

Avec revenu agrégé en C2 et nombre de commandes en B2 :

```text
=IF(B2=0,"",C2/B2)
```

Le choix de `""` signifie « pas de ratio affiché ». Il ne dit pas que le panier vaut zéro. Un dénominateur absent et un résultat nul ne sont pas équivalents.

Sur un tableau métier, documenter si l’on affiche vide, `N/A` ou un statut séparé, et éviter d’introduire des messages texte dans une série numérique destinée à un graphique.

### 11.9 Actualisation et plage source

Un TCD se met à jour quand ses cellules source changent, mais une nouvelle ligne située **hors de la plage source** n’appartient pas soudain au TCD. Vérifier l’extension de la plage, les filtres et les nouvelles catégories.

Le mot « dynamique » ne garantit ni la fraîcheur de l’import ni la couverture de toutes les lignes. Contrôler au minimum le total général par rapport à la table enrichie.

---

## 🧮 12. QUERY : une première lecture du langage de requête

### 12.1 Ce qui est au programme ici

**Cours source.** QUERY est présentée comme puissante mais secondaire pour un débutant : elle permet de sélectionner, filtrer, trier et agréger. On apprend à lire des exemples utiles, sans transformer ce chapitre en cours SQL complet.

```text
=QUERY(data,query,[headers])
```

`data` est la plage ; `query` est le texte de la requête ; `headers` indique le **nombre de lignes d’en-têtes à l’entrée**. Pour `A1:S1000` avec une ligne de noms, utiliser `1`. Ce paramètre n’est pas un booléen demandant simplement de montrer ou cacher l’en-tête de sortie.

La fonction utilise le **Google Visualization API Query Language**, proche de SQL mais distinct de BigQuery SQL. Référence : [QUERY](https://support.google.com/docs/answer/3093343?hl=en).

### 12.2 Sélectionner et filtrer

```text
=QUERY(Clean_Orders!A1:S1000,"select A,B,D,O where A is not null and D = 'Paris'",1)
```

Cette formule choisit commande, client, ville et montant pour Paris. Les doubles guillemets entourent la requête Sheets ; les apostrophes délimitent le texte `Paris` dans cette requête.

Un nombre s’écrit sans apostrophes :

```text
=QUERY(Clean_Orders!A1:S1000,"select A,D,O where A is not null and O >= 50 order by O desc",1)
```

Avec une plage de feuille directe, les identifiants des colonnes sont leurs lettres. Sur certaines expressions matricielles, la notation `Col1`, `Col2` est utilisée. Les intitulés métier ne remplacent pas automatiquement les lettres de colonne.

### 12.3 Agréger le même résultat que le TCD

```text
=QUERY(Clean_Orders!A1:S1000,"select M,count(A),sum(O) where A is not null group by M order by M label count(A) 'orders_count',sum(O) 'revenue_eur'",1)
```

Le regroupement est défini par M, le canal. Les autres valeurs sélectionnées sont agrégées. `label` renomme les colonnes de sortie.

**Complément Brocode.** Calculer le même tableau par TCD et QUERY est un exercice de contrôle utile : si les totaux divergent, chercher une différence de plage, de filtre, de type ou d’agrégation.

### 12.4 Ce qu’il ne faut pas importer aveuglément depuis SQL

La plage `data` joue déjà le rôle de source : on n’ajoute pas de `FROM Clean_Orders` dans la chaîne. Le langage ne fournit pas toute la grammaire SQL, notamment pas un `JOIN` SQL général ni `SELECT DISTINCT` à recopier tel quel.

Pour une liste distincte, utiliser simplement :

```text
=UNIQUE(FILTER(Clean_Orders!D2:D1000,Clean_Orders!A2:A1000<>""))
```

Référence de syntaxe : [Google Visualization Query Language](https://developers.google.com/chart/interactive/docs/querylanguage).

### 12.5 Les types mixtes peuvent faire disparaître des valeurs du calcul

La documentation QUERY précise qu’une colonne de types mixtes est interprétée selon son type majoritaire ; les types minoritaires peuvent devenir des valeurs nulles pour la requête.

Si O contient des nombres et quelques montants texte, une somme peut donc être incomplète sans que la formule semble cassée. La solution est de nettoyer et contrôler la colonne **avant** l’agrégation, puis de comparer les totaux.

### 12.6 Garder les paramètres simples

Un critère dynamique peut être intégré à une chaîne QUERY, mais cela ajoute des niveaux de guillemets et des cas à gérer si la valeur contient une apostrophe. Pour les critères interactifs du premier cours, FILTER relié à une cellule est souvent plus facile à maintenir.

Il ne faut pas changer d’outil uniquement pour raccourcir une formule. Choisir une expression que l’on peut expliquer et diagnostiquer.

---

## 📈 13. Graphiques : représenter un résultat déjà compris

### 13.1 Partir d’une table de synthèse vérifiée

**Cours source.** Le formateur montre des réglages de graphiques, insiste sur les séries choisies et sur la lisibilité. La pratique permet de retrouver les options, mais le bon point de départ reste la question analytique.

| Question | Représentation simple |
| --- | --- |
| Quel canal totalise le plus de montant ? | Barres ou colonnes par canal |
| Comment le montant évolue-t-il dans le temps ? | Courbe sur des dates triées |
| Comment se répartit une population entre quelques catégories ? | Barres ; éventuellement secteurs pour une composition simple |
| Où se situent deux mesures quantitatives l’une par rapport à l’autre ? | Nuage de points si chaque point a un sens défini |

Les deux dernières propositions sont des **compléments Brocode**, pas un inventaire des graphiques démontrés à l’écran.

### 13.2 Créer et vérifier le graphique

1. Sélectionner les catégories et la mesure agrégée, sans le total général si celui-ci ferait doublon.
2. Choisir **Insertion → Graphique**.
3. Dans la configuration, vérifier la plage, l’axe des catégories et chaque série.
4. Retirer les séries ajoutées automatiquement mais inutiles, notamment les identifiants.
5. Dans la personnalisation, préciser titre, unités, légende et éventuellement étiquettes.
6. Comparer les valeurs au tableau source.

Un graphique créé directement sur des commandes ne doit pas être confondu avec un graphique de ventes déjà agrégées par canal. Vérifier ce que chaque barre ou chaque point représente.

### 13.3 Mélanger euros et pourcentages

Une série allant de 0 à 1 peut paraître écrasée à côté de montants de plusieurs centaines sur le même axe. Le format `%` ne change pas l’échelle numérique sous-jacente.

**Complément Brocode.** Deux graphiques séparés sont souvent plus faciles à lire. Un axe secondaire peut servir dans certains cas, mais ses unités et sa lecture doivent être explicites ; il peut suggérer visuellement une relation qui dépend surtout du choix des échelles.

### 13.4 Trois séries et cinq secondes : des repères, pas des critères absolus

**Cours source.** Le formateur recommande de limiter les séries et de faire comprendre le message rapidement.

**Correction Brocode.** « Maximum trois séries » et « compréhension en cinq secondes » sont des heuristiques de lisibilité, pas des règles mathématiques. Un graphique plus complexe peut être justifié pour un public expert. Inversement, un graphique très simple peut être trompeur.

Faire relire le visuel par quelqu’un qui ne connaît pas le fichier. Vérifier s’il identifie la population, la période, les unités et le message principal. Une question de sa part n’est pas automatiquement un échec ; elle peut révéler une légende ou une définition à améliorer.

### 13.5 Titre, contexte et conclusion

« Revenue by channel » nomme des axes. « Montant des commandes enregistrées par canal — juillet 2026 » précise davantage le périmètre. Ajouter la devise et expliquer le traitement des canaux inconnus.

Dans le fil rouge, une barre `Non trouvé` n’est pas du bruit à cacher : elle représente un défaut de couverture du référentiel. La restitution peut annoncer à la fois les résultats disponibles et cette limite.

---

## 🧩 14. Expressions régulières : tester, extraire ou remplacer

### 14.1 Trois fonctions, trois résultats

| Fonction Sheets | Intention | Type de résultat |
| --- | --- | --- |
| `REGEXMATCH` | Le motif est-il présent ? | TRUE / FALSE |
| `REGEXEXTRACT` | Quel texte correspond au motif ? | Texte extrait ; `#N/A` sans correspondance |
| `REGEXREPLACE` | Remplacer les portions correspondant au motif | Texte modifié |

> [!warning] Correction Brocode — ne pas confondre Sheets et BigQuery
> Le résumé mentionne `REGEXCONTAINS`. Dans Google Sheets, la fonction du test de motif est `REGEXMATCH`. `REGEXP_CONTAINS` est notamment un nom du SQL BigQuery, pas la formule Sheets à recopier ici.

Pour **enlever** un suffixe, utiliser une logique de remplacement. REGEXEXTRACT peut extraire la partie que l’on veut garder avec un motif adapté, mais ce n’est pas un remplacement et son cas « aucun motif » doit être traité.

Références : [REGEXMATCH](https://support.google.com/docs/answer/3098292?hl=en), [REGEXEXTRACT](https://support.google.com/docs/answer/3098244?hl=en), [REGEXREPLACE](https://support.google.com/docs/answer/3098245?hl=en).

### 14.2 Extraire un domaine d’email

Pour l’email texte de H2 :

```text
=IF(H2="","",LOWER(REGEXEXTRACT(TRIM(H2),"@([^@ ]+)$")))
```

Le groupe entre parenthèses capture ce qui suit `@`, jusqu’à la fin, sans autre `@` ni espace. Pour `alice@gmail.com`, il renvoie `gmail.com`.

**Complément Brocode.** Ce motif sert à extraire un domaine dans un jeu propre ; il ne valide pas toute la syntaxe possible d’une adresse email. Un email malformé doit être identifié plutôt que confondu automatiquement avec une valeur vide.

### 14.3 Supprimer seulement un suffixe juridique reconnu

```text
=TRIM(REGEXREPLACE(A2,"(?i)\s+(LLC|GmbH|Inc)\.?\s*$",""))
```

| Élément | Sens dans cet exemple |
| --- | --- |
| `(?i)` | Ignorer la casse |
| `\s+` | Au moins un espace ou caractère d’espacement avant le suffixe |
| `(LLC\|GmbH\|Inc)` | Une des trois alternatives |
| `\.?` | Un point final facultatif |
| `\s*` | Éventuels espaces après le suffixe |
| `$` | Fin du texte |

Ces antislashs sont à conserver tels quels dans la formule Sheets. Les barres verticales du tableau sont échappées uniquement pour le rendu Markdown ; la formule complète au-dessus est celle à copier.

| Entrée | Sortie attendue |
| --- | --- |
| `Acme LLC` | `Acme` |
| `Beta GmbH` | `Beta` |
| `Gamma Inc.` | `Gamma` |
| `Acme llc` | `Acme` |
| `Inc Factory` | `Inc Factory` |
| `Delta SAS` | `Delta SAS` |

La règle ne supprime que **ces trois suffixes reconnus en fin de texte**. Elle ne résout pas toutes les formes juridiques mondiales, ni les chaînes empilant plusieurs suffixes. Conserver le nom brut et ajuster le contrat au besoin réel.

### 14.4 Ne pas transformer le cours en catalogue de regex

Sheets utilise RE2 pour les expressions régulières, avec des limitations documentées. Une expression trouvée pour un autre moteur peut ne pas être compatible.

Avant une regex longue, écrire quelques couples entrée/sortie attendus, dont des cas à ne pas modifier. Un motif plus sophistiqué n’est utile que s’il améliore la précision de la règle et reste maintenable.

---

## ⚙️ 15. Fiabilité, performance et actualisation

### 15.1 Les quatre conditions d’un tableau réellement actualisable

```text
Source effectivement mise à jour
          ↓
Import qui récupère cette mise à jour
          ↓
Transformations couvrant les nouvelles lignes
          ↓
TCD / graphique couvrant le résultat transformé
```

Si un seul maillon reste figé, l’apparence dynamique du tableau ne suffit pas. Ajouter une ligne test est un contrôle simple et très utile.

### 15.2 Recalcul, import et planification

| Mécanisme | Question traitée |
| --- | --- |
| Recalcul d’une formule locale | La sortie suit-elle ses cellules d’entrée ? |
| Fonction d’import | Les données du document ou de l’URL distante ont-elles été récupérées ? |
| TCD | Les cellules source incluses ont-elles été réagrégées ? |
| Connecteur ou automatisation planifiée | Quel outil déclenche la collecte ou la mise à jour à l’heure voulue ? |

**Correction Brocode.** Il n’existe pas un réglage universel de planification qui transforme toutes les fonctions du cours en jobs quotidiens fiables. Connected Sheets et certains connecteurs ont leurs propres possibilités ; Apps Script peut également servir à déclencher des opérations. Leur configuration détaillée est hors du premier cours.

Pour un besoin « chiffre définitif chaque lundi à 8 h », identifier la source, le déclencheur, le délai de collecte et la gestion des échecs. `TODAY()` dans une cellule ne résout pas à lui seul cette demande.

### 15.3 Limites de Sheets : raisonner en cellules et en calculs

Google documente une limite de **10 millions de cellules** et jusqu’à **18 278 colonnes** pour un classeur Sheets. Ce plafond ne garantit pas que tout classeur de cette taille sera agréable à utiliser. Référence : [limites des fichiers Google Drive](https://support.google.com/drive/answer/37603?hl=en).

**Correction Brocode.** Les 50 000–100 000 lignes citées dans le cours sont un ordre de grandeur d’expérience, pas une limite dure universelle. La performance dépend aussi du nombre de colonnes, des recherches, des imports, des formules volatiles et des dépendances.

Réduire des plages inutiles, importer une fois puis référencer localement, et agréger en amont peut aider. Quand les besoins de volume, de traçabilité ou d’exploitation dépassent le tableur, utiliser une base ou un entrepôt. Voir [[wagon2321/cours_sol/05_intro_sql_relational_databases_bigquery_sol|SQL et BigQuery]] et [[wagon2321/cours_sol/10_data_pipelines_views_tables_sol|Data Pipelines, Views & Tables]].

### 15.4 Contrôles minimum avant partage

- Le nombre de lignes correspond au périmètre prévu.
- La clé du grain est renseignée et unique si le contrat l’exige.
- Les clés de recherche trouvent exactement une correspondance, ou les exceptions sont visibles.
- Les dates sont numériques et correspondent au texte source.
- Les montants ont la bonne unité et ne sont pas restés en texte.
- Les totaux se réconcilient entre source, table enrichie, TCD et graphique.
- Les ratios ont un dénominateur défini et un traitement explicite de zéro.
- Une nouvelle ligne traverse toute la chaîne jusqu’à la restitution.

Ce ne sont pas des tests de perfection absolue. Ce sont des contrôles choisis pour les erreurs les plus probables du fichier.

---
## 🛠️ 16. Atelier complet : des commandes brutes au tableau de synthèse

### 16.1 Objectif et contrat des données

**Complément Brocode — atelier autonome.** Reconstituer les opérations du cours sur un petit jeu contrôlable à la main. Ce n’est pas le corrigé du challenge original.

**Question :** quel montant de commandes est enregistré par canal d’acquisition, et quelle part reste sans canal connu ?

**Grain :** une ligne par commande. Pour simplifier l’exercice, chaque commande a une quantité et un seul prix unitaire applicable à cette quantité. Dans une vraie table de plusieurs produits par commande, il faudrait d’abord traiter les lignes produit.

**Mesure :** `revenue_eur = quantity × unit_price_eur`. Aucun calcul de TVA, remise, frais, remboursement ou statut de paiement n’est ajouté. Le nom de colonne est une convention de l’exercice ; il ne constitue pas une définition comptable du chiffre d’affaires.

### 16.2 Créer les onglets

```text
Raw_Orders
Ref_Customers
Ref_Cities
Clean_Orders
Params
Filtered_Orders
Query_Channel
Pivot_Channel
Dashboard
Checks
```

Configurer la locale États-Unis et conserver les fonctions anglaises pour copier exactement les formules. Le jour analysé sera le jour **UTC** écrit dans la source. Les prix sont en euros malgré la locale : appliquer explicitement le format monétaire EUR lorsque nécessaire.

La borne de capacité de cet atelier est **la ligne 1000**. Elle doit être augmentée dans toute la chaîne si le jeu la dépasse.

### 16.3 Données à coller dans `Raw_Orders!A1`

Le bloc ci-dessous est séparé par des tabulations. Il contient huit colonnes A à H. Si le collage ne les sépare pas, choisir la tabulation comme séparateur. Vérifier que les timestamps avec `UTC` restent du texte et que les quantités/prix sont numériques.

```text
order_id	customer_id	ordered_at_text	city	quantity	unit_price_eur	company_raw	email
101	C001	2026-07-06 10:00:00 UTC	Paris	2	20	Acme LLC	alice@gmail.com
102	C002	2026-07-06 11:30:00 UTC	Lyon	1	100	Beta GmbH	bob@yahoo.com
103	C001	2026-07-07 09:00:00 UTC	Paris	3	20	Acme LLC	alice@gmail.com
104	C003	2026-07-07 15:45:00 UTC	Lille	1	40	Gamma Inc.	chloe@gmail.com
105	C004	2025-01-07 08:00:00 UTC	Lyon	2	30	Delta SAS	david@yahoo.com
106	C999	2026-07-08 12:00:00 UTC	Nice	1	80	Epsilon LLC	elise@example.com
```

Deux particularités sont volontaires : une commande de janvier 2025 pour ne pas supposer une seule année, et le client C999 absent du référentiel.

### 16.4 Référentiels à coller en A1

**Dans `Ref_Customers` :**

```text
customer_id	acquisition_source	country
C001	organic	FR
C002	paid	FR
C003	organic	FR
C004	paid	FR
```

**Dans `Ref_Cities` :**

```text
city	region
Paris	Île-de-France
Lyon	Auvergne-Rhône-Alpes
Lille	Hauts-de-France
Nice	Provence-Alpes-Côte d'Azur
```

La ville sert ici de clé parce que ce petit référentiel est défini ainsi. Dans un projet réel, des villes homonymes imposeraient un identifiant géographique plus précis.

### 16.5 Créer la table enrichie

Copier **les huit en-têtes** de Raw_Orders vers `Clean_Orders!A1:H1`. En `Clean_Orders!A2` :

```text
=IF(Raw_Orders!$A2="","",Raw_Orders!A2)
```

Recopier de A2 à H2, puis jusqu’à la ligne 1000. La référence `$A2` vérifie toujours la présence de la clé de la ligne, tandis que la valeur à recopier passe de A à B, C… H. Les lignes sans commande affichent vide.

Ajouter les en-têtes suivants de I1 à S1 :

```text
order_date_utc	year	month_start	week_start	acquisition_source	region	revenue_eur	company_clean	email_domain	order_id_occurrences	customer_matches
```

Chaque formule ci-dessous est à placer dans la cellule indiquée puis recopier **vers le bas jusqu’à la ligne 1000**, sauf si l’on choisit explicitement l’alternative ARRAYFORMULA plus loin.

**I2 — jour UTC reconstruit à partir du format source connu :**

```text
=IF($A2="","",DATE(VALUE(LEFT(C2,4)),VALUE(MID(C2,6,2)),VALUE(MID(C2,9,2))))
```

**J2 — année :**

```text
=IF($A2="","",YEAR(I2))
```

**K2 — mois de regroupement :**

```text
=IF($A2="","",DATE(YEAR(I2),MONTH(I2),1))
```

**L2 — lundi de la semaine :**

```text
=IF($A2="","",I2-WEEKDAY(I2,2)+1)
```

**M2 — canal d’acquisition :**

```text
=IF($A2="","",XLOOKUP(B2,Ref_Customers!$A$2:$A$1000,Ref_Customers!$B$2:$B$1000,"Non trouvé",0))
```

**N2 — région :**

```text
=IF($A2="","",IFNA(VLOOKUP(D2,Ref_Cities!$A$2:$B$1000,2,FALSE),"Non trouvé"))
```

**O2 — montant de commande en euros :**

```text
=IF($A2="","",E2*F2)
```

**P2 — nom d’entreprise nettoyé :**

```text
=IF($A2="","",TRIM(REGEXREPLACE(G2,"(?i)\s+(LLC|GmbH|Inc)\.?\s*$","")))
```

**Q2 — domaine de l’email :**

```text
=IF($A2="","",IF(H2="","",LOWER(REGEXEXTRACT(TRIM(H2),"@([^@ ]+)$"))))
```

**R2 — nombre d’occurrences de la commande :**

```text
=IF($A2="","",COUNTIF($A$2:$A$1000,A2))
```

**S2 — nombre de correspondances client :**

```text
=IF($A2="","",COUNTIF(Ref_Customers!$A$2:$A$1000,B2))
```

Mettre I et L au format Date ; K au format année-mois ; J, R et S en nombres entiers ; O en montant EUR. Le format ne modifie pas les calculs.

**Alternative pour O uniquement :** laisser O2:O1000 vide, puis déposer en O2 :

```text
=ARRAYFORMULA(IF(A2:A1000="","",E2:E1000*F2:F1000))
```

Ne pas conserver en même temps cette formule et les formules O3:O1000 issues de la recopie. Ce sont deux méthodes alternatives.

### 16.6 Résultat détaillé attendu

| order_id | Date UTC | Canal | Montant EUR | Nom nettoyé | Correspondances client |
| --- | --- | --- | --- | --- | --- |
| 101 | 2026-07-06 | organic | 40 | Acme | 1 |
| 102 | 2026-07-06 | paid | 100 | Beta | 1 |
| 103 | 2026-07-07 | organic | 60 | Acme | 1 |
| 104 | 2026-07-07 | organic | 40 | Gamma | 1 |
| 105 | 2025-01-07 | paid | 60 | Delta SAS | 1 |
| 106 | 2026-07-08 | Non trouvé | 80 | Epsilon | 0 |

Toutes les valeurs de R sont égales à 1. C001 peut apparaître deux fois en B sans violer le grain commande. Le lundi de la commande 105 est le **6 janvier 2025** ; celui des autres commandes est le **6 juillet 2026**.

### 16.7 Construire les paramètres

Dans `Params`, saisir :

| Cellule A | Libellé | Cellule B | Valeur ou formule |
| --- | --- | --- | --- |
| A1 | `analysis_date` | B1 | `=DATE(2026,7,8)` |
| A2 | `week_start` | B2 | `=B1-WEEKDAY(B1,2)+1` |
| A3 | `channel` | B3 | `organic` |
| A4 | `city` | B4 | `Paris` |

La date fixe garantit que l’exercice donnera les mêmes résultats dans plusieurs mois. Pour un suivi courant, B1 pourrait contenir `=TODAY()` ; ce changement doit être volontaire.

### 16.8 Filtrer sans perdre l’original

Copier les en-têtes A1:S1 de Clean_Orders vers `Filtered_Orders!A1:S1`, puis mettre en A2 :

```text
=FILTER(Clean_Orders!A2:S1000,Clean_Orders!A2:A1000<>"",Clean_Orders!M2:M1000=Params!$B$3,Clean_Orders!D2:D1000=Params!$B$4)
```

Résultat attendu pour organic et Paris : **commandes 101 et 103**, soit **100 EUR**. Cette sortie ne change pas les six commandes du tableau source.

Le filtre temporel de la section 10.5, utilisé séparément avec le lundi du 6 juillet 2026, retourne **cinq commandes, pour 320 EUR**. La commande 105 est hors période.

### 16.9 Agréger par canal

Créer le TCD de la section 11 dans `Pivot_Channel`. Dans `Query_Channel!A1`, déposer la formule QUERY de la section 12.3. Les deux doivent retrouver, à l’ordre des lignes près :

| Canal | Commandes | Montant EUR |
| --- | --- | --- |
| Non trouvé | 1 | 80 |
| organic | 3 | 140 |
| paid | 2 | 160 |
| **Total** | **6** | **380** |

QUERY ne rajoute pas automatiquement la ligne Total de ce tableau documentaire. On compare la somme de ses groupes au total calculé séparément.

Le montant moyen global par commande est **380 / 6 ≈ 63,33 EUR**. La moyenne des trois moyennes de canal ne donne pas nécessairement ce résultat : les groupes n’ont pas tous le même nombre de commandes.

### 16.10 Ajouter un onglet Checks

Chaque ligne de Checks doit indiquer le **nom du contrôle**, sa **formule**, le **résultat observé** et l’**attendu**. Les formules ci-dessous supposent le jeu initial inchangé.

| Contrôle | Formule | Attendu |
| --- | --- | --- |
| Commandes source numériques | `=COUNT(Raw_Orders!A2:A1000)` | 6 |
| Commandes enrichies numériques | `=COUNT(Clean_Orders!A2:A1000)` | 6 |
| Montant total | `=SUM(Clean_Orders!O2:O1000)` | 380 |
| Quantités | `=SUM(Clean_Orders!E2:E1000)` | 10 |
| Lignes dont la clé commande est dupliquée | `=COUNTIF(Clean_Orders!R2:R1000,">1")` | 0 |
| Canaux inconnus | `=COUNTIF(Clean_Orders!M2:M1000,"Non trouvé")` | 1 |
| Lignes avec plusieurs correspondances client | `=COUNTIF(Clean_Orders!S2:S1000,">1")` | 0 |

Le contrôle des doublons compte ici les **lignes concernées**, pas le nombre de clés distinctes dupliquées. Et COUNT sur A est adapté parce que les identifiants de commande de la fixture sont numériques : ce n’est pas une règle universelle pour tous les identifiants.

Pour les clients distincts présents, utiliser la formule de la section 11.4 : attendu **5**, avec la nuance sur C999.

**Contrôle des dates :** dans une colonne temporaire libre de Clean_Orders, comparer :

```text
=IF($A2="","",TEXT(I2,"yyyy-mm-dd")=LEFT(C2,10))
```

Les six lignes doivent retourner TRUE. Ce contrôle vise la partie date au format attendu ; il ne valide pas toutes les composantes horaires du timestamp.

### 16.11 Construire un graphique lisible

À partir des trois groupes de Query_Channel, créer un graphique en barres du **montant par canal**. Ne pas y ajouter `orders_count` sur le même axe EUR et ne pas inclure une barre Total.

Titre proposé : « Montant des commandes enregistrées par canal — extrait de démonstration ». Ajouter une note : « 1 commande sur 6 sans client dans le référentiel ; montant correspondant : 80 EUR. »

Ne pas conclure que le canal paid est le plus rentable : nous n’avons ni coûts d’acquisition ni marge. Le résultat permet seulement de décrire les montants du périmètre.

### 16.12 Trois erreurs à provoquer dans une copie d’exercice

**A. Une nouvelle commande.** Ajouter dans Raw_Orders une ligne 107 pour C002, datée du 9 juillet 2026, quantité 1, prix 50, avec les autres champs valides. Attendre **7 commandes, 430 EUR au total**, paid à **210 EUR** et un montant de semaine à **370 EUR**. Si un résultat ne bouge pas, retrouver le maillon dont la plage ou les formules sont figées. Retirer ensuite cette ligne précise.

**B. Un doublon de référentiel.** Ajouter une deuxième ligne C001 avec un autre canal. La recherche peut encore afficher une valeur plausible, mais S doit passer à **2** sur les deux commandes de C001. Le contrôle `>1` doit compter **2 lignes**. Retirer la ligne ajoutée après observation.

**C. Compléter l’inconnu.** Ajouter C999 avec canal organic. Le total reste **380 EUR**, organic passe à **220 EUR sur 4 commandes**, paid reste à **160 EUR**, et le nombre de canaux inconnus passe à zéro. Le nombre de clients distincts présents dans les commandes reste cinq.

Ces variations vérifient des comportements utiles : extension de la chaîne, détection d’une ambiguïté, enrichissement sans modification du montant global. Restaurer la fixture initiale avant de comparer à nouveau aux tableaux de référence.

---

## 🧾 17. Aide-mémoire des formules et des traductions

### 17.1 Choisir selon l’opération

| Je veux… | Fonction ou mécanisme | Première vérification |
| --- | --- | --- |
| Lire un autre classeur | IMPORTRANGE | Accès, plage et déploiement |
| Lire un CSV distant | IMPORTDATA | URL du contenu, pas seulement page de partage |
| Remplacer une chaîne connue | SUBSTITUTE | Casse, position et occurrences |
| Garder le début ou la fin | LEFT / RIGHT | Longueur et format homogène |
| Assembler un libellé | `&` / CONCATENATE | Séparateur et types |
| Convertir une date texte | DATEVALUE ou parsing explicite | Locale et format source |
| Conserver une heure reconnue dans le texte | VALUE | Reconnaissance et fuseau |
| Calculer un âge ou un délai | DATEDIF ou soustraction | Unité et convention |
| Construire une clé mensuelle | DATE + YEAR + MONTH | Conserver l’année |
| Retrouver un attribut | XLOOKUP / VLOOKUP / INDEX + MATCH | Unicité du référentiel et exact |
| Compter des correspondances | COUNTIF | Population et type de clé |
| Afficher plusieurs lignes répondant à des critères | FILTER | Dimensions identiques et cas vide |
| Obtenir les valeurs distinctes | UNIQUE | Étendue : une colonne ou des lignes complètes |
| Agréger et trier dans une formule | QUERY | Types, en-têtes et syntaxe spécifique |
| Agréger par une interface | TCD | Grain, filtre et fonction d’agrégation |
| Calculer sur une colonne | ARRAYFORMULA | Compatibilité et place disponible |
| Tester / extraire / remplacer un motif | REGEXMATCH / REGEXEXTRACT / REGEXREPLACE | Fonction choisie et cas sans motif |

### 17.2 Noms français : ne pas recopier automatiquement ceux d’Excel

| Nom anglais | Nom dans Sheets en français, lorsque localisé |
| --- | --- |
| VLOOKUP | RECHERCHEV |
| XLOOKUP | RECHERCHEX |
| INDEX / MATCH | INDEX / EQUIV |
| IF / IFERROR / IFNA | SI / SIERREUR / SI.NON.DISP |
| LEFT / RIGHT / LEN | GAUCHE / DROITE / NBCAR |
| SUBSTITUTE | SUBSTITUE |
| CONCATENATE | CONCATENER |
| TRIM | SUPPRESPACE |
| VALUE / DATEVALUE | CNUM / DATEVAL |
| YEAR / MONTH / DAY | ANNEE / MOIS / JOUR |
| TODAY | AUJOURDHUI |
| COUNT / COUNTA | NB / NBVAL |
| SUM / AVERAGE | SOMME / MOYENNE |
| DATEDIF | DATEDIF |
| FILTER / QUERY / ARRAYFORMULA | FILTER / QUERY / ARRAYFORMULA |
| REGEXMATCH / REGEXEXTRACT / REGEXREPLACE | Noms conservés |

**Correction Brocode.** Le nom français de FILTER dans Google Sheets reste **FILTER** dans la documentation consultée ; `FILTRE` est notamment le nom que l’on rencontre dans Excel français. Vérifier l’aide de l’outil utilisé. Références : [liste des fonctions Sheets en français](https://support.google.com/docs/table/25273?hl=fr), [FILTER en français](https://support.google.com/docs/answer/3093197?hl=fr).

Garder les noms anglais est une option confortable pour suivre ce chapitre. Cela n’impose pas de changer les conventions locales d’un fichier métier déjà utilisé par une équipe.

---

## 🎓 18. Révision : savoir expliquer, pas seulement recopier

### « Pourquoi préparer la table avant de créer un TCD ? »

Parce que le TCD agrège les valeurs qu’on lui donne. Il ne corrige pas les dates texte, les identifiants dupliqués ou les mauvaises unités. Une sortie bien présentée peut synthétiser une entrée incorrecte.

### « Quelle différence entre formater une date et convertir une date ? »

Le format change l’affichage d’une valeur ; la conversion transforme un texte en valeur exploitable selon une convention. Il faut vérifier les deux, notamment pour les dates ambiguës.

### « Pourquoi VLOOKUP doit-il souvent finir par FALSE ? »

Pour imposer une correspondance exacte sur une clé. Sinon, son défaut approximatif peut renvoyer une valeur voisine sur une plage supposée triée. Ce n’est généralement pas le contrat d’un identifiant client.

### « XLOOKUP résout-il le problème des doublons ? »

Non. Il facilite l’écriture de la recherche, mais le référentiel peut rester ambigu. Contrôler le nombre de correspondances et la règle de choix.

### « Quel est le risque d’un IFERROR partout ? »

Transformer des défauts techniques et des absences métier en cellules silencieusement vides. Choisir un traitement précis, garder les erreurs visibles pendant la construction et mesurer les exceptions.

### « Pourquoi mon total est-il faux alors que tous mes ratios sont corrects ? »

Des ratios corrects ligne par ligne ne s’additionnent généralement pas et ne se moyennent pas toujours à poids égal. Le ratio global doit être recalculé à partir des totaux de son numérateur et de son dénominateur, selon la définition métier.

### « Le TCD indique six clients : est-ce forcément vrai ? »

Non. Il peut compter six occurrences de customer_id dans six commandes, avec le même client plusieurs fois. Le grain et la méthode de comptage déterminent le sens du chiffre.

### « Quand faut-il quitter le tableur ? »

Quand les contraintes de volume, de calcul, de fiabilité ou de maintenance justifient une infrastructure adaptée. Il n’existe pas un seuil de lignes identique pour tous les classeurs.

### « Comment savoir si mon analyse suivra les prochaines données ? »

Ajouter une ligne contrôlée et vérifier son passage dans l’import, les colonnes calculées, les agrégations et les graphiques. Puis tester une catégorie nouvelle et une référence manquante.

### Exercices à refaire sans regarder les formules

- [ ] Rechercher le même canal avec VLOOKUP, XLOOKUP et INDEX + MATCH.
- [ ] Expliquer chaque `$` dans une formule recopiée vers le bas.
- [ ] Extraire une date sans convertir implicitement UTC en heure locale.
- [ ] Filtrer une semaine traversant le changement d’année.
- [ ] Obtenir le même total par TCD et QUERY.
- [ ] Montrer une recherche qui donne un résultat malgré un doublon de clé.
- [ ] Expliquer pourquoi `Non trouvé`, zéro et vide sont trois états différents.
- [ ] Nettoyer un suffixe sans modifier un nom qui contient le même texte au milieu.

---

## 🔗 19. Ce que ce cours prépare dans la suite du Brocode

| Notion de ce chapitre | Lien utile | Nuance à garder |
| --- | --- | --- |
| Table, type, grain et clé | [[wagon2321/cours_sol/05_intro_sql_relational_databases_bigquery_sol\|Introduction SQL et bases relationnelles]] | Un tableur est plus permissif qu’un schéma de base de données |
| TCD et agrégations | [[wagon2321/cours_sol/06_sql_aggregation_string_date_time_functions_sol\|Agrégation, texte et dates]] | Compter des lignes, des valeurs ou des entités donne des résultats différents |
| Recherche par identifiant | [[wagon2321/cours_sol/07_joins_and_testing_sol\|JOINs & Testing]] | Un JOIN peut multiplier les correspondances que la recherche scalaire masque |
| Filtres et transformations successives | [[wagon2321/cours_sol/08_subqueries_ctes_union_sol\|CTEs, sous-requêtes et UNION]] | Décomposer une opération facilite sa vérification |
| Imports, actualisation et couches | [[wagon2321/cours_sol/10_data_pipelines_views_tables_sol\|Data Pipelines, Views & Tables]] | Une formule liée à une source n’est pas un pipeline orchestré complet |

Ces liens prolongent les concepts ; ils ne signifient pas que le SQL ou dbt sont des prérequis au cours #2.

**Deuxième cours Google Sheets.** À réception, ajouter le lien de navigation et répartir les approfondissements selon son contenu réel. Le présent chapitre fournit déjà les bases nécessaires aux exercices et aux premiers tableaux de suivi.

---

## 🩹 20. Corrections Brocode, références et vérification

### 20.1 Registre des corrections

| Point fragile dans les notes ou la transcription | Version retenue |
| --- | --- |
| 50 000–100 000 lignes comme limite dure | Repère de performance variable ; plafond technique exprimé notamment en cellules |
| 95 % de fonctions communes Excel/Sheets | Estimation orale, non conservée comme statistique démontrée |
| Nettoyage toujours supérieur à 50 % du travail | Peut être très coûteux ; proportion dépendante du contexte |
| Les espaces entre arguments sont nécessaires | Ils facilitent la lecture, pas la reconnaissance syntaxique des arguments |
| Les couleurs prouvent que la formule est correcte | Aide visuelle seulement ; vérifier les références, types et résultats |
| Changer le pays traduit l’interface et toutes les fonctions | Locale, langue et noms des fonctions sont des réglages distincts |
| IMPORTDATA nécessite un second argument délimiteur | La signature officielle de référence consultée publie un seul argument `url` |
| IMPORTRANGE garantit une mise à jour à fréquence fixe | Pas de promesse de temps réel ; documentation donnant plusieurs indications selon la page |
| Masquer protège la donnée importée | Le masquage ne retire ni les valeurs ni les autorisations |
| Enlever UTC convertit la date/heure | Nettoyage textuel uniquement, sans conversion de fuseau |
| DATEVALUE et VALUE font la même chose | DATEVALUE cible une date entière à partir de texte ; VALUE peut conserver une heure reconnue |
| DATEDIF accepte semaines et trimestres | Unités publiées : D, M, Y, MD, YM, YD |
| Un numéro de mois/semaine suffit pour tout historique | Conserver l’année et la convention, ou employer une clé de début de période |
| Troisième argument optionnel vide de VLOOKUP | L’index est obligatoire ; pas de repli intégré dans cette fonction |
| Sans correspondance, une ligne est ignorée | La recherche produit une absence/erreur ; supprimer la ligne est une autre opération |
| Recherche par clé identique à un JOIN SQL | Concept partagé, mais comportement différent face aux correspondances multiples |
| Recopier toute une colonne couvre toutes les futures données | Seules les plages/formules effectivement étendues sont couvertes |
| ARRAYFORMULA fonctionne universellement sur toute fonction | Compatibilité à vérifier ; certaines fonctions sont déjà matricielles |
| COUNTA compte les clients ou les lignes visibles | Il compte des valeurs selon son comportement, pas automatiquement des entités distinctes |
| Custom corrige l’affichage d’un pourcentage | Le mode de calcul et le format numérique sont deux réglages différents |
| QUERY est du SQL complet | Langage Google Visualization spécifique ; pas de transposition aveugle de FROM/JOIN/DISTINCT |
| REGEXCONTAINS est une fonction Sheets | Employer REGEXMATCH |
| REGEXEXTRACT est un remplacement de suffixe | Distinguer extraction et remplacement ; REGEXREPLACE convient au remplacement |
| FILTER devient FILTRE en français dans Sheets | La documentation Sheets conserve FILTER |
| Graphiques absents de la journée | Contradiction des résumés ; les principes sont présents dans une transcription |
| Trois séries / cinq secondes comme règles absolues | Repères pédagogiques de lisibilité |
| Programmation d’actualisation universelle | Dépend de la fonction, du connecteur ou d’un mécanisme d’automatisation distinct |

### 20.2 Sources documentaires

Source pédagogique principale : export Markdown du **7 juillet 2026**, contenu dans `02_google_sheet.zip`. L’ancienne version du vault sert de repère éditorial et de variante ; elle ne remplace pas la transcription et la vérification technique.

Documentation officielle consultée le **8 septembre 2026** :

| Sujet | Référence |
| --- | --- |
| Paramètres et recalcul | [Localisation et paramètres de calcul](https://support.google.com/docs/answer/58515?hl=en) |
| Import de classeur | [IMPORTRANGE](https://support.google.com/docs/answer/3093340?hl=en) |
| Import CSV/TSV | [IMPORTDATA](https://support.google.com/docs/answer/3093335?hl=en) |
| Remplacement de texte | [SUBSTITUTE](https://support.google.com/docs/answer/3094215?hl=en) |
| Conversion | [DATEVALUE](https://support.google.com/docs/answer/3093039?hl=en), [VALUE](https://support.google.com/docs/answer/3094220?hl=en) |
| Écarts de dates | [DATEDIF](https://support.google.com/docs/answer/6055612?hl=en) |
| Semaines ISO | [ISOWEEKNUM](https://support.google.com/docs/answer/7368793?hl=en) |
| Recherches | [VLOOKUP](https://support.google.com/docs/answer/3093318?hl=en), [XLOOKUP](https://support.google.com/docs/answer/12405947?hl=en) |
| Position et valeur | [MATCH](https://support.google.com/docs/answer/3093378?hl=en), [INDEX](https://support.google.com/docs/answer/3098242?hl=en) |
| Gestion d’absence | [IFNA](https://support.google.com/docs/answer/9365944?hl=en) |
| Plages calculées | [ARRAYFORMULA](https://support.google.com/docs/answer/3093275?hl=en) |
| Filtrage | [FILTER](https://support.google.com/docs/answer/3093197?hl=en), [filtres et vues](https://support.google.com/docs/answer/3540681?hl=en) |
| TCD | [Création et champs calculés](https://support.google.com/docs/answer/1272900?hl=en) |
| Requêtes | [QUERY](https://support.google.com/docs/answer/3093343?hl=en), [syntaxe du langage](https://developers.google.com/chart/interactive/docs/querylanguage) |
| Expressions régulières | [REGEXMATCH](https://support.google.com/docs/answer/3098292?hl=en), [REGEXEXTRACT](https://support.google.com/docs/answer/3098244?hl=en), [REGEXREPLACE](https://support.google.com/docs/answer/3098245?hl=en) |
| Limites | [Fichiers Google Drive](https://support.google.com/drive/answer/37603?hl=en) |
| Traductions et autres fonctions | [Liste officielle française](https://support.google.com/docs/table/25273?hl=fr) |

### 20.3 Portée de la vérification de cette version

Les signatures et les points fragiles ont été confrontés aux références ci-dessus. Les données du fil rouge, les regroupements, les dates de début de semaine, les nettoyages et les scénarios d’ajout ont été recalculés indépendamment. Les références de cellules, le YAML et les liens du vault ont été contrôlés.

**Aucun classeur Google Sheets n’a été exécuté dans cette validation.** Les résultats attendus servent de points de contrôle à reproduire dans Sheets avec la locale annoncée. L’actualisation d’un import réel, les autorisations et les interactions de l’interface dépendent du document utilisé et ne sont pas présentées comme testées ici.

---

> [!success] À la fin de ce premier cours
> Je peux partir d’une demande, construire une table propre et enrichie, vérifier son grain, produire un regroupement cohérent et expliquer les limites du résultat. Je sais aussi retrouver une formule et diagnostiquer ses erreurs sans cacher le problème sous une cellule vide.
