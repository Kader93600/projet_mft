# P3 #1 — Pédagogie augmentée — Plan d'implémentation

> Version : 2026-05-18 · Statut : à valider · Auteur : Claude
> Roadmap : `scripts/generate-roadmap-pdf.ts` → priorité P3 (post go-live)

---

## TL;DR

Trois features distinctes regroupées sous "Pédagogie augmentée" :

| Feature | Effort | État DB | État UI | Risque | Coût |
|---|---|---|---|---|---|
| **A. Gamification** (badges/streaks/leaderboard) | **2 j** | ✅ déjà fait à 90 % | ⚠️ partiel | faible | nul |
| **B. PWA offline renforcée** | **2-3 j** | N/A | ✅ base SW + manifest | faible | nul |
| **C. IA tuteur RAG** (chat + correction QR) | **5-7 j** | ❌ à créer | ❌ à créer | élevé | 50-200 €/mois |

**Ordre recommandé** : A → B → C. La gamification est essentiellement
de la finition UI sur une infra déjà en place ; la PWA enrichit l'existant ;
l'IA est le gros morceau et mérite d'être bien isolé.

---

## Feature A — Gamification

### Objectif

Augmenter la rétention et la régularité des stagiaires en visibilisant
leur progression et en récompensant les comportements vertueux
(jours consécutifs, modules terminés, examens blancs réussis).

### État actuel — l'essentiel est déjà fait

La couche DB est très avancée :

- `xp_events` (table) — historique points XP par événement
- `badges` (catalogue) + `user_badges` (déblocages) — UNIQUE par (user, badge)
- `user_gamification` (vue) — total XP, niveau, jours actifs
- `leaderboard_public` (vue) — top 50 anonymisé
- `user_daily_activity` (vue) — agrégation activité quotidienne
- `user_streak(user_id)` (RPC) — calcule streak courant + record
- `recompute_user_achievements(user_id)` (RPC) — réévalue badges + certificats
- Triggers `tg_xp_lesson`, `tg_xp_quiz` — insertion auto sur événements
- Fonctions `xp_level(xp)` + `xp_for_next_level(lvl)` — barème quadratique

**Pages déjà câblées** :
- `/reussites` (badges)
- `/classement` (leaderboard)

### Ce qui reste à faire

#### A.1 Streak persistant + bonus XP

Aujourd'hui `user_streak()` se calcule à la volée. Ça suffit pour
l'affichage mais pas pour le **bonus XP automatique** au jour J+1.

- **Migration SQL** `supabase/2026_05_18_streak_bonus.sql` :
  - Table `user_streaks (user_id PK, current_streak int, longest_streak int, last_active_date date, last_bonus_at date)`
  - RPC `award_daily_login_bonus(user_id)` : vérifie si l'utilisateur s'est connecté hier, incrémente streak, insère `xp_events(kind='streak_bonus', points = min(streak * 5, 50))`
  - Trigger sur `user_sessions` ou appel explicite depuis `app/(auth)/callback/route.ts`

- **UI** : bandeau streak dans le dashboard
  - Composant `components/gamification/streak-banner.tsx`
  - Server Component, lit `user_streaks` + dernière date
  - "🔥 7 jours d'affilée — encore 3 jours pour le badge Régulier !"

#### A.2 Finition `/reussites`

- Audit visuel de la page existante (`app/reussites/page.tsx`, 106 lignes)
- Mettre en avant :
  - Total XP + niveau + barre vers le prochain niveau
  - Streak courant + record
  - Badges débloqués (déjà fait) **+ badges à débloquer** avec progression
    (ex : "Modules terminés 4/5" pour le badge "Bachelier CCP1")
  - Historique XP (timeline ou par mois)

#### A.3 Finition `/classement`

- Audit `/classement/page.tsx` (180 lignes — probablement déjà bien)
- Vérifier :
  - Anonymisation respectée (pas de full_name si opt-out)
  - Période (semaine / mois / all-time) — toggle
  - Mise en avant de la position du stagiaire actuel
  - Privacy : un toggle "apparaître dans le classement" dans `/parametres`

#### A.4 Notifications de badge

