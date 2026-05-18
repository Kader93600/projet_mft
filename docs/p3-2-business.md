# P3 #2 — Business & comptes pros — Plan d'implémentation

> Version : 2026-05-19 · Statut : à valider · Auteur : Claude
> Suit le pattern P3 #1 (cf. `docs/p3-1-pedagogie-augmentee.md`)

---

## TL;DR

| Sprint | Feature | Effort | Risque | Impact business |
|---|---|---|---|---|
| **A** | Programme parrainage | **2-3 j** | Faible | ★★ Croissance B2C |
| **B** | Dashboard financeur enrichi | **3-4 j** | Moyen | ★★★★ Contrats OPCO/B2B |
| **C** | Multi-tenant entreprise | **5-7 j** | Élevé | ★★★★★ Ventes pros |
| ~~D~~ | ~~Marketplace formateurs externes~~ | ~~7-10 j~~ | Très élevé | Reporté en P4 |

**Total : 10-14 jours** sur ~3 semaines pour A+B+C.

---

## Surprise audit — l'existant est solide

Le repo a déjà beaucoup de fondations qu'on va étendre plutôt que recréer :

| Brique existante | Implication |
|---|---|
| Table `funders` (6 types) + `funder_id` sur enrollments + RLS portail | B s'appuie dessus, on étend |
| Route `/admin/reports/bpf` + RPC `bpf_summary` + vue `funder_overview` + exports CSV | B = enrichir avec drill-down |
| Rôle `trainer` + permissions fines (`can_grade`, `can_edit_content`) | Préparé pour D mais hors-scope |
| Stripe checkout + webhook + metadata extensible | A et B utilisent `metadata.referrer_id`, `metadata.organization_id` |
| Vue `funder_overview` (enrollments actifs, budget total/payé) | B se branche dessus |
| Table `groups` (classes/promotions) | Réutilisable pour C (groupes intra-orga) |

---

## Sprint A — Programme parrainage (2-3 j)

### Objectif business

Activer la croissance B2C par le bouche-à-oreille incentivé. Chaque stagiaire devient un canal d'acquisition potentiel.

### Modèle économique proposé

> À valider avec le client — voir "Décisions à trancher" en fin de doc.

**Proposition par défaut :**
- Parrain reçoit **50 € de crédit** sur sa prochaine formation (ou cashback si déjà tout payé)
- Filleul reçoit **−10 % sur sa première inscription**
- Déblocage : à la **première inscription payée du filleul** (pas à la simple création de compte)
- Plafond : **10 parrainages/an par parrain** (anti-abus)
- Validation finale par admin avant cashout

### Schéma DB

`supabase/2026_05_19_referrals.sql` :

```sql
-- Table 1 : codes de parrainage (1 par stagiaire, généré à la première visite de /parrainage)
CREATE TABLE referral_codes (
  user_id uuid PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  code text UNIQUE NOT NULL,                  -- ex: "MFT-AYMAN-3X7K"
  created_at timestamptz DEFAULT now(),
  active boolean DEFAULT true
);

-- Table 2 : usages de codes (1 ligne par filleul inscrit)
CREATE TABLE referrals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  referred_user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  code_used text NOT NULL,
  status text CHECK (status IN ('pending', 'qualified', 'rewarded', 'rejected')),
  -- pending = filleul inscrit, pas encore payé
  -- qualified = filleul a payé, parrain peut recevoir
  -- rewarded = cashout effectué
  -- rejected = anti-fraude (admin rejette)
  enrollment_id uuid REFERENCES enrollments(id) ON DELETE SET NULL,
  reward_cents int,                            -- montant cashout en centimes
  rewarded_at timestamptz,
  created_at timestamptz DEFAULT now(),
  UNIQUE (referred_user_id)                    -- 1 filleul ne peut être référé qu'une fois
);

-- Index pour /admin/referrals (file d'attente cashouts)
CREATE INDEX referrals_pending_idx ON referrals(status, created_at) WHERE status = 'qualified';

-- RPC : générer ou récupérer le code du user courant
CREATE FUNCTION get_or_create_referral_code(p_user uuid) RETURNS text ...;

-- RPC : valider un code à l'inscription (renvoie l'éligibilité)
CREATE FUNCTION validate_referral_code(p_code text, p_new_user uuid) RETURNS ...;

-- RPC : passer un referral en 'qualified' (appelé depuis webhook Stripe)
CREATE FUNCTION qualify_referral(p_referred_user uuid, p_enrollment_id uuid) RETURNS void ...;
```

