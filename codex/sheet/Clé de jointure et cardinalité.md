# Clé de jointure et cardinalité

> **La clé de jointure** est la colonne commune qui permet de relier deux tables. **La cardinalité** décrit combien de lignes de chaque côté correspondent à une même valeur de clé. C'est la cardinalité — pas la clé — qui détermine si le résultat sera juste ou faux.

---

## 🎯 Les quatre cardinalités

| Type | Ce que ça veut dire | Risque |
|---|---|---|
| **1:1** | Une ligne à gauche ↔ une ligne à droite | Aucun |
| **N:1** | Plusieurs lignes à gauche → une seule à droite | Aucun — c'est le cas sain (fait → dimension) |
| **1:N** | Une ligne à gauche → plusieurs à droite | ⚠️ **Fan-out** : les lignes de gauche sont dupliquées |
| **N:N** | Plusieurs des deux côtés | 💥 Produit cartésien partiel — presque toujours une erreur de modélisation |

**La seule question à se poser avant tout join :** *la clé est-elle unique dans la table de droite ?*

- **Oui** → le join est sûr, le nombre de lignes ne change pas
- **Non** → chaque ligne de gauche sera dupliquée autant de fois qu'il y a de correspondances

---

## 💥 Le fan-out : l'erreur la plus coûteuse

```
commandes            lignes_commande
order_id | total     order_id | produit  | montant
   42    | 100 €        42    | A        |  50 €
                        42    | B        |  30 €
                        42    | C        |  20 €
```

```sql
SELECT SUM(c.total)
FROM commandes c
JOIN lignes_commande l ON l.order_id = c.order_id;
-- → 300 €   au lieu de 100 €
```

Le total de la commande a été **répliqué sur chaque ligne** puis sommé trois fois. Le chiffre d'affaires est multiplié par le nombre moyen de lignes par commande. Aucune erreur n'est levée. Le rapport part au métier.

**Les deux parades :**

```sql
-- 1. Agréger AVANT de joindre (à privilégier)
SELECT c.order_id, c.total, l.nb_lignes
FROM commandes c
LEFT JOIN (
  SELECT order_id, COUNT(*) AS nb_lignes
  FROM lignes_commande GROUP BY order_id
) l USING (order_id);

-- 2. Dédupliquer à la lecture
SELECT SUM(DISTINCT ...)   -- fragile, à éviter : casse si deux commandes ont le même total
```

