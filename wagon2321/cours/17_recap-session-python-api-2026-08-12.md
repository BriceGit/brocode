# 📌 Récap session — Python / Pandas / APIs (12/08/2026)

**Contexte** : debugging de notebooks Jupyter (module Python pandas + module API météo Le Wagon)
**Fil rouge de la journée** : la majorité des bugs viennent de confusions entre **types de données** (string vs autre, tuple vs liste, dict vs liste) plutôt que d'erreurs de logique.

---

## 1️⃣ `\"` casse une string — piège du backslash

```python
# ❌ Erreur
df_orders.to_csv("data/file.csv", sep="\")
# SyntaxError: unterminated string literal
```

**Pourquoi** : `\` est un caractère d'échappement en Python. `\"` juste avant la fermeture d'une string est lu comme un guillemet littéral, pas comme la fermeture → Python cherche un autre `"` pour fermer et ne le trouve pas.

**Règle** : pour un vrai backslash dans une string, il faut le doubler (`"\\"`).

```python
# ✅
df_orders.to_csv("data/file.csv", sep=";")   # ou le vrai séparateur voulu
```

📎 *Même piège que les chemins Windows type `"C:\Users\nom\"`.*

---

## 2️⃣ Colonnes fantômes à l'import Excel (`Unnamed: 0`, `Unnamed: 1`)

**Symptôme** : `pd.read_excel(..., header=3, index_col=3)` ramène des colonnes vides `NaN` en plus des colonnes utiles.

**Cause** : les colonnes A/B du fichier Excel sont vides mais existent quand même dans le sheet → pandas les charge par défaut.

**Deux solutions équivalentes** :
```python
# Option A — dropper après lecture
df = pd.read_excel("file.xlsx", sheet_name="X", header=3, index_col=3).dropna(axis=1, how="all")

# Option B — ne charger que les colonnes utiles dès le départ
df = pd.read_excel("file.xlsx", sheet_name="X", header=3, index_col=3, usecols="C:F")
```

---

## 3️⃣ UNION vs JOIN → `concat` vs `merge`

| Besoin | SQL | pandas |
|---|---|---|
| Empiler des lignes (mêmes colonnes) | `UNION` | `pd.concat([...], axis=0)` |
| Coller des colonnes selon une clé commune | `JOIN` | `pd.merge()` / `.join()` |

```python
df1["restaurant_id"] = 1
df2["restaurant_id"] = 2
df_sales = pd.concat([df1, df2], axis=0)
```

⚠️ **Piège d'index dupliqué** : après un `concat(axis=0)`, l'index se répète (0,1,2... puis 0,1,2... à nouveau). Ajouter `ignore_index=True` dans `concat()` ou faire `.reset_index(drop=True)` après si besoin d'un index propre.

---

## 4️⃣ Lire un CSV compressé (`.csv.gz`)

Pas besoin de décompresser à la main : `read_csv` gère la décompression à la volée.

```python
# Auto-détection via l'extension (recommandé)
df = pd.read_csv("data/file.csv.gz")

# Explicite
df = pd.read_csv("data/file.csv.gz", compression="gzip")
```

---

## 5️⃣ `requests.get()` avec `params` plutôt qu'une URL codée en dur

```python
url = "https://weather.lewagon.com/geo/1.0/direct"
params = {"q": "Paris"}
response = requests.get(url, params=params)
```

**Avantages vs concaténation manuelle dans l'URL** :
- Encodage automatique des caractères spéciaux (espaces, accents)
- Paramètres nommés et lisibles
- Facile à rendre dynamique dans une fonction (`params={"q": city_name}`)

⚠️ **Piège classique** : écrire `"...?q=city_name"` dans une f-string ou une string brute au lieu de `params={"q": city_name}` → `city_name` est alors interprété littéralement comme texte, pas comme la variable. Résultat : requête vers une ville qui n'existe pas → réponse vide.

---

## 6️⃣ Indexer `[0]` vs slicer `[-1:1]`

`paris_info` = liste contenant **un seul dictionnaire** : `[{...}]`

| Syntaxe | Type de `[]` | Résultat |
|---|---|---|
| `paris_info[0]` | indexation (entier) | **le dictionnaire** lui-même |
| `paris_info[-1:1]` ou `[0:1]` | slice (`:`) | une **nouvelle liste** contenant le dict |

➡️ Pour accéder aux clés (`["lat"]`, `["lon"]`), il faut d'abord **indexer** avec `[0]`, sinon on tente d'appliquer `["lat"]` sur une liste → erreur.

