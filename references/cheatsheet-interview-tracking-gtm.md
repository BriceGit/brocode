# ⚡ Cheat-sheet interview — Tracking Web & GTM

*Révision rapide avant entretien. Version condensée du chapitre #17.*

---

## 🔑 Les 3 concepts en une phrase

| Concept | Question | Réponse type |
|---|---|---|
| **Trigger** | Quand ? | La condition qui déclenche le tag (clic, page vue, custom event...) |
| **Variable** | Quoi/comment ? | La donnée dynamique récupérée (prix, nom de page, form ID...) |
| **Tag** | Quoi faire ? | Le snippet qui envoie l'info à un outil précis (1 tag = 1 event = 1 outil) |

**Ordre de setup logique : Trigger → Variable → Tag**

---

## ❓ Questions probables + réponses courtes

**"C'est quoi GTM en une phrase ?"**
> Un Tag Management System gratuit de Google qui centralise le déploiement de tags/tracking sur un site sans dépendre d'un dev à chaque changement, et qui distribue l'info à plusieurs outils (GA4, Ads, Amplitude...) via un seul setup.

**"Est-ce que GTM stocke de la donnée ?"**
> Non. GTM est une porte d'entrée qui **distribue** l'info vers les outils connectés — il ne stocke rien. Conséquence directe : impossible de récupérer de la donnée a posteriori si le tracking n'était pas en place.

**"Quelle est la différence entre un Configuration tag et un Event tag ?"**
> Le Configuration tag (Google Tag) connecte GTM à un outil une seule fois (ex: ID de compte GA4). Chaque action trackée ensuite (add_to_cart, sign_up...) a son propre Event tag, qui référence ce Configuration tag.

**"Le nom d'un event doit-il être identique partout ?"**
> Ça dépend où. Le nom du **Custom Event trigger** doit être **strictement identique** (casse incluse) au nom poussé dans le DataLayer par le site — sinon le trigger ne se déclenche jamais. Le nom d'event affiché **dans le tag GA4**, lui, est libre : c'est juste ce qui apparaît dans les rapports.

**"Front-end vs back-end tracking, tu choisis quoi et pourquoi ?"**
> Front-end (client) pour l'intent utilisateur (clics, scrolls) — facile à mettre en place, pas de dev nécessaire, mais peut perdre de la donnée (ad blockers, erreurs JS). Back-end (serveur) pour les outcomes système — plus complet mais nécessite un développeur. Les deux sont complémentaires : le front capture ce que l'utilisateur a *tenté*, le back ce qui a *abouti*.

**"Comment tu inspectes ce que trackerait un concurrent ?"**
> Console navigateur → taper `dataLayer`, ou Preview Tool de GTM, ou extension Data Layer Checker. Le DataLayer expose les noms exacts des events/variables utilisés sur un site.

**"Comment tu gères un tracking cassé sans que personne s'en rende compte ?"**
> Alertes automatiques sur absence de données (ex: 0 event sur "add_to_cart" pendant X heures = signal). Sans ça, un changement mineur côté site (casse, renommage) peut casser le tracking pendant des mois sans être détecté.

**"C'est quoi la sanction RGPD si on ne respecte pas les règles ?"**
> Jusqu'à 4% du chiffre d'affaires de la maison mère (CNIL).

---

## 🧮 Chiffres à retenir

| Donnée | Valeur |
|---|---|
| Sanction CNIL max | 4% du CA de la maison mère |
| Conservation données e-commerce | 1 à 2 ans |
| Convention de nommage | `snake_case`, pattern `object_action` |

---

## ⚠️ Pièges classiques à mentionner (montre que tu as pratiqué)

- Tester aussi les **faux positifs** (un tag qui se déclenche sur la mauvaise action), pas juste "est-ce que ça se déclenche"
- Un changement de **casse** sur un nom d'élément côté site casse le tracking silencieusement
- **Accès GTM limité** à 1-2 personnes admin — accès complet = maîtrise de toute la donnée envoyée et à qui
- Toujours **tracking plan avant setup**, jamais l'inverse

---

## 🗣️ Une anecdote structurée à avoir sous la main

*(Utile pour "donne-moi un exemple concret" en entretien)*

> "Sur un exercice, j'ai dû tracker un formulaire d'inscription newsletter avec GTM : j'ai inspecté le site pour récupérer l'ID exact du formulaire (`newsletter-form`), créé un trigger Form Submission avec cette condition précise, puis un tag GA4 Event nommé `sign_up`. Le point que j'ai trouvé le plus important : bien distinguer le nom technique côté DataLayer (à copier exactement) du nom d'event que je choisis pour l'affichage dans GA4 (libre) — une confusion classique qui casse le setup si on ne fait pas attention."
