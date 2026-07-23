# 🧠 Fiche de synthèse — Config initiale dbt & gestion des sources

**Contexte** : basée sur la session de debug réelle du projet `greenweez_dbt` (23/07/2026)

---

## 1. Les 3 fichiers de config qu'il ne faut jamais confondre

C'est LA confusion qui a causé la moitié des erreurs de la session. Trois fichiers, trois rôles totalement différents :

| Fichier | Rôle | Où il vit |
|---|---|---|
| `dbt_project.yml` | Config du **projet** : nom, chemins, matérialisation par défaut des modèles | À la racine du projet dbt |
| `profiles.yml` | Config de **connexion** à la base de données (quel fichier `.duckdb`, quels credentials) | `~/.dbt/profiles.yml` — **hors du projet**, propre à ta machine |
| `sources.yml` | Déclaration des **tables sources brutes** (raw) que dbt peut référencer via `source()` | Dans `models/` (souvent `models/staging/sources.yml`) |

**Piège vécu** : `dbt_project.yml` contient `name: 'greenweez_dbt'` — c'est le nom du **projet**. Ça n'a *rien à voir* avec le nom d'une source. Le nom à utiliser dans `source('xxx', 'table')` vient uniquement de `sources.yml`, sous la clé `name:` du bloc `sources:`.

---

## 2. `profiles.yml` — la connexion à la base

Structure type :
```yaml
greenweez_dbt:              # doit matcher le `profile:` déclaré dans dbt_project.yml
  outputs:
    dev:
      type: duckdb
      path: dev.duckdb      # chemin RELATIF au dossier où tu lances `dbt run`
      threads: 4
    prod:
      type: duckdb
      path: prod.duckdb
      threads: 4
  target: dev                # environnement utilisé par défaut
```

**Points de vigilance (vécus aujourd'hui) :**
- Le `path:` doit pointer vers un fichier `.duckdb` qui **existe réellement** et **contient déjà les données attendues** (schémas, tables). dbt ne crée pas la base à ta place si tu attends des données préchargées.
- Si tu as chargé des données brutes à la main via le CLI DuckDB (`duckdb mon_fichier.duckdb` + `CREATE TABLE ...`), c'est **ce fichier précis** qu'il faut référencer dans `path:` — pas un autre fichier `.duckdb` qui traîne dans le dossier avec un nom proche.
- `Catalog "xxx" does not exist!` = le fichier pointé par `path:` existe mais est vide (mauvais fichier).
- `Binder Error: Table with name "raw.xxx" does not exist because schema "raw" does not exist` = tu es bien dans le bon fichier, mais le schéma/les tables n'y ont jamais été créés.

**Débug rapide** :
```bash
# Vérifier quel fichier .duckdb existe et sa taille (un fichier vide ≈ quelques Ko)
ls -la *.duckdb

# Ouvrir le fichier référencé dans profiles.yml pour vérifier son contenu
duckdb dev.duckdb
D .tables
D SELECT * FROM raw.raw_gz_sales LIMIT 5;
```

---

## 3. `sources.yml` — déclarer les tables brutes

Structure type :
```yaml
version: 2

sources:
  - name: raw                          # ← nom LIBRE, choisi par toi
    description: "Les tables de Greenweez"
    schema: raw                        # ← nom du schéma DANS la base DuckDB
    tables:
      - name: raw_gz_sales
        description: "Tableau des ventes"
        columns:
          - name: orders_id
            description: "..."
```

**Ce que `source('raw', 'raw_gz_sales')` fait réellement** :
1. dbt cherche un bloc `sources:` avec `name: raw`
2. Dans ce bloc, il cherche une table `name: raw_gz_sales`
3. Il compile ça en SQL réel : `"dev"."raw"."raw_gz_sales"` (base . schéma . table)

**Piège vécu** : écrire `{{ source(raw_gz_sales) }}` sans guillemets → dbt essaie d'interpréter `raw_gz_sales` comme une variable Jinja (qui n'existe pas) plutôt qu'une chaîne de caractères. **Toujours deux arguments string, entre quotes.**

