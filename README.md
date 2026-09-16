# Brocode

Base de connaissances personnelle construite au fil du parcours **Le Wagon — Data Analytics, batch 2321**. Elle rassemble des cours, des fiches de concepts, des exemples de code et des projets pour apprendre, réviser et réutiliser les méthodes étudiées.

**Obsidian est l’interface de lecture et de travail du Brocode.** Git conserve l’historique des notes ; ce dépôt permet aussi de partager le parcours et les travaux réalisés.

## Commencer ici

Dans Obsidian, ouvrir **[Accueil Brocode](Accueil%20Brocode.md)**, le point d’entrée de la navigation quotidienne.

| Besoin | Point d’entrée |
|---|---|
| Suivre les cours et retrouver leurs variantes | [Catalogue des cours](navigation/Cours.md) |
| Retrouver les travaux d’un modèle IA | [Modèles IA](modeles-ia/README.md) |
| Revoir une notion ou une méthode | [Codex — concepts et guides](codex/README.md) |
| Consulter une syntaxe ou un aide-mémoire | [Références — cheat sheets et lexiques](references/README.md) |
| Explorer une application concrète | [Projet RFM — segmentation Olist](projets-perso/rfm-segmentation-olist.md) |

Les notes couvrent Google Sheets, les KPI, SQL et BigQuery, Git, dbt, les API, le tracking, l’automatisation, la visualisation de données et Python.

## Références de cours et modèles IA

Chaque sujet possède **une version de référence pour la lecture**. Lorsqu’une autre rédaction existe, elle est conservée comme variante et reliée à la référence dans les deux sens.

Pour les neuf cours disposant d’une version Sol, celle-ci est la référence retenue ; la rédaction Sonnet reste accessible comme variante. Les autres cours conservent leur référence Sonnet. Ce choix de lecture ne constitue pas une nouvelle validation technique du contenu.

Le bandeau placé au début de chaque cours permet d’identifier immédiatement son modèle de rédaction, son rôle et son éventuelle autre version.

- **Claude Sonnet** a rédigé les notes de `wagon2321/cours/`.
- **ChatGPT Sol** a rédigé les notes de `wagon2321/cours_sol/` et la cheat sheet Python / NumPy / pandas.
- Les quatre autres documents de `references/` sont de **Claude Sonnet**.
- L’attribution des fiches du **Codex** reste à confirmer.

La propriété `modeles_ia` relie les notes à la page de leur modèle, y compris hors des dossiers de cours. Les révisions ultérieures ne remplacent pas l’attribution de la rédaction initiale.

## Organisation du coffre

| Dossier | Contenu |
|---|---|
| `wagon2321/cours/` | Cours Sonnet et compléments de session |
| `wagon2321/cours_sol/` | Cours Sol |
| `wagon2321/fiche_challenge/` | Fiches de révision issues des challenges |
| `codex/` | Concepts transversaux, guides et code réutilisable |
| `codex/a-creer/` | Fiches identifiées, encore à rédiger |
| `references/` | Cheat sheets et lexiques |
| `projets-perso/` | Projets et analyses personnelles |
| `modeles-ia/` | Pages des modèles et catalogue de leurs travaux |
| `navigation/` | Catalogue des cours, conventions et journal de nettoyage |
| `workspace/` | Espace personnel de travail, exclu du dépôt Git |

## Fonctionnement dans Obsidian

Les catalogues utilisent le module natif **Bases** pour classer les notes à partir de leurs propriétés. La vue **Références** présente les cours par date ; **Toutes les versions** les regroupe par sujet. Les pages des modèles rassemblent automatiquement leurs travaux.

Les cours renvoient aux fiches transversales du Codex, qui proposent des liens de retour vers les cours concernés. Les longs chapitres réorganisés disposent de grandes parties et d’un plan de lecture repliable.

Les noms de fichiers historiques sont conservés pour stabiliser les liens. Le titre, la date et le numéro de session renseignés dans les propriétés servent de repères. Une note portant le statut `a_creer` reste à compléter.

Pour utiliser le coffre depuis une copie du dépôt, ouvrir le dossier `brocode` dans Obsidian et activer le module natif **Bases**. Les réglages personnels `.obsidian/` sont exclus de Git. Sur GitHub, les fichiers Markdown restent consultables, mais les catalogues Bases et la navigation par wikilinks s’utilisent dans Obsidian.

## Faire évoluer les notes

Les [conventions Obsidian](navigation/Conventions%20Obsidian.md) décrivent les propriétés, les liens entre versions et la méthode de rédaction. Elles servent de référence pour ajouter un cours ou une fiche en conservant une structure cohérente.

Le [journal de nettoyage](navigation/Nettoyage%20Obsidian.md) conserve les décisions de migration et les points à compléter.
