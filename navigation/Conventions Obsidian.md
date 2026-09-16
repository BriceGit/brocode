# Conventions Obsidian

[[Accueil Brocode|Accueil]]

## 📄 Schéma Obsidian

Le sujet (course_id), l’auteur (modeles_ia) et le rôle (role_version) sont indépendants.
Une seule note sert de référence à un cours ; ses variantes sont conservées.

- **type** : course, concept, guide, reference, project, recap, redirect ou model.
- **status** : active ou a_creer ; **role_version** : reference ou variante.
- **course_id** : identifiant stable du sujet partagé par les variantes.
- **reference** : wikilink vers la référence depuis une variante ; **variantes** : liste de liens réciproques.
- **modeles_ia** : liste de wikilinks vers les modèles de rédaction ; **modeles_revision** : révisions de contenu ultérieures, sans remplacer l’auteur initial.
- **language** : langue humaine ; **code_language** : langage technique ; **database** : contexte de base de données.
- **session** : entier attesté ; **date** : date du cours ; **updated** : dernière modification éditoriale lorsqu’elle est renseignée.
- **topics** : sujets détaillés ; **tags** : marqueurs structurels, par exemple brocode et wagon2321/cours.
- Les fiches ont un frontmatter minimal ; attribution inconnue : modeles_ia vide et attribution a_confirmer.
- Les noms de fichiers existants restent stables, même si leur ancien numéro diffère du cours. Les propriétés pilotent le classement.
- Les liens ciblent un fichier réel, avec un libellé lisible si nécessaire. Un titre YAML ou un alias seul ne sert pas d’adresse implicite.
- Les alias nomment la note entière ; ils ne concurrencent pas des fiches-concepts existantes.
- Les sommaires ciblent les titres de sections ; les nouveaux noms de notes évitent les caractères réservés.


Les propriétés servent au classement ; le bandeau du cours indique immédiatement le modèle et la version. Les notes personnelles de workspace et certains documents historiques peuvent ne pas avoir de propriétés.

Les catalogues Bases constituent les index à jour. Un projet vide porte le statut a_creer. Les dates de cours sont reprises des sources attestées ; le numéro de session du Reboot reste à confirmer.

## Production d’une note

1. Réunir les sources fournies par Brice avant de rédiger, lorsqu’il le demande.
2. Conserver les explications et exemples utiles ; signaler les corrections techniques dans une section dédiée.
3. Renseigner le modèle de rédaction et les sujets ; relier référence et variante réciproquement.
4. Ajouter des liens vers les fiches transversales existantes.
