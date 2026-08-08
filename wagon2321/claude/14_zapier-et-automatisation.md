# 📝 #18 — Zapier & Automatisation no-code

**Date** : 29 juillet 2026
**Thème** : Automatisation de workflows (Zapier en pratique, panorama Make/n8n)
**Compréhension (1→5)** : ⭐⭐⭐⭐

---

## 🎯 Pourquoi automatiser ?

Un outil d'automatisation no-code sert à remplacer des tâches manuelles répétitives et chronophages (souvent liées au CRM, à la qualification de leads, au reporting).

**Bénéfices principaux :**
- **Gain de temps** — libère du temps pour des tâches à plus haute valeur ajoutée
- **Réduction des erreurs humaines** — moins d'intervention manuelle = moins de fautes de saisie
- **Flexibilité / personnalisation** — workflows sur-mesure, multi-étapes

⚠️ Ce n'est **pas** un outil de suppression de postes — l'idée reçue "on automatise donc on licencie" est un raccourci trompeur ; dans les faits, ça libère de la bande passante pour du travail à plus forte valeur ajoutée.

---

## 🥊 Zapier vs Make vs n8n

| | **Zapier** | **Make** | **n8n** |
|---|---|---|---|
| Positionnement | Leader marché, le plus simple d'accès | Leader marché, interface plus complexe (canvas visuel) | Plus technique, orienté profils dev |
| Connecteurs natifs | ~10 000-12 000 (le plus large) | Large mais moins que Zapier | Moins nombreux, mais **open-source & self-hostable** |
| Courbe d'apprentissage | Faible | Moyenne | Plus élevée |
| Cas d'usage typique | Automatisation business/marketing rapide | Workflows visuels complexes, logique avancée | Équipes tech, hébergement interne, coûts maîtrisés à volume élevé |

💡 Les 3 outils font fondamentalement la même chose (trigger → actions), le choix dépend surtout du **profil de l'équipe** (technique ou non) et de la **contrainte d'hébergement/coût** (n8n self-hosted devient intéressant à fort volume).

D'autres outils plus **spécialisés** existent en périphérie (ex : scrapers de données de contact type PhantomBuster) — ils ne remplacent pas un orchestrateur comme Zapier/Make/n8n, mais s'y connectent en amont.

---

## 🏗️ Structure d'un Zap (workflow)

```
Trigger → [Filtres] → Action(s) multiples → [Chemins conditionnels] → Actions multiples
```

