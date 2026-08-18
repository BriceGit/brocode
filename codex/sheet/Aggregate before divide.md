# Aggregate before divide

> **La règle en une ligne :** un ratio agrégé se calcule `SUM(numérateur) / SUM(dénominateur)`, **jamais** `AVERAGE(numérateur / dénominateur)`.

Un ratio n'est **pas une quantité additive**. On peut sommer des revenus, des commandes, des clients. On ne peut jamais sommer ni moyenner des taux, des pourcentages, des paniers moyens ou des prix unitaires sans repasser par les totaux qui les composent.

---

## 🔥 Pourquoi c'est faux

Faire la moyenne des ratios donne à **chaque ligne le même poids**, quelle que soit sa taille. C'est une moyenne **non pondérée** — et ce n'est presque jamais ce qu'on veut.

| Boutique | Revenu | Commandes | Panier moyen |
|---|---|---|---|
| A | 10 000 € | 100 | 100 € |
| B | 500 € | 1 | 500 € |

```
❌ AVERAGE des paniers   = (100 + 500) / 2      = 300 €
✅ SUM / SUM             = 10 500 / 101          = 103,96 €
```

**Écart : ×2,9.** Une boutique qui a fait une seule vente pèse autant qu'une boutique qui en a fait cent. Le chiffre remonté au métier est faux d'un facteur 3, et rien ne le signale.

Plus la distribution des dénominateurs est déséquilibrée, plus l'écart explose. Sur des données réelles (clients, campagnes, agences), la distribution est **toujours** déséquilibrée.

> [!danger] Le cas extrême : le paradoxe de Simpson
> Quand les dénominateurs sont très inégaux, le ratio agrégé peut **s'inverser** par rapport aux ratios individuels : chaque sous-groupe montre A > B, et le total montre B > A. Ce n'est pas une erreur de calcul, c'est un effet de pondération. C'est pour ça qu'on ne conclut jamais sur un ratio sans regarder le dénominateur qui le porte.

---

## 🛠️ Comment ça se traduit dans chaque outil

### Google Sheets — champ calculé d'un TCD

Le champ calculé d'un tableau croisé dynamique applique la formule **ligne par ligne puis moyenne**, selon le mode d'agrégation choisi. C'est le piège d'origine.

```
✅ Colonne à part, en dehors du pivot : = SUM(revenu) / SUM(commandes)
```

Le conseil du formateur en [[02-google-sheets]] — *calculer le ratio en dehors du pivot* — n'est pas une préférence esthétique : c'est la parade à ce problème.

### SQL / BigQuery

```sql
-- ❌
SELECT region, AVG(revenu / commandes) AS panier_moyen
FROM ventes GROUP BY region;

-- ✅
SELECT region, SAFE_DIVIDE(SUM(revenu), SUM(commandes)) AS panier_moyen
FROM ventes GROUP BY region;
```

`SAFE_DIVIDE` plutôt que `/` dès que le dénominateur peut valoir 0 ou `NULL`.

### pandas

```python
# ❌
df["ratio"] = df["revenu"] / df["commandes"]
df.groupby("region")["ratio"].mean()

# ✅
g = df.groupby("region")[["revenu", "commandes"]].sum()
g["panier_moyen"] = g["revenu"] / g["commandes"]
```

### dbt

Ne **jamais** matérialiser un ratio en couche `staging` ou `intermediate` s'il doit être ré-agrégé plus loin. On transporte les **composants** (`revenu`, `commandes`) jusqu'au mart, et on ne divise qu'au dernier moment — idéalement dans la couche de restitution.

```sql
-- int_ventes_par_region.sql  →  on garde les briques
SELECT region, SUM(revenu) AS revenu, SUM(commandes) AS commandes
FROM {{ ref('stg_ventes') }}
GROUP BY region
```

### Power BI — DAX

C'est **la** raison pour laquelle on écrit des **mesures** et pas des colonnes calculées.

```dax
❌  Colonne calculée : Panier = Ventes[revenu] / Ventes[commandes]
    puis AVERAGE(Ventes[Panier])   → moyenne de ratios, faux

✅  Mesure : Panier moyen = DIVIDE( SUM(Ventes[revenu]), SUM(Ventes[commandes]) )
```

Une mesure est réévaluée dans **chaque contexte de filtre** : elle recalcule `SUM/SUM` au niveau où elle est affichée. Une colonne calculée est figée à la granularité de la ligne, et tout ce qu'on peut en faire ensuite, c'est la moyenner — c'est-à-dire se tromper.

`DIVIDE()` plutôt que `/` : gère le dénominateur nul sans erreur.

### Looker Studio

Même logique : un champ calculé au niveau ligne puis agrégé en `AVG` est faux. Il faut construire le champ avec les agrégats à l'intérieur : `SUM(revenu) / SUM(commandes)`.

---

## ✅ L'exception légitime

Il existe un cas où la moyenne des ratios est **la bonne réponse** : quand on veut délibérément donner le **même poids à chaque entité**.

> *« Quel est le taux de conversion de la boutique médiane ? »*
> *« Sur nos 40 agences, combien performent au-dessus de 3% ? »*

Ce sont des questions sur la **distribution**, pas sur le total.

> [!important] Si c'est le cas, il faut le nommer
> `taux_moyen_par_boutique` ≠ `taux_global`. Deux colonnes distinctes, deux noms distincts. Une métrique dont on ne peut pas dire si elle est pondérée ou non est une métrique inutilisable.

---

## 🧪 Le test de contrôle

Après tout calcul de ratio agrégé, recalculer la valeur globale **depuis les totaux bruts** et comparer.

```sql
-- La ligne "Total" du rapport doit être égale à ceci, jamais à la moyenne des lignes
SELECT SAFE_DIVIDE(SUM(revenu), SUM(commandes)) FROM ventes;
```

**Le symptôme qui doit alerter** : la ligne « Total » d'un tableau n'est pas égale à la moyenne des lignes au-dessus. C'est normal et c'est même le signe que le calcul est **juste**. Si elles sont égales, il y a de fortes chances que le ratio soit calculé au mauvais endroit.

---

## 🔗 Principes voisins

- **Ne jamais arrondir une colonne intermédiaire** utilisée comme multiplicateur ou comme dénominateur. `ROUND()` uniquement à la sortie finale. Même famille de problème : une erreur d'arrondi injectée en amont se propage et s'amplifie à l'agrégation.
- **Test de conservation** : vérifier `SUM` avant / après toute distribution ou transformation.
- Un ratio calculé sur la mauvaise **granularité** est faux même avec `SUM/SUM` → [[Granularité d'une table]]
- Un ratio calculé après un join qui duplique des lignes est faux même avec la bonne granularité → [[Clé de jointure et cardinalité]]

---

## 🔗 Liens

- Première apparition dans le cursus : [[02-google-sheets]] — champs calculés du tableau croisé dynamique
- [[Granularité d'une table]]
- [[Clé de jointure et cardinalité]]
- [[NULL et agrégation (AVG, COUNT)]] — l'autre piège des agrégats : `AVG` ignore les `NULL`, `SUM/COUNT(*)` non
