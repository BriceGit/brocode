# Nested Query vs CTE

Deux façons d'imbriquer une requête dans une autre — souvent confondues, pas tout à fait la même chose.

## La différence

- **Nested query** (sous-requête imbriquée) : une requête directement à l'intérieur du `FROM` ou du `WHERE` d'une autre, **sans nom**
- **CTE** (Common Table Expression) : la même idée, mais **nommée explicitement** via `WITH ... AS` en amont, puis réutilisée comme une table normale

```sql
-- CTE
WITH name_subquery AS (
  SELECT ...
  FROM source_table
)
SELECT ...
FROM name_subquery
```

Les deux appartiennent à la famille des *subqueries*. Une CTE est en général plus lisible dès que la logique se complexifie ou s'enchaîne sur plusieurs étapes — d'où sa préférence en pratique.

⚠️ À ne pas confondre avec une [[Window Function vs GROUP BY et JOIN|window function]] : une CTE n'a **pas** de mot-clé `OVER`, ce sont deux mécanismes distincts, même s'ils peuvent se combiner dans une même requête complexe (filtrer sur le résultat d'une window function nécessite justement de passer par une CTE).

## Deux cas d'usage concrets

**1. Injecter une agrégation `GROUP BY` dans une requête de jointure ultérieure**

```sql
WITH orders_subquery AS (
  SELECT orders_id, SUM(turnover) AS turnover
  FROM sales
  GROUP BY orders_id
)
SELECT orders_id, turnover, shipping_fee
FROM orders_subquery
INNER JOIN orders_ship USING(orders_id)
```

**2. Enchaîner plusieurs calculs successifs dans une seule requête**

```sql
WITH margin_subquery AS (
  SELECT orders_id, turnover, turnover - purchase_cost AS margin
  FROM course17.orders
)
SELECT orders_id, turnover, margin,
  SAFE_DIVIDE(margin, turnover) AS margin_percent
FROM margin_subquery
```

## Voir aussi

- [[Reboot SQL Fivetran Git dbt]] — chapitre source, section Subqueries & CTE
- [[Window Function vs GROUP BY et JOIN]]