Les triggers DB insèrent déjà dans `notifications`. Vérifier :
- Le toast côté client s'affiche bien à l'obtention d'un badge
- Le service worker envoie le push si l'utilisateur l'a autorisé
- Une animation de déblocage (confetti léger) sur l'écran si l'utilisateur est sur le site

### Fichiers à créer / modifier

```
supabase/2026_05_18_streak_bonus.sql        # NEW
components/gamification/streak-banner.tsx   # NEW
components/gamification/xp-timeline.tsx     # NEW
components/gamification/badge-progress.tsx  # NEW
app/dashboard/page.tsx                      # EDIT — ajouter <StreakBanner />
app/reussites/page.tsx                      # EDIT — ajouter sections
app/(auth)/callback/route.ts                # EDIT — appeler award_daily_login_bonus()
app/parametres/page.tsx                     # EDIT — toggle "apparaître au classement"
```

### Effort : **2 jours**

---

## Feature B — PWA offline renforcée

### Objectif

Permettre à un stagiaire en zone blanche (route, 4G faible) de
**continuer une leçon déjà consultée** et de **passer un quiz** sans
connexion, avec sync au retour réseau.

### État actuel

Le service worker `/public/sw.js` (164 lignes) gère déjà :
- Précache page `/offline` + icônes + manifest
- Stratégie network-first sur les navigations, fallback cache, puis `/offline`
- Web Push complet (push + notificationclick)
- Skip-waiting + clients.claim()

Le manifest `app/manifest.ts` (64 lignes) est OK.

### Ce qui reste à faire

#### B.1 Cache contenu pédagogique consulté

Étendre le SW pour :
- Stratégie **stale-while-revalidate** sur les routes `/modules/*` et `/leçon/*`
- Précacher en arrière-plan les leçons du module en cours (depuis le client : envoyer un message au SW avec la liste des URLs)
- Cache séparé `mft-content-v1` (limite : ~50 leçons, LRU)

#### B.2 Quiz offline avec sync différée

Le risque pédagogique d'un quiz offline = un attempt envoyé 6h plus tard
qui pollue les stats. Limiter à :
- **Quiz d'entraînement uniquement** (pas examens blancs ni QR)
- IndexedDB pour stocker les attempts en attente
- Background Sync API au retour réseau
- Indicateur UI clair "Tentative en attente de synchronisation"

#### B.3 Indicateur réseau

- Composant `components/offline-indicator.tsx` qui écoute `online` / `offline`
- Bandeau rouge sticky en haut quand offline
- Badge sur les leçons disponibles offline (icône cloud-down)

#### B.4 Install prompt natif

- Composant `components/pwa/install-prompt.tsx`
- Écoute l'event `beforeinstallprompt`
- Affiche un bouton "Installer l'app" sur le dashboard après 3 visites
- Stocké en `localStorage` (un seul refus = pas de relance avant 30 j)

#### B.5 Push notifications brancher la pipeline manquante

Le SW reçoit déjà les push events. Il manque :
- Endpoint d'inscription `POST /api/push/subscribe`
- Table `push_subscriptions (user_id, endpoint, p256dh, auth, user_agent, created_at)`
- Cron / RPC qui envoie les push pour les badges, coaching, examens
- Toggle dans `/parametres/notifications` pour activer/désactiver

### Fichiers à créer / modifier

```
public/sw.js                                # EDIT — cache leçons + bg sync
public/sw-content.js                        # NEW (optionnel — séparer)
components/offline-indicator.tsx            # NEW
components/pwa/install-prompt.tsx           # NEW
components/pwa/offline-lessons-list.tsx     # NEW
lib/pwa/indexed-db.ts                       # NEW — wrapper IndexedDB
lib/pwa/sync-queue.ts                       # NEW — file d'attentes quiz
app/api/push/subscribe/route.ts             # NEW
app/api/push/unsubscribe/route.ts           # NEW
supabase/2026_05_18_push_subscriptions.sql  # NEW
app/parametres/notifications/page.tsx       # EDIT — toggle push
```

### Effort : **2-3 jours**

### Risques

