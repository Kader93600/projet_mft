# P3 #3 — Marketing & data — Plan d'implémentation

> Version : 2026-05-19 · Statut : à valider · Auteur : Claude
> Suit le pattern P3 #1 et P3 #2 (cf. docs sœurs)

---

## TL;DR

| Sprint | Feature | Effort | Risque | Impact business |
|---|---|---|---|---|
| **A** | CRM léger (suivi prospects) | **5-6 j** | Faible | ★★★★ Conversion leads |
| **B** | UTM tracking + funnel multi-touch | **3-4 j** | Faible | ★★★ Visibilité ROI marketing |
| **C** | Stats réseaux sociaux (Insta + LinkedIn) | **4-5 j** | Moyen (APIs tierces) | ★★ Dashboard interne |

**Total : 12-15 jours** sur ~3 semaines.

---

## Surprise audit — ce qui est déjà là

- ✅ Table `enrollment_requests` + `/admin/enrollments` (suivi des leads simple)
- ✅ PostHog (client + serveur) en région EU, RGPD-compliant
- ✅ Vue `vw_admin_funnel_conversion` (5 étapes : signup → payer)
- ✅ Vue `vw_admin_activity_heatmap` (7j × 24h)
- ✅ Resend pour les emails transactionnels (templates `newLeadEmail`, `enrollmentReceivedEmail`)
- ✅ Cron Vercel infrastructure (`vercel.json` + `/api/cron/inactivity`)
- ✅ Page `/admin/analytics` riche avec ~10 vues SQL

→ Conclusion : on ÉTEND beaucoup, on ne réinvente presque rien.

---

## Sprint A — CRM léger (5-6 j)

### Objectif business

Convertir plus de prospects en payeurs en outillant les commerciaux MFT
avec un vrai pipeline (et plus juste un tableau "leads à contacter").

### Ce qu'il manque vraiment

1. **Assignation** : qui dans l'équipe MFT gère ce lead ?
2. **Notes privées** : historique des échanges téléphone, email, etc.
3. **Relances** : "rappeler le 28 mai", système de snooze
4. **Pipeline visuel** : vue kanban par statut (nouveau / contacté / devis / inscrit / refusé)
5. **Historique statuts** : audit trail (qui a changé quoi quand)

### Schéma DB

`supabase/2026_05_20_crm.sql` :

```sql
-- Enrichir enrollment_requests
ALTER TABLE enrollment_requests
  ADD COLUMN assigned_to_admin_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
  ADD COLUMN next_followup_at timestamptz,
  ADD COLUMN snoozed_until timestamptz,
  ADD COLUMN source text,                   -- "form_contact" | "form_inscription" | "import" | "manual"
  ADD COLUMN tags text[];                    -- pour catégorisation libre

-- Table notes (1 lead peut avoir N notes)
CREATE TABLE lead_notes (
  id uuid PRIMARY KEY,
  enrollment_request_id uuid REFERENCES enrollment_requests(id) ON DELETE CASCADE,
  author_id uuid REFERENCES profiles(id),
  body text NOT NULL,
  kind text CHECK (kind IN ('call', 'email', 'sms', 'meeting', 'note')),
  occurred_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- Table activités (audit trail automatique)
CREATE TABLE lead_activities (
  id uuid PRIMARY KEY,
  enrollment_request_id uuid REFERENCES enrollment_requests(id) ON DELETE CASCADE,
  author_id uuid REFERENCES profiles(id),
  kind text CHECK (kind IN (
    'status_changed', 'assigned', 'note_added',
    'followup_scheduled', 'snoozed', 'email_sent'
  )),
  details jsonb,                             -- {from, to, ...}
  created_at timestamptz DEFAULT now()
);

-- Vue : ma file (leads assignés à moi, triés par priorité)
CREATE VIEW crm_my_queue WITH (security_invoker = on) AS
  SELECT er.*, ...
  WHERE assigned_to_admin_id = auth.uid()
  ORDER BY
    CASE WHEN next_followup_at <= now() THEN 0 ELSE 1 END,
    next_followup_at NULLS LAST;

-- Trigger : insertion auto dans lead_activities quand status change
CREATE TRIGGER tg_lead_log_status_change ...
```

### UI à créer

