# KPI vs métrique

> Tout KPI est une métrique. L'inverse est faux. Ce qui les sépare n'est pas la nature du chiffre, c'est **ce qu'on y accroche**.

---

## 🎯 En une phrase

Une **métrique** décrit ce qui se passe. Un **KPI** dit si ce qui se passe est acceptable **au regard d'un objectif**.

Le même chiffre peut être l'un ou l'autre selon le contexte. `4 200 commandes ce mois-ci` est une métrique dans un rapport d'activité, et un KPI si l'objectif mensuel est de 5 000.

---

## 📊 Le tableau

| | **KPI** | **Métrique** |
|---|---|---|
| Question | *Are we on track?* | *What's happening and why?* |
| Nature | Un **objectif** à atteindre | Une **valeur** à monitorer |
| Rôle | Suit la progression vers un objectif business | Décrit l'activité opérationnelle |
| Dimension | **Stratégique** | **Opérationnelle** |
| Lecture | Sujet à **interprétation** | Lecture **littérale** |
| Owner | Le métier (jamais le Data Analyst) | Souvent personne en particulier |
| Nombre | 3–5 par dashboard | Autant que nécessaire |
| Exemple | Taux de satisfaction vs cible de 90 % | Nombre de réponses à 5/5, 4/5, 3/5… |

---

## 🧪 Le test pratique : « et alors ? »

Le seul test qui compte. Tu énonces le chiffre, puis tu réponds à « et alors ? ».

- **« On a 12 400 visiteurs uniques ce mois. » → Et alors ?** → *…* → **métrique** (et probablement une *vanity metric*).
- **« Notre taux de conversion est à 1,8 %, l'objectif est 2,5 %, on perd 0,3 pt depuis le lancement du nouveau tunnel. » → Et alors ?** → on gèle le déploiement et on investigue → **KPI**.

Un KPI **déclenche une décision**. S'il n'en déclenche aucune quelle que soit sa valeur, ce n'est pas un KPI, c'est de la décoration.

---

## 🧱 Les trois composants d'un KPI

Un chiffre seul n'est jamais un KPI. Il lui faut :

```
KPI = chiffre  +  objectif  +  point de comparaison
```

| Composant | Sans lui | Exemple |
|---|---|---|
| **Le chiffre** | rien à mesurer | `18 490 €` de marge brute |
| **L'objectif** | on ne sait pas si c'est bien | cible à `20 000 €/jour` |
| **La comparaison** | on ne sait pas si ça bouge | `↓ -900 €` vs la veille |

Les trois axes de comparaison à toujours envisager :

| Comparaison | Ce qu'elle révèle |
|---|---|
| **vs période précédente** (J-1, M-1, N-1) | la tendance |
| **vs objectif / budget** | l'atteinte |
| **vs segment** (région, produit, équipe) | le benchmark interne |

> [!warning] Le sens du delta n'est pas le sens de la performance
> `↓ -0,05 %` sur un taux de rupture est une **bonne** nouvelle. `↓ -900 €` sur la marge est une mauvaise nouvelle. Sur un dashboard, la couleur du delta doit suivre **la performance**, pas le signe arithmétique — sinon tu affiches du rouge sur une amélioration. Dans Power BI c'est le paramètre *Invert colors* du KPI visual ; dans Looker Studio, une règle de mise en forme conditionnelle dédiée.

---

## 🔗 Le couple : le KPI ouvre, les métriques expliquent

C'est la relation la plus utile à avoir en tête pour construire un dashboard :

```
        KPI  ──────────────  « ça va mal »
         │
         ├── métrique 1  ─── « parce que la catégorie A a décroché »
         ├── métrique 2  ─── « et que le canal mobile a chuté »
         └── métrique 3  ─── « alors que le desktop est stable »
```

Un bon KPI ne répond pas à une question, **il en ouvre dix**. Un taux d'atteinte d'objectif à 87 % appelle immédiatement : à quelle date ? actualisé quand ? par région ? par produit ? par équipe ? Ces questions sont exactement la liste des métriques de décomposition à mettre sous le KPI.

Corollaire : **un KPI qu'on ne peut pas segmenter est un cul-de-sac**. Si tu ne peux pas descendre d'un cran, tu ne peux pas agir.

---

## 🧭 Exemples par département

