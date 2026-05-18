# Marketplace formateurs externes — Roadmap d'implémentation complète

> Sprint D du plan P3 #2. **Statut actuel : scaffolding livré, feature non-fonctionnelle.**
> Version : 2026-05-19 · À valider avec le client avant exécution.

---

## TL;DR — Pourquoi ce n'est pas fini

La feature "Marketplace formateurs externes" est ambitieuse : permettre à des formateurs indépendants de créer ET vendre leurs propres modules sur la plateforme MFT, avec revenue split automatique.

Pour la rendre opérationnelle, **8 chantiers complémentaires** sont nécessaires, dont **3 hors-code** (juridique, Stripe Connect, KYC). C'est pour cette raison qu'on a livré uniquement le scaffolding (tables DB + page admin placeholder) et qu'on attend une décision client formelle avant d'attaquer le reste.

---

## Ce qui a été livré dans ce Sprint D

| Brique | Status |
|---|---|
| Tables DB (`trainer_payouts`, `trainer_revenue_events`) | ✅ Posées |
| Colonnes marketplace sur `modules` (`created_by`, `marketplace_status`, `marketplace_price_cents`) | ✅ Posées |
| Vue agrégée `trainer_revenue_summary` | ✅ |
| Page admin `/admin/marketplace` (placeholder + KPIs vides) | ✅ |
| Stripe Connect | ❌ |
| UI création de modules par trainer | ❌ |
| Workflow modération admin | ❌ |
| Marketplace front (vitrine, achat) | ❌ |
| CGU + droits d'auteur | ❌ |