```
app/admin/crm/page.tsx                       # Vue kanban + ma file
app/admin/crm/[id]/page.tsx                  # Drill-down 1 lead
app/admin/crm/[id]/note-form.tsx             # Ajouter une note (client)
app/admin/crm/[id]/timeline.tsx              # Timeline des activités
app/admin/crm/[id]/actions.ts                # Server actions : assign, snooze, etc.
components/crm/lead-card.tsx                 # Card pour la vue kanban
components/crm/lead-pipeline.tsx             # Kanban drag-and-drop (ou clic-to-move)
```

### Endpoint email automatique

- Cron `/api/cron/crm-followup` quotidien à 08:00 :
  - Liste les leads `next_followup_at <= now()` ET `snoozed_until IS NULL`
  - Notifie l'admin assigné (table `notifications` + email)

### Fichiers à créer / modifier

```
supabase/2026_05_20_crm.sql                       NEW
app/admin/crm/*                                   NEW (~6 fichiers)
components/crm/*                                  NEW (~3 composants)
app/api/cron/crm-followup/route.ts                NEW
lib/email.ts                                      EDIT (template followupReminder)
components/nav-groups.ts                          EDIT (entrée admin "CRM")
app/admin/enrollments/page.tsx                    EDIT (lien vers le drill-down CRM)
```

### Décisions à trancher

1. **Auto-assignation** : round-robin entre admins, ou tout est `null` au début et l'admin self-assigne ? (recommandation : self-assign en v1, round-robin en v2)
2. **Notes visibles aux autres admins** : oui (transparence interne) ou privées par auteur ? (recommandation : visibles)
3. **Format des relances** : email seul, ou email + SMS via Twilio ? (recommandation : email seul en v1)
4. **Délai par défaut de relance** : 3 jours après le 1er contact ? Configurable ?

---

## Sprint B — UTM tracking + funnel multi-touch (3-4 j)

### Objectif business

Savoir **d'où viennent les paying customers** : Instagram ? LinkedIn ?
SEO ? Bouche-à-oreille parrainage ? Permet d'arbitrer le budget marketing.

### Schéma DB

`supabase/2026_05_20_acquisition.sql` :

```sql
CREATE TABLE acquisition_events (
  id uuid PRIMARY KEY,
  -- Identité (anonyme tant que pas d'inscription, puis lié)
  visitor_id text NOT NULL,                  -- cookie côté client
  user_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
  -- UTM
  utm_source text,
  utm_medium text,
  utm_campaign text,
  utm_content text,
  utm_term text,
  -- Contextes additionnels
  referrer text,
  landing_page text,
  user_agent text,
  ip_country text,                            -- via Vercel geo (anonyme RGPD)
  -- Événement
  kind text CHECK (kind IN ('landing', 'signup', 'contact_form', 'enrollment')),
  occurred_at timestamptz DEFAULT now()
);

CREATE INDEX acquisition_events_visitor_idx ON acquisition_events(visitor_id);
CREATE INDEX acquisition_events_user_idx ON acquisition_events(user_id);
CREATE INDEX acquisition_events_campaign_idx ON acquisition_events(utm_source, utm_campaign);

-- Vue : attribution first-touch (le canal qui a amené le visiteur)
CREATE VIEW acquisition_attribution AS
  SELECT DISTINCT ON (visitor_id)
    visitor_id, user_id, utm_source, utm_medium, utm_campaign,
    referrer, landing_page, occurred_at AS first_touch_at
  FROM acquisition_events
  WHERE kind = 'landing'
  ORDER BY visitor_id, occurred_at ASC;

-- Vue : funnel par utm_source pour le dashboard
CREATE VIEW vw_admin_funnel_by_utm AS
  WITH attrib AS (SELECT * FROM acquisition_attribution),
       enrolled AS (SELECT user_id FROM enrollments WHERE status NOT IN ('refuse', 'abandon'))
  SELECT
    COALESCE(a.utm_source, 'direct') AS source,
    COALESCE(a.utm_medium, '—') AS medium,
    count(DISTINCT a.visitor_id) AS visitors,
    count(DISTINCT a.user_id) AS signups,
    count(DISTINCT e.user_id) AS conversions,
    round(100.0 * count(DISTINCT e.user_id) / NULLIF(count(DISTINCT a.user_id), 0), 1) AS conversion_pct
  FROM attrib a
  LEFT JOIN enrolled e ON e.user_id = a.user_id
  GROUP BY 1, 2
  ORDER BY conversions DESC NULLS LAST;
```

