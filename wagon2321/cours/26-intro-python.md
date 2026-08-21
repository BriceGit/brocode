---
title: "Python — Bases du langage : variables, structures de données & fonctions"
aliases:
  - "Intro Python"
  - "Python — Bases"
  - "print vs return"
  - "try / except Python"
  - "Listes vs dictionnaires"
  - "Boucle for Python"
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 26
date: 2026-08-10
language: "Python"
database: "n/a — pas de base de données dans cette session (premier cours 100% Python)"
topics:
  - "Python"
  - "Jupyter Notebook"
  - "Variables et types"
  - "Strings"
  - "Listes"
  - "Dictionnaires"
  - "Conditions"
  - "Boucles"
  - "Fonctions"
  - "Gestion d'erreurs"
tags:
  - brocode
  - wagon2321/cours
  - python
---

# 26 - Intro Python

> Premier cours 100% Python du bootcamp — la brique sur laquelle tout le reste (pandas dès demain, puis sklearn) va se construire. Deux temps : le matin pose le langage (variables, types, listes, dictionnaires, conditions, boucles, fonctions) case par case dans un notebook ; l'après-midi enchaîne sur un exercice fil rouge (segmentation de clients) qui fait travailler toutes ces briques ensemble.

**Date :** 10 août 2026
**Format :** cours du matin (bases du langage) + exercice guidé l'après-midi (`achats_clients`) + exercices en autonomie
**Outil :** Jupyter Notebook (VS Code ou interface web)

> [!info] Notes de contexte
> Le transcript Notion de cette session s'était auto-évalué **⭐ 1/5 en compréhension** au moment de la prise de notes — ça confirme que le mode "généreux en explications" demandé était le bon réglage ici. Par ailleurs, la transcription audio brute contient pas mal d'approximations de reconnaissance vocale (ex. "Python" → *"Biton"*, "erreur" → *"Gérard"*). Je me suis appuyé en priorité sur les **deux blocs de notes structurées** générés par l'IA de Notion (fiables) et sur les captures d'écran ; la transcription brute a surtout servi à reconstituer le déroulé de l'exercice fil rouge de l'après-midi. Les 7 captures fournies couvrent bien toute la session — rien à signaler côté screenshots manquants cette fois.

---

## 🎯 TL;DR

- **Jupyter** : cellules indépendantes, exécutables dans **n'importe quel ordre** (`Shift+Enter` exécute et avance, `Ctrl+Enter` exécute et reste sur la cellule) → source n°1 de bugs "fantômes" si on ne relance pas tout depuis le haut
- **Types de base** : `int`, `float`, `str` — `type()` pour vérifier, `int()` / `float()` / `str()` pour convertir (il faut **réaffecter** la variable pour que la conversion persiste)
- **Listes** `[...]` : indexées à partir de `0`, index négatifs depuis la fin (`-1`), slicing `liste[a:b]` avec **`b` toujours exclu**
- **Dictionnaires** `{clé: valeur}` : pas d'ordre, accès par clé, clés **uniques**, `.items()` indispensable pour boucler sur clé **et** valeur en même temps
- **`if / elif / else`** : indentation obligatoire, pas de parenthèses ni d'accolades (contrairement à SQL/JS)
- **`print()` vs `return`** : `print` affiche à l'écran et s'arrête là ; `return` sauvegarde le résultat pour le réutiliser ailleurs — **le piège n°1 du jour**
- **`try / except`** : l'équivalent Python du `SAFE_DIVIDE` de BigQuery pour sécuriser une division qui peut tomber sur un dénominateur à zéro

---

## 1. Pourquoi Python ?

- **Langage le plus populaire**, la plus grande communauté (donc la doc, Stack Overflow, les tutos… tout est là)
- **Petite courbe d'apprentissage** — syntaxe épurée, comparée à d'autres langages
- **Application universelle** : backend, algorithmique, data analyse, IA
- **Plus de 70% des offres data exigent Python** — repère utile pour tes candidatures Genève : sur les fiches de poste banking, c'est quasiment un prérequis coché par défaut, pas un "plus"
- **THE langage de l'IA** : écosystème scikit-learn / TensorFlow / Keras qui va prendre le relais dans les semaines à venir (module ML)

