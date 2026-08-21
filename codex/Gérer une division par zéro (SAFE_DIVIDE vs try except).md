# Gérer une division par zéro (SAFE_DIVIDE vs try/except)

Le même problème — un dénominateur qui peut valoir zéro (ou être vide) — revient dans tous les outils manipulant des données. Chacun a son mécanisme dédié, mais la logique de fond est identique : **anticiper le cas limite plutôt que laisser le calcul planter en silence ou en erreur**.

## SQL / BigQuery — `SAFE_DIVIDE`

```sql
SELECT
  SAFE_DIVIDE(total_ventes, nombre_commandes) AS panier_moyen
FROM clients
```

`SAFE_DIVIDE(x, y)` renvoie `NULL` au lieu de faire échouer la requête si `y` vaut `0`. Pas besoin de `CASE WHEN y = 0 THEN NULL ELSE x / y END`.

## Python — `try` / `except ZeroDivisionError`

```python
def calculer_panier_moyen(client, table):
    try:
        return sum(table[client]) / len(table[client])
    except ZeroDivisionError:
        return 0
```

Ici, pas de fonction native équivalente à `SAFE_DIVIDE` : on encadre la division dans un bloc `try`, et on définit explicitement ce qui doit se passer si elle échoue (`except`). Cibler l'exception précise (`ZeroDivisionError` plutôt qu'un `except` générique) évite de masquer d'autres bugs sous le même filet.

## pandas — équivalent à venir

Pandas (vu en cours dès le lendemain de cette session) aura son propre réflexe pour ce même problème — division vectorisée sur une colonne avec un dénominateur potentiellement nul. À compléter ici une fois le chapitre pandas repassé en revue.

## Le vrai piège : la valeur de repli n'est jamais neutre

Que ce soit `NULL` (SQL) ou `0` (Python), la valeur choisie pour le cas d'erreur **n'est pas un détail** :

- `NULL` est généralement ignoré par les fonctions d'agrégation SQL (`AVG`, `SUM`) — comportement souvent voulu.
- `0` en Python, en revanche, est une valeur **normale** pour la suite des calculs : si ce panier moyen "de secours" est réinjecté dans une moyenne globale ou un tri, il fausse silencieusement le résultat sans lever la moindre erreur.

**Réflexe** : ne jamais choisir la valeur de repli par automatisme. Se demander explicitement ce que cette valeur va devenir dans les calculs qui suivent — et si `None` (l'équivalent Python d'un NULL, souvent plus sûr qu'un `0` silencieux) ne serait pas le choix le plus honnête.

---
🔗 Fait partie de la famille [[Aggregate before divide]]
🔗 Vu dans [[26-intro-python|Intro Python]]