**En l'état, aucune transaction marketplace ne peut s'effectuer.** La page admin sert juste à monitorer si/quand des modules apparaissent (ce qui n'arrivera pas tant que les briques manquantes ne sont pas livrées).

---

## Les 8 chantiers restants

### Chantier 1 — Validation juridique (CLIENT, 1-2 semaines)

**À faire par le client (ou son avocat) :**

- [ ] Rédiger CGU "formateur partenaire" :
  - Cession de droits d'auteur (le formateur cède-t-il les droits à MFT ou conserve-t-il les droits ?)
  - Garanties (le formateur garantit que son contenu est original, non-plagié, à jour réglementairement)
  - Responsabilité (qui est responsable si une info pédagogique est erronée ?)
  - Résiliation (que devient le module si le partenariat s'arrête ?)
- [ ] Statut fiscal du formateur :
  - Auto-entrepreneur : MFT verse en honoraires (facture du formateur)
  - Société : MFT verse via facture commerciale
  - Salarié-formé : interdit par le code du travail (cumul illégal)
- [ ] Conformité Qualiopi : un formateur externe non-certifié peut-il vendre via MFT ? Quelle responsabilité Qualiopi ?

**Pourquoi c'est bloquant** : sans ces réponses, on ne peut pas écrire les contrats partenaires ni configurer les versements.

---

### Chantier 2 — Stripe Connect activation (CLIENT + DEV, 3-5 jours)

**À faire par le client :**

- [ ] Activer Stripe Connect sur le compte Stripe MFT (https://dashboard.stripe.com/settings/connect)
- [ ] Choisir le modèle d'intégration : **Express** (recommandé) ou Standard
  - Express : MFT contrôle l'onboarding, les partenaires sont des Connected Accounts
  - Standard : les partenaires ont leur propre compte Stripe complet (plus complexe)
- [ ] Configurer les Webhooks Connect (events `account.updated`, `payout.created`, etc.)
- [ ] Compléter le profil "Platform" sur Stripe (description du business model, etc.)
- [ ] Activer le KYC obligatoire pour les Connected Accounts

**À faire côté dev :**

- [ ] Wrapper SDK Stripe Connect dans `lib/stripe-connect.ts`
- [ ] Route `POST /api/marketplace/connect/onboard` : crée un Connected Account + onboarding link
- [ ] Webhook handlers pour `account.updated` (mettre à jour `trainer_payouts.stripe_*`)
- [ ] Page `/formateur/payouts/onboarding` qui redirige vers Stripe pour le KYC

**Coût** : 0,25 % de frais Stripe additionnels sur chaque transaction Connect (en plus des frais Stripe classiques).

---

### Chantier 3 — UI création de modules par trainer (DEV, 5-7 jours)

Le formateur doit pouvoir, depuis `/formateur/modules/nouveau` :

- [ ] Créer un module avec titre, description, durée estimée, niveau
- [ ] Ajouter N leçons (markdown + médias)
- [ ] Créer des quizzes attachés (QCM + QR)
- [ ] Définir le prix (`marketplace_price_cents`)
- [ ] Prévisualiser le module comme s'il était un stagiaire
- [ ] Soumettre pour validation MFT (passage de `draft` → `pending_review`)

**Fichiers à créer (estim.)** :
```
app/formateur/modules/page.tsx                  Liste de mes modules
app/formateur/modules/nouveau/page.tsx          Wizard de création
app/formateur/modules/[id]/page.tsx             Édition (draft uniquement)
app/formateur/modules/[id]/lessons/...          CRUD leçons (markdown editor)
app/formateur/modules/[id]/quizzes/...          CRUD quizzes
app/formateur/modules/[id]/preview/page.tsx     Preview stagiaire
app/formateur/modules/[id]/submit/page.tsx      Soumission validation
```

**Difficultés** :
- L'éditeur markdown doit supporter les blocs MFT custom (callouts, examples, etc.)
- L'upload de médias (images, vidéos) doit utiliser Supabase Storage avec quota par trainer
- Le preview doit utiliser exactement le même rendu que la production (pas un mock)

---

### Chantier 4 — Workflow modération admin (DEV, 3-4 jours)

L'admin MFT doit pouvoir, depuis `/admin/marketplace` :

- [ ] Voir la file d'attente des modules `pending_review`
- [ ] Ouvrir un module en preview "comme un stagiaire"
- [ ] Approuver (passe à `approved`, devient visible dans la marketplace)
- [ ] Refuser avec notes (passe à `rejected`, le trainer est notifié)
- [ ] Demander des révisions (passe à `draft` avec commentaires)

**Critères de validation** à définir avec le client :
- Conformité Qualiopi (sources réglementaires citées, version à jour)
- Qualité pédagogique (objectifs clairs, progression cohérente)
- Pas de plagiat (vérification au moins manuelle, peut-être Copyleaks plus tard)
- Pas de contenu hors-domaine (transport routier uniquement)

---

### Chantier 5 — Marketplace front (DEV, 4-5 jours)

Vitrine publique des modules à l'unité :

- [ ] Page `/marketplace` (publique, hors auth) : grille des modules `approved`
- [ ] Page `/marketplace/[slug]` : détail d'un module (description, leçons preview, prix, auteur, avis)
- [ ] Achat à l'unité via Stripe Connect (revenue split appliqué automatiquement)
- [ ] Note : un stagiaire peut acheter un module marketplace SANS être inscrit à une formation complète
- [ ] Notation/avis post-achat (table `module_reviews`)

**Question stratégique** : la marketplace est-elle publique (SEO, acquisition) ou privée (uniquement pour les stagiaires existants) ?

---

### Chantier 6 — Revenue split au checkout (DEV, 2-3 jours)

Au moment du paiement :

- [ ] Détecter si le module acheté est marketplace (`created_by IS NOT NULL`)
- [ ] Récupérer le `stripe_connect_account_id` du trainer
- [ ] Calculer le split : `trainer_share = price × (revenue_share_pct / 100)`
- [ ] Créer la session Stripe avec `application_fee_amount` + `transfer_data.destination`
- [ ] Au webhook `checkout.session.completed` : insérer ligne `trainer_revenue_events`
- [ ] Lancer le transfert automatique au trainer (ou différé selon préférences cashflow)

**Édge cases à gérer** :
- Trainer dont le compte Stripe est désactivé temporairement → bloquer la vente
- Reversement échoué (KYC expiré) → retry logic + alerte admin
- Remboursement (refund) → reverser aussi côté trainer (Stripe le gère natif)
- Modules en panier mixte (1 module MFT + 1 module trainer) → split à la ligne

---

### Chantier 7 — Notifications & dashboard trainer (DEV, 2-3 jours)

Le trainer doit avoir :

- [ ] `/formateur/payouts` : dashboard de ses revenus (gross, net, en attente, transféré)
- [ ] Notifications quand un de ses modules est :
  - Approuvé (passage à `approved`)
  - Refusé (avec raison)
  - Acheté (mail "Bravo, +X € sur ton solde")
- [ ] Téléchargement de l'historique CSV/PDF pour sa comptabilité

---

### Chantier 8 — Audit & conformité (DEV, 2-3 jours)

Pour la sérénité juridique et l'audit Qualiopi :

- [ ] Log immutable de toutes les transactions marketplace (`marketplace_transactions_audit`)
- [ ] Génération automatique des factures Stripe (côté MFT) + des notes d'honoraires (côté trainer)
- [ ] Rapport mensuel : volume marketplace, top trainers, modules les plus vendus
- [ ] Tests Playwright d'isolation : un trainer ne peut JAMAIS voir le contenu/revenu d'un autre trainer

---

## Effort total estimé

| Chantier | Effort | Bloqué par |
|---|---|---|
| 1. Validation juridique | 1-2 semaines | Client + avocat |
| 2. Stripe Connect | 3-5 jours | Client (activation) |
| 3. UI création modules | 5-7 jours | — |
| 4. Modération admin | 3-4 jours | Chantier 3 |
| 5. Marketplace front | 4-5 jours | Chantier 4 |
| 6. Revenue split | 2-3 jours | Chantier 2 |
| 7. Dashboard trainer | 2-3 jours | Chantier 6 |
| 8. Audit & conformité | 2-3 jours | — |
| **Total dev pur** | **~3-4 semaines** | |
| **Total avec juridique** | **~5-6 semaines** | |

---

## Recommandation

**Ne lance pas la marketplace tant que** :

1. ☐ Le client n'a pas validé son modèle juridique (chantier 1)
2. ☐ Le client n'a pas activé Stripe Connect côté son compte Stripe
3. ☐ Au moins **2-3 formateurs partenaires identifiés** prêts à monter sur la plateforme (sinon : feature sans usage, pas de PMF)
4. ☐ Le volume marketplace prévu justifie l'investissement (≥ 5 000 € de GMV annuelle estimée)

**Si ces 4 conditions sont remplies, on peut planifier un Sprint dédié "Marketplace v1" sur 4-5 semaines.**

D'ici là, le scaffolding posé dans Sprint D permet :
- D'avoir les tables DB prêtes (zéro migration douloureuse plus tard)
- De monitorer l'évolution si on commence à enrôler manuellement des trainers
- De montrer au client "la marketplace est en cours, voici à quoi ça ressemblera"

---

## Fichiers du scaffolding livré

```
supabase/2026_05_19_marketplace.sql       Tables + colonnes + vue (déployable maintenant)
app/admin/marketplace/page.tsx            Page admin (placeholder + KPIs vides)
docs/p3-2-marketplace-roadmap.md          Ce document
```

Tout le reste (Stripe Connect, UI trainer, modération, marketplace front) reste à faire selon le planning ci-dessus.
