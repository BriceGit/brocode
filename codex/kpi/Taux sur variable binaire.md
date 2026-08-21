# Taux sur variable binaire

> **Toute question « quel pourcentage de X vérifie la condition C ? » se résout par une moyenne sur un indicateur 0/1.** Un pattern, une ligne de code, et il couvre la moitié des KPI de taux qu'on te demandera.

---

## 🎯 Le principe

Sur une colonne qui ne contient que des `1` et des `0` :

```
AVERAGE(colonne)  =  SUM(colonne) / COUNT(colonne)
                  =  nb de 1 / nb total de lignes
                  =  le taux
```

La démonstration tient en une ligne : la somme d'une colonne binaire **est** le comptage des `1`. Donc la moyenne **est** la proportion.

```
=AVERAGE(in_stock)        →  taux de disponibilité   (0.75)
=1 - AVERAGE(in_stock)    →  taux de rupture         (0.25)
```

Une seule fonction. Pas de `COUNTIF`, pas de sous-requête, pas de `CASE WHEN` imbriqué.

---

## 💻 Implémentation par outil

**Google Sheets**

```
=AVERAGE(C2:C)              // taux de disponibilité
=1 - AVERAGE(C2:C)          // taux de rupture

// alternative verbeuse, à éviter
=COUNTIF(C2:C; 0) / COUNTA(C2:C)
```

**SQL / BigQuery**

```sql
-- booléen natif
AVG(CAST(in_stock AS INT64))                     AS availability_rate
COUNTIF(in_stock) / COUNT(*)                     AS availability_rate

-- avec sécurisation du dénominateur (réflexe systématique)
SAFE_DIVIDE(COUNTIF(NOT in_stock), COUNT(*))     AS shortage_rate

-- condition à la volée, sans colonne binaire préexistante
AVG(IF(status = 'churned', 1, 0))                AS churn_rate
```

**pandas**

```python
# un booléen pandas EST un 0/1 déguisé
df["in_stock"].mean()          # taux de disponibilité
1 - df["in_stock"].mean()      # taux de rupture

# condition à la volée
(df["status"] == "churned").mean()

# segmenté
df.groupby("category", as_index=False)["in_stock"].mean()
```

**DAX (Power BI)**

```dax
Availability Rate = AVERAGE( Products[in_stock] )

// condition à la volée
Churn Rate = DIVIDE( CALCULATE( COUNTROWS(Customers), Customers[status] = "churned" ),
                     COUNTROWS(Customers) )
```

**dbt** — matérialiser la colonne binaire dans un modèle intermédiaire rend le taux calculable partout en aval :

```sql
select
    product_id,
    category,
    case when stock_quantity > 0 then 1 else 0 end as is_in_stock
from {{ ref('stg_products') }}
```

---

## ⚠️ Piège 1 — les valeurs vides changent le dénominateur

Le piège qui casse l'astuce, et il est **totalement silencieux**.

> [!warning] `AVERAGE` / `AVG` exclut les valeurs vides du dénominateur
> Colonne `in_stock` : 100 lignes, dont 10 vides et 63 à `1`.
>
> - Ce que tu crois calculer : `63 / 100 = 63 %`
> - Ce qui est calculé : `63 / 90 = 70 %`
>
> **7 points d'écart, aucun message d'erreur.**

Le comportement est cohérent avec la sémantique : une cellule vide n'est pas un zéro, elle est **inconnue**. Statistiquement, l'exclure est même le choix correct. Le problème n'est pas le comportement de la fonction, c'est de ne pas savoir qu'il existe.

**Réflexe systématique avant tout `AVERAGE` sur du binaire :**

```sql
-- SQL : les deux doivent être égaux
SELECT COUNT(in_stock) AS non_null, COUNT(*) AS total FROM products
```
```
-- Sheets : les deux doivent être égaux
=COUNT(C2:C)    vs    =COUNTA(C2:C)
```
```python
# pandas
df["in_stock"].isna().sum()   # doit valoir 0
```

Et si des vides existent, **trancher explicitement** — jamais par défaut :

| Décision | Traduction | Quand |
|---|---|---|
| Les exclure | `AVG()` tel quel | La donnée est réellement inconnue |
| Les compter comme `0` | `COALESCE(in_stock, 0)` / `.fillna(0)` | L'absence signifie « non » |
| Les isoler | Les compter à part et le signaler | Toujours, en plus du reste |

> [!important] C'est le même sujet que « une valeur manquante n'est pas un zéro »
> Google Sheets traite une cellule vide comme `0` dans une opération arithmétique directe (`=A1+A2`) mais **l'ignore** dans `AVERAGE`. Deux comportements opposés dans le même outil. En SQL, `NULL` se propage dans l'arithmétique et est ignoré par les agrégats. Il faut connaître le comportement de chaque fonction, pas en déduire une règle générale.

