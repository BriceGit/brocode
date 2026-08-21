---
title: "KPI Advanced — Funnels, cohortes, segmentation & KPI marketing"
aliases:
  - "KPI Advanced"
  - "B2C vs B2B"
  - "Funnel d'acquisition"
  - "Funnel d'expansion"
  - "Analyse de cohorte"
  - "Segmentation RFM"
  - "CAC, CPC, ROAS"
  - "KPI CRM email"
  - "Vanity metric"
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 4
date: 2026-07-09
language: "Formules Google Sheets"
database: "n/a — tableur (Google Sheets)"
topics:
  - "KPI"
  - "B2C / B2B"
  - "Funnel"
  - "Cohortes & rétention"
  - "Segmentation"
  - "RFM"
  - "CRM & emailing"
  - "Media & acquisition payante"
  - "NPS & CSAT"
  - "Dashboards dynamiques"
  - "Greenweez"
tags:
  - brocode
  - wagon2321/cours
  - kpi
  - marketing-analytics
  - business-analysis
  - google-sheets
---

# KPI Advanced

> Suite directe de [[KPI Basics]]. La session précédente disait *ce qu'est* un KPI ; celle-ci dit **d'où il vient**. Réponse : du modèle économique, de la maturité de la boîte, et de l'équipe qui le porte. On descend ensuite dans les KPI concrets de trois métiers (média, CRM, satisfaction), plus les deux outils d'analyse structurants de tout le métier : **le funnel** et **la cohorte**.

**Date :** 9 juillet 2026
**Format :** cours du matin (2 parties enchaînées) puis challenges toute la journée
**Intervenant :** intervenant externe, ex-marketing/growth en agence et en annonceur (parle de « mon ancienne boîte », leader des coupons de caisse en retail)
**Dataset fil rouge :** **Greenweez**
**Challenges :** 🔴 Médias · 🔴 CRM · 🔴 NPS *(obligatoires)* — ESSEC · engagement vidéo *(optionnels)*
**Ressources :** 3 cheat sheets de formules KPI dispo dans le cours

> [!note] Le mot d'ordre du cours
> *« Le but des KPI, ce n'est pas de les connaître par cœur. C'est de comprendre à quoi ça correspond, et de savoir retrouver la formule quand vous en aurez besoin. »*

---

## 🎯 TL;DR