### Intégration Stripe

Le webhook `app/api/stripe/webhook/route.ts` est étendu pour :
1. Lire `metadata.referrer_code` (passé au checkout)
2. Si présent → appel à `qualify_referral(user_id, enrollment_id)`
3. Le parrain est notifié (table `notifications`)

Le checkout `app/api/stripe/checkout/route.ts` accepte un nouveau param `referrer_code` qui est :
1. Validé serveur-side (anti-tampering)
2. Ajouté en `metadata.referrer_code` + appliqué comme `discount` Stripe

### UI à créer

```
app/parrainage/page.tsx              # Page stagiaire : mon code + mes parrainages + statut
app/parrainage/page-client.tsx       # Composants client (copy code, share)
app/admin/referrals/page.tsx         # Admin : file d'attente cashouts + validation
app/admin/referrals/actions.ts       # Server actions : reward / reject
components/referral/share-card.tsx   # Card de partage (WhatsApp, email, lien copié)
```

### Sécurité

- **Anti-self-referral** : trigger SQL qui refuse `referred_user_id = referrer_id` (vérifié aussi par email check)
- **Anti-fraude** : admin doit valider avant cashout (workflow manuel pour la v1)
- **Rate limit** : 1 code par user, 10 parrainages max/an
- **Audit log** : table `referrals_audit` qui log chaque changement de statut

### Fichiers à créer / modifier

```
supabase/2026_05_19_referrals.sql               NEW
app/parrainage/{page,page-client,layout}.tsx    NEW
app/admin/referrals/{page,actions}.tsx          NEW
app/api/referrals/validate/route.ts             NEW — appelé pendant le checkout
components/referral/share-card.tsx              NEW
app/api/stripe/checkout/route.ts                EDIT — accepte referrer_code
app/api/stripe/webhook/route.ts                 EDIT — appelle qualify_referral
components/user-menu.tsx                        EDIT — lien "Parrainer un ami"
components/nav-groups.ts                        EDIT — entrée admin "Parrainages"
```

---

## Sprint B — Dashboard financeur enrichi (3-4 j)

### Objectif business

Permettre aux OPCO, Pôle Emploi, employeurs (via la table `funders`) d'avoir **un vrai portail** au-delà du BPF annuel. Pré-requis pour signer un contrat avec un grand financeur.

### État actuel (rappel)

- Table `funders` avec 6 types + portail user (`portal_user_id`) ✅
- RLS : un financeur voit ses propres enrollments ✅
- Vue `funder_overview` agrégée ✅
- Export CSV annuel (BPF) ✅

### Ce qui manque