---

## ⚠️ Piège 2 — le dénominateur, c'est le total

L'erreur la plus fréquente, et celle du quiz du cours :

```
❌  taux de rupture = nb en rupture / nb en stock          →  1/3 = 33 %
✅  taux de rupture = nb en rupture / nb TOTAL             →  1/4 = 25 %
```

Le dénominateur est **la population entière**, pas la catégorie complémentaire. Le test de cohérence est immédiat :

> **Si les deux taux complémentaires ne font pas exactement 1, le dénominateur est faux.**

`25 % + 75 % = 100 %` ✅ · `33 % + 75 % = 108 %` ❌

---

## ⚠️ Piège 3 — l'unité de comptage

Un taux binaire compte des **lignes**. Encore faut-il savoir ce qu'est une ligne.

Sur le shortage rate : on compte des **références produits**, pas des unités en stock ni de la valeur de stock. Un produit avec 1 unité restante et un produit avec 10 000 unités comptent tous les deux pour `1`.

| Ce qu'on compte | Question à laquelle ça répond |
|---|---|
| Références en rupture / total références | *Quelle part de mon catalogue est indisponible ?* |
| Unités manquantes / unités théoriques | *Quel est mon taux de service en volume ?* |
| Valeur des ruptures / valeur du catalogue | *Quel CA je ne peux pas réaliser ?* |

Trois questions différentes, trois chiffres différents, et une seule est demandée. Voir [[Granularité d'une table]] : **avant de calculer un taux, savoir ce qu'une ligne représente**.

---

## ⚠️ Piège 4 — quand la moyenne simple ne suffit plus

L'astuce marche uniquement si **chaque ligne pèse le même poids**. Dès qu'il faut pondérer, il faut repasser en ratio explicite :

```sql
-- taux non pondéré : chaque commande compte pour 1
AVG(CAST(is_refunded AS INT64))

-- taux pondéré par le CA : chaque commande compte pour son montant
SAFE_DIVIDE(
  SUM(IF(is_refunded, turnover, 0)),
  SUM(turnover)
)
```

Un taux de retour de 6 % **en volume** et de 6 % **en valeur** ne racontent pas la même histoire : 6 % portés par un seul produit cher ≠ 6 % portés par des centaines de petites commandes. C'est [[Aggregate before divide]] sous un autre angle — la moyenne des indicatrices est un cas particulier où numérateur et dénominateur ont le même poids par ligne.

---

## ⚠️ Piège 5 — un taux sur 4 lignes n'est pas un taux

Sur un petit dénominateur, un taux est instable et trompeur. `1 rupture sur 4 références = 25 %` — mais une rupture de plus fait passer à 50 %.

**Réflexe** : toujours afficher **le taux ET le dénominateur** à côté. `25 % (1/4)` se lit correctement ; `25 %` seul induit en erreur. C'est valable sur tout dashboard segmenté : une catégorie à 100 % de rupture avec 2 références n'est pas un incident majeur.

---

## 🧰 Cas d'usage — le même pattern partout

| Taux | Colonne binaire | Domaine |
|---|---|---|
| Taux de rupture | `in_stock` | Supply chain |
| Taux de churn | `is_churned` | Rétention |
| Taux de conversion | `has_converted` | Marketing / produit |
| Taux de retour | `is_refunded` | Qualité |
| Taux de réachat | `is_repeat_customer` | Fidélité |
| **Taux de complétude KYC** | `is_kyc_complete` | **Conformité bancaire** |
| **Taux de STP** | `is_straight_through` | **Ops bancaires** |
| **Taux de breach SLA** | `sla_breached` | **Ops / service** |

---

## 🎤 En entretien

**« Comment tu calcules un taux ? »**
→ Une colonne indicatrice 0/1, puis une moyenne. Mais je vérifie deux choses avant : que le dénominateur est bien la population totale et pas la catégorie complémentaire, et qu'il n'y a pas de valeurs manquantes qui rétrécissent silencieusement le dénominateur.

**« Ton taux de rupture est à 0,93 %, c'est bien ? »**
→ Impossible à dire sans trois choses : la cible, l'évolution vs la période précédente, et la segmentation. Un 0,93 % global peut cacher une catégorie à 12 %, et c'est celle-là qui déclenche l'action.

---

## 🔗 Liens

- Chapitre source : [[KPI Basics]]
- [[Aggregate before divide]] — le cas général dont ce pattern est un cas particulier
- [[Granularité d'une table]] — savoir ce qu'une ligne représente avant de la compter
- [[KPI vs métrique]] — un taux devient un KPI quand on lui accroche une cible
- [[NPS (Net Promoter Score)]] — un taux composite qui, lui, ne se calcule PAS avec ce pattern
