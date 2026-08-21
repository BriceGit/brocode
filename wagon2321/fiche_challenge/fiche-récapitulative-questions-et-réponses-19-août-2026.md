# 📌 Fiche Récapitulative – Questions et Réponses – 19 août 2026
*Contexte : Travail sur un projet de data analysis (Le Wagon), avec manipulation de DataFrames Pandas, calculs de métriques, et préparation de données pour un modèle de classification.*

---

## 📋 Sommaire
1. [Filtrer des valeurs dans un DataFrame](#1️⃣-filtrer-des-valeurs-dans-un-dataframe)
2. [Remplacer les valeurs `NaN`](#2️⃣-remplacer-les-valeurs-nan)
3. [Extraire les fournisseurs de messagerie uniques](#3️⃣-extraire-les-fournisseurs-de-messagerie-uniques)
4. [Corriger une erreur de syntaxe avec `drop`](#4️⃣-corriger-une-erreur-de-syntaxe-avec-drop)
5. [Créer la colonne `nb_tags`](#5️⃣-créer-la-colonne-nb_tags)
6. [Créer la colonne `nb_goals`](#6️⃣-créer-la-colonne-nb_goals)
7. [Corriger une `KeyError` avec `nb_goals`](#7️⃣-corriger-une-keyerror-avec-nb_goals)
8. [Filtrer avec `is_unwanted == 1`](#8️⃣-filtrer-avec-is_unwanted--1)
9. [Undersampling : Équilibrer les classes](#9️⃣-undersampling-équilibrer-les-classes)
10. [Préparer `X_train`, `X_test`, `y_train`, `y_test`](#🔟-préparer-x_train-x_test-y_train-y_test)
11. [Calculer des métriques (Accuracy, Precision, Recall)](#1️⃣1️⃣-calculer-des-métriques-accuracy-precision-recall)
12. [Importer des modules (`LogisticRegression`, `StandardScaler`)](#1️⃣2️⃣-importer-des-modules-logisticregression-standardscaler)
13. [Appliquer `StandardScaler`](#1️⃣3️⃣-appliquer-standardscaler)

---

---

### 1️⃣ Filtrer des valeurs dans un DataFrame
**Question :**
*Comment filtrer des lignes où une colonne a une valeur spécifique (ex. : probabilité entre 20 % et 50 %) ?*

**Réponse :**
Utiliser une **condition booléenne** ou `query()` :
```python
# Méthode 1 : Condition booléenne
df_filtre = df[(df["Will Repurchase"] >= 0.2) & (df["Will Repurchase"] <= 0.5)]

# Méthode 2 : Avec query()
df_filtre = df.query("`Will Repurchase` >= 0.2 and `Will Repurchase` <= 0.5")
```
**→ Astuce :** Vérifier que la colonne existe avec `df.columns`.

---

### 2️⃣ Remplacer les valeurs `NaN`
**Question :**
*Comment remplacer les `NaN` dans des colonnes spécifiques (`nb_chars_in_bio`, `tags`, `goals`) ?*

**Réponse :**
Utiliser `fillna()` :
```python
df["nb_chars_in_bio"] = df["nb_chars_in_bio"].fillna(0)
df["tags"] = df["tags"].fillna("")
df["goals"] = df["goals"].fillna("")
```
**→ Alternative :** Tout faire en une ligne :
```python
df = df.fillna({"nb_chars_in_bio": 0, "tags": "", "goals": ""})
```

---

### 3️⃣ Extraire les fournisseurs de messagerie uniques
**Question :**
*Comment extraire les domaines (ex. : `gmail.com`) d’une colonne d’e-mails ?*

**Réponse :**
Utiliser `str.split()` et `unique()` :
```python
providers_list = df["email"].str.split("@").str[1].unique()
```

---

### 4️⃣ Corriger une erreur de syntaxe avec `drop`
**Question :**
*Erreur `TypeError: 'method' object is not subscriptable` avec `train.drop["is_unwanted"]`.*

**Réponse :**
`drop` est une **méthode**, donc elle doit être appelée avec des **parenthèses** :
```python
X_train = train.drop("is_unwanted", axis=1)  # axis=1 pour supprimer une colonne
y_train = train["is_unwanted"]
```

---

### 5️⃣ Créer la colonne `nb_tags`
**Question :**
*Comment compter le nombre de tags dans une chaîne de caractères (séparés par `;`) ?*

**Réponse :**
Utiliser `str.count()` et ajuster pour les chaînes vides :
```python
df["nb_tags"] = (df["tags"].str.count(';') + 1) - (df["tags"].str.len() == 0)
```
**→ Explication :**
- `str.count(';') + 1` : Compte les `;` et ajoute 1 (car *n* tags = *n-1* `;`).
- `- (df["tags"].str.len() == 0)` : Corrige le cas des chaînes vides (qui donneraient `1` sans cette soustraction).

---

### 6️⃣ Créer la colonne `nb_goals`
**Question :**
*Comment créer une colonne `nb_goals` similaire à `nb_tags` ?*

**Réponse :**
Même logique que pour `nb_tags` :
```python
df["nb_goals"] = (df["goals"].str.count(';') + 1) - (df["goals"].str.len() == 0)
```
**→ Vérification :** `print(df[["goals", "nb_goals"]].head())`

---

### 7️⃣ Corriger une `KeyError` avec `nb_goals`
**Question :**
*Erreur `KeyError: 'nb_goals'` lors de la sélection de colonnes pour `dataset`.*

**Réponse :**
Vérifier l’orthographe (`nb_goals` et non `nb_goal`) :
```python
dataset = df[[
    "has_picture_cover", "has_linkedin", "has_twitter", "has_personal_url",
    "has_instagram", "nb_chars_in_bio", "nb_tags", "nb_goals", "is_unwanted"
]]
```

---

### 8️⃣ Filtrer avec `is_unwanted == 1`
**Question :**
*Erreur `KeyError` avec `df["is_unwanted"==1]`.*

**Réponse :**
La syntaxe correcte pour filtrer est :
```python
df_filtered = df[df["is_unwanted"] == 1]
```
**→ Explication :** `df["is_unwanted"==1]` cherche une colonne nommée `"is_unwanted"==1` (ce qui n’existe pas).

---

### 9️⃣ Undersampling : Équilibrer les classes
**Question :**
*Comment créer un jeu de données équilibré avec 1000 échantillons de la classe majoritaire et tous les échantillons de la classe minoritaire ?*

**Réponse :**
```python
# Échantillonner la classe minoritaire (is_unwanted=1)
dfunwanted = df[df["is_unwanted"] == 1]

# Échantillonner 1000 lignes de la classe majoritaire (is_unwanted=0)
df1000 = df[df["is_unwanted"] == 0].sample(1000, random_state=42)

# Combiner les deux
dataset = pd.concat([dfunwanted, df1000])
```
**→ Vérification :**
```python
print(dataset['is_unwanted'].value_counts())
```

---

### 🔟 Préparer `X_train`, `X_test`, `y_train`, `y_test`
**Question :**
*Erreur `KeyError: 'is_unwanted'` lors de la séparation des features et de la cible.*

**Réponse :**
Si `train` et `test` ne contiennent pas `is_unwanted`, il faut **séparer `X` et `y` avant le split** :
```python
from sklearn.model_selection import train_test_split

X = dataset.drop("is_unwanted", axis=1)  # Features
y = dataset["is_unwanted"]               # Cible

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
```

---

### 1️⃣1️⃣ Calculer des métriques (Accuracy, Precision, Recall)
**Question :**
*Erreur `NameError: name 'accuracy' is not defined` lors de l’affichage des métriques.*

**Réponse :**
Calculer les métriques à partir de `TP`, `FP`, `TN`, `FN` :
```python
TP, FP, TN, FN = 40, 10, 45, 5

accuracy = (TP + TN) / (TP + TN + FP + FN)
precision = TP / (TP + FP)
recall = TP / (TP + FN)

print(f"Accuracy: {accuracy:.2%}")
print(f"Precision: {precision:.2%}")
print(f"Recall: {recall:.2%}")
```

---

### 1️⃣2️⃣ Importer des modules (`LogisticRegression`, `StandardScaler`)
**Question :**
*Erreur `SyntaxError: invalid syntax` avec `pass from sklearn.linear_model import LogisticRegression`.*

**Réponse :**
Supprimer `pass` et écrire les importations directement :
```python
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
```

---

### 1️⃣3️⃣ Appliquer `StandardScaler`
**Question :**
*Erreur `ValueError` avec `StandardScaler` sur `X_train` ou `X_test`.*

**Réponse :**
Vérifier et corriger les problèmes courants :
1. **Valeurs manquantes (`NaN`)** :
   ```python
   X_train = X_train.fillna(X_train.mean())
   X_test = X_test.fillna(X_test.mean())
   ```
2. **Colonnes non numériques** :
   ```python
   X_train = X_train.apply(pd.to_numeric, errors='coerce').fillna(0)
   ```
3. **Valeurs infinies (`inf`)** :
   ```python
   X_train = X_train.replace([np.inf, -np.inf], np.nan).fillna(0)
   ```
4. **Appliquer le scaling** :
   ```python
   scaler = StandardScaler()
   X_train_scaled = scaler.fit_transform(X_train)
   X_test_scaled = scaler.transform(X_test)
   ```

---

---

## 📝 Résumé des bonnes pratiques

| Problème | Solution Clé | Méthode/Outils |
|----------|--------------|----------------|
| Filtrer un DataFrame | Conditions booléennes ou `query()` | `df[condition]`, `df.query()` |
| Remplacer les `NaN` | `fillna()` | `df.fillna(valeur)` |
| Extraire des sous-chaînes | `str.split()` + `unique()` | `df["col"].str.split("@").str[1].unique()` |
| Supprimer une colonne | `drop()` avec `axis=1` | `df.drop("colonne", axis=1)` |
| Compter des occurrences | `str.count()` | `df["col"].str.count(";") + 1` |
| Équilibrer un dataset | `sample()` + `concat()` | `pd.concat([df_minority, df_majority.sample(n)])` |
| Séparer `X` et `y` | `drop()` + accès direct | `X = df.drop("cible", axis=1)`, `y = df["cible"]` |
| Calculer des métriques | Formules manuelles | `accuracy = (TP+TN)/(TP+TN+FP+FN)` |
| Importer des modules | Syntaxe correcte | `from module import Class` |
| Scaler des données | `StandardScaler` | `scaler.fit_transform(X_train)` |

---

---

## 💡 Conseils pour ton *brocode*

1. **Vérifie toujours les colonnes** avec `df.columns` avant de les manipuler.
2. **Utilise `fillna()`** pour les valeurs manquantes, et `pd.to_numeric()` pour les colonnes non numériques.
3. **Sépare `X` et `y` avant le `train_test_split`** pour éviter les erreurs de `KeyError`.
4. **Teste chaque étape** avec `print(df.head())` ou `print(df.shape)` pour valider les transformations.
5. **Documenter tes étapes** dans ton *brocode* avec des commentaires clairs et des exemples de code.

---

*Fiche générée le 19 août 2026 – À intégrer dans ton **brocode** pour référence future.* 🚀