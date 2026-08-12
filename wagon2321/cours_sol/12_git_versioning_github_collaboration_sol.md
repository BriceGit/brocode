---
title: "Git — Versioning, GitHub & Collaboration"
aliases:
  - "Git & GitHub"
  - "Git Versioning"
  - "Git Collaboration"
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 12
date: 2026-07-21
topics:
  - "Git"
  - "GitHub"
  - "Version Control"
  - "Terminal"
  - "Collaboration"
tags:
  - brocode
  - wagon2321/cours
  - git
  - github
  - version-control
  - collaboration
---

# 📝 12 — Git · Versioning, GitHub & Collaboration

> [!info] Navigation Brocode
> **← Précédent :** [[10_data_pipelines_views_tables_sol|10 — Data Pipelines, Views & Tables]]
>
> [!tip] Navigation Obsidian
> Utilise l’**Outline** pour parcourir les sections, `Cmd/Ctrl + O` pour le Quick Switcher et les **backlinks** pour retrouver les connexions entre notes.

---

> **Le Wagon — Data Analytics · Session #12 · 21 juillet 2026**
>
> Git permet de versionner le code, de conserver un historique exploitable et de collaborer sans multiplier les copies de fichiers. Ce chapitre pose les fondations du workflow utilisé ensuite avec dbt.

## 🎯 Objectifs

- Naviguer dans le terminal.
- Distinguer **Git** de **GitHub**.
- Comprendre repository, Working Directory, staging, commit, branch et remote.
- Maîtriser `status → diff → add → commit`.
- Comprendre `clone`, `push`, `pull`, Pull Request, code review et merge.
- Comprendre les conflits et les bonnes pratiques collaboratives.
- Savoir ce qui ne doit pas être versionné.
- Relier Git au workflow [[13 — dbt · Introduction]].

---

## 🧭 1. Pourquoi le versioning ?

Sans Git, le versioning finit facilement ainsi :

```text
report.docx
report_v2.docx
report_final.docx
report_final_v2_FINAL.docx
```

Le problème n'est pas seulement le nom des fichiers. On veut pouvoir répondre à :

```text
Qu'est-ce qui a changé ?
Quand ?
Qui ?
Pourquoi ?
Peut-on revenir à un état antérieur ?
Comment plusieurs personnes travaillent-elles ensemble ?
```

Git transforme donc :

```text
un dossier de fichiers
```

en :

```text
un projet
+
un historique de versions
```

→ [[Version Control]]

## 🧠 2. Git ≠ GitHub

**Git** est le système de contrôle de version. Il fonctionne localement et permet notamment de créer des commits, branches et historiques.

**GitHub** est une plateforme distante qui héberge des repositories Git et ajoute des outils collaboratifs comme les Pull Requests et la code review.

```text
Git
→ version control

GitHub
→ hosting + collaboration
```

GitLab et Bitbucket jouent des rôles comparables.

## 💻 3. Terminal — commandes essentielles

| Besoin | Commande |
|---|---|
| Afficher le dossier courant | `pwd` |
| Lister le contenu | `ls` |
| Afficher aussi les fichiers cachés | `ls -a` |
| Créer un dossier | `mkdir dossier` |
| Changer de dossier | `cd dossier` |
| Remonter d'un niveau | `cd ..` |
| Revenir au home | `cd ~` |
| Créer un fichier vide | `touch fichier.txt` |
| Copier | `cp source destination` |
| Déplacer / renommer | `mv source destination` |
| Supprimer un fichier | `rm fichier` |
| Supprimer récursivement | `rm -r dossier` |
| Afficher l'arborescence | `tree` |
| Ouvrir VS Code ici | `code .` |

La touche **Tab** permet l'autocomplétion.

Dans le setup Windows du cours, Ubuntu tourne via WSL et les fichiers de travail sont notamment accessibles sous `/home/<user>`.

> ⚠️ `rm -r` peut supprimer un dossier et son contenu. À utiliser avec prudence.

## 🗃 4. Repository

Un **repository** (*repo*) est un projet suivi par Git.

Créer un repository à partir d'un dossier local :

```bash
git init
```

Git crée alors un dossier caché :

```text
.git/
```

Il contient les informations nécessaires à l'historique Git local.

Deux points de départ sont donc possibles :

```text
nouveau projet local
→ git init
```

ou :

```text
projet existant distant
→ git clone <URL>
```

→ [[Repository]]

## 🧠 5. Le modèle mental fondamental de Git

```text
WORKING DIRECTORY
       │
       │ git add
       ▼
STAGING AREA
       │
       │ git commit
       ▼
LOCAL REPOSITORY
       │
       │ git push
       ▼
REMOTE REPOSITORY
```

À retenir :

```text
je modifie
→ je sélectionne
→ j'enregistre une version
→ je la publie éventuellement
```

## 📝 6. Working Directory

C'est l'état des fichiers sur lesquels tu travailles réellement dans VS Code.

Important : Git observe les fichiers **sauvegardés sur disque**. Une modification encore non sauvegardée dans l'éditeur n'est pas encore une modification du fichier que Git peut versionner.

```text
modifier dans VS Code
↓
sauvegarder
↓
git status
```

## 🎭 7. Staging Area

Le staging sélectionne ce qui doit appartenir au prochain commit.

```bash
git add fichier.sql
```

ou :

```bash
git add .
```

`git add` ne crée pas encore une version. Il prépare la prochaine version.

Exemple :

```text
churn.sql       modifié
README.md       modifié
notes.txt       modifié
```

Si le commit concerne seulement le churn :

```bash
git add churn.sql
```

Le staging sert donc à construire un commit cohérent.

→ [[Staging Area]]

## 📸 8. Commit

Le cours utilise l'image d'une **photo à un instant T**.

```bash
git commit -m "Add customer churn analysis"
```

Un commit enregistre une version dans le repository local.

Bon message :

```text
Add customer churn analysis
Fix duplicated orders after join
Document retention metric
```

Mauvais message :

```text
update
test
changes
```

Un bon commit doit représenter une intention logique compréhensible.

→ [[Commit]]

## 🧭 9. `git status` — le GPS

```bash
git status
```

permet notamment de voir :

- la branche active ;
- les fichiers nouveaux ;
- les fichiers modifiés ;
- les changements staged ;
- si le working tree est clean.

> 🧠 **Réflexe Brocode : perdu dans Git ? Commence par `git status`.**

## 🔬 10. `git diff`

```bash
git diff
```

permet d'inspecter les changements non staged.

Pour inspecter ce qui est prêt à être committé :

```bash
git diff --staged
```

Modèle :

```text
git diff
→ Working Directory vs staging/index

git diff --staged
→ staging/index vs dernier commit
```

Les interfaces présentent généralement :

```text
rouge → supprimé
vert  → ajouté
```

## 🕰 11. `git log`

```bash
git log
```

affiche l'historique.

Version compacte :

```bash
git log --oneline
```

Un historique lisible peut raconter :

```text
initial project
↓
add staging model
↓
add customer tests
↓
fix retention calculation
```

## 🔁 12. Premier workflow à automatiser

```text
MODIFIER
   ↓
SAUVEGARDER
   ↓
git status
   ↓
git diff
   ↓
git add
   ↓
git diff --staged
   ↓
git commit
   ↓
git log
```

Exemple :

```bash
git status
git diff
git add analysis.sql
git diff --staged
git commit -m "Add churn analysis"
git log --oneline
```

## 🌿 13. Branches

La branche principale est généralement appelée :

```text
main
```

Historiquement, de nombreux projets utilisaient `master`.

Une branche permet d'isoler une évolution :

```text
main
●────●────●
          \
feature    ●────●────●
```

Lister :

```bash
git branch
```

Créer :

```bash
git branch feature/customer-cleaning
```

Changer :

```bash
git switch feature/customer-cleaning
```

Le cours montre aussi :

```bash
git checkout feature/customer-cleaning
```

Forme pratique pour créer + basculer :

```bash
git switch -c feature/customer-cleaning
```

→ [[Branch]]

## 🧠 14. Une branche n'est pas une copie manuelle du dossier

Pour débuter, l'image de la « copie de `main` » aide, mais Git ne duplique pas simplement le dossier.

Le Working Directory reflète la branche active.

```bash
git switch main
```

puis :

```bash
git switch feature/customer-cleaning
```

peut donc modifier ce que tu vois dans les mêmes fichiers locaux.

## 📍 15. HEAD

`HEAD` indique où tu te situes actuellement dans l'historique, généralement via la branche active.

```text
HEAD
 ↓
feature/churn
 ↓
●
```

Lorsque tu commits sur cette branche, son pointeur avance.

→ [[HEAD]]

## 🧪 16. Pourquoi ne pas travailler directement sur `main` ?

Dans le modèle du cours :

```text
main
=
code stable / production
```

En Data :

```text
SQL incorrect
↓
table incorrecte
↓
dashboard incorrect
↓
décision métier incorrecte
```

Une branche permet de développer et tester avant intégration.

Le cours présente aussi une organisation :

```text
main
  │
  └── dev
       ├── feature A
       ├── feature B
       └── feature C
```

`dev` sert alors de tampon d'intégration.

> ⚠️ **Complément Brocode**
>
> `main → dev → features` est une stratégie possible, pas une règle universelle de Git. Les équipes peuvent adopter d'autres workflows.

## 👥 17. Collaboration et conflits

Git permet le travail parallèle, mais ne remplace pas la communication.

```text
Git organise les changements
mais
l'équipe organise le travail
```

Un conflit peut apparaître lorsque deux historiques modifient de manière incompatible la même zone.

```text
          ┌── Alice modifie ligne 10
main ─────┤
          └── Brice modifie ligne 10
```

Git demande alors une décision humaine.

Workflow mental :

```text
1. identifier les fichiers en conflit
2. comprendre les deux intentions
3. conserver / combiner le bon contenu
4. supprimer les marqueurs de conflit
5. sauvegarder
6. stage
7. terminer l'opération Git
```

→ [[Merge Conflict]]

## 🌐 18. Local vs Remote

Les commits peuvent exister uniquement sur ton ordinateur.

```text
LOCAL REPOSITORY
      ⇅
REMOTE REPOSITORY
```

Dans le cours, le remote est hébergé sur GitHub.

Trois opérations structurent la relation :

```text
clone
push
pull
```

## 📥 19. `git clone`

```bash
git clone <URL>
```

crée un repository local depuis un repository distant.

```text
REMOTE
  │
  │ clone
  ▼
LOCAL
```

C'est le scénario utilisé dans plusieurs kickstarts du Wagon.

## 🔗 20. `origin`

Pour relier un repository local à un remote :

```bash
git remote add origin <URL>
```

`origin` est le nom conventionnel donné à ce remote.

```text
origin
=
raccourci local vers l'adresse du repository distant
```

Voir les remotes :

```bash
git remote -v
```

→ [[Remote Repository]]

## ⬆️ 21. `git push`

```bash
git push origin main
```

publie des commits locaux vers le remote.

Pour une nouvelle branche :

```bash
git push -u origin feature/customer-cleaning
```

L'option `-u` configure l'upstream ; les push suivants peuvent souvent être réduits à :

```bash
git push
```

```text
LOCAL
  │
  │ push
  ▼
REMOTE
```

## ⬇️ 22. `git pull`

```bash
git pull
```

récupère puis intègre les changements distants selon la configuration.

```text
REMOTE
  │
  │ pull
  ▼
LOCAL
```

Après un merge réalisé sur GitHub, ton `main` local ne se met pas à jour tout seul :

```bash
git switch main
git pull
```

## ⚠️ 23. Commit ≠ Push

Erreur classique :

```text
git commit
≠
envoyer sur GitHub
```

Le bon modèle :

```text
git commit
→ version locale

git push
→ publication vers le remote
```

Donc :

```text
MODIFY
 ↓
ADD
 ↓
COMMIT
 ↓
PUSH
```

## 🌍 24. Créer un repository GitHub depuis un projet local

Le workflow montré dans le cours :

```bash
git remote add origin <URL>
git branch -M main
git push -u origin main
```

Conceptuellement :

```text
repo local
   │
   │ remote add origin
   ▼
adresse distante connue

repo local
   │
   │ push
   ▼
repo GitHub
```

## 🛰 25. `main` vs `origin/main`

Dans les outils comme Git Graph :

```text
main
→ branche locale

origin/main
→ référence locale de l'état distant connu
```

Quand les deux pointent sur le même commit, ils sont alignés à ce point.

## 🔐 26. Pull Request

La **Pull Request (PR)** appartient au workflow collaboratif GitHub.

```text
feature branch
      ↓
push
      ↓
GitHub
      ↓
Pull Request
      ↓
code review
      ↓
validation
      ↓
merge
      ↓
main
```

Une PR signifie :

> « Je propose d'intégrer les changements de cette branche dans la branche cible. »

Elle permet d'ajouter :

- description ;
- reviewers ;
- labels ;
- commentaires ligne par ligne ;
- demandes de modification ;
- validation.

→ [[Pull Request]]

## 🔎 27. Code review

Le reviewer peut vérifier :

```text
lisibilité
logique
tests
maintenabilité
impact
```

Dans un projet Data :

```text
Quel est le grain ?
La clé supposée unique l'est-elle encore ?
Le JOIN duplique-t-il des lignes ?
La métrique est-elle correctement définie ?
Les tests sont-ils suffisants ?
```

La code review relie directement Git aux pratiques de Data Quality.

## 🔀 28. Merge

Le merge intègre les historiques.

```text
feature
   ●──●──●
  /       \
●──●───────● main
```

Après intégration, la branche de feature peut généralement être supprimée.

Les commits intégrés ne disparaissent pas pour autant.

→ [[Merge]]

## ♻️ 29. Revert

Le cours montre le principe de `revert`.

```text
commit problématique
        ↓
revert
        ↓
nouveau commit qui inverse le changement
```

Le commit original reste dans l'historique.

Cela préserve la traçabilité :

```text
problème
+
correction
```

→ [[Revert]]

## 🚫 30. Ce qu'il ne faut pas traquer

Le cours insiste sur :

```text
gros datasets
vidéos
musiques
gros fichiers générés
credentials
passwords
API keys
tokens
```

En Data, l'idée est souvent :

```text
Git
→ versionne la logique

Warehouse / storage
→ contient les données
```

## 🙈 31. `.gitignore`

Exemple :

```gitignore
.env
.DS_Store
*.csv
data/
```

Dans un projet Data :

```text
SQL / Python / dbt / tests / docs
→ oui

credentials / gros datasets
→ non
```

> ⚠️ Ajouter un secret déjà committé à `.gitignore` ne l'efface pas de l'historique. Un secret exposé doit être révoqué / rotaté.

→ [[gitignore]]

## 🔐 32. Secrets — règle absolue

Ne jamais faire :

```python
API_KEY = "abc123..."
```

puis le committer.

Approche :

```python
import os
api_key = os.getenv("API_KEY")
```

avec par exemple :

```gitignore
.env
```

Le secret vit hors du code versionné.

## 🧪 33. Git et tests

Le récapitulatif du cours prépare dbt :

```text
code
↓
tests
↓
validation
↓
construction / déploiement
```

Un test de clé primaire peut par exemple conditionner la suite d'un pipeline.

Cette logique sera approfondie dans [[13 — dbt · Introduction]].

## 🧱 34. Pourquoi Git est fondamental avec dbt

Avec dbt, une transformation SQL devient un fichier de projet :

```text
models/staging/stg_customers.sql
```

Donc :

```text
SQL
→ fichier
→ Git
→ historique
→ branch
→ review
→ merge
```

C'est le passage de :

```text
"j'écris une query"
```

à :

```text
"je maintiens un projet analytique"
```

## 🧠 35. BigQuery ↔ VS Code ↔ Git

Le cours présente le workflow suivant :

```text
BigQuery
→ tester / valider la requête

VS Code
→ conserver le code dans des fichiers

Git
→ versionner les fichiers
```

Avec dbt, ces fichiers deviennent ensuite les modèles structurés du projet.

## 🔄 36. Workflow Git complet du cours

```text
1. git init OU git clone
           ↓
2. se synchroniser avec la branche de référence
           ↓
3. créer une branche
           ↓
4. modifier les fichiers
           ↓
5. git status / git diff
           ↓
6. git add
           ↓
7. git commit
           ↓
8. répéter 4 → 7
           ↓
9. git push
           ↓
10. Pull Request
           ↓
11. code review
           ↓
12. merge
           ↓
13. revenir sur main
           ↓
14. git pull
           ↓
15. nouvelle branche
```

## 🧪 37. Exemple complet — analyse de churn

```bash
git switch main
git pull

git switch -c feature/churn-analysis
```

Modifier :

```text
sql/churn_analysis.sql
```

Puis :

```bash
git status
git diff
git add sql/churn_analysis.sql
git diff --staged
git commit -m "Add churn analysis query"
```

Documentation :

```bash
git add README.md
git commit -m "Document churn definition"
```

Publication :

```bash
git push -u origin feature/churn-analysis
```

Sur GitHub :

```text
Pull Request
feature/churn-analysis
        ↓
main
```

Après review et merge :

```bash
git switch main
git pull
```

Puis nouvelle tâche → nouvelle branche.

## 🧬 38. Complément Brocode — un commit et son historique

L'image de la photo est excellente pour débuter.

On peut approfondir ainsi :

```text
A ← B ← C ← D
```

Chaque commit s'inscrit dans un historique en référençant son ou ses parents.

Les commits possèdent également un identifiant basé sur un hash, souvent affiché sous forme abrégée :

```text
7f3a92c
```

Cela permet d'identifier précisément un point de l'historique.

## 🌿 39. Complément Brocode — une branche est surtout un pointeur

```text
A ← B ← C ← D
            ↑
           main
```

