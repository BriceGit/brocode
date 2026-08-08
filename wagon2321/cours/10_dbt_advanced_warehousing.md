# 📝 Fiche de synthèse — #14 DBT Advanced

**Date session :** 23 juillet 2026
**Dataset démo :** Jaffle Shop
**Compréhension :** à noter après relecture

---

## 1. Avant d'écrire un modèle : le check Grain & Primary Key

Pour chaque table brute, répondre à 4 questions avant de coder quoi que ce soit :

- **Grain** : que représente une ligne ?
- **Primary key** : quelle(s) colonne(s) identifie(nt) une ligne de façon unique ?
- **Row count** : ordre de grandeur du volume
- **Data quality issues** : types faux, NULLs, incohérences

> Si tu ne peux pas répondre à ça, tu ne connais pas encore assez la donnée pour la transformer.

**Exemple de dirty data rencontré (cas Greenweez) :**
- `purchSE_PRICE` : nom de colonne en casse mixte
- `purchSE_PRICE` stocké en `VARCHAR` → `CAST("purchSE_PRICE" AS DOUBLE)` avant tout calcul
- `ship_cost` : idem, `VARCHAR` → `CAST(ship_cost AS DOUBLE)`

Ces surprises se trouvent avec un `SELECT * ... LIMIT 10` + inspection des types de colonnes.

---

## 2. Pourquoi tester : les silent failures

**Scénario** : `dbt run` réussit, mais le mart renvoie de mauvais chiffres **silencieusement**.

4 questions que les tests permettent de répondre :
1. `customer_id` identifie-t-il vraiment un seul client ? → `unique`
2. Y a-t-il des NULLs là où il ne devrait pas y en avoir ? → `not_null`
3. Les valeurs de statut appartiennent-elles à l'ensemble attendu ? → `accepted_values`
4. Chaque commande référence-t-elle un client réel ? → `relationships`

---

## 3. Les 4 tests génériques natifs

| Test | Ce qu'il vérifie |
|---|---|
| `unique` | Pas de doublons dans la colonne |
| `not_null` | Pas de NULL dans la colonne |
| `accepted_values` | Toutes les valeurs viennent d'une liste définie |
| `relationships` | Chaque valeur existe dans la colonne référencée d'un autre modèle |

**Déclaration dans `schema.yml` :**

```yaml
models:
  - name: stg_payments
    columns:
      - name: payment_id
        tests: [unique, not_null]
      - name: payment_method
        tests:
          - not_null
          - accepted_values:
              values: [credit_card, coupon, bank_transfer, gift_card]
```

**Le test `relationships` en détail :**

```yaml
- name: fct_orders
  columns:
    - name: customer_id
      tests:
        - relationships:
            to: ref('dim_customers')
            field: customer_id
```
→ Vérifie que chaque `customer_id` de `fct_orders` existe dans `dim_customers`. Échoue si une commande référence un client supprimé ou inexistant.

---

## 4. Lire l'output de `dbt test`

- Chaque ligne montre : nom du test + modèle + colonne
- Un test qui échoue affiche les lignes en échec dans le log
- Résumé final : `Done. PASS=X WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=X`

---

## 5. Severity : `error` vs `warn`

```yaml
tests:
  - not_null:
      config:
        severity: warn
```

- **`error`** (défaut) : un échec bloque le build
- **`warn`** : un échec log un warning mais continue

**Utiliser `warn` pour** : NULLs attendus, champs optionnels, problèmes de qualité "soft"
**Utiliser `error` pour** : primary keys, FK critiques, valeurs qui casseraient un calcul

---

## 6. Organisation des fichiers `schema.yml`

```
models/
├── schema.yml          ← sources: uniquement (pas de models: ici)
├── staging/
│   └── schema.yml       ← modèles stg_ + tests
├── intermediate/
│   └── schema.yml       ← modèles int_ + tests
└── marts/
    └── schema.yml       ← modèles dim_/fct_ + tests
```

**Règle : `sources:` reste à la racine, `models:` va dans le sous-dossier qui contient ces modèles.**
Erreur classique : ajouter des entrées `models:` dans le `schema.yml` racine où vivent déjà les `sources:` → dbt lève une erreur de définition dupliquée si un même modèle est déclaré dans deux fichiers.

