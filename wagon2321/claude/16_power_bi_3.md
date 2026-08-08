# 📝 #24 — Power BI (3/3) : gouvernance, sécurité, partage & Apps

**Date** : 06 août 2026
**Thème** : Licences, distinction précise Report vs Dashboard, Workspaces & rôles, publication, sécurité (Dashboard-Level, Row-Level, Object-Level), partage, Apps, collaboration sans co-édition simultanée, brief du projet Deluxe E-Commerce
**Compréhension (1→5)** : ⭐⭐⭐

---

## 🎯 Contexte de la session

- Troisième et dernier jour du module Power BI — clôture la trilogie [#22](22-power-bi-1.md) → [#23](23-power-bi-2.md) → #24
- Journée projet : cours théorique court le matin (gouvernance, sécurité, partage, collaboration), après-midi consacré à un projet complet sur le dataset **Deluxe E-Commerce** (BigQuery, dataset connu disponible sur Kaggle)
- Contenu plus léger sur le plan technique que #22/#23, mais couvre des sujets **absents des deux premiers cours** : sécurité de la donnée et gouvernance du partage

---

## 💳 Licences — compléments par rapport à #22

| Licence | Prix indicatif | Permet |
|---|---|---|
| **Gratuite** | — | Desktop uniquement (Windows) ; VM nécessaire pour les utilisateurs Mac |
| **Pro** | ~14 $/poste/mois | Partage et collaboration via Power BI Service, **uniquement** entre personnes elles-mêmes licenciées Pro |
| **Premium** | ~24 $/poste/mois | Partage à des personnes sans licence, accès à **Microsoft Fabric** (jusqu'à 100 To de stockage), fonctionnalités type Copilot |

💰 Coût réel à anticiper : au-delà du prix par poste, un abonnement payant implique aussi de payer le **stockage cloud** associé — à prendre en compte avant de recommander un tier à une entreprise.

---

## 🧱 Report vs Dashboard — la distinction précise (souvent confondue)

Le mot "dashboard" est utilisé au sens large partout ailleurs (y compris dans mes propres chapitres jusqu'ici). Dans le **vocabulaire strict Power BI**, ce sont deux objets bien distincts :

| | Report | Dashboard |
|---|---|---|
| Créé dans | Power BI Desktop | **Power BI Service uniquement** |
| Structure | Une ou plusieurs pages | **Une seule page** |
| Contenu | Plusieurs visuels | Plusieurs **tuiles** |
| Source de données | Un seul modèle sémantique | Peut agréger des tuiles venant de **plusieurs reports/modèles différents** |
| Interactivité | Filtrer, trancher (slice), drill-down | Non interactif — un clic renvoie vers le report source |
| Usage typique | Analyse détaillée d'un scope | Overview transverse (ex. vue globale marketing + sales + compta réunie en un coup d'œil) |

📌 Un Dashboard se construit en **épinglant** des tuiles depuis un ou plusieurs reports (*Pin to a dashboard* pour une page entière, *Pin visual* pour un seul graphique) — c'est littéralement un montage de pièces détachées provenant d'ailleurs, pas un objet qu'on construit en soi.

### Rappel — les 4 objets Power BI (recap précisé de #22)
- **Report** : cf. tableau ci-dessus
- **Dashboard** : cf. tableau ci-dessus
- **Semantic Model** (ex-Dataset) : couche de relations entre tables (Star Schema), publiée automatiquement avec le report
- **Workspace** : environnement de navigation et de partage, décliné par pôle/projet, avec gestion des accès

---

## 🗂️ Workspaces & rôles d'accès

| Workspace | Usage |
|---|---|
| **My Workspace** | Personnel, non partageable, disponible même en licence Gratuite |
| **Workspaces d'équipe/projet** (ex. Finance, Sales Europe) | Pensés pour la collaboration entre développeurs BI — pas pour les utilisateurs finaux consommateurs de dashboards |

Quatre niveaux d'accès à un Workspace :

| Rôle | Peut faire |
|---|---|
| **Admin** | Tout, y compris supprimer des éléments |
| **Member** | Gérer le contenu |
| **Contributeur** | Ajouter/modifier du contenu (ex. annotations) |
| **Viewer** | Consulter uniquement, ne peut rien modifier |

💡 Exemple donné en session : des business analysts qui pilotent activement un dashboard → Admin ; des collaborateurs opérationnels qui ne font que le consulter ou l'annoter → Contributeur ou Viewer.

⚠️ Partager nécessite une licence Pro ou Premium ; accéder à un contenu partagé nécessite soit une licence Pro personnelle, soit que le report soit hébergé dans une capacité Premium.

---

## 🚀 Publier vers Power BI Service

- Depuis Power BI Desktop : onglet *Accueil* → **Publier** — nécessite un compte Microsoft avec licence
- Publier un report envoie **le report ET le modèle sémantique** ensemble : "la partie visible de l'iceberg et le cerveau"
- Une fois publié, il est possible de créer/modifier des graphiques **directement dans Power BI Service**, sans repasser par Desktop — **sauf** pour Power Query (transformation de données), qui reste Desktop uniquement
- Les modifications faites sur Desktop peuvent être **rafraîchies** et s'appliquent automatiquement dans Power BI Service, sans re-publier de zéro

---

## 🔐 Trois niveaux de sécurité — à ne pas confondre

| | Contrôle | Se configure | Limite |
|---|---|---|---|
| **Dashboard/Report-Level Security** | Accès à des **pages** spécifiques selon le rôle (ex. page 1 accessible à tous, pages 2-3 réservées) | Power BI Service | — |
| **Row-Level Security (RLS)** | Accès à certaines **lignes** selon un filtre défini | Règles créées dans Desktop (*Modeling > Manage Roles*) ; rôle ensuite **assigné à une personne par e-mail** dans Power BI Service (Sécurité du modèle sémantique) | Ne s'applique qu'aux **Viewers** |
| **Object-Level Security (OLS)** | Masque des **colonnes/tables entières** | Pas nativement dans Power BI — nécessite un outil externe (ex. **Tabular Editor**) | Ne s'applique qu'aux **Viewers** |

⚠️ Piège important à retenir : **Admins, Members et Contributors voient toujours l'intégralité de la donnée**, quel que soit le RLS/OLS configuré — ces sécurités ne protègent que les Viewers.

💡 Démo travaillée en session : sur un dataset de films avec une colonne *Certificate* (classification d'âge), un rôle "Certificate 12" ne voit que les films classés 12, un rôle "Certificate 15" que les films classés 15. Power BI permet de **prévisualiser** (*View As*) ce que chaque rôle verra avant publication — réflexe à prendre systématiquement avant de livrer un dashboard segmenté par profil.

---

## 🔗 Partage — ce qu'on partage vraiment

### Niveaux d'accès au partage basique
| Niveau | Par défaut | Permet |
|---|---|---|
| **Read-only** | — | Consulter uniquement |
| **Re-share** | ✅ Inclus par défaut | Repartager le contenu à d'autres personnes |
| **Build** | ❌ Exclu par défaut | Construire ses **propres** reports à partir de la donnée sous-jacente |

### ⚠️ Ce qu'on partage sans y penser
Partager un report/dashboard sans précaution supplémentaire, c'est partager **tout ce qui est visible** — et **tout le modèle sémantique** en dessous :

- **Visible** : l'utilisateur peut changer les slicers, retirer ou ajouter des filtres pour voir plus de détail, faire un drill-down — "tout ce que l'utilisateur peut rendre visible"
- **Modèle sémantique** : masquer une colonne, une table, une mesure ou une page dans le report **ne la retire pas** du modèle sémantique sous-jacent — un utilisateur avec un accès Build peut donc potentiellement y accéder quand même

📌 C'est précisément pour ça que l'**Object-Level Security** existe : masquer une colonne dans l'interface du report n'est **pas** une mesure de sécurité, seul l'OLS retire réellement l'accès à la donnée.

---

## 📱 Apps

- Façon "grand public" de partager du contenu, pensée comme un **site web** — organisation en Z-pattern (KPI en haut, informations secondaires lues en diagonale), même logique déjà vue en dataviz ([#21](21-looker-studio-3-data-storytelling.md)) et rappelée pour Power BI en [#22](22-power-bi-1.md)
- Une App peut regrouper **plusieurs dashboards et/ou reports**
- Différence clé avec un partage classique : une App **ne partage jamais la couche sémantique** — contrairement au partage direct d'un report/dashboard vu plus haut

### Créer une App — 3 étapes
1. **Setup** : nom, description, logo, couleur du thème, informations de contact, paramètres globaux (installation automatique, masquer le panneau de navigation, autoriser la copie des reports...)
2. **Content** : ajouter les reports/dashboards/classeurs déjà présents dans le workspace
3. **Audience** : définir qui peut installer/consulter l'App

⚠️ Tout ce qui a été dit sur les reports (sécurité, ce qui reste visible) s'applique aussi aux Apps — la seule vraie différence de gouvernance est l'absence de partage de la couche sémantique.

---

## 🤝 Collaborer malgré les limites de Power BI Desktop

Power BI Desktop n'est **pas conçu pour la co-édition simultanée** d'un même report par plusieurs personnes. Trois façons de contourner cette limite :

| Approche | Fonctionnement |
|---|---|
| **Split data model / visuels** | Une personne construit le modèle de données (un `.pbix` sans visuel) et le **publie** ; une autre construit les visuels dans un autre `.pbix` connecté (Live Connection) au modèle publié |
| **Split par report** | Pas besoin de travailler tous dans le même report : un report par thème, tous connectés au même modèle sémantique, puis réunis dans un **dashboard** ou une **App** à la fin |
| **Fichier dev + fichier master** | Chacun a sa propre version de travail ; une fois prêt, on reproduit les changements sur le fichier master. Le formateur insiste : *"c'est trouver comment résoudre le problème qui prend le plus de temps — faire ou refaire est bien plus rapide"* |

📌 La première approche nécessite malgré tout de **publier** le modèle sémantique — donc au minimum une licence Pro quelque part dans l'équipe, malgré la formulation "sans Power BI Service" entendue en session.

---

## 🛍️ Projet du jour — Deluxe E-Commerce (BigQuery / Kaggle)

- Dataset **Deluxe E-Commerce** : boutique retail mondiale (vêtements + accessoires), tables customers / produits / commandes / campagnes marketing / website
- Disponible sur **Kaggle** — dataset connu, largement utilisé pour des exercices, avec une documentation des colonnes qui aide à reconstruire l'ERD sans deviner à l'aveugle
- Consigne explicite : se connecter à **BigQuery** (copier le dataset dans son propre projet), pas de raccourci CSV
- 🎯 Consigne principale, répétée plusieurs fois : choisir **1 à 2 périmètres maximum** et creuser en entonnoir (hypothèse générale → hypothèses spécifiques vérifiées), plutôt que de viser une overview qui finit par ne rien montrer faute de temps
  - Périmètres suggérés : sales + inventaire, customers + marketing, sales + customers
  - ⚠️ Le périmètre **marketing seul est limité** : impossible de calculer un ROI marketing faute de données de coût — le croiser avec website et comportement client est recommandé
- DAX **non obligatoire**, mais nécessaire pour aller plus loin (Time Intelligence, ratios, marges, variations de ventes déjà vus en [#23](23-power-bi-2.md))
- Méthode conseillée : définir la **user story** et l'audience cible **avant** d'ouvrir Power BI, identifier 5 hypothèses à vérifier plutôt que de multiplier les graphiques puis chercher une histoire après coup
- 💡 Phrase retenue du formateur : *"Je préfère avoir une recommandation béton que 4 recommandations basiques."*

---

## 🎯 Points clés pour les entretiens

- Savoir distinguer précisément **Report vs Dashboard** dans le vocabulaire strict Power BI — bon test pour vérifier qu'on ne confond pas jargon outil et langage courant
- Expliquer les **trois couches de sécurité** (Dashboard-Level, RLS, OLS) et surtout leur limite commune : elles ne protègent que les Viewers, jamais les Admins/Members/Contributors
- Argumenter pourquoi **masquer une colonne dans un report n'est pas une mesure de sécurité** — seul l'OLS retire réellement l'accès à la donnée sous-jacente ; bonne réponse pour une question gouvernance/conformité, particulièrement pertinente en contexte bancaire
- Donner un cas d'usage RLS concret (équipe régionale qui ne voit que ses propres données) — bon exemple business en entretien
- Expliquer la différence de gouvernance entre partager un Report/Dashboard classique (partage la couche sémantique) et une App (ne la partage jamais)

---

## 🔗 Liens avec d'autres notions

- La distinction Report vs Dashboard précise et corrige la définition volontairement simplifiée donnée en [#22](22-power-bi-1.md) — une notion peut légitimement être réintroduite plus finement plusieurs sessions plus tard
- Le Row-Level Security formalise, avec une vraie barrière côté données, ce qui n'était fait qu'avec des bookmarks/boutons verrouillés sur un slicer en [#22](22-power-bi-1.md) (vue pré-filtrée par commercial) — même intention, mais RLS est infranchissable pour un Viewer alors qu'un bookmark reste une simple facilité d'interface
- "Masquer visuellement ne sécurise pas" est le pendant gouvernance du principe déjà noté sur les KPIs et scorecards (#22) : une apparence propre en surface peut cacher un problème de fond — ici un problème de sécurité plutôt que de fiabilité de calcul
- Le dataset Deluxe E-Commerce (Kaggle) suit la même logique que les datasets publics déjà identifiés pour le portfolio banking (Bank Customer Churn, Kaggle) — réflexe transférable : vérifier si un dataset Kaggle documente déjà son propre schéma avant de reconstruire l'ERD à l'aveugle
- La consigne "1 à 2 périmètres max, creuser en entonnoir" rejoint directement la rétrospective personnelle déjà notée sur le projet RFM (aller trop vite sur la segmentation nuit à la clarté de la présentation) — ici le même conseil est donné en amont plutôt qu'en retour d'expérience



---

*Chapitre 3/3 — clôture le module Power BI ([#22](22-power-bi-1.md) → [#23](23-power-bi-2.md) → #24). Le Drillthrough, évoqué mais jamais détaillé sur les trois cours, reste à creuser en autonomie si besoin.*
