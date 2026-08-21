# NPS (Net Promoter Score)

> L'indicateur de satisfaction le plus utilisé au monde, et l'un des plus mal calculés. Il tombe très souvent en entretien parce qu'il a deux pièges que presque personne ne connaît.

---

## 🎯 Définition

Sur une question unique — **« Recommanderiez-vous [entreprise/produit] à un proche ? »**, notée de 0 à 10 — les répondants sont segmentés en trois groupes :

| Segment | Note | Traitement |
|---|---|---|
| 😠 **Détracteurs** | **0 – 6** | Comptés **négativement** |
| 😐 **Passifs** *(passives / neutres)* | **7 – 8** | **Exclus du calcul** — mais pas de la base |
| 😃 **Promoteurs** | **9 – 10** | Comptés **positivement** |

```
NPS = % de promoteurs − % de détracteurs
```

Les deux pourcentages sont calculés **sur le total des répondants**, passifs inclus au dénominateur.

**Exemple sur 200 réponses :**

| | Nb | % du total |
|---|---|---|
| Promoteurs (9–10) | 90 | 45 % |
| Passifs (7–8) | 70 | 35 % |
| Détracteurs (0–6) | 40 | 20 % |
| **Total** | **200** | 100 % |

```
NPS = 45 − 20 = 25
```

---

## ⚠️ Les deux pièges

> [!warning] Piège 1 — le NPS n'est PAS un pourcentage
> Malgré une formule qui soustrait deux pourcentages, le résultat s'exprime **en points**, sur une échelle de **−100 à +100**.
>
> - ❌ « On a un NPS de 25 % »
> - ✅ « On a un NPS de 25 »
>
> −100 = tout le monde est détracteur. +100 = tout le monde est promoteur. `0` est déjà un score neutre, pas un mauvais score au sens absolu.

> [!warning] Piège 2 — les passifs pèsent au dénominateur mais dans aucun terme
> Ils diluent les deux pourcentages sans jamais apparaître dans la soustraction. Conséquence : **deux distributions radicalement différentes peuvent produire le même NPS**.
>
> | | Entreprise A | Entreprise B |
> |---|---|---|
> | Promoteurs | 40 % | 70 % |
> | Passifs | 45 % | 5 % |
> | Détracteurs | 15 % | 25 % |
> | **NPS** | **25** | **45** |
>
> …et à l'inverse, A avec 30/65/5 et B avec 55/15/30 donnent toutes les deux **25**. Une base tiède et une base polarisée, indistinguables au NPS seul.

---

## 🧩 Pourquoi c'est l'exemple canonique du KPI

Le NPS illustre parfaitement le couple KPI / métrique :

```
NPS = 25                        ← LE KPI     : « on est où par rapport à la cible ? »
  ├── % promoteurs = 45 %       ← métriques  : « pourquoi ? »
  ├── % passifs    = 35 %
  ├── % détracteurs = 20 %
  └── distribution complète 0→10
```

**Le KPI seul est structurellement insuffisant** : sans la distribution, tu ne sais pas si tu dois convertir des passifs en promoteurs (base tiède) ou éteindre des détracteurs (base polarisée). Deux plans d'action opposés pour un score identique.

C'est la meilleure démonstration de [[KPI vs métrique]] : le KPI est la porte d'entrée, la métrique explique.

---

## 💻 Calcul

**SQL / BigQuery**

```sql
SELECT
  SAFE_DIVIDE(COUNTIF(score >= 9), COUNT(*)) * 100
  - SAFE_DIVIDE(COUNTIF(score <= 6), COUNT(*)) * 100   AS nps,
  COUNT(*)                                             AS n_responses,   -- toujours l'afficher
  COUNTIF(score >= 9)                                  AS promoters,
  COUNTIF(score BETWEEN 7 AND 8)                       AS passives,
  COUNTIF(score <= 6)                                  AS detractors
FROM `project.dataset.survey`
WHERE score IS NOT NULL          -- décision explicite sur les non-répondants
```

**pandas**

```python
def nps(scores: pd.Series) -> float:
    s = scores.dropna()
    return 100 * ((s >= 9).mean() - (s <= 6).mean())

nps(df["score"])
df.groupby("segment")["score"].apply(nps)   # segmenté
```

**DAX**