## 2. Bonnes pratiques & réflexes de debug

- **Lire la documentation** des librairies et regarder les exemples fournis
- **Kaggle & GitHub** pour trouver projets et datasets d'entraînement
- **Practice, practice, practice** — c'est un langage qui s'apprend en écrivant, pas en lisant
- **Stack Overflow = meilleur ami** en cas de bug
- **Lire le message d'erreur** (la fameuse ligne rouge) : ça fait peur au début, mais c'est justement **la dernière ligne** qui dit où chercher. Réflexe à prendre dès aujourd'hui, il te sert pour tout le reste du cursus (SQL, dbt, pandas plus tard…)

> Le formateur le formule bien : *"n'ayez pas peur de faire des erreurs et de poser des questions, on est tous passés par là."*

## 3. Environnement de travail : Jupyter Notebook

Un notebook est un **service web qui permet d'écrire et exécuter du code Python par cellules** — chaque cellule peut contenir du code, du texte en Markdown, ou des images/vidéos, et le résultat s'affiche **directement en dessous** de la cellule qui l'a produit.

Deux façons d'y accéder, vues en cours :
- **Google Colaboratory** : notebook Jupyter hébergé par Google, gratuit, librairies principales déjà installées, exécution sur machine distante, collaboratif en temps réel (façon Google Docs)
- **VS Code ou interface web locale** : `code .` pour ouvrir en VS Code, ou `jupyter notebook` en ligne de commande pour l'interface web — pas de différence fonctionnelle notable entre les deux, question de préférence

> [!warning] L'ordre d'exécution des cellules est libre — et c'est un piège
> Contrairement à un script classique lu de haut en bas, dans un notebook **tu peux exécuter les cellules dans n'importe quel ordre**, et le numéro `[n]` à gauche de la cellule te montre l'ordre réel d'exécution (pas l'ordre d'affichage). C'est pratique pour itérer, mais c'est exactement l'origine du principe déjà tracké dans le brocode : les **variables silencieusement obsolètes** — une cellule peut afficher une valeur qui n'est plus à jour parce qu'une cellule en amont a été modifiée sans être ré-exécutée. Réflexe : en cas de résultat qui ne colle pas, relancer tout le notebook depuis le haut avant de chercher plus loin.

### Cheatsheet notebook