### Code à ajouter

1. **Helper client** `lib/acquisition.ts` :
   - Au mount d'une page publique, lit les UTM depuis `window.location`
   - Génère/lit un `visitor_id` (cookie 90 jours)
   - POST `/api/acquisition/track` avec les params

2. **Endpoint** `app/api/acquisition/track/route.ts` :
   - Parse les UTM
   - Insère dans `acquisition_events` avec `kind = 'landing'`

3. **Hook signup** : quand un user crée son compte, on lit le `visitor_id` du cookie et on update les `acquisition_events` correspondants avec `user_id`. Ainsi l'attribution remonte du visiteur anonyme jusqu'au payant.

4. **UI dashboard** `app/admin/analytics/acquisition/page.tsx` :
   - Tableau des sources (visitors → signups → conversions → CA)
   - Graphique évolution sur 30j par source
   - Drill-down par campagne

### Fichiers à créer / modifier

```
supabase/2026_05_20_acquisition.sql              NEW
lib/acquisition.ts                                NEW (helper client cookie + tracking)
app/api/acquisition/track/route.ts                NEW
app/admin/analytics/acquisition/page.tsx          NEW (sous-page existing analytics)
components/acquisition-tracker.tsx                NEW (Client Component monté sur layout public)
app/(public-or-site-routes)/layout.tsx            EDIT (monte le tracker)
```

### Décisions à trancher

1. **Attribution model** : first-touch (le tout premier canal) ou last-touch (le canal au moment de l'inscription) ? Recommandation : **first-touch en v1**, multi-touch (linéaire ou time-decay) plus tard.
2. **Cookie consent** : on track AVANT le consent cookie ou APRÈS ? Recommandation : on track les UTM côté serveur sans cookie (juste session) tant que pas de consent → respect RGPD strict.
3. **Périmètre** : on track aussi sur les routes authentifiées (dashboard, etc.) ou uniquement landing publique ? Recommandation : landing uniquement, sinon trop de bruit.

---

## Sprint C — Stats réseaux sociaux Instagram + LinkedIn (4-5 j)

### Objectif business

Voir dans un tableau de bord interne l'évolution :
- Nombre de followers Instagram + LinkedIn
- Engagement (likes, comments, partages)
- Reach des posts (Instagram)
- Impressions LinkedIn

→ Permet à l'équipe marketing de mesurer son ROI sans aller sur 2 outils
externes en permanence.

### Stack proposée

| Provider | API | Coût |
|---|---|---|
| Instagram | **Meta Graph API** — Instagram Business Account | Gratuit (avec token long-lived) |
| LinkedIn | **LinkedIn Marketing Developer Platform** | Gratuit (mais OAuth complexe) |

**Difficulté principale** : LinkedIn impose une review d'application pour
accéder à l'API. Compter ~1-2 semaines de validation Meta + LinkedIn.

### Schéma DB

`supabase/2026_05_20_social_stats.sql` :

```sql
-- Stockage des tokens OAuth (sécurité critique)
CREATE TABLE social_auth (
  id uuid PRIMARY KEY,
  platform text CHECK (platform IN ('instagram', 'linkedin')),
  account_name text,                          -- @maformationtransport
  access_token text,                          -- chiffré côté app
  refresh_token text,
  expires_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
-- RLS : admin only

-- Snapshots quotidiens (1 ligne / plateforme / jour)
CREATE TABLE social_snapshots (
  id uuid PRIMARY KEY,
  platform text NOT NULL,
  snapshot_date date NOT NULL,
  followers int,
  posts_count int,
  total_impressions int,
  total_reach int,
  total_engagement int,
  raw_payload jsonb,
  fetched_at timestamptz DEFAULT now(),
  UNIQUE (platform, snapshot_date)
);

-- Posts individuels (Top posts par engagement)
CREATE TABLE social_posts (
  id uuid PRIMARY KEY,
  platform text NOT NULL,
  external_id text NOT NULL,                  -- id Instagram/LinkedIn
  posted_at timestamptz,
  caption text,
  media_url text,
  likes int,
  comments int,
  shares int,
  reach int,
  impressions int,
  last_synced_at timestamptz,
  UNIQUE (platform, external_id)
);
```

### Cron de synchronisation

`app/api/cron/social-sync/route.ts` (1 fois / 6 h) :

```ts
// 1. Pour chaque platform :
//    - Lit le token depuis social_auth
//    - Si expiré : refresh
//    - Fetch /me/insights (followers, reach, etc.)
//    - Upsert dans social_snapshots
//    - Fetch /me/media (10 derniers posts)
//    - Upsert dans social_posts
```

### UI à créer

```
app/admin/analytics/social/page.tsx              # Dashboard temps réel
components/social/social-kpis.tsx                # Cards (followers, reach, engagement)
components/social/social-growth-chart.tsx        # Courbe followers 30j
components/social/social-top-posts.tsx           # Top 10 posts par engagement
app/admin/analytics/social/connect/page.tsx      # Page OAuth (1ère config)
```

### Décisions à trancher (CRITIQUES)

1. **Compte Instagram** : MFT a-t-il un **Instagram Business Account** ou seulement un compte perso ? La Meta Graph API nécessite OBLIGATOIREMENT un compte Business (sinon : impossible).
2. **Page LinkedIn** : MFT a-t-il une **Page LinkedIn entreprise** (vs profil perso) ? Pareil — la Marketing API ne marche que sur des Pages.
3. **Application Meta + LinkedIn** : il faut **créer une App Developer** côté Meta + côté LinkedIn (1-2h chacune) avant de pouvoir générer un token. Le client doit faire ça lui-même (responsable du compte).
4. **Périmètre v1** : tableau de bord en lecture seule (recommandation) ou aussi planification de posts (= produit dans le produit, hors-scope) ?

### Risques

- **Rejet API Review** par Meta ou LinkedIn → bloquant. Mitigation : commencer le process maintenant pour avoir une marge.
- **Rate limits** : Meta = 200 requêtes/heure/utilisateur. OK pour un cron 6h.
- **Tokens qui expirent** : Instagram = 60j (long-lived), LinkedIn = 60j aussi. Cron de refresh automatique nécessaire.

---

## Recommandation d'ordre

**A → B → C** est l'ordre naturel :

1. **CRM (A)** en premier : impact immédiat sur la conversion lead → payant, et tout est sous notre contrôle (pas de dépendance externe).
2. **UTM/Funnel (B)** : aide à orienter les arbitrages marketing dans le CRM.
3. **Social stats (C)** en dernier : c'est le plus complexe (APIs tierces, OAuth, review), peut bloquer plusieurs jours sur la validation côté Meta/LinkedIn.

**Plan B** : si l'équipe MFT veut prioriser le marketing avant la conversion, ordre **B → A → C** (UTM d'abord pour mesurer les canaux, puis CRM pour transformer les leads identifiés).