Création d'une feature :

```text
A ← B ← C ← D
            ↑
           main
            ↑
          feature
```

Puis commits sur la feature :

```text
A ← B ← C ← D ← E ← F
            ↑         ↑
           main     feature
```

Cette représentation explique pourquoi une branche est légère : Git ne crée pas simplement une deuxième copie physique complète du projet.

## 📥 40. Complément Brocode — fetch vs pull

Le cours se concentre sur `pull`.

Pour compléter le modèle :

```bash
git fetch
```

récupère les informations du remote sans intégrer directement les changements à la branche courante.

```text
fetch
→ récupérer / observer

pull
→ récupérer + intégrer
```

## 🔀 41. Complément Brocode — merge vs Pull Request

```text
Merge
→ opération Git d'intégration

Pull Request
→ workflow de discussion / review / validation sur GitHub
```

On peut merger localement, mais le cours privilégie le workflow collaboratif par PR.

## 🏭 42. Complément Brocode — branche et environnement

Le cours assimile pédagogiquement :

```text
main = production
dev = tampon
```

C'est une convention de workflow utile, mais une branche Git n'est pas à elle seule un environnement de production.

En entreprise, la mise en production peut aussi dépendre de :

```text
CI/CD
permissions
jobs
targets
environnements
tests
```

## 🧰 43. Git Graph dans VS Code

Le cours recommande **Git Graph** pour visualiser :

- commits ;
- branches ;
- merges ;
- références distantes ;
- divergence entre branches.

Exemple :

```text
●────●──────────● main
      \        /
       ●──●──● feature
```

Lecture :

```text
feature créée depuis main
↓
plusieurs commits
↓
intégration dans main
```

## 🧠 44. Les erreurs mentales fréquentes

| Erreur | Correction |
|---|---|
| `git add` sauvegarde mon fichier | la sauvegarde appartient à l'éditeur ; `add` stage |
| `git commit` envoie sur GitHub | commit = local |
| `git push` crée le commit | push publie des commits existants |
| Git = GitHub | outils différents |
| branche = copie manuelle du dossier | branche = ligne/pointeur d'historique |
| conflit = repository cassé | ambiguïté nécessitant une décision |
| `.gitignore` efface un secret déjà committé | non |

## 🧯 45. Quand on est perdu

Observer avant d'agir :

```bash
pwd
git status
git branch
git log --oneline
git remote -v
```

Questions :

```text
Suis-je dans le bon dossier ?
Quelle branche est active ?
Ai-je des changements non commités ?
Quel est l'historique récent ?
Quel remote est configuré ?
```

Éviter de lancer au hasard des commandes de reset, nettoyage ou force push.

## ⚠️ 46. Commandes à traiter avec prudence

À ne pas exécuter mécaniquement sans comprendre leur portée :

```text
rm -r
git reset --hard
git clean
force push
```

Principe :

> **Une commande qui supprime, force, reset ou nettoie mérite une vérification avant exécution.**

## 🧾 47. Cheat sheet — Git local

| Besoin | Commande |
|---|---|
| Initialiser | `git init` |
| État | `git status` |
| Diff non staged | `git diff` |
| Diff staged | `git diff --staged` |
| Stage un fichier | `git add fichier` |
| Stage les changements du chemin courant | `git add .` |
| Commit | `git commit -m "message"` |
| Historique | `git log` |
| Historique compact | `git log --oneline` |
| Branches | `git branch` |
| Changer de branche | `git switch nom` |
| Créer + changer | `git switch -c nom` |

## 🧾 48. Cheat sheet — Remote / GitHub

| Besoin | Commande |
|---|---|
| Cloner | `git clone <URL>` |
| Voir les remotes | `git remote -v` |
| Ajouter `origin` | `git remote add origin <URL>` |
| Renommer en `main` | `git branch -M main` |
| Premier push + upstream | `git push -u origin <branche>` |
| Push suivant | `git push` |
| Récupérer + intégrer | `git pull` |
| Récupérer sans intégrer directement | `git fetch` |

## 🧾 49. Cheat sheet — vocabulaire

| Terme | Modèle mental |
|---|---|
| Repository | projet suivi par Git |
| Working Directory | fichiers de travail |
| Staging Area | sélection du prochain commit |
| Commit | version / snapshot logique |
| Branch | ligne de développement |
| `main` | branche principale par convention |
| HEAD | position courante |
| Remote | repository distant référencé |
| `origin` | nom conventionnel du remote principal |
| Push | local → remote |
| Pull | remote → local + intégration |
| Clone | remote → nouveau repo local |
| Pull Request | proposition d'intégration + review |
| Merge | intégration d'historiques |
| Conflict | arbitrage automatique impossible |
| Revert | nouveau commit inverse |
| `.gitignore` | exclusions de suivi |

## 🎤 50. Questions d'entretien

### Git vs GitHub ?

Git est un système de contrôle de version distribué. GitHub héberge des repositories Git et fournit des fonctionnalités collaboratives.

### `git add` vs `git commit` ?

`git add` sélectionne l'état des changements pour le prochain commit. `git commit` enregistre ce contenu dans l'historique local.

### Commit vs push ?

Commit crée une version locale ; push la publie vers un remote.

### Pourquoi une branche ?

Pour isoler une évolution, travailler en parallèle et permettre test/review avant intégration.

### Qu'est-ce qu'une Pull Request ?

Une proposition d'intégration entre branches avec un espace de discussion, review et validation.

### Qu'est-ce qu'un merge conflict ?

Une situation où Git ne peut pas combiner automatiquement des modifications concurrentes et demande une décision humaine.

### Pourquoi committer régulièrement ?

Pour créer des unités de changement plus petites, compréhensibles, testables et plus faciles à corriger ou annuler.

## 🧪 51. Exercice mental — où vit le changement ?

Tu modifies et sauvegardes `orders.sql` :

```text
Working Directory
```

Puis :

```bash
git add orders.sql
```

```text
Staging Area
```

Puis :

```bash
git commit -m "Fix orders"
```

```text
Local Repository
```

Puis :

```bash
git push
```

```text
Remote Repository
```

## 🧠 52. Les 15 idées à retenir

1. **Git ≠ GitHub.**
2. Git versionne le code et son historique.
3. `git status` est le GPS du workflow.
4. Sauvegarder dans VS Code ≠ staging.
5. `git add` prépare le prochain commit.
6. `git commit` crée une version locale.
7. `git push` publie vers un remote.
8. `git pull` récupère et intègre les changements distants.
9. Une branche isole une ligne de travail.
10. Une PR organise review et validation.
11. Un merge intègre les historiques.
12. Un conflit demande un arbitrage humain.
13. Les petits commits cohérents rendent l'historique utile.
14. Secrets et gros datasets n'ont généralement pas leur place dans Git.
15. Git devient une fondation directe du workflow dbt.

## 🧠 53. Modèle mental final

```text
                     GITHUB
                       │
                 Pull Request
                 Code Review
                     Merge
                       │
        ┌──────────────┴──────────────┐
        │                             │
   origin/main                 origin/feature
        ▲                             ▲
        │ pull                        │ push
        │                             │
      main                       feature
                                     ▲
                                     │ commit
                              LOCAL REPOSITORY
                                     ▲
                                     │ git commit
                                STAGING AREA
                                     ▲
                                     │ git add
                              WORKING DIRECTORY
                                     ▲
                                     │
                                  VS CODE
```

> **Je travaille localement sur une branche, je sélectionne des changements cohérents, je les enregistre dans des commits, je publie la branche, je fais relire les changements, je les intègre dans la branche de référence, puis je resynchronise mon environnement local.**

## 🔗 54. Connexions Brocode

- [[13 — dbt · Introduction]]
- [[Version Control]]
- [[Repository]]
- [[Commit]]
- [[Staging Area]]
- [[Branch]]
- [[HEAD]]
- [[Remote Repository]]
- [[Pull Request]]
- [[Merge]]
- [[Merge Conflict]]
- [[Revert]]
- [[gitignore]]
- [[Granularité]]

## ✅ 55. Actions post-session

- [ ] Installer **Git Graph** dans VS Code.
- [ ] Répéter les commandes de navigation terminal.
- [ ] Automatiser mentalement `status → diff → add → commit`.
- [ ] Répéter `branch → work → push → PR → merge → pull`.
- [ ] Faire au moins une résolution de conflit en binôme.
- [ ] Vérifier la branche active avant de travailler.
- [ ] Ne jamais committer de credentials.
- [ ] Écrire des messages de commit explicites.

## 🏁 56. Résumé en une phrase

> **Git transforme un dossier de code en historique structuré : on travaille dans le Working Directory, on sélectionne avec le staging, on enregistre avec des commits, on isole les évolutions dans des branches, puis GitHub permet de publier, relire et intégrer ces changements en équipe.**

---

## 📎 Annexe — source brute de la session

La transcription complète et les notes de session ont servi de base à ce chapitre. Le bloc ci-dessous est conservé comme archive brute afin que rien du matériau du cours ne soit perdu lors de cette première version Brocode v2.

<details>
<summary>Afficher la transcription / les notes brutes</summary>

## 📝 #12 - Git and versioning

**Date : 21 juillet 2026**

**Thème :**

**Tags :** 

**Compréhension (1→5) :** ⭐

---

#### 📝 **NOTES**

