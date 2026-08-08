# 📝 #17 — Tracking Web & Google Tag Manager (GTM)

**Date** : 28 juillet 2026
**Thème** : Tracking web (théorie) + prise en main de GTM (pratique)
**Compréhension (1→5)** : ⭐⭐⭐⭐

---

## 🎯 Pourquoi tracker un site web ?

Objectif business : optimiser le trafic, développer de meilleures features, comprendre les attentes utilisateurs. Concrètement, on veut savoir :

- **Traffic & Sources** : combien de visiteurs, d'où viennent-ils
- **Engagement** : pages vues, temps passé, bounce
- **Usage & Funnels** : quelles features sont utilisées, à quelle étape les gens décrochent

> 🎯 *If you don't track it, you can't improve it.*

Cas d'usage typique (e-commerce) : identifier à quelle étape du funnel on perd le plus d'utilisateurs (clic produit → panier → paiement) pour formuler des **recommandations chiffrées** à l'équipe web (friction, UX, etc.).

⚠️ Le tracking web est **historiquement un sujet marketing**, mais un data analyst peut être amené à le faire — notamment dans une structure sans ressource marketing dédiée. Même sans le faire soi-même, comprendre comment la donnée est générée est indispensable pour l'exploiter derrière.

---

## 🧩 Front-end (client) vs Back-end (serveur)

| | **Front-end / Client** | **Back-end / Server** |
|---|---|---|
| Capture | User **intent** (clics, scrolls, pages vues) | **System outcomes** (commandes, updates) |
| Avantage | Facile à mettre en place, pas besoin de dev avancé | Plus complet (ex: durée d'appel, tel qui n'aboutit pas) |
| Limite | Peut manquer de la donnée (ad blockers, erreurs JS) | Ne montre pas ce que l'utilisateur a **tenté et raté** |
| Support requis | Aucun (ou léger) | Développeur nécessaire |

👉 **Aujourd'hui on fait du tracking front-end / client**, avec des événements précis (clic, scroll, page vue, soumission de formulaire).

💡 En pratique, la donnée back existe déjà "naturellement" côté serveur (chaque action y est loggée), mais elle est moins actionnable d'un point de vue opérationnel/marketing sans effort de mise en forme.

**Trigger-Based Change Data Capture** : pour ne rien perdre, on peut aussi logguer chaque changement back-end (insert/update/delete en base) comme un event timestampé dans une table d'events, analysable aux côtés des events front.

---

## 🍪 Cookies, UTM & RGPD

### Cookies

Petits fichiers texte déposés sur l'appareil de l'utilisateur, permettant de comprendre son comportement. Trois usages principaux :
- **Analytics** : analyser l'audience et le comportement
- **Personalization** : contextualiser l'expérience
- **Marketing** : tracer la provenance (réseaux sociaux) pour du retargeting

⚠️ **Consentement obligatoire** (RGPD). Sans consentement → pas de collecte → on n'a jamais 100% des utilisateurs trackés.

📌 **Ce n'est pas grave statistiquement** : à partir d'un volume suffisant, un échantillon (même partiel) suffit à tirer des conclusions fiables. Le B2B est plus difficile à analyser à cause des volumes plus faibles.

### UTM Parameters (paramètres d'URL)

Méthode **indépendante des cookies** pour tracker la provenance cross-site, en particulier utile pour l'e-mail marketing.

```
https://monsite.com/produit?utm_source=Newsletter+Ete&utm_medium=email&utm_campaign=Promo+Juillet
```

- `utm_source` : d'où vient le trafic (ex: nom de la campagne)
- `utm_medium` : canal (email, cpc, social...)
- `utm_campaign` : campagne précise

💡 **Attribution "dernier point de contact"** : si on sait que le dernier point de contact tracké est un clic dans un email promo, on peut attribuer la vente qui suit (même 3-4 jours après) à cette campagne — même si le suivi via cookie/session est perdu entre-temps.

### RGPD (CNIL)

