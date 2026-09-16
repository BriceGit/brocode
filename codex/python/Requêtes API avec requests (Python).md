---
title: Requêtes API avec requests (Python)
type: concept
status: active
modeles_ia: []
attribution: a_confirmer
language: fr
tags:
- brocode
- codex
---

# Requêtes API avec requests (Python)

`requests` est la librairie de référence en Python pour interroger une API : robuste, largement adoptée par la communauté, une seule fonction à retenir pour la quasi-totalité des cas d'usage.

## Trois façons de requêter une API

| Méthode | Exemple | Cas d'usage |
|---|---|---|
| No-code | Insomnia | Explorer/tester rapidement, sans écrire de code |
| Terminal | `curl` | Présent dans la doc de la plupart des API, peu confortable au quotidien |
| Code | `requests` (Python) | Intégrer l'appel dans un pipeline, un notebook, un script |

## Anatomie d'une requête

```python
import requests

response = requests.method(url, params=params, data=data, headers=headers)
# en pratique : requests.get(...), requests.post(...), requests.put(...), requests.delete(...)
```

| Argument | Contenu | Rôle |
|---|---|---|
| `url` | `"http://base_url.com/endpoint_name/"` | L'endpoint ciblé |
| `params` | `{"key1": value1, ...}` | Paramètres d'une requête **GET** |
| `data` | `{"key1": value1, ...}` | Données envoyées dans une requête **POST** |
| `headers` | `{"Authorization": "Bearer TOKEN", "User-Agent": "...", ...}` | Métadonnées : clé API, token, type de contenu |

> [!tip] Réflexe GET/POST
> **GET → `params`** (on demande de la donnée, les paramètres finissent visibles dans l'URL). **POST → `data`** (on envoie de la donnée, dans le corps de la requête, hors de l'URL). Même logique que sur un client comme Insomnia.

## Exploiter la réponse

```python
response.url             # URL effectivement requêtée
response.status_code     # code de statut HTTP
response.text            # résultat en string — difficile à exploiter
response.json()          # résultat en dictionnaire Python — à privilégier
```

## Status codes — les 5 familles

| Famille | Sens | Exemples |
|---|---|---|
| 1XX | Information | `102` en cours de traitement |
| 2XX | Succès | `200` succès · `204` succès, résultat vide |
| 3XX | Redirection | `301` requête redirigée |
| 4XX | Erreur client | `400` requête incorrecte · `401` non autorisé · `404` endpoint introuvable |
| 5XX | Erreur serveur | `500` erreur côté serveur |

Réflexe : vérifier `response.status_code` **avant** de traiter `response.json()` — un code 4XX/5XX signifie que le contenu de la réponse n'est probablement pas la donnée attendue.

## Exemple minimal (API publique, sans authentification)

```python
response = requests.get("https://api.github.com/users/<username>")
data = response.json()   # dictionnaire Python
data["id"]                 # accès à une clé précise
```

Pour une API nécessitant une authentification, la clé/le token se place dans `headers` (`{"Authorization": "Bearer YOUR_API_TOKEN"}`), jamais dans l'URL en clair.

---
🔗 Vu dans [[wagon2321/cours/28-acces-donnees-api-scraping|Accès aux données]]
🔗 Prolongé par [[codex/python/Web scraping avec BeautifulSoup (Python)|Web scraping avec BeautifulSoup (Python)]] — même point de départ (`requests.get`), destination différente (parser du HTML plutôt que du JSON)
