# Print vs Return

Deux mots-clés qui semblent faire la même chose au premier coup d'œil — tous les deux "montrent" un résultat — mais qui n'ont rien à voir en pratique.

## La différence

- **`print()`** affiche une valeur à l'écran, **au moment où la ligne s'exécute**. C'est un effet de bord, rien de plus : dès que la cellule ou la fonction se termine, cette valeur n'existe plus nulle part.
- **`return`** **sauvegarde** le résultat de la fonction à l'endroit où elle a été appelée, pour qu'il puisse être réutilisé (stocké dans une variable, réinjecté dans un calcul, chaîné avec autre chose).

```python
def calcul_v1(a, b):
    print(a / b)      # affiche le résultat...

def calcul_v2(a, b):
    return a / b       # ...et le sauvegarde pour plus tard

resultat_1 = calcul_v1(9, 3)   # affiche "3.0" à l'écran, mais resultat_1 = None
resultat_2 = calcul_v2(9, 3)   # n'affiche rien, mais resultat_2 = 3.0
```

## Le piège

`calcul_v1` a l'air de "marcher" — on voit bien `3.0` s'afficher. C'est ce qui rend l'erreur trompeuse : tout semble correct jusqu'au moment où on essaie de **réutiliser** `resultat_1` dans un autre calcul, et là on découvre que sa valeur est `None` (la valeur par défaut renvoyée par une fonction qui n'a pas de `return` explicite).

**Réflexe** : dès qu'une fonction doit alimenter autre chose derrière (une variable, une boucle, une autre fonction), vérifier qu'elle fait bien `return` et pas seulement `print`. Si le résultat doit uniquement être vu à l'écran une fois (debug, vérification ponctuelle), `print` suffit.

## Note transversale

Ce n'est pas propre à Python : la distinction "afficher" vs "renvoyer une valeur réutilisable" existe partout où on écrit des fonctions — `console.log` vs `return` en JavaScript, `SELECT` vs une fonction SQL qui `RETURN`-e une valeur, etc. Le nom change, le principe reste le même.

---
🔗 Vu dans [[26-intro-python|Intro Python]]