---

## 7. Documentation : `description:`

```yaml
- name: stg_payments
  description: "One payment per row. Amount converted from cents to dollars."
  columns:
    - name: amount
      description: "Payment amount in USD (source stores in cents — divided by 100.0 here)"
```

- `description:` au niveau **modèle** = à quoi correspond ce modèle ?
- `description:` au niveau **colonne** = que signifie cette valeur ?

→ Future-toi remerciera présent-toi d'avoir écrit ça.

---

## 8. Data Quality Rules par couche — grille de référence

| Couche | Tests typiques |
|---|---|
| **Staging** | `unique` + `not_null` sur les PK · `accepted_values` sur les catégorielles |
| **Intermediate** | `unique` sur les PK dérivées · `not_null` sur les join keys · `accepted_values` sur les champs de statut |
| **Marts** | `unique` + `not_null` sur les PK · `relationships` pour les FK |

---

## 9. `dbt build` vs `dbt run` + `dbt test`

- `dbt run && dbt test` : construit tout, **puis** teste tout
- `dbt build` : construit **et** teste dans l'ordre du DAG — construit `stg_customers` → le teste immédiatement → construit ensuite `int_orders_with_payments` seulement si le test passe
- Si `stg_customers` échoue un test, `dbt build` s'arrête **avant** de construire tout ce qui en dépend

**💡 À retenir : `dbt build` en défaut. `dbt run` seul pendant le dev quand tu ne veux pas que les tests bloquent.**

---

## 10. Tests singuliers custom (SQL libre)

```sql
-- tests/assert_positive_order_amount.sql
SELECT order_id, total_amount
FROM {{ ref('fct_orders') }}
WHERE total_amount < 0   -- returned rows = test failures
```

- Fichier SQL dans `tests/` : si la requête renvoie des lignes → le test échoue
- Lancer avec : `dbt test --select test_type:singular`
- À utiliser quand la logique de validation ne rentre pas dans les 4 tests génériques
- 💡 Nomme tes fichiers de façon descriptive, le nom de fichier s'affiche dans l'output `dbt test`

---

## 11. Créer son propre test générique (réutilisable)

```sql
{% test name_of_your_test(model, column_name) %}
  SELECT
    COUNT(*) as num_records
  FROM
    {{ model }}
  WHERE
    {{ column_name }} = 'some_value_not_to_be_found_in_col'
{% endtest %}
```
- Écrit dans le dossier `tests/`
- Le test passe s'il n'y a **aucune ligne renvoyée**
- Contrairement au test singulier (ponctuel, un seul modèle), le test générique custom est réutilisable sur n'importe quelle colonne/modèle comme `unique` ou `not_null`

---

## 12. `dbt docs` — documentation auto-générée

```bash
dbt docs generate   # lit le projet + schema.yml + résultats de requêtes → génère un catalogue JSON
dbt docs serve       # ouvre localhost:8080 avec le site de docs
```

Contient :
- **Lineage graph** : tous les modèles/sources reliés par les edges `{{ ref() }}` et `{{ source() }}`, cliquable
- **Descriptions de modèles** : tirées directement du `description:` dans `schema.yml`
- **Descriptions de colonnes** : chaque colonne listée avec sa description et son type
- **Badges de tests** : les colonnes testées affichent `unique`, `not_null`, etc. comme tags
- **SQL compilé** : bouton "Details" sur un modèle pour voir le SQL réellement exécuté

---

## 13. Les targets dbt (dev vs prod)

```yaml
greenweez_dbt:
  target: dev          # target par défaut
  outputs:
    dev:
      type: duckdb
      path: "dev_database.duckdb"
      threads: 4
    prod:
      type: duckdb
      path: "dev_database.duckdb"
      schema: analytics_prod
      threads: 4
```

- `dbt build` → target `dev` → écrit dans `main_staging`, `main_marts`
- `dbt build --target prod` → écrit dans `analytics_prod_staging`, `analytics_prod_marts`
- Même code SQL, namespace de schéma différent

