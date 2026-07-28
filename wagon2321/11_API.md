# 📝 #15 — API

**Date :** 24 juillet 2026
**Thème :** Data Collection, Big Data & API
**Tags :** API, Webhook, Data Engineering, REST, HTTP

---

## Contexte du cours

Ce cours fait suite au module SQL / transformation de données (le « T » de l'ETL). Il couvre la partie Extract : comment on va chercher la donnée là où elle se trouve, avant de la transformer et de l'agréger. Le rôle qui porte cette responsabilité en entreprise est le Data Engineer — surnommé « le plombier de la donnée ».

La séance part de la Data Collection au sens large (formats de fichiers, Big Data, bases de données) pour aboutir sur le cœur du sujet : les API et leur usage en tant que data analyst, avant d'ouvrir sur les webhooks, mécanisme complémentaire aux API.

## 1. La Data Collection

### 1.1 Le concept

La data collection consiste à rassembler des données venant de sources multiples, un peu comme les pièces d'un puzzle, afin d'en extraire des insights et des métriques exploitables. Cette donnée peut prendre des formes très variées : images, vidéos, audio, ou formats plus « base de données » comme le texte, le CSV, le XLS ou le HTML.

### 1.2 Les formats de fichiers

Chaque format a ses propres avantages en termes de lisibilité, de structure et d'usage :

| Format | Description | Usage typique |
|---|---|---|
| Text file | Texte brut, sans aucune structure | — |
| CSV (Comma Separated Value) | Champs séparés par des virgules | Fichiers, transferts de données |
| JSON (JavaScript Object Notation) | Paires clé-valeur ; n'a plus grand-chose à voir avec JavaScript aujourd'hui | Automatisation, appels API |
| HTML (Hypertext Markup Language) | Structure des pages web | Sites internet |
| XLS / XLSX | Format tableur, similaire au CSV avec méta-informations en plus (en-têtes, types...) | Excel, Google Sheets |
| XML (Extensible Markup Language) | Fait communiquer deux systèmes hétérogènes selon un langage commun | Transferts de données, appels API, sitemaps |
| ASCII | Norme d'encodage de caractères | Communication électronique bas niveau |

Un même jeu de données — un carnet de contacts avec `customer_id`, `firstname`, `name`, `phone` — illustre bien la différence entre formats. En **texte brut**, tout est mis à la chaîne sans repère, illisible :

```
customer_id firstname name phone   124 Antoine Farouk 0620456596 689 Camille Dupo 0785963247 478 Sarah Martoud 0687954866
```

En **CSV**, chaque ligne correspond à un client, les champs séparés par des virgules :

```
customer_id,firstname,name,phone
124,Antoine,Farouk,0620456596
689,Camille,Dupo,0785963247
478,Sarah,Martoud,0687954866
```

En **JSON**, chaque client est un objet avec des paires clé-valeur, et un champ peut contenir un tableau (ici un client peut avoir plusieurs numéros) :

```json
{"customer_id": 124, "name": {"firstname": "Antoine", "surname": "Farouk"}, "phone": [0620456596, 0144568321]}
```

En **XML**, la même information est encapsulée dans des balises ouvrantes/fermantes, pensées pour que deux systèmes différents se comprennent :

```xml
<customer>
  <customer_id>124</customer_id>
  <firstname>Antoine</firstname>
  <surname>Farouk</surname>
  <phone>0620456596</phone>
</customer>
```

### 1.3 Données structurées vs non structurées : le pipeline Bronze / Silver / Gold

Quand on va chercher de la donnée à la source, elle arrive brute, sans organisation spécifique : c'est la donnée **Bronze** (raw data), par exemple des fichiers vidéo de durées variables. Elle est généralement stockée sur des solutions de stockage cloud comme Amazon S3, Google Cloud Storage ou Azure.

Cette donnée brute est ensuite nettoyée : suppression des valeurs nulles, normalisation des formats (l'exemple classique est le numéro de téléphone, écrit tantôt avec le +33, tantôt avec des espaces ou des parenthèses). On obtient alors la donnée **Silver**.

Enfin, une fois harmonisée selon le lexique métier de l'entreprise, la donnée peut être enrichie, agrégée et rendue compréhensible pour les équipes business : c'est la donnée **Gold**, celle que l'on manipule avec des outils comme Google BigQuery, Amazon Redshift ou Snowflake — c'est le travail déjà fait lors du module SQL.

## 2. Le Big Data

La collecte de données ne date pas d'hier : les premières écritures cunéiformes de Mésopotamie (3300 av. J.-C.) constituent déjà une forme de base de données — marchands, religieux et rois y consignaient chacun leurs propres informations. Ce besoin est apparu spontanément dans plusieurs civilisations non connectées entre elles, signe qu'il s'agit d'un besoin fondamental de toute société organisée.

Depuis, les pipelines de données ont évolué des pierres gravées transportées par un coureur jusqu'au stockage cloud connecté en Wi-Fi. Cette facilité croissante de stockage et de transmission a eu un impact direct : toujours plus de données. Le volume mondial est ainsi passé d'environ 2 zettaoctets en 2010 à un peu plus de 17 zettaoctets en 2015, pour atteindre une projection de 175 zettaoctets en 2025 — une croissance quasi exponentielle.

### 2.1 Les 3V du Big Data

Le Big Data se caractérise traditionnellement par 3 V :

- **Volume** : des quantités de données toujours plus importantes (téraoctets, pétaoctets), issues par exemple des transactions ou des capteurs.
- **Variété** : des données de plus en plus hétérogènes — RDBMS, images, vidéos, sons, XML...
- **Vélocité** : un besoin de traiter la donnée à différents rythmes (batch, temps réel, périodique, en flux continu).

### 2.2 Des besoins de stockage toujours plus complexes

Plus la variété de la donnée augmente, plus les capacités de stockage nécessaires doivent se démultiplier. On peut visualiser cette croissance comme une pyramide :

- **Megabytes — ERP** : historique d'achats, de paiements, détails d'achats.
- **Gigabytes — CRM** : segmentation, détail client, historique client, détail de contact, historique de commandes.
- **Terabytes — Web** : données de tests A/B, search marketing, funnels, logs web, historique d'offres.
- **Petabytes — Big Data** : sentiment, contenu généré par les utilisateurs, coordonnées GPS, speech-to-text, SMS/MMS, vidéo HD, web mobile, RFID, réseaux sociaux.

Chaque palier correspond à un besoin croissant de **variété et de complexité** de la donnée traitée.

## 3. Les bases de données : architecture et optimisation

### 3.1 Du on-premise au cloud

Historiquement, les entreprises hébergeaient leurs serveurs en interne (on-premise) : coûteux et difficiles à dimensionner correctement. Le cloud a permis d'optimiser dynamiquement la capacité disponible, en fonction du besoin réel.

### 3.2 Partitioning et distribution

Pour absorber un volume de données croissant, trois approches existent :

1. **Augmentation de la taille** de la base — limitée par la technologie, le prix et la performance.
2. **Réplication** — la base principale (écriture) est dupliquée vers des répliques de lecture pour absorber la charge des nombreux lecteurs ; cela ne résout rien côté écriture.
3. **Distribution / Partitioning** — la base est éclatée en plusieurs petits serveurs thématiques, un peu comme des bibliothèques spécialisées. L'écriture est répartie entre plusieurs petits serveurs, et la lecture se fait directement sur le serveur pertinent où se trouve l'information. C'est la solution la plus complexe à mettre en place, mais la plus efficace à grande échelle.

### 3.3 Le calcul parallèle

Diviser un calcul entre plusieurs « cerveaux » (serveurs, machines, ou même personnes) permet de réduire drastiquement le temps de traitement — au prix d'une puissance de calcul plus importante. Ce principe ne s'applique pas à tous les types de calculs, mais il est à la base du traitement de données à grande échelle.

L'exercice fait en classe l'illustre bien : pour calculer `(4 * 6 / 8) + (6 / 2 * 4) + (10 * 6 / 5) - (7 * 2 - 5) = +18`, une seule personne qui exécute les sous-calculs les uns après les autres met **11 unités de temps**. En répartissant les 4 sous-calculs entre plusieurs « cerveaux » qui travaillent simultanément avant de sommer les résultats, le même total est obtenu en seulement **4 unités de temps**. Diviser le travail ne change pas le volume total de calcul, mais réduit le temps nécessaire pour l'obtenir.

### 3.4 Spécialisation des formats de stockage : SQL vs NoSQL

Face à la diversité des usages, différentes familles de bases de données se sont spécialisées :

- **SQL** — Bases de données relationnelles.
- **NoSQL** — Colonnaires (Column-oriented DBMS), Clé-valeur (Key-value), Graphes (Graph database), Orientées documents (Document-oriented database).

### 3.5 Les différentes structures de bases de données

| Type | Usage principal | Application | Outils |
|---|---|---|---|
| **Relationnelle (SQL)** | Données orientées lignes, structurées, normalisées, tables liées entre elles par une clé primaire | Transactionnel (OLTP), bases standards utilisées par l'IT au quotidien | MySQL, PostgreSQL, Oracle, SQLite, Azure SQL |
| **Colonnaire (NoSQL)** | Stockage en colonnes pour optimiser les agrégations sur un grand nombre de lignes | Entrepôt analytique (OLAP), agrégations, calculs lourds | BigQuery, Redshift, Snowflake |
| **Graphe (NoSQL)** | Gérer des liens et relations entre personnes ou objets, via nœuds et liens | Réseaux sociaux, routes et itinéraires | Neo4j, OrientDB, FlockDB |
| **Clé-valeur (NoSQL)** | Stockage clé → valeur, très simple et très performant | Logs, chat, cache, IoT, panier d'achat | Redis, Memcached, Azure Cosmos DB, SimpleDB |
| **Document (NoSQL)** | Clé → valeur, où la valeur est un dictionnaire flexible pouvant stocker des informations complexes | Moteur de recherche, catalogue produit, bibliothèques numériques, historique utilisateur | Elastic Search, MongoDB, Cassandra, CouchBase, DynamoDB |

Pour bien visualiser la différence, reprenons le même carnet de contacts (Antoine Farouk, Camille Dupo, Sarah Martoud) dans chaque structure :

- **Relationnelle** : une table `clients` (id, firstname, name) liée par une clé étrangère à une table `téléphones` (phone, client_id) — un client peut ainsi avoir plusieurs numéros sans dupliquer ses infos.
- **Colonnaire** : les mêmes données, mais organisées colonne par colonne (`id`, puis `firstname`, puis `name`, puis `phone`) plutôt que ligne par ligne — plus rapide quand on veut agréger une seule colonne sur des millions de lignes.
- **Graphe** : les individus sont des nœuds, et les liens entre eux portent un sens (« amis », « cousins », « en couple »).
- **Clé-valeur** : une simple paire `id → nom` d'un côté et `id → téléphone` de l'autre.
- **Document** : un objet JSON complet par client, indexé par une clé (`client_id`), regroupant nom et tous les numéros dans un seul document flexible.

## 4. Les API

### 4.1 Définition

Une **API** (Application Programming Interface) expose un service, le plus souvent de la donnée. Les développeurs — et les data analysts — écrivent des programmes qui consomment ce service, sans avoir besoin de connaître le fonctionnement interne de l'application qui l'expose.

En tant que data analyst, les API servent principalement à deux choses : extraire de la donnée de sources tierces vers la plateforme de données (ex. Google Ads → CRM), ou faire communiquer différents outils entre eux (ex. centre d'appel → CRM).

### 4.2 Ce qu'il se passe lors d'une requête : la métaphore du restaurant

Le fonctionnement d'une API se comprend bien avec la métaphore du restaurant : le **client** passe commande (la **requête**), le **serveur** (l'interface, l'API elle-même) transmet la commande en cuisine (l'**application**) puis rapporte le plat (la **réponse**). Le client n'a jamais accès à la cuisine directement — seule l'interface fait le lien entre les deux.

### 4.3 Les types de clients

On peut interroger une API depuis différents types de « clients » :

- des **outils no-code** (Insomnia, Postman...) ;
- un simple **navigateur web** (Chrome, Firefox, Safari) ;
- des **commandes bash** (curl) ;
- ou directement depuis un **langage de programmation** (Python, JavaScript, Ruby...).

### 4.4 Anatomie d'une requête

Une requête HTTP se décompose en quatre grandes parties : l'URL, la méthode (ou verbe), les headers, et éventuellement un body.

#### L'URL

L'URL permet de localiser une ressource sur le web, sans ambiguïté. Prenons l'exemple `https://www.google.com:443/search?q=le+wagon&hl=en` :

- `https` est le **scheme** (le protocole).
- `www.google.com` est le **host**, plus précisément le nom de domaine.
- `:443` est le **port** du serveur (443 étant le port par défaut pour HTTPS, on n'a généralement pas besoin de le préciser).
- `/search` est le **path** ou **endpoint** : il définit la page exacte demandée sur le site.
- `?q=le+wagon&hl=en` est la **query string**, composée de **query parameters**. Elle est optionnelle et précise ici les mots-clés recherchés et la langue souhaitée — l'équivalent de préciser sa commande au restaurant (une couleur, une taille de t-shirt...).

#### Les méthodes (verbes HTTP)

La méthode définit l'action souhaitée sur la ressource identifiée par l'URL :

| Méthode | Rôle |
|---|---|
| GET | Obtenir une donnée — chaque clic sur un lien, chaque URL tapée dans la barre d'adresse est une requête GET |
| POST | Envoyer / enregistrer une nouvelle donnée — déclenchée typiquement par la soumission d'un formulaire |
| PUT | Remplacer entièrement une ressource existante |
| PATCH | Modifier partiellement une ressource existante |
| DELETE | Supprimer une ressource |

GET et POST sont de loin les deux méthodes les plus courantes ; PUT, PATCH et DELETE existent mais sont moins utilisées en pratique. Pour savoir quelle méthode utiliser dans un contexte donné : lire la documentation de l'API.

#### Les headers

Les headers donnent du contexte supplémentaire au serveur pour qu'il adapte sa réponse. Quelques exemples côté requête :

- `Accept: text/html` — indique qu'on souhaite une réponse au format HTML.
- `Accept-Language: en-GB` — indique qu'on souhaite une réponse en anglais britannique si plusieurs langues sont disponibles.
- `User-Agent: Mozilla/5.0 ...` — indique quel navigateur et quel système d'exploitation sont utilisés (par exemple Firefox 64 sur macOS Mojave). C'est ce mécanisme qui explique pourquoi un même site peut s'afficher différemment sur mobile et sur ordinateur.

Réciproquement, le serveur renvoie lui aussi des headers dans sa réponse, pour aider le client à interpréter ce qu'il reçoit — voir plus bas.

#### Le body

Le body n'existe que pour les requêtes qui envoient de la donnée (typiquement POST) : il contient le **payload** transmis au serveur. Exemple simple : un formulaire de connexion Facebook non authentifié, où l'on doit saisir un email et un mot de passe pour se connecter — cet email et ce mot de passe constituent le body de la requête.

#### L'Authorization

La plupart du temps, il faut être authentifié pour utiliser une API : le serveur sait qui fait la requête et peut autoriser ou refuser l'accès (quota de requêtes dépassé, droits insuffisants...). Deux façons principales d'indiquer qui l'on est :

- **Dans la query string** : directement dans l'URL, par exemple `?api_key=xxxxx`.
- **Dans les headers** : par exemple `Authorization: Bearer xxxx`.

### 4.5 Sécurité importante

> ⚠️ Une clé d'API ne doit **jamais** être placée en clair dans un paramètre de l'URL. Sur Internet, chaque requête laisse une trace via les **référeurs (referrers)** — les outils d'analytics comme GA4 permettent de voir précisément d'où vient chaque visiteur avant d'arriver sur un site : on n'est jamais réellement anonyme sur Internet. Si une clé d'API circule en clair dans une URL, elle peut être interceptée et réutilisée par un tiers via ces référeurs. Pour une API de blagues, la conséquence est anecdotique ; pour une API bancaire ou de gestion de patrimoine, c'est une faille critique — c'est pourquoi ce type d'API impose de passer la clé par le header `Authorization` plutôt que par l'URL.

### 4.6 Anatomie d'une réponse

Une réponse HTTP se décompose en trois parties : le **status code**, les **headers**, et le **body**.

**Les codes de statut** indiquent si la requête a pu être traitée ou non :

| Code | Signification |
|---|---|
| 200 | Succès — réponse standard d'une requête HTTP réussie |
| 301 | Moved Permanently — la page demandée a une nouvelle URL |
| 401 / 403 | Unauthorized / Forbidden — authentification manquante ou insuffisante (clé/token invalide) |
| 404 | Not Found — ressource introuvable |
| 500 | Internal Server Error — erreur côté code serveur, qui n'a pas pu renvoyer de réponse |

**Les headers de réponse** donnent au client des méta-informations pour interpréter ce qu'il reçoit, par exemple :

- `ETag: "cc-5344555136fe9"` — identifie la version de la page servie, ce qui permet au navigateur d'utiliser son cache local et de demander moins d'informations lors de la prochaine visite.
- `Content-Length: 204` — indique que le corps de la réponse fait 204 octets, ce qui permet au client de vérifier que tout a bien été téléchargé.
- `Content-Type: text/html` — indique le format du corps de la réponse (norme MIME) ; les valeurs courantes incluent `image/jpeg`, `video/mp4` ou `application/json` (très fréquent avec les API).

**Le body** est le contenu réellement renvoyé : HTML, données, JSON...

### 4.7 Démonstration pratique avec Insomnia

La séance se termine par une démonstration en direct dans **Insomnia**, un client API open source (utilisé notamment chez Netflix), avec une interface plus confortable qu'un navigateur — en particulier pour ajouter des headers personnalisés. Le principe reste le même que taper une URL dans un navigateur : on choisit une destination, on précise ce que l'on cherche, puis d'éventuels paramètres.

- **API Chuck Norris** (GET) : récupération d'une blague aléatoire — la réponse arrive avec un statut 200 et contient la blague dans le body.
- **API Rick and Morty** (GET + query string) : récupération de tous les personnages, filtrés uniquement sur ceux marqués comme « morts » grâce à un paramètre dans la query string.
- **Requête POST** avec un body en JSON : le serveur confirme la bonne réception en renvoyant les données envoyées.
- **Ajout d'une clé d'autorisation dans le header** : démonstration de l'ajout d'un `Authorization: Bearer ...` pour sécuriser une requête.
- Une faute de frappe volontaire dans l'URL permet aussi d'illustrer un cas d'erreur (ressource introuvable).

Point important souligné en cours : toutes les requêtes qui font fonctionner un site web sont visibles dans les outils de développement du navigateur (onglet **Network**). Tout Internet fonctionne, en coulisses, à coups d'appels d'API.

## 5. Les Webhooks

### 5.1 Principe

Le webhook fonctionne à l'inverse de l'API. Avec une API, c'est le client qui doit interroger le serveur pour savoir si une information est disponible — mais on ne peut pas raisonnablement demander toutes les 30 secondes « y a-t-il du nouveau ? ». Avec un webhook, c'est le serveur qui envoie automatiquement l'information dès qu'un événement survient : *don't call us, we will call you*.

L'analogie du Moyen-Âge est parlante : sans sonnette, il faut faire des allers-retours à la porte pour savoir si les invités sont arrivés (c'est l'API — on interroge en boucle). Avec une sonnette, on est prévenu directement au bon moment (c'est le webhook — l'information vient à nous).

### 5.2 Cas d'usage concrets

- **MailChimp → CRM** : dès qu'un utilisateur remplit un formulaire d'inscription à la newsletter, l'information est transmise automatiquement au CRM interne, sans avoir à multiplier les appels d'API « est-ce qu'il y a du nouveau ? ».
- **Shopify → email + Slack** : dès qu'une commande est passée, un email de confirmation part automatiquement au client, et une notification Slack prévient l'équipe qu'il faut préparer le colis avec l'adresse de livraison.
- **Stripe → outil de comptabilité** : dès qu'un paiement est effectué, l'outil de comptabilité est notifié automatiquement du montant encaissé.

### 5.3 API ou Webhook : comment choisir ?

Les webhooks permettent de limiter les appels d'API dans le fonctionnement courant d'une entreprise, en particulier pour des événements imprévisibles ou en temps réel. Côté data, en revanche, on utilise beaucoup plus les API — notamment pour l'enrichissement de données, avec des appels planifiés à des rythmes précis (une, deux, cinq fois par jour), sachant que les appels d'API sont la plupart du temps coûteux. L'exemple donné en cours : connecter l'API d'un outil d'A/B testing à un assistant IA pour automatiser l'analyse des résultats de campagnes.

## 6. Évolution du métier de la data & de l'IA

Les intitulés de poste évoluent : « data analyst » et « business analyst » tendent à se spécialiser par domaine métier (data finance, data produit...), tandis que le rôle d'**analytics engineer** connaît une forte croissance. L'ETL classique reste coûteux (de l'ordre de 10 000 €/mois pour le seul extract & load dans certaines structures), ce qui pousse à explorer des agents IA capables de réduire le besoin de stockage massif.

Recommandation du formateur : apprendre les fondamentaux sans IA d'abord, pour bien comprendre les concepts, avant de les intégrer dans son usage quotidien. Le marché de l'emploi data est décrit comme « assez saturé », mais cela ne doit pas être décourageant pour autant.

---

### 💡 Ce que j'ai retenu

- Une API expose un service, un webhook le pousse : deux façons complémentaires de faire circuler la donnée, à utiliser selon que l'événement est prévisible (API, planifiable) ou non (webhook, temps réel).
- La structure d'une requête (URL → méthode → headers → body) est toujours la même quelle que soit l'API — c'est ce socle commun qui rend le concept transférable d'un outil à l'autre.
- Le point de vigilance le plus concret pour la suite : ne jamais mettre une clé d'API dans l'URL, toujours passer par le header Authorization.
- Le choix d'une base de données (relationnelle, colonnaire, graphe, clé-valeur, document) dépend avant tout du cas d'usage — il n'y a pas une structure « meilleure » que les autres dans l'absolu.

### ❓ Questions / Points flous

- [ ] Comment repérer, dans la documentation d'une API, si l'authentification attendue passe par un header, un token OAuth ou une clé en query param ?
- [ ] Dans quels cas concrets, côté data analyst, privilégier un appel API planifié plutôt qu'un webhook, quand les deux semblent possibles ?

### 🔗 Liens avec d'autres notions

Fait suite au module SQL / Transform (le « T » de l'ETL) ; prépare la session de lundi sur la partie Extract complète. À relier avec les architectures Bronze/Silver/Gold vues ici et le futur module sur les pipelines d'automatisation (Make, n8n).

### ✅ Actions post-session

- [ ] Télécharger et installer Insomnia pour les exercices pratiques sur les API.
- [ ] Compléter les challenges API disponibles sur Discord.
