# loc vs iloc (Pandas)

Deux méthodes de sélection de lignes/colonnes sur un DataFrame, souvent confondues parce qu'un index par défaut est numérique — ce qui les fait sembler interchangeables alors qu'elles suivent des conventions différentes.

| | Sélectionne par | Borne de fin | Type d'argument attendu |
|---|---|---|---|
| **`.loc`** | **Labels** (valeurs d'index, noms de colonnes) | **Incluse** | Labels : entiers personnalisés, strings, dates... |
| **`.iloc`** | **Positions entières** | **Exclue** (convention Python classique) | Toujours des entiers, quel que soit l'index réel |

## Exemples

```python
df.loc[1:3, ["store_id", "item_id"]]
# → lignes d'INDEX 1, 2 ET 3 (borne incluse), colonnes nommées explicitement

df.iloc[1:4, 1:3]
# → lignes en POSITION 1, 2, 3 (position 4 exclue), colonnes en position 1 et 2
# → résultat identique en nombre de lignes à l'exemple .loc ci-dessus,
#   par coïncidence car l'index par défaut est 0,1,2,3... et matche les positions
```

> [!warning] Pourquoi les deux exemples ci-dessus se ressemblent
> Avec un index par défaut (0, 1, 2, 3...), position et label coïncident, ce qui brouille la distinction à l'usage. La différence saute aux yeux dès que l'index a été trié, filtré, ou remplacé par des labels non numériques (dates, chaînes...) : `.loc[1:3]` continuera à chercher les *labels* 1 à 3 même s'ils ne sont plus aux positions 1 à 3, alors que `.iloc[1:3]` continuera à prendre les 2e et 3e lignes quel que soit leur label.

## Le repère pour ne pas se tromper

`.iloc` suit la même convention que `range()` et `np.arange()` : la borne de fin est **exclue**. `.loc` suit une convention plus "humaine" : la borne de fin est **incluse**, comme on le ferait en énumérant "de 1 à 3" dans une conversation.

**Règle pratique** :
- Besoin de cibler des colonnes ou des lignes par leur **nom/label** → `.loc`
- Besoin de cibler par **position pure** (ex. "les 3 premières lignes, peu importe leur label") → `.iloc`

---
🔗 Vu dans [[27-pandas-manipulation-donnees|Pandas — Manipulation de données]]
