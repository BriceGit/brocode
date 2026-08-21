# 🐛 Régression linéaire — erreurs vécues & solutions

> Fiche de debugging issue de la session **Python For AI — Regression** (18/08/2026).
> Challenges : `data-analytics-instagram-likes-prediction` + House Prices.
> Chaque entrée = une erreur réellement rencontrée, sa cause racine, son fix, et le principe à retenir.

---

## 🗺️ Index des erreurs

| # | Symptôme | Cause racine | Section |
|---|---|---|---|
| 1 | `test_sorted_by_timestamp` FAILED | `sort_values` non réassigné | [[#1️⃣ sort_values ne modifie rien]] |
| 2 | `ValueError: n_samples=1` | X mal construit (reshape) | [[#2️⃣ n_samples=1 sur train_test_split]] |
| 3 | `IndexError: only integers, slices…` | `df.columns['a','b']` | [[#3️⃣ df.columns indexé par des noms]] |
| 4 | Ne sait pas exclure 1 colonne sur 75 | confusion `drop` / `select_dtypes` | [[#4️⃣ Séparer X et y]] |
| 5 | R² négatif / prédictions aberrantes | mismatch `scaled` / brut | [[#5️⃣ predict sur des données non transformées]] |
| 6 | `inconsistent numbers of samples` | `y_train` avec `y_pred_test` | [[#6️⃣ y_true et y_pred dépariés]] |
| 7 | `print(r2)` → valeur périmée | state Jupyter | [[#7️⃣ Variables fantômes dans Jupyter]] |
| 8 | "aucune amélioration" du model_2 | cellule d'éval copiée-collée | [[#8️⃣ Évaluer le mauvais modèle]] |
| 9 | Impossible de comparer m1 vs m2 | variables écrasées | [[#9️⃣ Écrasement et perte de comparaison]] |
| 10 | Retirer les posts récents de l'archive | index préservé par `drop_duplicates` | [[#🔟 Complément d'un sous-ensemble]] |
| 11 | Supprimer colonnes >30% NaN | `isna().mean()` inconnu | [[#1️⃣1️⃣ Filtrer les colonnes par taux de NaN]] |
| 12 | Ne sait pas fit le `SimpleImputer` | `fit_transform` vs `fit`+`transform` | [[#1️⃣2️⃣ Protocole fit / transform]] |
| 13 | `UserWarning: unknown categories` | modalités test absentes du train | [[#1️⃣3️⃣ OneHotEncoder et catégories inconnues]] |
| 14 | NaN silencieux en arithmétique | alignement par étiquette | [[#1️⃣4️⃣ reset_index après le split]] |
| 15 | "Is this model good?" | pas de baseline | [[#1️⃣5️⃣ Interpréter une métrique]] |
| 16 | Feature qui contient la réponse | agrégat incluant la cible | [[#1️⃣6️⃣ Data leakage]] |

---

# 🐼 PARTIE A — Pandas

## 1️⃣ sort_values ne modifie rien

**Symptôme** — pytest rouge sur le seul test sensible à l'ordre, les deux autres verts.

```python
df_posts.sort_values(by=["ts"], ascending=True)   # ❌ résultat jeté
```

**Cause** — la quasi-totalité des méthodes pandas **retournent une copie**. Jupyter affiche cette copie, ce qui donne l'illusion que l'objet a changé.

```python
df_posts = df_posts.sort_values(by="ts").reset_index(drop=True)   # ✅
```

**Méthodes concernées** : `sort_values`, `drop`, `rename`, `fillna`, `dropna`, `drop_duplicates`, `reset_index`, `astype`, `replace`, `merge`…

> ⚠️ Ne pas contourner avec `inplace=True` — déprécié en pandas 3.0 et casse le chaînage.

**Diagnostic ciblé** : quand *seul* le test d'ordre casse → chercher un tri non réassigné.
**Vérif** : `df["ts"].is_monotonic_increasing`

🧠 **Principe** — *L'affichage ment, la variable ne ment pas.*

---

## 3️⃣ df.columns indexé par des noms

```python
cols_to_drop = df.columns['PoolQC', 'MiscFeature', 'Alley']   # ❌ IndexError
```

**Cause double** :
1. `df.columns` est un objet `Index` → s'indexe par **position**, **slice** ou **masque booléen**, jamais par ses propres valeurs.
2. `[a, b, c]` sans crochets englobants crée un **tuple** → pandas le reçoit comme clé unique → `IndexError` au lieu du `KeyError` attendu.

```python
cols_to_drop = ['PoolQC', 'MiscFeature', 'Alley']      # ✅ liste simple
df = df.drop(columns=cols_to_drop, errors="ignore")
```

`errors="ignore"` rend la cellule ré-exécutable sans planter au 2ᵉ run.

**La syntaxe était à un pas du bon pattern** — il fallait une *condition* dans les crochets, pas des noms :

```python
cols_to_drop = df.columns[df.isna().mean() > 0.3]      # ✅ masque booléen
```

---

## 4️⃣ Séparer X et y

```python
X = df.drop(columns="SalePrice")   # copie sans la colonne, df intact
y = df["SalePrice"]
```

Confusion fréquente avec `select_dtypes(exclude=...)` qui filtre par **type**, pas par nom.

| Besoin | Méthode |
|---|---|
| Exclure par **nom** | `df.drop(columns=...)` |
| Exclure par **type** | `df.select_dtypes(exclude="object")` |
| Garder par nom | `df[["a", "b"]]` |
| Filtrer par condition | `df.loc[:, masque]` |

> ⚠️ Retirer aussi les identifiants (`Id`, `customer_id`). Un ID n'est pas une feature : le modèle y trouve de la corrélation par hasard sur le train, zéro pouvoir prédictif réel.

---

## 🔟 Complément d'un sous-ensemble

**Besoin** — retirer les posts les plus récents de l'archive pour calculer un historique.

```python
most_recent = archive.drop_duplicates(subset=["id"], keep="last")
previous    = archive.drop(most_recent.index)          # ✅
```

**Clé** — `drop_duplicates` **préserve l'index d'origine** → le sous-ensemble sert directement de liste de lignes à retirer. Vrai pour tout sous-ensemble obtenu par filtrage.

```python
assert len(previous) + len(most_recent) == len(archive)   # test de conservation
print(archive.index.is_unique)                            # doit être True
```

Si l'index n'est pas unique (concat sans `reset_index`), `.drop()` supprime **toutes** les lignes portant l'étiquette → version robuste :

```python
previous = archive[~archive.index.isin(most_recent.index)]
```

---

## 1️⃣1️⃣ Filtrer les colonnes par taux de NaN

```python
df.isna().mean()                    # taux de NaN par colonne
df = df.loc[:, df.isna().mean() <= 0.3]     # ✅ une ligne, sans lister les noms
```

**Pourquoi ça marche** — `.isna()` produit des booléens, et la **moyenne d'un booléen est sa proportion de `True`**. Généralisable : `(df["x"] > 100).mean()` = % de lignes au-dessus de 100.

**Variante `thresh`** :
```python
df = df.dropna(axis=1, thresh=int(0.7 * len(df)))   # thresh = compte absolu, pas ratio
```

⚠️ **`>` vs `>=`** : "more than 30%" = strictement. Une colonne à exactement 30% se garde. Les datasets de challenge en placent souvent une pile au seuil.

**Le seuil de 30% est une convention, pas une loi** :

| Situation | Décision |
|---|---|
| 40% NaN mais très prédictive | garder + flag `is_missing` |
| 5% NaN mais **non aléatoires** (MNAR) | l'absence est un signal |
| 35% NaN sur variable redondante | supprimer |

```python
df["revenu_missing"] = df["revenu"].isna().astype(int)   # garder la trace avant d'imputer
```

> 💼 Cas banking : un champ "revenu déclaré" vide corrèle souvent avec un profil de risque. Imputer par la médiane efface ce signal.

---

## 1️⃣4️⃣ reset_index après le split

```python
y_train = y_train.reset_index(drop=True)
y_test  = y_test.reset_index(drop=True)
```

**`drop=True` obligatoire** — sur une **Series**, `reset_index()` seul transforme l'ancien index en colonne → renvoie un **DataFrame (n, 2)**. L'objet cesse d'être une Series.

**Pourquoi c'est nécessaire** — `train_test_split` mélange les lignes : `y_test` sort avec un index `[1043, 27, 891…]`. `predict()` renvoie un numpy array indexé `0, 1, 2…`.

```python
residus = y_test - pd.Series(y_pred)   # 🔴 NaN partout, aucune erreur levée
```

**Pandas aligne par étiquette, numpy par position.** Aucune correspondance → NaN silencieux.

⚠️ Si tu ne reset que `y`, X et y sont désalignés. Sans effet pour sklearn (positionnel), mais `pd.concat([X_test, y_test], axis=1)` produira un DataFrame double rempli de NaN. Reset les quatre si tu prévois de recombiner.

---

# ⚙️ PARTIE B — Preprocessing

## 1️⃣2️⃣ Protocole fit / transform

```python
X_train_num_imputed = num_imputer.fit_transform(X_train_num)   # apprend + applique
X_test_num_imputed  = num_imputer.transform(X_test_num)        # applique seulement
```

| Méthode | Effet |
|---|---|
| `.fit(X)` | apprend les paramètres (moyennes, écarts-types, catégories) |
| `.transform(X)` | applique les paramètres appris |
| `.fit_transform(X)` | les deux d'affilée |

**Règle universelle** : `fit_transform` sur le train, `transform` seul sur le test. Vrai pour `SimpleImputer`, `StandardScaler`, `OneHotEncoder`, `PCA` — **sans exception**.

`fit_transform` sur le test = **leakage** : on utilise une statistique du test qu'on n'est pas censé posséder.

**Attributs appris** — se terminent par `_` et n'existent qu'après le fit :
```python
num_imputer.statistics_    # moyennes apprises
scaler.mean_, scaler.scale_
ohe.categories_
```
Un `AttributeError` sur un attribut en `_` = fit oublié.

**`.set_output(transform='pandas')`** conserve les noms de colonnes en sortie — sinon numpy array anonyme et perte de traçabilité des features.

---

## 1️⃣3️⃣ OneHotEncoder et catégories inconnues

```
UserWarning: Found unknown categories in columns [13, 14, 15, 17, 27] during transform.
These unknown categories will be encoded as all zeros
```

**Ce warning est le comportement demandé.** `handle_unknown='ignore'` transforme une erreur bloquante en avertissement : les modalités absentes du train sont encodées en zéros sur toute la variable.

Les indices sont **positionnels dans l'objet passé au transformer** :
```python
X_test_cat.columns[[13, 14, 15, 17, 27]]
```

⚠️ **Piège du nommage `_imputed`** — `OneHotEncoder` **n'impute rien**. Il traite `NaN` comme une **catégorie à part entière** et lui crée sa colonne (`MasVnrType_nan`).

```python
X_train_cat.isna().sum().sum()                                   # NaN AVANT encodage
[c for c in X_train_cat_imputed.columns if 'nan' in str(c).lower()]
```

Un `assert X_cat_imputed.isnull().sum().sum() == 0` **est toujours vrai** après encodage (tout est 0/1) → il ne prouve rien. Vérifier les NaN **avant**.

Traiter l'absence comme catégorie est souvent correct ici (`GarageType` vide = "pas de garage", pas "donnée manquante") — mais c'est une **décision à assumer**, pas un effet secondaire.

**Cohérence des schémas** :
```python
assert list(X_train_cat_imputed.columns) == list(X_test_cat_imputed.columns)
```
Garantie par le `fit` unique sur le train. Avec `fit_transform` des deux côtés, les shapes divergent et `predict()` plante plus tard.

---

# 🤖 PARTIE C — Modélisation

## 2️⃣ n_samples=1 sur train_test_split

```
ValueError: With n_samples=1, test_size=0.2 and train_size=None,
the resulting train set will be empty.
```

**Ne jamais toucher à `test_size`.** Le message dit que sklearn ne voit **qu'une ligne** dans X. Le problème est en amont, dans la construction de X.

```python
print(X.shape, y.shape)   # attendu (n, k), pas (1, n)
```

| Cause | Code fautif | Fix |
|---|---|---|
| reshape inversé | `.reshape(1, -1)` → `(1, N)` | `.reshape(-1, 1)` |
| sélection d'une ligne | `df.iloc[0]`, `df.head(1)` | `df[["a","b","c"]]` |
| agrégation involontaire | `df[features].mean()` | retirer l'agrégat |

**Mnémotechnique** :
- `reshape(-1, 1)` → **1 feature**, N lignes ✅
- `reshape(1, -1)` → **1 échantillon**, N features ❌

> Le message d'erreur sklearn `"Expected 2D array"` propose **les deux** reshape — d'où la copie de la mauvaise.

🧠 **Convention sklearn** : `(n_samples, n_features)`. Lignes = observations, colonnes = variables.

```python
assert X.shape[0] == y.shape[0], f"{X.shape} vs {y.shape}"
```

---

## 5️⃣ predict sur des données non transformées

```python
model.fit(X_train_scaled, y_train)
y_pred = model.predict(X_train)          # 🔴 mismatch silencieux
```

**Aucune erreur levée.** Le shape est identique, sklearn ne peut pas savoir. Il applique des coefficients calibrés pour des valeurs centrées-réduites (≈ -3 à +3) à des `followers` valant 1703.

**Signal de détection** : **R² négatif sur le train**.
> Un R² négatif signifie "pire que prédire la moyenne". Sur des données d'**entraînement**, c'est mécaniquement impossible pour une régression linéaire correctement appliquée → il y a un mismatch.

**Fix structurel — `Pipeline`** :
```python
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression

pipe = make_pipeline(StandardScaler(), LinearRegression())
pipe.fit(X_train, y_train)       # scale + fit
y_pred = pipe.predict(X_train)   # scale automatiquement avant de prédire
```

Le Pipeline **encapsule le scaler** → impossible d'oublier la transformation, et pas de leakage sur le test. Standard en production, valorisé en entretien.

**Ce qui est détecté vs ce qui ne l'est pas** :

| Mismatch | Détecté par sklearn ? |
|---|---|
| Nombre de features différent | ✅ `X has 4 features, but expecting 3` |
| Données scaled vs brutes | ❌ **silencieux** |

---

## 8️⃣ Évaluer le mauvais modèle

Question q) demande "this **new** model", le code appelle `model_1`.

**Le copier-coller de la cellule d'évaluation entre model_1 et model_2 est le bug n°1 de tout notebook.** Les shapes correspondent souvent → aucune erreur → on conclut à tort "pas d'amélioration".

```python
y_pred_test_2 = model_2.predict(X_test_scaled_2)
r2_test_2  = r2_score(y_test_2, y_pred_test_2)
```

**Suffixer modèle ET données** rend le mismatch visible à la relecture.

---

## 9️⃣ Écrasement et perte de comparaison

Écraser `X_test_scaled` pour le modèle 2 est **valide**. Écraser `r2_test` et `mse` ne l'est pas : les métriques du modèle 1 sont perdues, et la question demande de comparer.

```python
comparaison = pd.DataFrame({
    "model_1": [r2_m1, mse_m1, mae_m1],
    "model_2": [r2_m2, mse_m2, mae_m2],
}, index=["R²", "MSE", "MAE"])
```

🧠 **Principe** — *Écraser est légitime quand on remplace un état, piégeux quand on veut comparer deux états.*

Récupération possible : les sorties des cellules précédentes restent affichées dans le notebook même après écrasement de la variable.

---

## 7️⃣ Variables fantômes dans Jupyter

```python
r2_test = model_1.score(X_test_scaled, y_test)
...
print(r2)     # 🔴 n'existe pas dans cette cellule
```

Deux issues possibles, la seconde bien pire :
1. `NameError` — visible, corrigé immédiatement
2. **Affichage silencieux d'une valeur d'une cellule antérieure** — on lit un score de train en croyant lire un score de test

🧠 **Principe** — *Dans Jupyter, une variable non redéfinie n'est pas vide : elle garde son ancienne valeur.* Toujours vérifier que le nom imprimé est bien celui qu'on vient de calculer.

---

# 📊 PARTIE D — Métriques

## 6️⃣ y_true et y_pred dépariés

```python
y_pred = model.predict(X_test_scaled)
mse = mean_squared_error(y_train, y_pred)   # 🔴 inconsistent numbers of samples
```

**`y_train` n'est pas une référence d'entraînement ni un baseline.** C'est simplement les vraies valeurs d'**autres lignes**.

$$\text{MSE} = \frac{1}{n}\sum_{i=1}^{n}(a_i - b_i)^2$$

La métrique compare **ligne par ligne, dans l'ordre** → `a` et `b` doivent décrire **les mêmes observations**.

| Objet | Lignes concernées |
|---|---|
| `X_test_scaled` | posts 42, 87, 103… (20%) |
| `y_pred` | prédictions pour **42, 87, 103…** |
| `y_test` | vrais likes de **42, 87, 103…** ✅ |
| `y_train` | vrais likes de **1, 2, 3…** ❌ |

🧠 **Règle mécanique** — *Le X qui entre dans `predict()` détermine le y qui entre dans la métrique.*

```python
y_pred_test = model.predict(X_test_scaled)
mse_test    = mean_squared_error(y_test, y_pred_test)   # même suffixe des deux côtés
```

**Convention de nommage anti-bug** :

| Objet | Nom |
|---|---|
| Prédictions | `y_pred_train` / `y_pred_test` |
| Métriques | `r2_train` / `r2_test`, `mse_train` / `mse_test` |

---

## 📐 Les trois métriques

```python
from sklearn.metrics import r2_score, mean_squared_error, mean_absolute_error
```

⚠️ **Ordre : `(y_true, y_pred)`, jamais l'inverse.** MSE et MAE sont symétriques → l'inversion ne se voit pas. **R² est asymétrique** → valeur fausse silencieusement.

| Métrique | Unité | Lecture | Outliers |
|---|---|---|---|
| **R²** | sans unité | % de variance expliquée | moyennement sensible |
| **MSE** | cible**²** | pénalise fort les grosses erreurs | 🔴 très sensible |
| **MAE** | cible | erreur moyenne lisible | 🟢 peu sensible |
| **RMSE** | cible | MSE ramenée à l'unité | 🔴 sensible |

```python
rmse = np.sqrt(mse)
# ou : from sklearn.metrics import root_mean_squared_error
# ⚠️ mean_squared_error(squared=False) est déprécié depuis sklearn 1.4
```

**Diagnostic** : `RMSE >> MAE` → présence d'outliers qui explosent l'erreur (posts viraux, maisons de luxe).

**`.score()`** — R² sur un régresseur, **accuracy** sur un classifieur. Même méthode, métrique différente selon l'estimateur. Question d'entretien classique.

---

## 1️⃣5️⃣ Interpréter une métrique

**Aucune métrique d'erreur ne s'interprète sans baseline.**

```python
y_pred_mean = np.full(len(y_test), y_train.mean())     # modèle trivial
mae_baseline = mean_absolute_error(y_test, y_pred_mean)

print(f"MAE modèle   : {mae_lin:,.0f} $")
print(f"MAE baseline : {mae_baseline:,.0f} $")
print(f"Réduction    : {(1 - mae_lin/mae_baseline)*100:.1f} %")
print(f"% du prix moyen : {mae_lin / y_test.mean() * 100:.1f} %")
```

⚠️ La baseline se calcule sur **`y_train.mean()`** — même règle que tout élément appris.

### 🔗 Le R² *est* cette comparaison, formalisée

$$R^2 = 1 - \frac{\text{erreur du modèle}}{\text{erreur de la baseline moyenne}}$$

D'où : **R² = 0 → équivalent à prédire la moyenne. R² < 0 → pire que la moyenne.**

### Grille de lecture

| R² test | Verdict (comportement social / immobilier) |
|---|---|
| < 0 | 🔴 bug ou features inutiles |
| 0 – 0.1 | 🔴 les features n'expliquent rien |
| 0.1 – 0.3 | 🟡 signal faible mais réel |
| 0.3 – 0.6 | 🟢 correct |
| > 0.8 | 🤨 suspect → chercher une **fuite** |

> Le seuil est **relatif au domaine**. En physique R² = 0.7 est mauvais ; sur des likes Instagram, 0.4 est honorable. Jamais de jugement dans l'absolu.

### Lecture train vs test

| Situation | Diagnostic |
|---|---|
| R² train ≈ R² test, tous deux élevés | ✅ généralise bien |
| R² train >> R² test | 🔴 **overfitting** |
| R² train ≈ R² test, tous deux faibles | 🟡 **underfitting** |

⚠️ *Train ≈ Test ne veut pas dire "bon modèle"* — seulement "pas d'overfitting".

### Comparateur alternatif : RMSE vs σ(y)

$$R^2 \approx 1 - \frac{\text{RMSE}^2}{\sigma_y^2}$$

- RMSE ≈ σ(y) → le modèle n'apporte rien
- RMSE << σ(y) → le modèle capture du signal

Même information que le R², **en unités lisibles**. Un décideur comprend *"on se trompe de 24 000 $ sur un prix moyen de 180 000 $"*, pas *"MSE = 1.2e9"*.

### 🎯 Sur "Do you think our model is a good one?"

La réponse attendue est **non, et voici pourquoi**. Le challenge est construit pour produire un modèle faible.

Structure de réponse :
1. **Chiffres en unités interprétables** — R², RMSE en $ ou likes
2. **Comparaison train/test** → overfitting ou underfitting
3. **Diagnostic structurel** — une régression **linéaire** sur des likes suivant une **loi de puissance** (minorité de posts viraux concentrant l'essentiel) est condamnée d'avance
4. **Pistes** — `np.log1p(y)` pour linéariser, feature engineering (ratio likes/followers, heure du post), modèle non linéaire

> Vérifier la **distribution de `y`** (histogramme) *avant* de choisir le modèle, pas après.

💼 **En entretien** : on montre un modèle et on regarde si le candidat sait dire qu'il est mauvais, avec des arguments. Répondre "oui c'est bon" est l'erreur.

---

# 🚨 PARTIE E — Data leakage

## 1️⃣6️⃣ Data leakage

**Le bug le plus dangereux : rien ne casse, le score devient juste trop beau.**

### Cas rencontré — feature `median_likes`

L'énoncé insiste : *"calculate the median likes per author from **all previous posts**"*.

Si la médiane était calculée sur *tous* les posts, elle contiendrait les likes du post à prédire → le modèle disposerait d'un morceau de la réponse dans ses features → R² excellent en entraînement, effondrement en production.

```python
most_recent = archive.drop_duplicates(subset=["id"], keep="last")
previous    = archive.drop(most_recent.index)

median_likes = previous.groupby("id")["likes"].median().rename("median_likes")
most_recent  = most_recent.merge(median_likes, on="id", how="left")
```

`how="left"` obligatoire : garder tous les posts récents, y compris les auteurs sans historique.

**Les auteurs à un seul post produisent des `NaN`** — structurel, pas un bug. Leur unique post *est* leur post le plus récent.

| Option | Effet |
|---|---|
| `dropna()` | perte de lignes, feature propre |
| `fillna(median_globale)` | fallback neutre |
| garder NaN + colonne `has_history` | le modèle apprend la différence |

### Les 3 formes de leakage vues aujourd'hui

| Forme | Mécanisme | Prévention |
|---|---|---|
| **Temporel** | agrégat incluant la ligne cible | strictement antérieur |
| **Preprocessing** | `fit` sur le test | `fit_transform` train / `transform` test |
| **Baseline** | `y_test.mean()` comme référence | `y_train.mean()` |

🧠 **Principe unificateur** — *Tout ce qui est "appris" (moyenne, écart-type, catégories, médiane par entité) doit l'être exclusivement sur le train, ou sur des données strictement antérieures à la cible.*

---

# ✅ Checklist anti-bug

### Avant le split
- [ ] `df.isna().mean()` inspecté, décision sur les colonnes >30%
- [ ] Flag `is_missing` créé si l'absence porte du sens
- [ ] Identifiants (`Id`) retirés de X
- [ ] `X.shape` en `(n_samples, n_features)` — pas `(1, n)`
- [ ] `assert X.shape[0] == y.shape[0]`

### Après le split
- [ ] `reset_index(drop=True)` sur y (et sur X si recombinaison prévue)
- [ ] `type(y_train)` toujours une Series

### Preprocessing
- [ ] `fit_transform` train / `transform` test — sur **chaque** transformer
- [ ] `.set_output(transform='pandas')` pour garder les noms de colonnes
- [ ] NaN comptés **avant** l'encodage, pas après
- [ ] Schémas de colonnes identiques train/test après OHE

### Entraînement & prédiction
- [ ] `predict()` reçoit la **même représentation** que `fit()` (scaled si scaled)
- [ ] Numéro de modèle cohérent partout dans la cellule (`model_2`, `X_test_2`…)

### Évaluation
- [ ] `(y_true, y_pred)` dans cet ordre
- [ ] Même suffixe `_test` des deux côtés de la métrique
- [ ] Les noms imprimés sont ceux qui viennent d'être calculés
- [ ] Baseline calculée (`y_train.mean()`)
- [ ] MSE traduite en RMSE, puis en % de la cible
- [ ] R² train **et** test affichés pour le diagnostic overfitting

---

# 💼 Angles entretien

| Question probable | Réponse ancrée sur du vécu |
|---|---|
| *"Pourquoi `transform` et pas `fit_transform` sur le test ?"* | leakage — le scaler doit ignorer le test, comme en production |
| *"Qu'est-ce qu'un R² négatif ?"* | pire que la moyenne — sur le train, c'est le signe d'un mismatch de preprocessing |
| *"Ce modèle est-il bon ?"* | pas de réponse sans baseline ni contexte métier |
| *"Différence MAE / RMSE ?"* | RMSE pénalise les grosses erreurs — le choix dépend du coût métier d'une grosse erreur |
| *"Comment détecter un leakage ?"* | score anormalement bon, features agrégées, timing de calcul des features |
| *"Que fait `.score()` ?"* | R² sur régresseur, accuracy sur classifieur |
| *"Pourquoi un Pipeline ?"* | garantie structurelle contre le mismatch et le leakage, pas un confort |

---

# 🔗 Notes liées

- [[pandas - Series vs DataFrame]]
- [[pandas - copie vs vue et SettingWithCopyWarning]]
- [[Data leakage - typologie et détection]]
- [[Métriques de régression - R2 MSE MAE RMSE]]
- [[sklearn - protocole fit transform predict]]
- [[Baseline - pourquoi aucune métrique ne s'interprète seule]]