- Page dédiée `/financeur` (aujourd'hui, le financeur n'a aucune UI dédiée — la RLS le protège mais il n'a pas de tableau de bord)
- Drill-down stagiaire par stagiaire (progression, présence, score, statut)
- Notifications temps réel sur les jalons (entrée en formation, premier examen blanc, certification)
- Exports PDF structurés (au-delà du CSV) pour Démarches Simplifiées
- Filtres par période, par formation, par statut

### Schéma DB

Pas de migration lourde — uniquement ajouts de vues.

`supabase/2026_05_19_funder_dashboard.sql` :

```sql
-- Vue : détail stagiaire pour un financeur (drill-down)
CREATE VIEW funder_student_details AS
SELECT
  e.id AS enrollment_id,
  e.funder_id,
  p.id AS user_id,
  p.full_name,
  p.email,
  f.title AS formation_title,
  f.slug AS formation_slug,
  e.pack,
  e.status,
  e.funding_kind,
  e.payment_schedule,
  e.paid_amount_cents,
  e.created_at,
  e.completed_at,
  -- Progression
  (SELECT count(*) FROM lesson_progress lp
    JOIN lessons l ON l.id = lp.lesson_id
    JOIN formation_modules fm ON fm.module_id = l.module_id
   WHERE lp.user_id = p.id AND lp.completed
     AND fm.formation_id = f.id) AS lessons_done,
  -- Score moyen sur les attempts de la formation
  (SELECT round(avg(percentage))::int FROM quiz_attempts qa
   WHERE qa.user_id = p.id AND qa.formation_id = f.id
     AND qa.percentage IS NOT NULL) AS avg_score,
  -- Dernière activité
  (SELECT max(last_ping_at) FROM lesson_views WHERE user_id = p.id) AS last_active_at,
  -- Statut Qualiopi
  EXISTS (SELECT 1 FROM certificates c WHERE c.user_id = p.id AND c.type = 'final') AS certified
FROM enrollments e
JOIN profiles p ON p.id = e.user_id
JOIN formations f ON f.id = e.formation_id
WHERE e.status NOT IN ('refuse', 'abandon');

-- RLS : portail financeur uniquement
ALTER VIEW funder_student_details SET (security_invoker = on);

-- Notifications pour financeur (déclencheurs)
-- Trigger : quand un stagiaire passe son examen blanc → notif au funder
CREATE FUNCTION tg_funder_milestone() RETURNS trigger ...;
```

### API à créer

```
GET /api/funder/dashboard           Récap : enrollments actifs, %s en cours, derniers événements
GET /api/funder/students            Liste filtrable + paginée
GET /api/funder/students/[id]       Drill-down complet d'un stagiaire
GET /api/funder/export/pdf?period   PDF structuré pour archivage
GET /api/funder/export/json?period  JSON pour import système financeur (CPF, etc.)
```

### UI à créer

```
app/financeur/layout.tsx                  # Auth-gated : portal_user_id required
app/financeur/page.tsx                    # Dashboard temps réel
app/financeur/stagiaires/page.tsx         # Tableau filtré + tri + recherche
app/financeur/stagiaires/[id]/page.tsx    # Drill-down stagiaire
app/financeur/exports/page.tsx            # Centre d'exports + historique
components/funder/funder-kpis.tsx
components/funder/funder-student-row.tsx
components/funder/funder-export-button.tsx
```

### Notifications

Étendre la table `notifications` avec le nouveau type `funder_milestone`. Trigger SQL qui insère une notif quand :
- Stagiaire commence sa formation (1er ping de session)
- Premier examen blanc passé
- Certification finale obtenue
- Inactivité > 14j (alerte)

Le funder reçoit les notifs dans son portail + par email (s'il est opt-in).

### Sécurité

- RLS stricte : `funders.portal_user_id = auth.uid()` partout
- Pas de PII exposée au-delà du minimum nécessaire (financeur voit nom + score, pas l'historique des messages)
- Audit log de tous les exports (qui, quand, quoi)

### Fichiers à créer / modifier

```
supabase/2026_05_19_funder_dashboard.sql          NEW
app/financeur/**/*.tsx                            NEW (~6 fichiers)
app/api/funder/**/*.ts                            NEW (~5 routes)
components/funder/*.tsx                           NEW (~4 composants)
components/auth-layout.tsx                        EDIT — détecter rôle funder
lib/permissions.ts                                EDIT — helper isFunder
middleware.ts                                     EDIT — route `/financeur` gated
```

---

## Sprint C — Multi-tenant entreprise (5-7 j)

### Objectif business

Permettre à une **entreprise cliente** (transporteur, gestionnaire de flotte) de :
1. Avoir un **espace dédié** avec son logo
2. Inscrire **plusieurs salariés** sur la même formation
3. Recevoir **une seule facture** consolidée
4. Suivre la progression de **tous ses salariés** dans un dashboard

C'est ce qui débloque les ventes à 5+ stagiaires en une vente. Et c'est la fondation pour D si on le fait un jour.

### Décisions structurantes à prendre AVANT de coder

1. **Modèle de facturation** :
   - Option A : 1 facture par stagiaire (juste un dashboard agrégé)
   - Option B : 1 facture consolidée par mois (avec ligne par stagiaire) — plus complexe Stripe
2. **Pré-paiement** :
   - L'entreprise peut-elle "réserver" 10 places sans avoir les emails des stagiaires ? Ou doit-elle avoir la liste avant ?
3. **Identité visuelle** :
   - L'orga peut-elle uploader son logo et personnaliser un peu l'UI ?
4. **Rôles dans l'orga** :
   - Admin orga uniquement, ou Admin + Viewer (RH consultatif) ?

### Schéma DB

`supabase/2026_05_19_organizations.sql` :

```sql
-- Table organizations
CREATE TABLE organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,                  -- "transport-dupont"
  name text NOT NULL,                          -- "Transport Dupont SAS"
  legal_name text,                             -- "TRANSPORT DUPONT SAS"
  siret text,
  vat_number text,
  billing_email text NOT NULL,
  billing_address jsonb,                       -- {line1, line2, postal_code, city, country}
  logo_url text,
  primary_color text,
  -- Stripe (1 customer par org pour factures consolidées)
  stripe_customer_id text UNIQUE,
  -- Statut
  status text CHECK (status IN ('trial', 'active', 'suspended', 'churned')) DEFAULT 'active',
  trial_ends_at timestamptz,
  -- Métadonnées
  contact_full_name text,
  contact_phone text,
  notes text,                                  -- pour l'admin MFT
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Membres d'une orga (1 user peut être dans 0 ou 1 orga)
CREATE TABLE organization_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role text CHECK (role IN ('org_admin', 'org_viewer', 'org_learner')) DEFAULT 'org_learner',
  -- org_admin : peut tout faire dans son orga (inscrire, voir, exporter)
  -- org_viewer : lecture seule (RH consultatif, sponsor)
  -- org_learner : c'est un stagiaire de l'orga (peut juste se former)
  invited_by uuid REFERENCES profiles(id) ON DELETE SET NULL,
  joined_at timestamptz DEFAULT now(),
  UNIQUE (user_id)                            -- 1 user = 1 orga max
);

-- Lien orga ↔ enrollment (un enrollment peut être pour le compte d'une orga)
ALTER TABLE enrollments
  ADD COLUMN organization_id uuid REFERENCES organizations(id) ON DELETE SET NULL,
  ADD COLUMN seats_reserved boolean DEFAULT false;
  -- seats_reserved = enrollment "pré-créé" sans user assigné (l'orga réserve N places)

-- Index
CREATE INDEX organization_members_org_idx ON organization_members(organization_id, role);
CREATE INDEX enrollments_org_idx ON enrollments(organization_id) WHERE organization_id IS NOT NULL;

-- RLS critique : org_admin voit les members + enrollments de SON orga
CREATE POLICY orgs_self_admin ON organization_members
  FOR ALL USING (
    EXISTS (SELECT 1 FROM organization_members m
            WHERE m.organization_id = organization_members.organization_id
              AND m.user_id = auth.uid()
              AND m.role = 'org_admin')
  );

-- Vue agrégée pour le dashboard orga
CREATE VIEW organization_dashboard AS ...;

-- RPC pour stats orga (progression moyenne, taux completion, etc.)
CREATE FUNCTION organization_stats(p_org_id uuid) RETURNS jsonb ...;
```

### Stripe Customer per org

Quand une orga est créée :
1. Créer `Customer` Stripe avec billing_email + tax_id
2. Stocker `stripe_customer_id`
3. Toutes les factures passent par ce Customer (peu importe le payeur réel)

### Workflow d'inscription

**Flow A — Orga inscrit directement** :
1. Org_admin va sur `/organisation/inscriptions/nouveau`
2. Sélectionne formation + pack + nombre de places
3. Stripe checkout sur le Customer org (paiement consolidé)
4. Webhook crée N enrollments avec `seats_reserved=true` + `organization_id`
5. Org_admin invite les stagiaires : `POST /api/organization/invite { email, enrollment_id }`
6. Le stagiaire reçoit un email magic-link → crée son compte → son enrollment passe à `seats_reserved=false`

**Flow B — Stagiaire s'inscrit avec code orga** :
1. Stagiaire entre le code "TRANSPORT-DUPONT-2026" au checkout
2. Le code est rattaché à l'orga
3. Paiement zéro (l'orga a pré-payé) ou paiement réduit
4. Enrollment lié à l'orga

### UI à créer

```
app/organisation/layout.tsx                       # Auth-gated : org_admin only
app/organisation/page.tsx                         # Dashboard : KPIs, derniers événements
app/organisation/stagiaires/page.tsx              # Liste + progression
app/organisation/stagiaires/[id]/page.tsx         # Détail
app/organisation/inscriptions/page.tsx            # Historique des inscriptions/places
app/organisation/inscriptions/nouveau/page.tsx    # Wizard achat groupé
app/organisation/factures/page.tsx                # Historique Stripe
app/organisation/parametres/page.tsx              # Branding (logo, couleur), équipe
app/organisation/parametres/equipe/page.tsx       # Gérer org_admin + org_viewer

app/admin/organizations/page.tsx                  # Admin MFT : liste des orgas clients
app/admin/organizations/[id]/page.tsx             # Détail orga (statut, MRR, etc.)
```

### API à créer

```
POST /api/organization/create               Création initiale (avec validation SIRET)
GET  /api/organization/me                   Info de l'orga du user courant
POST /api/organization/invite               Inviter un stagiaire (magic link)
POST /api/organization/seats/reserve        Acheter N places à l'avance
GET  /api/organization/dashboard            KPIs
POST /api/admin/organizations               Admin MFT crée une orga (sans payment upfront)
PATCH /api/admin/organizations/[id]         Modifier statut, notes
```

### Sécurité

- RLS sur **toutes** les tables touchées par `organization_id`
- Tests d'intégration obligatoires (un org_admin de A ne doit JAMAIS voir B)
- Audit log sur les actions destructrices (suppression de stagiaire, annulation d'enrollment)
- Validation SIRET via API Sirene (INSEE) à la création — anti-orga bidon

### Risques

| Risque | Mitigation |
|---|---|
| RLS mal calibrée → fuite cross-orga | Tests Playwright d'isolation + revue manuelle policies |
| Stripe Customer mal lié → factures fausses | Création atomique org + customer dans une transaction |
| Conflit avec `funders` (peut-on être Funder + Org ?) | Décision : oui mais comptes séparés (1 user = 1 rôle principal) |
| Migration des enrollments existants | Backfill : enrollments existants → `organization_id = NULL` (compte stagiaire individuel) |

### Fichiers à créer / modifier

```
supabase/2026_05_19_organizations.sql              NEW — table + RLS + RPC + vue
app/organisation/**/*.tsx                          NEW (~10 fichiers)
app/admin/organizations/**/*.tsx                   NEW (~3 fichiers)
app/api/organization/**/*.ts                       NEW (~6 routes)
components/organization/*.tsx                      NEW (~6 composants)
lib/organization/access.ts                         NEW — helpers org_admin / org_viewer
lib/permissions.ts                                 EDIT — `isOrgAdmin(userId, orgId)`
middleware.ts                                      EDIT — route `/organisation` gated
components/auth-layout.tsx                         EDIT — détecter org_admin → afficher menu orga
components/nav-groups.ts                           EDIT — entrées admin "Entreprises clientes"
app/api/stripe/checkout/route.ts                   EDIT — mode "organization checkout"
app/api/stripe/webhook/route.ts                    EDIT — créer N enrollments seats_reserved
```

---

## Décisions arrêtées (2026-05-19)

| Sujet | Décision |
|---|---|
| **Sprint A — Récompense** | **50 € de crédit pour le parrain** sur sa prochaine formation (cashback si plus rien à acheter) + **−10 % pour le filleul** sur sa 1re inscription |
| **Sprint A — Déclenchement** | À la 1re inscription **payée** du filleul (pas à la création de compte) |
| **Sprint A — Plafond annuel** | 10 parrainages / parrain / an |
| **Sprint A — Validation admin** | Systématique en v1 (workflow manuel pour éviter la fraude) |
| **Sprint A — Périmètre** | Tout stagiaire peut parrainer tout autre stagiaire, peu importe les formations |
| **Sprint C — Facturation** | **1 facture par stagiaire (Option A)** pour la v1. La consolidation mensuelle (Option B) reportée à plus tard si besoin client |
| **Sprint D — Marketplace formateurs** | **Maintenu en planning** mais EN DERNIÈRE POSITION (après A+B+C). Ajoute ~2 semaines au planning |
| **Démarrage** | **Sprint A — Parrainage** en premier (2-3 j, quick win indépendant) |

### Implications du Sprint A "récompense 50 € crédit"

- Le crédit doit être stocké quelque part : nouvelle table `user_credits` ou nouveau champ `enrollments.discount_credit_cents` ?
- **Choix retenu** : nouvelle table `user_credits` (history complet, débit/crédit, traçabilité audit)
- Au checkout : si `user_credits.balance > 0`, on applique le crédit avant le paiement Stripe
- Si le balance dépasse le prix de la formation → cashback à demander explicitement (POST /api/referrals/cashout) qui déclenche un virement (à valider avec admin) — workflow manuel en v1

### Décisions restantes à trancher (Sprint B et C)

### Sprint B — Dashboard financeur (à valider au démarrage du Sprint)

1. **Notification au funder** : email + dashboard ou dashboard seul ?
2. **Granularité accès** : un financeur voit-il les messages stagiaire ↔ formateur ? (par défaut : non, RGPD)
3. **Exports** : PDF + CSV + JSON, ou CSV seul ?
4. **Cofinancement** : un stagiaire peut-il avoir 2 financeurs (50 % CPF + 50 % employeur) ?

### Sprint C — Multi-tenant entreprise (à valider au démarrage du Sprint)

1. ~~Facturation~~ ✅ Locked : 1 facture/stagiaire (Option A)
2. **Pré-paiement de places** : oui (Flow A) ou non (Flow B seul) ?
3. **Branding orga** : logo seul ou logo + couleur primaire + favicon ?
4. **Rôles dans l'orga** : org_admin seul, ou org_admin + org_viewer (RH consultatif) ?
5. **Validation SIRET** : INSEE API (gratuite) ou pas de validation ?

---

## Pré-requis avant Sprint C (Multi-tenant)

1. Décision sur les 5 questions ci-dessus
2. Confirmer qu'il n'y a **pas d'orga client en attente** qui aurait des besoins exotiques (ex: 50 stagiaires d'un coup, formation custom)
3. Tests Playwright d'isolation cross-orga (à écrire pendant le sprint)

---

## Calendrier proposé

```
Semaine 1 :
  J1-J2 : Sprint A (parrainage)
  J3    : Validation client + retouches

Semaine 2 :
  J1-J4 : Sprint B (dashboard financeur)
  J5    : Tests + démo client

Semaine 3-4 :
  J1-J5 : Sprint C (multi-tenant) — la plus lourde
  J6-J7 : Tests cross-orga + déploiement progressif
```

**Total : ~3 semaines** pour un livrable production-grade A+B+C.

---

## Hors-scope de P3 #2 (reporté en P4)

- **Marketplace formateurs externes** : Stripe Connect + KYC + modération de contenu + revenue split + droits d'auteur. Trop de chantiers transverses pour un seul sprint, et le ROI est incertain tant que MFT n'a pas validé son product-market-fit B2B avec A+B+C.
- **API publique partenaire** (OAuth) : utile si un OPCO veut intégrer MFT à son SI, mais demande un effort spec/sécu lourd. À envisager après le 1er gros client OPCO.
- **Webhooks outbound** : utile pour intégration tierce (envoyer une notif à un système RH externe quand un stagiaire est certifié), mais peu de demandes pour l'instant.