- **iOS Safari** : pas de Background Sync, pas d'install prompt → fallback gracieux
- **Sync ratée** : un quiz envoyé en double si l'utilisateur tape "envoyer" puis perd la connexion → dédupe sur `client_attempt_id` côté serveur

---

## Feature C — IA tuteur RAG

### Objectif

Un chatbot stagiaire qui :
1. Répond aux questions sur le cours en citant les sources (RAG sur les modules)
2. Corrige les questions rédigées (QR) avec un barème
3. Suggère des modules / leçons à revoir selon les erreurs

### Stack proposée

| Choix | Recommandation | Alternative |
|---|---|---|
| LLM | **Anthropic Claude Sonnet 4** ✅ retenu | — |
| Embeddings | OpenAI `text-embedding-3-small` (1536 dim, 0.02 $/1M tokens) | Mistral embed, Voyage AI |
| Vector store | **pgvector sur Supabase** (extension officielle, RLS-compatible) | Pinecone, Qdrant |
| SDK | `@anthropic-ai/sdk` + `openai` (pour embeddings) | LangChain (overkill) |
| Streaming | Server-Sent Events via Next.js Route Handler | WebSockets (overkill) |

**Pourquoi Claude pour le tuteur :** qualité FR supérieure pour la pédagogie,
gestion stricte des refus quand la question est hors corpus (réduit les hallucinations).

### C.1 DB — nouvelles tables

```sql
-- supabase/2026_05_18_tutor.sql

create extension if not exists vector;

-- Conversations
create table tutor_conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  title text,
  context_module_id uuid references modules(id),  -- module en cours si lancé depuis une leçon
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Messages
create table tutor_messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references tutor_conversations(id) on delete cascade,
  role text check (role in ('user', 'assistant', 'system')),
  content text not null,
  citations jsonb,  -- [{lesson_id, chunk_id, text, similarity}]
  tokens_in int,
  tokens_out int,
  cost_cents int,  -- coût en centimes pour quota
  created_at timestamptz default now()
);

-- Chunks de leçons embeddés
create table lesson_chunks (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid references lessons(id) on delete cascade,
  chunk_index int,
  content text not null,
  embedding vector(1536),
  token_count int,
  created_at timestamptz default now()
);

create index on lesson_chunks using ivfflat (embedding vector_cosine_ops) with (lists = 100);

-- Quota par stagiaire (anti-abus)
create table tutor_quotas (
  user_id uuid primary key references profiles(id) on delete cascade,
  month date,           -- premier du mois
  messages_count int default 0,
  cost_cents int default 0,
  reset_at timestamptz
);

-- RPC — recherche sémantique
create or replace function search_lesson_chunks(
  query_embedding vector(1536),
  match_count int default 6,
  formation_filter text default null
) returns table (
  lesson_id uuid,
  chunk_id uuid,
  content text,
  similarity float,
  lesson_title text,
  module_slug text
) language sql stable as $$
  select c.lesson_id, c.id, c.content,
         1 - (c.embedding <=> query_embedding) as similarity,
         l.title, m.slug
  from lesson_chunks c
  join lessons l on l.id = c.lesson_id
  join modules m on m.id = l.module_id
  -- filtre formation si fourni (via formation_modules)
  where formation_filter is null or exists (
    select 1 from formation_modules fm
    join formations f on f.id = fm.formation_id
    where fm.module_id = m.id and f.slug = formation_filter
  )
  order by c.embedding <=> query_embedding
  limit match_count;
$$;
```

**RLS** : `tutor_conversations`, `tutor_messages`, `tutor_quotas` — accès uniquement par le propriétaire. `lesson_chunks` lisible par tout authentifié.

### C.2 Pipeline d'ingestion

Script `scripts/ingest-lessons-embeddings.ts` :
- Charge toutes les `lessons` + `question_bank` (corrections types)
- Découpe en chunks ~500 tokens (recouvrement 50)
- Génère les embeddings batch (100 chunks par appel OpenAI)
- Upsert dans `lesson_chunks` (idempotent sur lesson_id + chunk_index)
- À lancer : initial + à chaque mise à jour de contenu (CI ou manuel)

### C.3 API — Route handler streaming