---

## 7️⃣ Tuple sans crochets vs liste

```python
output = jsonfile[0]["lat"], jsonfile[0]["lon"]     # ❌ tuple : (48.85, 2.32)
output = [jsonfile[0]["lat"], jsonfile[0]["lon"]]   # ✅ liste : [48.85, 2.32]
```

**Règle** : en Python, une virgule entre deux valeurs crée un **tuple** par assignation implicite (`a, b` ≡ `(a, b)`), avec ou sans parenthèses. Il faut des **crochets explicites** `[ ]` pour forcer une vraie liste.

📎 *Un test qui échoue avec `(x, y) != [x, y]` (mêmes valeurs, types différents) = signal direct de ce piège.*

---

## 8️⃣ Dict "enveloppe" avant la vraie donnée

Une réponse d'API n'est pas toujours directement exploitable — souvent il y a un niveau d'emballage à identifier :

```python
paris_forecasts            # dict complet : {"cod":..., "city":..., "list": [...]}
paris_forecasts["list"]    # la vraie liste de créneaux de prévisions
```

➡️ Toujours faire un `paris_forecasts.keys()` ou regarder un extrait avant de boucler dessus, pour repérer la bonne clé d'entrée.

---

## 9️⃣ `KeyError` vs `IndexError` — diagnostic rapide

| Erreur | Signification | Cause typique |
|---|---|---|
| `IndexError: list index out of range` | tu indexes une **liste** en dehors de ses bornes | souvent une liste **vide** (requête sans résultat) |
| `KeyError: 0` (avec un entier comme clé) | tu traites un **dict** comme une liste | tu fais `dict[0]` au lieu de `dict["une_clé"]` |

➡️ `KeyError: 0` est presque toujours un signe qu'on confond dict et liste — vérifier le type avec `type(variable)` en cas de doute.

---

## 🔟 Construire un nouveau dict à partir d'une boucle `for`

Objectif : extraire des infos d'une liste de dicts (ex: prévisions météo) vers 2 listes séparées, puis les ranger dans un dict.

```python
times = []
maxs = []
for element in paris_forecasts["list"]:
    times.append(element["dt_txt"])
    maxs.append(element["main"]["temp_max"])

paris_dict = {"datetime": times, "max_temperature": maxs}
```

**Point clé à retenir** : le nom de la **variable** (`times`, `maxs`) n'a **aucun lien obligatoire** avec le nom de la **clé** choisie dans le dict (`"datetime"`, `"max_temperature"`). On peut nommer les clés comme on veut, indépendamment des noms de variables utilisés pour les construire.

---

## 1️⃣1️⃣ Laisser le test dicter la structure attendue d'une fonction

Piège rencontré : hésitation sur si `get_forecasts()` devait renvoyer le JSON brut de l'API, ou un dict déjà transformé (`{"datetime": [...], "max_temperature": [...]}`).

**Réflexe à avoir** : quand un test (`ChallengeResult`, `assertEqual`, etc.) est disponible, **lire ce qu'il compare** donne la réponse directement — le nom des clés utilisées dans l'assertion (`self.result.output['max_temperature']`) révèle exactement la structure que la fonction doit renvoyer.

```python
self.assertEqual(
    self.result.output['max_temperature'][:5],
    forecasts_function(self.result.f1)['max_temperature'][:5]
)
```
➡️ Ici, la présence de `['max_temperature']` sur `self.result.output` (= le retour de la fonction testée) indique que la fonction doit déjà renvoyer un dict transformé, pas le JSON brut.

**Fonction finale correcte** :
```python
def get_forecasts(city_name):
    coordinates = get_coordinates(city_name)
    response = requests.get(
        "https://weather.lewagon.com/data/2.5/forecast",
        params={"lat": coordinates[0], "lon": coordinates[1]}
    )
    jsonfile = response.json()

    times = []
    maxs = []
    for element in jsonfile["list"]:
        times.append(element["dt_txt"])
        maxs.append(element["main"]["temp_max"])

    return {"datetime": times, "max_temperature": maxs}
```

---

## 🧠 Fil conducteur à retenir

Avant de manipuler une variable (indexer, boucler, extraire une clé) :
1. **Vérifier son type** (`type(x)` ou juste regarder l'affichage : `{}` = dict, `[]` = liste)
2. **Vérifier s'il y a un niveau d'emballage** (`["list"]`, `[0]`) avant la vraie donnée utile
3. **Lire les tests disponibles** s'il y en a — ils décrivent souvent la structure exacte attendue mieux que l'énoncé
