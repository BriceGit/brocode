# Web scraping avec BeautifulSoup (Python)

Le web scraping combine `requests` (récupérer le HTML brut d'une page) et `BeautifulSoup` (le parser pour en extraire des éléments précis).

> [!warning] Légalité avant tout
> Le scraping n'est **pas légal sur tous les sites** — toujours vérifier les conditions d'utilisation (terms of use) avant de scraper. LinkedIn et Amazon, notamment, mettent en place des restrictions anti-bot fortes.

## Workflow en 4 étapes

1. **Récupérer** le HTML de la page : `response = requests.get(url)`
2. **Parser** avec BeautifulSoup : `soup = BeautifulSoup(response.text, "html.parser")`
3. **Cibler** un élément avec `find` (première occurrence) ou `find_all` (toutes les occurrences), par balise + classe
4. **Extraire** le texte pur avec `.text` (retire les balises HTML)

```python
import requests
from bs4 import BeautifulSoup

response = requests.get("https://bootcamp_da.com")
soup = BeautifulSoup(response.text, 'html.parser')

# première occurrence d'un <p class="introduction">
tag_p = soup.find("p", {"class": "introduction"})
print(tag_p.text)

# toutes les occurrences d'un <span class="auteur">
authors = soup.find_all("span", {"class": "auteur"})
```

## Identifier la bonne balise à cibler

Une page web repose sur HTML (structure, balises), CSS (style, souvent piloté par des `class`) et JS (comportements dynamiques). Pour savoir quelle balise/classe cibler : **inspecteur d'éléments du navigateur** (F12, ou clic droit → Inspecter) — il révèle le HTML/CSS exact de n'importe quel élément affiché.

## Construire un jeu de données structuré

Pattern courant : boucler sur les résultats d'un `find_all`, et construire une liste de dictionnaires — directement convertible en DataFrame Pandas ensuite.

```python
quotes = []
for quote in soup.find_all("div", {"class": "quote"}):
    text = quote.find("span", {"class": "text"}).text
    author = quote.find("small", {"class": "author"}).text
    quotes.append({"text": text, "author": author})

# pd.DataFrame(quotes) pour repasser en territoire connu
```

## Sites dynamiques (JavaScript) → Selenium

`requests` + `BeautifulSoup` fonctionnent uniquement sur des sites **statiques** : le HTML récupéré est celui envoyé par le serveur, sans exécution de JavaScript. Si le contenu recherché n'apparaît qu'après exécution de scripts (site "dynamique"), il faut passer par **Selenium**, qui pilote un vrai navigateur et peut donc attendre que le JS s'exécute avant de lire la page.

## Contourner les restrictions basiques

Simuler un vrai navigateur via les `headers` (ex. `User-Agent: Mozilla ...`) peut suffire à passer certaines restrictions légères — sans effet contre des protections anti-bot avancées (LinkedIn, Amazon).

## Pagination

- **URL paramétrée** : incrémenter un numéro de page dans l'URL si le site l'expose directement (ex. `?page=2`)
- **Lien "next"** : suivre l'attribut `href` du bouton "suivant" quand la structure d'URL n'est pas triviale à reconstruire

## Alternatives sans code

| Outil | Spécialité |
|---|---|
| **webscraper.io** | Extension navigateur point-and-click, +400k utilisateurs, API disponible |
| **Phantombuster** | Spécialisé réseaux sociaux (LinkedIn notamment), +100k clients, workflows prêts à l'emploi |

Sauf si le scraping est un actif métier central, s'appuyer sur un outil existant plutôt que de développer une solution sur mesure pour des cibles difficiles (réseaux sociaux) reste souvent le choix le plus rationnel.

---
🔗 Vu dans [[28-acces-donnees-api-scraping|Accès aux données]]
🔗 Point de départ commun avec [[Requêtes API avec requests (Python)]] (`requests.get`), destination différente (HTML à parser plutôt que JSON)