- **Le bon KPI dépend du modèle et de la maturité.** B2C → volume + automatisation. B2B → relation + suivi. Modèle commande → **taux de réachat**. Modèle abonnement → **rétention & churn**. Early-stage → croissance. Mature → efficacité & profit.
- **Le funnel d'acquisition s'analyse à l'envers** : on part des acheteurs et on remonte. Et on priorise sur le **volume absolu perdu**, pas sur le taux de perte.
- **Cohorte** = regrouper les clients par mois de première commande et suivre chaque groupe dans le temps. L'objectif n'est pas une courbe qui monte, c'est **un plateau, le plus haut possible**. Une courbe qui tombe à zéro = pas de business.
- **Un plateau de rétention + une acquisition constante = croissance incrémentale automatique.** C'est le seul mécanisme de croissance durable d'un modèle par abonnement.
- **Media** : `CTR = clics/impressions` · `CPC = coût/clics` · `CAC = coût/nouveaux clients` · `ROAS = CA/coût`. Le CAC se compare à une **cible** ; sous la cible → on **scale**.
- **⚠️ Le ROAS se calcule sur le CA, pas sur la marge.** Le seuil de rentabilité est `1 / taux de marge`. Marge à 20 % → il faut un ROAS de **5** pour rentrer dans ses frais.
- **CRM** : `taux d'ouverture` · `taux de clic` · `CTR = clics/ouvertures` · `revenu pour 1 000 emails`. Le CTR est l'indicateur de **pertinence du contenu**, mais il ne vaut rien sans un taux d'ouverture correct.
- **⚠️ « CTR » ne veut pas dire la même chose sur les deux slides du cours.** Toujours demander le dénominateur. Voir [[#🩹 12. Corrections & points d'attention sur le support]].
- **Vanity metric** : le test est *« si cet indicateur augmente, est-ce que mon CA augmente ? »*. Sans corrélation, c'est du confort, pas du pilotage.
- **Le DA ne définit pas les KPI** (c'est le lead ou un senior de l'équipe), mais il doit **connaître l'ordre de grandeur attendu** de chacun — c'est ce qui lui permet de repérer ses propres erreurs de calcul.

---

## 🗺️ Sommaire

- [[#🧭 1. Le contexte détermine les KPI]]
- [[#🎯 2. Le funnel d'acquisition]]
- [[#🔁 3. Le funnel d'expansion]]
- [[#🧩 4. La segmentation client]]
- [[#📈 5. L'analyse de cohorte]]
- [[#📣 6. KPI Médias — l'acquisition payante]]
- [[#✉️ 7. KPI CRM — l'emailing]]
- [[#😀 8. KPI Satisfaction — NPS & CSAT]]
- [[#🚩 9. Vanity metrics]]
- [[#🛠️ 10. Dashboards dynamiques dans Google Sheets]]
- [[#🏦 11. Transposition banking (hors cours)]]
- [[#🩹 12. Corrections & points d'attention sur le support]]
- [[#🎤 13. Angle entretien]]

---

## 🧭 1. Le contexte détermine les KPI

> **Good KPIs depend on the company's model and maturity.**

C'est la thèse de la session. Le même métier (« data analyst marketing ») ne suit pas du tout les mêmes indicateurs selon trois axes : **B2C/B2B**, **commande/abonnement**, **early-stage/mature**.

### B2C vs B2B

| | **B2C** | **B2B** |
|---|---|---|
| Volumétrie | **Volume de clients** élevé | **Volume de commandes** — beaucoup moins de comptes |
| Type d'analyse | **Quantitative** | **Qualitative** |
| Approche | **Standard**, industrialisée | **Personnalisée**, sur mesure |
| Traitement | **Automatisé** | **Manuel** (saisie CRM à la main par les commerciaux) |
| Business types | e-commerce, SaaS | e-commerce, SaaS, industrie |
| Data | Générée par le comportement (web, transactions) | Souvent **saisie à la main** → qualité hétérogène |

**Qui porte chaque phase du cycle client :**

| Phase | **B2C** | **B2B** |
|---|---|---|
| **Attract** | Media · Merchandising | Media *(rôle mineur : juste récupérer des coordonnées)* |
| **Develop** | CRM · Merchandising | **Sales** *(rôle majeur : qualification + transformation)* |
| **Support** | Customer service | **Customer success / care** |

> [!important] Ce que ça change pour un Data Analyst
> En **B2C**, la donnée est massive, propre-ish, générée automatiquement → l'enjeu est le **volume et la segmentation**.
> En **B2B**, la donnée est saisie manuellement dans le CRM par des commerciaux → l'enjeu est la **qualité, la complétude et la déduplication**. Une grosse partie du travail est du nettoyage et de la réconciliation, pas de l'analyse.
>
> Et le **Customer Success** est bien plus stratégique en B2B : c'est lui qui gère l'implémentation post-vente, le réachat et l'upsell. Une implémentation ratée ne fait pas partir le client tout de suite (les grosses boîtes ne changent pas d'outil sur un coup de tête) — mais elle génère de l'insatisfaction qui explose 1 à 2 ans plus tard.

### Modèle commande vs modèle abonnement

| | **Modèle commande** (majorité B2C) | **Modèle abonnement** |
|---|---|---|
| KPI central | **Taux de réachat** | **Rétention & churn** |
| Enjeu n°1 | Décrocher **la première conversion** | Garder le client |
| Enjeu n°2 | Augmenter le **panier moyen** | Faire monter en gamme (upsell) |
| Combien on paie un client | Au maximum ce que rapporte la commande | **Bien plus qu'un mois d'abonnement** |
| Logique d'acquisition | ROI à court terme | **Customer Lifetime Value** |

> [!tip] Pourquoi les télécoms sont si agressifs en pub
> L'exemple donné, très parlant : un opérateur facture ~20 €/mois, mais la durée de vie moyenne d'un client se compte en **années**. Il raisonne donc sur la **CLV** (ce que le client rapportera sur toute sa vie), pas sur le prix mensuel — et est donc prêt à payer 200, 300 ou 400 € pour l'acquérir. C'est exactement pour ça que leur communication est aussi offensive.
>
> Corollaire : **la CLV est ce qui autorise un CAC élevé.** Sans elle, tout budget d'acquisition supérieur au premier panier paraît irrationnel.

**Les leviers de rétention par business :**

| Business | Levier de rétention |
|---|---|
| Télécoms | Offre de renouvellement à échéance d'engagement (ils sont prêts à payer 5 €/mois de remise pour vous garder) |
| Netflix | **Création de contenu phare** — sortir régulièrement de quoi rester abonné. Pas d'offres de rétention : ils sont leaders |
| SaaS B2B | Élargir l'adoption à d'autres services de l'entreprise cliente. **Plus il y a de services utilisateurs, moins le client peut partir** |
| e-commerce | Programme de fidélité, accès anticipé, contenu exclusif |

### Maturité de l'entreprise

> **Early-stage → growth focus | Mature → efficiency & profit**

Une jeune boîte regarde la croissance (nombre d'utilisateurs, acquisition). Une boîte installée regarde l'efficacité et la rentabilité (marge, CAC, cost/income). Même secteur, même produit, KPI opposés.

**Et le même principe s'applique à l'échelle d'une équipe ou d'un canal :**

| Phase | Focus | KPI exemples (CRM) |
|---|---|---|
| 🚀 **Launch** | Engagement de base | Taux d'ouverture, taux de clic |
| ⚙️ **Optimize** | Conversion | Taux de conversion, taux de désinscription |
| 🎯 **Value** | Impact long terme | Réactivation, **LTV** |

> [!note] La lecture utile de ce tableau
> On ne « monte » pas d'un étage parce que c'est plus prestigieux, mais parce que **les KPI de l'étage précédent sont devenus stables**. Suivre la LTV sur une campagne lancée il y a trois semaines n'a aucun sens : il n'y a pas encore de recul. Inversement, piloter une équipe CRM mature sur le taux d'ouverture, c'est du [[#🚩 9. Vanity metrics]].

### La carte des équipes

Les trois pôles qu'on retrouve dans à peu près toute entreprise :

| **Growth & Revenue** | **Core Operations** | **Support Services** |
|---|---|---|
| Sales & Marketing | Operations & Production | Finance & Accounting |
| Customer Service | Product Development & Engineering | Human Resources |
| Business Development | | Information Technology |

Comme Data Analyst, trois configurations possibles :
1. **Rattaché à une équipe métier** (le DA de l'équipe marketing)
2. **Dans une équipe data centrale**, au service de plusieurs pôles
3. **Dans une très petite boîte** : au service de quasiment tous les services

> [!important] Qui définit les KPI — et ce qu'on attend de toi
> *« C'est toujours la personne qui est leader de l'équipe, ou au moins une personne senior. Vous pouvez faire des propositions, mais ce n'est pas vous qui décidez. »* — cohérent avec [[KPI Basics|le cours précédent]].
>
> **Ce qu'on attend de toi, c'est de savoir les calculer, et de les calculer juste.** Et l'intervenant ajoute une pratique concrète et sous-estimée : *« il faut avoir une connaissance des valeurs théoriques qu'on est censé obtenir pour chaque KPI, ça évite pas mal de problèmes »*.
>
> **Traduction opérationnelle : connaître l'ordre de grandeur attendu de chaque indicateur est un test de non-régression gratuit.** Un taux d'ouverture email à 26 % est plausible ; à 260 %, tu as divisé par la mauvaise colonne. Un CPC à 0,27 € est plausible ; à 27 €, tu as oublié un `/1000`. C'est ce réflexe qui aurait dû attraper la coquille de la slide média (voir [[#🩹 12. Corrections & points d'attention sur le support]]).

---

## 🎯 2. Le funnel d'acquisition

Quand on arrive dans une nouvelle boîte, la première question est : **comment cette entreprise gagne-t-elle de l'argent ?** Le funnel d'acquisition est la réponse structurée.

```
        ┌──────────────── AWARENESS ────────────────┐
          └────────────── INTEREST ──────────────┘
             └─────────── INTENT ───────────┘
                  └────── PURCHASE ──────┘
```

| Étape | **B2C** | **B2B** |
|---|---|---|
| **Awareness** | Voit une pub (réseaux sociaux, display) | Télécharge un e-book, visite le site |
| **Interest** | Visite le site | **A un call et une démo** ⭐ |
| **Intent** | **Ajoute un produit au panier** ⭐ · ou essai gratuit | Estime son besoin et demande un devis |
| **Purchase** | Transaction | Souscription / signature |

L'étape charnière n'est pas la même : en **B2B c'est la démo produit**, en **B2C c'est l'optimisation des pages produit et du tunnel de paiement**.

> [!note] Autre framework courant : AARRR
> Mentionné en passant — le funnel **AARRR** (« pirate metrics ») : **A**cquisition, **A**ctivation, **R**etention, **R**evenue, **R**eferral. Il couvre à peu près le même terrain mais intègre l'après-achat dans le même schéma, là où le cours sépare acquisition et expansion en deux funnels. *(Le transcript dit « réactivation » pour le 2ᵉ A — c'est « activation ».)*

### La règle : analyser le funnel à l'envers

> [!important] Partir des acheteurs et remonter
> *« On ne va pas regarder dans ce sens-là, on va plutôt regarder dans le sens inverse. Ça ne paraît pas logique, mais c'est mieux d'analyser d'abord les personnes qui ont acheté, voir leur comportement, ce qui a fait qu'elles ont acheté, et après on remonte le funnel. »*

Pourquoi ça marche : en partant de la conversion, on caractérise ce qui **fonctionne** avant de chercher ce qui casse — et chaque étape remontée pose une question actionnable et bornée.

| On remonte de… | Perte constatée | Question posée | À qui |
|---|---|---|---|
| Achat ← Paiement | 30 % d'abandons au paiement | La page fait-elle peur ? Trop de clics ? Un bug ? Le bouton est-il bien placé ? | Équipe produit / site |
| Paiement ← Panier | Beaucoup de visites produit, peu d'ajouts | Les pages produit convertissent-elles ? | Merchandising / produit |
| Panier ← Site | Peu de visiteurs sur les pages produit | Le trafic est-il qualifié ? | Marketing |
| Site ← Notoriété | Trop peu de trafic | Est-on meilleur qu'avant ? Peut-on ouvrir d'autres canaux ? | Media |

> [!warning] Prioriser sur le volume perdu, pas sur le taux — non dit en cours, et c'est le piège
> Une étape qui perd **80 % de 500 personnes** (400 perdues) est un problème plus petit qu'une étape qui perd **20 % de 50 000 personnes** (10 000 perdues). Le taux attire l'œil, le volume absolu porte l'argent.
>
> Le bon réflexe : sur chaque étape, calculer **et** le taux de conversion **et** le nombre absolu perdu, puis trier sur le second. Un plan d'action se justifie en volume et en euros, pas en points de pourcentage.

> [!tip] Deux taux de conversion à ne pas confondre
> - **Étape à étape** (`étape N / étape N-1`) : localise le point de friction
> - **Cumulé** (`étape N / tout en haut du funnel`) : mesure la performance globale
>
> Un taux étape-à-étape de 50 % sur quatre étapes donne un cumulé de 6,25 %. Annoncer « on convertit à 50 % » sans préciser lequel des deux, c'est une réunion qui part mal.

### Les canaux d'acquisition

Deux familles, deux objectifs, deux niveaux de traçabilité :

| | 🔴 **Performance** (objectif : achat) | 🔵 **Branding** (objectif : notoriété) |
|---|---|---|
| **Online** | SEA (Google, Bing), Social ads, **Retargeting**, Emailing, Affiliation | Display, contenu / articles |
| **Offline** | Flyers **avec code promo** | Panneaux, métro, TV, radio, salons & événements |
| Traçabilité | ✅ Mesurable | ❌ Très difficile à attribuer |

**Points clés :**

- **SEO ≠ SEA.** SEO = référencement **gratuit**, long terme, résultat incertain (*« pas toujours si évident, un sujet difficile à gérer »*). SEA = liens **payants** sur les moteurs de recherche.
- **Le SEA a un prix variable selon la qualité de ton site.** Google attribue un **score de qualité** à chaque site et le multiplie par ton enchère. Un bon site paie moins cher pour la même position. Critères : vitesse de chargement, qualité des textes, temps passé sur la page — donc **le SEO améliore le coût du SEA**. Les deux ne sont pas indépendants.
- **SEA branding** = enchérir sur son propre nom de marque. Contre-intuitif (« pourquoi payer pour des gens qui me cherchent déjà ? ») mais **très rentable** : ce sont des prospects à forte intention. Et c'est défensif — un concurrent peut enchérir sur ton nom et récupérer le clic.
- **Retargeting** : recibler sur d'autres sites les visiteurs de ton site (le canapé qui te suit pendant trois semaines). Très puissant, techniquement basé sur un identifiant device/navigateur.
- **Le principe des 7 points de contact** : on n'achète quasiment jamais au premier contact avec une marque. *« 7, c'est arbitraire, ne gardez pas ce chiffre en tête »* — ce qui compte, c'est le principe de la répétition. C'est ce qui justifie retargeting, emailing et relance panier abandonné.
- **Flyer avec code promo** = un canal offline qui devient mesurable. La leçon générale : **c'est le mécanisme de traçage qui fait basculer un canal de branding vers performance**, pas le support.
- **Affiliation** : rémunérer un tiers (site, influenceur) au client apporté via un lien ou un code. Très présent chez les paris sportifs.

> [!warning] L'angle mort du cours : l'attribution
> Le sujet n'est jamais nommé, alors que les « 7 points de contact » le posent directement. Si un client voit une pub display, clique sur un retargeting, puis tape le nom de la marque sur Google avant d'acheter — **quel canal a fait la vente ?**
>
> - **Last-click** (le défaut de la plupart des outils) : tout le crédit au dernier clic → survalorise systématiquement le SEA branding et le retargeting, sous-valorise le display et le social
> - **First-click** : tout au premier contact → l'inverse
> - **Multi-touch / data-driven** : répartit le crédit entre les points de contact
>
> Conséquence très concrète : **si tu coupes un canal parce que son CAC last-click est mauvais, tu peux faire chuter la performance de tous les autres.** C'est le premier piège qu'on te tendra sur un poste de DA marketing.

---

## 🔁 3. Le funnel d'expansion

Ce qui se passe **après** l'achat. Le cours le présente comme une pyramide inversée par rapport au funnel d'acquisition.

```
                  ▲  PURCHASE
                 ███  SUPPORT
                █████  RETAIN
               ███████  DEVELOP
```

| Étape | **B2C** | **B2B** |
|---|---|---|
| **Purchase** | Suivi de commande | **Implémentation** |
| **Support** | Service client (livraison, produit défectueux — réactivité) | **Onboarding et support** (formations, mise en avant des nouvelles fonctionnalités) |
| **Retain** | Programme de fidélité, campagnes de rétention | Offres de renouvellement & campagnes |
| **Develop** | Campagnes, **cross-sell** | **Upsell et cross-sell** |

> [!note] Comment lire la forme du schéma — l'intervenant le relève lui-même
> Le schéma s'élargit vers le bas, ce qui suggère une population croissante. **C'est faux en volume** : *« en général on le ferait plutôt dans l'autre sens, parce qu'on a de moins en moins de personnes »*. L'élargissement est **symbolique : c'est la valeur générée par client qui augmente**, pas le nombre de clients. À ne pas confondre avec un vrai funnel de conversion.

**Upsell vs cross-sell** — la confusion classique :

| | Définition | Exemple |
|---|---|---|
| **Upsell** | Faire passer sur un **plan supérieur du même produit** | Basic → Premium |
| **Cross-sell** | Faire acheter un **autre produit** | Amazon : *« les gens achètent aussi ce produit avec »* |

Les deux sont les deux seules façons d'augmenter le CA sur une base existante — l'alternative étant d'acquérir plus de clients. **Trois leviers de croissance au total : plus de clients, clients qui paient plus, clients qui restent plus longtemps.**

> [!tip] Le mécanisme de verrouillage en B2B
> *« Plus vous touchez de services chez le client, moins vous avez de chance qu'il s'en aille sur le long terme. »* Vendre à un service et ne pas élargir = churn programmé. C'est pourquoi le KPI B2B SaaS de référence n'est pas le nombre de clients mais **le nombre de sièges actifs / la profondeur d'adoption** — et pourquoi la fréquence d'usage est le meilleur signal précoce de churn.

---

## 🧩 4. La segmentation client

> **Segmenting = grouping customers with similar characteristics to better understand and target them.**

Le point de départ : *« C'est rare que vous n'ayez qu'un seul type de client, vous allez toujours en avoir au moins 3 ou 4 »* — les **personas**. Une marque de chaussures touche les 15-25 ans **et** les plus de 50 ans, avec des modèles et des messages différents.

### Les quatre axes du cours

| Axe | Contenu | Contexte de prédilection |
|---|---|---|
| **RFM** | **R**ecency · **F**requency · **M**onetary value | B2C retail, produits à réachat régulier |
| **Purchase type** | Catégorie de produit, plan d'abonnement | Abonnement, catalogue large |
| **Behavior** | Réponse aux offres, **sensibilité aux promos** | Retail, e-commerce |
| **Profile** | Âge, genre, localisation (socio-démographique) | Mode, contenu |

**Le bénéfice attendu : analyse plus granulaire → actions plus pertinentes** (campagnes, offres, support).

### L'analyse RFM en détail

Trois indicateurs, **combinés** (pas multipliés) pour identifier les clients les plus rentables :

| | Définition | Ce que ça capte |
|---|---|---|
| **Recency** | Date du dernier achat | Le client est-il encore actif ? |
| **Frequency** | Nombre d'achats sur une période, ou nombre de jours moyen entre deux achats | À quelle fréquence revient-il ? |
| **Monetary** | Montant dépensé | Combien il pèse |

L'exemple qui rend le M indispensable : *« si vous venez tous les jours mais achetez pour 5 €, ou quelqu'un qui vient une fois par semaine mais achète pour 500 € — c'est le second qui est plus intéressant. »* R et F seuls désignent le mauvais client.

> [!tip] Le cas d'application le plus concret : les coupons de caisse
> L'intervenant a travaillé pour le leader du secteur. Vous passez votre carte de fidélité, et l'imprimante crache des coupons calculés **sur votre historique d'achat** : soit le produit que vous venez d'acheter avec une promo pour la prochaine fois, soit un produit similaire. C'est de la segmentation comportementale exécutée en temps réel, à la caisse.

**Autres actions déclenchées par la segmentation en retail :**
- Campagnes **VIP** pour les gros clients
- Sur un client à fréquence stable → travailler le **panier moyen**
- **Produits d'appel** : une promo agressive sur un produit pour faire venir en magasin et faire acheter le reste (les glaces en été, typiquement)

> [!warning] Deux limites à garder en tête
> **Volume.** L'intervenant est explicite : croiser rétention × segmentation fine exige une base suffisante. *« Si tu as 1 000 nouveaux clients, tu ne feras pas une segmentation aussi précise. »* Netflix, avec potentiellement 100 à 200 k nouveaux clients par mois, peut segmenter par genre ; une PME analysera ses nouveaux clients en bloc. Chaque croisement divise l'effectif — et un taux sur un petit effectif ne veut rien dire (cf. [[Taux sur variable binaire]]).
>
> **Légalité.** Question posée en séance sur la segmentation par genre, réponse honnête : *« Déjà, est-ce que c'est légal ? Je ne sais pas. »* En Europe, le RGPD encadre strictement les données personnelles, et le genre, l'âge ou la localisation ne se traitent pas comme un montant d'achat. **En banque, ce sujet est un point de contrôle en soi** — ne jamais segmenter sur un critère sensible sans validation juridique/conformité.

---

## 📈 5. L'analyse de cohorte

**Le principe :** on regroupe les clients par **période de première commande** (mois, semaine, ou jour selon le volume), et on suit **chaque groupe séparément** dans le temps.

C'est ce qui distingue une cohorte d'un simple suivi de la base : sur la ligne « janvier », on ne parle **que** des clients arrivés en janvier, pour toujours.

### Le tableau du cours (reconstruit)

> [!warning] Reconstruction partielle
> Pas de capture de cette slide. Les valeurs ci-dessous sont **reconstruites depuis la description orale** — les cases vides sont celles qui n'ont pas été énoncées. La structure et les chiffres cités sont fiables, le reste est incomplet.

**En volume :**

| Cohorte | M0 | M+1 | M+2 | … | M+5 | M+6 |
|---|---|---|---|---|---|---|
| **Janvier** | 40 | 30 | | | 11 | **12** ⬆️ |
| **Février** | 70 | ~48 | | | | |
| **Mars** | 45 | ~36 | | | | |
| **Avril** | 80 | ~59 | | | | |

**En pourcentage** *(le même tableau, normalisé — c'est celui qu'on lit)* :

| Cohorte | M0 | M+1 |
|---|---|---|
| **Janvier** | 100 % | **75 %** |
| **Février** | 100 % | **69 %** |
| **Mars** | 100 % | **80 %** |
| **Avril** | 100 % | **74 %** |

> [!important] Pourquoi les deux tableaux, et pas un seul
> Le tableau **en volume** dit combien de personnes sont en jeu. Le tableau **en pourcentage** dit si la performance s'améliore. Il faut les deux : février a le plus gros M0 (70) **et** la pire rétention (69 %) — c'est précisément le signal d'une campagne d'acquisition agressive qui a ramené du volume mal qualifié.
>
> C'est l'hypothèse que l'intervenant formule lui-même : *« on a peut-être fait des campagnes plus agressives pour toucher d'autres cibles, mais ce ne sont pas des clients très qualifiés. »*

### La méthode d'interprétation

1. Construire le tableau
2. **Lister les actions menées sur chaque période** (campagnes, refonte du site, changement produit, lancement de contenu)
3. Confronter les deux : *« Entre février et mars, qu'est-ce qui s'est passé qui explique cette baisse ? »*

C'est ce qui transforme le tableau en analyse : **une cohorte seule ne dit rien, une cohorte confrontée à un calendrier d'actions dit tout.**

### Les trois formes de courbe

```
100% ┤╲                                   100% ┤╲                       100% ┤╲
     │ ╲___________  ← plateau ✅              │ ╲                           │ ╲___     ╱  ← smile
     │                                         │  ╲___                       │     ╲___╱
  0% ┤                                      0% ┤      ╲____  ← mort ❌     0% ┤
```

| Forme | Diagnostic |
|---|---|
| **Décroissance puis plateau** ✅ | L'objectif. Les insatisfaits partent (normal), les satisfaits restent |
| **Décroissance jusqu'à zéro** ❌ | Deux causes possibles : produit pas assez différenciant, **ou besoin résolu trop vite** |
| **Courbe en sourire** 🙂 | Un plateau + des campagnes de **réactivation** qui font remonter la courbe |

> [!tip] Le cas contre-intuitif : le client satisfait qui part
> *« Vous répondez tellement bien au besoin qu'ils n'en ont plus besoin. »* L'exemple donné est Duolingo : si l'app vous apprend vraiment la langue, vous arrêtez de payer — **parce que ça a marché**. Ce sont des clients contents qui churnent.
>
> C'est un cas où le taux de churn **ne mesure pas l'insatisfaction**. À creuser via le NPS des churnés : churn + NPS bas = problème produit ; churn + NPS haut = besoin résolu, et la réponse est un nouveau produit, pas une campagne de rétention.

> [!important] Le mécanisme central : plateau + acquisition = croissance incrémentale
> *« Si la rétention est meilleure et qu'on garde le même niveau d'acquisition, on est censé avoir une courbe croissante d'utilisateurs. »*
>
> Chaque nouvelle cohorte dépose son plateau **par-dessus** les précédents. La base active est la **somme des plateaux**. C'est pour ça que l'intervenant dit que sur un service par abonnement, *« la priorité absolue, ce n'est pas l'acquisition, c'est de créer ce plateau »* : sans plateau, acquérir revient à remplir un seau percé.

### Les campagnes de réactivation (« ghosts »)

Une fois le plateau atteint, on va chercher les clients perdus **3 à 6 mois plus tard**. Logique : ils ont peut-être testé le produit au mauvais moment. Sur le tableau reconstruit, la cohorte de janvier passe de **11 à M+5 à 12 à M+6** — c'est la signature d'une réactivation réussie (et l'intervenant note qu'on a peut-être perdu 3 et regagné 4 : le net cache les flux bruts).

### Quand faire une cohorte

| Situation | Maille |
|---|---|
| SaaS / abonnement, suivi standard | Mensuelle |
| Produit à usage quotidien (type Duolingo) | **Journalière** sur J+1 → J+14, puis hebdomadaire |
| Mesurer l'impact d'une refonte de site ou produit | Comparer les cohortes avant/après |
| Mesurer l'effet d'un lancement de contenu (série, droits sportifs) | Deux questions : **pic de nouveaux clients** ? **hausse de la rétention des cohortes antérieures** ? |

> [!note] Ce que le cours ne dit pas — les liens algébriques
> Trois formules qui relient tout ce chapitre au précédent et qui tombent en entretien :
>
> ```
> Taux de churn        = 1 − taux de rétention
> Durée de vie moyenne ≈ 1 / taux de churn périodique
> LTV                  ≈ ARPU × durée de vie × taux de marge
> ```
>
> Concrètement : churn mensuel de 5 % → durée de vie ≈ 20 mois. À 20 €/mois et 70 % de marge → LTV ≈ 280 €. Et **c'est ce chiffre qui plafonne le CAC** — voir [[#Le chaînon manquant — le ratio LTV sur CAC]].
>
> Attention : ces formules supposent un churn constant, ce qui est faux au début (il est toujours plus élevé les premiers mois). Elles donnent un ordre de grandeur, pas une valeur exacte. C'est justement l'utilité du plateau : une fois atteint, l'hypothèse de churn constant devient raisonnable.

---

## 📣 6. KPI Médias — l'acquisition payante

Cas Greenweez, campagne **SEA – Alphabuy Shopping – Google** :

| KPI | Définition | Formule | Valeur |
|---|---|---|---|
| **CTR** | Click Through Rate | `Clics / Impressions` | 29 844 / 3 520 879 = **0,85 %** |
| **CPC** | Cost Per Click | `Coût / Clics` | 8 034 / 29 844 = **0,27 €** |
| **CAC** | Customer Acquisition Cost | `Coût / Nouveaux clients` | 8 034 € / 146 = **55,03 €** |
| **ROAS** | Return On Ad Spend | `CA / Coût` | 22 420,20 € / 8 034 € = **2,79** |

*(⚠️ deux corrections appliquées vs la slide — voir [[#🩹 12. Corrections & points d'attention sur le support]])*

Et un cinquième, mentionné à l'oral mais absent de la slide :

| **CPM** | Cost Per Mille | `Coût / Impressions × 1 000` | Combien on paie pour 1 000 affichages |

### L'ordre de lecture

L'intervenant donne un ordre de priorité, et il est logique — **on descend le funnel** :

```
CPM  →  CTR  →  CPC  →  CAC  →  ROAS
 ↑       ↑       ↑       ↑        ↑
coût   attrac-  coût   coût    rentabilité
d'ex-  tivité   du     d'un    finale
position  du    trafic client
          message
```

> [!tip] Les trois premiers sont algébriquement liés — non dit en cours
> ```
> CPC = CPM / (1 000 × CTR)
> ```
> Un CPC élevé a donc **exactement deux causes** : soit l'espace publicitaire est cher (CPM), soit la créa n'accroche pas (CTR). Savoir laquelle des deux détermine l'action : renégocier/changer de plateforme, ou refaire les visuels et le wording. Sans ce découpage, on constate un mauvais CPC sans savoir quoi en faire.

### Le CAC et la logique de scale

Le CAC est **le** KPI de décision. Il ne se lit jamais seul : il se compare à une **cible fixée à l'avance**.

| Situation | Décision |
|---|---|
| CAC **>** cible | Optimiser la campagne pour repasser sous la cible, ou l'arrêter et tester autre chose |
| CAC **<** cible | **Scaler** : augmenter le budget. Si on maintient la performance en touchant plus de monde, on génère plus de revenu |

> [!warning] Le scale a une limite, et le cours ne la donne pas
> Augmenter le budget ne conserve pas la performance indéfiniment. On commence par les audiences les plus qualifiées ; en élargissant, on touche des profils de moins en moins pertinents, et **le CAC remonte mécaniquement**. C'est la saturation d'audience.
>
> Réflexe : après un scale, ne pas comparer le CAC moyen avant/après (il est dilué par l'historique) mais le **CAC marginal** — combien coûtent les clients acquis *depuis* l'augmentation de budget.

### Périmètre temporel : vie de campagne vs mois glissant

Question posée en séance. Les deux ont un sens et répondent à deux questions différentes :

| Périmètre | Ce que ça mesure |
|---|---|
| **Depuis le lancement** | Le bilan global : cette campagne a-t-elle valu le coup ? |
| **Mois par mois** | La performance actuelle : est-elle encore bonne *maintenant* ? |

L'intervenant préférait le mois glissant, pour une raison précise : une campagne démarre souvent mal (mauvais wording, mauvaises créas) puis s'améliore. Le cumul depuis le lancement **masque une campagne devenue excellente** derrière ses débuts ratés. **À toujours préciser dans un dashboard : quel périmètre est affiché.**

### ⚠️ ROAS — le calcul est sur le CA, pas sur la marge

C'est le point le plus important de la section, et l'énoncé du cours est trompeur.

**Ce qui a été dit :** *« un ROAS de 3, ça veut dire que pour 1 € investi on a récupéré 3 €, dont l'euro investi, donc on a fait au moins 2 € de marge. »*

**C'est faux.** Le ROAS est calculé sur le **chiffre d'affaires**. Les 2 € restants ne sont pas de la marge : il faut encore payer le produit, la logistique, l'expédition. Voir [[Marge brute, marge opérationnelle, marge nette]].

**Le calcul juste :**

```
Contribution = (CA × taux de marge) − dépense pub

À l'équilibre :  ROAS seuil = 1 / taux de marge
```

| Taux de marge | ROAS d'équilibre |
|---|---|
| 50 % | 2,0 |
| 33 % | 3,0 |
| **20 %** | **5,0** |
| 10 % | 10,0 |

> [!important] L'intervenant se corrige lui-même deux minutes plus tard
> *« Dans mon ancienne boîte, on visait un objectif de rentabilité aux alentours de 80 %. C'est-à-dire qu'il fallait faire du 5 pour 1 pour rentrer globalement dans nos frais. »*
>
> 80 % de coûts → **20 % de marge** → ROAS d'équilibre de **5**. La formule est exactement respectée. La phrase précédente sur « 2 € de marge » était un raccourci.
>
> **Conclusion à retenir : un ROAS n'a aucun sens sans le taux de marge de l'entreprise.** Un ROAS de 3 est excellent chez un éditeur de logiciel (marge 80 %, seuil à 1,25) et catastrophique chez un distributeur alimentaire (marge 15 %, seuil à 6,7). Comparer des ROAS entre secteurs ne veut rien dire.

### Le chaînon manquant — le ratio LTV sur CAC

Le cours donne la **CLV** d'un côté (section abonnement) et le **CAC** de l'autre (section média), sans jamais les croiser. C'est pourtant l'indicateur qui décide de la viabilité d'un modèle.

```
Ratio LTV / CAC
```

| Ratio | Lecture |
|---|---|
| **< 1** | On perd de l'argent sur chaque client acquis |
| **≈ 1–2** | Modèle fragile, aucune marge pour les coûts fixes |
| **≈ 3** | Le repère usuel : sain et scalable |
| **> 5** | Souvent le signe qu'on **sous-investit** en acquisition — il y a de la croissance laissée sur la table |

Et son complément temporel, le **CAC payback period** : au bout de combien de mois le client a-t-il remboursé son coût d'acquisition ? Un LTV/CAC de 3 avec un payback de 30 mois est un problème de trésorerie même s'il est rentable sur le papier.

> [!tip] Pourquoi c'est le bon niveau d'analyse
> C'est ce ratio qui explique le comportement des télécoms mentionné en début de cours : payer 300 € pour un client à 20 €/mois est parfaitement rationnel si la LTV est de 900 €. Sans le ratio, ça ressemble à une folie.

---

## ✉️ 7. KPI CRM — l'emailing

Cas Greenweez, campagne **210805_nl_generale** (newsletter générale) :

| KPI | Formule | Valeur |
|---|---|---|
| **Opening rate** | `Ouvertures / Emails envoyés` | 20 029 / 77 182 = **26,0 %** |
| **Click rate** | `Clics / Emails envoyés` | 2 233 / 77 182 = **2,9 %** |
| **CTR** | `Clics / Ouvertures` | 2 233 / 20 029 = **11,1 %** |
| **Turnover per mille** | `CA / Emails × 1 000` | 8 208 € / 77 182 × 1 000 = **106 €** |

### Comment les lire ensemble

```
Emails envoyés  ──ouverture──▶  Ouvertures  ──CTR──▶  Clics  ──conversion──▶  CA
                    26 %                      11,1 %
                └──────────── click rate : 2,9 % ────────────┘
```

| KPI | Ce qu'il diagnostique | Ce qu'on corrige |
|---|---|---|
| **Taux d'ouverture** | La qualité de **l'objet** et de l'expéditeur, la délivrabilité | Objet, nom d'expéditeur, heure d'envoi, hygiène de base |
| **CTR** (clics/ouvertures) | La qualité du **contenu** — le mail tient-il la promesse de l'objet ? | Contenu, offre, design, position des boutons |
| **Taux de clic** (clics/envois) | La performance **globale** de la campagne | Les deux ci-dessus |
| **Revenu / 1 000 emails** | La **valeur économique** — le seul qui parle en euros | Ciblage, offre, page d'atterrissage |

> [!important] Le CTR est l'indicateur le plus important — avec une condition
> *« Pour moi c'est l'indicateur le plus important sur l'email. Mais si on a un taux d'ouverture à 2 % et un super CTR, ce n'est pas ouf. »*
>
> Autrement dit : **le CTR est un taux conditionnel**. Il mesure la pertinence du contenu *pour ceux qui ont ouvert* — un public auto-sélectionné. Sur une base de 2 % d'ouvreurs, un CTR de 50 % ne représente que 1 % des destinataires. C'est exactement le piège du dénominateur de [[Taux sur variable binaire]] : toujours afficher le CTR **à côté** du taux d'ouverture, jamais seul.

> [!note] Contextualiser par type de campagne
> Une campagne **promotionnelle** et une campagne **informationnelle** n'ont pas les mêmes attentes — pas la même conversion, pas le même revenu/mille. Les comparer directement n'a aucun sens. Le bon réflexe : **regrouper les campagnes par type et ne comparer qu'à l'intérieur d'un groupe.**

> [!warning] Le taux d'ouverture n'est plus fiable — hors cours, mais critique
> Depuis **Apple Mail Privacy Protection** (iOS 15, septembre 2021), le client mail d'Apple **précharge automatiquement les images** de tous les messages, ouverts ou non. Comme la mesure d'ouverture repose sur un pixel image invisible, cela génère des ouvertures fantômes en masse.
>
> Conséquences pratiques : le taux d'ouverture est **gonflé et non comparable dans le temps** de part et d'autre de cette date (le dataset Greenweez est justement de 2021) ; le CTR, qui a les ouvertures au dénominateur, est **mécaniquement déflaté** ; et l'industrie s'est largement déplacée vers le **taux de clic** et le **revenu par email** comme indicateurs de référence. À savoir si le sujet arrive en entretien — c'est un marqueur de quelqu'un qui a suivi le métier.

### Analyse des clics par bouton

Au-delà des taux globaux, on descend au niveau du **bloc** : quel bouton de l'email a généré les clics ?

Ce que ça permet : identifier les blocs qui portent réellement l'engagement, et repérer les faux positifs (*« il y a des boutons qui sont plus faits pour être cliqués, forcément »* — un CTA visuellement dominant capte du clic par design, pas par intérêt).

### Faire évoluer les KPI avec la maturité

Le tableau de la slide 4, appliqué au CRM :

| Phase | Focus | KPI |
|---|---|---|
| 🚀 **Launch** | Engagement de base — *on teste, on cherche ce qui plaît* | Ouverture, clic |
| ⚙️ **Optimize** | Conversion — *on sait ce qui plaît, on affine* | Taux de conversion, **taux de désinscription** |
| 🎯 **Value** | Impact long terme | Campagnes de **réactivation** (ghosts), **LTV** |

> [!tip] Le taux de désinscription est le garde-fou du CRM
> C'est le seul indicateur qui pénalise le sur-envoi. Sans lui, on optimise le volume d'ouvertures en spammant — et on brûle la base. *« Comment on touche les bonnes personnes avec le bon message »*, c'est exactement ce que ce taux mesure en creux.

### Le churn prédictif

Point important glissé en fin de section : à partir des signaux comportementaux, **on peut modéliser la probabilité de départ d'un client**, et déclencher une campagne ciblée avant qu'il ne parte.

| Business | Signal précoce de churn |
|---|---|
| Netflix | Fréquence d'usage en baisse (*« avant vous y alliez tous les jours, maintenant une fois par semaine »*) → départ probable dans 3–6 mois |
| SaaS B2B | Nombre d'utilisateurs actifs dans l'entreprise cliente, fréquence de connexion, fonctionnalités utilisées |

> [!note] C'est exactement ton projet portfolio
> Ce paragraphe décrit un modèle de **scoring de churn** : features comportementales → probabilité de départ → action ciblée. C'est le passage du descriptif au prédictif dont parle [[Reporting vs analyse ad hoc]], et c'est la brique qui différencie un portfolio banking d'un dashboard de plus.

---

## 😀 8. KPI Satisfaction — NPS & CSAT

Le **NPS** est traité en détail dans sa fiche dédiée : [[NPS (Net Promoter Score)]]. Ce que cette session ajoute :

### Segmenter le NPS

Le NPS global est un point de départ. Le cours montre deux découpages sur le cas Greenweez :

| Segmentation | Usage |
|---|---|
| **Par transporteur / mode de livraison** | La livraison étant critique en e-commerce, c'est l'axe qui déclenche des actions fournisseur |
| **Par type de client** (nouveaux / fréquents / anciens) | Un nouveau client insatisfait et un ancien client insatisfait n'appellent pas les mêmes actions |

Le cas concret présenté : une **dégradation de la satisfaction sur Chronopost à domicile et DPD Pickup**. Les questions qui suivent : la qualité du livreur a-t-elle baissé ? Le problème est-il chez nous (produits défectueux, préparation) ? — et c'est cette segmentation qui rend la question posable.

### CSAT — Customer Satisfaction Score

| | **NPS** | **CSAT** |
|---|---|---|
| Question | *Recommanderiez-vous ?* | *Êtes-vous satisfait de [cette interaction] ?* |
| Échelle (ici) | 0 à 10 | **0 à 5** |
| Portée | Relation globale, long terme | **Transactionnel**, à chaud |
| Usage dans le cas | Score global + par segment | Score par **moyen de livraison**, suivi dans le temps |

> [!warning] Le CSAT n'a pas de définition unique
> Contrairement au NPS dont la formule est normée, le CSAT varie : échelle 0–5, 1–5 ou 1–10 ; restitué en **moyenne** ou en **% de répondants satisfaits** (typiquement les notes 4 et 5). **Deux entreprises annonçant « CSAT 4,2 » ne mesurent pas forcément la même chose.** Toujours demander l'échelle et le mode de calcul avant de comparer quoi que ce soit.

### Benchmarks NPS — à manier avec précaution

L'intervenant avance qu'un score correct se situerait **autour de 40–70** selon le secteur, et qu'un score légèrement positif ne suffit pas.

> [!warning] Ces chiffres sont des ordres de grandeur, pas une norme
> L'intervenant le reconnaît lui-même dans le même échange : *« c'est difficile à dire, ça dépend de ton secteur, de ton produit »*, et *« tu vas avoir du mal à faire un benchmark des NPS des concurrents »* — les entreprises ne publient pas leurs scores. Ajoute à ça les biais de notation évoqués en séance (formulaires pré-remplis, cultures nationales), et un benchmark externe devient très peu fiable.
>
> **La bonne pratique est celle que l'intervenant donne juste après**, et c'est la plus solide : Le Wagon calcule le NPS de **chaque batch** et le compare **à ses propres batchs précédents**. Ils connaissent leur moyenne, ils savent ce qu'ils peuvent attendre, et un écart déclenche une action. Le benchmark interne dans le temps bat toujours le benchmark externe.

---

## 🚩 9. Vanity metrics

Un des concepts les plus réutilisables de la session, et il s'applique bien au-delà du CRM.

**Définition** : un indicateur flatteur qui monte sans que la performance réelle suive.

**Le cas d'école donné :** un excellent **taux d'ouverture**. Ça veut dire que l'objet du mail est attirant. Mais si le contenu ne tient pas la promesse de l'objet, les gens sont déçus, ne cliquent pas, n'achètent pas. Le KPI est vert, le CA ne bouge pas.

> [!important] Le test, en une question
> ### *« Si cet indicateur augmente, est-ce que mon chiffre d'affaires augmente ? »*
>
> S'il y a une corrélation, c'est un bon indicateur de suivi. Sinon, c'est une vanity metric.

**Les suspects habituels :**

| Vanity metric | Pourquoi ça flatte | Ce qu'il faut suivre à la place |
|---|---|---|
| Nombre d'emails envoyés | Monte quand on travaille plus, pas mieux | Revenu / 1 000 emails |
| Taux d'ouverture seul | Mesure l'objet, pas le contenu | CTR + conversion |
| Nombre d'impressions | Monte avec le budget, mécaniquement | CTR, CPC, CAC |
| Followers / inscrits **cumulés** | Ne peut structurellement pas baisser | Taux d'engagement, actifs sur la période |
| Nombre de téléchargements | Ignore ce qui se passe après | Activation, rétention J+7 |

> [!tip] Deux raffinements au test, non dits en cours
> **1. Corrélation ≠ causalité.** Le nombre d'impressions corrèle avec le CA — parce que les deux montent avec le budget. Ça n'en fait pas un bon KPI de pilotage. Le vrai critère est : *cet indicateur est-il **actionnable** indépendamment ?*
>
> **2. Les cumuls sont presque toujours des vanity metrics.** Tout indicateur qui ne peut mathématiquement pas baisser (total d'inscrits depuis le lancement, CA cumulé, nombre de clients « jamais ») ne peut pas signaler un problème. Un KPI doit pouvoir devenir rouge — sinon il ne sert à rien. Cf. [[KPI vs métrique]].

---

## 🛠️ 10. Dashboards dynamiques dans Google Sheets

Démo de fin de séance, en réponse aux questions. La technique : un **menu déroulant qui pilote un tableau, un TCD et un graphique**. C'est le premier vrai dashboard interactif du cursus.

> [!note] Reconstruction
> Les formules ci-dessous sont **reconstruites** depuis la description orale (le transcript est très dégradé sur cette partie : « Journey ID » / « Journal Name » sont vraisemblablement `journey_id` / `journey_name`, « block name » = `block_name`, les libellés des boutons de l'email). La logique est fidèle, les noms de champs sont indicatifs.

### Étape 1 — Le menu déroulant

`Données` → `Validation des données` → critère **Liste à partir d'une plage**.

> [!tip] Ne jamais saisir les options à la main
> L'option par défaut demande de taper les valeurs une par une. **Pointer une plage à la place** : Sheets déduplique automatiquement (une plage avec des doublons ne produit que des valeurs uniques dans la liste), et la liste se met à jour quand la source évolue. Saisir en dur, c'est une liste morte le jour où une campagne est ajoutée.

### Étape 2 — Le tableau filtré

```
=FILTER(A5:F; A5:A = $C$4)
```

Où `$C$4` est la cellule du menu déroulant. La plage est **ouverte** (`A5:F`, pas `A5:F200`) pour absorber les nouvelles lignes — même principe qu'`IMPORTRANGE` dans [[Google Sheets]].

### Étape 3 — Le TCD piloté par le menu

Dans le tableau croisé dynamique, ajouter un **filtre** sur le champ campagne :
`Filtrer par condition` → **« Le texte est exactement »** → `=C4`

Le TCD se recalcule à chaque changement du menu déroulant.

> [!warning] Une seule condition de filtre par champ
> Limitation relevée en direct : dans un TCD Google Sheets, **on ne peut poser qu'un filtre par colonne**. Si un filtre existe déjà sur le champ, il faut le retirer avant d'en poser un autre — ou filtrer sur une colonne différente.

### Étape 4 — COUNT vs COUNTA dans le TCD

| Fonction | Compte | Quand l'utiliser |
|---|---|---|
| `COUNT` | Uniquement les valeurs **numériques** | Une colonne de nombres |
| `COUNTA` | **Toute valeur non vide** | Une colonne de texte (nom de bloc, libellé…) |

> [!tip] Le réflexe du choix de colonne
> Pour compter des lignes, choisir **une colonne sans valeur vide** — sinon le comptage est silencieusement faux. Même famille de piège que celui d'`AVERAGE` sur du binaire ([[Taux sur variable binaire]]) : la fonction ignore les vides sans rien signaler.

### Étape 5 — Le pourcentage, sans formule

Dans le TCD, sur la valeur : `Afficher en tant que` → **% du total**.

| Option | Effet | Quand |
|---|---|---|
| **% du total général** | Part de chaque ligne dans l'ensemble | Le cas standard |
| **% de la ligne** | Répartition à l'intérieur d'une ligne | Quand les données à comparer sont **en colonnes** |
| **% de la colonne** | Répartition à l'intérieur d'une colonne | Structure inverse |

Remarque faite en direct : sur un tableau à **une seule valeur par ligne**, le « % de la ligne » donne 100 % partout — logique, et un bon rappel qu'il faut savoir dans quel sens son tableau est construit.

> [!important] Encore [[Aggregate before divide]]
> Cette option calcule `valeur du groupe / total`, donc **après agrégation**. C'est le calcul correct, et il est fait par l'outil sans qu'on écrive de formule — donc sans risque de se tromper. À chaque fois qu'un ratio par rapport à un total est demandé, chercher d'abord si l'outil sait le faire nativement.

### Étape 6 — Le graphique

Le graphe pointe sur les plages du TCD (`B12:B37`, `C12:C37`), donc il suit le menu déroulant automatiquement. **C'est la brique de base d'un dashboard** : un critère → plusieurs visuels. On peut d'ailleurs piloter une partie des graphiques par un critère et une autre partie par un second critère.

### Alternative : les slicers

Les **segments** (`Données` → `Ajouter un segment`) font le même travail de filtrage, avec l'avantage de pouvoir en poser un par source de données quand un dashboard en agrège plusieurs.

> [!note] Le cadrage donné par l'intervenant
> *« Dans la pratique, même dans une petite entreprise, il est peu probable que vous fassiez des dashboards sur Google Sheets. »* L'intérêt ici est **l'entraînement** : la logique (filtre → agrégation → visuel réactif) est la même sur Looker Studio et Power BI. Dans Sheets, on fait surtout de l'**analyse exploratoire**, pas des dashboards de production.
>
> *(Le transcript dit « ça serait plus optimal de le faire avec Google Sheets » — coquille manifeste de la transcription, il voulait dire Looker/Power BI.)*

---

## 🏦 11. Transposition banking (hors cours)

Toute cette session est marketing B2C. Ce qui se transpose, ce sont les **structures**, pas les noms.

| Concept du cours | Équivalent banque privée |
|---|---|
| **Funnel d'acquisition** | Prospect → RDV → proposition → **ouverture de compte / mandat signé** |
| **Funnel d'expansion** | Onboarding → **Net New Money** → élargissement du mandat (crédit lombard, prévoyance, immobilier) |
| **CAC** | Coût d'acquisition d'un client, très élevé et amorti sur des années |
| **CLV / LTV** | Revenu actualisé sur la durée de relation — souvent **décennale** en gestion de fortune |
| **Analyse de cohorte** | Rétention des clients par **année d'entrée en relation** ; attrition d'AuM par cohorte |
| **Churn** | **Attrition** : sorties d'AuM, clôtures de mandats, départ d'un gérant emportant son portefeuille |
| **Segmentation RFM** | Segmentation par **tranche d'AuM**, fréquence d'interaction, produits détenus |
| **Cross-sell / upsell** | **Taux de détention produits par client** — le KPI de développement du portefeuille |
| **Vanity metric** | Nombre de comptes ouverts (vs AuM effectivement transférés), nombre de RDV (vs mandats signés) |
| **NPS / CSAT** | Très utilisés en wealth management, sur de petits échantillons → cf. les précautions de [[NPS (Net Promoter Score)]] |

> [!tip] Ce qui se raconte le mieux en entretien
> **L'analyse de cohorte.** C'est un outil que peu de candidats juniors maîtrisent vraiment, il est directement transposable à l'attrition d'AuM, et il démontre une compétence technique (pivot par période relative) doublée d'une lecture business (plateau, qualité d'acquisition). Bien plus différenciant qu'une liste de KPI marketing.

---

## 🩹 12. Corrections & points d'attention sur le support

**1. ⚠️ Coquille sur la slide Média — 8 304 vs 8 034**
La ligne **CPC** indique `8,304 / 29,844 = 0.27€`. Les deux lignes suivantes (CAC et ROAS) utilisent **8,034 €** pour le même coût de campagne. Vérification : `8 304 / 29 844 = 0,278` (≈ 0,28), alors que `8 034 / 29 844 = 0,269` (≈ 0,27). **C'est bien 8 034 € qui est correct** — les chiffres 0 et 3 ont été intervertis sur la ligne CPC. Le résultat affiché (0,27 €) est juste, seul le numérateur est faux.
→ Illustration parfaite du conseil de l'intervenant sur les ordres de grandeur : c'est exactement le type d'erreur qu'un contrôle de cohérence attrape.

**2. ⚠️ Le ROAS n'est pas exprimé en euros**
La slide affiche `2.79€`. Le ROAS est un **ratio sans unité** (des euros divisés par des euros). On l'écrit `2,79` ou `2,79 ×`, jamais `2,79 €`. Même famille d'erreur que « NPS de 25 % » — cf. [[NPS (Net Promoter Score)]]. Ça paraît anecdotique, mais afficher une unité fausse sur un dashboard est le meilleur moyen de faire douter de tout le reste.

**3. ⚠️ « CTR » désigne deux choses différentes dans le même cours** — le point le plus piégeux
- Slide **Média** : `CTR = Clics / Impressions` → **0,85 %**
- Slide **CRM** : `CTR = Clics / Ouvertures` → **11,1 %**

Deux dénominateurs, deux ordres de grandeur, un seul acronyme. Ce n'est pas une erreur du cours — c'est l'usage réel du secteur — mais c'est un piège majeur : en emailing, `clics/ouvertures` s'appelle plus précisément le **CTOR** (*Click-To-Open Rate*), et « CTR » désigne conventionnellement `clics/envois` (ou `clics/délivrés`).
→ **Réflexe à ancrer : ne jamais accepter un « CTR » sans demander le dénominateur.** Et dans un dashboard, écrire la formule dans l'info-bulle du KPI.

**4. Taux d'ouverture : envoyés ≠ délivrés**
Les formules du cours utilisent **Emails sent** au dénominateur. Le standard du secteur est **Emails delivered** (envoyés − bounces). Sur une base propre l'écart est faible, mais sur une base ancienne il peut atteindre plusieurs points — et il **dégrade artificiellement** les taux. À vérifier systématiquement quelle colonne est disponible dans le dataset.

**5. AARRR : « activation », pas « réactivation »**
Le transcript énonce le funnel AARRR comme *« acquisition, réactivation, rétention, revenu et referral »*. Le second A est **Activation** (le moment où l'utilisateur vit sa première expérience de valeur), pas réactivation.

**6. Ce que la slide « Expansion funnel » ne dit pas**
La pyramide s'élargit vers le bas, ce qui suggère une population croissante. L'intervenant le relève lui-même : en volume, on a **de moins en moins de monde** à chaque étape. L'élargissement représente la **valeur générée**, pas les effectifs.

**7. ROAS de 3 ≠ 2 € de marge**
Détaillé en [[#⚠️ ROAS — le calcul est sur le CA, pas sur la marge]]. L'intervenant se corrige lui-même deux minutes plus tard avec son exemple du « 5 pour 1 ».

**8. Coquille signalée en direct sur le tableau de cohortes**
Une valeur à 0 % sur la ligne de mars, reconnue comme une coquille pendant la séance (*« pour 0 % de mars, c'est une coquille »*).

**9. Graphie du dataset**
Toujours `GreenWiz` / `Greenway` dans les transcripts. La graphie correcte est **Greenweez** (elle est correcte sur les slides de cette session, contrairement à la précédente).

**10. Ce qui a été ajouté au-delà du support**
Pour transparence : l'attribution (last-click / multi-touch), la relation `CPC = CPM / (1000 × CTR)`, le ratio **LTV/CAC** et le CAC payback, les formules `churn = 1 − rétention` / `durée de vie ≈ 1/churn` / `LTV ≈ ARPU × durée × marge`, la formule du **ROAS d'équilibre**, la distinction taux de conversion étape-à-étape vs cumulé, la priorisation par volume absolu perdu, la saturation d'audience au scale, **Apple Mail Privacy Protection**, la variabilité de définition du CSAT, la mise en garde RGPD sur la segmentation socio-démographique, et la section [[#🏦 11. Transposition banking (hors cours)]].

---

## 📌 Logistique & suite

- **Challenges du jour :** Médias, CRM, NPS (obligatoires) · ESSEC, engagement vidéo (optionnels). Ils sont **indépendants** — on peut les faire dans n'importe quel ordre. L'intervenant estime que finir les trois premiers est déjà ambitieux.
- **3 cheat sheets** de formules KPI accessibles depuis le cours. Explicitement conçues pour ne PAS apprendre les formules par cœur.
- **Demain : premier cours de SQL.** Annoncé comme *« la journée la plus dure »*, puis reformulé en *« la plus challengeante »*. Message rassurant donné en séance : c'est normal de galérer le premier jour, l'objectif est d'avoir des automatismes **d'ici la fin de la semaine suivante**. Le prepwork aide mais n'est pas requis.
- Remarque de l'intervenant qui vieillit bien : *« une fois qu'on a goûté à SQL, on a du mal à revenir sur Google Sheets »*.

---

## 🎤 13. Angle entretien

**« Comment tu analyses un funnel de conversion ? »**
→ Je pars du bas — les acheteurs — et je remonte, parce que caractériser ce qui marche est plus informatif que chercher ce qui casse. Je calcule le taux de conversion étape à étape **et** le volume absolu perdu, et je priorise sur le second : 20 % de perte sur 50 000 personnes pèse plus que 80 % sur 500.

**« C'est quoi une analyse de cohorte, et à quoi ça sert ? »**
→ On regroupe les clients par période de première commande et on suit chaque groupe séparément. Ça sert à isoler la qualité de l'acquisition de l'effet du temps : une cohorte avec un gros volume et une mauvaise rétention signale une campagne mal ciblée. La forme visée n'est pas une courbe qui monte, c'est un **plateau le plus haut possible** — parce que plateau + acquisition constante = croissance incrémentale.

**« On te dit que la campagne a un ROAS de 3. C'est bien ? »**
→ Impossible à dire sans le taux de marge. Le ROAS d'équilibre est `1 / taux de marge` : à 50 % de marge le seuil est 2, à 20 % il est 5. Un ROAS de 3 est excellent en SaaS et déficitaire en distribution alimentaire.

**« Comment tu sais qu'un KPI est pertinent ? »**
→ Le test : si cet indicateur augmente, est-ce que le CA augmente ? Et est-il actionnable indépendamment ? Sinon c'est une vanity metric. Un cumul qui ne peut pas baisser n'est jamais un KPI.

**« Ton taux d'ouverture email est à 45 %, c'est très bon ? »**
→ Question piège possible : depuis Apple Mail Privacy Protection en 2021, le préchargement d'images génère des ouvertures fantômes. Je ne piloterais pas sur ce chiffre, je regarderais le taux de clic et le revenu par email envoyé.

**« Différence entre upsell et cross-sell ? »**
→ Upsell = plan supérieur du même produit. Cross-sell = produit additionnel. Ce sont deux des trois leviers de croissance sur une base existante, le troisième étant la durée de rétention.

---

## 🔗 Liens

- Chapitre précédent : [[03_KPI_Basics]] — définition du KPI, méthodologie en 7 étapes, marges, shortage rate
- [[02-google-sheets]] — TCD, `FILTER`, validation des données
- [[KPI vs métrique]] — le test « et alors ? », dont les vanity metrics sont le cas limite
- [[Taux sur variable binaire]] — le piège du dénominateur, décliné ici sur le CTR conditionnel
- [[NPS (Net Promoter Score)]] — la fiche complète, complétée ici par la segmentation et le CSAT
- [[Marge brute, marge opérationnelle, marge nette]] — pourquoi le ROAS se lit à travers le taux de marge
- [[Reporting vs analyse ad hoc]] — la cohorte est de l'ad hoc, le dashboard média est du reporting
- [[Aggregate before divide]] — le « % du total » d'un TCD est la version outillée du principe

**Fiches-concept à créer** (wikilinks pas encore résolus) :
- [[Analyse de cohorte et courbe de rétention]]
- [[Funnel de conversion]]
- [[CAC, LTV et unit economics]]
- [[Vanity metric]]
- [[Segmentation RFM]] *(existe peut-être déjà côté projet Olist — à vérifier avant création)*