---

## 14. Jinja : ce que `{{ }}` fait réellement

| Syntaxe | Rôle | Exemple dbt |
|---|---|---|
| `{{ expression }}` | Renvoie une valeur | `{{ ref('stg_sales') }}`, `{{ source('raw', 'orders') }}` |
| `{% statement %}` | Flux de contrôle (pas de sortie) | `{% set x = 1 %}`, `{% if ... %}` |

- Avant d'exécuter du SQL, dbt compile tous les `{{ }}` en SQL brut
- Une **macro** est une fonction Jinja réutilisable : `{{ ref() }}`, `{{ source() }}`, `{{ config() }}` sont toutes des macros intégrées à dbt

---

## 15. Macros custom pour réutiliser du code

```sql
-- macros/functions.sql
{% macro create_product_id(model, color) %}
  concat({{model}}, "_", {{color}}, "_", ifnull(size, "no-size"))
{% endmacro %}
```

Utilisation dans un modèle :
```sql
-- models/staging/raw_data_circle/stg_stock.sql
select
    {{ create_product_id('model', 'color') }} as product_id,
    ...
```

---

## 16. `dbt compile` : la fenêtre de debug

`dbt compile` résout tous les `{{ ref() }}`, `{{ source() }}` et macros **sans rien exécuter**.
Output : `target/compiled/your_project/models/...`

**3 moments où l'utiliser :**
1. Après avoir écrit un `{{ source() }}` pour vérifier qu'il pointe vers la bonne table
2. Après avoir utilisé une macro, pour voir le SQL généré
3. Quand un modèle échoue — lire le SQL compilé, pas le template Jinja

---

## 17. dbt Packages (dbt_utils)

```yaml
# packages.yml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
```

```bash
dbt deps   # à lancer depuis l'intérieur du dossier greenweez_dbt/
```

- **Problème résolu** : tu as réécrit le même `CASE WHEN denominator > 0 THEN ...` cinq fois
- **Solution** : des macros testées par la communauté, à installer et réutiliser
- `dbt deps` installe tous les packages listés dans `packages.yml`
- `dbt deps` se lance depuis le dossier du projet dbt, pas depuis la racine du challenge
- Ne pas commit `dbt_packages/` → doit être dans le `.gitignore`

---

## 📌 Vue d'ensemble : où se situe DBT dans le pipeline data

D'après la transcription (récap tableau blanc) :

```
Sources (Paypal, Stripe...) → EL (Fivetran/Airbyte) → Data Warehouse (raw)
                                                              ↓
                                              DBT : staging → intermediate → marts
                                                              ↓
                                                          Dashboard
```

- DBT **ne stocke pas** la donnée — il stocke uniquement la logique de code (SQL compilé)
- Architecture en couches = "médaillon" = data layers, plusieurs synonymes pour la même logique :
  - **Staging** (vert) : nettoyage
  - **Intermediate** : jointures, agrégats, calculs complexes
  - **Marts** : modèles finaux, KPIs, calculs simples
- Tout ça peut être schedulé (ex. tous les matins à 8h) : rebuild + tests automatiques avant que les collègues arrivent
- Question posée en session : pourquoi toujours les fichiers YML en version 2 ? → c'est la version actuelle standard, comprise par dbt ; rien à voir avec une "version affichée"

---

## ✅ Actions post-session (rappel de tes notes Notion)

- [ ] Terminer le projet Jaffle Shop (staging, intermediate, marts) avec tests associés avant de passer à la suite
- [ ] À partir de l'exercice 3 : démarrer une nouvelle pipeline sur le dataset Italy/Guinness (données réelles)
- [ ] Si l'exercice 6 (couche intermediate) n'est pas fini, le compléter avant de continuer
- [ ] Créer `packages.yml` + lancer `dbt deps` pour installer `dbt_utils`
- [ ] Documenter chaque modèle et colonne dans les `schema.yml` au fil de l'avancement

---

*Fiche générée à partir des captures d'écran + transcription de la session #14 (23/07/2026), pour intégration dans `sql-cookbook` ou Notion.*