```dax
NPS =
VAR Total      = COUNTROWS( Survey )
VAR Promoters  = CALCULATE( COUNTROWS(Survey), Survey[score] >= 9 )
VAR Detractors = CALCULATE( COUNTROWS(Survey), Survey[score] <= 6 )
RETURN
    100 * ( DIVIDE(Promoters, Total) - DIVIDE(Detractors, Total) )
```

> [!note] Ce n'est PAS un [[Taux sur variable binaire]]
> Le NPS a **trois** catégories, dont une exclue du numérateur mais présente au dénominateur. L'astuce `AVERAGE` sur 0/1 ne s'applique pas — il faut deux comptages distincts sur la même base. C'est le contre-exemple utile à garder en tête pour ne pas appliquer le pattern mécaniquement.

---

## 🚩 Les limites (à connaître, elles arrivent en question de suivi)

| Critique | Détail |
|---|---|
| **Perte d'information** | Une note de 0 et une note de 6 comptent identiquement. Un client furieux et un client mitigé, même poids |
| **Seuils arbitraires** | Pourquoi 9 et non 8 ? Le découpage 0-6 / 7-8 / 9-10 est une convention, pas un résultat statistique |
| **Sensible à la taille d'échantillon** | Sur 30 réponses, quelques détracteurs font bouger le score de 15 points. **Toujours afficher n** |
| **Biais de non-réponse** | Ceux qui répondent sont les très satisfaits et les très mécontents. Le milieu se tait |
| **Biais culturels** | Les échelles de notation ne sont pas utilisées de la même façon selon les pays — un NPS n'est pas comparable tel quel entre marchés |
| **Benchmark trompeur** | Les niveaux « normaux » varient énormément selon le secteur. Comparer son NPS à un chiffre générique n'a aucun sens ; seul un benchmark **sectoriel** est exploitable |

> [!tip] La bonne pratique
> Suivre **l'évolution de son propre NPS dans le temps** et sa **segmentation** (par produit, par canal, par ancienneté client) plutôt que sa valeur absolue comparée à l'extérieur. Et coupler systématiquement avec la question ouverte « pourquoi cette note ? » — c'est le verbatim qui rend le score actionnable, pas le score.

---

## 🔄 Les alternatives

| Indicateur | Question | Mesure |
|---|---|---|
| **NPS** | *Recommanderiez-vous ?* | La **fidélité / l'advocacy**, sur la relation globale |
| **CSAT** *(Customer Satisfaction Score)* | *Êtes-vous satisfait de [cette interaction] ?* | La satisfaction **transactionnelle**, à chaud |
| **CES** *(Customer Effort Score)* | *Quel effort avez-vous dû fournir ?* | La **friction** d'un parcours |

Les trois sont complémentaires : NPS pour la santé relationnelle long terme, CSAT après un contact support, CES sur un tunnel ou un process.

---

## 🏦 En banque privée

Le NPS est très utilisé en wealth management, où la relation client est le produit. Points de vigilance spécifiques :

- **Échantillons petits** — un gérant suit quelques dizaines de clients. Le n est structurellement faible, le score très instable
- **Segmentation par tranche d'AuM** — le NPS des grands comptes n'a rien à voir avec celui de la clientèle affluent, et ce sont deux plans d'action différents
- **Corrélation avec le Net New Money** — c'est le croisement qui intéresse vraiment la direction : est-ce que la satisfaction se traduit en apports et en recommandations ?

---

## 🎤 En entretien

**« Comment se calcule un NPS ? »**
→ % promoteurs (9–10) − % détracteurs (0–6), sur l'ensemble des répondants. Les passifs (7–8) sont exclus des deux termes mais comptent au dénominateur. Le résultat est un score de −100 à +100, **pas un pourcentage**.

**« Quelle est sa principale limite ? »**
→ Il écrase l'information : un 0 et un 6 comptent pareil, et deux distributions très différentes donnent le même score. Il faut toujours l'accompagner de la distribution complète et des verbatims.

**« Un NPS de 25, c'est bon ? »**
→ Impossible à dire sans le secteur, la taille d'échantillon et l'évolution. Ce qui m'intéresse, c'est la tendance et la segmentation, pas la valeur absolue.

---

## 🔗 Liens

- Chapitre source : [[KPI Basics]]
- [[KPI vs métrique]] — le NPS est l'exemple le plus net d'un KPI inutilisable sans ses métriques
- [[Taux sur variable binaire]] — le contre-exemple : trois catégories, le pattern ne s'applique pas
