# Lexique Git

## 🔀 Git — Gestion de versions

### Configuration initiale (une seule fois)

| Commande | Effet |
|---|---|
| `git config --global user.name "Ton Nom"` | Définit ton nom pour les commits |
| `git config --global user.email "ton@email.com"` | Définit ton email pour les commits |

### Créer / cloner un dépôt

| Commande | Effet |
|---|---|
| `git init` | Transforme le dossier courant en dépôt Git |
| `git clone url_du_repo` | Copie un dépôt distant en local |

### Suivre les modifications

| Commande | Effet |
|---|---|
| `git status` | Affiche l'état actuel (fichiers modifiés, ajoutés, etc.) |
| `git diff` | Affiche les différences ligne par ligne depuis le dernier commit |
| `git add fichier.sql` | Ajoute un fichier à l'index (staging) |
| `git add .` | Ajoute tous les fichiers modifiés à l'index |
| `git commit -m "message"` | Enregistre les changements avec un message |
| `git commit -am "message"` | Ajoute + commit en une commande (fichiers déjà suivis uniquement) |

### Historique

| Commande | Effet |
|---|---|
| `git log` | Affiche l'historique des commits |
| `git log --oneline` | Historique condensé, une ligne par commit |
| `git log --graph --oneline --all` | Historique visuel avec les branches |

### Branches

| Commande | Effet |
|---|---|
| `git branch` | Liste les branches locales |
| `git branch nom_branche` | Crée une nouvelle branche |
| `git checkout nom_branche` | Change de branche |
| `git checkout -b nom_branche` | Crée et bascule sur une nouvelle branche |
| `git merge nom_branche` | Fusionne une branche dans la branche courante |
| `git branch -d nom_branche` | Supprime une branche (déjà fusionnée) |

### Dépôts distants (remote)

| Commande | Effet |
|---|---|
| `git remote -v` | Liste les dépôts distants liés |
| `git remote add origin url` | Lie un dépôt distant nommé "origin" |
| `git push` | Envoie les commits vers le dépôt distant |
| `git push -u origin main` | Envoie et lie la branche locale à la branche distante |
| `git pull` | Récupère et fusionne les changements distants |
| `git fetch` | Récupère les changements distants sans les fusionner |

### Annuler / corriger

| Commande | Effet |
|---|---|
| `git restore fichier.sql` | Annule les modifications non commitées d'un fichier |
| `git restore --staged fichier.sql` | Retire un fichier de l'index (sans perdre les modifs) |
| `git reset --soft HEAD~1` | Annule le dernier commit, garde les modifs en staging |
| `git reset --hard HEAD~1` | ⚠️ Annule le dernier commit ET les modifs (perte définitive) |
| `git revert commit_id` | Crée un nouveau commit qui annule un commit précédent (sans réécrire l'historique) |

### Divers utiles

| Commande | Effet |
|---|---|
| `git stash` | Met de côté temporairement les modifs non commitées |
| `git stash pop` | Récupère les modifs mises de côté |
| `.gitignore` | Fichier listant ce que Git doit ignorer (ex : `.env`, `node_modules/`) |

---

## 💡 Bon à savoir

- Le symbole `⚠️` signale une commande destructive/irréversible — toujours vérifier avant d'exécuter.
- `main` (ou parfois `master`) est généralement le nom de la branche principale d'un dépôt.
- Un commit = une "photo" de l'état de ton code à un instant T, avec un message qui explique pourquoi.
- Toujours faire `git status` avant `git add` pour savoir ce que tu es sur le point d'ajouter.
