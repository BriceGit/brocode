# WHERE vs HAVING

Deux clauses qui filtrent toutes les deux, mais pas au même moment de l'exécution.

## L'idée centrale

- **`WHERE`** filtre les **lignes individuelles**, **avant** toute agrégation (pre-filtering)
- **`HAVING`** filtre le **résultat groupé**, **après** l'agrégation (post-filtering)

Conséquence directe : **`WHERE` ne peut pas utiliser une fonction d'agrégation** (`SUM`, `COUNT`, `AVG`...). Au moment où `WHERE` s'exécute, le calcul d'agrégation n'a pas encore eu lieu — la valeur n'existe donc pas encore.

## Ordre obligatoire dans une requête

`WHERE` est **toujours avant** `GROUP BY` ; `HAVING` vient **après**. On n'est pas obligé d'avoir les deux dans la même requête, mais rien n'empêche de les combiner.

```sql
SELECT buyer, SUM(spend) AS total_spend
FROM purchases
WHERE spend > 0          -- filtre les lignes brutes, avant regroupement
GROUP BY buyer
HAVING total_spend > 10  -- filtre le résultat déjà groupé
```

## Piège classique : même seuil, résultat différent

Sur la table `purchases` (buyer, spend) vue dans le chapitre reboot, comparer :

```sql
-- WHERE avant agrégation : ne garde QUE les lignes individuelles où spend > 10
SELECT buyer, SUM(spend) AS total_spend
FROM purchases
WHERE spend > 10
GROUP BY buyer
-- → Julien : 15 (sa seule ligne à 15 passe le filtre individuel)
```

```sql
-- HAVING après agrégation : garde les buyers dont le TOTAL dépasse 10
SELECT buyer, SUM(spend) AS total_spend
FROM purchases
GROUP BY buyer
HAVING total_spend > 10
-- → Julie : 12.5  ET  Julien : 17.5
```

Julie disparaît complètement de la première requête : ses achats (3, 3, 4.5, 2) ne dépassent jamais 10 **individuellement**, même si leur somme (12.5) le fait. La deuxième requête la garde, car elle compare le total déjà agrégé, pas les lignes brutes. Même seuil `> 10`, deux résultats radicalement différents — exactement le genre de nuance qui tombe en entretien.

## Voir aussi

- [[Reboot SQL Fivetran Git dbt]] — chapitre source, section Fonctions d'agrégation
- [[Window Function vs GROUP BY et JOIN]] — même logique sous-jacente : l'ordre d'exécution des clauses
- [[NULL et agrégation (AVG, COUNT)]]