- Référence légale : site de la **CNIL** (formations disponibles)
- Ne collecter que des données **cohérentes avec l'activité** du site (jamais de CB ou numéro de sécu pour un e-commerce classique)
- Durée de conservation type pour un e-commerce : **entre 1 et 2 ans**
- Sanction CNIL potentielle : jusqu'à **4% du chiffre d'affaires de la maison mère** (cas réel cité : Altice/BFM, rappel à l'ordre + refonte du site)

---

## 🏗️ Anatomie d'un événement

| Concept | Définition | Exemple |
|---|---|---|
| **Event** | Signal qui reporte une action utilisateur | `add_to_cart`, `purchase`, `page_view` |
| **Property (standard)** | Présente pour tous les events | `date`, `customer_id`, `platform` |
| **Property (custom)** | Présente pour certains events seulement | `purchase_id`, `total_amount`, `nb_items` |
| **User attributes** | Rattachés à l'utilisateur, pas à un event précis | démographiques, contact, device, statut, comportement agrégé |

3 grands types d'events : **Page view**, **Click**, **Action / Conversion**.

Exemple JSON envoyé lors d'un event :

```json
{
  "event_name": "add_to_cart",
  "parameters": {
    "product_name": "Trek SL6",
    "category": "Road Bike",
    "price": 3299.00,
    "user_id": "83920"
  }
}
```

---

## 📋 Du Business Need au Tracking Plan

Process en 3 phases, dans l'ordre :

1. **Business goals** → qu'est-ce qu'on veut accomplir (ex: +30% revenue en 6 mois)
2. **KPIs** → indicateurs qui répondent à ces goals, avec leur formule de calcul
3. **Events à tracker** → ce qu'il faut capturer pour calculer ces KPIs

| Business goal | KPI | Calcul | Event | Définition |
|---|---|---|---|---|
| Acquisition, activation, revenue | Nombre de sessions | Count new session / user | `start_session` | user arrive sur le site |
| | Conversion rate | # purchases / # sessions | `purchase` | user achète ≥1 produit |
| | Panier moyen | Sum revenue / # purchases | | |

### Contenu obligatoire d'un tracking plan
- Nom, description, **type** de l'event
- **Properties** de chaque event, avec description et **data type**
- **Valeurs attendues**

### Best practices
- Définir **quoi mesurer et pourquoi** avant tout
- KPIs **spécifiques et actionnables**
- Outils fiables + méthodes de capture claires
- **Naming convention** cohérente → `object_action` en **snake_case** (ex: `video_played`, `add_to_cart`)
- Revoir et mettre à jour le plan quand le produit évolue
- Document **unique et partagé** dans l'entreprise

---

## 🏷️ Google Tag Manager (GTM)

### Qu'est-ce qu'un TMS ?

**Tag Management System** = centralise le déploiement de tags (events) et variables (properties) sur un site, **sans (forcément) besoin d'un développeur** à chaque changement.

**GTM** = TMS gratuit de Google, le plus utilisé au monde.

**Sans TMS** → il faut setup le tracking séparément dans chaque outil (Google Analytics, Amplitude, Google Ads, AB Tasty...) → autant de fois que d'outils.

**Avec GTM** → un seul setup, GTM redistribue l'info vers tous les outils connectés.

> ⚠️ **GTM ne stocke aucune donnée** — c'est une porte d'entrée qui distribue l'info, rien de plus. Conséquence : **impossible de récupérer de la donnée a posteriori** si le tracking n'était pas en place au moment de l'action. Il faut donc le mettre en place le plus tôt possible.

GTM propose un système de **versioning façon Git** : possibilité de revenir à une version antérieure en cas de problème.

### Structure d'un compte GTM

- **Account** = votre entreprise
- **Container** = un par site web / app (et par pays si spécificités locales) → identifiant unique `GTM-XXXX`, contient tous les tags/triggers/variables
  - Setup en collant un snippet JS dans le site : un bout dans `<head>`, un bout juste après l'ouverture de `<body>`
- **Workspace** = zone de brouillon où on fait les changements avant publication

### Les 3 concepts clés

| | **Trigger** | **Variable** | **Tag** |
|---|---|---|---|
| Question | **When** ? | What/when/**how** exactement ? | **What** veut-on que GTM fasse ? |
| Rôle | Détermine quand/comment un tag se déclenche | Fournit la donnée dynamique utilisée par tags & triggers | Snippet qui collecte et envoie la donnée à un outil |
| Exemple | "clic sur un bouton", "visite d'une page" | "nom de page", "prix produit", "form ID" | 1 tag = 1 event = 1 outil |

**Ordre logique de setup : Trigger (1) → Variable (2) → Tag (3)**

Concepts additionnels côté GA4 :

| | **Event** | **Event parameters** | **User properties** |
|---|---|---|---|
| Définition | L'action trackée | Infos contextuelles clé-valeur sur l'event | Attributs persistants rattachés à l'utilisateur (pas à un event) |
| Exemple | `sign_up`, `purchase` | `form_id: newsletter-form` | `user_type: subscriber`, `plan: premium` |
| Usage | Visible dans les rapports GA | Décrit "comment/quoi" | Segmentation d'audience (à introduire une fois la stratégie de tag claire) |

### ⚠️ Configuration Tag vs Event Tag — piège fréquent

- Après publication du container, il faut **au moins un tag de configuration** (le **Google Tag**) : connecte GTM à l'outil (ex: GA4) une seule fois, via l'ID de compte. Se déclenche typiquement sur trigger "Page View".
- **Chaque action trackée ensuite** = un **Event tag** distinct (type "Google Analytics: GA4 Event"), qui référence le Configuration tag et se déclenche sur son propre trigger.

### 🔑 Nuance critique : nom du trigger vs nom affiché dans GA4

- Le **nom du Custom Event dans le trigger** doit être **strictement identique** (casse incluse) au nom poussé dans le DataLayer par le site (ex: `AddToCart` ≠ `addtocart` ≠ `add_to_cart` — il faut copier EXACTEMENT ce que le site utilise). Sinon **ça ne se déclenche pas du tout**.
- Le **nom de l'event dans le Tag GA4** (`eventName`), lui, est **libre** — c'est juste le nom qui s'affichera dans les rapports Google Analytics. On peut choisir un nom cohérent et cross-site, indépendant du nom brut côté DataLayer.

### Le DataLayer

Couche de code entre le site visible et les outils analytics, maintenue par les développeurs. Contient les noms exacts de tous les events/variables du site — **sensibles à la casse**, à copier tel quel.

3 façons de l'inspecter :
1. Extension Chrome **Data Layer Checker**
2. **Preview Tool** de GTM (onglet Data Layer)
3. Console navigateur → taper `dataLayer` (d minuscule, L majuscule)

💡 Astuce : on peut inspecter le DataLayer d'un **site concurrent** pour comprendre ce qu'il tracke (ex : `ecommerce.items.0.price` pour récupérer un prix produit dans le DataLayer d'un site e-commerce).

### Types de Trigger

**Page View triggers** (ordre de déclenchement du plus tôt au plus tard) :
| Trigger | Se déclenche quand |
|---|---|
| Consent Initialisation | Avant tout autre trigger — vérifie/applique le consentement (RGPD) |
| Initialisation | Juste après le consentement, avant le chargement du contenu |
| Page View | Le navigateur commence à charger la page → recommandé pour les tags de Configuration |
| DOM Ready | Le HTML est parsé (mais pas forcément images/scripts) |
| Window Loaded | Page entièrement chargée (images, CSS, scripts inclus) |

**Click triggers** : All Elements (tout clic) / Just Links (uniquement les `<a href>`, utile pour liens sortants/téléchargements)

**User Engagement** : Element Visibility / Form Submission / Scroll Depth

**Autres** : Custom Event (déclenché par un `dataLayer.push`), History Change (SPA), JavaScript Error, Timer, Trigger Group (combine plusieurs triggers)

⚠️ **En pratique, on préfère largement les Custom Events** aux triggers par défaut (même pour des clics ou des soumissions de formulaire), car ils offrent plus de flexibilité — on définit exactement ce qu'on veut récupérer plutôt que de dépendre du comportement par défaut de GTM.

```js
// Exemple de push dans le DataLayer déclenchant un Custom Event trigger
window.dataLayer.push({ event: "add_to_cart" });
```

---

## ⚙️ Setup pas à pas

### 1. Compte + Container
- Nom de compte cohérent, choisir la plateforme cible : **Web** / iOS / Android / AMP / **Server** (server-side possible mais setup plus complexe, hors scope aujourd'hui)
- Coller les 2 snippets fournis : un dans `<head>`, un juste après `<body>`
- **Submit** puis **Publish**

### 2. Variable
1. `Variables` → Built-In Variables → **Configure** pour activer les variables courantes
2. Si absente → **New** → User-Defined Variable
3. Choisir un **Variable Type** (Constant, Data Layer Variable, DOM Element...)
4. Renseigner les options (clé, valeur)
5. Save → réutilisable dans tags, triggers, autres variables

### 3. Trigger
- Choisir le type (le + souvent : Custom Event)
- Ajouter des **conditions** si besoin pour cibler précisément (ex: se déclenche seulement si le nom de l'event = `newsletter-form`, ou si l'URL contient `product`)

### 4. Tag
1. `Tags` → **New** → choisir le type (ex: "Google Analytics: GA4 Event")
2. **Event Name** = l'action à afficher dans GA4 (ex: `sign_up`)
3. **Event Parameters** : clé (nom brut, ex: `price`) → valeur dynamique (cliquer sur l'icône lego, sélectionner la variable créée → apparaît entre accolades `{{...}}`, signe que c'est dynamique)
4. **User Properties** (optionnel, GA4) pour la segmentation d'audience
5. Assigner le **trigger**
6. Save → Preview

### Exemple complet : tracker une inscription newsletter
1. Inspecter le formulaire du site → `id="newsletter-form"`
2. Activer la built-in variable `{{Form ID}}`
3. Créer un trigger *Form Submission*, condition : `{{Form ID}}` équals `newsletter-form`
4. Créer un tag GA4 Event, `event name = sign_up`, event parameter `form_id: {{Form ID}}`
5. Lier le tag au trigger
6. Preview, tester, publier

---

## 🧪 Test & environnements

### Preview Tool
- Ouvre une **copie du site testable sans publier**
- Vérifie l'onglet "Tags Fired" vs "Tags Not Fired"
- ⚠️ Tester **aussi les faux positifs** : reproduire une action *non ciblée* pour vérifier que le tag ne se déclenche **pas** par erreur (souvent plus difficile à repérer qu'un tag qui ne se lance pas du tout)
- **Google Tag Assistant** (extension navigateur) pour vérifier en conditions réelles après publication

### Les 3 environnements classiques (développeurs)
**Sandbox** (site potentiellement cassé, features en cours) → **Staging / pré-prod** (copie fonctionnelle du site réel, non publique) → **Production** (site public)

### Process global (macro)
```
Business needs → KPI Framework → Tracking Plan Definition
   → Implementation (GA & GTM setup)
   → QA (QA, GTM Release, QC in staging)
   → 🚀 Go-Live
   → QC (Real-time QC, QC D+3/7, Follow-up report)
   → Production tracking (Alerts)
```

---

## ⚠️ Bonnes pratiques & pièges

- **Toujours préparer le tracking plan avant** de créer le moindre tag — s'aligner avec les parties prenantes sur quoi tracker et où l'envoyer
- **Toujours tester** (Preview Mode GTM + GA4 DebugView) — un setup non testé = risque
- **Convention de nommage stricte et cohérente** (snake_case, `object_action`) — un nom mal orthographié entre deux étapes du setup = ça ne marche pas
- Le tracking est **fragile aux changements côté site** : un simple changement de casse sur un nom d'élément (ex: `AddToCart` → `addtocart`) casse le setup **sans prévenir** → nécessité d'**alertes** sur absence de données sur un event critique (ex: 0 donnée pendant 10h sur un event → signal d'alerte)
- **Maintenance** : pas besoin d'intervenir souvent une fois le setup stable (retour d'expérience : ~1x/mois en régime de croisière), mais **coordination essentielle** avec l'équipe web lors des refontes/mises à jour de design
- **Gouvernance des accès** : très peu de personnes (1-2) avec accès admin à GTM — un accès complet = maîtrise de toute la donnée envoyée et à qui. GTM permet des **profils avec droits différenciés** (ex: droit de modifier sans droit de publier en live)
- Perte de données = perte définitive : si un problème n'est détecté que 6 mois après (personne ne consulte les rapports en continu), ce sont 6 mois de données perdues, sans rattrapage possible

---

## 🎯 Points clés pour les entretiens

- **GTM ne stocke aucune donnée** — il ne fait que distribuer l'info vers les outils connectés (GA4, Ads, Amplitude...)
- Différence **Tag / Trigger / Variable** = What / When / How
- Différence **Configuration Tag** (connexion outil, une fois) vs **Event Tag** (une fois par action trackée)
- Le nom du **Custom Event trigger** doit matcher EXACTEMENT (casse incluse) le nom poussé dans le DataLayer par le site ; le **nom d'event affiché dans GA4** (dans le tag), lui, est libre
- RGPD : sanction CNIL jusqu'à **4% du CA de la maison mère** ; conservation type **1-2 ans** pour un e-commerce
- Le tracking web est **event-based / trigger-based** : rien ne peut être récupéré sans déclencheur, et rien ne peut être récupéré rétroactivement

---

## 🔗 Liens avec d'autres notions

- Les events trackés ici (add_to_cart, purchase, sign_up...) sont la matière première des KPIs de **cohort analysis / churn / funnel** vus en semaine 1
- La donnée GA4 peut atterrir en warehouse (BigQuery) via **Fivetran** → même exigence de rigueur sur les noms de colonnes/events que pour les variables DataLayer (cf. leçon dbt : ne jamais faire confiance à un nom approximatif)

---

## ✅ Actions post-session

- [ ] Challenge 1 — Tracking plan (template Google Sheet, ~1h-1h15, sur copie du site e-commerce fictif fourni)
- [ ] Challenge 2 — Setup GTM + GA4 (Google Tag + premier event)
- [ ] Challenges 3 & 4 — Mise en pratique : tracker plusieurs actions utilisateurs
- [ ] Challenge optionnel — récap GTM
- [ ] Installer l'extension Chrome **Data Layer Checker**

---

## ❓ Questions / Points flous

- [ ]
- [ ]
