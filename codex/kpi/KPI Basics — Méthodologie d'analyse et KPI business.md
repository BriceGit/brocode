---
title: "KPI Basics — Méthodologie d'analyse & premiers KPI business"
aliases:
  - "KPI Basics"
  - "KPI vs métrique"
  - "Méthodologie d'analyse en 7 étapes"
  - "5W + H"
  - "Reporting vs analyse ad hoc"
  - "Gross margin & operating margin"
  - "Shortage rate"
  - "% of initial turnover"
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 3
date: 2026-07-08
language: "Formules Google Sheets"
database: "n/a — tableur (Google Sheets)"
topics:
  - "KPI"
  - "Metrics"
  - "Data Analysis Workflow"
  - "Scoping"
  - "Reporting"
  - "Ad hoc analysis"
  - "Marges"
  - "Stock & rupture"
  - "Retours & qualité"
  - "Greenweez"
tags:
  - brocode
  - wagon2321/cours
  - kpi
  - business-analysis
  - google-sheets
---

# KPI Basics

> Première journée où le bootcamp arrête de parler d'outils et commence à parler de **métier**. Deux cours enchaînés le matin : la **méthodologie en 7 étapes** d'une analyse de données, puis les **KPI business**. L'après-midi, les trois challenges Greenweez (Finance / Stock / Qualité) qui produisent les premiers dashboards. Techniquement c'est encore du Google Sheets, mais tout ce qui est vu ici se rejoue à l'identique en SQL, en dbt, en DAX et en Python. C'est le socle conceptuel, pas un cours de tableur.

**Date :** 8 juillet 2026
**Format :** cours 1 (méthodologie, ~9h–10h05) + pause + cours 2 (KPI) + challenges jusqu'à 17h · promo de 8 personnes
**Intervenant :** intervenant externe (data analyst en poste, pas le formateur habituel — il reviendra ponctuellement dans le cursus)
**Dataset fil rouge :** **Greenweez** — utilisé aujourd'hui, demain, et bien au-delà
**Suite :** un **cours 2 sur les KPI** viendra plus tard dans le cursus

---

## 🎯 TL;DR