| Contexte | Raccourci | Effet |
|---|---|---|
| N'importe où | `Shift + Enter` | Exécute la cellule et **avance** à la suivante |
| N'importe où | `Ctrl + Enter` *(précision orale, absente du slide)* | Exécute la cellule et **reste** dessus |
| Mode édition | `Esc` | Passe en mode commande |
| Mode édition | `Tab` | Autocomplétion / suggestion de code |
| Mode édition | `Shift + Tab` (dans les parenthèses d'une fonction) | Affiche la doc de la fonction (auto en Colab, manuel en Jupyter) |
| Mode Markdown | `#` … `#####` | Titre niveau 1 à 5 |
| Mode commande | `Enter` | Passe en mode édition |
| Mode commande | `M` | Passe la cellule en Markdown |
| Mode commande | `Y` | Passe la cellule en code |
| Mode commande | `A` | Crée une cellule au-dessus |
| Mode commande | `B` | Crée une cellule en dessous |
| Mode commande | `D D` | Supprime la cellule |
| Mode debugger | `Q` | Quitte le debugger |
| Mode debugger | `U` | Remonte d'un niveau (fonction parente) |

## 4. Variables & types de données

- **Affectation** avec `=` : `a = 10` — la variable est réutilisable dans n'importe quelle cellule suivante, quel que soit l'ordre d'exécution
- **Trois types de base** :
  - `int` — entier (`10`, `-1`)
  - `float` — décimal (`-1.0`)
  - `str` — chaîne de caractères (`"hello"`)
- **`type(x)`** retourne le type de `x` — le réflexe à avoir dès qu'un résultat surprend
- **Conversion de type** : `int()`, `float()`, `str()` — attention, ça ne modifie pas la variable en place, il faut **réaffecter** : `a = str(a)` et non juste `str(a)` seul sur sa ligne
- **`abs(x)`** : valeur absolue
- **`len(x)`** : longueur — fonctionne sur des types très différents (string, liste, dictionnaire), on le recroise plus loin

```python
a = 10
b = a / 2       # b = 5.0
c = a + b       # réutilise deux variables entre elles : c = 15.0

type(c)         # <class 'float'>
```

## 5. Chaînes de caractères (`str`)

- **Concaténation** avec `+`
- **F-strings** : `f"Hello {variable}"` — la façon moderne d'insérer une variable dans du texte, à privilégier
- Une string se comporte **comme une liste de caractères** : indexable et slicable exactement pareil
- Des méthodes spécifiques existent (`.count()` pour compter les occurrences, etc.) — chaque type a son propre jeu de méthodes, `variable.` + `Tab` pour les lister

Exemple vu en cours (indexation et slicing d'une string) :

```python
hello_variable = 'Hello, World!'

# Caractère à la position 1 (le premier caractère est en position 0)
print(hello_variable[1])       # 'e'

# Caractères de la position 2 à 5 (5 exclu)
print(hello_variable[2:5])     # 'llo'

# Index négatif : -1 = dernier caractère, -2 = avant-dernier, etc.
print(hello_variable[-2])      # 'd'
```

## 6. Listes

- **Création** : `[1, 3, 5]` — une liste peut mélanger les types (`[1, "deux", 3.0]`)
- **Indexation** : commence à `0` ; index négatif (`-1`) pour partir de la fin
- **Slicing** : `liste[0:2]` — comme pour les strings, **la borne de droite est exclue**
- **Modification d'un élément** : `liste[0] = 10`
- **Méthodes clés** :
  - `.insert(index, valeur)` — insère à une position précise (décale les éléments suivants)
  - `.append(valeur)` — ajoute à la fin, sans avoir à réfléchir à un index
  - `.pop(index)` — supprime **et retourne** l'élément (dernier élément par défaut si pas d'index) ; pratique pour supprimer une valeur tout en la récupérant dans une variable
- **Listes imbriquées** : une liste peut contenir d'autres listes — accès par double indexation, ex. `liste[-1][0]` va chercher la dernière sous-liste puis son premier élément

```python
liste = [3.4, "test", 2]

liste[0]        # 3.4 (premier élément)
liste[-1]       # 2 (dernier élément, sens inverse)
liste[0:2]      # [3.4, 'test'] — le 2 est exclu

liste.append(10)     # ajoute 10 à la fin
val = liste.pop()    # supprime le dernier élément et le retourne dans val

len(liste)      # nombre d'éléments dans la liste
```

## 7. Dictionnaires

- Structure **clé : valeur**, **sans ordre d'index** — l'accès se fait uniquement par nom de clé
- Les **clés sont uniques**
- **Modifier une valeur** : `dict["cle"] = nouvelle_valeur`
- **Ajouter une clé** inexistante : même syntaxe, `dict["nouvelle_cle"] = valeur`
- **Méthodes clés** :
  - `.keys()` — liste des clés
  - `.values()` — liste des valeurs (techniquement un `set`, pas une vraie liste modifiable)
  - `.items()` — paires clé-valeur, indispensable pour boucler sur les deux à la fois (voir section boucles)
  - `.pop("cle")` — supprime et retourne la valeur associée ; ne peut pas être relancé deux fois sur la même clé (elle n'existe plus après)
- **Plusieurs valeurs pour une même clé** : utiliser une **liste** comme valeur (`{"Alice": [65, 12, 40]}`)
- **Dictionnaires imbriqués** : accès chaîné, ex. `dict["mesure"]["hauteur"]`

## 8. Opérateurs de comparaison & conditions

- `==` pour comparer (à ne pas confondre avec `=` qui affecte une valeur), `!=`, `>`, `<`, `>=`, `<=` — tous retournent `True` ou `False`
- Structure `if / elif / else` :

```python
if panier_moyen > 50:
    print("VIP")
elif 0 < panier_moyen <= 50:
    print("Standard")
else:
    print("Pas de commande")
```

> [!warning] Indentation obligatoire, pas de parenthèses
> Contrairement à SQL (`CASE WHEN ... THEN`) ou à d'autres langages avec accolades, Python structure ses blocs **uniquement par l'indentation**. Une ligne mal indentée = erreur, ou pire, un comportement silencieusement différent de celui voulu.

Ces comparateurs s'appliquent aussi bien à des variables simples qu'à des éléments de listes ou de dictionnaires (`panier_moyen["Alice"] > 50`).

## 9. Boucles `for`

- Syntaxe : `for element in liste:` — itère automatiquement sur chaque élément
- Fonctionne aussi sur les **strings** (caractère par caractère) et sur les **dictionnaires**
- Sur un dictionnaire, plusieurs options :
  - `for cle in dictionnaire:` — itère sur les clés uniquement (comportement par défaut)
  - `for valeur in dictionnaire.values():` — itère sur les valeurs uniquement
  - `for cle, valeur in dictionnaire.items():` — "déplie" chaque paire en deux variables séparées, la plus utile des trois pour manipuler clé et valeur ensemble

```python
for cle, valeur in dict_exemple.items():
    print(cle)
    print(valeur)
```

## 10. Fonctions

- **Déclaration** : `def nom_fonction(param):`
- **Appel** : `nom_fonction(argument)`
- **Valeurs par défaut** : `def f(a=2, b=3):` — évite une erreur si un argument est manquant à l'appel ; attention à l'ordre positionnel des arguments si tu n'utilises pas les valeurs par défaut

> [!warning] `print` vs `return` — le piège n°1 de la session
> - `print()` **affiche** une valeur à l'écran au moment où la cellule s'exécute. Point. Rien n'est sauvegardé derrière.
> - `return` **sauvegarde** le résultat de la fonction dans la variable qui reçoit l'appel, pour pouvoir le réutiliser plus loin dans d'autres calculs.
>
> Une fonction qui `print()` son résultat au lieu de le `return`-er semble "marcher" (tu vois bien le résultat s'afficher), mais si tu essaies de récupérer ce résultat dans une variable (`resultat = ma_fonction(...)`), tu récupères `None`. C'est l'erreur la plus fréquente en début d'apprentissage des fonctions — dès que tu veux réutiliser une valeur de sortie, vérifie que ta fonction fait bien `return` et pas seulement `print`.

```python
def calcul(a, b=3):
    return a / b

test = calcul(9)   # test = 3.0, réutilisable derrière
```

## 11. 🧵 Exercice fil rouge de l'après-midi : segmentation clients

L'après-midi enchaîne sur un exercice complet qui fait travailler **dictionnaire + fonction + boucle + condition + gestion d'erreur** ensemble, à partir d'un dictionnaire de départ `achats_clients` (clé = nom du client, valeur = liste de ses montants d'achat).

### 11.1 Fonction `calculer_panier_moyen`

```python
def calculer_panier_moyen(client, table):
    return sum(table[client]) / len(table[client])
```

- `sum()` et `len()` réutilisés directement sur la liste d'achats du client
- La fonction a été **refactorisée** en cours de route : initialement écrite avec le nom du dictionnaire "en dur" à l'intérieur, elle a été rendue générique en ajoutant le paramètre `table` — bon réflexe à retenir : une fonction ne devrait jamais dépendre d'un nom de variable extérieur codé en dur si elle peut le recevoir en argument

### 11.2 Le piège du client sans commande

Un client sans aucun achat (`Georges`, liste vide) fait planter `calculer_panier_moyen` avec une **`ZeroDivisionError`** (`len(table[client])` vaut `0`). Solution : `try / except`.

```python
def calculer_panier_moyen(client, table):
    try:
        return sum(table[client]) / len(table[client])
    except ZeroDivisionError:
        return 0
```

> [!warning] Le `0` de secours n'est pas neutre
> Le formateur le signale explicitement en cours : renvoyer `0` par défaut pour un client sans commande évite le crash, mais **ce n'est pas anodin** — si ce `0` est ensuite réutilisé dans un autre calcul (une moyenne globale, par exemple), il fausse silencieusement le résultat, exactement comme un `NULL` mal géré dans une agrégation SQL. Une alternative mentionnée : `None`, la valeur par défaut d'une fonction qui ne fait pas de `return` explicite. À trancher au cas par cas selon ce qu'on veut faire du résultat ensuite — mais ne jamais choisir `0` par réflexe sans se poser la question de l'impact en aval.

### 11.3 Construire le dictionnaire des paniers moyens

```python
panier_moyen = {}
for client, prix in achats_clients.items():
    panier_moyen[client] = calculer_panier_moyen(client, achats_clients)
```

- Initialisation **à vide** avant la boucle — pattern classique
- `.items()` est ce qui permet de récupérer `client` en même temps que la table pour l'appel de fonction
- Sans `.items()`, un `for client in achats_clients` ne donne accès qu'aux clés, pas aux valeurs

### 11.4 Segmentation VIP / Standard

```python
vip = []
standard = []
pas_client = []

for client in panier_moyen:
    if panier_moyen[client] > 50:
        vip.append(client)
    elif 0 < panier_moyen[client] <= 50:
        standard.append(client)
    else:
        pas_client.append(client)
```

- Trois listes initialisées vides, remplies automatiquement par la boucle — même logique que la construction du dictionnaire juste avant
- Résultat directement exploitable pour une équipe marketing (relance des "pas_client", ciblage des VIP, etc.)
- Le formateur note qu'on **aurait pu** structurer ça en dictionnaire imbriqué plutôt qu'en 3 listes séparées (`{"Alice": {"panier_moyen": 65, "segment": "VIP"}}`) — plus proche de ce que pandas fera "nativement" dès demain avec des colonnes

## 12. Gestion des erreurs : `try` / `except`

- Mots-clés `try` (essaie ce bloc) / `except` (si ça échoue, fais ceci à la place)
- On peut cibler une exception **précise** (`except ZeroDivisionError:`) plutôt qu'attraper toutes les erreurs sans distinction — plus sûr, ça évite de masquer un bug différent sous le même filet
- Une fonction sans `return` explicite renvoie `None` par défaut (l'équivalent Python d'un NULL)

> 🔗 **Connexion brocode** : `try / except ZeroDivisionError` en Python, c'est exactement le même problème que `SAFE_DIVIDE` en BigQuery — protéger une division contre un dénominateur potentiellement nul ou vide, dans un outil différent. Voir [[Aggregate before divide]] pour la version SQL/dbt/pandas de cette famille de principes. Ça mérite sa propre fiche dédiée (faite ci-dessous, voir [[Gérer une division par zéro (SAFE_DIVIDE vs try except)]]).

## 13. Aperçu de demain : Pandas

- La session Pandas reprend directement la logique vue aujourd'hui (création de colonne, boucles, conditions), mais avec une **syntaxe plus concise**
- Le formateur prévient : "pour recréer une colonne, `tableau["nouvelle_colonne"] = ...` — c'est la même logique qu'aujourd'hui" (assignation de clé sur un dictionnaire ≈ assignation de colonne sur un DataFrame)
- Une comparaison avec Excel sera également abordée
- Un chapitre pandas existe déjà dans ton vault (session ultérieure déjà traitée) — pense à ajouter le lien croisé manuellement de ton côté si le nom de fichier diffère de ce que j'utiliserais en devinant, pour éviter un wikilink cassé

## ✅ Actions post-session

- [ ] Ouvrir les notebooks d'exercices (VS Code ou interface web Jupyter) et compléter les exercices du jour
- [ ] Télécharger le cheat sheet partagé en cours
- [ ] Préparer la session Pandas du lendemain
- [ ] *(point ouvert soulevé en fin de session, non résolu)* Vérifier l'existence d'une extension de formatage SQL pour l'éditeur utilisé

---

## 🔗 Liens brocode

- [[Aggregate before divide]] — même famille de principe que le `try/except` sur division par zéro
- [[Gérer une division par zéro (SAFE_DIVIDE vs try except)]] — fiche dédiée créée à partir de cette session
- [[Print vs Return]] — fiche dédiée créée à partir de cette session
- Chapitre suivant : session Pandas (à lier manuellement, cf. section 13)
