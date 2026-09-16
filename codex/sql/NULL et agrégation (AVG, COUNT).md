---
title: NULL et agrégation (AVG, COUNT)
type: concept
status: active
modeles_ia: []
attribution: a_confirmer
language: fr
tags:
- brocode
- codex
---

# NULL et agrégation (AVG, COUNT)

Les fonctions d'agrégation ne traitent pas toutes les `NULL` de la même façon selon qu'elles comptent des lignes ou calculent une moyenne — un piège récurrent.

## COUNT(colonne) vs COUNT(*)

```sql
SELECT COUNT(date) FROM purchases   -- ignore les lignes où date est NULL
SELECT COUNT(*) FROM purchases      -- compte TOUTES les lignes, NULL ou pas
```

Sur une table de 10 lignes où une seule a une `date` à `NULL` :
- `COUNT(date)` → **9**
- `COUNT(*)` → **10**

## AVG et les NULL

`AVG(colonne)` équivaut en interne à `SUM(colonne) / COUNT(colonne)`. Comme `COUNT(colonne)` ignore les `NULL`, **`AVG` les ignore aussi** — un `NULL` n'est jamais traité comme un `0`.

**Piège classique** : avec les valeurs `10, 20, NULL` :

```
AVG = (10 + 20) / COUNT(10, 20, NULL) = 30 / 2 = 15
```

Le résultat est **15**, pas 10 (`30 / 3`, si le `NULL` comptait comme une 3ème valeur) — et surtout pas une erreur.

## Et sur du texte ?

`MIN`/`MAX` fonctionnent sans erreur sur une colonne texte (retourne la valeur la plus petite/grande par ordre alphabétique), mais **`AVG` ne fonctionne pas sur du texte** — logique, une moyenne suppose des valeurs numériques additionnables.

## Voir aussi

- [[wagon2321/cours/24_rebootsql_fivetran_git_dbt|Reboot SQL Fivetran Git dbt]] — chapitre source, section Fonctions d'agrégation
- [[codex/sql/WHERE vs HAVING|WHERE vs HAVING]]

## Cours de référence

- [[wagon2321/cours_sol/06_sql_aggregation_string_date_time_functions_sol|SQL — Aggregations, String, Date & Time Functions]]
- [[wagon2321/cours_sol/14_dbt_advanced_sol|dbt — Tests, documentation, environnements, macros & packages]]