`app/api/tutor/ask/route.ts` :

```ts
// 1. Auth + quota check (rejet si dépassé)
// 2. Embed la question utilisateur
// 3. search_lesson_chunks() top-6 chunks pertinents
// 4. Construire prompt système avec citations
// 5. Stream Claude → SSE vers le client
// 6. À la fin : enregistrer message user + assistant + citations + coût
//    + incrémenter tutor_quotas
```

**Quota proposé** : 50 messages / stagiaire / mois en gratuit, 200 en premium.
Reset automatique le 1er du mois via cron Supabase ou check à la volée.

### C.4 Correction QR

Endpoint distinct `app/api/tutor/grade-qr/route.ts` :
- Prompt système avec barème de la question (depuis `question_bank.scoring_grid`)
- Réponse JSON structurée : `{ score, max_score, feedback_md, criteria: [{name, weight, awarded}] }`
- Persisté dans `quiz_attempts.answers` + `feedback_md`
- Visible côté stagiaire dans `/quiz/[id]/results`

**Garde-fou** : un admin doit pouvoir **ré-évaluer manuellement** une correction IA (UI dans `/admin/qr-review`).

### C.5 UI — Chat drawer global

```
components/tutor/tutor-drawer.tsx     # Drawer slide-right, ouvert via bouton FAB
components/tutor/tutor-message.tsx    # Bulle avec markdown + citations cliquables
components/tutor/tutor-input.tsx      # Textarea + envoyer, raccourci ⌘+K
components/tutor/tutor-fab.tsx        # Bouton flottant en bas à droite
hooks/use-tutor.tsx                   # SSE consumer + état conversation
app/tuteur/page.tsx                   # Page dédiée plein écran (mobile)
```

