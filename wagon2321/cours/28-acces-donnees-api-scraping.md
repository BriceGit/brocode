---
title: "Accès aux données : fichiers, bases de données, API & web scraping"
aliases:
  - "Python 3"
  - "Access Data"
  - "SQLAlchemy"
  - "BigQuery pandas_gbq"
  - "Requests library Python"
  - "Web scraping BeautifulSoup"
  - "Status codes HTTP"
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 28
date: 2026-08-12
language: "Python"
database: "Multiple — connexion générique à tout SGBD via SQLAlchemy + BigQuery via pandas_gbq ; pas de DB unique, le fil conducteur de la session est l'accès aux données (fichiers, bases, API, web)"
topics:
  - "Python"
  - "Fichiers texte"
  - "JSON"
  - "CSV"
  - "Excel"
  - "SQLAlchemy"
  - "BigQuery"
  - "pandas_gbq"
  - "API REST"
  - "Requests"
  - "Web scraping"
  - "BeautifulSoup"
  - "HTML/CSS"
tags:
  - brocode
  - wagon2321/cours
  - python
  - data-access
---

# 28 - Accès aux données : fichiers, bases de données, API & web scraping

> [!info] TL;DR
> Troisième jour de Python, cours court, gros volume d'exercices derrière. Fil conducteur : **comment faire entrer n'importe quelle donnée externe dans un notebook** — fichiers texte/JSON en Python natif, CSV/Excel via Pandas (rappel), bases de données via **SQLAlchemy** (connexion générique) et **BigQuery** via `pandas_gbq`, puis **API REST** avec `requests`, et enfin **web scraping** avec `BeautifulSoup`. Un motif transversal traverse tout le chapitre : quelle que soit la source, le format brut est pénible à manipuler (tuples, dictionnaires imbriqués, texte HTML) — et Pandas sert systématiquement de point d'atterrissage pour retomber sur un DataFrame exploitable.

🔗 Fait suite à [[27-pandas-manipulation-donnees|Pandas — Manipulation de données]]

---

## 🗺️ Sommaire

