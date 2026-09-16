---
title: Masque booléen (boolean masking)
type: concept
status: active
modeles_ia: []
attribution: a_confirmer
language: fr
tags:
- brocode
- codex
---

# Masque booléen (boolean masking)

Le **masquage booléen** est le mécanisme de filtrage central en Pandas (et en NumPy). Le principe : appliquer une condition logique sur une Series produit une nouvelle Series de `True`/`False`, alignée sur l'index d'origine — ce masque peut ensuite être passé entre crochets à un DataFrame pour n'en garder que les lignes où il vaut `True`.

## Syntaxe

```python
# Version explicite, en deux temps
mask = (df["store_id"] == 23)
df_filtered = df[mask]

# Version condensée, la plus courante en pratique
df_filtered = df[df["store_id"] == 23]
```

## Combiner des conditions

| Opérateur | Rôle | Équivalent SQL |
|---|---|---|
| `&` | ET | `AND` |
| `\|` | OU | `OR` |
| `!=` | Négation | `<>` / `!=` |

```python
df[(df["store_id"] == 23) & (df["quantity"] > 2)]
```

> [!warning] Parenthèses obligatoires
> À cause de la précédence des opérateurs Python, chaque condition individuelle doit être entre parenthèses lorsqu'on les combine avec `&` / `|` — sans quoi Python essaie d'évaluer `&`/`|` avant les comparaisons et lève une erreur.

## L'astuce True = 1, False = 0

En data, les booléens `True`/`False` sont encodés comme des valeurs numériques : `True` = 1, `False` = 0. Conséquence directe : appeler `.sum()` sur une Series booléenne (ou sur un masque directement) revient à **compter le nombre de `True`** — c'est-à-dire le nombre de lignes qui respectent la condition.

```python
(df["time"] == "Lunch").sum()   # nombre de lignes où time == "Lunch"
```

C'est rigoureusement le même principe que `SUM(CASE WHEN condition THEN 1 ELSE 0 END)` ou `COUNTIF(condition)` côté SQL/BigQuery : une condition booléenne réduite à un comptage via une somme.

### Variantes pour arriver au même résultat

| Méthode | Code | Quand la préférer |
|---|---|---|
| Masque + `.sum()` | `(df["col"] == val).sum()` | Réponse directe à "combien de lignes respectent X" |
| Masque + `.shape[0]` | `df[df["col"] == val].shape[0]` | Si on a aussi besoin du sous-DataFrame filtré ensuite |
| `.value_counts()` | `df["col"].value_counts()[val]` | Si on veut la répartition complète, pas juste une valeur |

Aucune de ces méthodes n'est "la bonne" — l'essentiel est d'en maîtriser une et de savoir pourquoi elle fonctionne, plutôt que de courir après le one-liner le plus court.

## Piège classique

```python
df["Lunch"]   # ❌ KeyError
```

Entre crochets simples, Pandas attend un **nom de colonne** — pas une valeur contenue dans une colonne. `"Lunch"` est une valeur de la colonne `time`, pas un intitulé de colonne. Réflexe utile avant de coder : formuler la demande en pseudo-code ("je veux compter" + "je veux filtrer sur Lunch") pour ne pas confondre les deux niveaux.

---
🔗 Vu dans [[wagon2321/cours/27-pandas-manipulation-donnees|Pandas — Manipulation de données]]
🔗 Fait partie de la famille [[codex/sheet/Aggregate before divide|Aggregate before divide]]