- **Trigger** : événement qui démarre le workflow — toujours un et un seul par Zap
- **Actions** : nombre **illimité**, exécutées en cascade après le trigger
- **Filtres** : stoppent le workflow si les données ne remplissent pas certaines conditions (ex : email mal formé) — évite d'envoyer des leads non qualifiés plus loin dans le process
- **Paths (chemins conditionnels)** : dirigent vers des actions différentes selon le profil des données (scoring, taille d'entreprise...) — **max 10 chemins possibles, mais 2 à 5 recommandés en pratique** pour rester débuggable

**Exemple type** : remplissage d'un formulaire → ajout d'une ligne dans Google Sheets → envoi dans le CRM → notification Slack au commercial concerné.

---

## ⚡ Types de trigger

| Type | Comportement | Choix utilisateur ? |
|---|---|---|
| **Instant** | Déclenchement immédiat dès que la condition est remplie | — |
| **Polling** | Zapier vérifie périodiquement (1 à 15 min) les nouvelles entrées et les traite par lots | Non — dépend de l'outil connecté, pas un choix libre |

💡 La plupart des triggers utilisés en pratique sont **instantanés**.

---

## 🧰 Outils intégrés ("Helpers")

Deux grandes familles d'usage : améliorer l'exploitation de la donnée, ou servir d'élément déclencheur.

| Outil | Rôle |
|---|---|
| **Filter** | Stoppe le workflow si une condition n'est pas remplie |
| **Formatter** | Mise en forme (téléphone, dates, remplacement de texte — équivalent d'un `REPLACE` SQL) |
| **Schedule** | Déclenche une étape à un moment précis (ex : tous les lundis 8h) |
| **Delay** | Ajoute un temps d'attente entre deux étapes |
| **Paths** | Chemins conditionnels |
| **Webhooks** | Usage avancé — cf. section dédiée |
| **Code** | JavaScript/Python pour filtres ou transformations complexes — **utilisé dans <5% des cas** (l'outil est justement pensé pour éviter le code) |
| **Sub-Zap** | Réutilise un enchaînement d'étapes déjà existant dans un autre Zap |
| **Looping** | Répète une action pour chaque élément d'une liste |
| **Storage** | Stockage de données simples, cas d'usage limité |
| **SMS / SMTP** | Micro-services internes remplaçant un outil tiers |
| **Lead Score** | Scoring de contact directement dans le workflow |
| **Zapier Chrome extension / Zapier Manager** | Monitoring — "Zaps for Zaps" (automatiser la gestion du compte lui-même) |

---

## ⚙️ Setup en 5 étapes (trigger ou action)

| Étape | Description | Exemple |
|---|---|---|
| 1. Choisir une app | Selon l'outil à automatiser | Slack |
| 2. Choisir un événement | Liste déroulante équivalente aux actions possibles côté front de l'app | "Send message to Slack Channel" |
| 3. Choisir un compte | Authentification (login/mdp ou clé API) — **connexion mémorisée**, à faire une seule fois | Login Slack |
| 4. Configurer trigger/action | Détails précis de la tâche | Channel, contenu, formatage |
| 5. Tester | Envoi d'un échantillon ou événement test | Test avec un vrai message Slack |

### ⚠️ Piège fréquent : la qualité des données de test

Si on clique sur "Test Trigger" **sans avoir d'abord rempli le formulaire soi-même avec des données cohérentes**, Zapier renvoie un échantillon générique et non représentatif (ex : `John Doe`, texte aléatoire à la place d'un numéro de commande). Toujours **tester avec ses propres données réalistes en premier**, sinon "des données pourries donnent un test pourri".

### Autres points pratiques (démo Google Form → Google Sheet)
- Les **entêtes de colonnes doivent être en ligne 1** du spreadsheet, sinon Zapier ne les reconnaît pas
- **Valeur statique** (fixe, ex : toujours "Thomas") vs **valeur dynamique** (`{{}}`, issue d'une étape précédente, ex : email du formulaire)
- Possibilité d'insérer des **formules** dans un champ (calculs, concaténations...)

---

## 🔀 Exemple complet : Paths pour un scénario marketing

**Objectif** : adapter la méthode de contact selon le score d'un lead.

```
Trigger : Webflow — "New form Submission" (Form = Newsletter)
    ↓
Action : Lead Score by Zapier — "Find Person and Company Information"
    Input : email → Output : {{score}}
    ↓
Action : Paths by Zapier — "Conditionally run"
    Path A : {{score}} < 50%   → lead peu qualifié
    Path B : 50% < {{score}} < 90% → lead moyennement qualifié
    Path C : {{score}} > 90%   → lead très qualifié
```

| Path | Score | Action |
|---|---|---|
| **A** | 14% (peu qualifié) | Mailchimp → "Unsubscribe Email" (on arrête de le solliciter, inutile de spammer quelqu'un que ça n'intéresse pas) |
| **B** | 62% (moyennement qualifié) | Slack → "Send Channel Message" dans `#Sales` (visibilité équipe, sans contact direct immédiat) |
| **C** | 91% (très qualifié) | Reply → "Create person and push to Campaign" (contact direct immédiat, forte priorité) |

---

## 🔌 Webhooks & API calls

Les **webhooks** ne sont utiles que lorsqu'un outil n'est **pas intégré nativement** dans Zapier (typiquement un outil interne "maison"). Ça reste un cas assez rare vu le nombre de connecteurs déjà disponibles — et ça nécessite un **plan payant**.

### Élements d'un call API (rappel)
Documentation → **Méthode** (GET/POST) → **Endpoint** (URL) → **Clé API** → **Inputs** (query params / payload) → **Output** (JSON) → **Code de réponse**

### Catch Hooks
Les Catch Hooks sont "l'autre côté" d'un webhook : quand on envoie un call API vers une URL, cette URL est le Catch Hook qui **attend** de recevoir la donnée.
- **Zapier Integrated** : outil déjà connecté nativement (ex: Google Sheets, BigQuery) → pas besoin de webhook manuel
- **Zapier Supported** : outil non natif → utiliser "Webhooks by Zapier", Zapier génère une **URL de webhook custom** à configurer côté outil tiers, puis "écoute" les requêtes entrantes

---

## ⏱️ Rate limits & systèmes de queue

Utile pour étaler les déclenchements dans le temps (ex : éviter de submerger une équipe humaine limitée, ou respecter les limites d'API d'un outil tiers).

| Action | Comportement |
|---|---|
| **Delay For** | Retarde les actions suivantes d'une durée choisie (heures, jours, semaines) — **délai minimum : 20 minutes** |
| **Delay Until** | Met en pause le Zap jusqu'à une date/heure précise (souvent une date récupérée d'une étape précédente, ex : fin d'un rendez-vous) |
| **Delay After Queue** | Garantit un temps de traitement suffisant à chaque action avant que la suivante ne s'exécute |

💡 Cas d'usage concret : étaler l'arrivée de leads sur une équipe commerciale (ex : 10 personnes toutes les 10 minutes) plutôt que de tout envoyer d'un coup.

---

## 🔁 Sub-Zaps

Permettent d'appeler un Zap depuis un autre Zap — factorise un enchaînement d'étapes répétitif et réutilisable dans plusieurs workflows.

- **"Start a Sub-Zap"** (trigger) + **"Return from a Sub-Zap"** (action, doit être la dernière étape du sous-Zap)
- **"Call a Sub-Zap"** (action, utilisée depuis le Zap "parent" pour déclencher le sous-Zap)

⚠️ Peu utilisé en pratique — pertinent seulement à partir d'un **volume élevé de Zaps actifs** (retour d'expérience cité : ~150 Zaps actifs) partageant un enchaînement identique.

---

## ⚠️ Gestion des erreurs

| Code | Type | Description | Exemple |
|---|---|---|---|
| **400 Bad Request** | HTTP | Champ requis manquant ou mal formaté | Action "Find Email" sans nom/prénom/entreprise |
| **401 Unauthorized** | HTTP | Zapier ne peut plus se connecter à l'app tierce | Mot de passe Gmail changé → reconnexion nécessaire |
| **429 Too Many Requests** | HTTP | Trop de requêtes envoyées trop vite, dépasse la limite API de l'outil tiers | Afflux massif de leads simultané vers un outil limité à 1 req/10s |
| **500 Error** | HTTP | Serveur de l'app tierce en panne | Maintenance mensuelle programmée d'un outil |
| **"Problem updating node"** | Erreur Zapier | Modifications simultanées sur le même Zap dans deux onglets différents | Travailler sur Path A et Path B en parallèle dans 2 fenêtres |

### Historique & alertes
- L'**historique du Zap** distingue : succès (allé au bout), filtré (arrêté volontairement par un filtre — normal), en erreur (bug réel à corriger)
- **Dépassement de plan** : Zapier stocke les entrées en attente et peut les **rejouer** si on passe à un plan supérieur
- **Alertes e-mail** configurables : Zap arrêté, nouveau Zap créé, etc.
- **Zaps for Zaps** (monitoring) : automatiser la gestion du compte Zapier lui-même (ex : générer un rapport d'activité CSV, alerter en cas de limite atteinte)
- **Zapier Community** : forum avec les messages d'erreur les plus courants — bonne première ressource de dépannage

---

## ⚠️ Bonnes pratiques & gouvernance

- **Accès limité** : Zapier est un outil **critique** — si un Zap casse, ça peut bloquer un process essentiel de l'entreprise. Idéalement **1 propriétaire principal + 1 backup**, éventuellement 1 référent par équipe pour des automatisations locales.
- **Qualité de la donnée** : tester plusieurs fois **avant** la mise en prod — difficile de corriger après coup si de mauvaises données sont déjà parties dans le CRM (pas de "retour en arrière" magique, il faut corriger le Zap et refaire passer les gens dedans).
- **RGPD & sécurité** :
  - Rester attentif aux données qui transitent (visibilité pas toujours totale sur "quel outil reçoit quelle info")
  - Possibilité de **hasher/chiffrer** des données sensibles dans un Zap
  - Zapier peut lui-même automatiser des process RGPD (ex : email de renouvellement de consentement après 1 an de silence)
- **Naming convention cohérente** pour les Zaps — indispensable au-delà de quelques dizaines de workflows actifs
- **Organisation en dossiers** par équipe
- **Documentation** : un document récapitulatif de tous les Zaps actifs (comparable à une doc dbt, mais tenue manuellement)
- **Ne pas sur-complexifier** : éviter les workflows-monstres à 200 actions — mieux vaut découper en plusieurs Zaps plus lisibles et débuggables

### Contexte d'usage
- Outil surtout utilisé par les **startups et scale-ups**
- Rare dans les très grandes entreprises à fort volume (coût qui grimpe vite) — sauf projets **intrapreneuriaux** internes reproduisant une stack type startup

---

## 🗄️ Data Governance (cadre théorique — lié aux workflows automatisés)

La gouvernance de la donnée est le **framework** pour gérer, protéger et encadrer la donnée collectée — pertinent en particulier pour les workflows automatisés type Zapier, où la donnée circule vite entre plusieurs systèmes.

### 3 piliers
| Pilier | Rôle |
|---|---|
| **Manage** | Organiser le cycle de vie de la donnée (collecte → archivage/suppression), maintenir la qualité des assets |
| **Protect** | Protéger contre accès non autorisé, breach, perte — confidentialité, intégrité, disponibilité, conformité |
| **Govern** | Politiques, process et contrôles garantissant un usage conforme aux objectifs business, obligations légales, bonnes pratiques du marché |

### Pourquoi c'est important
Assure la **qualité** de la donnée, renforce la **sécurité**, soutient la **conformité**, facilite la **découverte** de la donnée (data discovery).

### Data Lifecycle
```
Data collection & storage → Data cleaning & transformation → Data analysis → Data activation → Data deletion
        ↑____________________________ (nouvelle donnée générée) __________________________|
```
Catégories de gouvernance qui s'appliquent à différents moments du cycle : **Data Quality Assessment**, **Data Discovery**, **Data Security**, **Data Privacy** (ces deux dernières s'appliquent sur tout le cycle, de bout en bout).

### En pratique — 6 catégories
| Catégorie | Rôle |
|---|---|
| Data Catalog & Metadata | Documenter/tagger sources, datasets, tables, colonnes |
| Data Access Control | Chaque utilisateur n'accède qu'à ce qui est pertinent pour son poste |
| Data Architecture | Définir comment la donnée est stockée, organisée, accédée, traitée |
| Data Profiling | Évaluation qualité (types, anomalies, distribution) |
| Data Encryption | Rendre la donnée illisible sans clé de déchiffrement |
| Naming Conventions | Noms cohérents et intuitifs reflétant contenu/usage |

💡 Lien direct avec ce chapitre : ces principes de gouvernance (qualité, métadonnées, sécurité) sont ce qui **maintient l'intégrité et la fiabilité** des workflows automatisés type Zapier.

### Adapter la gouvernance à la taille de l'organisation
| | **Startup** | **Scale-up** | **Grande entreprise** |
|---|---|---|---|
| Outils | Spreadsheets, Git | Catalogue de données, gestion métadonnées, data quality features | Plateforme de gouvernance robuste, Master Data Management |
| Process | Liste des sources, checks basiques | Doc formelle (lineage, ownership, framework qualité) | Framework de gouvernance, conformité, comité dédié |
| Approche | Automatiser les tâches routinières pour réduire les erreurs | Culture de collaboration data et partage de connaissance | Automatisation + IA pour qualité, lineage, métadonnées |

---

## 🎯 Points clés pour les entretiens

- Un Zap = **Trigger** (unique) + **Actions** (illimitées) + éventuellement **Filtres** et **Paths** (max 10, en pratique 2-5)
- **Trigger instant vs polling** : ce n'est **pas un choix utilisateur**, ça dépend de l'outil connecté
- **Toujours tester avec des données cohérentes** avant de mettre en prod — piège classique du test "par défaut" non représentatif
- **Gouvernance des accès** : très peu de personnes avec accès complet à un outil critique comme Zapier — même logique que pour GTM
- **Zapier / Make / n8n** : même logique fonctionnelle, différence de complexité d'UI, de nombre de connecteurs, et de modèle (SaaS vs self-hosted pour n8n)
- La gouvernance de la donnée (Manage / Protect / Govern) est le cadre qui garantit la fiabilité d'un workflow automatisé — pas juste un sujet "légal" à part

---

## 🔗 Liens avec d'autres notions

- Les **Webhooks/API calls** dans Zapier reprennent exactement la même logique que le chapitre API vu la semaine précédente (méthode, endpoint, clé, inputs, output, code réponse)
- La **documentation manuelle des Zaps actifs** est comparée explicitement à une documentation dbt — même besoin de traçabilité, mais sans l'outillage automatique
- Le principe de **gouvernance des accès restreints** (1-2 personnes admin) est identique à celui vu pour **GTM** (#17) — les deux sont des outils "critiques" dont une casse impacte tout un process business

---

## ✅ Actions post-session

- [ ] Créer un Google Form (Full Name, Email) + Google Sheet avec entêtes en ligne 1
- [ ] Connecter formulaire → sheet via un Zap (trigger : nouvelle réponse → action : créer une ligne)
- [ ] Tester le Zap avec des données cohérentes avant mise en live
- [ ] Nommer les Zaps de façon claire et cohérente
- [ ] Créer une documentation récapitulative de tous les Zaps du compte

---

## ❓ Questions / Points flous

- [ ]
- [ ]