- [[#1. Fichiers en Python natif (sans librairie)]]
- [[#2. CSV & Excel avec Pandas]]
- [[#3. Bases de données — SQLAlchemy (connexion générique)]]
- [[#4. BigQuery avec pandas_gbq]]
- [[#5. Requêtes API avec requests]]
- [[#6. Web scraping avec BeautifulSoup]]
- [[#7. Bonnes pratiques retenues]]
- [[#✅ Actions post-session]]
- [[#🧾 Corrections & remarques sur la source]]

---

## 1. Fichiers en Python natif (sans librairie)

Avant Pandas, Python sait déjà ouvrir n'importe quel fichier de base — utile pour des cas d'usage simples ou quand aucune librairie externe n'est disponible.

### Fichiers texte

```python
# Lecture
with open("test.txt", mode='r', encoding='utf-8') as f:
    for line in f:
        print(line)

# Écriture
with open("test.txt", mode='w', encoding='utf-8') as f:
    f.write("my first line")
    f.write("my second line")
```

> [!note] Le mot-clé `with`
> `with open(...) as f` ouvre le fichier, l'assigne à la variable `f`, puis le **referme automatiquement** à la sortie du bloc indenté — même en cas d'erreur. C'est l'équivalent Python d'un `try/finally` implicite pour la gestion de ressources. `mode='r'` (read) et `mode='w'` (write, écrase le contenu existant) sont les deux modes vus ici ; `'a'` (append, ajoute à la suite) existe aussi mais n'a pas été abordé en cours.

### Fichiers JSON

Même structure `with open`, mais la librairie `json` apporte les outils de conversion dictionnaire ↔ JSON.

```python
import json

# Lecture
with open('sample.json', 'r') as f:
    content = json.load(f)   # → dictionnaire Python

# Écriture
d = {"cat": "saturne", "color": "gray", "age": 1}
with open("my_cat.json", "w") as f:
    json.dump(d, f)
```

> [!tip] Chemin de fichier
> `open()` accepte un chemin **absolu** ou un simple nom de fichier — dans ce dernier cas, il est résolu par rapport au **cwd** (current working directory, le dossier depuis lequel le notebook est ouvert). Piège classique : `FileNotFoundError` quand le notebook n'est pas ouvert depuis le dossier attendu.

---

## 2. CSV & Excel avec Pandas

**CSV = Comma Separated Value.** Le séparateur peut varier : avec une tabulation comme séparateur, un CSV devient un **TSV**. Lire/écrire un CSV en Python natif (boucles + séparateurs à gérer à la main) est fastidieux — Pandas simplifie radicalement : **ouvrir un CSV = créer un DataFrame, sauvegarder un CSV = exporter un DataFrame**.

```python
import pandas as pd

# Charger depuis un CSV
df = pd.read_csv("my_file.csv")

# Sauvegarder vers un CSV
df.to_csv("my_file.csv")
```

> [!warning] `read_csv()` a énormément de paramètres
> Le paramètre le plus utile au quotidien : **`sep`** — le séparateur. `sep=","` pour un CSV classique, `sep="\t"` pour un TSV. Utile quand le fichier source utilise un séparateur non standard (certains exports régionaux utilisent `;` par exemple). Beaucoup d'autres paramètres existent (`header`, `index_col`, `encoding`, `na_values`, `skiprows`...) — se référer à la [documentation officielle](https://pandas.pydata.org/docs/reference/api/pandas.read_csv.html) plutôt que de les mémoriser.

**Excel** suit exactement la même logique, avec des paramètres différents (notamment `sheet_name`, index 0 par défaut si non précisé) :

```python
df = pd.read_excel("my_file.xlsx")
df.to_excel("my_file.xlsx")
```

---

## 3. Bases de données — SQLAlchemy (connexion générique)

Chaque base de données opérationnelle (PostgreSQL, MySQL, SQL Server...) a son propre système de connexion. **SQLAlchemy** standardise la façon de requêter une base, quel que soit le moteur derrière.

**Trois étapes** :
1. Installer `sqlalchemy` **et** la librairie spécifique au type de base (ex. `pymysql` pour MySQL)
2. Créer une connexion (`create_engine`), avec le driver correspondant
3. Requêter la base et récupérer les résultats

### Créer la connexion

```python
from sqlalchemy import inspect, create_engine, engine

con = create_engine(
    # Équivalent URL : <driver_name>://<db_user>:<db_pass>@<db_host>:<db_port>/<db_name>
    engine.url.URL.create(
        drivername=driver_name,
        username=db_user,
        password=db_pass,
        host=db_host,
        port=db_port,
        database=db_name,
    )
)
```

> [!note] D'où viennent ces paramètres ?
> Host, port, utilisateur, mot de passe : dans un contexte professionnel, ces identifiants sont **fournis par l'entreprise** (accès à la base de données de production, staging, etc.) — ce n'est pas quelque chose que l'on invente ou que l'on retrouve seul.

### Requêter la base

```python
# Lister les tables disponibles
insp = inspect(con)
insp.get_table_names()

# Requête brute
query = "SELECT * FROM table"
result = con.execute(query)
data = result.fetchall()   # → liste de tuples [(...), (...), ...], un tuple = une ligne
```

> [!warning] Format brut peu exploitable
> `fetchall()` renvoie une **liste de tuples** — pratique pour vérifier rapidement un résultat, pénible pour une vraie analyse (pas de noms de colonnes, pas d'indexation par label).

**Avec Pandas, la même requête devient un DataFrame directement** :

```python
data = pd.read_sql(query, con)   # → DataFrame, une ligne = une ligne de la base
```

> [!tip] Motif récurrent de la session — Pandas comme point d'atterrissage universel
> Ce même schéma va se répéter avec BigQuery juste après : la librairie "brute" (`SQLAlchemy`, puis `pandas_gbq` en mode bas niveau) renvoie un format peu maniable (tuples, JSON imbriqué), et l'intégration Pandas (`pd.read_sql`, `read_gbq`) transforme systématiquement ça en DataFrame. Peu importe la source — fichier, base SQL, API, page web scrapée — Pandas est le format d'atterrissage commun avant l'analyse. Voir la fiche [[Requêtes API avec requests (Python)]] pour la suite du même motif côté API.

---

## 4. BigQuery avec `pandas_gbq`

Deux façons de s'authentifier, selon l'environnement.

### Hors Google Colab — clé de compte de service

```python
from google.oauth2 import service_account
import pandas_gbq

# Charger les credentials depuis le fichier de clé JSON
credentials = service_account.Credentials.from_service_account_file('path/to/key.json')

# Requêter BigQuery
query = "SELECT * FROM table"
df = pandas_gbq.read_gbq(query, project_id="YOUR-PROJECT-ID", credentials=credentials)
```

> [!warning] Permissions minimales & sécurité de la clé
> Le compte de service doit avoir au minimum les rôles **BigQuery Job User** et **BigQuery Data Viewer**. La clé JSON téléchargée donne accès à **tout le projet BigQuery** associé — à stocker dans un emplacement sécurisé (jamais commité sur un repo public), et idéalement dans un dossier dédié plutôt que le dossier Téléchargements par défaut.

### Dans Google Colab — authentification déjà disponible

Étant déjà authentifié dans l'environnement Google, pas besoin de clé de service explicite :

```python
from google.colab import auth
import pandas_gbq

auth.authenticate_user()   # récupère les credentials automatiquement

query = "SELECT * FROM table"
df = pandas_gbq.read_gbq(query, project_id="YOUR-PROJECT-ID")
```

> [!tip] "Pandas strike again"
> Même logique qu'avec SQLAlchemy : `pandas_gbq.read_gbq()` renvoie directement un DataFrame (une ligne = une ligne de la table BigQuery), sans étape intermédiaire de type liste de tuples/dictionnaires à parser à la main.

---

## 5. Requêtes API avec `requests`

### Trois façons de requêter une API

| Méthode | Exemple d'outil | Cas d'usage |
|---|---|---|
| No-code, client API | Insomnia | Explorer/tester une API sans écrire de code |
| Terminal, `curl` | `curl` | Possible mais peu confortable — présent dans la doc de la plupart des API |
| Code | Python (`requests`), JS, Ruby, C... | Intégrer l'appel dans un pipeline / notebook |

`requests` est **LA** référence en Python : robuste, largement utilisée par la communauté, [documentation officielle](https://requests.readthedocs.io/) riche en exemples.

### Anatomie d'une requête — une seule fonction

```python
import requests

response = requests.method(url, params=params, data=data, headers=headers)
```

| Argument | Rôle |
|---|---|
| `method` | `"GET"`, `"POST"`, `"PUT"`, `"DELETE"` — s'écrit en pratique `requests.get(...)`, `requests.post(...)`, etc. |
| `url` | L'endpoint de l'API, ex. `"http://base_url.com/endpoint_name/"` |
| `params` | Dictionnaire de paramètres — utilisé pour les requêtes **GET** |
| `data` | Dictionnaire de données envoyées — utilisé pour les requêtes **POST** |
| `headers` | Dictionnaire (ex. `Content-Type`, `Authorization: Bearer <token>`, `User-Agent`) — clés API, tokens d'autorisation |

> [!note] `params` vs `data`
> Réflexe simple : **GET → `params`** (on demande de la donnée, les paramètres apparaissent dans l'URL), **POST → `data`** (on envoie de la donnée, dans le corps de la requête). C'est exactement la même distinction que sur un client comme Insomnia.

### Response Object

```python
response.url             # URL effectivement requêtée (utile pour vérifier)
response.status_code     # code de statut HTTP
response.text            # résultat en string (peu exploitable)
response.json()          # résultat en dictionnaire Python (à privilégier)
```

> [!tip] `.json()` plutôt que `.text`
> `.text` renvoie une chaîne de caractères brute — dès qu'on veut naviguer dans la structure (aller chercher une clé précise), `.json()` est largement préférable puisqu'il renvoie directement un dictionnaire Python natif.

### Status codes

| Famille | Sens | Exemples |
|---|---|---|
| **1XX** | Information | `102` — requête en cours de traitement |
| **2XX** | Succès | `200` — succès ; `204` — succès mais résultat vide |
| **3XX** | Redirection | `301` — la requête a été redirigée |
| **4XX** | Erreur côté client | `400` — requête incorrecte ; `401` — non autorisé ; `404` — endpoint introuvable |
| **5XX** | Erreur côté serveur | `500` — erreur serveur |

### Exemple — API GitHub

```python
response = requests.get("https://api.github.com/users/<username>")
response.url             # confirme l'URL requêtée
response.status_code     # 200 = succès

data = response.json()   # dictionnaire Python
data["id"]                # accès à une clé précise, comme n'importe quel dict
```

Un endpoint public (pas de clé API nécessaire ici) qui renvoie les informations publiques d'un utilisateur GitHub — bon exemple pour s'entraîner à naviguer dans un JSON de réponse avant de passer à des API nécessitant une authentification (`headers`).

🔗 Détail complet de l'anatomie d'une requête API dans la fiche [[Requêtes API avec requests (Python)]].

---

## 6. Web scraping avec BeautifulSoup

### Pourquoi scraper le web ?

Quantité de données disponible en ligne, avec plusieurs cas d'usage concrets : constituer des listes de prospection depuis des résultats de recherche LinkedIn (Sales Navigator), récupérer des avis clients sur les réseaux sociaux pour améliorer un produit, scraper des offres d'emploi pour cibler des entreprises qui recrutent, ou identifier des influenceurs/prospects via des posts Instagram/Twitter liés à un hashtag.

> [!warning] Légalité
> Le web scraping n'est **pas légal sur tous les sites** — toujours vérifier les conditions d'utilisation (terms of use) avant de scraper.

### Le scraping est de plus en plus difficile

De plus en plus de sites (LinkedIn, Amazon en tête) mettent en place des restrictions anti-bot et des mécanismes dynamiques (JavaScript) pour compliquer l'extraction automatisée.

### Outils sans code

| Outil | Spécialité |
|---|---|
| **webscraper.io** | Extension navigateur, point-and-click, +400 000 utilisateurs — la communauté la plus large ; API disponible pour plus de flexibilité |
| **Phantombuster** | Spécialisé réseaux sociaux (LinkedIn notamment, très difficile à scraper autrement) — +100 000 clients, workflows prêts à l'emploi |

> [!tip] Ne pas réinventer la roue
> Sauf si le scraping est un vrai actif métier de l'entreprise, mieux vaut s'appuyer sur un outil existant (Phantombuster, webscraper.io) plutôt que d'investir du temps de développement sur des cibles difficiles comme les réseaux sociaux.

### Rappel HTML/CSS avant de scraper avec du code

Une page web repose sur trois briques :
- **HTML** : structure de la page, via des **balises** (`<html>...</html>`, `<p>...</p>`) qui délimitent chaque élément
- **CSS** : mise en forme (une balise peut avoir une **classe**, ex. `<p class="introduction">`, ciblée ensuite par une règle CSS comme `p.introduction { color: #8A5EFD }`)
- **JS** : animations et comportements dynamiques

**Comment identifier la bonne balise à cibler ?** Utiliser l'**inspecteur d'éléments** du navigateur (F12, ou clic droit → Inspecter) : il révèle le HTML et le CSS de n'importe quel élément de la page, y compris sa classe exacte — l'information indispensable pour cibler précisément l'élément avec BeautifulSoup.

### Workflow de scraping en 4 étapes

1. **Récupérer** le HTML brut de la page avec `requests`
2. **Parser** ce HTML avec une librairie dédiée, `BeautifulSoup`
3. `BeautifulSoup` permet d'**extraire** du contenu par id ou par classe (`find`/`find_all`)
4. Si le site utilise **JavaScript** (site dynamique — le contenu n'apparaît qu'après exécution de scripts), `requests` + `BeautifulSoup` ne suffisent plus : il faut passer par **Selenium**, qui pilote un vrai navigateur

```python
import requests

url = "https://bootcamp_da.com"
response = requests.get(url)

from bs4 import BeautifulSoup

# soup peut maintenant être requêté pour extraire du contenu
soup = BeautifulSoup(response.text, 'html.parser')

# chercher la balise p avec la classe "introduction"
tag_p = soup.find("p", {"class": "introduction"})

# extraire le contenu texte
print(tag_p.text)   # welcome to web scraping class
```

> [!note] `find` vs `find_all`
> `find` renvoie la **première occurrence** correspondant au critère ; `find_all` renvoie **toutes les occurrences**, sous forme de liste. Un sélecteur CSS peut aussi cibler des relations entre éléments (ex. "le deuxième `span` sous le premier `p`") pour des cas plus précis.

> [!note] `.content` vs `.text` sur la réponse
> Pour parser avec `BeautifulSoup`, `.text` suffit dans la plupart des cas. `.content` (bytes bruts) est légèrement plus sûr si la page contient des ressources non textuelles (images notamment) qu'on veut aussi pouvoir traiter — mais `.text` reste le choix par défaut recommandé en cours.

### Contourner les restrictions basiques

Ajouter des `headers` simulant un vrai navigateur (ex. `User-Agent: Mozilla`, ou un `Accept-Language`) peut suffire à contourner certaines restrictions légères — le site "croit" alors recevoir une requête d'un vrai navigateur plutôt que d'un script. Cela ne fonctionne évidemment pas contre les protections anti-bot avancées.

### Cas pratique — extraire une liste de citations (site de démo dédié au scraping)

```python
quotes = []

for quote in soup.find_all("div", {"class": "quote"}):
    text = quote.find("span", {"class": "text"}).text
    author = quote.find("small", {"class": "author"}).text
    quotes.append({"text": text, "author": author})
```

Résultat : une liste de dictionnaires, immédiatement réutilisable — par exemple convertible en DataFrame avec `pd.DataFrame(quotes)`.

### Pagination

Deux approches courantes pour scraper plusieurs pages :
- **Modifier l'URL** en incrémentant le numéro de page si le site l'expose directement (ex. `?page=2`)
- **Suivre le lien "next"** via son attribut `href` — utile quand la structure d'URL n'est pas triviale à reconstruire soi-même

🔗 Détail complet du workflow de scraping dans la fiche [[Web scraping avec BeautifulSoup (Python)]].

---

## 7. Bonnes pratiques retenues

- Toujours vérifier les **conditions d'utilisation** d'un site avant de le scraper
- Stocker une clé de service (BigQuery ou autre) dans un emplacement sécurisé, jamais dans un repo versionné publiquement
- Préférer `.json()` à `.text` pour exploiter une réponse d'API
- Vérifier `response.status_code` avant de traiter une réponse, plutôt que de supposer que la requête a réussi
- Pour un site dynamique (JavaScript), ne pas s'acharner avec `requests`/`BeautifulSoup` seuls — passer directement à Selenium
- Reprendre le cours de référence pour la syntaxe SQLAlchemy plutôt que d'essayer de la retenir par cœur — elle est volontairement verbeuse

---

## ✅ Actions post-session

- [ ] **Toi** : réaliser l'exercice 1 — lecture et écriture de fichiers texte avec `with open()`
- [ ] **Toi** : créer une clé de compte de service BigQuery (si pas encore fait) et la stocker dans un endroit sécurisé
- [ ] **Toi** : réaliser l'exercice 2 — connexion à BigQuery via compte de service
- [ ] **Toi** : réaliser l'exercice 3 — requêter l'API OpenWeatherMap
- [ ] *(Formateur)* Vérifier et mettre à jour l'exemple Selenium pour le récap du soir — l'exemple montré en cours n'était pas garanti à jour

---

## 🧾 Corrections & remarques sur la source

- **Fiabilité du transcript** : la transcription audio brute contient de nombreux artefacts de reconnaissance vocale, particulièrement denses sur cette session (ex. "l'esprit alchimique" pour *SQLAlchemy*, "RedBons"/"le pouls" pour *response*/*engine*, "GVQ" pour *GBQ*, "Val-Zéon, Lafite, Lézéon" pour des noms d'outils de scraping non identifiables avec certitude). Ce chapitre s'appuie prioritairement sur les deux blocs de notes structurées (fiables) et sur les 30 captures d'écran ; la transcription brute n'a servi qu'à retrouver le fil pédagogique.
- **Exemple GitHub API** : le nom d'utilisateur exact utilisé en démonstration live n'est pas identifiable avec certitude dans le transcript garbled — remplacé par un placeholder générique `<username>` plutôt que de risquer une information inventée.
- **Outils de scraping cités par le formateur mais non captés en slide** : un ou deux noms d'outils mentionnés à l'oral (au-delà de webscraper.io et Phantombuster) restent illisibles dans le transcript — non repris ici pour éviter d'inventer une référence.
- **Aucune incohérence technique repérée** dans le contenu des slides eux-mêmes (code SQLAlchemy, BigQuery, requests, BeautifulSoup) — tout est cohérent avec le comportement réel de ces librairies.
- **Contenu ajouté au-delà du transcript** : le tableau récapitulatif "3 façons de requêter une API", le motif transversal "Pandas comme point d'atterrissage universel" reliant SQLAlchemy et BigQuery, la clarification `params` vs `data` par méthode HTTP, et la distinction `find` vs `find_all`.

---

🔗 Voir aussi : [[27-pandas-manipulation-donnees|Pandas — Manipulation de données]] · [[Requêtes API avec requests (Python)]] · [[Web scraping avec BeautifulSoup (Python)]]
