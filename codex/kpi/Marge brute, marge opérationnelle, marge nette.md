# Marge brute, marge opérationnelle, marge nette

> Trois étages du même escalier. Chacun répond à une question différente, et l'écart entre deux étages est toujours plus informatif que les étages eux-mêmes.

---

## 🪜 La cascade du compte de résultat

```
Chiffre d'affaires  (CA / revenue / turnover)
  − coûts directs (achat des marchandises, production)
  ═══════════════════════════════════════════════
  = MARGE BRUTE  (gross margin / gross profit)
      − charges d'exploitation (salaires, marketing, logistique, loyers, amortissements)
      ═══════════════════════════════════════════
      = RÉSULTAT D'EXPLOITATION  (operating income / EBIT)
          − charges financières
          − impôts
          ═══════════════════════════════════════
          = RÉSULTAT NET  (net income)   ← la dernière ligne, elle englobe tout
```

---

## 📊 Les trois niveaux

| | **Marge brute** | **Marge opérationnelle** | **Marge nette** |
|---|---|---|---|
| Formule | CA − coûts directs | Marge brute − charges d'exploitation | Résultat d'exploitation − financier − impôts |
| Anglais | Gross margin | Operating margin / EBIT margin | Net margin / net income |
| Ce que ça mesure | L'efficacité de **l'achat ou de la production** | La rentabilité du **modèle opérationnel** | Ce qui reste **réellement** |
| Qui pilote | Achats, pricing | Ops, direction générale | Direction financière |
| Signal d'alerte | Basse → problème de sourcing ou de prix de vente | Négative alors que la marge brute est bonne → **la structure de coûts mange tout** | Négative alors que l'EBIT est positif → dette ou fiscalité |
| Levier d'action | Renégocier fournisseurs, augmenter les prix | Optimiser la logistique, les frais fixes | Refinancer, optimisation fiscale |

> [!important] Le diagnostic le plus utile : l'écart entre deux étages
> **Marge brute correcte + marge opérationnelle négative** = le produit est rentable, l'entreprise ne l'est pas. C'est **le** problème structurel du e-commerce : la marge produit existe, la logistique et l'expédition la détruisent.
>
> Un seul chiffre de « marge » globale masque totalement ce diagnostic. C'est exactement pour ça qu'on décompose.

---

## 🧮 Vocabulaire adjacent

| Terme | Définition | Piège |
|---|---|---|
| **COGS** | *Cost of Goods Sold* — les coûts directs | Ne contient **que** ce qui est directement attribuable au produit vendu |
| **EBITDA** | Résultat avant intérêts, impôts, dépréciation et amortissement | Souvent mis en avant parce qu'il flatte : il exclut l'amortissement des investissements |
| **EBIT** | Résultat d'exploitation = EBITDA − amortissements | ≈ marge opérationnelle |
| **Contribution margin** | CA − coûts **variables** | ≠ marge brute : le découpage est variable/fixe, pas direct/indirect |

---

## 🌿 Le cas Greenweez — définition simplifiée

Dans le dataset du bootcamp, les formules sont volontairement réduites au périmètre disponible :

```
Gross Margin      = (turnover + ship fee) − purchase costs
Operating Margin  = gross margin − (logistics costs + ship costs)
```

Les cinq postes :

| Poste | Nature | Sens |
|---|---|---|
| `turnover` | Revenu | Vente du produit |
| `ship fee` | **Revenu** | Frais de port **facturés au client** |
| `purchase cost` | Coût direct | Prix payé au fournisseur |
| `ship cost` | **Charge** | Prix payé **au transporteur** |
| `logistics cost` | Charge | Préparation, entrepôt, manutention |

> [!warning] `ship fee` ≠ `ship cost`
> Même préfixe, sens opposés, et les deux apparaissent dans les formules. `ship fee` est un **revenu** (il entre dans la marge brute), `ship cost` est une **charge** (il en sort au niveau opérationnel). L'écart entre les deux est un mini-centre de profit à part entière : le client paie 10 € de port, le transporteur en coûte 7 € → 3 € de marge sur le transport.
>
> Se tromper de colonne ici est une **erreur silencieuse** : le calcul tourne, le chiffre est plausible, il est faux.

> [!warning] La définition Greenweez n'est pas la définition comptable
> La marge opérationnelle réelle intègre **toutes** les charges d'exploitation : salaires, marketing, loyers, amortissements. Ici elle est réduite à `logistics + ship`, parce que c'est ce que contient le dataset.
>
> **Formulation sûre en entretien** : *« On a défini la marge opérationnelle comme la marge brute nette des coûts logistiques et d'expédition — c'était le périmètre qu'autorisait le dataset. La définition comptable complète intègre aussi les charges de structure. »* Tu montres que tu connais les deux **et** que tu sais adapter une définition à un périmètre de données.

---

## 💶 Marge en valeur vs taux de marge

Deux objets différents, deux usages différents :

| | Marge en **valeur** (€) | **Taux** de marge (%) |
|---|---|---|
| Formule | `CA − coûts` | `(CA − coûts) / CA` |
| Répond à | *Combien on gagne ?* | *Quelle est l'efficacité du modèle ?* |
| Additive | ✅ oui | ❌ **non** |
| Comparable entre entités de tailles différentes | ❌ non | ✅ oui |

