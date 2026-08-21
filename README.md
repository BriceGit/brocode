# 🧠 brocode

> **Base de connaissances personnelle** — **Le Wagon Data Analytics (#batch 2321)**

**Dernière refonte** : 21 août 2026 — remplace l'ancien README « SQL Cookbook », devenu obsolète depuis le passage en vault Obsidian multi-format (dossiers, deux formats de notes, wikilinks).

---

## 📌 Nature du projet

Le brocode a une double nature :

- **Vault Obsidian** — notes cross-linkées via wikilinks `[[...]]`, frontmatter YAML sur les chapitres de cours, fiches-concept atomisées sur les notions transversales.
- **Repo Git versionné et public sur GitHub** (`BriceGit`) — gardé public volontairement : l'avantage compétitif en entretien tient à la compréhension et à la capacité d'expliquer, pas au contenu copiable d'un README ou d'une commande Git. Le repo sert aussi de pièce de portfolio pour la recherche Genève.

Anciennement `sql-cookbook`, renommé et restructuré une fois que le scope a dépassé le seul SQL (Git, dbt, API, BI, Python...).

---

## 🎯 Objectif

Deux fonctions en parallèle :
1. **Apprentissage structuré** — synthétiser chaque session du bootcamp (transcript Notion + audio + screenshots) en note complète, pédagogique et durable.
2. **Portfolio** — donner à voir, à un recruteur genevois, une trace organisée et compréhensible de la montée en compétence.

---

## 🗂️ Structure des dossiers

| Dossier          | Contenu                                                                     | Auteur                                     |
| ---------------- | --------------------------------------------------------------------------- | ------------------------------------------ |
| `wagon2321/`     | Chapitres de cours. Un par session du batch 2321                            | Synthèse IA (Claude Sonnet et ChatGPT Sol) |
| `codex/`         | Code perso, requêtes, raisonnement synthétisé, fiches-concept atomisées     | Brice                                      |
| `projets-perso/` | Deep-dives analytiques (Projet 1 — churn banking, etc.)                     | Brice                                      |
| `references/`    | Matériel externe consulté mais non écrit par Brice (cheat sheets, lexiques) | Externe                                    |

Le filing dans tel ou tel dossier reste une question de lisibilité côté GitHub — dans Obsidian, les wikilinks résolvent par **nom de note**, indépendamment du dossier où elle se trouve.

---

## 📄 Deux formats de notes

### 1. Chapitres de cours — `type: course`

Une note complète par session, avec frontmatter YAML obligatoire :

```yaml
---
title: "Window Functions"
aliases: ["Fonctions de fenêtrage"]
type: course
status: reference
course: "Le Wagon — Data Analytics"
batch: 2321
session: 9
date: 2026-07-15
language: fr
database: "BigQuery / GoogleSQL"
topics:
  - SQL
  - Window Functions
tags:
  - brocode
  - wagon2321/cours
  - sql
---
```

- `topics` = taxonomie de contenu (de quoi parle la note) ≠ `tags` = marqueurs structurels/navigation uniquement (`brocode`, `wagon2321/cours`, + tag sujet). Cette séparation évite le drift entre les deux.
- `session` reste un entier nu (pas `"#9"`) pour permettre un tri numérique correct via Dataview.

### 2. Fiches-concept atomisées

Notes courtes, standalone, cross-linkées entre elles et vers leur chapitre source — sur des notions transversales qui dépassent une seule session (ex. `WHERE vs HAVING`, `SAFE_DIVIDE`, `Data Leakage`).

- Pas de frontmatter, sauf indication contraire.
- Titre naturel descriptif, sans kebab-case ni numéro — contrairement à l'ancienne convention `NN-nom-fichier.md` héritée du repo GitHub classique, abandonnée depuis le passage en vault.
- ⚠️ Éviter `:` et `/` dans les titres de wikilinks — ces caractères cassent la résolution des ancres Obsidian.
- Sommaires internes en `[[#Titre de section exact]]`.

---

## 🔄 Sommaire dynamique (Dataview)

Plutôt qu'un tableau de statut à maintenir à la main — l'ancien README « SQL Cookbook » en était un, et c'est en partie pour ça qu'il a périmé — le suivi peut vivre directement dans Obsidian via une requête sur le frontmatter :

```dataview
TABLE session AS "Session", date AS "Date", topics AS "Sujets"
FROM "wagon2321"
WHERE type = "course"
SORT session ASC
```

*(nécessite le plugin communautaire Dataview ; sur GitHub ce bloc s'affiche en texte brut — la requête ne s'exécute que dans Obsidian)*

---

## ⚙️ Workflow de production

1. Brice fournit le transcript Notion (capture live + résumé audio par IA) + captures d'écran, parfois en plusieurs envois — Claude attend que tout soit réuni avant de rédiger si signalé.
2. Claude synthétise en note Obsidian-ready : profondeur pédagogique ajoutée au-delà du transcript, erreurs de la source corrigées **explicitement dans une section dédiée**, actions à échéance signalées.
3. Cross-links vers les notions existantes via wikilinks.
4. Fiches-concept compagnons produites pour les notions transversales identifiées dans la session.

---

## 🧰 Écosystème & outils

- **Vault / capture** : Obsidian · Notion (audio + résumé IA)
- **Versioning** : Git / GitHub — public (`BriceGit`)
- **Dev** : VS Code · Jupyter Notebook · DBeaver
- **Data stack** : BigQuery/GoogleSQL · dbt (DuckDB en local) · Python (pandas, sklearn, sktime, scipy, matplotlib, seaborn, Plotly) · Power BI (via Parallels) · Looker Studio · Google Sheets
- **Intégrations** : Zapier · Make · Fivetran · HubSpot CRM API · Insomnia · BeautifulSoup · `requests`

