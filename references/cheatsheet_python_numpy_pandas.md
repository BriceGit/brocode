---
title: Cheat Sheet — Python · NumPy · pandas
aliases:
  - Cheat Sheet Python
  - Python NumPy pandas
  - Python Data Cheat Sheet
type: reference
status: active
course: "Le Wagon — Data Analytics #2321"
topics:
  - Python
  - NumPy
  - pandas
tags:
  - brocode
  - wagon2321/cours
  - python
  - numpy
  - pandas
  - cheatsheet
---

# 🐍 Cheat Sheet — Python · NumPy · pandas


> [!abstract] Objectif
> Une fiche de référence rapide pour **écrire, lire, déboguer et manipuler des données** en Python, NumPy et pandas.

> [!important] Réflexe central
> **Python** gère la logique générale · **NumPy** gère efficacement les tableaux numériques · **pandas** gère les données tabulaires avec `Series` et `DataFrame`.

> [!tip] Navigation Obsidian
> Utilise le **Sommaire**, l’**Outline** d’Obsidian et `Cmd/Ctrl + O` pour naviguer rapidement. Les liens internes de cette fiche ciblent directement les headings de la note.

---

## 🧭 Sommaire

1. [[#1 — Python : fondamentaux|Python — fondamentaux]]
2. [[#2 — Python : structures de données|Python — structures de données]]
3. [[#3 — Python : conditions, boucles et compréhensions|Python — conditions, boucles et compréhensions]]
4. [[#4 — Python : fonctions|Python — fonctions]]
5. [[#5 — Python : outils très utiles en Data|Python — outils très utiles en Data]]
6. [[#6 — NumPy : fondamentaux|NumPy — fondamentaux]]
7. [[#7 — NumPy : indexing, filtering et broadcasting|NumPy — indexing, filtering et broadcasting]]
8. [[#8 — NumPy : calculs et statistiques|NumPy — calculs et statistiques]]
9. [[#9 — pandas : objets essentiels|pandas — objets essentiels]]
10. [[#10 — pandas : inspection rapide|pandas — inspection rapide]]
11. [[#11 — pandas : sélection et filtrage|pandas — sélection et filtrage]]
12. [[#12 — pandas : création et transformation de colonnes|pandas — création et transformation de colonnes]]
13. [[#13 — pandas : valeurs manquantes|pandas — valeurs manquantes]]
14. [[#14 — pandas : nettoyage texte|pandas — nettoyage texte]]
15. [[#15 — pandas : tri, doublons et valeurs uniques|pandas — tri, doublons et valeurs uniques]]
16. [[#16 — pandas : groupby et agrégations|pandas — groupby et agrégations]]
17. [[#17 — pandas : merge, join et concat|pandas — merge, join et concat]]
18. [[#18 — pandas : reshape, pivot et melt|pandas — reshape, pivot et melt]]
19. [[#19 — pandas : dates et time series|pandas — dates et time series]]
20. [[#20 — pandas : fenêtres et calculs analytiques|pandas — fenêtres et calculs analytiques]]
21. [[#21 — pandas : import/export|pandas — import/export]]
22. [[#22 — SQL ↔ pandas|SQL ↔ pandas]]
23. [[#23 — Pipeline Data Analyst type|Pipeline Data Analyst type]]
24. [[#24 — Pièges fréquents|Pièges fréquents]]
25. [[#25 — Debug express|Debug express]]
26. [[#26 — Recettes indispensables|Recettes indispensables]]
27. [[#27 — Ultra cheat sheet|Ultra cheat sheet]]

---

## 1 — Python : fondamentaux

### Imports usuels

```python
import numpy as np
import pandas as pd
```

### Variables

```python
name = "Brice"
age = 35
price = 12.5
is_active = True
nothing = None
```

Python utilise un typage dynamique :

```python
x = 10
x = "hello"
```

### Types fondamentaux

| Type | Exemple | Usage |
|---|---|---|
| `int` | `42` | entier |
| `float` | `3.14` | nombre décimal |
| `str` | `"hello"` | texte |
| `bool` | `True` | logique |
| `NoneType` | `None` | absence de valeur |

```python
type(42)
type(3.14)
type("hello")
```

### Conversion de types

```python
int("42")
float("3.14")
str(42)
bool(1)
```

⚠️ Une conversion invalide lève une exception :

```python
int("hello")  # ValueError
```

### Opérateurs arithmétiques

```python
10 + 3    # 13
10 - 3    # 7
10 * 3    # 30
10 / 3    # division réelle
10 // 3   # division entière
10 % 3    # modulo
10 ** 3   # puissance
```

### Comparaisons

```python
x == 10
x != 10
x > 10
x >= 10
x < 10
x <= 10
```

### Logique

```python
x > 0 and x < 10
x < 0 or x > 100
not x == 10
```

#### Réflexe Pythonique

```python
0 < x < 10
```

plutôt que :

```python
x > 0 and x < 10
```

### Identité vs égalité

```python
a == b   # même valeur ?
a is b   # même objet ?
```

Pour `None` :

```python
x is None
x is not None
```

---

## 2 — Python : structures de données

### List

Ordonnée, mutable, doublons autorisés.

```python
numbers = [10, 20, 30]
```

#### Accès

```python
numbers[0]
numbers[-1]
numbers[1:3]
numbers[:2]
numbers[1:]
numbers[::2]
numbers[::-1]
```

#### Modification

```python
numbers.append(40)
numbers.extend([50, 60])
numbers.insert(1, 15)
numbers.remove(20)
last = numbers.pop()
```

#### Utilitaires

```python
len(numbers)
min(numbers)
max(numbers)
sum(numbers)
sorted(numbers)
```

```python
numbers.sort()      # modifie la liste
sorted(numbers)     # retourne une nouvelle liste
```

### Tuple

Ordonné mais immutable.

```python
point = (10, 20)
x, y = point
```

Très utile pour retourner plusieurs valeurs :

```python
def min_max(values):
    return min(values), max(values)

minimum, maximum = min_max([3, 7, 2])
```

### Dict

Structure clé → valeur.

```python
user = {
    "name": "Alice",
    "age": 29,
    "country": "France"
}
```

#### Accès

```python
user["name"]
user.get("name")
user.get("city", "unknown")
```

#### Modification

```python
user["age"] = 30
user["city"] = "Paris"
```

#### Parcours

```python
for key in user:
    print(key)

for value in user.values():
    print(value)

for key, value in user.items():
    print(key, value)
```

### Set

Collection de valeurs uniques.

```python
countries = {"FR", "CH", "DE"}
```

```python
countries.add("IT")
countries.remove("DE")
```

Très pratique pour dédupliquer :

```python
unique_values = set([1, 1, 2, 2, 3])
```

#### Opérations ensemblistes

```python
a | b   # union
a & b   # intersection
a - b   # différence
a ^ b   # différence symétrique
```

### Membership

```python
"FR" in countries
"name" in user
3 in [1, 2, 3]
```

---

## 3 — Python : conditions, boucles et compréhensions

### if / elif / else

```python
if score >= 80:
    level = "high"
elif score >= 50:
    level = "medium"
else:
    level = "low"
```

### Expression conditionnelle

```python
status = "adult" if age >= 18 else "minor"
```

### for

```python
for value in values:
    print(value)
```

Avec index :

```python
for index, value in enumerate(values):
    print(index, value)
```

### range

```python
range(5)          # 0,1,2,3,4
range(1, 5)       # 1,2,3,4
range(0, 10, 2)   # 0,2,4,6,8
```

### zip

```python
names = ["Alice", "Bob"]
scores = [90, 75]

for name, score in zip(names, scores):
    print(name, score)
```

### while

```python
while x < 10:
    x += 1
```

### break / continue

```python
for value in values:
    if value < 0:
        continue
    if value > 100:
        break
```

### List comprehension

```python
squares = [x**2 for x in range(10)]
```

Avec condition :

```python
even_squares = [x**2 for x in range(10) if x % 2 == 0]
```

Avec `if/else` dans l'expression :

```python
labels = ["positive" if x >= 0 else "negative" for x in values]
```

### Dict comprehension

```python
squares = {x: x**2 for x in range(5)}
```

### Set comprehension

```python
first_letters = {name[0] for name in names}
```

---

## 4 — Python : fonctions

### Fonction simple

```python
def add(a, b):
    return a + b
```

### Valeur par défaut

```python
def greet(name, greeting="Hello"):
    return f"{greeting} {name}"
```

### Arguments nommés

```python
greet(name="Alice", greeting="Bonjour")
```

### Type hints

```python
def add(a: float, b: float) -> float:
    return a + b
```

### `*args`

Nombre variable d'arguments positionnels :

```python
def total(*values):
    return sum(values)
```

### `**kwargs`

Nombre variable d'arguments nommés :

```python
def show_user(**kwargs):
    print(kwargs)
```

### Lambda

```python
square = lambda x: x**2
```

Très fréquent avec pandas :

```python
df["label"] = df["score"].apply(lambda x: "high" if x > 80 else "low")
```

> **Attention** — Une fonction vectorisée pandas/NumPy est généralement préférable à `apply(lambda ...)` lorsqu'elle existe.

### Scope

```python
x = 10

def f():
    x = 20  # variable locale
```

### Docstring

```python
def churn_rate(churned: int, customers: int) -> float:
    """Return customer churn rate."""
    return churned / customers
```

---

## 5 — Python : outils très utiles en Data

### f-string

```python
name = "Alice"
score = 92.456

print(f"{name}: {score:.2f}")
```

### Unpacking

```python
a, b = [10, 20]
```

```python
first, *middle, last = [1, 2, 3, 4, 5]
```

Fusion de listes :

```python
new_list = [*list_a, *list_b]
```

Fusion de dictionnaires :

```python
new_dict = {**dict_a, **dict_b}
```

ou :

```python
new_dict = dict_a | dict_b
```

### enumerate

```python
for i, value in enumerate(values, start=1):
    print(i, value)
```

### zip

```python
pairs = list(zip(names, scores))
```

### sorted avec key

```python
sorted(users, key=lambda user: user["score"], reverse=True)
```

### any / all

```python
any(x < 0 for x in values)
all(x >= 0 for x in values)
```

### map / filter

```python
list(map(str.upper, names))
list(filter(lambda x: x > 0, values))
```

En pratique Data : les compréhensions, NumPy ou pandas sont souvent plus lisibles.

### Exceptions

```python
try:
    value = int(text)
except ValueError:
    value = None
```

```python
try:
    ...
except FileNotFoundError:
    ...
except ValueError:
    ...
else:
    ...
finally:
    ...
```

### Lecture de fichier texte

```python
with open("file.txt", "r", encoding="utf-8") as file:
    content = file.read()
```

### Modules

```python
import math
from pathlib import Path
from collections import Counter
```

### pathlib

```python
from pathlib import Path

path = Path("data") / "customers.csv"
path.exists()
path.name
path.suffix
```

---

## 6 — NumPy : fondamentaux

NumPy est centré sur l'objet `ndarray`.

```python
import numpy as np
```

### Création

```python
a = np.array([1, 2, 3])
b = np.array([[1, 2], [3, 4]])
```

### Générateurs utiles

```python
np.zeros(5)
np.ones(5)
np.full(5, 42)
np.arange(0, 10, 2)
np.linspace(0, 1, 5)
```

Matrices :

```python
np.zeros((3, 4))
np.ones((2, 2))
np.eye(3)
```

### Propriétés fondamentales

```python
a.shape
a.ndim
a.size
a.dtype
```

Exemple :

```python
arr = np.array([[1, 2, 3], [4, 5, 6]])

arr.shape   # (2, 3)
arr.ndim    # 2
arr.size    # 6
arr.dtype
```

### dtype

```python
np.array([1, 2, 3], dtype=float)
```

Conversions :

```python
arr.astype(float)
arr.astype(int)
```

### reshape

```python
arr = np.arange(12)
arr.reshape(3, 4)
```

Une dimension peut être inférée :

```python
arr.reshape(-1, 3)
```

### flatten / ravel

```python
arr.flatten()  # copie
arr.ravel()    # vue si possible
```

### transpose

```python
arr.T
np.transpose(arr)
```

### concaténation

```python
np.concatenate([a, b])
np.vstack([a, b])
np.hstack([a, b])
```

---

## 7 — NumPy : indexing, filtering et broadcasting

### Indexing 1D

```python
a = np.array([10, 20, 30, 40])

a[0]
a[-1]
a[1:3]
a[::2]
```

### Indexing 2D

```python
matrix[row, column]
```

```python
matrix[0, 1]
matrix[:, 0]
matrix[0, :]
matrix[:2, 1:3]
```

### Boolean masking

```python
a[a > 20]
```

```python
mask = (a >= 20) & (a <= 40)
a[mask]
```

⚠️ Avec NumPy/pandas, utiliser :

```python
&   # AND
|   # OR
~   # NOT
```

avec parenthèses :

```python
(a > 10) & (a < 40)
```

et non :

```python
(a > 10) and (a < 40)  # incorrect pour un array
```

### np.where

```python
np.where(a >= 20, "high", "low")
```

Analogue d'un `CASE WHEN` simple.

### np.select

Plusieurs conditions :

```python
conditions = [
    scores >= 80,
    scores >= 50
]

choices = ["high", "medium"]

labels = np.select(conditions, choices, default="low")
```

### Fancy indexing

```python
a[[0, 2, 3]]
```

### Broadcasting

NumPy peut appliquer des opérations entre arrays de formes compatibles sans recopier explicitement les données.

```python
a = np.array([1, 2, 3])
a + 10
```

```python
matrix = np.array([
    [1, 2, 3],
    [4, 5, 6]
])

matrix + np.array([10, 20, 30])
```

#### Règle mentale

NumPy compare les dimensions **depuis la droite**. Deux dimensions sont compatibles si :

- elles sont égales ;
- ou l'une vaut `1`.

Exemple :

```text
(2, 3)
   (3)
------
(2, 3)
```

### Vectorization

Préférer :

```python
arr * 2
```

à :

```python
[x * 2 for x in arr]
```

NumPy implémente de nombreuses opérations sous forme de fonctions vectorisées / ufuncs.

---

## 8 — NumPy : calculs et statistiques

### Calcul élément par élément

```python
a + b
a - b
a * b
a / b
a ** 2
```

### Fonctions mathématiques

```python
np.sqrt(a)
np.exp(a)
np.log(a)
np.abs(a)
np.round(a, 2)
```

### Agrégations

```python
np.sum(a)
np.mean(a)
np.median(a)
np.min(a)
np.max(a)
np.std(a)
np.var(a)
```

### Axis

Pour une matrice :

```python
matrix.sum(axis=0)  # agrège les lignes → résultat par colonne
matrix.sum(axis=1)  # agrège les colonnes → résultat par ligne
```

#### Mémo

```text
axis=0 → on descend verticalement → résultat par colonne
axis=1 → on traverse horizontalement → résultat par ligne
```

### argmin / argmax

```python
np.argmin(a)
np.argmax(a)
```

### NaN

```python
np.nan
np.isnan(a)
```

Agrégations ignorant les NaN :

```python
np.nansum(a)
np.nanmean(a)
np.nanmedian(a)
```

### Valeurs uniques

```python
np.unique(a)
```

Avec compte :

```python
values, counts = np.unique(a, return_counts=True)
```

### Random moderne

```python
rng = np.random.default_rng(42)

rng.random(5)
rng.integers(0, 10, size=5)
rng.normal(loc=0, scale=1, size=100)
rng.choice(["A", "B", "C"], size=10)
```

La seed permet la reproductibilité :

```python
rng = np.random.default_rng(42)
```

---

## 9 — pandas : objets essentiels

```python
import pandas as pd
```

### Series

Une colonne avec un index.

```python
s = pd.Series([10, 20, 30], name="sales")
```

### DataFrame

Table à deux dimensions.

```python
df = pd.DataFrame({
    "customer_id": [1, 2, 3],
    "country": ["FR", "CH", "FR"],
    "sales": [100, 200, 150]
})
```

### Index

```python
df.index
df.columns
```

Changer l'index :

```python
df = df.set_index("customer_id")
```

Revenir à un index standard :

```python
df = df.reset_index()
```

---

## 10 — pandas : inspection rapide

### Les commandes à lancer presque systématiquement

```python
df.head()
df.tail()
df.shape
df.columns
df.dtypes
df.info()
df.describe()
```

### Nombre de lignes / colonnes

```python
len(df)
df.shape[0]
df.shape[1]
```

### Statistiques descriptives

```python
df.describe()
```

Inclure les colonnes non numériques :

```python
df.describe(include="all")
```

### Valeurs uniques

```python
df["country"].unique()
df["country"].nunique()
df["country"].value_counts()
```

Inclure les valeurs manquantes :

```python
df["country"].value_counts(dropna=False)
```

### Missing values

```python
df.isna().sum()
```

Part de valeurs manquantes :

```python
df.isna().mean().sort_values(ascending=False)
```

### Doublons

```python
df.duplicated().sum()
```

Sur une clé métier :

```python
df.duplicated(subset=["customer_id"]).sum()
```

### Mémoire

```python
df.memory_usage(deep=True)
```

---

## 11 — pandas : sélection et filtrage

### Sélection d'une colonne

```python
df["sales"]
```

Résultat : `Series`.

### Plusieurs colonnes

```python
df[["customer_id", "sales"]]
```

Résultat : `DataFrame`.

### `.loc[]`

Sélection par **labels**.

```python
df.loc[rows, columns]
```

```python
df.loc[:, ["country", "sales"]]
```

```python
df.loc[df["sales"] > 100, ["customer_id", "sales"]]
```

### `.iloc[]`

Sélection par **positions**.

```python
df.iloc[0]
df.iloc[:5]
df.iloc[:, :3]
df.iloc[0:5, 0:3]
```

### Filtre simple

```python
df[df["sales"] > 100]
```

### Plusieurs conditions

```python
df[(df["sales"] > 100) & (df["country"] == "FR")]
```

```python
df[(df["country"] == "FR") | (df["country"] == "CH")]
```

### isin

Analogue de `IN` en SQL :

```python
df[df["country"].isin(["FR", "CH"])]
```

Inverse :

```python
df[~df["country"].isin(["FR", "CH"])]
```

### between

```python
df[df["sales"].between(100, 500)]
```

### query

```python
df.query("sales > 100 and country == 'FR'")
```

Pratique pour les filtres lisibles, mais les expressions booléennes standards restent souvent plus explicites.

---

## 12 — pandas : création et transformation de colonnes

### Création simple

```python
df["revenue_eur"] = df["revenue"] * 0.92
```

### Calcul entre colonnes

```python
df["margin"] = df["revenue"] - df["cost"]
```

### Ratio

```python
df["margin_rate"] = df["margin"] / df["revenue"]
```

⚠️ Vérifier les divisions par zéro :

```python
df["margin_rate"] = np.where(
    df["revenue"].ne(0),
    df["margin"] / df["revenue"],
    np.nan
)
```

### assign

```python
df = df.assign(
    margin=df["revenue"] - df["cost"],
    is_profitable=df["revenue"] > df["cost"]
)
```

### rename

```python
df = df.rename(columns={
    "cust_id": "customer_id",
    "rev": "revenue"
})
```

### drop

```python
df = df.drop(columns=["unused_column"])
```

### astype

```python
df["customer_id"] = df["customer_id"].astype("int64")
```

### map

Remplacement / mapping sur une `Series` :

```python
country_map = {
    "FR": "France",
    "CH": "Switzerland"
}

df["country_name"] = df["country"].map(country_map)
```

### replace

```python
df["status"] = df["status"].replace({
    "A": "active",
    "I": "inactive"
})
```

### apply

```python
df["segment"] = df["score"].apply(custom_function)
```

#### À retenir

Avant `apply`, chercher une opération vectorisée :

- opérateur arithmétique ;
- `.str` ;
- `.dt` ;
- `.map()` ;
- `.replace()` ;
- `np.where()` ;
- `np.select()`.

---

## 13 — pandas : valeurs manquantes

### Détection

```python
df.isna()
df.isnull()
```

```python
df["age"].isna()
df["age"].notna()
```

### Compter

```python
df.isna().sum()
```

### Supprimer

```python
df.dropna()
```

Sur certaines colonnes :

```python
df.dropna(subset=["customer_id"])
```

### Remplir

```python
df["age"] = df["age"].fillna(df["age"].median())
```

```python
df["country"] = df["country"].fillna("Unknown")
```

Forward fill :

```python
df["value"] = df["value"].ffill()
```

Backward fill :

```python
df["value"] = df["value"].bfill()
```

> **Réflexe Data Quality** — Ne jamais imputer automatiquement avant d'avoir compris pourquoi la valeur manque.

---

## 14 — pandas : nettoyage texte

Les opérations texte passent généralement par `.str`.

### Lower / upper

```python
df["name"].str.lower()
df["name"].str.upper()
```

### Strip

```python
df["name"] = df["name"].str.strip()
```

### Replace

```python
df["phone"] = df["phone"].str.replace(" ", "", regex=False)
```

### Contains

```python
df[df["email"].str.contains("gmail", case=False, na=False)]
```

### Startswith / endswith

```python
df["email"].str.startswith("admin")
df["email"].str.endswith(".com")
```

### Split

```python
df["email"].str.split("@")
```

Extraire une partie :

```python
df["domain"] = df["email"].str.split("@").str[-1]
```

### Regex extract

```python
df["postal_code"] = df["address"].str.extract(r"(\d{5})")
```

### Nettoyage de noms de colonnes

Pattern fréquent :

```python
df.columns = (
    df.columns
      .str.strip()
      .str.lower()
      .str.replace(" ", "_", regex=False)
)
```

---

## 15 — pandas : tri, doublons et valeurs uniques

### Tri

```python
df.sort_values("sales")
```

Décroissant :

```python
df.sort_values("sales", ascending=False)
```

Plusieurs colonnes :

```python
df.sort_values(
    ["country", "sales"],
    ascending=[True, False]
)
```

### nlargest / nsmallest

```python
df.nlargest(10, "sales")
df.nsmallest(10, "sales")
```

### Doublons

```python
df.duplicated()
df.duplicated().sum()
```

Sur une clé :

```python
df.duplicated(subset=["customer_id"], keep=False)
```

Suppression :

```python
df = df.drop_duplicates()
```

```python
df = df.drop_duplicates(
    subset=["customer_id"],
    keep="last"
)
```

### Valeurs uniques

```python
df["country"].unique()
df["country"].nunique()
df["country"].value_counts()
```

Proportions :

```python
df["country"].value_counts(normalize=True)
```

---

## 16 — pandas : groupby et agrégations

### Modèle mental

```text
SPLIT → APPLY → COMBINE
```

1. séparer les lignes par groupe ;
2. appliquer une opération à chaque groupe ;
3. recombiner le résultat.

### Agrégation simple

```python
df.groupby("country")["sales"].sum()
```

### Retourner un DataFrame

```python
df.groupby("country", as_index=False)["sales"].sum()
```

### Plusieurs clés

```python
df.groupby(["country", "segment"], as_index=False)["sales"].sum()
```

### Plusieurs métriques

```python
df.groupby("country", as_index=False).agg(
    revenue=("sales", "sum"),
    avg_order=("sales", "mean"),
    customers=("customer_id", "nunique"),
    orders=("order_id", "count")
)
```

#### Named aggregation

Pattern à privilégier :

```python
summary = (
    df.groupby("country", as_index=False)
      .agg(
          total_sales=("sales", "sum"),
          avg_sales=("sales", "mean"),
          n_customers=("customer_id", "nunique")
      )
)
```

### count vs size

```python
grouped["column"].count()
```

`count()` ignore les valeurs manquantes de la colonne.

```python
grouped.size()
```

`size()` compte les lignes.

### transform

Conserve la granularité initiale.

```python
df["country_avg"] = (
    df.groupby("country")["sales"]
      .transform("mean")
)
```

Très proche conceptuellement d'une Window Function SQL.

Exemple ratio au total du groupe :

```python
df["share_country"] = (
    df["sales"]
    / df.groupby("country")["sales"].transform("sum")
)
```

### filter sur les groupes

```python
df.groupby("country").filter(
    lambda group: len(group) >= 100
)
```

### cumcount

```python
df["row_number"] = df.groupby("customer_id").cumcount() + 1
```

---

## 17 — pandas : merge, join et concat

### merge

Analogue principal du `JOIN` SQL.

```python
result = left.merge(
    right,
    on="customer_id",
    how="left"
)
```

### Types de merge

```python
how="inner"
how="left"
how="right"
how="outer"
how="cross"
```

### Clés portant des noms différents

```python
left.merge(
    right,
    left_on="customer_id",
    right_on="id",
    how="left"
)
```

### Plusieurs clés

```python
left.merge(
    right,
    on=["customer_id", "date"],
    how="left"
)
```

### suffixes

```python
left.merge(
    right,
    on="id",
    suffixes=("_left", "_right")
)
```

### indicator

Excellent outil de contrôle de jointure :

```python
merged = left.merge(
    right,
    on="customer_id",
    how="outer",
    indicator=True
)

merged["_merge"].value_counts()
```

Valeurs :

```text
left_only
right_only
both
```

### validate

Permet de faire échouer une jointure dont la cardinalité n'est pas celle attendue :

```python
left.merge(
    right,
    on="customer_id",
    validate="one_to_one"
)
```

Autres valeurs utiles :

```text
one_to_one
one_to_many
many_to_one
many_to_many
```

#### Réflexe Brocode

Avant/après un merge, contrôler :

```python
len(left)
len(right)
len(merged)
```

et l'unicité des clés :

```python
left["customer_id"].nunique()
right["customer_id"].nunique()
```

### join

Pratique surtout pour les index :

```python
left.join(right, how="left")
```

### concat vertical

Analogue de `UNION ALL` :

```python
pd.concat([df_2025, df_2026], ignore_index=True)
```

### concat horizontal

```python
pd.concat([df_a, df_b], axis=1)
```

---

## 18 — pandas : reshape, pivot et melt

### pivot

```python
df.pivot(
    index="date",
    columns="country",
    values="sales"
)
```

Nécessite que chaque combinaison index/columns soit unique.

### pivot_table

Permet une agrégation :

```python
pd.pivot_table(
    df,
    index="country",
    columns="segment",
    values="sales",
    aggfunc="sum",
    fill_value=0
)
```

### melt

Wide → long.

```python
long_df = df.melt(
    id_vars=["customer_id"],
    value_vars=["sales_2025", "sales_2026"],
    var_name="year",
    value_name="sales"
)
```

### stack / unstack

```python
df.stack()
df.unstack()
```

Particulièrement utile avec les MultiIndex.

---

## 19 — pandas : dates et time series

### Conversion en datetime

```python
df["date"] = pd.to_datetime(df["date"])
```

Conversion robuste :

```python
df["date"] = pd.to_datetime(
    df["date"],
    errors="coerce"
)
```

Les valeurs non convertibles deviennent manquantes.

### Extraction avec `.dt`

```python
df["year"] = df["date"].dt.year
df["month"] = df["date"].dt.month
df["day"] = df["date"].dt.day
df["weekday"] = df["date"].dt.day_name()
df["quarter"] = df["date"].dt.quarter
```

### Périodes

```python
df["month"] = df["date"].dt.to_period("M")
```

### Timedelta

```python
df["duration"] = df["end_date"] - df["start_date"]
```

En jours :

```python
df["duration_days"] = df["duration"].dt.days
```

### Filtre temporel

```python
df[df["date"] >= "2026-01-01"]
```

```python
df[df["date"].between("2026-01-01", "2026-12-31")]
```

### Date range

```python
pd.date_range("2026-01-01", "2026-12-31", freq="D")
```

### Resample

Pour des séries temporelles indexées par date :

```python
df = df.set_index("date")

monthly = df["sales"].resample("MS").sum()
```

### Rolling

```python
df["rolling_7d"] = df["sales"].rolling(7).mean()
```

---

## 20 — pandas : fenêtres et calculs analytiques

### transform

Conserver une ligne par observation :

```python
df["country_total"] = (
    df.groupby("country")["sales"]
      .transform("sum")
)
```

### Cumul

```python
df["cumulative_sales"] = df["sales"].cumsum()
```

Par groupe :

```python
df["customer_cumulative_sales"] = (
    df.groupby("customer_id")["sales"]
      .cumsum()
)
```

### Ranking

```python
df["rank"] = df["sales"].rank(
    method="dense",
    ascending=False
)
```

Par groupe :

```python
df["rank_country"] = (
    df.groupby("country")["sales"]
      .rank(method="dense", ascending=False)
)
```

### shift

Valeur précédente :

```python
df["previous_sales"] = (
    df.groupby("customer_id")["sales"]
      .shift(1)
)
```

### pct_change

```python
df["growth_rate"] = df["sales"].pct_change()
```

Par groupe :

```python
df["customer_growth"] = (
    df.groupby("customer_id")["sales"]
      .pct_change()
)
```

### rolling par groupe

```python
df["rolling_avg"] = (
    df.groupby("customer_id")["sales"]
      .transform(lambda s: s.rolling(3, min_periods=1).mean())
)
```

---

## 21 — pandas : import/export

### CSV

```python
df = pd.read_csv("customers.csv")
```

Options utiles :

```python
df = pd.read_csv(
    "customers.csv",
    sep=",",
    encoding="utf-8",
    usecols=["customer_id", "country", "sales"],
    parse_dates=["date"]
)
```

Exporter :

```python
df.to_csv("output.csv", index=False)
```

### Excel

```python
df = pd.read_excel("customers.xlsx", sheet_name="customers")
```

```python
df.to_excel("output.xlsx", index=False)
```

### JSON

```python
df = pd.read_json("data.json")
```

### Parquet

```python
df = pd.read_parquet("data.parquet")
```

```python
df.to_parquet("output.parquet", index=False)
```

### SQL

Avec une connexion SQLAlchemy :

```python
df = pd.read_sql(query, connection)
```

---

## 22 — SQL ↔ pandas

| SQL | pandas |
|---|---|
| `SELECT *` | `df` |
| `SELECT col` | `df["col"]` |
| `SELECT a,b` | `df[["a", "b"]]` |
| `WHERE x > 10` | `df[df["x"] > 10]` |
| `IN (...)` | `.isin(...)` |
| `ORDER BY x` | `.sort_values("x")` |
| `GROUP BY` | `.groupby()` |
| `COUNT(*)` | `.size()` |
| `COUNT(col)` | `.count()` |
| `COUNT(DISTINCT col)` | `.nunique()` |
| `SUM(col)` | `.sum()` |
| `AVG(col)` | `.mean()` |
| `MIN(col)` | `.min()` |
| `MAX(col)` | `.max()` |
| `JOIN` | `.merge()` |
| `UNION ALL` | `pd.concat()` |
| `CASE WHEN` | `np.where()` / `np.select()` |
| Window `SUM() OVER()` | `groupby().transform("sum")` |
| `ROW_NUMBER()` | `groupby().cumcount() + 1` |
| `LAG()` | `groupby().shift()` |
| `RANK()` | `.rank()` |

### SELECT / WHERE / GROUP BY

SQL :

```sql
SELECT
  country,
  SUM(sales) AS total_sales
FROM sales
WHERE sales > 0
GROUP BY country;
```

pandas :

```python
summary = (
    df.loc[df["sales"] > 0]
      .groupby("country", as_index=False)
      .agg(total_sales=("sales", "sum"))
)
```

### LEFT JOIN

SQL :

```sql
SELECT *
FROM customers c
LEFT JOIN orders o
  ON c.customer_id = o.customer_id;
```

pandas :

```python
result = customers.merge(
    orders,
    on="customer_id",
    how="left"
)
```

### CASE WHEN

SQL :

```sql
CASE
  WHEN score >= 80 THEN 'high'
  WHEN score >= 50 THEN 'medium'
  ELSE 'low'
END
```

pandas / NumPy :

```python
df["segment"] = np.select(
    [
        df["score"] >= 80,
        df["score"] >= 50
    ],
    ["high", "medium"],
    default="low"
)
```

---

## 23 — Pipeline Data Analyst type

### 1. Charger

```python
import pandas as pd
import numpy as np

raw = pd.read_csv("customers.csv")
```

### 2. Inspecter

```python
raw.head()
raw.shape
raw.info()
raw.describe(include="all")
raw.isna().sum()
raw.duplicated().sum()
```

### 3. Travailler sur une copie

```python
df = raw.copy()
```

### 4. Standardiser les colonnes

```python
df.columns = (
    df.columns
      .str.strip()
      .str.lower()
      .str.replace(" ", "_", regex=False)
)
```

### 5. Corriger les types

```python
df["date"] = pd.to_datetime(df["date"], errors="coerce")
df["amount"] = pd.to_numeric(df["amount"], errors="coerce")
```

### 6. Contrôler la clé / granularité

```python
len(df)
df["customer_id"].nunique()
df.duplicated(subset=["customer_id"]).sum()
```

### 7. Nettoyer

```python
df["country"] = df["country"].str.strip().str.upper()
df = df.dropna(subset=["customer_id"])
```

### 8. Feature engineering

```python
df["is_high_value"] = df["revenue"] >= 1000
df["margin"] = df["revenue"] - df["cost"]
```

### 9. Agréger

```python
customer_summary = (
    df.groupby("customer_id", as_index=False)
      .agg(
          revenue=("revenue", "sum"),
          orders=("order_id", "nunique"),
          last_order=("date", "max")
      )
)
```

### 10. Tester

```python
assert customer_summary["customer_id"].is_unique
assert customer_summary["revenue"].notna().all()
```

### 11. Exporter

```python
customer_summary.to_csv(
    "customer_summary.csv",
    index=False
)
```

---

## 24 — Pièges fréquents

### 1. `and` / `or` avec pandas

❌

```python
df[(df["age"] > 18) and (df["country"] == "FR")]
```

✅

```python
df[(df["age"] > 18) & (df["country"] == "FR")]
```

### 2. Oublier les parenthèses

❌

```python
df[df["age"] > 18 & df["country"] == "FR"]
```

✅

```python
df[(df["age"] > 18) & (df["country"] == "FR")]
```

### 3. `=` vs `==`

```python
x = 10      # affectation
x == 10     # comparaison
```

### 4. Mauvais type de colonne

```python
df.dtypes
```

Une date stockée en `str` ne se comporte pas comme une date.

### 5. Modifier une vue de DataFrame ambiguë

Pattern robuste :

```python
filtered = df.loc[df["sales"] > 0].copy()
filtered["margin"] = filtered["sales"] - filtered["cost"]
```

### 6. `merge` qui multiplie les lignes

Toujours vérifier la granularité et la cardinalité avant la jointure.

```python
left["id"].is_unique
right["id"].is_unique
```

Puis utiliser :

```python
validate="one_to_one"
```

ou la cardinalité attendue.

### 7. `count()` vs `size()`

```python
groupby.size()            # lignes
groupby["col"].count()    # valeurs non nulles
```

### 8. `apply()` partout

Souvent plus lent et moins lisible qu'une opération vectorisée.

Chercher d'abord :

```text
+, -, *, /
.str
.dt
.map
.replace
np.where
np.select
groupby.transform
```

### 9. Arrondir trop tôt

Éviter :

```python
df["ratio"] = (df["a"] / df["b"]).round(2)
# puis réutiliser ratio dans d'autres calculs
```

Préférer garder la précision et arrondir au rendu final :

```python
final["ratio"] = final["ratio"].round(2)
```

### 10. Oublier l'index après groupby

```python
df.groupby("country")["sales"].sum()
```

retourne souvent une `Series` indexée par `country`.

Pour un DataFrame :

```python
df.groupby("country", as_index=False)["sales"].sum()
```

### 11. Confondre copie et modification inplace

Pattern clair :

```python
df = df.drop(columns=["x"])
```

plutôt que multiplier les mutations implicites.

### 12. Mélanger granularités

Si `orders` est à la maille commande et `order_items` à la maille produit, un merge peut dupliquer les métriques commande.

#### Réflexe

```text
Quelle est la granularité de chaque DataFrame ?
Quelle est la clé unique ?
Quelle cardinalité dois-je obtenir ?
```

---

## 25 — Debug express

### Comprendre l'objet

```python
type(obj)
```

### DataFrame

```python
df.shape
df.head()
df.info()
df.dtypes
```

### Vérifier une colonne

```python
df["col"].head()
df["col"].dtype
df["col"].unique()[:20]
df["col"].value_counts(dropna=False).head(20)
```

### Vérifier les nulls

```python
df["col"].isna().sum()
```

### Vérifier la clé

```python
df["id"].nunique()
df["id"].is_unique
df.duplicated("id").sum()
```

### Voir les doublons

```python
df[df.duplicated("id", keep=False)].sort_values("id")
```

### Vérifier un merge

```python
merged = left.merge(
    right,
    on="id",
    how="outer",
    indicator=True
)

merged["_merge"].value_counts()
```

### Vérifier une agrégation

Avant :

```python
before = df["revenue"].sum()
```

Après :

```python
summary = df.groupby("country", as_index=False)["revenue"].sum()
after = summary["revenue"].sum()
```

Test de conservation :

```python
np.isclose(before, after)
```

### Assertions

```python
assert df["customer_id"].notna().all()
assert df["customer_id"].is_unique
assert (df["revenue"] >= 0).all()
```

---

## 26 — Recettes indispensables

### Top N par groupe

```python
top_3 = (
    df.sort_values("sales", ascending=False)
      .groupby("country")
      .head(3)
)
```

### Dernière ligne par client

```python
latest = (
    df.sort_values("date")
      .drop_duplicates("customer_id", keep="last")
)
```

### Première transaction par client

```python
first_orders = (
    df.sort_values("date")
      .drop_duplicates("customer_id", keep="first")
)
```

### Nombre de jours depuis la dernière transaction

```python
reference_date = df["date"].max()

last_order = (
    df.groupby("customer_id", as_index=False)
      .agg(last_order=("date", "max"))
)

last_order["recency_days"] = (
    reference_date - last_order["last_order"]
).dt.days
```

### RFM simplifié

```python
reference_date = df["date"].max() + pd.Timedelta(days=1)

rfm = (
    df.groupby("customer_id", as_index=False)
      .agg(
          last_order=("date", "max"),
          frequency=("order_id", "nunique"),
          monetary=("revenue", "sum")
      )
)

rfm["recency"] = (
    reference_date - rfm["last_order"]
).dt.days
```

### Churn rate

Si une ligne = un client :

```python
churn_rate = df["churned"].mean()
```

Si `churned` est booléen ou codé `0/1`.

Sinon :

```python
churn_rate = (
    df.loc[df["churned"] == 1, "customer_id"].nunique()
    / df["customer_id"].nunique()
)
```

### Retention rate simple

```python
retention_rate = 1 - churn_rate
```

### Cohort month

```python
df["order_month"] = df["date"].dt.to_period("M")

df["cohort_month"] = (
    df.groupby("customer_id")["order_month"]
      .transform("min")
)
```

### Nombre de clients par pays

```python
customers_by_country = (
    df.groupby("country", as_index=False)
      .agg(customers=("customer_id", "nunique"))
)
```

### Part du CA par pays

```python
summary = (
    df.groupby("country", as_index=False)
      .agg(revenue=("revenue", "sum"))
)

summary["revenue_share"] = (
    summary["revenue"] / summary["revenue"].sum()
)
```

### Growth MoM

```python
monthly = (
    df.assign(month=df["date"].dt.to_period("M"))
      .groupby("month", as_index=False)
      .agg(revenue=("revenue", "sum"))
)

monthly["mom_growth"] = monthly["revenue"].pct_change()
```

### Flag multi-condition

```python
df["risk_level"] = np.select(
    [
        (df["churn_probability"] >= 0.8),
        (df["churn_probability"] >= 0.5)
    ],
    ["high", "medium"],
    default="low"
)
```

### Z-score NumPy

```python
z = (x - np.mean(x)) / np.std(x)
```

### IQR et outliers

```python
q1 = df["value"].quantile(0.25)
q3 = df["value"].quantile(0.75)
iqr = q3 - q1

lower = q1 - 1.5 * iqr
upper = q3 + 1.5 * iqr

outliers = df[
    (df["value"] < lower)
    | (df["value"] > upper)
]
```

### Normalisation min-max

```python
scaled = (x - x.min()) / (x.max() - x.min())
```

### Standardisation

```python
standardized = (x - x.mean()) / x.std()
```

---

## 27 — Ultra cheat sheet

### Python

```python
# Types
int, float, str, bool, list, tuple, dict, set

# Conditions
if / elif / else

# Boucles
for x in values:
    ...

for i, x in enumerate(values):
    ...

# Compréhension
[x**2 for x in values if x > 0]

# Fonction
def f(x):
    return x * 2

# Test None
x is None

# Exceptions
try:
    ...
except ValueError:
    ...
```

### NumPy

```python
np.array(...)
np.arange(...)
np.linspace(...)
np.zeros(...)
np.ones(...)

arr.shape
arr.ndim
arr.dtype
arr.reshape(...)

arr[arr > 0]
np.where(condition, yes, no)
np.select(conditions, choices, default=...)

np.sum(arr)
np.mean(arr)
np.median(arr)
np.std(arr)
np.min(arr)
np.max(arr)

arr.sum(axis=0)
arr.sum(axis=1)
```

### pandas — inspecter

```python
df.head()
df.shape
df.info()
df.describe()
df.dtypes
df.isna().sum()
df.duplicated().sum()
```

### pandas — sélectionner

```python
df["col"]
df[["a", "b"]]
df.loc[condition, columns]
df.iloc[rows, columns]
```

### pandas — filtrer

```python
df[df["x"] > 10]
df[(df["x"] > 10) & (df["country"] == "FR")]
df[df["country"].isin(["FR", "CH"])]
```

### pandas — transformer

```python
df["new"] = df["a"] + df["b"]
df["label"] = np.where(condition, "yes", "no")
df["date"] = pd.to_datetime(df["date"], errors="coerce")
```

### pandas — agréger

```python
summary = (
    df.groupby("country", as_index=False)
      .agg(
          revenue=("sales", "sum"),
          customers=("customer_id", "nunique")
      )
)
```

### pandas — join

```python
merged = left.merge(
    right,
    on="id",
    how="left",
    validate="many_to_one"
)
```

### pandas — fenêtres

```python
df.groupby("group")["x"].transform("sum")
df.groupby("group")["x"].shift(1)
df.groupby("group")["x"].rank()
df.groupby("group").cumcount() + 1
```

### pandas — dates

```python
df["date"].dt.year
df["date"].dt.month
df["date"].dt.to_period("M")
```

### pandas — exporter

```python
df.to_csv("output.csv", index=False)
df.to_excel("output.xlsx", index=False)
df.to_parquet("output.parquet", index=False)
```

---

## 🧠 Les 10 réflexes à retenir

1. **Toujours connaître la granularité du DataFrame.**
2. **Toujours identifier la clé supposée unique avant un `merge`.**
3. **Inspecter `shape`, `dtypes`, nulls et doublons avant l'analyse.**
4. **Utiliser `.loc[]` pour les sélections explicites.**
5. **Utiliser `&`, `|`, `~` avec les masques pandas/NumPy.**
6. **Préférer les opérations vectorisées à `apply()` quand elles existent.**
7. **Utiliser `groupby().agg()` pour réduire la granularité ; `transform()` pour la conserver.**
8. **Contrôler les lignes et les métriques avant/après un `merge`.**
9. **Ne pas arrondir les données intermédiaires : arrondir au rendu final.**
10. **Écrire des tests simples (`assert`, conservation des sommes, unicité, nulls) dès que le calcul devient important.**

---

## 🎯 Modèle mental final

```text
PYTHON
│
├── logique générale
├── variables / conditions / boucles
├── fonctions
└── structures de données

NUMPY
│
├── ndarray
├── calcul vectorisé
├── broadcasting
├── masques booléens
└── calcul numérique

PANDAS
│
├── Series / DataFrame
├── sélectionner / filtrer
├── nettoyer / transformer
├── groupby / aggregate
├── merge / concat
├── dates / fenêtres
└── analyse tabulaire
```

```text
Data brute
   ↓
inspect
   ↓
clean
   ↓
types
   ↓
filter
   ↓
transform
   ↓
aggregate / merge
   ↓
test
   ↓
analyse
   ↓
export / dashboard / modèle
```

---

### 📚 Références techniques

Fiche alignée sur la documentation officielle moderne de :

- Python ;
- NumPy ;
- pandas.

Les API évoluent : pour un comportement version-spécifique ou une méthode rare, vérifier la documentation de la version installée.