![Capture d’écran 2026-07-21 à 09.12.11.png](%F0%9F%93%9D%20#12%20-%20Git%20and%20versioning/Capture_decran_2026-07-21_a_09.12.11.png)

![Capture d’écran 2026-07-21 à 09.18.53.png](%F0%9F%93%9D%20#12%20-%20Git%20and%20versioning/Capture_decran_2026-07-21_a_09.18.53.png)

![Capture d’écran 2026-07-21 à 09.19.04.png](%F0%9F%93%9D%20#12%20-%20Git%20and%20versioning/Capture_decran_2026-07-21_a_09.19.04.png)

![Capture d’écran 2026-07-21 à 09.19.39.png](%F0%9F%93%9D%20#12%20-%20Git%20and%20versioning/Capture_decran_2026-07-21_a_09.19.39.png)

![Capture d’écran 2026-07-21 à 09.23.06.png](%F0%9F%93%9D%20#12%20-%20Git%20and%20versioning/Capture_decran_2026-07-21_a_09.23.06.png)

![Capture d’écran 2026-07-21 à 09.24.50.png](%F0%9F%93%9D%20#12%20-%20Git%20and%20versioning/Capture_decran_2026-07-21_a_09.24.50.png)

![Capture d’écran 2026-07-21 à 10.01.58.png](%F0%9F%93%9D%20#12%20-%20Git%20and%20versioning/Capture_decran_2026-07-21_a_10.01.58.png)

![Capture d’écran 2026-07-21 à 10.04.38.png](%F0%9F%93%9D%20#12%20-%20Git%20and%20versioning/Capture_decran_2026-07-21_a_10.04.38.png)

![Capture d’écran 2026-07-21 à 10.14.32.png](%F0%9F%93%9D%20#12%20-%20Git%20and%20versioning/Capture_decran_2026-07-21_a_10.14.32.png)

![Capture d’écran 2026-07-21 à 10.14.56.png](%F0%9F%93%9D%20#12%20-%20Git%20and%20versioning/Capture_decran_2026-07-21_a_10.14.56.png)

#### 💡 **Ce que j’ai retenu**

#### ❓ Questions / Points flous

- [ ]  
- [ ]  

#### 🔗 Liens avec d’autres notions

#### ✅ Actions post-session

- [ ]  
- [ ]  

#### 🔗 Transcription

Résumé

#### Actions à réaliser

- [ ]  Installer l'extension **Git Graph** dans VS Code pour visualiser les branches
- [ ]  Copier-coller le kickstart fourni pour chaque challenge dans le terminal Ubuntu
- [ ]  Réaliser le premier exercice de prise en main du terminal (commandes de navigation)
- [ ]  Réaliser les exercices Git à partir du deuxième challenge
- [ ]  Faire l'exercice en binôme sur les conflits Git

---

#### Contexte de la session

- Session de formation (probablement Le Wagon) portant sur le terminal, Git et GitHub
- Outils utilisés : terminal Ubuntu, VS Code, Git en ligne de commande
- Git sera la fondation de **DBT** qui sera abordé dès le lendemain

---

#### Commandes de base du terminal

- `pwd` — affiche le répertoire courant (*Print Working Directory*)
- `ls` — liste les fichiers du dossier courant
- `mkdir` — crée un nouveau dossier (*Make Directory*)
- `cd` — change de répertoire ; `cd ~` revient au dossier racine  ; `cd ..` remonte d'un niveau
- `touch fichier.txt` — crée un fichier vide
- `cp` — copie un fichier ; `mv` — déplace un fichier
- `rm -r` — supprime un dossier et tout son contenu, à utiliser avec parcimonie
- `echo "texte" > fichier.txt` — écrit du texte dans un fichier
- `tree` — affiche l'arborescence complète des dossiers
- `code .` — ouvre le dossier dans VS Code
- La **tabulation** permet l'autocomplétion des noms de fichiers et dossiers
- Le terminal Ubuntu tourne dans un environnement virtuel WSL ; les fichiers se trouvent dans `/home/[user]`

---

#### Concepts Git

- **Git** : outil de versioning qui traque les changements dans le code et facilite la collaboration
- Utilisé par ~84% des développeurs ; indispensable en entreprise
- **Repository (repo)** : dossier traqué par Git, initialisé avec `git init`
- **Commit** : "photo" à un instant T des changements effectués, constituant une version
- **Staging** : étape intermédiaire où l'on sélectionne les fichiers à inclure dans le prochain commit
- Les changements sont visibles **ligne par ligne** : lignes ajoutées en vert, supprimées en rouge

---

#### Commandes Git essentielles

- `git init` — initialise le tracking Git dans un dossier
- `git status` — affiche l'état des fichiers (modifiés, non trackés, staged)
- `git add .` — ajoute tous les fichiers modifiés au staging
- `git add fichier.txt` — ajoute un fichier spécifique
- `git commit -m "message"` — crée une version avec un message descriptif
- `git log` — affiche l'historique de tous les commits
- `git diff` — affiche les modifications exactes depuis le dernier commit
- **Bonne pratique** : committer régulièrement pour faciliter les retours en arrière

---

#### Branches Git

- La branche principale s'appelle **main** (anciennement *master*) : c'est le code en production
- **Principe** : on ne travaille jamais directement sur `main` pour ne pas impacter les utilisateurs
- **1 feature = 1 branche** ; exemple : `feature/nettoyage-table`
- `git branch` — liste les branches existantes
- `git branch feature-1` — crée une nouvelle branche
- `git switch feature-1` ou `git checkout feature-1` — change de branche
- Les branches sont **décorrélées** : les fichiers reflètent la branche active
- **Workflow typique** : créer une branche → faire ses commits → push → pull request → merge dans main
- Structure courante en entreprise : `main` (production) → `dev` (tampon) → branches de feature
- L'environnement `dev` sert de tampon pour tester les combinaisons de features avant la mise en production
- Après le merge d'une feature, **supprimer la branche** est une bonne pratique

---

#### GitHub et travail en équipe

- **GitHub** (aussi GitLab, Bitbucket) : plateforme web pour héberger les repos en ligne et collaborer
- `git remote add origin [URL]` — lie le repo local au repo distant
- `git push origin main` — envoie les commits locaux en ligne
- `git pull` — rapatrie les changements distants en local
- `git clone [URL]` — clone un repo existant en ligne vers sa machine
- **Pull Request (PR)** : demande de merge d'une branche vers `main`, permettant une revue de code par un collègue
    - On peut ajouter des reviewers, des labels, des commentaires sur des lignes précises
    - Le reviewer valide ou demande des corrections avant le merge
- **Revert** : possible via les PR fermées pour annuler un merge sans supprimer l'historique

---

#### Ce qu'il ne faut PAS traquer avec Git

- Fichiers volumineux : images, vidéos, musiques, données brutes ou transformées
- **Credentials et mots de passe** : même sur un repo privé, ne jamais les committer
- Utiliser `.gitignore` pour exclure certains types de fichiers
- Git est fait pour traquer **la logique de code**, pas les données

---

#### Bonnes pratiques et points de vigilance

- **Communiquer** sur qui fait quoi pour éviter les conflits
- Bien **découper les tâches** : chacun travaille sur des fichiers différents
- Les **conflits** (deux personnes modifient le même fichier) sont gérables mais coûteux : Git demande de choisir quelle version conserver
- **Committer régulièrement** et **pousser ses branches en ligne** régulièrement
- Utiliser des **messages de commit clairs et descriptifs**

---

#### Visualisation avec Git Graph (VS Code)

- Extension **Git Graph** dans VS Code permet de visualiser l'arborescence des branches et commits
- Affiche les branches locales et distantes (préfixe `origin/` = branche uniquement en ligne)
- Accessible via un bouton en bas de VS Code

---

#### Exercices prévus

- **Exercice 1** : prise en main du terminal — `pwd`, `cd`, `ls`, `touch`, `rm`, déplacement dans les dossiers
- **Exercices suivants** : workflow Git complet (add, commit, branches)
- **Exercice binôme** : simulation de conflit Git, résolution manuelle
- Chaque exercice fournit un **kickstart** à copier-coller pour initialiser le dossier et lancer les tests

Notes

Transcription

J'ai pas eu de message moi perso. Il a mis un message sur Slack, il a dit j'aurais un peu de retard. Ok, merci.

Alors c'est bon, vous avez tous votre thé, café, tout ça, vous êtes prêts ?

Je crois que c'est surtout le USB-C qui fonctionne bien.

Hier, ça marchait avec le USB-C, le câble blanc. Ouais, mais le PC, il ne marche pas avec le USB-C. Moi, la semaine dernière, on disait que c'était la même salle et ça marchait très bien avec l'autre.

Ok, c'est moi pour le petit retard technique, on est bon pour tout le monde ? Ok, donc aujourd'hui, on aborde des nouvelles notions, là on sort un peu de l'estuel et tout ça. Vous allez bien retrouver par-ci, par-là... qui sont anglais souhaits, mais peut-être beaucoup moins aujourd'hui d'ailleurs, plutôt à partir de demain. Aujourd'hui...

Donc voilà, c'est une très belle logique qui est quitte et quittable. Donc vous avez peut-être déjà entendu parler de ces termes-là, mais on va y aller.

un tout petit peu un tout petit peu ok très bien aujourd'hui on va rappeler les bases

Donc, pour ce faire, on va parler en même temps de Git, et quand on parle de Git, on va parler du Terminal. Le fameux truc de Hatcher qu'on voit dans les films. C'est ce que vous avez normalement tout set-up dès le premier jour, donc on va revenir sur ce terminal-là et vous allez travailler principalement avec aujourd'hui et aujourd'hui.

et aussi beaucoup demain et après-demain.

Pour survivre dans le terminal, il y a quelques petites commandes de navigation qui sont détaillées juste après.

Donc, c'est des comptes que vous allez normalement utiliser tout le temps quand vous êtes sur le terminal.

PWD pour Print Working Directory. Tous les petits mots clés comme ça, généralement, c'est des abréviations. Donc le Print Working Directory, ça vous affiche... actuellement, où vous vous situez, dans votre dossier, vous êtes situé actuellement. Ça, c'est le PNVD, donc c'est important, évidemment, pour voir où vous êtes et ce que vous allez nous dire.

Ls pour liste, ça vous liste en gros tous les fichiers qui sont dans le dossier auquel vous êtes. MKDIA Coursy pour Make Directory, ça vous crée un dossier. CD, ça c'est pour Change Directory, donc comme son nom l'indique, ça va vous changer votre direction de dossier, donc vous allez mettre...

Généralement, on passe, on va voir des petits raccourcis tout à l'heure pour aller naviguer dans les dossiers de votre PC. Justement, pour changer votre pré-nouvellé.

Le petit touch, simplement, c'est pour créer un fichier, donc si vous mettez le touch hello.txt, ça va vous faire un fichier .txt par exemple.

Cp pour copy, md pour move, c'est l'option de choisir un ctrl x ou un ctrl v, ou ce qu'on veut d'autre. Et lmr à utiliser tirer r, à utiliser avec parsimonie parce que là ça vous supprime le dossier et tout ce qu'il y a dedans, tout ce qui est sous la scène derrière.

C'est les quelques petites commandes de base que vous allez utiliser pour vous y retrouver un peu dans le targal. N'hésitez pas à y revenir si ce n'est pas clair. De toute façon, tout le monde est challenge, c'est assez guidé, vous n'allez pas trop

Je n'ai pas du tout égoskié, il y a plein de cheat sheets avec qui on partagerait, par la suite, qui me permettent de les retrouver et de naviguer sur pas mal de choses dans le tableau. Alors, à partir d'aujourd'hui, vous n'allez pas encore trop utiliser le jus de termes de boucle, ça sera plutôt sur les jeux Mpito bien entendu, mais vous allez par contre utiliser l'autre outil qui va être le VS Code, le Visual Studio Code, pour justement visualiser vos fichiers, les modifier, etc.

Vous allez utiliser le VS Code en plus du terminal, notamment. C'est tout.

Ok, donc tout ça, ça nous amène à Git, où c'est un truc que vous avez installé normalement le premier jour, qui fonctionne notamment grâce à ce terminal-là.

Le Git, qu'est-ce que c'est ? Certains d'entre vous le savent déjà, c'est l'outil principal pour traquer les changements dans votre code.

Et vous n'avez en contrepartie pas le seul guide qui est sur votre PC et où on va voir Kitev qui est en ligne et qui est un site sur le web. de retrouver un peu les changements que vous avez faits et de travailler avec des personnes en plus qui a cette logique guide derrière, c'est pas le seul, vous avez le GitLab, vous avez du PQF, il y en a plein d'autres.

Donc, Git, vous avez utilisé, comme je viens de vous le dire, pour le versionner, en gros, pour traquer les changements dans votre code. Vous avez aussi utilisé, pour collaborer avec les personnes, parce qu'on peut voir qu'on peut faire ce qu'on appelle des branches, on peut faire un terme après.

Chacun travaille dans son coin, et après, on réunit tout ça.

Pourquoi c'est important de savoir tout ça ? C'est parce que vous allez, à partir de demain, notamment utiliser DBT, qui est un outil qui me dira d'adapter tout, voilà.

On voit un, l'étape, l'adrège, etc. Donc DBG, ça va vous permettre de regrouper un peu toutes ces étapes-là en termes de logique. Vous le verrez demain. Mais du coup, ça fonctionne sous-jacent avec une logique de Git, en tant que versionning, de branche, etc.

Donc c'est quand même important de comprendre qu'aujourd'hui... ce que vous faites, parce que demain, ça reposera sur ces bateaux. Ok. Alors, pourquoi c'est important pour vous en tant qu'atelier ? Je viens un peu de le dire. Dans l'idée, vous allez avoir des outils dédiés, comme des BD, qui sont très, très utilisés dans l'industrie, et qui reposent sur des logiques guidées.

l'utilisation de ligne pour travailler ensemble. Et globalement, quand vous allez pouvoir modifier des fichiers, ça va être important pour vous aussi. Également. Si on prend un exemple, vous êtes sur une création de fichier texte, vous étiez en train de faire votre rapport de matériel.

Merci. Près de votre mémoire, quand vous allez travailler sur votre mémoire, vous créez votre fichier, vous le sauvegardez, vous l'éditez, vous le sauvegardez, vous répétez jusqu'à la fin, jusqu'à la fin, qu'il soit tout. Ça c'est un peu le workflow classique.

on change les problématiques, etc. C'est tout ce que vous allez faire classiquement, ce que vous avez peut-être déjà fait. Et à la fin, on vous retrouve avec un truc qui est report matin, finale édition, jeunes et versions, dalles, finale édition. Moi je l'ai fait en tout cas quand j'ai fait mon mémoire.

L'idée, si on travaille en communauté avec des collègues, c'est un peu compliqué si on se retrouve avec ça sur les noms de nos fichiers. Si on faisait en mode manuel ce contrôle de version, l'idée c'est d'introduire notamment Git qui va nous aider à faire des versions plus logiques et plus propres.

Parce qu'en effet, on veut automatiser un peu ce workflow de création de version, c'est-à-dire que vous devez finir par savoir quand est-ce que le fichier a été modifié, qu'est-ce qui a été changé dans le fichier, et aussi pourquoi ça a été modifié derrière.

Notamment, ça, c'est aussi de le retrouver en termes d'équipe. C'est-à-dire que vous n'êtes pas forcément les seuls à travailler sur votre dossier. votre dossier ou votre fichier, votre projet data, entre guillemets, donc il y a une personne qui fait cette partie-là, en bleu c'est une autre personne, etc. Donc l'idée c'est aussi d'automatiser cette logique de la surnom au sein d'une équipe.

et de rappeler aussi en fait qui fait sur le monde en plus de ces trois deux enfants. Et ça, du coup, si vous utilisez Git, ça va vous permettre en effet de traquer. proprement ces différents documents de leur personne, d'avoir cet historique et de travailler en équipe.

En terme de résumé, ce que vous allez retrouver, alors ça vous allez le retrouver plutôt sur la partie github.com, on peut le retrouver rapidement sur...

ça a été changé avec un petit message et derrière si on clique techniquement sur ce qu'on appelle un commit, une version, on peut aller retrouver exactement les fichiers qui ont été changés. Ça vous permet de voir dans un premier temps ici à gauche tous les fichiers

qui ont été traquées et ceux qui ont été modifiés surtout dans ce comic-là. Et si on clique sur un fichier modifié, vous allez pouvoir avoir dans le détail toutes les lignes de ce sujet-là, en vert celles qui ont été ajoutées et en rouge celles qui ont été supprimées.

Donc ça vous permet vraiment d'avoir... C'est quelque chose d'assez coupé là-dessus. Sachez par contre que tout ce qui se met en une ligne, elle est considérée modifiée ou supprimée, même si vous le supprimez avec un caractère. Ça ne se fait pas caractère par caractère, ça se fait ligne par ligne.

C'est cette petite couleur-là qui nous permet de voir rapidement ce qui est modifié et ce qui est supprimé. Donc ça, c'est la coule bien enrhumée. Et Git, c'est utile quand on fait du DEM, parce que là, on a le petit Datastat qui est quasiment 84% d'élèves qui utilisent Git. Et ceux qui ne l'utilisent pas, j'imagine qu'ils font du DEM.

des petits projets en solo ou des trucs un peu dans leur camp. Parce que c'est un peu indispensable quand on va travailler en équipe ou dans une boîte. C'est très important, même si vous me faites un petit peu de dette par la suite, de vous connaître et de vous soutenir également. Et je le rappelle, comme je l'ai dit tout à l'heure, mais c'est les fondations de DVD que vous allez voir à partir de demain.

Je vous dis qu'un sujet un petit peu vite, là c'est plutôt la conceptualisation, qu'on fera un petit exemple bien entendu après. Alors techniquement, il y a deux façons d'utiliser... Il y a ce qu'on va voir aujourd'hui, c'est ce qu'on appelle le CLink, les commandes blindes d'interface qui sont vraiment déterminables, pour écrire vos petites lignes de code, etc. Et il y a les façons avec des interfaces utilisateurs que vous avez.

On parlait tout à l'heure de GitHub.com en ligne, vous avez la version locale qui est GitHub Desktop qui vous permet d'avoir une interface, si vous êtes vraiment allergique, on va dire, au livre. Mais c'est quand même le plus utilisé dans l'entreprise, ça va être le terminal, les commandes blindes interfaces.

On va apprendre cette partie là, et du coup si vous comprenez la logique ici, vous n'aurez aucun mal à utiliser une interface graphique par la suite si jamais, si vous êtes dans votre boîte.

Ok, donc les principes de guide, il y a une petite terminologie à comprendre derrière.

c'est le dossier qui va être traqué par Git. À l'intérieur de ce dossier-là, quand Git est initialisé, en fait, ça va traquer les versions que je fais dedans. On peut gérer évidemment ce qu'on traque de bas, mais quand on parle de l'écho, en gros c'est le dossier global qui est traqué par Kit et la logique de Mathieu.

Vous avez l'image d'appareil photo, l'idée c'est de prendre une petite photo à l'instant T des changements qu'on a faits. On va par exemple faire 2-3 changements, on va faire une petite commande dans les commits et ça va vous faire votre version. On parle d'une commit, en gros on parle d'une version.

et ça vous permet d'avoir une photo à l'instant T et potentiellement de revenir aussi si on s'est planté sur ce tutoriel. Donc on parle de comique, on parle vraiment de sauvegarde d'instant. et ça va être notre version à cet enceinte là.

Ok, dans l'idée, je vous parlais des commits, en effet, quand on va faire des changements sur nos fichiers, vous allez créer, modifier, supprimer des fichiers, tout ça c'est des changements. Vous allez ensuite, on va le voir à travers une petite commande, faire ce qu'on appelle une partie de staging. On va vous marquer les fichiers que vous voulez traquer dans la version.

La plupart du temps, on traque tout ce qu'on a changé. Ça peut arriver que si, vraiment, vous faites plein de modifs, on veut traquer quelques dossiers en un groupe, ça peut arriver, mais c'est pas... Généralement, vous n'avez pas trop... Vous allez juste prendre tous vos dossiers que vous avez modifiés et vous allez y aller. Mais voilà, vous avez quand même cet état de staging, où on vous dit, ok, on va ajouter tel, tel, tel dossier dans cette version, pour dire, ok, je fais une photo à un sentier de cette version-là avec...

avec les fichiers que l'on a sélectionnés. Et ça, vous devez le compter assez régulièrement, parce que l'idée, c'est de le compter régulièrement pour avoir des petites versions. C'est plus facile de revenir, en gros, sur une version.

Je veux revenir sur une version que vous avez enregistrée il y a une semaine, sinon vous allez perdre le travail d'une semaine. En termes de logique...

de pouvoir faire des commits, des versions assez régulières de votre travail pour justement pas te perdre si jamais il y a quelque chose que vous avez... créé, qui fait publier et qu'on attend de revenir sur une version précédente. En termes de logique, essayez de committer assez régulièrement votre travail.

Ok, ça va, ça a tout sort, penses-t'on? Ouais.

On va faire un petit exemple maintenant. Je vais aller sur mon terminal et on va se créer un petit fichier et on va initier les équipes. Alors aujourd'hui vous allez utiliser du coup le terminal via Ubuntu, apparemment c'est ce petit logo Ubuntu là. Vous pouvez aussi le rechercher si vous ne le voyez pas dans votre terminal.

Avec ce que vous avez installé normalement au début du wagon, ça devrait ressembler à ça, vous allez arriver, il n'y aura pas écrit grand-chose.

Généralement, vous avez du setup en password, ils devraient vous demander de vous connecter peut-être. Vous arrivez là-dessus. Là, vous voyez... On a un petit tile, en gros ça veut dire qu'on est à la maison, on est au dossier rationnel. Si vous voulez voir justement explicitement où vous êtes, le petit mot P c'est PWD. Ça, ça veut dire que tu es dans slash home slash faux corps.

Donc ça c'est le dossier dans lequel je me situe actuellement.

Là on peut regarder par exemple qu'est-ce qu'il y a dedans, si je me fais un petit ls, qu'est-ce que j'ai dedans, donc j'ai que un sous-dossier, donc je peux acheter des codes. plus précisément ce dossier-là et tous les sous-dossiers. Si je fais un petit tri, généralement arbre, vous voyez, là, c'est tout ce qu'il y a. Actuellement, je suis ici, dans le coin. Ensuite, il y a code. Et dans le code, j'ai un sous-dossier, le coin, un sous-dossier, le wagon.

Et dans ces dossiers-là, j'ai plein de trucs. Donc le tri, ça vous permet vraiment d'avoir la reconnaissance complète des dossiers.

En dessous du thème, vous êtes. Je n'arrive pas bien à comprendre où est-ce qu'on est là. C'est quoi homme francois ? C'est en gros... quand vous avez installé WSL qui est en gros un petit environnement virtuel. Vous pouvez l'ouvrir d'ailleurs avec explorer.exe

C'est la partie virtuelle que vous avez installée au début de ce groupe complet. Ce n'est pas tout à fait des dossiers classiques sur le PC. Nous, on se situe là dans Broom, au Chocoa, et derrière, en fait, c'est Ubuntu et tous les dossiers qui ont été installés pour que ça fonctionne, c'est OS virtuel.

Là vous êtes dans une petite partie virtuelle, dont on se situe dans la partie home de cet entourement virtuel.

dossier actuel, un dossier assez sympa à utiliser, je vous mets un petit peu d'ailleurs en radio peu, ok donc là pour rappel en effet si je fais pwd, je suis vraiment bien dans slash home slash quoi, vous savez mon dossier de base avec les setup en gros comme

Maintenant, si je veux me déplacer dans mes dossiers, on va le faire avec le site Sidi. Et Sidi, si je fais une tabulation, là, automatiquement, j'ai que... Une seule possibilité, c'est code.

ça ouvre toutes les possibilités du terminal à partir de ces... Ah ok. Pardon, c'est super compliqué. Vous faites CD espace. Ah oui. Et vous avez... Ça marche. ...toutes les possibilités... sur lesquels aller. Donc là, j'ai 3 possibilités. Je peux aller dans mon coin, au-dessus du wagon, par exemple, et je peux continuer l'établissation. S'il n'y a pas de possibilité, il m'envoie...

et là je suis dans un dossier spécifique d'exercice que vous allez aller voir demain et si je fais un petit pwd, vous voyez là j'ai vraiment tout l'arbre à essai sur laquelle je suis allé C'est un dossier qui est dans l'intro de Data Transformation, etc.

Donc c'est pas où je voulais aller, si jamais vous voulez revenir rapidement au dossier principal vous pouvez faire CD et le petit tile comme vous voyez tout à l'heure affiché en haut, CD tile, vous laissez à vous, on y reviendra à 8h. S'il vous plaît, ça vous remontre à la maison du monde.

On va se déplacer, on va aller dans... Ouais, je vais juste aller dans...

et là on va se faire un petit dossier exemple, pour faire un petit dossier en gros c'est mkdir donc vraiment make directory, et là on peut lui donner un nom qu'on a envie. Voilà des exemples pour...

Je suis toujours dans le code, je n'ai pas changé d'endroit. Si je regarde ce qu'il y a dans le code, il y a ce que j'avais avant, le wagon, mais il y a en plus ce que je viens de créer qui est exemple de cours. Maintenant je peux aller naviguer dans ce dossier avec cd, je suis bien dans mon endroit et je peux faire explore.exe

pour l'ouvrir et le visualiser dans mon dossier. Vous voyez que là, pour l'instant, j'ai créé un dossier vide avec l'un dedans, pour monter dans l'armoire, certainement. Une boîte qui est bien ici, avec... à l'écrisure 1.0

et du coup voyez tout ce que je fais avec l'interface souris et clavier, on peut le faire avec les lumières du courant

Et maintenant, pour vous montrer aussi, on peut créer des fichiers, comme vous l'avez dit, à partir de rien. Donc là, je me suis mis dans... Dossier exemple court, je peux faire un petit touch et dire ok on va faire un petit dossier, un petit fichier hello.txt

qui va être mon fichier texte là-dessus. Et si je regarde ce que j'ai dedans maintenant, donc exemple pour LS, ma liste, ce qu'il y a dedans, j'ai bien mon petit fichier. et le texte. Et si je vais le revoir ici...

Si je veux remonter simplement d'un petit cran, je peux faire un CD, ça remonte juste d'un cran. Si j'ai oublié le nom du dossier au-dessus, c'est des frampons, ça remonte d'un cran. Pareil, on peut rappeler ces détails, là ça remonte à la racine. Par contre, si je veux descendre, là, je suis obligé d'appeler CD, le dossier que j'ai envie, le code. Ensuite, je vais dans Exemples courts.

je suis obligé, quand je descends, de taper, évidemment, les choses.

Sous-titres réalisés para la communauté d'Amara.org

Tout ça, c'est du terminal, on va dire un petit peu basique, les quelques premières lignes de commandes que vous pouvez utiliser pour naviguer. Si je peux vous montrer aussi comment modifier directement un fichier à partir de votre Un vide de commande, parce que c'est tout à fait possible. Et j'ai créé un petit fichier texte. Si j'avais envie de raconter des...

également. Je ne suis pas obligé de passer par l'éditeur de texte ou par DeskCode ou d'autres. Je peux simplement dire, OK, Echo, qu'est-ce que je vais mettre dedans ?

Ok, où est-ce que tu vas le mettre, la petite flèche, tu vas le mettre dans, par exemple, si je fais tab, où est-ce que je vais le trouver ?

Ah, vous ne m'avez pas dit, mais j'ai oublié de fermer mon... Le guillemet ? Le guillemet. On essaie ?

Si je veux rajouter un truc dedans, je fais un coup d'écho et ça va faire l'exemple. Et normalement, si je fais tabulation, il me le détecte automatiquement, c'est beaucoup mieux. Donc si je fais écho exemple texte, pareil, je peux aller explorer.

Et j'ai bien maintenant mon petit texte qui s'est marqué dans mon petit texte. Donc techniquement on peut modifier avec Echo nos fichiers de cette façon là. Je ne sais pas si vous allez le faire le plus souvent, mais c'est juste pour que vous le montriez. Donc là, pour l'instant, je n'ai toujours pas mes 6 équipes. J'ai vraiment juste fait des commandes.

Alors pour utiliser Git, normalement vous l'avez tous installé, la première étape c'est, si je veux, on va dire setup un dossier pour qu'il soit traqué et tout ce qu'il y a dedans soit traqué, c'est sur un petit git init. Ça, vous voyez, ça va initialiser un repo qui va être ici. Et dedans, vous allez avoir, du coup, un dossier qui est caché par défaut, qui est le .git.

Si je fais ls, il n'apparaît pas, mais si je fais un petit ls et là ça me permet d'afficher des fichiers cachés. Vous voyez que là j'ai des fichiers cachés qui sont liés.

Ça, vous ne les voyez pas, mais vraiment, c'est juste pour vous dire que ça a bien été initialisé quand on fait le kit-init. Kit-init, ça vous permet d'initialiser dans un dossier le tracking, le versionning. Alors, normalement, dans les exemples d'aujourd'hui, vous n'aurez même pas à le faire, c'est-à-dire que vous allez copier vos dossiers depuis le GitHub du lab.

j'ai mon dossier avec git 2.master. Ça on va reparler mais master en gros c'est les logiques de branche et master c'est la branche principale sur laquelle vous travaillez. On va en parler juste avant. Mais voilà, vous voyez en tout cas que déjà c'est craqué avec Git, parce que vous avez Git qui est derrière là-dessus. Ce qu'on peut faire, c'est regarder, maintenant que tout est craqué, voir s'il y a eu des changements dans mes fichiers ou autres. Et ça vous pouvez le faire avec le petit Git status.

Gitstatus, ça vous permet d'afficher quelques informations, ça veut dire que vous êtes bien sur la branche master, il n'y a eu zéro commit pour l'instant, donc on n'a pas fait de version. Et vous avez un fichier qui n'est pas traqué, donc hello.txt, il n'est pas traqué pour l'instant dans notre logique d'arrêt.

A partir de ça, je me dis que j'ai fait 2-3 modifs, j'ai fait 2-3 fichiers, imaginons, je suis content, j'ai envie de... de faire cette version rendue et de dire ok, ces fichiers-là, je veux les ajouter et ensuite faire une version avec ces fichiers-là à ce niveau-là.

Pour ce faire, première étape, c'est « Add » et là, soit vous ajoutez le fichier spécifique en question et le texte, soit vous faites le petit point, « Add point », ça vous permet d'ajouter tous les fichiers qui sont dans le dossier. Généralement, c'est ce qu'on fait.

Donc j'ai mon git add. Si je refais un git status, ça a changé un petit peu. Là il dit ok, on a bien ajouté des fichiers, maintenant il faut les compter, donc je change le git comitif, j'ai un nouveau fichier.

Maintenant, en effet, étape suivante, c'est de mettre ça dans notre version avec un petit bit commit. Généralement, on rajoute...

En tout cas, on va dire que c'est initialisation plus création fichée.

quand vous faites un comit, essayez de mettre un petit message qui vous permet de dire pourquoi, c'est quoi l'intérêt de ce comit là. Justement, l'idée c'est de pouvoir voir tous nos comit et rapidement naviguer dessus s'il y a une info relativement claire sur le sujet.

l'idée de ce comica. Et donc là, j'ai bien mon comique qui a été initialisé, donc un fichier, une insertion, j'ai ce comica qui a été créé dans l'idée. Et je peux voir normalement tous mes colis, si je fais un petit plug derrière, vous voyez que là j'ai fait un seul colis qui est de moi, à cette date là, avec ce petit message ici.

Et le petit club, ça vous permet de voir tous les comics que vous avez fait. Là, j'en ai fait un, mais si j'en faisais d'autres, je les verrais également derrière.

Donc ça, c'est la base, sans parler de ventes, sans parler de travail en équipe. Pour l'instant, c'est déjà la base. On fait nos motifs, on regarde nos statuts, on ajoute nos fichiers.

Est-ce qu'il y a des questions déjà par rapport à ce que je viens de vous montrer sur tout ça ? Ouais.

d'ouvrir VisioAlco Studio avec vos dossiers. Oui, parce que vous me faîtes confiance à moi, hop.

Ça permet d'introduire Visual Code Studio, donc quand vous faites code point, ça vous ouvre Visual Code Studio que vous allez utiliser pour modifier vos fichiers SQL, etc. Donc là, vous voyez, je viens dans l'exemple court qui est sous ma virtualisation.

J'ai mon fichier texte dedans. Si je clique sur mon fichier texte, j'ai mes textes ici que j'ai écrits tout à l'heure. Si je fais du texte... J'ajoute le texte. Si je fais juste ça, que je revais sur mon petit terminal, je lui dis, bah regarde s'il y a eu des trucs, ça va changer non ?

Pourquoi ? Pourquoi il y a quelques changements ? Vous ne l'avez pas enregistré, non ? On n'a juste pas enregistré notre dossier. Si je revenais sur Visual Studio, ici, en fait, vous voyez, il y a un petit point ici qui s'est mis. En gros, ça veut dire que ce n'est pas enregistré.

Là, par contre, si j'enregistre mon fichier, Dès que je retourne sur un git status, là il a capté que le PCI a été modifié, il n'est plus la même tête qu'avant. Et d'ailleurs, techniquement, on peut faire un petit GIF pour voir exactement ce qui a été modifié. Si je fais un petit GIF, vous voyez, il met en plus la ligne ajout texte en blanc, celle qui existait déjà. Ça vous permet aussi de visualiser rapidement ce qui a été modifié entre le commit d'avant et le petit GIF.

Dans le status, on voit bien qu'il a capté les changements. Dans le guide BIF, on peut voir les changements exacts qu'on a faits, les lignes à ajouter, etc. En bleu, c'est les lignes ? Ah bon, c'est quoi ? En bleu, en effet, c'est le nombre de lignes HD et leur localisation, je ne sais pas exactement.

Et si je veux terminer, ce qu'il me reste à faire, c'est d'ajouter ce fichier, donc le kit app et le texte. Pareil, je peux re-checker mon kit status. Il est bien ajouté au prochain comit. Là, je pourrais faire des nouveaux fichiers, etc. Je vais les ajouter derrière. Et ensuite, s'il me plaît, je suis content.

Ok, elle me parle bien, je m'arrange, je refais le status, j'ai la vie, là elle me dit ok, bien la comite, tout est clean, au bout. Et si je refais un petit git-lub, j'ai tous mes commits ici, le premier et le second avec les infos, d'ailleurs le premier et le second couteau.

Allez, j'les envoie derrière.

En gros c'est ajouter au commit. En fait il faut ajouter des fichiers pour faire un commit. Parce que si tu fais juste git commit, sans avoir à noter, tu commis pour rien. va admettre une erreur, on va refaire un petit exemple, on va faire changer encore...

En gros, c'est dans la logique de l'ajouter à la prochaine version du jeu. Si on remonte, pour faire un exemple,

soit je fais le point pour ajouter tous les fichiers, soit je précise un fichier spécifique ou des fichiers spécifiques. Là je peux dire, ok on ajoute et le texte. au tracking, on va dire, à la prochaine version que j'enregistrerai. Là, pareil, 17 juste pour vérifier, j'ai bien ce fichier-là qui a été ajouté là-dessus.

et je peux refaire mon produit maintenant, avec cette nouvelle batterie.

C'est bien ? Oui.

Ok, et donc là, j'ai fait la logique, j'ai changé mon fichier, ajouté ces changements à la nouvelle version, et renvoyé la version. Ok.

C'est déjà la première partie, est-ce que ça va jusque là ? Ouais.

Donc vous voyez, si je reviens rapidement ici, actuellement, par défaut, on est sur le master. Le master, généralement, il est appelé main maintenant. Master, main, c'est la même chose, c'est, en gros, votre branche principale, si on parle de branche.

C'est la branche de production. Alors, pourquoi on fait des branches dans l'idée déjà ? Parce que généralement, vous n'allez pas pouvoir envoyer tous vos changements directs à vos clients. Là par exemple je suis sur un PC Windows, on est d'accord que je n'ai pas envie que dès qu'il y a un dev, il fasse un petit changement sur un fichier, j'ai une mise à jour qui se télécharge. L'idée c'est de faire des gros packs, en gros on fait une version 1.1 avec tous nos changements, tous nos commits qu'on a fait.

on l'envoie, et nos utilisateurs font la mise à jour une fois par semaine, par exemple. Vous n'allez pas avoir de mise à jour toutes les 30 minutes, sinon ça va vite vous suer. Et surtout, c'est très risqué, parce que si ça envoie direct la mise à jour sur l'environnement...

de vos clients si jamais vous avez un bug qui arrive.

vous avez la branche main master et la branche de production et vous allez travailler d'abord sur une autre branche. Généralement il y en a plusieurs. On va simplifier, vous avez la branche main master et vous avez une branche de développement qui est parallèle.

sur laquelle vous allez pouvoir faire toutes vos modifications etc et une fois que ces modifications là, donc en gros votre partie de développement sera faite, généralement ça va être testé. Vous avez généralement une boîte d'EQA, d'Engineer, etc. Vous avez ensuite plusieurs accessoires, donc ça dépend en effet, là on parle plus sur par exemple dev, par exemple...

et une fois qu'on a développé, testé et validé par des testeurs, on va envoyer nos changements sur une grosse mise à jour, sur le produit final par exemple. Donc ça c'est la logique globale, c'est on va pas tout faire sur l'environnement de nos clients directement, on va pas leur casser le truc, ok ? Il faut évidemment, il y aura...

et finalement, on va être une partie testing du futur, donc ça peut mélanger les deux.

Ça c'est la logique principale. Pour ce faire, il y a une logique de branche qui est utilisée sur le kit que vous avez connu. J'en parlais. La branche principale, vous la retrouvez sous deux noms. Soit elle s'appelle main, soit elle s'appelle master. Maintenant, tout le monde a tendance à l'appeler main dans les jeux.

Cette branche là, c'est vraiment le code, comme je vous le disais, qui marche en production. Vos clients sont sur cette version de votre logiciel, de vos tables, en fonction de votre visage.

Evidemment, si on se plante et qu'on fait des trucs directement sur le mail, ça impacte les utilisateurs directement. Par exemple, si vous êtes en data, si vous êtes sur la création de modèles, vous modifiez un modèle qui est utilisé par des personnes derrière sur leur reporting journalier, si vous vous plantez et que vous faites directement des changements sur le mail, vous vous plantez sur le code, ça va casser, ce que les utilisateurs verront à la fin.

Donc c'est quand je vois la suite qu'il y a attention. C'est pour ça qu'on va introduire la logique de branche. Généralement, quand on parle de branche, je fais une future égale une branche. Par exemple, en termes de data, si vous voulez faire le nettoyage d'une table, ce sera une branche.

Ce sera la branche, le nettoyage, le table, le machin. Et ça, ça va faire votre branche, par exemple, en terminologie. Du coup, comment on le schématise, tout ça ? Vous avez toujours votre main et master, qui est vraiment le truc, le principal. Vous, en fait, vous allez, là justement, pour brancher, on va faire une branche à partir de ça.

C'est-à-dire que, là, le petit point, généralement, ça représente ce qu'on appelle des versions, donc des comics. Vous avez le dernier en gros commit qui marche bien sur main, vous allez créer une branche qui va sortir de main à partir de tout ce qu'il y avait avant. Donc en gros, vous prenez ici comment il est le main, vous créez une copie, vous le mettez en parallèle, et là, l'idée c'est de faire vos modifs, faire les 50 000 commits que vous avez besoin.

Et une fois que vous avez testé, validé, de remettre tout ça dans le main à un moment ou à un autre.

Donc ça c'est logique, vous faites vos petits comics, vos petits points, donc ça c'est un comic, on a fait un fichier, on a fait la version, hop, on est content, on fait un autre fichier, la version, etc. Jusqu'à ce que vous ayez votre feature qui marche bien, qui a été testée, tout ça.

Et une fois que ça, ça a été testé, que c'est bon, on va faire ce qu'on appelle un Merge, et même avant le Merge, on va faire une Pull Request. demandez à ce que ça soit mergé dans le mail, et quelqu'un, une personne d'équipe, va regarder votre demande, est-ce que c'est une logique en termes de code, est-ce qu'il y a des blocs ou pas, et la valider, et une fois que c'est validé, ça va être mergé dans le mail, et donc là, tous vos changements que vous avez faits dans votre côté à vous parallèle, ils vont se rapatrier.

dans votre branche principale, pour vos utilisateurs, pour qu'ils aient la mise à jour. Mais évidemment, cette étape-là, ne pas fabriquer tout ça dans le mail, ça se fait une fois qu'on est sûr que ça ne vaut pas, que ça a été testé et que ça a été validé.

En effet, ici, en gros, tu parles de ce dernier comité, donc en gros, tu parles du mail à l'instant T. À cet instant-là, tous les dossiers qu'il y a dans tous les fichiers, tout ce qui a été fait, tu dis OK, ici, je fais une branche égale, je fais une copie.

Ma branche, c'est une copie du mail à cet instant-là.

Ok, une bonne pratique, une fois que vous avez votre feature et qu'elle est bonne, vous pouvez supprimer. Merci d'avoir regardé cette vidéo !

Et ça, évidemment, vous pouvez le faire autant de fois que besoin. Vous avez une feature qui permet de nettoyer le site, une table, etc. ou peut-être une feature de voyage.

Et autant, que ce soit que vous avez besoin pour créer, modifier, faire votre feature, vous, c'est généralement des codes pour faire du table.

Evidemment, au bout d'un moment, ça peut commencer à se compliquer, vous allez avoir plein de branches qui partent un peu dans tous les sens en termes d'économie.

En règle générale, ce que vous allez retrouver en entreprise, si c'est à peu près structurel, c'est évidemment le mail. l'environnement de vos clients et vous allez retrouver on va dire un petit tampon de sécurité c'est à dire un environnement développement qui va toujours être présent et qui va suivre en fait le même. Dans l'idée, il sert à quoi ? Il sert à faire d'abord pareil des petites branches à partir de développement c'est à dire que vous au lieu de faire une branche directement à partir de main vous allez partir de développement, faire votre branche, vous bidouillez

Et remettre tout ça dans le développement, c'est quoi l'intérêt ? C'est que même si vous, vous avez normalement tout bien testé et tout, ça devrait marcher, en fait, il y a des gens aussi qui travaillent généralement en parallèle. Donc si jamais vous, de votre côté, quand vous avez...

au sens où ça marche mais qu'il y a quelqu'un qui a fait une branche permis dans le développement et en fait la combinaison des deux fait qu'il y a un bug infiné. Le fait d'avoir ce tampon là, ça permet de ne pas casser l'environnement de production directement.

C'est d'avoir en fait une petite couche tampon où tout le monde va d'abord mettre leur travail et une fois qu'on est sûr que cette couche tampon là, pareil, il n'y a plus de beuille, on peut la mettre. mail et faire une grosse vidéo. C'est un peu cette logique là, production, tampons et toutes vos features sur lesquelles vous créez et utilisez votre fichier.

Quand on voit la première ligne, enfin le premier comit de développe, en fait il y a deux branches qui partent et en fait le truc c'est que comment en fait le comit qui arrive, enfin celle du haut là, c'est le toute rouge, elle arrive sur un comit violet à la fin, elle vient fusionner à la fin.

C'est développeur 1, c'est développeur 2, et 2 il part de tous les endroits.

Lui, il a fini assez rapidement le développement, donc il a fait sa modif, tout ça marche, hop, il met ça dans le développement.

mais donc dans l'idée quand il est encore en feature 1 le développeur 1 il n'a pas accès en fait à ce qu'a fait le développeur 2 C'est ça, d'accord, ok. Par contre, la logique c'est que lui, s'il met à jour le développement, il met à jour tout ça, il fait une merde, tout ça, il met dans le développement.

Le développeur 2, si lui il n'a pas encore fini techniquement, il peut quand même reprendre les changements. Ah, il peut ressourcer du développe, c'est ça ? Il peut ressourcer du développe les changements. Ok, ok. Après, vu qu'il est censé travailler sur quelque chose qui est indépendant...

Il est censé travailler sur, dans votre cas par exemple, une table indépendamment de ce que l'autre a fait.

L'idée, c'est qu'en effet, si jamais ces deux développeurs travaillent sur le même fichier, vous aurez des conflits. Si développeur 1, qui en haut, travaille sur le même fichier que développeur 2... à partir du même moment en fait derrière quand vous allez merger développeur 2 et vous vous dire je ne comprends pas, je suis parti du même endroit d'un fichier ça a été modifié une fois et là tu me redemande de modifier à partir du même endroit dis-moi quoi choisir

Et vous allez avoir le cas dans un exercice vers la fin d'aujourd'hui où en effet vous allez être à deux dans le binôme, vous allez travailler deux fois sur le même fichier, faire deux grandes, une fois vous allez remettre tout ça ensemble et vous vous dire « je ne comprends pas, qu'est-ce que je choisis ?

» parce que vous êtes parti du même truc. et vous me proposez deux solutions différentes.

Donc en effet, ça c'est la limite qu'on va dire à la guide, c'est qu'il faut bien se communiquer, se séparer les tâches, parce que si vous travaillez sur la même chose, ça va faire des conflits.

Ça n'empêche pas la communication, bien au contraire d'ailleurs, vous travaillez sur du github, il faut communiquer, savoir qui fait quoi, et ne pas se marcher dessus, parce que si vous marchez dessus, ça amène des conflits, c'est gérable, mais c'est chiant, parce qu'il faut choisir, et ça demande un peu d'argent.

En termes de structure, dans la vraie vie, on va généralement se retrouver un peu plutôt ça. la branche mail, le devlog qui est un peu le tampon et après toutes nos petites branches pour travailler et faire nos...

ok donc en termes de workflow typique ce que vous allez retrouver c'est qu'on a commencé à faire c'est on va créer un loco ou le cloner parce que si c'est quelque chose qui existe dans votre boîte on peut le prendre en ligne et le ramener en local chez vous

On crée une clode, cloner c'est reprendre un dossier traqué par git qui existe déjà. Ensuite, vous allez directement vouloir créer une branche. Comme je vous le disais, on ne travaille pas sur Nasser. La première étape, c'est créer une branche, donc le branche futur 1.

Faire vos changements, les sauvegarder, les ajouter, les comiter, etc. Et ensuite, ce qu'on appelle faire une pull request, et mettre la branche dans l'environnement du dev, dans l'environnement de production. répéter ADVITAM et ETERNAM là-dessus.

Et une fois qu'on est satisfait de cette branche là, on met tous les changements d'un coup.

Ok, alors petite note, du coup, puisque là on parle du Git, c'est que je vous notifie un tout petit peu au début que Git, il y a des choses qu'il ne faut pas traquer.

Ce qu'il ne faut pas traquer d'ailleurs dans vos projets, c'est en fait tous les fichiers qui vont être assez gros. Tous les fichiers d'images, de musiques, de vidéos, de données brutes, etc. Même données nettoyées ou transformées. En gros, vous n'allez pas vouloir les...

Les traquer, parce que c'est pas le but de Git, le but de Git c'est de traquer que les logiques de code qui permettent justement de faire ces transformations là, c'est pas de traquer les logs

de chaque table, ça d'ailleurs il y a des database qui le font très bien et pourquoi d'ailleurs vous ne pouvez pas c'est que ça va être trop lourd à stocker, parce que ça dans l'idée vous allez stocker aussi en ligne derrière et quand vous allez faire des passes entre les deux, si vous stockez évidemment des tables

de nous donner, ça va être compliqué. Dans tous les cas, ça ne sera pas possible et ce n'est pas ce que vous voulez faire. Les autres choses à ne pas traquer et à ne pas oublier, c'est aussi les crédits et les passwords. Les credentials et les passwords.

Donc c'est jamais, alors déjà, deux bases. Je n'ai pas dit, mais un projet Git en ligne, il peut être public ou privé. Vous avez ce qu'on appelle l'open source. Quand on parle d'open source, généralement, c'est des projets Git qui sont ouverts en ligne. Donc voilà, vous pouvez avoir accès à tous les fichiers qui sont traqués en ligne.

Evidemment, on n'a pas trop envie de mettre nos passwords ou nos crédentiaux pour se connecter à des API exclusives. Et même si c'est privé, on va éviter parce qu'on ne sait jamais s'il y a du hacking ou autre, s'il y a des pertes de données. On essaye de ne pas les traquer dans les fichiers.

On n'a pas non plus envie de traquer ces types de fichiers-là, les passwords ou les crédentiaux. Donc, en termes de fondamentales, si vous avez lu, vous avez craqué généralement que votre code, votre logique de code derrière, et les fichiers peut-être restent aussi.

Ok, en petit bonus, mais je pense que je vous passerai un autre cheat-sheet mais là vous avez un petit Ricard pour vous, un petit truc un petit peu...

Ok, donc ça c'était notre première partie, et on a une seconde partie, alors peut-être avant de passer à la seconde partie, je vais vous faire l'exemple avec une branche, on va juste rajouter une branche, vous allez voir, c'est pas très complexe, la deuxième partie justement, elle va partir aussi de ces branches là, on va parler de travail en équipe et du coup de GitHub derrière, parce que là, je vous rappelle, on est sur Git, on est toujours en local, enfin, on est sur GitHub.

ce que j'ai fait jusque-là, tout existe sur mon PC. Si mon PC pète, il plante, il décolle, il racécule, je n'ai plus rien.

Ok, donc l'idée, très simplement, si on refait le workflow, mais avec ce qu'on a appris tout à l'heure avec les branches, il n'y a pas grand-chose à ajouter, seulement de faire une branche. Alors si je fais juste guide-branche, il va me dire quelles sont les branches actuellement existantes. Donc là j'ai que la branche master. Donc nous, ce qu'on veut c'est créer une branche. Donc je vais faire guide-branche et on va l'appeler feature 1.

Là ça m'a créé ma branche, si je fais pareil, mi-branche, j'ai mes deux, j'ai Ficure 1 Master qui me redit que je suis sur Master. Si je veux changer de branche, il y a deux options. L'historique, check out. Et si vous faites tabulation, vous allez voir plusieurs options, feature 1, alors Head, Head c'est un peu pour dire ce que vous êtes en train de lire actuellement. Donc en gros si je fais Head, je vais rester sur Master, ça va pas trop m'intéresser.

En gros, vous avez Feature 1 et Master. Nous, on va aller sur Feature 1. Tabulation, Feature 1. Switch to Feature 1. Vous allez pouvoir retrouver aussi le switch, qui est la même chose, qui vous permet de switch sur votre branche, vous allez effectuer un master, si je veux revenir sur master, hop, j'effectue master, pareil, vous avez les deux mots clés qui existent, maintenant on a plus tendance à utiliser switch.

Checkout, on va revenir sur ma feature 1 et là on va pouvoir commencer à travailler. Là je suis sur ma feature 1, je peux aller sur mon base code, le ré-ouvrir et remodifier mes fichiers. Je regarde, là c'est le workflow classique, j'écris ma branche, je vais aller sur ma branche, maintenant j'ouvre mon éditeur de texte, mon base code, je fais mes modifs,

Là, normalement, il me les a détectés, si je fais un petit git status, j'ai mon fichier texte modifié, donc logique, il vous le dit, qu'est-ce qu'il faut faire ? Il n'y a pas de changement, donc il nous dit git add, on peut faire raccourci aussi, git commit pas, mais on va faire étape par étape, git add, et donc là, on va ajouter notre fichier texte, il a ajouté à la prochaine version.

C'est bien. Oui. Parfait.

Ok, là j'ai fait mon petit workflow, j'ai ma branche qui est à jour, je peux continuer à faire mes codings jusqu'à ce que j'ai fini mon fichier. Et on va le voir après, comment on va rapatrier ça dans le mail. Parce que là, en effet, si je vous montre, j'ai toujours mon fichier.

Je vais me ficher avec la ville, par contre, si je reviens sur mail, si je fais un petit git, check out. et que je vais sur master, main master c'est la même chose et que cette fois-ci je ré-ouvre mon code vous voyez j'ai plus que mes 3 lignes les deux sont bien décorrélés

J'ai mon master qui avait 3 lignes d'avant et ma feature 1 qui avait 4 lignes, parce que je suis parti de master et j'ai arrêté un truc, et pour l'instant je n'ai pas regroupé dedans, ok, c'est bien de faire la suite ou c'est ça ? Et sur le fichier local il est tout le temps en mode master en fait c'est ça ?

Enfin le fichier local sur ton pc, le helotex il existe bien sur ton pc ? ton explorer ? Il est toujours en mode master c'est ça ?

là en effet j'ai bien mon classique de masseur techniquement si je vais

Vous pouvez voir la visualisation, en effet, staudiée aussi en termes de logique derrière, c'est bien.

Et ça, c'est géré par Gui, parce que Gui, il pointe sur le nouveau dossier en fonction de la rente d'arrivée, c'est toute la logique qui est là.

Donc voilà, vraiment, vous voyez, c'est bien de décorer les clusters et la feature 1 pour l'instant. C'est clair pour l'instant, surtout pour tout le monde sur ce que l'on a ? Ok, maintenant, on va voir la suite, qui est justement le travail en équipe et comment on va rapatrier des changements avec le Sandvik.

Ok, alors, donc, second point du cours et on va parler de Git mais surtout de GitHub en parallèle. Parce qu'en effet, quand vous travaillez en équipe, il va quand même falloir passer par un endroit où on va s'échanger les trucs. Et on va s'échanger les trucs à travers Agitop. Alors, comme je le disais, c'est pas seul, il y a Agitop qui est quand même assez utilisé, mais vous avez GitLab, vous avez Duplicate, et il y en a plein d'autres qui sont très similaires à Agitop.

Donc si jamais une entreprise vous dit que c'est Agitop, c'est Duplicate ou GitLab, c'est parfait. OK. Donc, on a vu comment créer un livre, comment stage les fichiers qu'on va ensuite co-lead et comment travailler avec ces gens-là. Maintenant, comment utiliser tout ça pour travailler en équipe ? Pour travailler en équipe, on a besoin d'un repo chez vous et d'un repo en ligne.

Je vous disais qu'il y en a plusieurs possibles, là c'est les 3 gros du marché que vous avez dans votre garantie. Alors Kitop c'est quoi ? C'est vraiment un site, une interface web qui vous permet d'accéder en remote à vos repos que vous avez envoyés en ligne.

Et ça permet évidemment d'inviter des gens à travailler sur votre dossier, qui eux-mêmes vont pouvoir cloner ce que vous avez fait et les mettre sur leur PC et vous proposer des changements. C'est le principe. Et l'idée, c'est qu'il y a pas mal de features supplémentaires. Il y a des codes review, des intégrations continues, des développements continus. C'est-à-dire que dès qu'on fait des changements, ça reconstruit les choses. Pour ça, vous ne verrez pas de soucis.

Mais déjà, ce qu'on va voir, c'est que ça nous permet de faire des codes review avant de mettre ensemble des champignons. Et voilà, du top, c'est en effet le leader du marché et il n'est pas axé sur un type de version. de personnes, de jobs particuliers se construisant sur le plan d'alerte de personnes libres dans l'emploi.

Ok, donc on va parler en effet de l'interaction entre les deux. Première interaction, ce que je n'ai pas fait ici, mais ce qui est tout à fait possible. Là dans mon exemple tout à l'heure, j'ai créé un fichier directement en local. Ce qu'on peut faire, c'est aussi prendre un fichier qui existe en ligne et le cloner en local chez vous.

D'abord partir de quelque chose qui est en ligne et le cloner. c'est tout à fait possible. Ensuite, une fois par exemple que vous avez créé votre dossier, vous avez commencé à travailler dessus, vous avez une branche, des changements, etc. Vous avez envie de mettre peut-être à dispo tout ça à vos collègues. Vous allez faire ce qu'on appelle un push, donc vraiment pousser en ligne vos changements.

L'idée c'est de mettre en ligne tout ce que vous avez fait. Et à contrario si des gens ont fait des changements, qu'ils ont mis à jour ou depuis chez eux qu'ils ont poussé en ligne, bien évidemment je ne vous les ai pas, on va faire ce qu'on appelle un pool, un Geek Pool qui permet de rapatrier les changements chez vous.

Donc ça, c'est un peu les trois interactions qu'on va faire globalement. Et si on fait un exemple schématique, en gros, vous avez votre colocale, vous commencez à bosser, vous faites une colise, vous rentrez...

Si vous êtes content, il y a quelqu'un qui y est, j'aimerais bien bosser avec toi sur ça. Vous allez l'envoyer en ligne, donc là sur github.com. Vous allez créer un nouveau congo en ligne et vous allez envoyer votre travail dessus. Lui, qu'est-ce qu'il va faire ? Pour vous aider, il va cloner. Quelqu'un qui clone, il va cloner, en fait.

le fichier avec l'URL ou le SSH, il va tenir ça chez lui et il va commencer, pareil, il fait sa branche, il fait ses comites, tout ça. Une fois qu'il est content, il va renvoyer ça en ligne pour que vous puissiez vous-même faire la mise à jour chez vous de ce travail-là. Et ça, évidemment...

Et en termes aussi de schéma de branche, généralement ça va se situer un peu comme ça, vous avez votre masseur, ou votre branché de branche, et on a un bout de retard. de ce point-là et qui est rapatrie à l'autre point, et l'autre, pareil, il part de ce point-là, il fait son travail, puis il est rapatrie après un autre point. C'est un peu long en termes de schématique, c'est le même principe avec des bandes.

Ok, je vais faire un exemple juste après, même si je ne l'ai pas codé, donc c'est très bien que vous le voyez en ligne, tout simplement.

Maintenant, une fois que j'ai fait des changements, je les ai envoyés en ligne, on va quand même pouvoir faire une étape de sécurité avant de les mettre dans notre production. L'idée, c'est que GitHub, il va vous permettre de faire ce qu'on appelle des codes élus. On a apparemment dit que, comme je disais, n'importe qui poche une info dans votre mail sans valider tout derrière, ou sans faire une étape de sécurité.

l'industrie a été modifiée.

Voilà, donc ça, c'est ce qu'on appelle boule d'équestre dans l'idée, et on va le voir plus loin juste après.

On va le voir d'ailleurs maintenant. Ok. Donc là j'ai, on est d'accord, j'ai mon dossier, avec Moon Master, ma feature 1, pour l'instant ça n'existe pas en ligne, c'est que sur ma machine à main. Si je veux que ça existe en ligne, je vais aller sur...

Donc là, je suis chez moi, j'ai mes petits repos à gauche, donc dans l'idée, il faut que je lui crée un endroit où il peut s'occuper.

On va choisir un donneur, là on va choisir moi, et on va dire que c'est un hippo qui sera, on va l'appeler pareil, pas obligé de l'appeler pareil techniquement, mais euh... Pour la logique, là, c'est avec lui. En vrai, dans l'idée, vous pouvez choisir deux ou trois options. Est-ce qu'on le met public ou privé ? Bon, là, je vais le mettre privé parce que ça passe loin, les gens voient ça. Et est-ce que j'ai un template X ou Y ?

Oui, je peux prendre des templates, là, le wagon en A, prédéfini. Je peux ajouter un fichier git-ignore pour ignorer des changements sur certains fichiers, notamment par la démo de base ou autre. Ça sert à travers le git-ignore, qui nous permet d'ignorer certains types de fichiers.

Tout ça je vais le laisser faire rien faire, j'ai rien besoin de faire, j'ai juste mis mon nom de Rigaud, hop, on va le créer.

Et donc là, ça nous envoie sur une page, vous voyez en haut à gauche, je suis chez moi, Florent, et j'ai mon exemple de cours, donc là, je suis bien dedans. On a plein de possibilités.

Et vous avez 2-3 autres choses, de settings, etc. Vous voyez, quand vous créez un repo, il y a déjà plusieurs options qui vous proposent. C'est soit de coder avec... leur truc, soit d'ajouter des gens à votre épo et également de créer quelque chose, des types de codes à mettre sur votre terminal.

Donc soit créer un truc de zéro, là ils ont créé toutes les codes, initialisation, readme, commit, branch, etc.

Ou soit, si vous avez déjà quelque chose, de faire le lien entre les deux. Donc on a une première ligne qui est git remote-add-origin. En gros, ça veut dire qu'on va ajouter un lien en ligne qui va s'appeler origin, et qu'on aura pour... point de destination git-github.com du nom du code ça ils vous le donnent au client maintenant ils vous font aussi renommer les branches master en main vous voyez c'est le... branche-m c'est pour modifier mail, donc ça c'est vraiment parce que maintenant tout le monde part en termes de mail

On va faire tout ça. Si je fais ce code là, que je le copie directement ici, pour simplifier.

ça change pas grand chose, mais on va se promener peut-être d'abord sur le main, on va chacaroute master, on va donc copier-coller ce qu'ils nous ont donné, donc vous voyez, git remote ajouté origine, et ajouter le git tube, voilà. C'est bien passé, on va faire ensuite ce qu'ils nous proposent aussi de faire, c'est modifier le nom d'une branche, une petite branche.

tirer end main, donc simplement ça nous renomme la branche, ça nous a pas créé, si je fais kick branche, vous voyez j'ai bien mes deux toujours, le spin et les features. En termes de nomenclature, maintenant c'est du courant de l'Europe. Ok ? Et maintenant, qu'est-ce que j'ai à faire ? Il me l'a proposé je crois d'ailleurs, en termes de logique, c'est de faire un git push.

Alors, il met le petit you, tirer you, c'est pour créer un lien permanent, ce qui me permettra après de faire simplement un git poche, au lieu d'écrire git poche, origine, même. Donc là, on lui dit, ok, tu parles de git, tu fais la grande poche, et tu l'envoies dans ce qu'on a créé tout à l'heure, origine.

Origine, en gros, c'est vraiment le raccourci du lien. C'est ce qu'on a créé tout à l'heure, l'origine c'est mon lien Github, donc tu envoies dans mon lien Github, la branche l'aime, c'est clairement ce que j'ai dit. Et si je fais ça, vous voyez, il fait un truc où il envoie mes informations en ligne.

Je vais ici que je rafraîchis, hop, je vais sur GitHub, je rafraîchis, j'ai bien les changements qui ont été rapatriés, donc j'ai bien montré le texte. Et pour le coup, j'ai bien que mon mail que je lui ai envoyé, que mon mailadre m'a envoyé. Et j'ai bien un officier que je peux voir. Je peux voir mon officier directement dans l'e-dub, ou bien le métro à Indonésie.

Ok, ça va jusque là. Vous voyez, je n'ai pas fait grand chose, j'ai juste ajouté un lien et fait un petit push pour l'envoyer en ligne.

ok je peux faire du coup maintenant la même chose dans l'idée

sur ma feature 1, et vous voyez d'ailleurs qu'il m'a rajouté une possibilité qui est Origin slash Main. Origin slash Main, c'est pour dire que c'est la branche qui est en ligne. Donc dans l'idée, c'est exactement la même chose que Main. Ok, et donc ça pareil, dans l'idée maintenant, je peux juste faire un petit cloche et il devrait automatiquement, je n'ai plus besoin d'ajouter derrière parce que j'ai déjà ici le petit you qui fait un lien.

Avec tout ça, on est dans l'idée. Ah non, ok. MyBal, ça a dû faire que pour le... Oui, non, je l'ai fait que pour... Il faudrait que je rajoute...

J'ai fait le lien, je vous promets que je vais en profiter.

Là, pareil, vous voyez les infos de qu'est-ce qui a été envoyé, compression, envoi, vous avez toutes les infos. Normalement, on sait que ça a marché. Si je revais ici, vous voyez d'ailleurs, il m'a dit que 6 sur 1, Arrèche a récemment été poche.

Pareil, je peux voir les fichiers dans Feature 1 qui ne sont pas les mêmes qu'eux-mêmes. Là, je peux voir aussi tout dans le kit Outlook. Ok, l'intérêt, vous voyez, c'est qu'ils vous proposent automatiquement maintenant de comparer et de faire une prouve d'équation.

ce qu'on veut c'est que cette feature là, généralement si je la poche, c'est que je l'ai finie à peu près et que j'ai envie de la mettre en mail. Et donc ça, dans un workflow classique, on la poche et on va faire ce qu'on appelle pull request, elle repose automatiquement.

et ils vous envoient sur une nouvelle interface. Ouvrir, vous ne pouvez pas essayer. Comme ça, vous voyez, j'ai juste cliqué sur l'option Ouvrir, vous ne pouvez pas essayer. Ce qu'il faut vérifier, c'est en gros, qu'est-ce qu'on met dans quoi. Là, je compare, feature 1, petite flèche, je vais le mettre dans mail.

Bon là il me dit que ça a l'air bon, il n'a pas l'air d'avoir de soucis. Bon l'idée, on va généralement faire un titre et là lui dire c'est merde je vis sur un...

avec la modif de l'huile. Et pareil, on peut ajouter une description, si on a fait quelque chose de complexe, c'est bien aussi de faire le commentaire. techniquement je peux aussi faire d'autres options je peux ajouter quelqu'un donc si j'avais des gens qui travaillent sur mon projet je peux dire Jean-Michel vient regarder et valider ma projet, est-ce que tout est ok ?

Je peux ajouter des labels, je trouve qu'il y en a par défaut. Est-ce que c'est une pull request qui va gérer un bug, la doc, etc. Évidemment ça on peut en modifier ou ajouter des labels. Là je peux dire ok c'est faire la doc.

elle va ajouter dans main un nouveau fichier texte, une ligne, donc là on va le fichier exact. Voilà, j'ai dit à quelqu'un une nouvelle idée, j'ai fait un lave-f, je suis ok, donc j'accepte le post-test. Bon, au revoir sur une nouvelle vidéo. page où je peux encore vérifier. Normalement, c'est pas moi qui vérifie, c'est la personne que j'attribue, on va voir sur le classique. La personne que j'attribue va devoir garder tous les commis qu'on lui a fait.

Pour le coup, j'ai écrit un comit, et s'il y en a plusieurs, il y en a plusieurs d'entre eux. On peut regarder chaque comit, et c'est l'interface que vous voyez dans le début de cours. Si je clique sur un comit, j'ai le fichier à gauche, où il est fichier, et je vois à l'intérieur ce qui a été modifié.

modifié et on peut aussi faire des commentaires si jamais la personne dit genre ça c'est un peu nul ce que t'as fait ou ça va te faire brouiller il peut faire un commentaire S'occuper des commentaires, rejeter la poubelle à l'équestre, c'est-à-dire... Vas-y, regarde ce que je t'ai commenté, il y a ça à résoudre pour pas que ça fasse planter nos clients.

Donc une fois que Jean-Michel, pour venir, par exemple, a validé tout ça, il n'a pas trouvé de bug. Et ce qu'il peut faire, c'est valider le petit bouton Merge de la Poubelle Ouest, en ajoutant un petit commentaire. Parce qu'au final, une Poubelle Ouest, c'est quoi ?

C'est un commentaire. C'est vraiment une version qu'on a énergée de branche.

Par défaut, MergePullRequest, ça me va, ok. On va confirmer. Et donc là, ma PullRequest, comme je le dis, a été bien mergé et fermé. Donc là, je peux en raccourci, supprimer ma branche, parce que, effectivement, je n'utilise pas. Je ne peux pas le faire pour l'exemple, mais vous avez compris le truc, c'est que, généralement, là, c'est trop long. Mais, pour l'exemple, j'ai besoin de la garder, parce que si je reviens, du coup, sur mon petit repo, exemple court, maintenant, les deux sont à jour, donc si je vais dans main,

que vous regardez le texte, j'aime bien l'hécatombe. Pareil que l'hécatombe surfiture en deux sur le même niveau, parce que j'ai émergé les deux. et est-ce qu'on peut revenir en arrière sur main là est-ce qu'on peut en revenir avant le merge En gros, ça repasse par un coin et ça normalement tu peux le faire directement dans les pull requests. Si tu vas sur tes pull requests fermés, il me semble que c'est dedans direct. Alors oui, je ne vais pas montrer, par contre j'ai un public. Vous avez plusieurs onglets, vous avez les onglets pull requests.

Donc si jamais il y en a une ouverte, vous les voyez ici. Sinon, vous pouvez aller sur celles qui sont déjà fermées. Et sur le principe, ici, il doit y avoir un petit bouton, une verte, qui permet, en gros, de refaire... une pull request qui inverse les changements que t'as fait, et donc t'as annulé tes changements. Je vais pas le faire, voyez, mais tu vois, ça te crée une branche intermédiaire, revert 1, feature 1, que tu remets dans le mail, et ça t'annule les changements.

Ce qu'il faut savoir, c'est que quand vous êtes sur git, normalement même si vous... faites un réveil de changement, vous aurez toujours un comit pour dire ça c'était le comit qui nous permet d'inverser les changements. Ça ne va pas vous supprimer le comit que vous avez fait de l'égalité, ça va vous garder et simplement ça va vous refaire un comit derrière.

L'idée de Kiks, c'est de ne jamais perdre de version.

Donc voilà, c'est tout à fait possible, en effet, de le faire, ok ? Alors maintenant, si je vais voir ici, est-ce que...

Du coup, l'indicateur est up-to-date avec Original, c'est ok.

Ça semble up-to-date avec Origin Mail, parce que la dernière fois que j'ai Push, c'était la même chose. Mais j'ai quand même une fonction. Donc là, j'ai encore une différence entre en local mail et git... J'ai été out, si je vais sur feature 1, on regarde.

Pourquoi il fait une update VSPEN maintenant, je comprends pas.

avoir une mise à jour de VSCODE. Dans l'idée, vous l'avez vu, sur main on avait trois lignes et là le temps qu'il fasse la mise à jour. C'est pas trop long, on va le voir, mais on en a à nos 4 lignes, en ligne. On va attendre 30 secondes, excusez-moi, c'est un peu lourd.

Et l'idée c'est qu'on montre un effet multi-étapes, où on va pool les changements pour les effets en ligne. de se mettre des commentaires sur le terminal non parce que c'est ce qui ne dure pas en fait si je ferme mon terminal là, ça me supprime tout ce qu'il y avait avant et le roux et...

Et non, t'as pas de commentaire à faire. Les commentaires, ça va être directement dans tes fichiers textes. Donc le terminal, c'est vraiment un truc que tu utilises et après, c'est pas sous-gardé.

Il y a fait un ménage lourd, et vous voyez, là, en effet, c'est surfectuant. Bon, là, j'ai bien mes cabines, que je n'avais pas sur le menu. OK. Donc, pour faire ça, ce qu'on va faire, ben, on va vite check-out tout de suite sur Jojo 6D2. C'est mieux parce qu'on n'a pas les autres trucs qui nous embarrassent.

Ce qu'il faut que je fasse, c'est un petit dip-pool. Et dans l'idée, là je ne connais plus le dip-pool parce que j'ai fait le lien tout à l'heure. Vous pourrez me le capter. Et si je fais un outil qui coule, là vous voyez, il regarde en ligne et il me télécharge les changements que j'ai faits en ligne.

Et maintenant, si je fais un petit code point, en local, j'ai bien mon fichier qui est à jour également. Donc là j'ai à jour en ligne et en local, tout est bon. C'est quoi l'étape d'après ? Si je voulais continuer à développer, qu'est-ce que je ferais maintenant ? Vous n'avez pas quelque chose ?

Et si là je fais une nouvelle feature ? Une nouvelle branche ? Une nouvelle branche ? Ouais, si là je veux repartir, c'est bon mon code a été validé, été mis dans main, aller, reblog

Et là, on va dans BaseCode, et on commence à faire nos nouveaux fichiers, nos colis, etc. Ok, vous avez compris le truc ? Donc là nous vous fichiez, ensuite je fais l'ajout, etc.

J'ai fait ma branche, je suis allé dans ma branche, je suis allé dans mon s-code développé, j'ai fait mon changement, liste status, est-ce qu'il y a bien mes changements qui sont captés ? Oui, j'ai bien mon exemple.txt qui est mon nouveau fichier que j'ai capté.

Imaginons que j'ai rechangé...

Et nous, point texte. Lalalala. Enfin, je sauvegarde. Je vais vous faire un petit status. Donc j'ai bien mes changements qui sont ici, modifiés et pas traqués. Il a déjà été modifié tout à l'heure, donc il n'est pas du tout traqué encore. Donc là, qu'est-ce qu'il me reste à faire ? Ajouter, donc là j'ai envie d'ajouter tous mes fichiers, donc je peux faire point.

Si je veux ajouter un de mes fichiers, vous voyez, tabulation, je propose un de mes fichiers. Mais techniquement, je peux ajouter les deux l'un à l'autre.

point bien entendu. On ajoute ça. Pareil, si je regarde mon git status maintenant, ok, j'ai mes deux changements qui sont captés, il y en a un qui est un nouveau fichier et il y en a un qui est un fichier modifié. Et maintenant, la suite, git, commit, cmsgm, nouveau fichier.

C'est mon colis, je peux continuer à faire des colis, des versions, et ensuite si je suis content, je fais un Hush Origin.

voir en ligne ma future. Et ensuite, qu'est-ce qu'il me reste à faire? Aller en ligne.

Il me dit qu'il y a des trucs, bah d'ailleurs il m'a quand même fait l'arrivère tout à l'heure, j'aurais déjà supris. Et là il me voit, feature 2, en ligne, récently punched, donc c'est cool. Maintenant, je veux faire une pull request, je compare pull request.

Alors vous pouvez aussi, si jamais ça ne s'affiche pas pour une série de raisons, aller dans pull request et la créer de zéro. Là, pareil, il me l'a remis ici, mais vous pouvez très bien faire une nouvelle pull request et choisir dans quoi dans. Vous mettez quoi dans quoi ? Là, nous c'est feature 2 dans l'ennemi.

Capture 2, voilà les changements, hop nouveau fichier, nouveau GIF, nouveau request. C'est la dernière, très mauvre request. Hop'là, il check, pas de conflit, c'est bien, tu réfléchis différemment, il n'y a pas quelqu'un qui a voulu se faire une fichie entre temps, on est ok, la merde, on confirme.

Là, ça veut dire que ta branche du haut, tu dois la remettre, tu devrais l'intégrer dans l'entente. La feature 2, je la mets dans la ligne. On a fait 8 sur 2, et on est parti dans main. Ici, je mets main contre 8 sur 2. Là, j'ai mis mon lit. Donc maintenant, dernière étape.

Si je veux mettre à jour, je fais un petit...

Je reviens sur mon mail, et du coup, un petit pull, et là il va mettre à jour mes changements sur le mail également en local. J'ai validé, je suis passé par en ligne, quelqu'un a fait ma revue code, il a validé.

Maintenant, qu'est-ce que je fais ? J'en refais une branche, j'en refais des modifs, etc. Etc. Ok ? Vous avez compris le truc un peu ? C'est quelques petites étapes créées, on va dire. Il n'y a pas 36, vous voyez, lignes de code à faire, simplement. Il faut juste se mettre en tête les étapes. C'est logique. Je ne veux pas se casser, donc je fais une branche. Je pars sur mon environnement d'aide. Je fais mes modules. Je suis content.

J'ai fait une première version, je continue mes modifs, j'en fais une autre version, j'ai fini tous mes modifs, j'ajoute tout ça, j'ajoute...

ligne en ligne et s'inverge dans la production le même ok et si je vous fais un petit GIFLOG On va envoyer tous les comics qui ont été faits depuis le début, là-dessus.

Et là j'ai mon petit G-Dog avec tous mes premiers disques. Ouais. Ok. Est-ce que j'ai oublié quelque chose ? Là je t'ai déjà montré pas mal de choses.

Petite dernière chose que je peux vous montrer, c'est que la chaîne d'initiation que je vous montrais avec les branches, on peut la retrouver techniquement sur Visual Studio.

Pour retrouver cette petite schématisation, on va vous la faire télécharger dans les extensions. On va vous le redire dans les exos dans les débats. On va vous demander de faire un petit graphe. L'extension du graphe, moi, je l'ai déjà. Qui est ici.

qui nous permet de visualiser, par exemple ici avec des petites branches qui s'enroulent. Et donc si on retourne sur mes fichiers ici, on a ça. Vous avez maintenant en tout en bas le petit truc qui te graffe, je ne sais pas si vous le voyez, qui est apparu et si vous cliquez dessus, vous pouvez voir justement ce que j'ai fait.

Au début, en bleu, c'est ValidMain, j'ai ValidMain, j'ai une commit d'initiation, ça reprend d'ailleurs les noms de commits, c'est très bien, j'ai fait le petit commit, à un moment, j'ai fait une branche 6 sur 1, je suis sorti, j'ai fait un commit, cette branche là, je l'ai remis dans le main.

J'ai déjà fait deux branches, bon là il m'a refait une branche pour le vert, qu'on devrait supprimer dans l'idée pour pas que ça nous gâche le chemin. On l'a déjà supprimé. Vous voyez d'ailleurs que c'est l'origine. Pourquoi ? Parce qu'elle n'existe qu'en ligne. C'est pour ça. S'il y a Origin devant, c'est qu'elle n'existe qu'en ligne.

Et le petit mail, ici, vous voyez d'ailleurs que c'est actuellement que je suis ici, pourquoi ? Parce que j'ai le petit rond qui est vide.

Et j'ai main-origine et origine-l, donc les deux, en gros ça veut dire que main et en ligne sont au même niveau. Main-origine sont au même niveau.

Si il y a d'autres utilisateurs qui bossent dessus, tu verrais les branches d'outils mieux ou juste les tiennes ? Si j'ai fait un pool de leurs branches, je la verrais. Mais voilà, ça nous permet d'avoir une petite visualisation, de voir ce qu'il s'est passé. Les comiques, les ronflements des têtes, s'il y a des ronfles qui traînent. Là par exemple, on voit très bien que j'ai une ronfle, un comique qui traîne dans l'air.

C'est bien comme petite navigation graphique, ce petit livre là.

Voilà, si on revient sur le cours, je crois que c'était à peu près tout, on voit que je ne suis pas dans tous les états que je veux dire, les tous les requests on l'a fait.

En termes de résumé, mais je vous l'ai déjà un petit peu dit, utiliser Git, ça n'exclut pas de communiquer et de paralyser proprement les jobs. table, personne qui fait le cleaning sur une table, l'autre sur une autre table, l'autre qui fait la dégagation sur une table qui est déjà cleanée, c'est pareil, la logique derrière.

Donc, faire des petites tâches que chacun va réaliser et il faut éviter d'être trop dépendant les uns des autres. Vous ne pouvez pas faire quelqu'un qui fait tous les nettoyages et vous, vous tournez les pouces pendant que lui fait les nettoyages et vous, après, vous faites l'allégation.

Non, évidemment, on lui fait 2-3 tables, il fait 2-3 tables, etc. C'est un peu la logique d'arrivée.

Attention aux dépendances, attention aux conflits.

En général, même si on communique bien, il y aura régulièrement des conflits, si ça vous arrive, ce n'est pas très grave. Vous allez voir un exemple dans les challenges aujourd'hui, vous allez voir, c'est facile à résoudre, il faut juste dire qu'est-ce qu'on garde.

Il va vous mettre des petits bouts de code, il va vous dire, il y a ça, il y a ça, lequel on garde, vous supprimez ou vous sauvegardez, si ça ne vous intéresse pas, c'est résolu. Vous pouvez en effet les avoir dans la baguette, ça arrivera.

Et, en règle générale, pareil, je l'ai un peu dit, mais n'oubliez pas de faire vos petits comics, vos versions régulièrement. C'est plus facile de revenir sur une version d'avant, si c'est des petits trucs, que si, évidemment, vous n'avez pas trop vite depuis 3 jours, et, en fait, vous avez fait des trucs qui font que vous comptez revenir en avant, en arrière.

C'est plus chiant. Donc voilà, faites des petits comics à jour, régulièrement. Mettez à jour aussi en ligne quand même vos branches régulièrement. On ne sait jamais si quelqu'un a besoin d'autres, mais c'est plus pour vous. Vous pouvez aussi, quand ça soit stocké en ligne, l'adopter sur votre PC.

Je relance un peu tout ce que je vous ai dit tout au long du cours, c'est un peu la règle que vous avez à la fin. Est-ce que ça peut pas faire pour tout le monde quand même la logique globale ? Je sais que c'est pas mal d'infos, c'est un nouvel outil, le terminage va vous faire un peu peur.

Vous avez vu que ce n'est pas non plus le sorcier et que vous avez des petits indices visuels sur le terminal. Dans tous les cas, aujourd'hui, ça commence tranquille. Les exos sont quand même assez guidés. Si je vous montre le premier, globalement, on va vous donner...

à chaque exo un petit kickstart, c'est-à-dire que vous avez ces quelques lignes de boîte là, qu'est-ce que ça vous permet de faire ? ça vous permet de créer automatiquement le dossier de justement prendre les structures qui sont déjà dispo en ligne sur le Verdin, pour nous faire un chronique, en gros, du dossier Le Verdin.

Et d'ouvrir votre Visual Studio pour que vous puissiez ensuite démarrer. Et le petit mec c'est pour run les tests, donc si vous copiez tout ça fera des tests mais généralement ils ne fonctionnent pas. L'idée c'est que vous avez des tests pour chaque challenge pour voir un petit peu ce que vous avez réalisé pour votre challenge.

Et dans les challenges, le premier, c'est une petite démo, ça va vous reprendre un peu des pratiques de terminal qu'on a fait, donc le freinage de code, comment... voilà, PWD pour dire où on est... Ensuite, comment se déplacer, comment regarder ce qu'il y a dedans. Voilà, ça va vous donner le premier exo, vraiment. Un peu ce qu'on a fait ce matin. Les CD, le changement de texte, le touch pour faire un fichier. Je vais vous montrer aussi, il y a le RM qu'on a vu tout à l'heure, qui est pour supprimer un fichier.

Voilà, ça va vous faire deux ou trois petites choses pour vous habituer un peu au terminal. Et c'est à partir du deuxième, on partira plus sur le bit, mais c'est par FRM, structure, on vous donne les infos, vous pouvez copier-coller ça, déjà, à bout, dans votre...

terminale et ça vous créera le fichier et ça vous enverra dans ce dossier-là, et ensuite, pareil, c'est parti.

OK ? Normalement c'est assez bas à bas, il n'y a pas trop de pièges, c'est juste pour la prise en main.

Une petite pause et c'est parti. Merci.

Sous-titres réalisés para la communauté d'Amara.org

Sous-titres réalisés para la communauté d'Amara.org
		

Résumé

#### Actions à entreprendre

- [ ]  Rechercher une idée de projet et en parler avant le 21 août
- [ ]  Préparer un pitch de 2-3 slides si l'on est porteur d'un projet (contexte, problématique, solution envisagée, risques)
- [ ]  Partager les ressources et liens de datasets aux participants
- [ ]  Organiser le vote en ligne pour les projets le 28 août

---

#### Récapitulatif du workflow Git

- Deux façons d'initialiser un dossier local : `git init` (créer de zéro) ou `git clone` (cloner un dépôt existant via SSH) — les participants ont utilisé le clone aujourd'hui
- Première étape dès l'arrivée dans un projet : **créer une branche** avec `checkout` / `switch`, car travailler directement sur `main` est souvent bloqué
- Modifier les fichiers dans l'IDE (VS Code), puis **commiter régulièrement** pour pouvoir revenir en arrière facilement avec `git revert`
- Vérifier avec `git status` qu'il ne reste pas de fichiers non commités avant de pousser
- **Envoyer la branche en ligne** avec `git push origin` vers un dépôt GitHub
- Créer une **pull request** sur [GitHub.com](http://GitHub.com) pour fusionner la branche dans `main`, faire valider par un relecteur, puis rapatrier les changements en local avec `git pull origin`
- Possibilité de faire un `git merge` en local si l'on travaille seul, mais ce n'est pas le flux standard en équipe

#### Points clés sur l'utilisation de VS Code et BigQuery

- VS Code sert à versionner et stocker le code ; BigQuery est utilisé pour tester et valider les requêtes SQL
- Workflow recommandé : tester les requêtes dans BigQuery, puis les déposer dans VS Code une fois validées
- L'utilisation de Git avec les projets finaux reste à définir selon le niveau des participants

#### Demain : introduction à DBT

- La session de demain sera moins axée sur Git et davantage sur le **terminal et DBT**, un nouvel outil complémentaire
- Des commits et pushs seront tout de même demandés

#### Tests dans le workflow

- Les tests (ex. : test de clé primaire en SQL) peuvent conditionner l'exécution d'un script — si le test passe, la création de table est autorisée

---

#### Projets de fin de formation — présentation générale

- Les deux dernières semaines de formation sont dédiées à un **projet de A à Z** : collecte, nettoyage, transformation de données et création d'un dashboard (Looker ou équivalent)
- Groupes de **4 personnes**
- Le projet sera présenté lors d'un **Demo Day** avec jury externe et/ou collègues d'autres promotions
- Les projets peuvent être mis sur GitHub en guise de **premier portfolio**

#### Calendrier des projets

- **21 août : date limite pour soumettre une idée de projet ût** : date limite pour soumettre une idée de projet
- **28 août** : session de vote — chaque participant classe les projets par préférence, un algorithme constitue les groupes
- **24 août** : début des deux semaines de projet
- **3 septembre** : journée de répétition des présentations orales
- **4 septembre** : Demo Day — présentation finale

#### Comment proposer un projet

- Présenter un pitch de 2-3 slides minimum : contexte, problématique, solution envisagée, points de difficulté potentiels
- Les projets peuvent être apportés par les participants ou choisis parmi les projets proposés par Le Wagon
- Des projets "business" avec de vraies données d'entreprise sont également disponibles (exemples cités : OmecChain, JobTeaser, Tiller, une néobanque)

#### Exemples de projets présentés

- **Projet bar** : analyse des données d'un bar (rentabilité, saisonnalité lundi-mercredi, provenance géographique des clients, popularité des cocktails) — dashboard interactif sur Looker
- **Projet SNCF** : analyse de la satisfaction des usagers, comparaison entre la note SNCF et la perception réelle des voyageurs, construction d'un nouveau score pondéré
- **Projet restaurants Paris** : outil permettant, selon un type de cuisine et un quartier, d'identifier ce qui fonctionne ou non — dashboard décisionnel pour ouverture de restaurant

#### Ressources pour trouver des données

- Liste de sources de données regroupées par thématique à partager (plus de 73 000 jeux de données disponibles)
- Sources spécialisées mentionnées : santé (Ameli), immobilier, jeux vidéo, sport
- Pas de seuil strict sur le volume de données, mais il faut pouvoir croiser plusieurs tables ou disposer d'une table suffisamment riche

Notes

Transcription

Les commandes terminales ne sont pas si complètes que ça, c'est plutôt la logique derrière qui est un peu plus complexe par rapport à tout ça.

Je vais reprendre le schéma que vous envoyez d'ailleurs, parce que je n'en ai pas parlé ce matin, mais on va le reprendre ensemble pour permettre de refaire une petite passe sur la logique derrière. Et en seconde partie, on va parler aussi des projets.

Donc en fait, Gui, ton récap, je ne vais pas avoir rien dans la tête.

grâce à la chaude la journée, mais j'aimerais bien parler déjà des projets, pour vous en dire un mot, parce que numéro 1 ça avance vite et c'est important d'en parler pour que vous puissiez, si vous avez envie... choisir et apporter vos projets à vous. Ça peut être sympa aussi.

Ok, donc voilà en deux parties, on va reparler du workflow de Git, prendre vos questions évidemment autour, et deuxième partie, on va parler un peu des...

Ok. Alors, s'il vous plaît.

Donc ce matin, je n'en ai pas trop parlé, mais je vous ai renvoyé directement ce schéma qui nous permet de récapituler un peu les commandes et différentes étapes d'un workflow guide classique.

donc si on reprend la logique depuis le départ vraiment ce que vous avez fait au final un peu

L'idée c'est de pouvoir travailler en local, parce que c'est là où vous allez faire votre développement de code, de fichiers, vous êtes d'accord, ça vous le faites de toute façon sur votre machine. Donc, il faut que vous puissiez initialiser votre dossier chez vous. Il y a deux façons de faire. C'est soit, c'est vous qui êtes le honneur du projet, donc vous créez le truc de zéro sur votre machine. Dans ce cas-là, vous allez créer un dossier et donc dossier à faire l'outil, ce qu'on a vu ce matin rapidement, git init.

Vous n'avez pas eu à le faire aujourd'hui parce que... Justement, c'est l'autre façon que vous avez prise, c'est que vous avez cloné des dossiers. Donc là, je l'ai mis dans l'exemple tout à droite, un collègue. Vous, aujourd'hui, vous étiez plutôt dans le mode collègue, c'est-à-dire que...

Il faut le savoir, c'est les premières instructions que vous copiez, c'est des coups de ventes, vous pouvez automatiquement les filer, les cloner dans le dossier, tout ça. Donc ça, c'est deux façons.

dossier chez vous, c'est soit vous créez de zéro, soit vous me clonez, avec git clone, et le ssh du projet GitHub en question. Donc ça c'est ce que vous avez fait aujourd'hui sans le savoir. Ok, si je reviens à la base, on a notre dossier local, la logique, qu'est-ce que je fais après sans regarder ?

sans regarder j'ai mon dossier je vais commencer à bosser c'est quoi le premier étape ? créer une branche ? ouais en effet je crée une branche c'est la première étape L'idée, c'est que même si des fois, on ne va pas vous autoriser, vous allez pouvoir faire les trucs sur le même, déjà 90% du temps, vous n'allez pas pouvoir, parce que ce sera bloqué.

On crée notre branche, c'est check out, on switch, pour aller sur notre branche, n'oublie pas, parce que si on en reste c'est sur le... sur notre code point, on balance, on va sur notre VSCode, peu importe ce qu'on a fouillé, là en l'occurrence c'est VSCode, c'est notre, ce qu'on appelle un IDE, donc Environnement de Développement.

vous commencez à modifier vos fichiers, créer des fichiers, etc. Ça se fait via VSTOP, là on est plus sur le terminal, on est vraiment sur la création de modélisation classique.

Une fois que vous êtes satisfait, bah du coup, enfin même pas une fois que vous êtes satisfait, c'est plutôt régulièrement on va dire, une fois que vous commencez à modifier des trucs qui passent correct, on n'oublie pas de faire un petit commit. parce que vous n'allez pas trouver le cas aujourd'hui mais si jamais il y a un truc qui planque ou qui ne marche plus, on a envie de revenir en arrière un petit peu plus facilement.

C'est une option un peu plus complexe, même si c'est une ligne de commande qui équipe Revert en mettant la équipe d'un comité. Ce n'est pas très complexe en soi, mais dans la logique derrière, on se dirait, est-ce que vraiment je veux annuler ce changement-là ?

Commit régulièrement vos fichiers, faites un commit, après vous pouvez revenir, j'aurais pu faire une petite loupe d'ailleurs, entre les deux, vous faites une loupe, c'est-à-dire que vous faites vos commits, On revient sur les DE, on retravaille, on fait nos comites, on retravaille, on fait nos comites, etc. Jusqu'à temps que votre banque, au final...

Vous avez fait ce que vous aviez envie, donc si c'était par exemple le nettoyage d'une database, vous avez fait plein de commis qui vous ont permis d'arriver à un nettoyage complet de la database. C'est un peu l'idée. Une fois qu'on a fait ça, on n'oublie pas de checker avec git status s'il ne reste pas des trucs à modifier, sinon de toute façon normalement il va vous le dire après le programme git.

qui s'attute et si jamais il vous reste des choses à noter, on n'oublie pas, on ajoute le fichier 1, 2, 3, etc. ou le petit point pour apprécier et on commite. Ok, donc là vous avez fini, vous avez fait 5-6 comics, vous avez fait votre table, propre, nickel. Maintenant il y a quelqu'un qui veut venir bosser avec vous et qui va lui partir de table. Donc il faut le mettre en ligne, ce que vous avez fait, il est à dispo.

Donc c'est ce que l'on va faire ici, une petite flèche qui va de chez vous en ligne. Pour t'en aider, je n'ai pas mis mais il faut qu'il y ait un repo en ligne pour l'envoyer ici. Donc création d'un repo si vous n'y n'utilisez pas déjà. Et l'idée du coup c'est d'envoyer ce que vous avez fait, notamment votre mail s'il n'est pas, mais aussi votre branche si vous n'êtes pas encore rentré dans le mail.

avec un petit kit de poche origine, étant évidemment le remote que vous avez vu aujourd'hui. Une fois que c'est dans github.com, soit vous avez plus de poche que le main, et là c'est ok, il peut partir de ça votre collègue, soit vous avez poche, le main et une branche, et dans ce cas là, ce que vous avez fait aujourd'hui, c'est que sûrement vous allez vouloir mettre votre branche et la valider dans le main.

Donc là, vous allez faire ce qu'on appelle une pull request et on va demander à ce que ça soit possible ensuite de couvrir le changement, c'est littéralement ça. Et comme je vous l'ai montré ce matin et que vous l'avez fait aujourd'hui, ça passe par l'interface uniquement de GitHub.com.

signer quelqu'un qui vérifie notre code. Une fois que la personne a validé et bah maintenant c'est nickel vous pouvez et lui-même revenir chez vous, revient sur le terminal, il dit ok je reviens sur main, j'ai validé les changements en ligne, maintenant je les rapatrie chez moi en donnant un pool origine.

de même. Donc littéralement, on attrape ce qu'il y a en ligne sur la grande chaîne. On le remet ici, chez nous. Et ça, c'est la logique que vous avez fait aujourd'hui et que... Il n'y a pas de chose ultra plus complète que ça, c'est vraiment, on parle de ça, voilà, on arpille, on arpille à mes jours, même si j'ai plus de branches chez moi, je repars, je vais en modifier une nouvelle table, on fait une nouvelle branche, voilà, je reviens sur mon environnement de golf.

je refais mes commis, etc, etc, je suis content, bam, je revais sur GitHub pour merguer dans le mail, pour mettre à dispo nos collègues, etc, etc. C'est ce que vous avez fait du coup aujourd'hui.

Il y a moyen de faire un peu la goutte et de faire un verre d'azu.

Ça marche si vous êtes tout seul et que vous virez des branches, vous pouvez faire un kit Merge, on ne va pas vous le montrer parce que ce n'est pas comme ça que vous allez pousser en vrai. mais c'est aussi voilà pour la logique est-ce que ça va quand même c'est encore assez flou pour

Après c'est la logique, si tu sais que dès que t'arrives tu crées une branche, dans ta branche, si tu veux bosser, tu vas sur l'environnement pour le code. Et ensuite, il suffit de reprendre, si tu regardes le schéma, t'as déjà des indications, et si tu comprends la logique, normalement tu pourrais t'y retrouver.

au début on va pas trop vite, c'est normal au début tu vas galérer, tu vas te dire ah oui c'est vrai que je suis là faut pas que je vide trop vite ah merde j'ai pas ajouté mon fichier dans le code lit ça en effet après c'est les petites étapes Dans tous les cas, si tu oublies la liste des éditions incommites, je peux te dire qu'il n'y a rien d'incommite ou des trucs comme ça. Donc, l'idée, ça ne se paie pas, on ne va pas pouvoir le passer.

Ok, donc gardez bien en tête en effet ce petit schéma là, c'est vraiment très simplifié. de Git et des étapes que vous allez en gros avoir à faire tout le temps si vous travaillez avec Git sur un projet de Dev ou de Data qui l'utilise. C'est juste au niveau des tests, je n'ai pas très bien compris ce qu'ils testaient.

et nous on sera amené à faire ça aussi ou pas du tout tu veux dire en vrai ? oui il y aura des tests qui seront

Si le test passe, on autorise la construction d'une table, pour l'inviter. On peut donc faire un test en SQL et autres. Si c'est un test, par exemple, test de clé primaire, ça n'envoie pas de lignes, c'est good. Du coup, ton code de création d'une table, par la suite d'une CSPL, il va s'envoyer, il va s'exécuter, encore une fois.

Il va autoriser le fait de s'exécuter, ça c'est la logique dvd, vous allez voir, l'intérêt c'est vraiment d'avoir un workflow, une pipeline complète avec ces questions-là.

Ok. Est-ce qu'il y a d'autres questions par rapport à ce qu'on a vu, la surprise, aujourd'hui ? C'est normal si ce n'est pas encore ultra limpide, forcément un jour c'est compliqué. Vous allez, je vais dire en remanger un petit peu demain, mais un peu moins au final. On va vous demander de faire quelques petits comités, quelques pouches demain, mais ça sera moins porté sur Geek notamment, même si ça sera quand même à fond sur le terminal.

Mais la logique de demain sera plus sur le DBT, qui est pareil, un nouvel outil très pratique, mais qui permet des petites choses à savoir. Ok, donc rien d'autre de spécial pour vous sur dites choses qui vous ont paru bizarres ou autres aujourd'hui ?

Donc normalement, ça va à peu près à la logique, on va dire. Juste qu'une question, peut-être bête comme question, mais dans VS Code, donc on a vu dans BigQuery, on fait nos SQL, on fait nos calculs, machin, mais dans VS Code, on met quoi, les calculs qu'on a validés dans BigQuery ?

C'est... Alors, en effet, j'avais utilisé VS Code, VS Code, c'est purement...

pour voir si ça marche. Donc on teste nos requêtes dans BigQuery et ensuite une fois qu'elles sont on les valide, on les met dans VS Code ? Dans l'exemple qu'on a fait aujourd'hui, en effet, c'est tout l'idée. Et pour les projets finaux, c'est ce qu'il faudra faire aussi ?

Je verrai comment on va set-up le truc, mais je suis peut-être pas sûr qu'on va s'embêter avec trop de billes, on verra, on verra. Si vous êtes ultra à l'aise, on fera les choses très bien, mais je sais que c'est assez complexe et que ça peut beaucoup ralentir.

Je ne dis pas oui, je ne dis pas non, mais on verra, j'espère. Ok, est-ce que... C'est ok pour tout le monde ? Sinon, je passe à la deuxième partie. Et je voulais parler, bah justement, des prophètes de Franeky. Merci pour l'attention. Vous savez sûrement, mais vous avez deux semaines à la fin de votre camp pour vous distraire en mode projet, pour réutiliser tout ce que vous avez appris et faire un projet de A à Z. Vous allez couper de la donnée, la nettoyer, la modifier.

et l'envoyer sur un outil type Booker que vous avez utilisé, ce sera plus simple pour vous, pour en faire un dashboard et vous raconter une histoire autour d'un sujet que vous avez appris à me dire derrière. C'est un peu l'idée de ce projet de fin d'études, donc vous aurez en effet 2 groupes, 2 groupes de 4, 2 groupes de 8 pour faire ce projet.

Si j'en parle rapidement et que vous avez des questions, s'il y en a, je vais vous dire pourquoi faire un projet. Faire un projet, ça va vous permettre de revoir tout ce que vous avez vu quasiment au bout de temps.

Ça n'a aucun intérêt en tant que data list aussi, votre job, c'est de rendre de sieste l'info. Donc ça permet de resituer ça proprement, parce que, je vous rappelle, peut-être que vous savez, peut-être que certains d'entre vous, d'ailleurs, on va citer au Demo Day de Nant, la dernière fois.

Non. Non, ça a été fait au DVD. Dommage. Mais vous aurez un petit DVD avec des présentations devant des personnes, vos enseignants extérieurs ou les collègues des autres matches.

Ok, donc c'est quoi globalement les dates à retenir, donc aujourd'hui, je ne me suis pas planté, on est le 21, je ne me suis pas planté, on est le 21 déjà, on est le 21 déjà. Donc petite info session Q&A pour vous informer de tout ça. Ça va arriver vite, on a quand même un mois.

je m'y prends relativement tôt mais en gros je vous informe aujourd'hui de comment ça va se passer. Je vous ai dit que du coup ça va être des projets que vous pouvez apporter si vous avez des idées de projet, je vais vous donner des ressources pour chercher ou d'autres, à portée de la donnée, si vous la trouvez, peu importe, derrière. Évidemment, on va aider ensemble si c'est cohérent, si c'est...

lesquelles sont les groupes les plus cités, avec lesquels vous pouvez travailler sur vos deux groupes. Mais du coup, c'est A4 et pas A2, c'est ça ? Ouais, en effet, c'est A4, parce que c'est un groupe le plus grand dans les rues, entre guillemets, son projet.

Ça sera des groupes de quatre. Donc voilà, on se retrouve ici le 21 juillet et le 21 août, c'est le mois auquel vous pouvez regarder, chercher de la donnée.

C'est un sujet un petit peu complexe, on n'aura pas le temps d'en deux semaines, ou c'est trop léger, voilà. Il n'y a pas de nouvelles idées, je vais vous montrer des exemples, il y a des projets à peu près sur n'importe quel type de sujet, que ce soit sport, que ce soit des entreprises publiques, des enjeux climatiques, santé, vous pouvez imaginer pas mal de choses.

que ce soit purement business ou pas forcément, l'idée c'est de trouver un petit scénario et des analyses à faire dessus. Oui. Et du coup tout le monde doit se mettre à un projet. Non, moi j'aimerais bien, mais c'est pas obligé. Non, non, j'en parlerai juste après, mais en effet, vous pouvez, si vous avez une idée, la présenter, venir en parler, si vous n'avez pas d'idée, c'est pas grave. J'espère qu'il y a quelqu'un ou deux personnes dont vous n'hésitez pas.

Sinon, il y a des back-up, il y a des projets du wagon. C'est des projets qui sont très bien, parce que c'est des vrais données.

pour venir en parler et qu'on essaie de valider ça avant le 21 août. Parce que du coup, le 28, et je me suis planté je crois de date, ici... Le 28, justement, ce sera le vendredi juste avant les projets, donc ce sera la petite session où vous allez voter pour qu'est-ce qui vous plaît le plus en termes de projet parmi les 12 projets que vous avez votés.

31, le lundi, et bien c'est parti, c'est le début des deux semaines de projet. Avec comme petite date à retenir, c'est qu'au final dès 6 septembre, ça sera le jeudi de la semaine d'après du commencement, et 6 septembre, ça sera full midi.

Je me suis peut-être planté dans les dates alors, parce que... Ah oui non, ça finit le 4 septembre, c'est ça ? Ouais. My bad. J'ai dû regarder où il est au date. C'est le 4 septembre le DoD, je ne vous ai pas donné 3 jours de plus, et du coup ça commence le...

Pour un projet de plus grande envergure. En plus de plus grande envergure. Du coup ça commence le 24...

C'est vrai. Du coup, c'est le 17 ou c'est pas le vendredi ? Ah oui. Je vais aller regarder. Là, vous êtes sur sept ans. Je suis sûr. Ah non, ok. 17 août, OK, c'est pas le 21, et le 21, c'est pas le 21.

Mais voilà, on démarre le 24 août, deux semaines, sachant que vous n'avez pas vraiment deux semaines parce qu'au final dès le 3 septembre, c'est une journée répète, comme je vous l'ai dit, il y a quand même de l'oral, donc on va s'en occuper. Je vous souhaite une bonne journée, voire un peu plus pour répéter les personnes qui vont passer à l'oral parce que, mine de rien, on n'est pas tous à l'aise de base à l'oral, sachant qu'il y aura normalement un micro et une grande...

500 personnes, c'est la scène de France, peut-être pas mais c'est jamais, vous avez beaucoup d'amis. Et voilà, dès 3 septembre, ce sera jeudi, au final, vos projets sont déjà terminés parce que ce sera les répètes, et le 4, c'est la journée déroutée, donc là, c'est le final d'année.

C'est l'artifice, je crois que c'est la faute. Et les votes se feront comment ? Alors, en effet, ce sera par vote. Vous allez choisir votre projet du plus aimé, sur lequel vous voulez bosser au moins aimé. Et ensuite, ça passera par un algorithme qu'on prendra, qui fera... Oh ! C'est comme ces algos de...

On va avoir un potentiel projet, si vous êtes sur votre deuxième choix, c'est peut-être le dernier coup. Ah ! Après rien que des pincettes bien entendu. Mais voilà, l'idée c'est, on a vos votes, on les passe, on s'en abo, ça fait, je vérifie même derrière.

Comment ? En ligne, on vote en ligne. Je vous enverrai, je les cite normalement.

Ok, du coup je vous le disais, mais évidemment ce serait top si vous motivez et vous changez d'avis. le 21, le 16, hop. Motiver à regarder un projet et à partier justement ce projet-là, donc quelque chose qui vous intéresse, qu'on en parle avant. Si jamais, en effet, il n'y a pas assez de projets, ou potentiellement, vous souhaitez particulièrement faire un business avec du Faboum, vous pouvez aussi me présenter. Sachez qu'il y en a plusieurs, il y en a cinq, il y a OmecChain, JobTeaser, Tiller, UneNeoBank...

Sous-titres réalisés para la communauté d'Amara.org pour qu'il soit forcément présenté à l'opération. Donc si jamais vous avez ça, le projet est dispo ici, déjà à la base.

L'impact de l'été sur les locations AirBnB à Paris, j'en sais rien de connerie comme ça, tu vois, ça peut être ça et du coup à partir d'essayer de collecter des données, de...

Et il y a un minimum entre guillemets de quantité de données, c'est-à-dire qu'en dessous duquel tu vas dire non parce que ce n'est pas assez ? On le sait trop. Tu peux avoir plein de tableaux, qui n'ont pas énormément de liens.

C'est dur de dire un ordi précis mais tu vois si t'as plein de tables et tu peux les retrouver derrière où t'as une énorme table, ça peut être marrant.

L'orientation est très précise là-dessus.

Si vous voulez pitcher en tant que porteur d'un projet, il vous faut 2-3 éléments, c'est-à-dire quel va être le contexte de votre projet, on reparlera de tout ça ensemble, mais vous avez une idée. Quel est le contexte ? Par exemple, on veut étudier, là c'est le cas néo-banque assez classique de la banque.

On veut étudier la rétention de nos clients.

c'est de faire une rétention sur le temps à travers les corps, donc ça va être un peu le but du challenge.

qu'est-ce qu'on veut résoudre, notre solution sur laquelle on pense et sur quoi on risque de galérer. Evidemment, ça peut être plus de slides, je peux vous chauffer à présenter un peu le contexte. Je sais qu'il y en a qui a fait sur la Formule 1. Si vous voulez, c'est quoi la Formule 1 et tout, vous pouvez faire 2-3 slides bonus quand même pour présenter à vos collègues.

Évidemment, si vous voulez rechercher un projet, vous avez plein d'idées, n'hésitez pas à déjà regarder ce qui s'est fait avant, je vais vous partager des ressources.

vous inspirez, regardez un peu ce qui a été fait, si ça vous donne des petites idées. Et évidemment, avant ça, il va falloir, si vous avez d'autres idées, trouver des données et m'en parler, pour qu'ensuite on submite votre pitch sur Kit sans avoir à le suivre.

Il n'y a pas de soucis, je profite de mon pouvoir.

Si il n'y a pas d'autres questions, je vais vous présenter rapidement 2-3 petits projets et je vous donnerai accès à 2-3 choses. Alors déjà, je vous donnerai accès à... Il s'en venait que j'ai regroupé un petit peu sur des thématiques pour que ça se pouvait de regarder un peu ce qui peut être récupéré en ligne. Sachant qu'il y a énormément de choses qu'on peut récupérer. Je vous passerai cette liste là, ce qui j'hésite, un peu moche, mais c'est pas le but.

On a énormément de jeux de données là-dessus. Vous pouvez... On est au bout de 73 000 jeux de données. Vous pouvez tenter de regarder un peu ce qui existe.

2, 3, 6 spécialisés sur la santé, il y a Amélie, qui est très bien en France aussi, qui a besoin de vous donner de la santé. Il y en a 2, 3 autres qui gèrent la France aussi. Vous allez sur l'immobilier, sur les jeux vidéo, sur le sport, notamment dans le supermarket.

C'est pas exhaustif, mais je vous ai lancé déjà quelques liens sur lesquels vous pouvez vous appuyer pour regarder un peu ce qui existe en termes de data. Pas exhaustif, bien entendu. Donc ça évidemment, je vous passerai par là-dessus. Et bien ensuite, je peux peut-être vous présenter un ou deux projets en exemple qui m'ont été faits. Par exemple...

C'est un projet qui a été fait le patch d'avant.

Je ne vais pas le mettre en très grand, mais ça y est. Ok, pour le coup, en termes de projet, c'est un projet un petit peu plus spécifique. C'était une personne qui est arrivée, il y avait son... ses collègues, qui avaient un bar, qui ont fait une place comme une plaisir, peut-être, d'ailleurs. Apparemment, c'est assez connu, en vrai, sur ce qu'ils font.

Y'avait des boulets sympas et leur but déjà c'était de comprendre un peu c'était quoi leur...

ce qui se passait un peu dans leur barre en termes de data, parce qu'ils n'avaient rien qui existait déjà. Donc c'était un projet sympa, donc on se pense qu'il n'y avait rien de créé, et il fallait voir un petit peu ce qu'on pouvait faire avec la donnée.

parce qu'il s'était motivé déjà à récupérer un peu de la donnée en amont. Donc tout ce qui est fond, ça, ça a été fait sur le moteur que j'étais allé emparer. Alors c'est pour ça que c'est pas le... C'est un peu plus simple en design à faire, mais vous pouvez faire quand même des trucs très faibles. Ils l'ont fait un peu en mode présentation, mais sachez que la plupart des graphes sont interactifs. Là, j'ai été chargé en PDF pour simplicité, mais c'est sur Blinkr, donc tout est interactif en termes de graphique.

Si l'article est positif, le boulevard bouge.

Ensuite, en continuant l'autonome, on va voir s'il s'intéresse à la renta, qu'est-ce qui fait qu'on considère la renta.

qui s'intéressent dans un peu à partir du facteur externe de la provenance géographique des touristes parce qu'ils avaient des infos sur les gens qui achètent les billets, d'où les... qu'ils entiennent, c'est quoi l'état sendu, tout ça...

Saisonnalité, donc là pas vraiment d'évolution mois par mois, mais global lundi-mercredi.

C'est évidemment pas ça qu'ils ont dit, je m'en souviens plus. Vous voyez, le principe, l'idée, c'est de faire ces graphes-là, d'en retirer une analyse et d'expliquer.

Voilà, c'est quoi l'évolution du courbier dans le temps, tout à l'heure.

c'est les cocktails élaborés, évidemment c'est plus cher là-dessus. Vous avez remarqué aussi que la vente de cocktails ici, c'était le même ordre que ceux qui étaient proposés à la carte. Ça, on va aussi l'avoir en détail, c'est une fashion, c'est le premier à la carte.

Il y a des gens qui travaillent quoi !

Alors à proprement parler, nous ne nous serons pas notés, cet exercice là c'est plus pour vous, n'hésitez pas d'ailleurs à la fin, limite à vous filmer, à prendre des photos.

Et d'ailleurs, tout ça, vous pourrez le mettre sur GitHub, en effet. Ce sera le premier portfolio, le premier projet à montrer à une personne. On peut s'enregistrer au Pitcher, par exemple.

Et après si on s'organise de façon à ce que chacun passe et qu'on chronomètre vraiment le temps de parole, c'est qu'on peut présenter à quatre. Bah 4 en 10 minutes ça fait trop d'aller-retour, on perd déjà du temps à faire des aller-retour, on n'a pas trop de temps, 2 c'est beaucoup plus long. Tu peux peut-être te mettre une condition et te filmer.

Je sais pas si t'en as deux qui pitchent le bon tournoi, mais si tu veux passer... Dans la répète, il y en a deux qui pitchent, et après... Ouais, après tu pitches et tu le refais. Si tu veux vraiment te filmer, quoi. Ouais, après, si tu veux le refaire, on va le refaire le matin, la nuit...

en sujet basé sur la SNCF, que la SNCF... Oh, non, non ! ... Satisfaction des usagers ? Oh, elle est fous ! Elles sont fous ! NPS et SNCF ! Voilà, en effet, SNCF, bah, ils donnent un...

Voilà, celui-là c'est quoi les promesses de la cinquantenaire ? Ah, une mention.

Ils ont vu que Paris-Bercy, la gare, SNCF, pour eux, c'est 7,51, donc c'était... Alors eux, c'est plutôt 3,6. Il y a quand même un écart de perception.

C'était de refaire ce baromètre-là, d'en garder des corrélations.

Tu peux aller te couvrir, la présentation, les notes, la punctualité, évidemment. Dormez, tout ça, il y a les avis.

De pondérer tout ça justement, ces nouvelles promesses avec ces ressentis, ces avis-là, et de repérer un fort derrière, une nouvelle notation.

Leur principe, c'était de faire le score d'Adam.

regardant sur le terrain à l'idée qu'est-ce qu'on va en récupérer et nous donner des avis sur une équipe précise de l'AFM sur la production et sur le contenu. J'ai lancé le projet PSG.

Et à la fin, l'idée, c'était de faire un petit outil, un petit outil dashboard. Si je veux ouvrir un resto, si je veux aller à un resto dans un quartier, je sélectionne, ça met, qu'est-ce qui marche, qu'est-ce qui ne marche pas, etc. L'idée, c'est d'avoir un dashboard assez classatif, c'est-à-dire...

Si je fais ce type de cuisine-là, c'est plutôt ces quartiers-là, par exemple. Si je fais ce type de cuisine-là, c'est plutôt ces quartiers-là, par exemple.

Ok ? Très bonne question, par rapport à ça. Oh ! C'est génial ! Et sinon, merci à vous d'avoir écouté. Merci. Et bon courage pour demain, parce que ça va pas être facile aujourd'hui. Ouais ! Bonsoir. Bonsoir.
</details>
