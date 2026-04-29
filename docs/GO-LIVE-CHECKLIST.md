# GO-LIVE CHECKLIST — MA FORMATION TRANSPORT

Checklist consolidée des **10 points bloquants** avant ouverture client.
À cocher dans l'ordre. Compléments métiers : voir `PRE-LAUNCH-LEGAL.md`,
`PRE-LAUNCH-OPS.md`, `PRE-LAUNCH-CONVERSION.md`.

---

## 1. Migration SQL `messaging_trainer.sql`

- [ ] Ouvrir Supabase Studio → SQL Editor
- [ ] Coller `supabase/messaging_trainer.sql` → Run
- [ ] Vérifier la sortie (aucune erreur)

```sql
-- Smoke test
SELECT proname FROM pg_proc
 WHERE proname IN ('trainer_shares_formation_with', 'list_trainer_conversations');
-- attendu : 2 lignes
```

## 2. Seed E2E `e2e_seed.sql`

- [ ] Avoir créé manuellement les 2 comptes auth (`stagiaire-e2e@test.local`,
      `formateur-e2e@test.local`) dans Supabase Studio → Auth
- [ ] Jouer `supabase/e2e_seed.sql`
- [ ] Récupérer l'`E2E_QUIZ_ID` affiché dans les NOTICES
- [ ] Compléter `.env.test` à la racine

## 3. Tests E2E

- [ ] `npm run test:e2e:install` (une fois)
- [ ] `set -a && source .env.test && set +a && npm run test:e2e`
- [ ] Tous les tests verts (6/6)
- [ ] Si échec : `npx playwright show-trace test-results/<dossier>/trace.zip`

## 4. Warning React `useContext`

- [x] Audit complet : aucun fichier ne consomme de hooks sans `"use client"`
- [x] Le warning observé en mode dev est un artefact Next.js (Link prefetch
      interrompu). Sans impact en production.

## 5. Variables d'environnement Vercel

À renseigner dans **Vercel → Project → Settings → Environment Variables**
pour les 3 environnements (Production / Preview / Development).

| Clé | Obligatoire | Source / Description |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | ✅ | Supabase → Settings → API → Project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | ✅ | Supabase → Settings → API → anon public |
| `SUPABASE_SERVICE_ROLE_KEY` | ✅ | Supabase → Settings → API → service_role (⚠️ secret) |
| `NEXT_PUBLIC_APP_URL` | ✅ | `https://maformationtransport.fr` |
| `RESEND_API_KEY` | ✅ | Resend → API Keys (voir point 6) |
| `EMAIL_FROM_ADDRESS` | ✅ | `noreply@maformationtransport.fr` |
| `EMAIL_REPLY_TO` | ✅ | `support@maformationtransport.fr` |
| `CRON_SECRET` | ✅ | `openssl rand -base64 32` — pour Vercel Cron |
| `STRIPE_SECRET_KEY` | si paiement | Stripe Dashboard |
| `STRIPE_WEBHOOK_SECRET` | si paiement | Stripe Webhook endpoint |
| `UPSTASH_REDIS_REST_URL` | si rate-limit | Upstash console |
| `UPSTASH_REDIS_REST_TOKEN` | si rate-limit | Upstash console |
| `NEXT_PUBLIC_SENTRY_DSN` | recommandé | Sentry → Project Settings |
| `SENTRY_ENVIRONMENT` | recommandé | `production` / `preview` |

**Procédure :**
- [ ] Tous les secrets ajoutés sur les 3 environnements
- [ ] Re-déployer Production (les variables ne sont pas appliquées
      rétroactivement aux builds existants)
- [ ] Smoke-test : `curl https://maformationtransport.fr/api/health`
      (s'il existe — sinon page d'accueil 200)

## 6. SMTP transactionnel (Resend recommandé)

- [ ] Créer un compte sur https://resend.com
- [ ] **Ajouter le domaine** `maformationtransport.fr` (Domains → Add)
- [ ] Configurer les **3 enregistrements DNS** fournis (SPF, DKIM, DMARC)
      chez le registrar
- [ ] Attendre la validation (vert) puis générer une **API Key prod**
- [ ] La copier dans `RESEND_API_KEY` Vercel
- [ ] Test depuis le code : déclencher une notification
      (`/admin/announcements` → publier une annonce de test)
- [ ] Vérifier la réception sur boîte réelle + dossier spam

**Templates utilisés** (à vérifier sur boîte réelle) :
- [ ] Notification copie corrigée (`copyGradedEmail`)
- [ ] Nouvelle copie à corriger (`newCopyToGradeEmail`)
- [ ] Annonce publiée → notif user
- [ ] Reset password Supabase → personnaliser dans Supabase Studio →
      Authentication → Email Templates

## 7. Backup Supabase

- [ ] Supabase → Database → Backups → activer `Daily backups` (plan Pro+)
- [ ] Configurer rétention 7 ou 14 jours selon plan
- [ ] Tester une restauration sur projet de staging
- [ ] **Export manuel de schéma** mensuel à archiver hors-Supabase :
      `pg_dump --schema-only` → S3/Drive de l'organisme

## 8. Domaine + DNS + SSL