---

## Décisions à trancher AVANT de coder

### Sprint A — CRM
1. Auto-assignation : self-assign (v1) ou round-robin auto ?
2. Notes : visibles entre admins ou privées par auteur ?
3. Relances : email seul ou email + SMS Twilio ?
4. Délai relance par défaut : 3 jours après 1er contact ?

### Sprint B — UTM
5. Attribution : first-touch (v1) ou last-touch ?
6. Cookie consent : tracker AVANT consent (session-only) ou ATTENDRE consent ?
7. Périmètre : pages publiques uniquement ?

### Sprint C — Social
8. Comptes Business Instagram + Page LinkedIn déjà créés ?
9. Application Developer Meta + LinkedIn : qui les crée (client ou nous) ?
10. v1 = lecture seule ?

---

## Pré-requis avant Sprint C (Social)

1. ☐ Compte Instagram Business activé sur le profil MFT
2. ☐ Page LinkedIn entreprise activée
3. ☐ Application Developer Meta créée + App ID disponible
4. ☐ Application LinkedIn créée + App ID disponible
5. ☐ Décision sur le périmètre (lecture seule vs publication aussi)

Si ces 5 conditions ne sont pas remplies, le Sprint C peut être différé sans bloquer les Sprints A et B.

---

## Total estimé pour P3 #3 complet

- Sprint A (CRM) : 5-6 j
- Sprint B (UTM) : 3-4 j
- Sprint C (Social) : 4-5 j
- **TOTAL : ~12-15 j** sur ~3 semaines

Hors-scope (à différer en v2) :
- Multi-touch attribution (linear, time-decay)
- Publication de posts depuis MFT (cross-posting)
- A/B testing landing pages
- Email marketing campagnes (Mailchimp / Sendgrid)
- Webhook tracking Stripe → CRM (lead converti)
