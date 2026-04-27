# Checklist conversion (avant ouverture des inscriptions)

À jouer **après** les checklists `PRE-LAUNCH-LEGAL.md` et `PRE-LAUNCH-OPS.md`.

---

## 1. Tarifs

### 1.1 Configuration

- [ ] Adapter les **prix** dans `lib/pricing-config.ts` (`PLANS[]`).
- [ ] Vérifier les **modes de financement** par plan (`funding[]`) — un plan auto-financement doit toujours inclure `"auto"` pour autoriser le checkout Stripe.
- [ ] Mettre à jour les **features** affichées sur la page `/tarifs`.

### 1.2 Affichage public

- [ ] Page `/tarifs` accessible sans authentification (vérifier middleware).
- [ ] Lien depuis la home `/` (Hero + section "Tarifs transparents").
- [ ] Footer légal (composant `<LegalFooter />`) bien présent.

---

## 2. Stripe (paiement direct auto-financement)

### 2.1 Compte Stripe

- [ ] Créer un compte sur https://stripe.com et activer le compte (KYC + RIB).
- [ ] Renseigner l'identité de l'organisme (raison sociale, SIRET, IBAN pour les virements).
- [ ] Récupérer les clés (Dashboard → Developers → API keys) :
  - `STRIPE_SECRET_KEY` (sk_live_… ou sk_test_…)
  - `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` (pk_live_… ou pk_test_…)

### 2.2 Webhook

Indispensable : sans webhook, le serveur ne sait pas quand un paiement est validé.

1. Dashboard Stripe → Developers → **Webhooks** → "Add endpoint".
2. URL : `https://gotrm-academy.fr/api/stripe/webhook`
3. Évènements à écouter :
   - `checkout.session.completed`
   - `checkout.session.async_payment_succeeded`
   - `checkout.session.async_payment_failed`
4. Récupérer le **Signing secret** → `STRIPE_WEBHOOK_SECRET`.
5. Tester avec la CLI Stripe :
   ```bash
   stripe listen --forward-to https://gotrm-academy.fr/api/stripe/webhook
   stripe trigger checkout.session.completed
   ```

### 2.3 Mode test → mode live

- [ ] Tester un parcours complet en mode **test** avec la carte `4242 4242 4242 4242`.
- [ ] Vérifier la table `payments_log` : 1 ligne par paiement, statut `paid`.
- [ ] Vérifier l'email de confirmation reçu.
- [ ] Basculer les clés en **live**, mettre à jour Vercel env vars.
- [ ] Effectuer un 1er paiement réel de test (1 €) avec sa propre carte → annuler/rembourser ensuite.

### 2.4 SQL à jouer

```bash
# Dans le SQL Editor Supabase :
supabase/payments_log.sql
```

### 2.5 3D-Secure et conformité PSD2

Stripe Checkout gère 3DS automatiquement. Aucune action.

### 2.6 Paiement en 3-4× sans frais

Activé via Klarna (`installments: true` dans le payload checkout). Activer Klarna côté Stripe Dashboard → Payment methods → Klarna. Disponible en France pour montants 35-1 000 €.

---

## 3. Devis & convocation auto

### 3.1 Devis

- [ ] Tester `/api/enrollments/{id}/devis` → PDF généré, lisible, montant correct.
- [ ] Vérifier que le devis est cliquable depuis `/inscription` (bouton "Devis (PDF)").

### 3.2 Convocation

- [ ] Tester `/api/enrollments/{id}/convocation` après avoir renseigné `start_date` sur l'enrollment.
- [ ] Si `start_date` est nulle : 400 `start_date_required` (attendu).
- [ ] Vérifier les sections obligatoires Qualiopi : objectifs, prérequis, modalités d'évaluation, accessibilité, contacts.

### 3.3 Workflow recommandé

```
Demande inscription → Devis PDF auto envoyé en pièce jointe →
  Accord OPCO/CPF/auto → Création enrollment + Convention PDF →
  Confirmation date démarrage → Convocation PDF envoyée (J-7 min)
```

À chaque étape, l'admin peut télécharger le PDF correspondant depuis l'admin enrollment ou lancer un email auto (à intégrer plus tard via un webhook ou cron).

---

## 4. EDOF (Mon Compte Formation / CPF)

### 4.1 Pourquoi c'est long

L'inscription au catalogue EDOF (Espace Des Organismes de Formation) est obligatoire pour proposer des formations finançables CPF. Le délai est de **2 à 4 mois** :

