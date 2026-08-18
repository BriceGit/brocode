# Granularité d'une table

> **La granularité (ou *grain*) d'une table, c'est ce que représente exactement une ligne.** C'est la première question à se poser devant un dataset, avant toute jointure, toute agrégation et tout calcul de KPI.

---

## 🧪 Le test de la phrase

On doit pouvoir compléter cette phrase **sans hésiter et sans « ou »** :

> *« Une ligne de cette table = un/une ______. »*

| Table | Grain |
|---|---|
| `orders` | une **commande** |
| `order_items` | une **ligne de commande** (un produit dans une commande) |
| `customers` | un **client** |
| `sessions_web` | une **visite** |
| `stock_quotidien` | un **produit × un jour** |
| `soldes_comptes` | un **compte × une date d'arrêté** |

Si la réponse contient un « ou » (*« une commande, ou parfois un remboursement »*), la table a un **grain mixte** — c'est un défaut de modélisation, et toute agrégation dessus sera fausse.

> [!important] Le grain se documente
> En dbt, la première ligne de la description d'un modèle `fct_` devrait être son grain. C'est l'information que le prochain analyste (ou toi dans trois mois) cherchera en premier.

---

## 🔀 Ce qui change le grain, ce qui le préserve

| Opération | Effet sur le grain |
|---|---|
| `GROUP BY` | **Grossit** le grain — c'est même sa définition |
| `JOIN` sur clé unique à droite | **Préservé** |
| `JOIN` sur clé non unique à droite | 💥 **Affiné involontairement** → fan-out |
| `WHERE` / `FILTER` | Préservé (moins de lignes, même grain) |
| **Window function** (`OVER()`) | **Préservé** — c'est tout leur intérêt |
| Tableau croisé dynamique | **Grossit** — un TCD, c'est un `GROUP BY` visuel |
| `UNION` | Préservé **si** les deux tables ont le même grain. Sinon, catastrophe silencieuse |

> [!tip] La distinction `GROUP BY` vs `OVER()`
> `GROUP BY` réduit le nombre de lignes pour produire un agrégat. `OVER()` calcule le même agrégat **en gardant chaque ligne**. Choisir entre les deux, c'est décider du grain de sortie. → [[Window Function vs GROUP BY et JOIN]]

---

## 💥 Le mode d'échec typique : la mesure au mauvais grain

C'est la conséquence pratique la plus fréquente, et elle passe inaperçue.

```
orders (grain = commande)          order_items (grain = ligne de commande)
order_id | order_total             order_id | produit | montant
   42    |   100 €                    42    |   A     |  50 €
                                      42    |   B     |  30 €
                                      42    |   C     |  20 €
```

Joindre `orders` à `order_items` ramène le grain au **niveau ligne de commande**. La colonne `order_total` est alors répétée trois fois. `SUM(order_total)` renvoie 300 € au lieu de 100 €.

**La règle générale :** une mesure n'est sommable **qu'au grain auquel elle a été définie**. `order_total` vit au grain commande. Descendue au grain ligne, elle devient non additive.

**Trois issues possibles :**

1. **Agréger d'abord, joindre ensuite** — la solution par défaut
2. **Ne pas descendre le grain** — se demander si le join est vraiment nécessaire
3. **Distribuer la mesure** sur les lignes filles (répartir les 100 € au prorata) — nécessaire quand on veut une analyse au niveau produit

> [!danger] Si tu distribues : ne jamais arrondir la clé de répartition
> `montant_ligne / total_commande` est un **multiplicateur**. L'arrondir à 2 décimales avant de multiplier fait fuir le total : la somme des parts ne redonne plus le tout. `ROUND()` uniquement sur la **sortie finale**, jamais sur un intermédiaire.
>
> *(Leçon durement acquise sur la distribution de coûts Greenweez.)*

---

## ✅ Le grain check — le contrôle systématique

À lancer **après chaque join** et après toute transformation censée préserver le grain :

```sql
SELECT COUNT(*) AS lignes, COUNT(DISTINCT order_id) AS cles
FROM mon_modele;
-- Si la table est au grain commande : les deux nombres sont égaux
```

Et le **test de conservation** sur les montants :

```sql
-- Avant transformation
SELECT COUNT(*), SUM(revenu) FROM source;
-- Après
SELECT COUNT(*), SUM(revenu) FROM resultat;
```

Un écart sur le `COUNT(*)` révèle un fan-out. Un écart sur le `SUM()` révèle soit un fan-out, soit une perte de lignes (jointure interne non voulue, filtre implicite, `NULL` mangés par un `INNER JOIN`).

**En dbt**, ce contrôle devient déclaratif et permanent :

```yaml
models:
  - name: fct_orders
    description: "Grain : une ligne = une commande."
    columns:
      - name: order_id
        tests: [unique, not_null]
```

Le test `unique` sur la clé de grain **est** le grain check, exécuté à chaque `dbt build`.

---

## 🏗️ Le grain dans la modélisation

### Couches dbt

| Couche | Grain attendu |
|---|---|
| `stg_` | Le grain de la source, inchangé. Nettoyage et renommage uniquement. |
| `int_` | Grain intermédiaire, souvent déjà agrégé ou enrichi |
| `fct_` | **Un grain unique, explicite, documenté** |
| `dim_` | Une ligne = une entité (client, produit, magasin). Clé unique obligatoire. |

### Star schema

Le star schema est **entièrement une affaire de grain** : une table de faits à un grain déclaré, entourée de dimensions chacune à leur propre grain, reliées par des clés uniques côté dimension.

Deux faits à des grains différents (commandes et lignes de commande) → **deux tables de faits distinctes**, jamais une seule. Elles se relient à travers les dimensions partagées, pas entre elles.

### Le choix du grain

Toujours modéliser au **grain le plus fin** dont on aura besoin. On peut toujours agréger vers le haut ; on ne peut jamais redescendre. Une table agrégée trop tôt est une information définitivement perdue.

Le contre-argument (volumétrie, coût de scan en BigQuery) se traite par le partitionnement et le clustering, pas par une perte de grain. → [[Data Pipelines, Views & Tables]]

---

## 📅 Le cas particulier des dates

Le grain temporel est celui qu'on oublie le plus souvent de nommer.

- Grouper par **mois seul** fusionne janvier 2025 et janvier 2026. Le vrai grain voulu est `année-mois`.
- Une table `stock_quotidien` a un grain **`produit × jour`** : sommer la colonne `stock` sur une année n'a aucun sens (on additionne des photographies successives du même stock). C'est une mesure **semi-additive** — additive sur les produits, pas sur le temps.
- Un solde de compte, un effectif, un nombre de clients actifs : mêmes propriétés. En DAX, c'est ce qui justifie `LASTDATE` / `CLOSINGBALANCEMONTH` plutôt qu'un simple `SUM`.

> [!note] Trois occurrences du même piège dans le cursus
> Le filtre `WEEKNUM` sans contrainte d'année en Sheets, le `GROUP BY EXTRACT(MONTH FROM d)` sans l'année en SQL, et la colonne Mois sans Calendar table en Power BI sont **le même bug de granularité temporelle**, rencontré dans trois outils différents.

---

## 🔗 Liens

- Première apparition implicite dans le cursus : [[02-google-sheets]] — le tableau croisé dynamique manipule la granularité sans jamais la nommer
- [[Clé de jointure et cardinalité]] — le fan-out, principale cause de changement de grain non voulu
- [[Aggregate before divide]] — un ratio calculé au mauvais grain est faux même avec `SUM/SUM`
- [[Window Function vs GROUP BY et JOIN]]
- [[Data Pipelines, Views & Tables]]