> [!warning] Un taux de marge ne s'additionne pas et ne se moyenne pas
> Il se **recalcule** à chaque niveau d'agrégation, à partir des numérateurs et dénominateurs sommés.
>
> ```
> ❌  AVERAGE(marge_ligne / CA_ligne)   →  une commande à 5 € pèse autant qu'une à 5 000 €
> ✅  SUM(marge) / SUM(CA)              →  pondéré par le poids réel
> ```
>
> Voir [[Aggregate before divide]] — c'est le même piège, dans son incarnation la plus coûteuse.

> [!note] Tout se calcule hors taxe
> La TVA transite par la trésorerie mais n'appartient jamais à l'entreprise. L'inclure gonfle artificiellement le CA et écrase tous les taux de marge.

---

## 💻 Implémentation

**SQL / BigQuery**

```sql
SELECT
  DATE(order_date) AS day,
  SUM(turnover + ship_fee)                          AS revenue,
  SUM(turnover + ship_fee - purchase_cost)          AS gross_margin,
  SUM(turnover + ship_fee - purchase_cost
      - logistics_cost - ship_cost)                 AS operating_margin,
  -- agréger AVANT de diviser, et sécuriser le dénominateur
  SAFE_DIVIDE(
    SUM(turnover + ship_fee - purchase_cost),
    SUM(turnover + ship_fee)
  )                                                 AS gross_margin_rate
FROM `project.dataset.orders`
GROUP BY day
ORDER BY day
```

**pandas**

```python
agg = (
    df.assign(
        revenue          = df["turnover"] + df["ship_fee"],
        gross_margin     = df["turnover"] + df["ship_fee"] - df["purchase_cost"],
    )
    .assign(
        operating_margin = lambda d: d["gross_margin"] - d["logistics_cost"] - d["ship_cost"]
    )
    .groupby("order_date", as_index=False)[["revenue", "gross_margin", "operating_margin"]]
    .sum()
)
# le taux se calcule APRÈS le groupby, sur les agrégats
agg["gross_margin_rate"] = agg["gross_margin"] / agg["revenue"]
```

**DAX (Power BI)**

```dax
Revenue          = SUM(Orders[turnover]) + SUM(Orders[ship_fee])
Gross Margin     = [Revenue] - SUM(Orders[purchase_cost])
Operating Margin = [Gross Margin] - SUM(Orders[logistics_cost]) - SUM(Orders[ship_cost])

// DIVIDE gère le dénominateur nul, contrairement à l'opérateur /
Gross Margin Rate = DIVIDE( [Gross Margin], [Revenue] )
```

Les mesures DAX sont **naturellement correctes** sur ce piège : elles s'évaluent dans le contexte de filtre courant, donc `DIVIDE([Gross Margin], [Revenue])` fait bien `SUM/SUM` à chaque niveau. C'est un champ calculé de **colonne** (ligne à ligne) qui casserait tout.

**Google Sheets — champ calculé de TCD**

```
Formule    : = (turnover + ship_fee - purchase_cost) / (turnover + ship_fee)
Summarize by : Custom        ← évalue sur les agrégats du groupe ✅
               SUM           ← somme les ratios ligne à ligne ❌
```

---

## 🏦 Transposition banque privée

| Concept e-commerce | Équivalent bancaire | Note |
|---|---|---|
| Marge brute | **Net Interest Margin (NIM)** — produits d'intérêt − coût de refinancement, rapporté aux actifs | Le « produit » d'une banque, c'est l'argent |
| Marge brute (commissions) | **Marge sur commissions de gestion** — fees sur AuM − rétrocessions | Cœur du modèle wealth management |
| Marge opérationnelle | **Cost/Income ratio** = charges d'exploitation / produit net bancaire | ⚠️ Se lit **à l'envers** : plus bas = mieux |
| CA | **Produit Net Bancaire (PNB)** / *net banking income* | L'équivalent du chiffre d'affaires |
| Résultat net | Résultat net, ROE | Idem |

> [!tip] Le cost/income ratio est LE KPI de la banque privée genevoise
> C'est l'indicateur que tout le secteur suit, et il est structurellement élevé en gestion de fortune (modèle à forte intensité humaine). Savoir qu'il se lit à l'envers — et pouvoir le relier conceptuellement à une marge opérationnelle — est exactement le genre de détail qui montre que tu as compris le secteur, pas juste appris une formule.

---

## 🎤 En entretien

**« Ta marge brute est bonne mais ton résultat opérationnel est négatif. Que fais-tu ? »**
→ La marge produit existe, ce sont les coûts indirects qui la détruisent. Je décompose par nature de coût (logistique vs expédition), puis je segmente par catégorie produit, zone géographique et mode de livraison. En e-commerce, le suspect n°1 est le petit panier avec livraison gratuite.

**« Comment tu calcules un taux de marge sur un mois ? »**
→ `SUM(marge) / SUM(CA)` sur la période, jamais la moyenne des taux journaliers. Sinon un jour à 200 € de CA pèse autant qu'un jour à 200 000 €.

**« Pourquoi décomposer la marge en plusieurs niveaux ? »**
→ Parce que l'écart entre deux niveaux localise le problème. Un chiffre unique dit qu'il y a un problème ; la cascade dit **où**.

---

## 🔗 Liens

- Chapitre source : [[KPI Basics]]
- [[Aggregate before divide]] — le piège du taux de marge, cas d'école du principe
- [[KPI vs métrique]] — la marge en valeur est une métrique, le taux de marge vs budget est un KPI
- [[Granularité d'une table]] — à quelle maille les coûts logistiques sont-ils disponibles ? (commande, ligne de commande, colis)