1. Pré-requis : certification Qualiopi valide + RNCP enregistré.
2. Création de compte EDOF par le représentant légal.
3. Saisie de la fiche formation (objectifs, durée, prix, sessions).
4. Validation par la Caisse des Dépôts (sous 30 jours).
5. Mise en ligne sur https://www.moncompteformation.gouv.fr.

### 4.2 Étapes concrètes

- [ ] **Compte EDOF créé** par le représentant légal sur https://of.moncompteformation.gouv.fr (avec attestation Qualiopi).
- [ ] **Code SIRET** déclaré et SIRENE validé.
- [ ] **Fiche formation EDOF** créée avec :
  - Référentiel : RNCP 40990
  - Modalité : à distance / mixte
  - Prix : net, conforme à `lib/pricing-config.ts`
  - Sessions ouvertes (au moins 2 dates pour démarrer)
  - Description ≥ 1 500 caractères
  - Indicateurs Qualiopi 9 (taux satisfaction, réussite, insertion) — affichables après 1ère cohorte
- [ ] **Conditions Générales d'Utilisation EDOF** acceptées.
- [ ] **Convention attendant signature** : la Caisse des Dépôts est partie tierce dans le règlement.
- [ ] **Préinscription stagiaire** : le stagiaire fait sa demande via Mon Compte Formation, l'OF a 48 h pour confirmer côté EDOF.
- [ ] **Bilan stagiaire EDOF** : à transmettre dans les 4 j après fin de session, sinon retenue financière.

### 4.3 Frais

- Aucun frais d'inscription au catalogue.
- Caisse des Dépôts retient un pourcentage (2,5–3,5 %) sur chaque encaissement CPF.

### 4.4 Pour aller plus loin

API EDOF (B2B, optionnelle) pour automatiser inscription/préinscription/bilan. Documentation : https://api.gouv.fr/les-api/api-edof.

---

## 5. Tracking conversion (recommandé)

Sans tracking, impossible de savoir d'où viennent les inscriptions.

### 5.1 Plausible / Umami (RGPD friendly)

Pas de cookies → pas de bandeau supplémentaire à afficher pour ces outils.

```bash
# Plausible auto-hébergé : https://plausible.io/docs/self-hosting
# Umami auto-hébergé : https://umami.is/
```

Ajouter le script dans `app/layout.tsx` (côté `<head>`) avec une CSP étendue.

### 5.2 Évènements à tracker

| Évènement                | Où                                 |
| ------------------------ | ---------------------------------- |
| `view_pricing`           | Page `/tarifs`                     |
| `click_plan`             | Bouton "Démarrer mon dossier"      |
| `start_checkout`         | Avant redirect Stripe              |
| `complete_checkout`      | Page `/inscription/success`        |
| `submit_request`         | Formulaire `/inscription`          |

### 5.3 Conversion globale visée

Pour une formation pro de ce type :
- Visiteur → Inscription tarifs : 5-10 %
- Inscription → Devis : 30-50 %
- Devis → Paiement : 15-25 %
- **Conversion globale visiteur → client payant : 0,2 % à 1 %**

À tracker semaine après semaine.

---

## 6. Tests d'acceptation

- [ ] `/tarifs` accessible déconnecté.
- [ ] Cliquer sur "Démarrer mon dossier" plan Essentiel → arriver sur `/inscription?plan=essentiel`.
- [ ] Lancer un checkout Stripe en test → arriver sur la page hébergée Stripe.
- [ ] Compléter le paiement avec `4242 4242 4242 4242` → redirection vers `/inscription/success`.
- [ ] Vérifier en base : ligne dans `payments_log`, ligne dans `enrollments` (si user connu).
- [ ] Email de confirmation reçu en boîte de réception.
- [ ] Devis PDF téléchargeable sans erreur.
- [ ] Convocation PDF — bloquée si `start_date` manquante.

---

## 7. Communication marketing

- [ ] Page d'accueil mentionne taux satisfaction / réussite (à mettre à jour après cohorte 1).
- [ ] Logos financeurs visibles (Qualiopi, Mon Compte Formation, France Travail).
- [ ] Au moins 3 témoignages (peuvent être anonymisés au début : "Ahmed, 34 ans, conducteur SPL").
- [ ] Numéro de téléphone visible en haut de la home (rassure énormément en B2B).
- [ ] FAQ : couvrir au minimum "Combien ça coûte ?", "Combien de temps ?", "C'est reconnu ?", "Qui peut financer ?", "Je peux essayer gratuitement ?".