Le drawer est monté dans `app/layout.tsx` (au-dessus de l'auth), accessible depuis n'importe quelle page.

### C.6 Sécurité / Privacy

- **Pas de PII dans les prompts** : on n'envoie jamais le nom du stagiaire au LLM
- **Logs** : conversations stockées 90 jours puis purge automatique (RPC)
- **Filtre output** : refuser de répondre si question hors corpus transport
- **Rate limit** : 5 msg/min par utilisateur (Redis ou table SQL)
- **Modération** : OpenAI Moderation API en pré-filtre sur le message utilisateur (insulte/jailbreak → refus)

### C.7 Coût estimé

Sur la base de 50 stagiaires actifs × 30 messages/mois :
- Embeddings (ingestion initiale + maintenance) : ~5 €/mois
- Inférence Claude Sonnet 4 : ~3000 messages × ~1500 tokens × 3 $/M tokens ≈ 14 €/mois
- Total : **~20 €/mois** au démarrage, scale linéaire

Pour 500 stagiaires actifs : ~200 €/mois.

### Fichiers à créer

```
supabase/2026_05_18_tutor.sql            # NEW — tables + RLS + RPC
scripts/ingest-lessons-embeddings.ts     # NEW — pipeline ingestion
app/api/tutor/ask/route.ts               # NEW — endpoint streaming
app/api/tutor/grade-qr/route.ts          # NEW — correction QR
app/api/tutor/quota/route.ts             # NEW — état du quota
app/tuteur/page.tsx                      # NEW — page plein écran
app/admin/qr-review/page.tsx             # NEW — ré-évaluation admin
components/tutor/*.tsx                   # NEW — 4 composants
hooks/use-tutor.tsx                      # NEW
lib/tutor/claude.ts                      # NEW — wrapper SDK
lib/tutor/embeddings.ts                  # NEW — wrapper OpenAI
lib/tutor/prompts.ts                     # NEW — system prompts
lib/tutor/moderation.ts                  # NEW — filtre pré-prompt
app/layout.tsx                           # EDIT — monter <TutorDrawer />
.env.example                             # EDIT — ajouter ANTHROPIC_API_KEY + OPENAI_API_KEY
```

### Effort : **5-7 jours** dont :
- 1 j — DB + ingestion
- 2 j — API + streaming + quota
- 2 j — UI chat + intégration QR
- 1 j — modération + rate limit + tests
- 1 j (buffer) — fine-tuning prompts + qualité

### Risques majeurs

| Risque | Mitigation |
|---|---|
| Hallucinations sur contenu réglementaire | Citations obligatoires, refus si similarité < 0.7 |
| Dérapage coût (quota mal calibré) | Quota strict + alerting Sentry au-delà de X €/jour |
| Latence dégradée (Claude > 3s) | Streaming dès le premier token, skeleton loader |
| Mauvaise qualité de correction QR | A/B sur 50 corrections vs admin réel avant rollout |
| Souveraineté FR / RGPD | Anthropic UK + DPA signé, ou bascule Mistral si exigence stricte |

---

## Roadmap proposée

### Sprint 1 (2 jours) — Gamification finition
- Migration streak_bonus
- StreakBanner sur dashboard
- Audit + finition /reussites + /classement
- Push notification badges

### Sprint 2 (2-3 jours) — PWA renforcée
- Cache leçons consultées
- Quiz offline (entraînement uniquement)
- Install prompt
- Pipeline push (subscribe + envoi)

### Sprint 3 (5-7 jours) — IA tuteur
- Setup DB + ingestion
- API streaming + quota
- UI drawer + page mobile
- Correction QR + UI admin
- Modération + tests

**Total : 9-12 jours** sur ~3 semaines.

### Pré-requis avant Sprint 3

1. Choisir le provider LLM (Anthropic Claude Sonnet 4 recommandé)
2. Obtenir les clés API + valider le budget (~20 €/mois au démarrage)
3. Vérifier le contrat DPA pour la conformité RGPD
4. Décider du quota gratuit vs premium (impact pricing pack Initial/Medium/Premium)

---

## Décisions arrêtées (2026-05-18)

| Sujet | Décision |
|---|---|
| **Provider LLM** | **Claude Sonnet 4** (Anthropic). SDK `@anthropic-ai/sdk` + OpenAI uniquement pour les embeddings. |
| **Accès IA tuteur** | **Pack Premium uniquement**. Les packs Initial et Medium n'ont pas accès au chat ni à la correction QR par IA. Argument commercial fort + cadrage coût. |
| **Correction QR** | **IA + validation formateur/admin systématique**. L'IA propose un score + feedback, l'admin valide ou ajuste avant que le stagiaire voit le résultat. Pipeline : `quiz_attempts.ai_score`, `quiz_attempts.ai_feedback_md`, `quiz_attempts.reviewed_at`, `quiz_attempts.final_score`. |
| **Quiz offline (PWA)** | **QCM d'entraînement uniquement**. Pas d'examens blancs, pas de QR. Risque zéro sur les stats officielles. |
| **Streak bonus** | À trancher en Sprint 1 — proposition : progressif (5 × streak, plafond 50 XP/jour à partir de 10 jours consécutifs). |

### Implications de "Premium uniquement"

- Le code doit lire `pack_tier` depuis l'enrollment actif du stagiaire
- Helper `lib/access/has-ia-access.ts` partagé entre `/api/tutor/*` et l'UI
- UI : si pack ≠ premium, le FAB tuteur affiche un upsell ("Disponible avec le pack Premium")
- Pas de quota côté Premium dans un premier temps — on monitore les coûts réels avant de plafonner
- Possibilité d'override admin (un formateur peut accorder l'IA à un stagiaire non-Premium pour tester)

### Implications de "Validation formateur systématique"

- La vue stagiaire d'une QR corrigée affiche "En cours de correction" jusqu'à validation
- Notification au formateur dès qu'une QR est en attente (`notifications.type = 'qr_pending'`)
- Page admin `/admin/qr-review` avec file d'attente, score IA proposé, edit possible, bouton "Valider"
- Quand validé → notif au stagiaire + score final visible + XP attribué

### Pré-requis avant Sprint 3 (IA tuteur)

1. ~~Choisir le provider LLM~~ ✅ Claude Sonnet 4
2. Obtenir `ANTHROPIC_API_KEY` + `OPENAI_API_KEY` (embeddings)
3. Signer le DPA Anthropic (UK) pour conformité RGPD
4. Vérifier que `pack_tier` est bien stocké et accessible côté server
