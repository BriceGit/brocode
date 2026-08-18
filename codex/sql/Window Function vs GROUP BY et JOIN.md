# Window Function vs GROUP BY et JOIN

Deux façons d'obtenir une agrégation "par groupe" — avec une différence fondamentale de granularité.

## La différence clé

- **`GROUP BY`** condense les lignes : une valeur unique de la colonne groupée = **une seule ligne** en sortie
- **Window function** (`OVER`) calcule aussi une agrégation par groupe, mais **garde toutes les lignes d'origine** — le résultat agrégé est simplement répété sur chaque ligne du groupe

`PARTITION BY` (dans une window function) est l'équivalent conceptuel de `GROUP BY`, sans la fusion des lignes.

## Les deux écritures, même résultat

**Avec une window function :**

```sql
SELECT
  model,
  model_type,
  stock_value,
  SUM(stock_value) OVER (PARTITION BY model_type) AS stock_model_type
FROM circle_stock
```

**Avec GROUP BY + JOIN (équivalent) :**

```sql
WITH stock_model_type AS (
  SELECT model_type, SUM(stock_value) AS stock_model_type
  FROM circle_stock
  GROUP BY model_type
)
SELECT
  c.model,
  c.model_type,
  c.stock_value,
  s.stock_model_type
FROM circle_stock AS c
INNER JOIN stock_model_type AS s USING (model_type)
```

Les deux requêtes renvoient exactement la même information — la window function le fait juste **en une seule requête**, sans [[Nested Query vs CTE|CTE]] ni jointure supplémentaire.

## Le mot-clé qui trahit une window function

`OVER` — dès qu'il apparaît (`SUM(...) OVER`, `RANK() OVER`, `COUNT(...) OVER`...), c'est une window function, pas un `GROUP BY` classique.

## ROW_NUMBER, RANK : ce qu'ils NE font PAS

**Piège classique** : `ROW_NUMBER() OVER (ORDER BY date)` :
- ❌ ne trie **pas** l'affichage de la table
- ❌ ne supprime **pas** les doublons
- ❌ ne calcule **pas** de somme

Il assigne juste un numéro de ligne séquentiel selon l'ordre choisi (**ascendant par défaut**). Rien de plus.

Pour filtrer sur ce numéro (ex. isoler la 1ère commande de chaque client avec `WHERE row_num = 1`), impossible de le faire directement dans la même requête : `WHERE` s'exécute **avant** que la window function soit évaluée. Il faut passer par une [[Nested Query vs CTE|CTE]].

## Window function + GROUP BY, dans la même requête ?

**Piège classique** : oui, ça fonctionne — par exemple `RANK() OVER (ORDER BY SUM(salary))` avec un `GROUP BY department` à la fin de la requête. Ça marche parce que le `GROUP BY` s'exécute **avant** le `SELECT` (donc avant l'évaluation de la window function) : l'agrégation `SUM(salary)` est déjà calculée et disponible quand `RANK() OVER` s'en sert pour classer les lignes.

## Voir aussi

- [[Reboot SQL Fivetran Git dbt]] — chapitre source, section Window Functions
- [[WHERE vs HAVING]] — même logique d'ordre d'exécution des clauses
- [[Nested Query vs CTE]]