> [!danger] `SUM(DISTINCT)` n'est pas une solution
> Deux commandes légitimes à 100 € seront comptées une seule fois. La bonne réponse est presque toujours d'agréger d'abord, ou de ne pas faire le join à cette granularité du tout → [[Granularité d'une table]]

---

## 🪞 Tableur vs SQL : deux modes d'échec opposés

C'est le point le plus contre-intuitif, et il vient directement du cours Google Sheets.

| | Clé dupliquée à droite → comportement |
|---|---|
| **`VLOOKUP` / `XLOOKUP` / `INDEX+MATCH`** | Renvoie **la première occurrence** et s'arrête. Silencieusement. → **sous-estimation** |
| **`JOIN` en SQL** | Renvoie **toutes** les occurrences, duplique la ligne de gauche. → **surestimation** |

Les deux sont faux, dans des directions **inverses**. Et aucun des deux ne prévient.

Conséquence pratique : un chiffre validé dans Excel puis reproduit en SQL peut légitimement diverger — sans qu'aucun des deux ne soit « le bon ». Il faut remonter à la cardinalité pour trancher.

---

## 🧪 Vérifier l'unicité — avant, pas après

**SQL / BigQuery**
```sql
SELECT customer_id, COUNT(*) AS n
FROM dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
-- Doit renvoyer 0 ligne
```

**Le contrôle en une ligne**
```sql
SELECT COUNT(*) AS lignes, COUNT(DISTINCT customer_id) AS cles
FROM dim_customers;
-- Les deux nombres doivent être égaux
```

**dbt** — la version déclarative, à mettre dans `schema.yml` et à ne plus jamais y penser :
```yaml
columns:
  - name: customer_id
    tests: [unique, not_null]
  - name: order_customer_id
    tests:
      - relationships:
          to: ref('dim_customers')
          field: customer_id
```

**pandas** — `validate` fait le travail et lève une exception au lieu de produire un chiffre faux :
```python
df["key"].duplicated().sum()          # doit valoir 0

pd.merge(orders, customers, on="customer_id",
         how="left", validate="many_to_one")   # ⚠️ lève une erreur si la cardinalité ne tient pas
```

**Google Sheets**
```
=COUNTA(A2:A)          vs   =COUNTA(UNIQUE(A2:A))
```
Les deux doivent être égaux. Sinon, le `VLOOKUP` ment déjà.

---

## ✅ Le test de conservation

Réflexe systématique après tout join :

```sql
-- Avant
SELECT COUNT(*) FROM commandes;        -- 12 480

-- Après
SELECT COUNT(*) FROM resultat_du_join; -- doit valoir 12 480
```

Un `LEFT JOIN` sur une clé unique à droite **conserve exactement** le nombre de lignes de gauche. Tout écart = fan-out. Toute perte = jointure interne déguisée ou clés orphelines.

Sur les montants, même logique : `SUM(revenu)` avant et après doivent être identiques.

---

## ⚠️ Les pièges de la clé elle-même

| Piège | Symptôme | Fix |
|---|---|---|
| **Homonymie sémantique** | `id` d'un côté, `id` de l'autre, contenus différents (`order_id` vs `customer_id`) | Vérifier ce que la colonne représente, pas son nom. Signalé dès le cours Sheets. |
| **Type incompatible** | `"123"` (texte) ne joint pas avec `123` (entier) — 0 correspondance, aucune erreur | `CAST()` / `SAFE_CAST()` explicite, dès la couche staging |
| **Espaces / casse** | `"Paris "` ≠ `"Paris"` ≠ `"paris"` | `TRIM()`, `LOWER()` en staging. Contrôle : `UNIQUE()` sur la colonne pour voir les variantes |
| **`NULL`** | `NULL = NULL` est faux en SQL : une clé nulle ne joint avec rien, jamais | `not_null` en test, ou clé de substitution |
| **Clé orpheline** | Une commande pointe vers un client absent de la dimension | `LEFT JOIN` + `WHERE dim.key IS NULL` pour les compter, test `relationships` en dbt |
| **Clé composite** | La vraie clé est `(date, magasin)`, pas `magasin` seul | Joindre sur les deux colonnes. Une clé partielle produit toujours un fan-out. |

---

## 📊 Power BI — la cardinalité devient explicite

Dans le modèle relationnel de Power BI, la cardinalité n'est plus implicite : elle se **déclare** à la création de la relation.

- **Plusieurs-à-un (\*:1)** — le cas normal. Table de faits (côté `*`) → dimension (côté `1`).
- **Un-à-un** — rare, souvent le signe que les deux tables devraient n'en faire qu'une.
- **Plusieurs-à-plusieurs** — à éviter. Symptôme d'une dimension manquante : il faut créer une table de pont avec des clés uniques.

> [!warning] Le côté « 1 » doit contenir des clés uniques
> Power BI refuse de créer une relation `*:1` si la colonne côté `1` contient des doublons — il force donc à respecter la règle. C'est un des rares outils qui protège activement contre le fan-out.

**Filtrage bidirectionnel** : à n'activer qu'en connaissance de cause. Il crée des chemins de filtre ambigus et peut réintroduire exactement le problème que le star schema évite.

Corollaire : dans un star schema, une table `dim_` a par construction une clé unique, une table `fct_` est toujours du côté `*`.

---

## 🔗 Liens

- Première apparition dans le cursus : [[02-google-sheets]] — `VLOOKUP` et la première occurrence
- [[Granularité d'une table]] — le fan-out est d'abord un problème de granularité mal identifiée
- [[Aggregate before divide]] — un ratio calculé après un fan-out est faux même avec `SUM/SUM`
- [[Window Function vs GROUP BY et JOIN]] — les window functions préservent la granularité, contrairement au join
- [[Data Pipelines, Views & Tables]]