- **7 étapes** : `Why? → Data → Types of analysis → Exploration → Cleaning → Summary → Visualization`. Et une 8ᵉ implicite qui les englobe toutes : **l'itération**.
- **L'exploration vient AVANT le nettoyage** dans ce framework — contre-intuitif, mais logique : on explore pour savoir *quoi* nettoyer.
- **KPI ≠ métrique.** KPI = **stratégique**, adossé à un objectif, sujet à interprétation. Métrique = **opérationnel**, lecture littérale de la donnée. Les deux sont complémentaires : le KPI est la porte d'entrée, la métrique explique le pourquoi.
- **3 ou 4 KPI bien choisis > 20 indicateurs.** Un bon KPI ne répond pas à une question, il en ouvre dix.
- **Un chiffre seul n'est pas un KPI.** Il lui faut un **objectif** et un **point de comparaison** (période précédente, cible, segment). C'est tout le sens des petits `↓ -900€` sur les slides.
- **Gross margin** = `(turnover + ship fee) − purchase costs` · **Operating margin** = `gross margin − (logistics costs + ship costs)`. ⚠️ Définition *Greenweez*, pas la définition comptable standard — voir [[#⚠️ Attention — la définition Greenweez n'est pas la définition comptable]].
- **Shortage rate** = raisonnement **binaire** (une référence est en stock ou non, on ne compte pas les unités). Dénominateur = **le total**, jamais la catégorie complémentaire.
- **Astuce 0/1** : sur une colonne binaire, `AVERAGE()` renvoie directement le taux. `1 − AVERAGE(in_stock)` = taux de rupture. ⚠️ Piège des cellules vides : voir [[#⚠️ Le piège qui casse l'astuce — les cellules vides]].
- **% of initial turnover** = `(CA avant retours − CA retourné) / CA avant retours`. Son miroir, c'est le taux de retour.
- Le Data Analyst est **l'exécutant, pas le décideur**. L'owner du KPI, c'est le métier.

---

## 🗺️ Sommaire

- [[#🧭 1. La méthodologie en 7 étapes]]
- [[#📊 2. KPI vs métrique]]
- [[#💰 3. Challenge Finance — les marges]]
- [[#📦 4. Challenge Stock & Logistique — le shortage rate]]
- [[#✅ 5. Challenge Qualité — % of initial turnover]]
- [[#🛠️ 6. La couche Google Sheets]]
- [[#🏦 7. Transposition banking (hors cours)]]
- [[#🩹 8. Corrections & points d'attention sur le support]]
- [[#🎤 9. Angle entretien]]

---

## 🧭 1. La méthodologie en 7 étapes

Le framework central de la journée, et probablement le plus réutilisable de tout le bootcamp. C'est la deuxième fois qu'il est présenté (déjà vu en session 2, cf. [[Google Sheets]]), cette fois par un praticien en poste et avec un cas concret.

```
1. Why?  →  2. Data  →  3. Types of analysis  →  4. Exploration  →  5. Cleaning  →  6. Summary  →  7. Visualization
```

> [!tip] L'ordre exploration → cleaning surprend, et c'est voulu
> L'intuition dit « je nettoie, puis j'explore ». Le framework dit l'inverse. Raison : **on ne sait pas quoi nettoyer avant d'avoir regardé**. L'EDA révèle les outliers, les formats bâtards, les NULL — c'est ce diagnostic qui dicte le plan de nettoyage. En pratique la boucle est `explorer → nettoyer → ré-explorer pour vérifier`. Le cleaning n'est jamais un one-shot.

### Étape 1 — Why? Le scoping

Le travail préliminaire avant toute ligne de code. Objectif : **cartographier le besoin**, y compris ce qui n'est pas dit.

**Le framework 5W + H** (six questions, pas cinq) :

| Question | À creuser |
|---|---|
| **WHAT** | Que s'est-il passé ? De quoi as-tu besoin ? |
| **WHY** | Pourquoi est-ce arrivé ? Pourquoi soulever le sujet *maintenant* ? |
| **WHEN** | Quand est-ce arrivé ? Pour **quand** te faut-il une solution ? |
| **WHO** | Qui est concerné ? |
| **WHERE** | Où est-ce arrivé ? |
| **HOW** | Comment est-ce arrivé ? Comment **imagines-tu** la résolution ? |

Deux questions à ne jamais zapper, parce qu'elles ne sont presque jamais posées spontanément :
- **« Pour quand ? »** → c'est ce qui détermine si tu livres une V0 ou un produit fini.
- **« Comment tu imagines la solution ? »** → l'interlocuteur a déjà une image mentale du livrable. Si tu ne la fais pas sortir, tu la découvres à la restitution.

> [!important] Besoin exprimé ≠ besoin réel
> Le point insistant du cours. Une demande arrive presque toujours mal formulée. Le rôle du DA n'est pas d'exécuter la demande littérale, c'est de **reformuler jusqu'à ce que le besoin sous-jacent apparaisse** — ça fait gagner du temps à tout le monde.

**Cas Greenweez appliqué** — l'équipe finance demande de suivre les marges quotidiennes sur la période du 1er au 15 octobre 2021 :

| | Réponse |
|---|---|
| **What** | Calculer et suivre les marges quotidiennes |
| **Why** | Donner à la finance de la visibilité coûts/marges pour de meilleurs arbitrages budgétaires |
| **When** | Période du 1er au 15 octobre 2021 |
| **Who** | Demandeur = finance. Mais **impactés** = ops (coûts logistiques), marketing (coûts pub)… |
| **Where** | France uniquement ? Certaines régions ? International ? → la maille géographique change tout |
| **How** | Décomposer la marge par type de coût, pour rattacher chaque coût à un département |

La question du **Where** est celle que les étudiants ont trouvée en premier et c'est un bon réflexe : faire varier la maille géographique est souvent le premier axe de segmentation utile.

### Étape 2 — Data

Trois questions, dans l'ordre :
1. **De quelles données ai-je besoin ?**
2. **Où les trouver ?** (open source, base interne, export métier)
3. **Y ai-je accès ?** — question loin d'être triviale en entreprise : les droits d'accès sont un blocage classique.

Et une quatrième, qui est celle qui distingue un analyste junior d'un analyste opérationnel :

> [!important] Penser l'automatisation de l'import dès le départ
> Pendant tout le bootcamp, les jeux de données sont **figés**. En entreprise, il y a de nouvelles commandes tous les jours. Une analyse qui n'est pas rebranchable sur une source vivante est une analyse jetable. C'est exactement l'intérêt d'`IMPORTRANGE` dans Sheets, et plus tard de Fivetran, de dbt et du scheduling.

Pour le cas Greenweez, il faut : le CA, les coûts d'achat par produit vendu, les coûts logistiques, les frais de port.

> [!note] Le DA comme couteau suisse
> Le sujet part de la finance mais déborde immédiatement sur les ops et le marketing. La connaissance métier des interlocuteurs est ce qui rend la donnée interprétable — et arriver sur un sujet qu'on ne connaît pas est **normal**, personne ne le reprochera. Ce qu'on reproche, c'est de ne pas demander.

### Étape 3 — Types of analysis

| | **Reporting** | **Analyse ad hoc** |
|---|---|---|
| Objet | **Monitorer** des KPI récurrents | **Investiguer** un problème spécifique |
| Exemple | Marge opérationnelle quotidienne | *Pourquoi la marge a chuté le 5 octobre ?* |
| Temporalité | Suivi continu, mise à jour régulière | Ponctuel, one-shot |
| Profondeur | Reste en surface, par construction | Va chercher les causes derrière les chiffres |
| Livrable | Dashboard qui vit | Analyse qui conclut |
| EDA | Utile | **Obligatoire** |

Les deux ne s'opposent pas, ils s'enchaînent : **le reporting détecte l'anomalie, l'ad hoc l'explique**. Une baisse repérée sur un dashboard de suivi déclenche une analyse ad hoc, dont les conclusions font souvent naître un nouvel indicateur… ajouté au reporting. Boucle.

> [!warning] À clarifier explicitement avec le demandeur
> « Tu veux un suivi ou tu veux une explication ? » — les deux demandes se ressemblent à l'oral et ne produisent pas du tout le même livrable. Se tromper là-dessus, c'est refaire le travail.

### Étape 4 — Exploration (EDA)

Objectif : **mieux connaître son jeu de données** avant de s'appuyer dessus.

- Détecter les **outliers** — des valeurs extrêmes, potentiellement des erreurs de saisie ou des cas légitimes à isoler
- Comprendre la **distribution** : plages de valeurs, moyennes, dispersion
- Calculer des **statistiques descriptives**
- Se donner le droit de suivre son intuition et de poser des questions

Sa fonction réelle : **garantir que tout ce qui vient ensuite repose sur de la donnée déjà vérifiée**. Sans ça, on construit un dashboard propre sur des chiffres faux — le pire scénario, parce que personne ne le voit.

### Étape 5 — Cleaning

> Ce n'est pas la partie la plus sexy, mais c'est la plus importante. C'est le back-end, l'arrière-boutique.

Les trois grandes familles de nettoyage vues :

**1. Les valeurs manquantes**

Le point le plus insisté du cours, et à raison :

> [!warning] Une valeur manquante n'est PAS un zéro
> **Google Sheets** est le seul endroit où l'ambiguïté existe : une cellule vide référencée dans un calcul arithmétique (`=A1+A2`) est traitée comme `0`. **Partout ailleurs** — SQL, pandas, DAX — le `NULL` / `NaN` est un **type de donnée à part entière** qui se propage et casse les calculs en silence.
>
> Sémantiquement : « pas de CA réalisé » (= 0 €) et « CA inconnu » (= NULL) sont deux affirmations totalement différentes. Les confondre fausse toutes les moyennes.

Sur une variable **catégorielle** (ex. couleur d'un t-shirt sans valeur), la bonne pratique n'est pas de supprimer la ligne mais de créer une catégorie explicite (`"Non renseigné"`, `"Unknown"`) — on garde la ligne dans les totaux tout en rendant le trou visible.

Et surtout : **avant de décider quoi que ce soit, remonter au métier**. Une absence de donnée peut venir d'un import raté, d'un produit pas encore référencé, d'un process pas encore fait. Les interlocuteurs qui connaissent le sujet ont toujours raison contre ton hypothèse. Le seul contexte où tu dois trancher seul, c'est un test technique de recrutement — et là, on t'évalue justement sur ta capacité à **formuler des hypothèses explicites**.

**2. La standardisation des formats**

Les dates en premier : les typer réellement en date conditionne toute agrégation par mois/année ultérieure. Attention aux formats qui varient d'un pays à l'autre (`MM/DD/YYYY` vs `DD/MM/YYYY` — un import qui mélange les deux produit des dates valides mais fausses, le pire des cas).

**3. Les doublons**

Un doublon non traité gonfle les agrégats. Et une décision prise sur un agrégat gonflé coûte de l'argent.

**Trois réflexes stratégiques sur le cleaning :**

> [!tip] Cibler, ne pas tout nettoyer
> « La donnée en grande majorité, elle est très sale. » Si tu pars sur l'idée de tout nettoyer avant de passer à la suite, tu ne passes jamais à la suite. Une table de production a souvent plusieurs centaines de colonnes ; tu en utilises dix. **Nettoie ces dix-là.**

> [!tip] Nettoyer à la source, pas dans l'outil de viz
> À arbitrer entre : la source (Sheets, SQL) ou l'outil de restitution (Looker, Power BI). **Privilégier la source** — la capacité de calcul d'une base SQL est sans commune mesure avec celle d'un outil de dataviz, et faire porter les transformations au niveau de la viz dégrade les temps de chargement pour tous les utilisateurs. Ce principe est exactement ce qui justifie l'existence de dbt plus tard dans le cursus.

> [!tip] Automatiser le nettoyage, en acceptant qu'il buggera
> Un pipeline de nettoyage automatisé finira par casser (une nouvelle chaîne de caractères apparaît, un format change). Ce n'est pas un argument contre l'automatisation : **rajouter une règle à un pipeline existant coûte toujours moins cher que refaire un nettoyage manuel intégral**.

### Étape 6 — Summary (insights)

C'est le passage du **chiffre** à la **conclusion**.

Le mécanisme : l'exploration produit des **hypothèses** → on les vérifie → on en tire des conclusions. Exemple donné : une hausse des coûts de carburant expliquerait la baisse de marge.

Exemple de lecture d'insight sur Greenweez :

> Marge moyenne = **15,8 % du CA** → sur 100 € encaissés, il reste 15,80 € avant les étapes suivantes du compte de résultat. Conclusion : **CA élevé ≠ marge élevée**. Le volume ne garantit rien.

Deux points à retenir :
- **Prioriser** les insights par rapport à la question initiale. Tu n'en présentes pas dix, tu en présentes ceux qui répondent.
- Sur un même jeu de données, **deux analystes ne trouveront pas les mêmes choses**. Ce n'est pas un défaut du process, c'est pour ça qu'on confronte les interprétations.

### Étape 7 — Visualization

> Le nettoyage, c'est l'arrière-boutique. La restitution, c'est la vitrine — et c'est elle qui conditionne la perception de tout le travail amont.

**Choisir le bon support :**
- Tableau d'un million de lignes → illisible, ne parle à personne
- Tableau restreint et chiffré → ça marche, certains interlocuteurs préfèrent
- Visualisation → le cas général

**Choisir le bon graphe :** courbe pour une **tendance**, diagramme pour des **proportions**. (Un cours dédié à la dataviz viendra plus tard.)

**Conseils dashboard :**

| Règle | Pourquoi |
|---|---|
| Rester lisible et compréhensible | Ajouter des commentaires, des filtres |
| **Ne pas abuser des couleurs** | *Trop de mise en avant = rien en avant.* Si tout est surligné, plus rien ne ressort |
| Laisser l'utilisateur explorer | Filtres, drill-down : il doit pouvoir se poser SES questions |
| Garder l'objectif initial en tête | Le dashboard répond à un besoin précis, pas à tous les besoins |

> [!note] Le principe de l'elevator pitch
> Ton interlocuteur gère mille dossiers et t'accorde **5 minutes**. À toi d'en tirer le maximum : concis, impactant, hiérarchisé. C'est la même logique que la dataviz — supprimer tout ce qui n'est pas le message.

### Étape 8 (implicite) — L'itération

Le point le plus « terrain » du cours.

- Une analyse n'est **jamais** un one-shot. On fait une **V0**, puis une **V1** enrichie, etc.
- L'enrichissement vient de deux sources : tes propres conclusions en cours de route, et les nouvelles demandes qui naissent de la restitution.
- Parfois il faut **revenir en arrière** : les hypothèses sont épuisées, le jeu de données ne suffisait pas → retour à l'étape 2.

> [!warning] Savoir poser le stylo
> Le corollaire, et le vrai piège du métier : **on peut toujours faire mieux**. Le titre est décalé, le jeu de couleurs pourrait être meilleur, cet indicateur gagnerait à être en pourcentage… L'intervenant raconte un dashboard **bloqué 2-3 semaines** pour des retouches, alors qu'il était déjà exploitable.
>
> **Un dashboard imparfait mais en production vaut mieux qu'un dashboard parfait bloqué.** Et il y a toujours des deadlines.

### 📚 Récap du cours 1

- Une **méthode en 7 étapes** pour analyser de la donnée
- Comment poser les **bonnes questions** et récupérer la **bonne donnée**
- La différence **reporting / analyse ad hoc**
- Comment **nettoyer, explorer et synthétiser** des insights
- Comment **présenter des dashboards qui font prendre des décisions**

---

## 📊 2. KPI vs métrique

### Définition

**KPI = Key Performance Indicator** = indicateur clé de performance.

C'est une métrique, oui — mais **intimement liée à un objectif de performance**. Une valeur mesurable *systématiquement associée à une cible*.

> [!important] La définition à retenir mot pour mot
> Un KPI, ce n'est pas un chiffre. C'est **un chiffre + un objectif + une interprétation**.

**L'exemple canonique du cours :** un taux de satisfaction à **79 %**.

- Lecture **littérale** (= métrique) : sur 100 clients, 79 sont satisfaits.
- Lecture **KPI** : **plus d'un cinquième de mes clients sont insatisfaits**, ce qui n'est pas acceptable au regard de l'objectif de maximisation de la satisfaction.

Même chiffre. Deux lectures. **L'essentiel du KPI réside dans son interprétation**, pas dans sa valeur.

Le KPI est le **pont entre la donnée brute et la conclusion** — exactement l'étape 6 du framework. Sans KPI, il n'y a pas de mesure du progrès possible.

### Le tableau du cours

| **KPI** — *Are we on track?* | **Métrique** — *What's happening and why?* |
|---|---|
| Un **objectif** à atteindre | Une **valeur** à monitorer |
| Suit la **progression vers un objectif business** | **Décrit** ce qui se passe opérationnellement |
| **Stratégique** | **Opérationnel** |
| Sujet à interprétation | Lecture littérale de la donnée |
| Ex. taux de satisfaction moyen vs cible | Ex. nombre de réponses à 5/5, à 4/5, à 3/5… |

> [!tip] La bonne image mentale
> **Le KPI est la porte d'entrée, la métrique est ce qui permet de creuser.** Le KPI te dit *que* ça va mal. Les métriques te disent *pourquoi*. Ils ne s'opposent jamais, ils s'emboîtent — et une analyse qui n'a que des KPI ne peut rien expliquer.

### Ce qui fait un bon KPI

**Peu, mais bien choisis.** « 3 ou 4 indicateurs » suffisent. Le critère de qualité n'est pas *combien de questions il répond*, c'est **combien de questions il ouvre**.

Exemple donné : un taux d'atteinte d'objectif à **87 %** affiché en gros sur un dashboard. En un coup d'œil on sait de quoi il s'agit. Et derrière, immédiatement :
- 87 % à quelle date ? Si on est en mars, c'est excellent. Si on est en décembre, c'est un problème.
- Est-ce actualisé ?
- Comment ça se décompose par région ? (Île-de-France vs PACA…)
- Par produit ? Par équipe ?

**Un seul indicateur, dix questions.** C'est ça, un bon KPI.

> [!note] Les KPI ne sont scrutés que quand ils vont mal
> Constat de terrain : un KPI satisfaisant, personne ne le regarde. C'est quand il devient insatisfaisant que tout le monde se penche dessus — et donc sur ta méthode de calcul. **Documente tes définitions avant qu'on te les demande.**

### Un chiffre sans comparaison n'est pas un KPI

Point non dit explicitement en cours mais visible sur toutes les slides — et essentiel :

```
Gross Margin - Oct 15th        Shortage rate
18,490€                        0.93%
↓ -900€                        ↓ -0.05%
```

Le petit delta en rouge sous chaque chiffre, **c'est ce qui transforme la métrique en KPI**. `18 490 €` ne veut rien dire dans l'absolu. `18 490 € en baisse de 900 € vs hier` déclenche une action.

Les trois points de comparaison à toujours envisager :

| Comparaison | Ce qu'elle révèle |
|---|---|
| **vs période précédente** (J-1, M-1, N-1) | La tendance |
| **vs objectif / budget** | L'atteinte |
| **vs segment** (autre région, autre catégorie, autre équipe) | Le benchmark interne |

> [!warning] Attention à la lecture du delta sur le shortage rate
> Un `↓ -0.05%` sur un taux de rupture est une **bonne** nouvelle (moins de ruptures), là où un `↓ -900€` sur la marge est une mauvaise nouvelle. Le sens de la flèche n'est pas le sens de la performance. Sur un dashboard, colorer les deltas **selon la performance, pas selon le signe** — sinon tu affiches du rouge sur une amélioration.

### Qui possède le KPI ?

Question posée en séance, et réponse importante :

> [!important] Le Data Analyst est l'exécutant, pas le décideur
> **L'owner d'un KPI n'est jamais le Data Analyst.** Ce sont les équipes métier qui fixent les objectifs et les cibles. Le DA construit, calcule, fiabilise, restitue.
>
> Ça ne veut pas dire subir : le rôle du DA est de **challenger la formulation**. Les besoins arrivent très souvent mal exprimés, et poser les bonnes questions en amont fait gagner du temps à tout le monde. Selon les organisations, les objectifs arrivent déjà définis, ou se construisent de manière itérative dans l'échange.

Et les KPI sont **spécifiques** : à une entreprise, à un secteur, à un département. Il n'y a pas de liste universelle — d'où l'importance des trois challenges ci-dessous, qui couvrent trois départements différents du même business.

### 📚 Récap du cours 2

- **Ce que sont les KPI** et en quoi ils diffèrent des **métriques**
- Comment les **équipes internes** utilisent les KPI pour suivre leur performance
- Comment **interpréter les formules de KPI** sur des cas business réels

---

## 💰 3. Challenge Finance — les marges

### Le contexte Greenweez

Greenweez est une entreprise **d'achat-revente** (e-commerce). Son CA est scindé en deux :

| Poste | Nature | Sens |
|---|---|---|
| **Turnover** | Revenu | Vente du produit lui-même |
| **Ship fee** | Revenu | Frais de port **facturés au client** |
| **Purchase cost** | Coût direct | Ce que Greenweez a payé le produit au fournisseur |
| **Ship cost** | Coût | Ce que Greenweez paie **au transporteur** |
| **Logistics cost** | Coût | Tout ce qui se passe entre la commande et l'acheminement (préparation, entrepôt, manutention) |

> [!warning] `ship fee` ≠ `ship cost` — le piège de nommage
> Les deux contiennent « ship », les deux apparaissent dans les formules, et ce sont **des sens opposés** : `ship fee` est un **revenu** (le client paie les frais de port), `ship cost` est une **charge** (Greenweez paie le transporteur). Une partie de ce que le client paie rentre dans la poche de Greenweez, le reste part chez le transporteur — l'écart entre les deux est un mini-centre de profit à part entière.
>
> Se tromper de colonne ici, c'est une erreur silencieuse : le calcul tourne, le chiffre est plausible, il est faux.

### Les formules du cours

```
Gross Margin      = (turnover + ship fee) − purchase costs

Operating Margin  = gross margin − (logistics costs + ship costs)
```

**Ce que chaque niveau raconte :**

| Marge | Ce qu'elle mesure | Signal d'alerte |
|---|---|---|
| **Gross margin** | L'efficacité de l'**achat / la production**. Plus elle est haute, moins le produit coûte cher à acquérir par rapport à son prix de vente | Basse → problème de sourcing ou de pricing |
| **Operating margin** | Ce qu'il reste une fois les **coûts indirects** absorbés | **Gross margin correcte mais operating margin négative** = le modèle logistique mange toute la marge. Tu perds de l'argent en vendant |

> [!important] Le cas classique de l'e-commerce
> Gross margin satisfaisante + operating margin négative = la marge produit existe mais les coûts d'expédition et de logistique la détruisent. C'est **le** problème structurel du e-commerce, et c'est exactement ce que la décomposition permet de rendre visible. Un seul chiffre de marge globale l'aurait masqué.

**Exemple chiffré donné à l'oral :**

```
Vente client        70 €   →  60 € turnover + 10 € ship fee
Purchase cost      −45 €
─────────────────────────
Gross margin        25 €   →  soit 35,7 % de la vente totale
```

> [!note] Tout se calcule HORS TAXE
> Question posée en séance, réponse nette : **pas de TVA dans ces calculs**. La TVA transite par la trésorerie mais n'appartient jamais à l'entreprise — l'inclure gonflerait artificiellement le CA et fausserait tous les taux de marge.

### ⚠️ Attention — la définition Greenweez n'est pas la définition comptable

Point important et **non dit en cours**, à ne pas se faire piéger dessus en entretien :

En comptabilité générale, la **marge opérationnelle** (résultat d'exploitation / EBIT) intègre **toutes** les charges d'exploitation : salaires, marketing, loyers, amortissements, R&D… Ici, elle est volontairement réduite à `logistics + ship costs`, parce que c'est ce que contient le dataset.

**La cascade complète du compte de résultat**, pour situer :

```
Chiffre d'affaires (CA / revenue)
  − coûts directs (achat / production)
  ────────────────────────────────────
  = Marge brute (gross margin)
      − charges d'exploitation (salaires, marketing, logistique, loyers…)
      ────────────────────────────────
      = Résultat d'exploitation (operating income / EBIT)
          − charges financières, impôts
          ────────────────────────────
          = Résultat net (net income)  ←  la dernière ligne, celle qui englobe tout
```

L'intervenant mentionne bien la **net margin** comme « ce qu'il y a tout en bas du compte de résultat », mais elle n'est pas calculée dans le challenge.

> [!tip] Formulation sûre en entretien
> « Sur ce projet, on a défini la marge opérationnelle comme la marge brute nette des coûts logistiques et d'expédition — c'est le périmètre qu'autorisait le dataset. La définition comptable complète intègrerait aussi les charges de structure. » → tu montres que tu connais les deux **et** que tu sais adapter une définition à un périmètre de données. C'est exactement ce qu'on attend d'un DA.

### ⚠️ Le piège du taux de marge

Les slides donnent la marge en **valeur** (€). Dès que tu passes en **taux**, le piège classique s'ouvre :

```
❌  AVERAGE(marge_ligne / CA_ligne)     →  moyenne de ratios, chaque commande pèse pareil
✅  SUM(marge) / SUM(CA)                →  ratio d'agrégats, pondéré par le poids réel
```

Une commande à 5 € et une commande à 5 000 € ne doivent évidemment pas peser le même poids dans le taux de marge global. Voir [[Aggregate before divide]].

Corollaire direct : **un taux de marge ne s'additionne pas et ne se moyenne pas**. Il se recalcule à chaque niveau d'agrégation, à partir des numérateurs et dénominateurs sommés.

---

## 📦 4. Challenge Stock & Logistique — le shortage rate

### Ce que ça mesure

Le **taux de rupture de stock** = pourcentage de références produits en rupture.

Ce n'est **pas** un indicateur de satisfaction client au sens strict, c'est un indicateur de la **capacité de l'entreprise à répondre à la demande**. Une rupture a deux causes possibles, et les deux méritent des actions opposées :
- **côté supply** : mauvaise anticipation du réapprovisionnement
- **côté demande** : le signal de demande n'est pas remonté à temps aux équipes achat

### Le raisonnement binaire — le point le plus insisté

> [!important] On raisonne en RÉFÉRENCES, pas en UNITÉS
> Une référence produit est **soit en stock (1), soit en rupture (0)**. On ne compte ni le nombre d'unités en stock, ni la valeur du stock. Un produit avec 1 unité restante et un produit avec 10 000 unités comptent tous les deux pour `1`.
>
> L'intervenant insiste explicitement là-dessus parce que la confusion avec la *valeur de stock* ou la *quantité en stock* est le contresens numéro 1.

**Illustration :** 4 références, 1 en rupture → `1 / 4 = 25 %` de taux de rupture, `75 %` de taux de disponibilité.

### Les deux formules

```
Shortage rate = (nb out-of-stock products / nb total products) × 100

     ou

Shortage rate = 1 − AVERAGE(in_stock)
```

> [!warning] ⚠️ Incohérence d'échelle entre les deux formules de la slide
> Les deux ne renvoient **pas la même unité** :
> - la première produit un **pourcentage** (`0.93`) grâce au `× 100`
> - la seconde produit un **ratio** (`0.0093`)
>
> Elles sont mathématiquement équivalentes **au facteur 100 près**. Si tu passes de l'une à l'autre dans un dashboard sans y penser, tu obtiens un shortage rate de 93 % au lieu de 0,93 %. Le bon réflexe : **calculer partout en ratio**, et gérer le `× 100` uniquement au niveau du **formatage d'affichage** (format pourcentage de la cellule / du visuel). Jamais dans la formule.
>
> C'est le même principe que « ne jamais arrondir un multiplicateur intermédiaire » — la mise à l'échelle est une décision d'affichage, pas de calcul.

### L'astuce 0/1 — le vrai take-away technique

C'est la démo Google Sheets de fin de session, et elle mérite d'être comprise à fond parce qu'elle se réutilise partout.

Sur une colonne binaire `in_stock` contenant des `1` et des `0` :

```
AVERAGE(in_stock)  =  SUM(in_stock) / COUNT(in_stock)
                   =  nb de références en stock / nb total de références
                   =  taux de disponibilité
```

Donc :

```
=AVERAGE(in_stock)        →  taux de disponibilité   (ex. 0.75)
=1 - AVERAGE(in_stock)    →  taux de rupture         (ex. 0.25)
```

**Une seule fonction, zéro `COUNTIF`.** L'alternative — `COUNTIF(range;0) / COUNTA(range)` — fonctionne mais est plus verbeuse et casse dès que les valeurs ne sont plus 0/1.

> [!tip] Le pattern à retenir : `AVERAGE` sur un booléen = un taux
> C'est un pattern universel, et il se transpose ligne pour ligne :
>
> ```sql
> -- SQL / BigQuery
> AVG(CAST(in_stock AS INT64))                 AS availability_rate
> SAFE_DIVIDE(COUNTIF(NOT in_stock), COUNT(*)) AS shortage_rate
> ```
> ```python
> # pandas — un booléen est un 0/1 déguisé
> df["in_stock"].mean()        # taux de disponibilité
> 1 - df["in_stock"].mean()    # taux de rupture
> ```
> ```dax
> // DAX
> Availability Rate = AVERAGE( Products[in_stock] )
> ```
>
> Généralisation : **toute question « quel pourcentage de X vérifie la condition C ? » se résout par une moyenne sur un indicateur 0/1.** Taux de churn, taux de conversion, taux de réclamation, taux de défaut : même mécanique.

### ⚠️ Le piège qui casse l'astuce — les cellules vides

Non abordé en cours, et c'est exactement là que ça fait mal :

> [!warning] `AVERAGE` ignore les cellules vides, mais pas les zéros
> Dans Google Sheets comme en SQL, **`AVERAGE` / `AVG` exclut les valeurs vides du dénominateur**. Si ta colonne `in_stock` a 100 lignes dont 10 vides et 63 à `1` :
>
> - Ce que tu crois calculer : `63 / 100 = 63 %`
> - Ce qui est calculé : `63 / 90 = 70 %`
>
> **7 points d'écart, aucun message d'erreur.** Et c'est cohérent avec l'étape 5 : une cellule vide n'est pas un zéro, elle est *inconnue* — statistiquement, l'exclure est même le comportement correct. Le problème n'est pas le comportement de la fonction, c'est de ne pas savoir qu'il existe.
>
> **Réflexe systématique avant tout `AVERAGE` sur du binaire :** vérifier que `COUNT(colonne) = COUNTA(plage totale)` — ou en SQL, comparer `COUNT(col)` et `COUNT(*)`.

### Segmentation

Le shortage rate se décline naturellement **par catégorie de produit**. C'est là qu'un tableau croisé dynamique devient utile : un taux global de 0,93 % peut masquer une catégorie à 12 % — et c'est cette catégorie-là qui déclenche l'action.

---

## ✅ 5. Challenge Qualité — % of initial turnover

### La formule

```
% of initial turnover = (turnover before refund − turnover refunded) / turnover before refund
```

**Ce que ça mesure :** la part du CA initialement vendu qui est **réellement encaissée** après retours. La slide affiche `93.61 %`.

**Comment le lire :** plus le taux est haut, mieux c'est. Un écart important entre CA initial et CA réel est un **signal qualité** : produits non conformes, descriptions trompeuses, problèmes d'emballage, erreurs de préparation de commande.

### Son miroir : le taux de retour

```
Taux de retour = turnover refunded / turnover before refund = 1 − (% of initial turnover)
```

Sur l'exemple : `1 − 93,61 % = 6,39 %` de CA retourné.

Les deux indicateurs portent exactement la même information. Le choix de présenter l'un ou l'autre est **une décision de communication** :
- Le **% of initial turnover** rassure (93 %, ça a l'air bien)
- Le **taux de retour** alarme (6,4 %, à comparer à un benchmark sectoriel)

> [!tip] Choisir le sens de lecture
> Pour un **suivi de performance** (est-ce qu'on progresse ?), le taux de rétention de CA fonctionne. Pour **déclencher une action**, le taux de retour est plus parlant — c'est lui qu'on segmente par catégorie et par fournisseur pour identifier les coupables. Même chiffre, deux usages.

### ⚠️ Valeur ≠ volume

Non dit en cours, et important :

Ce KPI est calculé **en euros**, pas en nombre de commandes. Les deux mesures ne racontent pas la même histoire :

| | Ce que ça mesure | Utile pour |
|---|---|---|
| Taux de retour **en valeur** (€) | L'impact financier | La finance, le pilotage de la marge |
| Taux de retour **en volume** (nb) | La fréquence du problème | La qualité, les ops, le service client |

Un taux de retour de 6 % en valeur porté par **un seul produit cher** ne se traite pas du tout comme 6 % portés par **des centaines de petites commandes**. Toujours croiser les deux.

Et un retour coûte plus cher que le CA perdu : logistique retour, reconditionnement, traitement client. **Le taux de retour dégrade la marge opérationnelle bien au-delà de la ligne CA** — ce qui relie ce challenge au challenge 1.

### Bonus — le NPS

Le **NPS (Net Promoter Score)** est mentionné rapidement comme indicateur de satisfaction mesurant la répartition promoteurs / détracteurs. Comme il n'est pas détaillé et qu'il tombe souvent en entretien, voici la définition complète :

Sur la question « recommanderiez-vous X à un proche, de 0 à 10 ? » :

| Segment | Note | Traitement |
|---|---|---|
| **Détracteurs** | 0–6 | Comptés négativement |
| **Passifs** | 7–8 | **Exclus du calcul** (mais pas de la base) |
| **Promoteurs** | 9–10 | Comptés positivement |

```
NPS = % promoteurs − % détracteurs
```

> [!warning] Deux pièges classiques sur le NPS
> 1. **Le NPS n'est pas un pourcentage**, malgré sa formule. Il s'exprime en points, sur une échelle de **−100 à +100**. Écrire « NPS de 42 % » est faux — c'est « NPS de 42 ».
> 2. **Les passifs comptent dans le dénominateur** des deux pourcentages, mais n'apparaissent dans aucun des deux termes. Deux entreprises avec un NPS identique peuvent avoir des distributions radicalement différentes → c'est précisément un cas où **le KPI seul ne suffit pas** et où il faut la métrique brute (la distribution des notes) pour comprendre. Illustration parfaite du tableau KPI/métrique.

---

## 🛠️ 6. La couche Google Sheets

Prolongement direct de [[Google Sheets]]. Les points nouveaux ou re-insistés cette session.

### Raccourcis clavier

| Raccourci (Mac / PC) | Effet |
|---|---|
| `CMD` / `CTRL` + `→ ← ↑ ↓` | Sauter à l'extrémité de la plage de données dans la direction choisie |
| `SHIFT` + `→ ← ↑ ↓` | Étendre la sélection cellule par cellule |
| **`CMD/CTRL` + `SHIFT` + `→ ← ↑ ↓`** | **Combinaison : sélectionner toute une plage d'un coup** ⭐ |
| `CMD` / `CTRL` + `A` | Sélectionner toute la table de données |
| `CMD` / `CTRL` + `D` | **Recopier la formule de la première cellule sur toute la sélection** |

Le combo à automatiser : `CMD+SHIFT+↓` pour sélectionner la colonne entière depuis la formule, puis `CMD+D` pour la propager. Ça remplace le double-clic sur la poignée de recopie, et ça marche même quand la colonne adjacente a des trous.

### Champ calculé dans un tableau croisé dynamique

La partie la plus dense de la démo, et un vrai palier conceptuel.

> [!important] Le TCD raisonne en CHAMPS, pas en cellules
> C'est le point de bascule mental annoncé pour la suite du cursus : `=B2/C2` référence des **cellules**, un champ calculé référence des **colonnes** (`=gross_margin / turnover`). C'est déjà la logique SQL, une semaine avant de faire du SQL.

Quand tu crées un champ calculé, Sheets propose une option **« Summarize by »** :

| Option | Comportement | Quand l'utiliser |
|---|---|---|
| **SUM** | La formule est évaluée **ligne par ligne**, puis les résultats sont sommés | Grandeurs **additives** (une marge en €) |
| **Custom** | La formule est évaluée sur les **valeurs déjà agrégées** du groupe | **Ratios et taux** (taux de marge, taux de rupture) |

> [!warning] C'est [[Aggregate before divide]] déguisé
> Sur un taux, `SUM` te donne « la somme des ratios ligne à ligne » — un nombre qui n'a **aucun sens** (il peut dépasser 100 %). `Custom` te donne `SUM(numérateur) / SUM(dénominateur)`, le seul calcul correct.
>
> **Test de vérification systématique** : compare la valeur de la ligne *Grand Total* du TCD avec un `SUM(num)/SUM(dén)` calculé à la main hors du tableau. Si les deux divergent, tu es sur la mauvaise option.

Pourquoi ça vaut le coup d'apprendre ça maintenant, alors que ça a l'air overkill : **c'est le premier pas vers l'automatisation**. Une fois le champ calculé posé, tu filtres, tu segmentes, tu changes la maille — sans jamais retaper une formule. C'est la même promesse que les mesures DAX en Power BI, ou les modèles dbt.

### Rappels des fonctions

Repris des notes de session :

- **`IMPORTRANGE`** : cibler des **colonnes entières** (`A:E`), jamais une plage figée (`A1:E35`). Sinon les nouvelles lignes ne remontent pas. Lier une source rend le fichier auto-actualisable ; en cas de blocage, un copier-coller en valeur dans un onglet dédié reste une solution acceptable — l'important est que **la source vive dans le fichier**.
- **`XLOOKUP`** : le dernier argument peut être **plusieurs colonnes**, pas une seule → une formule ramène plusieurs champs d'un coup.
- **Fonctions vs valeurs figées** : une formule est recalculée à l'ouverture du fichier. Tirer les formules **de manière préventive jusqu'en bas** de la plage anticipe les lignes futures.

> [!tip] Documenter ses colonnes
> Conseil détaché et à prendre au sérieux : le dataset Greenweez arrive avec une **table de définition des colonnes** déjà faite. Dans un job, si tu as l'occasion de documenter tes colonnes — onglet dédié, wiki, outil de catalogue — **fais-le**. C'est le genre de chose qui te distingue immédiatement, et c'est l'ancêtre direct des `description:` dans les fichiers `schema.yml` de dbt.

---

## 🏦 7. Transposition banking (hors cours)

Les trois KPI vus aujourd'hui sont e-commerce, mais leur **structure** est ce qui se réutilise. Correspondances utiles pour tes candidatures genevoises :

| KPI Greenweez | Structure | Équivalent banque privée |
|---|---|---|
| **Gross margin** | Revenu − coût direct | **Net Interest Margin** (produits d'intérêt − coûts de refinancement) ; **marge sur commissions** de gestion |
| **Operating margin** | Marge − coûts opérationnels | **Cost/Income ratio** — LE KPI de la banque privée, et il se lit à l'envers (plus bas = mieux) |
| **Shortage rate** | Comptage binaire / total | **Taux de STP** (Straight-Through Processing) ; **taux de breach SLA** ; **taux de trades en échec** |
| **% of initial turnover** | (Initial − annulé) / initial | **Taux d'annulation / amendement de transactions** ; qualité des données de référentiel |
| **NPS** | Promoteurs − détracteurs | Suivi client identique, très utilisé en wealth management |
| **AVERAGE sur 0/1** | Moyenne d'un booléen | **Taux de complétude KYC**, taux de conformité documentaire, taux de couverture réglementaire |

> [!tip] Le pattern transférable
> Ce que tu vends en entretien, ce n'est pas « j'ai calculé un taux de rupture de stock ». C'est : **« j'ai décomposé une marge en niveaux successifs pour identifier à quelle étape la valeur se perdait »** et **« j'ai construit des indicateurs de taux sur variables binaires, en veillant au périmètre du dénominateur »**. Les deux sont directement lisibles par un recruteur banking.

---

## 🩹 8. Corrections & points d'attention sur le support

**1. « Entreprise fictive » — faux, et c'est à ton avantage**
Le résumé Notion présente Greenweez comme *« une entreprise fictive servant d'étude de cas »*. C'est inexact : **Greenweez est une vraie entreprise française**, leader du e-commerce bio, fondée en 2008 en Haute-Savoie (Saint-Jorioz / Annecy) par Romain Roy et Carl De Miranda, **rachetée par Carrefour en 2016**, puis développée à l'international (Planeta Huerto en Espagne, Sorgente Natura en Italie). Les données sont vraisemblablement anonymisées ou reconstituées, mais le business est réel.
→ **Pourquoi ça compte** : en entretien, « j'ai travaillé sur les données d'un pure player e-commerce bio français » est infiniment plus crédible que « un cas d'école fictif ». Et anecdote utile : le siège est à ~40 km d'Annecy, dans ta zone de projection résidentielle.

**2. Nom de l'entreprise massacré par la transcription**
`GreenWiz`, `Greenway`, `GreenWheeze`, `Green Weez`, `Louise`, `Louises`… La graphie correcte est **Greenweez**. À corriger si tu réutilises des extraits.

**3. 5W vs 5W + H**
Le résumé Notion parle des *« 5W (Who, What, When, Where, Why) »* et omet le **How**. La slide affiche bien **5 W + H**, soit **six** questions — et le transcript parle explicitement de « ces six questions ». Le `HOW` est même la question la plus opérationnelle des six (*how do you imagine solving it?*).

**4. Septembre vs octobre 2021**
Le résumé Notion date la période d'analyse au *« 1er–15 septembre 2021 »*. Les slides et le reste du transcript disent **octobre** (`Gross Margin - Oct 15th`, `Why did margin drop on Oct 5?`). La période est **le 1er au 15 octobre 2021**.

**5. Erreur de formule dans le quiz shortage rate**
Le quiz énonce : *« on va diviser le nombre de références en rupture de stock par le nombre en stock »*. **Faux** — c'est **par le nombre total de produits**. L'intervenant corrige en direct : *« tu divises une catégorie par l'autre, mais pour avoir le shortage, tu divises la catégorie par le total »*. Erreur classique et coûteuse : sur 1 rupture / 3 en stock, la mauvaise formule donne 33 % au lieu de 25 %.

**6. Incohérence d'échelle sur la slide Shortage Rate**
Détaillée plus haut : la formule 1 inclut un `× 100`, la formule 2 non. Facteur 100 d'écart entre les deux. Voir [[#Les deux formules]].

**7. Définition non standard de l'operating margin**
Le périmètre `logistics + ship costs` est spécifique au dataset. La définition comptable intègre toutes les charges d'exploitation. Détaillé dans [[#⚠️ Attention — la définition Greenweez n'est pas la définition comptable]].

**8. Ce qui a été ajouté au-delà du support**
Pour transparence, les éléments ci-dessous ne viennent pas du cours : la cascade complète du compte de résultat, le piège des cellules vides sur `AVERAGE`, la définition détaillée du NPS et ses deux pièges, la distinction valeur/volume sur les retours, la section [[#🏦 7. Transposition banking (hors cours)]], la sémantique du sens des deltas, et les transpositions SQL/pandas/DAX de l'astuce 0/1.

---

## 🎤 9. Angle entretien

Questions probables et angles de réponse :

**« C'est quoi la différence entre un KPI et une métrique ? »**
→ Le KPI est stratégique et adossé à un objectif ; la métrique est opérationnelle et descriptive. Le KPI dit *si* on est sur la trajectoire, la métrique dit *pourquoi*. Exemple concret : le NPS est un KPI, la distribution des notes 0–10 est la métrique qui l'explique.

**« Comment tu abordes une nouvelle demande d'analyse ? »**
→ Dérouler 5W+H, en insistant sur les deux questions que personne ne pose : *pour quand* et *comment tu imagines la solution*. Puis : reporting ou ad hoc ? Ça détermine tout le livrable.

**« Quelle est l'étape la plus importante d'une analyse ? »**
→ Le nettoyage, sans hésiter — c'est l'étape la plus chronophage et la moins visible, et une erreur à ce niveau se propage jusqu'à la décision. Mais préciser qu'on **cible** le nettoyage sur les colonnes utiles, et qu'on le fait **à la source** plutôt que dans l'outil de viz, pour des raisons de performance.

**« Ta marge brute est bonne mais ton résultat opérationnel est négatif. Que fais-tu ? »**
→ La marge produit existe, ce sont les coûts indirects qui la détruisent. Décomposer par nature de coût (logistique, expédition), puis segmenter par catégorie produit / zone géographique / mode de livraison. En e-commerce, les petits paniers avec livraison gratuite sont le suspect numéro un.

**« Comment tu calcules un taux ? »**
→ Le piège est là. `SUM(num) / SUM(dén)`, jamais `AVERAGE(num/dén)`. Et vérifier le dénominateur : total, pas catégorie complémentaire. Cf. [[Aggregate before divide]].

---

## 🔗 Liens

- Chapitre précédent : [[Google Sheets]] — le framework 7 étapes y apparaît une première fois, plus les fonctions reprises ici
- [[Aggregate before divide]] — le principe transversal, ici dans sa version « champ calculé de TCD » et « taux de marge »
- [[Granularité d'une table]] — pourquoi le shortage rate se calcule à la maille *référence produit* et pas *unité en stock*

**Fiches-concept associées :**
- [[KPI vs métrique]]
- [[Reporting vs analyse ad hoc]]
- [[Marge brute, marge opérationnelle, marge nette]]
- [[Taux sur variable binaire]]
- [[NPS (Net Promoter Score)]]
