# Reporting vs analyse ad hoc

> Deux demandes qui se ressemblent à l'oral et qui ne produisent pas du tout le même livrable. Se tromper là-dessus, c'est refaire le travail.

---

## 📊 Le tableau

| | **Reporting** | **Analyse ad hoc** |
|---|---|---|
| Verbe | **Monitorer** des KPI récurrents | **Investiguer** un problème spécifique |
| Question type | *Où en est-on ?* | *Pourquoi ça a bougé ?* |
| Exemple | Marge opérationnelle quotidienne | *Pourquoi la marge a chuté le 5 octobre ?* |
| Temporalité | Continu, actualisé | Ponctuel, one-shot |
| Profondeur | Reste en **surface**, par construction | Va chercher les **causes** derrière le chiffre |
| Livrable | Un dashboard **qui vit** | Une analyse **qui conclut** |
| Durée de vie | Des mois, des années | La réunion où elle est présentée |
| EDA | Utile | **Obligatoire** |
| Critère de succès | Fiabilité, fraîcheur, disponibilité | Justesse de la réponse |

---

## 🔄 La boucle : ils s'enchaînent, ils ne s'opposent pas

```
   Reporting  ──détecte l'anomalie──▶  Analyse ad hoc
       ▲                                     │
       │                                 explique
       │                                     │
       └────ajoute un nouvel indicateur──────┘
```

Le dashboard de suivi montre une baisse le 5 octobre. Ça déclenche une investigation ad hoc. L'investigation découvre que la cause est une hausse des coûts de transport sur une zone. Conclusion : on ajoute un suivi du coût logistique par zone au reporting. **Boucle.**

C'est aussi la raison pour laquelle un reporting bien fait doit **laisser l'utilisateur explorer** (filtres, drill-down) : il absorbe une partie des demandes ad hoc avant qu'elles n'arrivent jusqu'à toi.

---

## ❓ Comment trancher avec le demandeur

La question à poser mot pour mot :

> **« Tu veux un suivi dans le temps, ou tu veux une explication ? »**

Et les questions de suivi qui tuent l'ambiguïté :

| Question | Reporting si… | Ad hoc si… |
|---|---|---|
| « Tu vas le regarder à quelle fréquence ? » | toutes les semaines | une fois |
| « Ça doit s'actualiser tout seul ? » | oui | peu importe |
| « Qui d'autre va le consulter ? » | plusieurs équipes | toi seul / ton N+1 |
| « Il te le faut pour quand ? » | pas d'urgence, mais durable | pour la réunion de jeudi |

> [!warning] Le piège du glissement silencieux
> Une analyse ad hoc bien reçue devient très souvent une demande de reporting : *« super, tu peux me le mettre à jour tous les mois ? »*. Le problème : elle a été construite **en jetable** — requête bricolée, copier-coller en dur, aucun test. La reprendre en pipeline coûte plus cher que de l'avoir faite proprement.
>
> Réflexe : dès qu'une analyse ad hoc touche un sujet stratégique, écrire la requête comme si elle allait être industrialisée. Le surcoût est de 20 %, l'économie potentielle de 300 %.

---

## 🏗️ Ce que ça change techniquement

| | **Reporting** | **Ad hoc** |
|---|---|---|
| Où vit le code | Modèle **dbt** versionné, planifié | Notebook, requête ponctuelle |
| Source | Pipeline automatisé (Fivetran → BigQuery → dbt) | Export, CSV, requête directe |
| Tests | `not_null`, `unique`, tests de conservation | Vérifications manuelles |
| Nettoyage | À la **source**, réutilisable | Suffisant pour la question posée |
| Documentation | Obligatoire (définitions, propriétaire, fraîcheur) | Les hypothèses dans le livrable |
| Erreur acceptable | ❌ aucune, ça pilote des décisions en continu | ⚠️ signalée et bornée |
| Outil de restitution | Looker Studio / Power BI | Slide, notebook, note écrite |

> [!important] Le reporting est un produit, l'ad hoc est un service
> Un dashboard a des utilisateurs, une maintenance, des régressions et une dette. Une analyse ad hoc est livrée puis oubliée. La charge de travail cachée n'est pas du tout la même — et c'est ce qu'un junior sous-estime systématiquement en s'engageant sur « je te fais un petit dashboard ».

---

## 🎯 Impact sur la méthodologie

Dans le [[KPI Basics|framework en 7 étapes]], le choix du type d'analyse est **l'étape 3**, juste après le sourcing de la donnée. Il conditionne tout l'aval :

| Étape | En reporting | En ad hoc |
|---|---|---|
| **4. Exploration** | Utile, cadrée | **Obligatoire et large** — c'est là que se trouve la réponse |
| **5. Cleaning** | Automatisé, exhaustif sur les colonnes du modèle | Ciblé sur les colonnes de la question |
| **6. Summary** | Les KPI *sont* la synthèse | Un insight priorisé + les preuves |
| **7. Visualization** | Dashboard interactif, filtrable | 2–3 graphes qui portent la démonstration |
| **Itération** | Enrichissement continu, V0 → V1 → V2 | Une passe, éventuellement une relance |

---

## 🧩 Le troisième type dont personne ne parle

Le cours en distingue deux. En pratique il y en a un troisième, qui arrive plus tard dans le cursus :

| Type | Question | Sortie |
|---|---|---|
| Reporting | *Que se passe-t-il ?* (descriptif) | Un chiffre suivi |
| Ad hoc | *Pourquoi ?* (diagnostic) | Une explication |
| **Prédictif / prescriptif** | *Que va-t-il se passer ? Que faire ?* | Un modèle, une recommandation |

C'est exactement la progression `descriptif → diagnostic → prédictif → prescriptif`, et c'est aussi l'argument de différenciation de ton projet portfolio banking : passer du descriptif (taux de churn constaté) au prédictif (score de risque de churn par client).

---

## 🎤 En entretien

**« Comment tu abordes une nouvelle demande d'analyse ? »**
→ 5W+H pour le scoping, puis immédiatement : reporting ou ad hoc ? Parce que ça détermine si je construis un pipeline ou si je réponds à une question. Les deux ne se travaillent pas pareil et ne coûtent pas le même temps.

**« Tu fais quoi si on te demande un dashboard pour hier ? »**
→ Je livre une V0 exploitable et je le dis. Un dashboard imparfait en production vaut mieux qu'un dashboard parfait bloqué trois semaines. L'itération vient après, avec les retours des utilisateurs.

---

## 🔗 Liens

- Chapitre source : [[KPI Basics]]
- [[KPI vs métrique]] — le reporting expose des KPI, l'ad hoc mobilise des métriques
- [[Aggregate before divide]] — le piège de calcul qui survit à l'ad hoc et contamine le reporting