| Département | KPI (stratégique) | Métriques de décomposition |
|---|---|---|
| Finance | Marge opérationnelle vs budget | CA, coûts d'achat, coûts logistiques, panier moyen |
| Stock / Logistique | Taux de rupture vs seuil toléré | Nb de références, nb en rupture, délai de réappro |
| Qualité | % du CA initial réalisé, NPS | Volume de retours, motifs de retour, notes 0–10 |
| Marketing | CAC vs LTV | Impressions, clics, CTR, coût par canal |
| **Banque privée** | **Cost/Income ratio**, Net New Money | AuM par gérant, produits d'intérêt, charges opérationnelles |
| **Conformité** | Taux de complétude KYC vs 100 % | Nb de dossiers, nb de champs manquants par type |

---

## 🚩 Anti-patterns

| Anti-pattern | Symptôme | Correctif |
|---|---|---|
| **Trop de KPI** | Dashboard à 20 cartes, personne ne sait où regarder | 3–5 max en haut, le reste en métriques dessous |
| **KPI sans owner** | Le chiffre est rouge depuis 6 mois, rien ne bouge | Un KPI sans nom en face n'existe pas |
| **KPI non actionnable** | « Et alors ? » sans réponse | Le remonter d'un cran ou le descendre en métrique |
| **Vanity metric** | Chiffre flatteur qui ne bouge jamais à la baisse (nb d'inscrits cumulés, followers) | Passer en taux, en flux, ou en variation |
| **KPI non segmentable** | Un chiffre global, aucun axe | Vérifier que les dimensions existent dans le modèle |
| **Définition non documentée** | Deux équipes annoncent deux chiffres différents | Une définition unique, versionnée, centralisée |

> [!important] Les KPI ne sont scrutés que quand ils vont mal
> Constat de terrain : un KPI satisfaisant, personne ne le regarde. C'est quand il devient mauvais que tout le monde se penche dessus — **et sur ta méthode de calcul**. D'où la règle : documente tes définitions avant qu'on te les demande, pas après.

---

## 🏗️ Où vit la définition d'un KPI

Le problème récurrent : le même KPI recalculé différemment dans trois outils, trois chiffres différents en réunion. La réponse est toujours la même — **remonter la définition le plus haut possible dans la chaîne**.

| Couche | Mécanisme | Portée |
|---|---|---|
| Tableur | Champ calculé de TCD | Le fichier |
| SQL / dbt | Modèle `mart`, ou couche `metrics` / semantic layer | Tous les outils branchés dessus ✅ |
| Power BI | Mesure DAX dans le modèle sémantique | Tous les rapports du modèle |
| Looker Studio | Champ calculé au niveau **source de données** (pas au niveau rapport) | Tous les rapports de la source |

C'est le même principe que « nettoyer à la source plutôt que dans l'outil de viz » : **une définition dupliquée est une définition qui divergera**.

---

## 🎤 En entretien

**« Quelle est la différence entre un KPI et une métrique ? »**
→ Le KPI est stratégique et adossé à un objectif, la métrique est opérationnelle et descriptive. Le KPI dit *si* on est sur la trajectoire, la métrique dit *pourquoi*. Ils sont complémentaires, pas concurrents.

**« Donne un exemple concret. »**
→ Le [[NPS (Net Promoter Score)]] est un KPI ; la distribution des notes de 0 à 10 est la métrique qui l'explique. Deux entreprises peuvent avoir le même NPS avec des distributions radicalement différentes — d'où la nécessité des deux.

**« Combien de KPI sur un dashboard ? »**
→ 3 à 5. Le critère de qualité d'un KPI n'est pas le nombre de questions auxquelles il répond, c'est le nombre de questions qu'il ouvre.

---

## 🔗 Liens

- Chapitre source : [[KPI Basics]]
- [[Reporting vs analyse ad hoc]] — le KPI vit dans le reporting, l'explication naît de l'ad hoc
- [[Marge brute, marge opérationnelle, marge nette]] — un cas où le même chiffre change de nature selon le niveau
- [[Taux sur variable binaire]] — la mécanique de calcul de la moitié des KPI de taux
- [[NPS (Net Promoter Score)]] — l'exemple canonique du KPI qui exige ses métriques
- [[Aggregate before divide]] — le piège de calcul le plus fréquent sur les KPI de type ratio