- [ ] Domaine `maformationtransport.fr` acheté
- [ ] DNS pointé vers Vercel :
  - `A` apex → `76.76.21.21`
  - `CNAME www` → `cname.vercel-dns.com`
- [ ] Vercel → Domains → Add `maformationtransport.fr` + `www`
- [ ] Certificat SSL auto-généré (Let's Encrypt via Vercel) — vérifier vert
- [ ] Redirection `www` → apex (ou inverse selon préférence)
- [ ] DNS records SMTP (SPF/DKIM/DMARC, voir point 6)
- [ ] Optionnel : enregistrement CAA pour limiter les CA autorisées

## 9. Pages légales — placeholders à compléter

Le fichier `lib/legal-config.ts` contient **17 placeholders** `[À COMPLÉTER]`
qui s'affichent tels quels en prod tant qu'ils ne sont pas renseignés.

Champs à remplir :

- [ ] `legalForm` (SAS / SASU / EURL / SARL / EI)
- [ ] `siret` (SIREN + 5 chiffres NIC)
- [ ] `rcs` (RCS Meaux + numéro)
- [ ] `vatNumber` (FR XX 908851280)
- [ ] `shareCapital` (capital social en €)
- [ ] `director` (nom du représentant légal)
- [ ] `publicationDirector` (directeur de publication, peut = director)
- [ ] `phone` (numéro public)
- [ ] `trainingActivityNumber` (déclaration d'activité OF — 11 chiffres + région)
- [ ] `qualiopiNumber` (numéro de certification Qualiopi)
- [ ] `qualiopiBody` (organisme certificateur, ex. AFNOR Certification)
- [ ] `dpoName` (nom du DPO)
- [ ] `mediator.name` + `mediator.website` (médiateur de la consommation)
- [ ] `qualiopi.averageSatisfaction` (après 1ère cohorte)
- [ ] `qualiopi.successRate` (après 1ère cohorte)

**Action :** ouvrir `lib/legal-config.ts`, remplacer les valeurs, commit.
Mettre à jour aussi `LEGAL_LAST_UPDATE` (date).

**Relecture juridique recommandée** des 5 pages : `/cgu`, `/cgv`,
`/mentions-legales`, `/retractation`, `/confidentialite`, `/reglement-interieur`.

## 10. Qualiopi — traçabilité

Indicateurs critiques à valider dans la plateforme :

| Indicateur | Preuve dans la plateforme | OK ? |
|---|---|---|
| **1** Information préalable | Pages `/formations/[slug]` (programme, durée, prix, prérequis) | ☐ |
| **2** Objectifs adaptés | `objectives[]` dans `lib/formations-config.ts` | ☐ |
| **3** Adaptation au public | Test de positionnement `/positionnement` | ☐ |
| **4** Adaptation pédagogique | Modules + quiz multi-niveau | ☐ |
| **5** Accueil et accompagnement | Onboarding + `/messages` (formateur ↔ stagiaire) | ☐ |
| **6** Engagement bénéficiaires | Convention + règlement intérieur signés (`document_acceptances`) | ☐ |
| **7** Compétences formateurs | CV/diplômes dans `/admin/users/[id]` (à uploader) | ☐ |
| **8** Moyens techniques | Documenté dans CGV + livret d'accueil | ☐ |
| **9** Sous-traitance | Contrats à archiver hors-plateforme | ☐ |
| **10** Inscription des bénéficiaires | `enrollments` + email de confirmation | ☐ |
| **11** Évaluation des résultats | `quiz_attempts` + scores + attestations | ☐ |
| **12** Investissement formateurs | Logs de connexion `/admin/users` | ☐ |
| **13** Veille légale/sectorielle | Annonces `/admin/announcements` (canal documenté) | ☐ |
| **14** Veille pédagogique | Idem | ☐ |
| **15** Veille innovation | Idem | ☐ |
| **16** Handicap | Référent + page accessibilité | ☐ |
| **17** Recueil appréciations | Enquête satisfaction (`/satisfaction`) | ☐ |
| **18** Réclamations | Formulaire `/contact` + délai de réponse documenté | ☐ |
| **19** Amélioration continue | KPI `/admin/stats` + comptes-rendus de revue | ☐ |
| **20** Indicateurs publics | À publier sur `/formations/[slug]` (taux satisfaction, réussite) | ☐ |
| **21** Accessibilité PSH | `accessibilityContact` dans legal-config + procédure | ☐ |
| **22** Dispositifs handicap | Document interne référencé | ☐ |
| **23** Mobilisation moyens | Idem | ☐ |
| **24-32** Critères 7 (administratif) | Convention, attestations, archivage 3 ans | ☐ |

**Action minimale avant audit :**
- [ ] Imprimer/archiver les preuves issues de la plateforme (export PDF)
- [ ] Documenter les processus hors-plateforme (sous-traitance, veille,
      revue annuelle) dans un classeur Qualiopi dédié

---

## ✅ Ordre conseillé

1. **Aujourd'hui** : 1, 2, 3, 4, 5 (tech)
2. **Cette semaine** : 6, 7, 8 (infra)
3. **Avant ouverture** : 9 (juridique)
4. **Pendant l'audit Qualiopi** : 10

Une fois 1→9 cochés, la plateforme est **prête pour la mise en ligne
publique**. Le 10 est un travail continu.