```sql
-- ❌ Faux
FROM {{ source(raw_gz_sales) }}
FROM {{ source('greenweez_dbt', 'raw_gz_sales') }}   -- confond nom de projet et nom de source

-- ✅ Correct
FROM {{ source('raw', 'raw_gz_sales') }}
```

**Pourquoi utiliser `source()` plutôt qu'écrire le nom de table en dur ?**
- dbt peut construire le **graphe de dépendances (DAG)** — il sait que `stg_gwz_sales` dépend de `raw.raw_gz_sales`
- Si le schéma source change de nom (staging → prod), un seul endroit à modifier (`sources.yml`)
- `dbt source freshness` devient possible (vérifier que les données sources ne sont pas périmées)

---

## 4. Matérialisation — `view` vs `views`

Erreur bête mais fréquente : dbt attend le nom **singulier** de la stratégie de matérialisation.

```yaml
# ❌ Faux — n'existe pas dans dbt
models:
  greenweez_dbt:
    staging:
      +materialized: views

# ✅ Correct
models:
  greenweez_dbt:
    staging:
      +materialized: view
```

Valeurs valides : `view`, `table`, `incremental`, `ephemeral` — toujours au singulier.

---

## 5. Ordre de résolution d'une erreur `dbt run`

Quand `dbt run` plante, l'ordre de diagnostic le plus efficace (du plus fréquent au plus rare, d'après les erreurs vécues aujourd'hui) :

1. **Compilation Error / Parsing Error** → problème de syntaxe Jinja/YAML (guillemets manquants, indentation `tests:` vs `test:`, clé YAML mal imbriquée)
2. **`source named 'X' which was not found`** → mismatch entre le nom utilisé dans `source()` et le `name:` réel dans `sources.yml`
3. **`No materialization 'X' was found`** → faute de frappe dans `+materialized:` (`dbt_project.yml`)
4. **`Catalog "X" does not exist`** → `path:` dans `profiles.yml` pointe vers un fichier `.duckdb` inexistant ou vide
5. **`Table with name "schema.table" does not exist because schema "X" does not exist`** → le bon fichier `.duckdb` est chargé, mais les données brutes n'y ont jamais été créées

**Astuce généralisable** : toujours vérifier le SQL compilé avant de creuser plus loin :
```bash
cat target/compiled/greenweez_dbt/models/staging/stg_gwz_sales.sql
```
Ça montre exactement le SQL final envoyé à DuckDB — souvent l'erreur saute aux yeux immédiatement (nom de colonne, nom de table, syntaxe).

---

## 6. Checklist de démarrage d'un nouveau projet dbt

À faire dans cet ordre pour éviter les allers-retours vécus aujourd'hui :

- [ ] `dbt_project.yml` : vérifier `name:` et `profile:` (doivent matcher `profiles.yml`)
- [ ] `~/.dbt/profiles.yml` : `path:` pointe vers le bon fichier `.duckdb`, celui qui contient réellement les données
- [ ] Vérifier que le fichier `.duckdb` a bien les schémas/tables attendus : `duckdb mon_fichier.duckdb` puis `.tables`
- [ ] `models/.../sources.yml` : `name:` de la source + `schema:` DuckDB + liste des `tables:`
- [ ] Premier modèle staging : `{{ source('nom_source', 'nom_table') }}` avec guillemets
- [ ] `+materialized:` toujours au singulier (`view`, pas `views`)
- [ ] `dbt run --select mon_premier_modele` pour valider la chaîne complète avant d'enchaîner

---

*Fiche générée à partir d'une session de debug réelle — garde-la comme référence pour tes prochains projets dbt (le module suivant du Wagon, ou ton portfolio banking).*
