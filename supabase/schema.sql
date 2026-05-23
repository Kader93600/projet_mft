-- =====================================================================
-- supabase/schema.sql — BASELINE CONSOLIDÉ (source de vérité des tables)
-- Généré le 2026-05-23 par scripts/introspect-schema.mjs
-- via introspection du schéma public déployé (PostgREST OpenAPI).
--
-- ⚠️  Régénérer avec :  node scripts/introspect-schema.mjs
--
-- CE FICHIER FAIT FOI pour la structure des TABLES (colonnes, types,
-- NOT NULL, défauts, PK, FK). Il remplace l'ancien schema.sql partiel.
--
-- Limites (non reconstructibles depuis l'introspection REST) :
--   • VUES : 32 vues listées en fin de fichier (corps SQL non exposé).
--   • FONCTIONS / TRIGGERS / RLS / INDEX / CHECK : voir les migrations
--     horodatées dans supabase/*.sql (index : supabase/MIGRATIONS_INDEX.md).
--
-- Tables : 94
-- =====================================================================

create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.accessibility_requests (
  id uuid default extensions.uuid_generate_v4(),
  user_id uuid not null,  -- FK → profiles.id
  category text not null,
  description text not null,
  adaptations_requested text,
  status text default 'nouveau' not null,
  admin_response text,
  referent_id uuid,  -- FK → profiles.id
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  resolved_at timestamp with time zone,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.acquisition_events (
  id uuid default gen_random_uuid(),
  visitor_id text not null,
  user_id uuid,  -- FK → profiles.id
  utm_source text,
  utm_medium text,
  utm_campaign text,
  utm_content text,
  utm_term text,
  referrer text,
  landing_page text not null,
  user_agent text,
  ip_country text,
  kind text not null,
  occurred_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.announcements (
  id uuid default gen_random_uuid(),
  title text not null,
  body_md text default '' not null,
  audience text default 'all' not null,
  group_id uuid,  -- FK → groups.id
  pinned boolean default false not null,
  published_at timestamp with time zone,
  created_by uuid,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.at_risk_students (
  id uuid,
  full_name text,
  email text,
  referent_id uuid,  -- FK → profiles.id
  group_id uuid,  -- FK → groups.id
  last_attempt_at timestamp with time zone,
  last_lesson_at timestamp with time zone,
  avg_score integer,
  risk_flag text,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.attendance_attendees (
  session_id uuid,  -- FK → attendance_sessions.id
  user_id uuid,  -- FK → profiles.id
  primary key (session_id, user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.attendance_sessions (
  id uuid default extensions.uuid_generate_v4(),
  title text not null,
  starts_at timestamp with time zone not null,
  ends_at timestamp with time zone not null,
  half_day text not null,
  modality text default 'distanciel' not null,
  location text,
  trainer_id uuid,  -- FK → profiles.id
  trainer_signed_at timestamp with time zone,
  trainer_signature_name text,
  topic text,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.attendance_signatures (
  id uuid default extensions.uuid_generate_v4(),
  session_id uuid not null,  -- FK → attendance_sessions.id
  user_id uuid not null,  -- FK → profiles.id
  signed_at timestamp with time zone default now() not null,
  signature_name text not null,
  signature_ip inet,
  signature_ua text,
  signature_hash text,
  signature_data text,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.attendance_summary (
  id uuid,
  title text,
  starts_at timestamp with time zone,
  ends_at timestamp with time zone,
  half_day text,
  expected bigint,
  signed bigint,
  trainer_signed boolean,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.audit_log (
  id uuid default extensions.uuid_generate_v4(),
  actor_id uuid,  -- FK → profiles.id
  actor_email text,
  action text not null,
  target_type text,
  target_id text,
  metadata jsonb,
  ip_address text,
  user_agent text,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.audit_logs (
  id uuid default extensions.uuid_generate_v4(),
  actor_id uuid,  -- FK → profiles.id
  action text not null,
  target_type text,
  target_id text,
  payload jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.badges (
  id uuid default gen_random_uuid(),
  code text not null,
  name text not null,
  description text,
  icon text default 'Award' not null,
  category text default 'progression' not null,
  tier text default 'bronze' not null,
  criteria jsonb not null,
  points integer default 10 not null,
  active boolean default true not null,
  "order" integer default 0 not null,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.blocs (
  id integer,
  code text not null,
  title text not null,
  description text,
  "order" integer default 0 not null,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.certificates (
  id uuid default gen_random_uuid(),
  user_id uuid not null,  -- FK → profiles.id
  "type" text not null,
  bloc_id integer,  -- FK → blocs.id
  serial text not null,
  issued_at timestamp with time zone default now() not null,
  revoked_at timestamp with time zone,
  score_snapshot jsonb,
  is_loyalty boolean default false not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.choices (
  id uuid default extensions.uuid_generate_v4(),
  question_id uuid not null,  -- FK → questions.id
  label text not null,
  is_correct boolean default false not null,
  "order" integer default 0 not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.coaching_notes (
  id uuid default gen_random_uuid(),
  user_id uuid not null,  -- FK → profiles.id
  trainer_id uuid not null,  -- FK → profiles.id
  body_md text not null,
  visible_to_student boolean default false not null,
  pinned boolean default false not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.coaching_sessions (
  id uuid default gen_random_uuid(),
  user_id uuid not null,  -- FK → profiles.id
  trainer_id uuid not null,  -- FK → profiles.id
  scheduled_at timestamp with time zone not null,
  duration_min integer default 30 not null,
  mode text default 'visio' not null,
  meeting_url text,
  location text,
  status text default 'prevue' not null,
  agenda text,
  summary text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.conversation_participants (
  conversation_id uuid,  -- FK → conversations.id
  user_id uuid,
  role_in_conv text default 'member' not null,
  joined_at timestamp with time zone default now() not null,
  last_read_at timestamp with time zone,
  pinned_at timestamp with time zone,
  muted boolean default false not null,
  archived_at timestamp with time zone,
  primary key (conversation_id, user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.conversations (
  id uuid default gen_random_uuid(),
  user_id uuid,
  last_message_at timestamp with time zone default now() not null,
  user_unread integer default 0 not null,
  admin_unread integer default 0 not null,
  created_at timestamp with time zone default now() not null,
  kind text default 'dm' not null,
  scope text,
  group_id uuid,  -- FK → groups.id
  title text,
  created_by uuid,
  archived_at timestamp with time zone,
  class_writable boolean default false not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.crm_my_queue (
  id uuid,
  user_id uuid,  -- FK → profiles.id
  full_name text,
  email text,
  phone text,
  funding_kind text,
  message text,
  status text,
  created_at timestamp with time zone,
  formation_slug text,
  pack_slug text,
  assigned_to_admin_id uuid,  -- FK → profiles.id
  next_followup_at timestamp with time zone,
  snoozed_until timestamp with time zone,
  source text,
  tags text[],
  updated_at timestamp with time zone,
  is_snoozed boolean,
  followup_due boolean,
  notes_count integer,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.data_access_log (
  id uuid default gen_random_uuid(),
  user_id uuid not null,  -- FK → profiles.id
  actor_id uuid,  -- FK → profiles.id
  action text not null,
  scope text,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.deletion_requests (
  id uuid default gen_random_uuid(),
  user_id uuid not null,  -- FK → profiles.id
  reason text,
  status text default 'pending' not null,
  requested_at timestamp with time zone default now() not null,
  resolved_at timestamp with time zone,
  admin_note text,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.document_acceptances (
  id uuid default gen_random_uuid(),
  user_id uuid not null,
  document_id uuid not null,  -- FK → onboarding_documents.id
  document_type text not null,
  document_version integer not null,
  accepted_at timestamp with time zone default now() not null,
  ip_address inet,
  user_agent text,
  signature_name text,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.enrollment_requests (
  id uuid default extensions.uuid_generate_v4(),
  user_id uuid,  -- FK → profiles.id
  full_name text not null,
  email text not null,
  phone text,
  funding_kind text not null,
  message text,
  status text default 'nouveau' not null,
  created_at timestamp with time zone default now() not null,
  formation_slug text,
  pack_slug text,
  assigned_to_admin_id uuid,  -- FK → profiles.id
  next_followup_at timestamp with time zone,
  snoozed_until timestamp with time zone,
  source text default 'form_contact',
  tags text[] not null,
  updated_at timestamp with time zone default now() not null,
  adresse text,
  code_postal text,
  ville text,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.enrollments (
  id uuid default extensions.uuid_generate_v4(),
  user_id uuid not null,  -- FK → profiles.id
  funder_id uuid,  -- FK → funders.id
  funding_kind text default 'auto' not null,
  session_label text,
  start_date date,
  end_date date,
  total_amount_cents integer default 0 not null,
  paid_amount_cents integer default 0 not null,
  status text default 'prospect' not null,
  contract_url text,
  convention_url text,
  cpf_dossier_ref text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  funder_signed_at timestamp with time zone,
  funder_signed_by_name text,
  funder_signed_by_email text,
  funder_signature_ip inet,
  funder_signature_hash text,
  hours_total integer,
  modality text default 'distanciel',
  location text,
  objectives text,
  prerequisites text,
  formation_slug text,
  formation_id uuid,  -- FK → formations.id
  pack public.pack_slug default 'initial' not null,
  organization_id uuid,  -- FK → organizations.id
  seats_reserved boolean default false not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.formation_modules (
  formation_id uuid,  -- FK → formations.id
  module_id uuid,  -- FK → modules.id
  display_order integer default 100 not null,
  required boolean default true not null,
  primary key (formation_id, module_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.formation_pack_prices (
  id uuid default extensions.uuid_generate_v4(),
  formation_id uuid not null,  -- FK → formations.id
  pack public.pack_slug not null,
  price_cents integer not null,
  compare_at_cents integer,
  active boolean default true not null,
  notes text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  updated_by uuid,  -- FK → profiles.id
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.formation_quizzes (
  formation_id uuid,  -- FK → formations.id
  quiz_id uuid,  -- FK → quizzes.id
  is_mock_exam boolean default false not null,
  display_order integer default 100 not null,
  primary key (formation_id, quiz_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.formation_settings (
  id boolean default true not null,
  organisme_nom text default 'GOTRM Academy' not null,
  organisme_siret text,
  organisme_num_da text,
  organisme_adresse text,
  organisme_email text,
  organisme_telephone text,
  organisme_responsable text,
  formation_titre text default 'Titre professionnel Gestionnaire des Opérations de Transport Routier de Marchandises' not null,
  formation_rncp text default 'RNCP 40990' not null,
  formation_duree_h integer default 700 not null,
  formation_public text default 'Demandeurs d''''emploi, salariés en reconversion, personnes souhaitant accéder au métier de gestionnaire de transport.',
  formation_prerequis text default 'Niveau baccalauréat ou équivalent. Maîtrise du français écrit et oral.',
  formation_objectifs text default '- Organiser et planifier des opérations de transport routier de marchandises
- Gérer l''''exploitation d''''une unité de transport
- Concevoir et commercialiser des solutions de transport
- Piloter la performance économique et sociale d''''une unité',
  formation_methodes text default - Formation 100% à distance (e-learning asynchrone)
- Leçons interactives, quiz d''entraînement, examens blancs
- Accompagnement pédagogique et suivi personnalisé
- Plateforme accessible 24h/24 et 7j/7,
  formation_evaluation text default - Évaluations formatives tout au long du parcours (quiz par leçon)
- Examens blancs en conditions réelles
- Évaluation à chaud et à froid de la satisfaction
- Épreuves officielles du titre professionnel devant un jury (hors plateforme),
  formation_handicap text default 'Les personnes en situation de handicap sont invitées à contacter notre référent handicap afin d''''étudier les adaptations nécessaires au bon déroulement de la formation.',
  formation_referent_handicap text,
  formation_tarif text,
  formation_delai_acces text default '7 jours ouvrés entre la demande d''''inscription et l''''entrée en formation.',
  indicateur_satisfaction numeric,
  indicateur_reussite numeric,
  updated_at timestamp with time zone default now() not null,
  updated_by uuid,
  formation_id uuid,  -- FK → formations.id
  primary key (formation_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.formations (
  id uuid default extensions.uuid_generate_v4(),
  slug text not null,
  code text not null,
  title text not null,
  tagline text,
  category text not null,
  level integer,
  rncp_code text,
  duration text,
  modality text,
  active boolean default true not null,
  display_order integer default 100 not null,
  accent_color text,
  icon_name text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.funders (
  id uuid default extensions.uuid_generate_v4(),
  name text not null,
  kind text not null,
  contact_email text,
  contact_phone text,
  siret text,
  portal_user_id uuid,  -- FK → profiles.id
  notes text,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.glossary_terms (
  id uuid default gen_random_uuid(),
  term text not null,
  definition_md text not null,
  bloc_id integer,  -- FK → blocs.id
  synonyms text[] not null,
  source text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  formation_id uuid,  -- FK → formations.id
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.groups (
  id uuid default extensions.uuid_generate_v4(),
  name text not null,
  description text,
  academic_year text,
  color text default 'navy',
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.inactivity_alerts (
  user_id uuid,
  full_name text,
  email text,
  last_activity_at timestamp with time zone,
  days_inactive numeric,
  primary key (user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.inactivity_pings (
  user_id uuid,  -- FK → profiles.id
  last_pinged_at timestamp with time zone default now() not null,
  ping_count integer default 1 not null,
  primary key (user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.lead_activities (
  id uuid default gen_random_uuid(),
  enrollment_request_id uuid not null,  -- FK → enrollment_requests.id
  author_id uuid,  -- FK → profiles.id
  kind text not null,
  details jsonb,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.lead_notes (
  id uuid default gen_random_uuid(),
  enrollment_request_id uuid not null,  -- FK → enrollment_requests.id
  author_id uuid,  -- FK → profiles.id
  kind text default 'note' not null,
  body text not null,
  occurred_at timestamp with time zone default now() not null,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.lesson_chunks (
  id uuid default gen_random_uuid(),
  lesson_id uuid not null,  -- FK → lessons.id
  chunk_index integer not null,
  content text not null,
  token_count integer,
  embedding public.vector(1536),
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.lesson_progress (
  id uuid default extensions.uuid_generate_v4(),
  user_id uuid not null,  -- FK → profiles.id
  lesson_id uuid not null,  -- FK → lessons.id
  completed boolean default false not null,
  completed_at timestamp with time zone,
  lesson_version_id uuid,  -- FK → lesson_versions.id
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.lesson_resources (
  id uuid default gen_random_uuid(),
  lesson_id uuid not null,  -- FK → lessons.id
  kind text not null,
  title text not null,
  url text not null,
  description text,
  size_kb integer,
  "order" integer default 0 not null,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.lesson_versions (
  id uuid default extensions.uuid_generate_v4(),
  lesson_id uuid not null,  -- FK → lessons.id
  version integer not null,
  title text,
  content_md text,
  summary_md text,
  video_url text,
  edited_by uuid,  -- FK → profiles.id
  edited_at timestamp with time zone default now() not null,
  change_note text,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.lesson_views (
  id uuid default extensions.uuid_generate_v4(),
  user_id uuid not null,  -- FK → profiles.id
  lesson_id uuid not null,  -- FK → lessons.id
  started_at timestamp with time zone default now() not null,
  last_ping_at timestamp with time zone default now() not null,
  duration_s integer default 0 not null,
  completed boolean default false not null,
  formation_id uuid,  -- FK → formations.id
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.lessons (
  id uuid default extensions.uuid_generate_v4(),
  module_id uuid not null,  -- FK → modules.id
  slug text not null,
  title text not null,
  content_md text not null,
  summary_md text,
  "order" integer default 0 not null,
  created_at timestamp with time zone default now() not null,
  cover_url text,
  video_url text,
  current_version integer default 1 not null,
  duration_min integer default 30 not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.live_sessions (
  id uuid default extensions.uuid_generate_v4(),
  title text not null,
  description text,
  formation_id uuid not null,  -- FK → formations.id
  module_id uuid,  -- FK → modules.id
  kind text default 'distanciel' not null,
  start_at timestamp with time zone not null,
  end_at timestamp with time zone not null,
  location text,
  meeting_provider text,
  meeting_url text,
  meeting_password text,
  max_participants integer,
  trainer_id uuid,  -- FK → profiles.id
  status text default 'scheduled' not null,
  notes_internal text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  created_by uuid,  -- FK → profiles.id
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.loyalty_events (
  id uuid default gen_random_uuid(),
  user_id uuid not null,  -- FK → profiles.id
  kind text not null,
  details jsonb,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.message_attachments (
  id uuid default gen_random_uuid(),
  message_id uuid not null,  -- FK → messages.id
  storage_path text not null,
  mime_type text not null,
  size_bytes bigint not null,
  original_name text not null,
  width integer,
  height integer,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.message_reactions (
  message_id uuid,  -- FK → messages.id
  user_id uuid,
  emoji text,
  created_at timestamp with time zone default now() not null,
  primary key (message_id, user_id, emoji)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.messages (
  id uuid default gen_random_uuid(),
  conversation_id uuid not null,  -- FK → conversations.id
  sender_id uuid not null,
  sender_role text not null,
  body text not null,
  read_at timestamp with time zone,
  created_at timestamp with time zone default now() not null,
  reply_to_id uuid,  -- FK → messages.id
  edited_at timestamp with time zone,
  deleted_at timestamp with time zone,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.modules (
  id uuid default extensions.uuid_generate_v4(),
  bloc_id integer not null,  -- FK → blocs.id
  slug text not null,
  title text not null,
  summary text,
  difficulty public.user_level default 'debutant' not null,
  duration_min integer default 30 not null,
  "order" integer default 0 not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  cover_url text,
  intro_video_path text,
  intro_video_label text,
  intro_video_duration_s integer,
  created_by uuid,  -- FK → profiles.id
  marketplace_status text,
  marketplace_price_cents integer,
  marketplace_published_at timestamp with time zone,
  marketplace_reviewer_id uuid,  -- FK → profiles.id
  marketplace_review_notes text,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.notification_preferences (
  user_id uuid,
  in_app_disabled text[] not null,
  push_disabled text[] not null,
  email_disabled text[] not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  primary key (user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.notifications (
  id uuid default extensions.uuid_generate_v4(),
  user_id uuid not null,  -- FK → profiles.id
  title text not null,
  body text,
  created_at timestamp with time zone default now() not null,
  "type" text default 'system' not null,
  link_url text,
  read_at timestamp with time zone,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.onboarding_documents (
  id uuid default gen_random_uuid(),
  "type" text not null,
  title text not null,
  version integer default 1 not null,
  content_md text default '' not null,
  published boolean default false not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  updated_by uuid,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.organization_dashboard (
  organization_id uuid,
  name text,
  slug text,
  status text,
  members_total integer,
  admins_count integer,
  learners_count integer,
  enrollments_total integer,
  enrollments_active integer,
  seats_pending integer,
  total_budget_cents integer,
  total_paid_cents integer,
  primary key (organization_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.organization_members (
  id uuid default gen_random_uuid(),
  organization_id uuid not null,  -- FK → organizations.id
  user_id uuid not null,  -- FK → profiles.id
  role text default 'org_learner' not null,
  invited_by uuid,  -- FK → profiles.id
  joined_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.organizations (
  id uuid default gen_random_uuid(),
  slug text not null,
  name text not null,
  legal_name text,
  siret text,
  vat_number text,
  billing_email text not null,
  billing_address jsonb,
  logo_url text,
  primary_color text,
  contact_full_name text,
  contact_phone text,
  status text default 'active' not null,
  trial_ends_at timestamp with time zone,
  notes text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.payment_schedule (
  id uuid default extensions.uuid_generate_v4(),
  enrollment_id uuid not null,  -- FK → enrollments.id
  due_date date not null,
  amount_cents integer not null,
  paid_at timestamp with time zone,
  paid_amount_cents integer default 0,
  method text,
  reference text,
  notes text,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.payments_log (
  id uuid default extensions.uuid_generate_v4(),
  stripe_session_id text not null,
  user_id uuid,  -- FK → profiles.id
  email text,
  plan_id text,
  amount_cents integer default 0 not null,
  status text not null,
  payload jsonb,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.pinned_messages (
  conversation_id uuid,  -- FK → conversations.id
  message_id uuid,  -- FK → messages.id
  pinned_by uuid not null,
  pinned_at timestamp with time zone default now() not null,
  primary key (conversation_id, message_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.placement_questions (
  id uuid default gen_random_uuid(),
  bloc_id integer not null,  -- FK → blocs.id
  prompt text not null,
  choices jsonb not null,
  correct_index integer not null,
  difficulty text default 'standard' not null,
  "order" integer default 0 not null,
  active boolean default true not null,
  created_at timestamp with time zone default now() not null,
  qtype text default 'qcm' not null,
  image_url text,
  expected_answer text,
  formation_id uuid,  -- FK → formations.id
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.placement_results (
  user_id uuid,
  scores jsonb not null,
  level_per_bloc jsonb not null,
  recommended_bloc_id integer,  -- FK → blocs.id
  answers jsonb,
  duration_s integer,
  taken_at timestamp with time zone default now() not null,
  primary key (user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.profiles (
  id uuid,
  email text not null,
  full_name text,
  role public.user_role default 'student' not null,
  level public.user_level default 'debutant' not null,
  avatar_url text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  group_id uuid,  -- FK → groups.id
  disabled boolean default false not null,
  phone text,
  notes text,
  last_sign_in_at timestamp with time zone,
  total_session_s integer default 0 not null,
  session_count integer default 0 not null,
  onboarding_completed_at timestamp with time zone,
  placement_completed_at timestamp with time zone,
  referent_id uuid,  -- FK → profiles.id
  a11y_font_scale numeric default 1 not null,
  a11y_dyslexia_font boolean default false not null,
  a11y_high_contrast boolean default false not null,
  a11y_reduced_motion boolean default false not null,
  a11y_underline_links boolean default false not null,
  a11y_notes text,
  a11y_rqth boolean default false not null,
  date_naissance date,
  adresse text,
  code_postal text,
  ville text,
  pays text default 'France',
  trainer_id uuid,  -- FK → profiles.id
  entry_date date,
  dossier_status text,
  current_formation_id uuid,  -- FK → formations.id
  leaderboard_opt_out boolean default false not null,
  mandatory_signature_at timestamp with time zone,
  locale text default 'fr' not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.push_subscriptions (
  id uuid default gen_random_uuid(),
  user_id uuid not null,
  endpoint text not null,
  p256dh text not null,
  auth text not null,
  user_agent text,
  created_at timestamp with time zone default now() not null,
  last_used_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.qr_responses (
  id uuid default extensions.uuid_generate_v4(),
  attempt_id uuid not null,  -- FK → quiz_attempts.id
  question_id uuid not null,  -- FK → question_bank.id
  student_answer text,
  trainer_score numeric,
  max_score numeric default 1 not null,
  trainer_comment text,
  graded_by uuid,  -- FK → profiles.id
  graded_at timestamp with time zone,
  submitted_at timestamp with time zone default now() not null,
  ai_score numeric,
  ai_feedback_md text,
  ai_criteria jsonb,
  ai_confidence text,
  ai_concerns text,
  ai_model text,
  ai_tokens_in integer,
  ai_tokens_out integer,
  ai_cost_cents integer,
  ai_graded_at timestamp with time zone,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.question_attachments (
  id uuid default extensions.uuid_generate_v4(),
  question_id uuid not null,  -- FK → question_bank.id
  storage_path text not null,
  file_name text not null,
  mime_type text not null,
  size_bytes integer,
  kind text default 'other' not null,
  label text,
  display_order integer default 100 not null,
  created_at timestamp with time zone default now() not null,
  created_by uuid,  -- FK → profiles.id
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.question_bank (
  id uuid default extensions.uuid_generate_v4(),
  formation_id uuid,  -- FK → formations.id
  module_id uuid,  -- FK → modules.id
  "type" text not null,
  statement text not null,
  choices jsonb,
  expected_answer text,
  scoring_grid text,
  max_score numeric default 1 not null,
  difficulty text default 'moyen' not null,
  tags text[] not null,
  explanation text,
  source_ref text,
  reformulated_at timestamp with time zone,
  reformulated_by uuid,  -- FK → profiles.id
  active boolean default true not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  created_by uuid,  -- FK → profiles.id
  import_id uuid,  -- FK → question_imports.id
  lesson_id uuid,  -- FK → lessons.id
  annex_pages integer[] not null,
  annex_labels text[] not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.question_imports (
  id uuid default extensions.uuid_generate_v4(),
  file_name text not null,
  file_size_bytes integer,
  file_kind text default 'pdf' not null,
  formation_id uuid,  -- FK → formations.id
  module_id uuid,  -- FK → modules.id
  expected_type text default 'mixed' not null,
  status text default 'extracted' not null,
  questions_count integer default 0 not null,
  errors_count integer default 0 not null,
  raw_text text,
  notes text,
  created_at timestamp with time zone default now() not null,
  completed_at timestamp with time zone,
  created_by uuid,  -- FK → profiles.id
  pdf_storage_path text,
  annex_pages integer[] not null,
  annex_labels text[] not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.questions (
  id uuid default extensions.uuid_generate_v4(),
  quiz_id uuid not null,  -- FK → quizzes.id
  statement text not null,
  explanation text,
  "order" integer default 0 not null,
  image_url text,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.quiz_attempts (
  id uuid default extensions.uuid_generate_v4(),
  user_id uuid not null,  -- FK → profiles.id
  quiz_id uuid not null,  -- FK → quizzes.id
  score integer,
  total integer,
  percentage integer,
  passed boolean default false,
  duration_s integer,
  answers jsonb,
  started_at timestamp with time zone default now() not null,
  finished_at timestamp with time zone,
  focus_loss_count integer default 0 not null,
  mode text default 'entrainement' not null,
  flagged_questions text[] not null,
  status text default 'completed' not null,
  qcm_score numeric,
  qr_score numeric,
  final_percentage numeric,
  final_passed boolean,
  graded_at timestamp with time zone,
  graded_by uuid,  -- FK → profiles.id
  trainer_global_comment text,
  formation_id uuid not null,  -- FK → formations.id
  client_attempt_id text,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.quiz_question_bank (
  quiz_id uuid,  -- FK → quizzes.id
  question_id uuid,  -- FK → question_bank.id
  display_order integer default 100 not null,
  primary key (quiz_id, question_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.quizzes (
  id uuid default extensions.uuid_generate_v4(),
  module_id uuid,  -- FK → modules.id
  title text not null,
  description text,
  "type" public.quiz_type default 'entrainement' not null,
  time_limit_s integer,
  pass_threshold integer default 70 not null,
  created_at timestamp with time zone default now() not null,
  timer_enabled boolean default true not null,
  is_mock_exam boolean default false not null,
  max_attempts integer,
  retake_delay_hours integer default 0 not null,
  shuffle_questions boolean default false not null,
  shuffle_choices boolean default false not null,
  require_fullscreen boolean default false not null,
  show_explanations_mode text default 'always' not null,
  generation_mode text default 'static' not null,
  bank_filters jsonb,
  requires_manual_grading boolean default false not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.referral_codes (
  user_id uuid,  -- FK → profiles.id
  code text not null,
  created_at timestamp with time zone default now() not null,
  active boolean default true not null,
  primary key (user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.referrals (
  id uuid default gen_random_uuid(),
  referrer_id uuid not null,  -- FK → profiles.id
  referred_user_id uuid not null,  -- FK → profiles.id
  code_used text not null,
  status text not null,
  enrollment_id uuid,  -- FK → enrollments.id
  reward_cents integer,
  rewarded_at timestamp with time zone,
  rewarded_by uuid,  -- FK → profiles.id
  rejection_reason text,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.satisfaction_surveys (
  id uuid default gen_random_uuid(),
  user_id uuid not null,
  "type" text not null,
  note_globale integer,
  note_contenu integer,
  note_pedagogie integer,
  note_plateforme integer,
  note_accompagnement integer,
  points_forts text,
  points_ameliorer text,
  recommandation integer,
  situation_pro text,
  situation_detail text,
  submitted_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.search_logs (
  id uuid default extensions.uuid_generate_v4(),
  user_id uuid,  -- FK → profiles.id
  query text not null,
  query_norm text,
  results_count integer default 0 not null,
  kind_filter text,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.session_attendance (
  session_id uuid,  -- FK → live_sessions.id
  user_id uuid,  -- FK → profiles.id
  signed_at timestamp with time zone default now() not null,
  method text default 'online_click' not null,
  ip_address inet,
  user_agent text,
  signature_storage_path text,
  validated_by uuid,  -- FK → profiles.id
  validated_at timestamp with time zone,
  notes text,
  primary key (session_id, user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.session_enrollments (
  session_id uuid,  -- FK → live_sessions.id
  user_id uuid,  -- FK → profiles.id
  status text default 'confirmed' not null,
  registered_at timestamp with time zone default now() not null,
  cancelled_at timestamp with time zone,
  cancellation_reason text,
  primary key (session_id, user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.trainer_assignments (
  id uuid default extensions.uuid_generate_v4(),
  trainer_id uuid not null,  -- FK → profiles.id
  student_id uuid not null,  -- FK → profiles.id
  role text default 'main' not null,
  formation_slug text,
  assigned_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.trainer_formations (
  id uuid default extensions.uuid_generate_v4(),
  trainer_id uuid not null,  -- FK → profiles.id
  formation_id uuid not null,  -- FK → formations.id
  can_grade boolean default true not null,
  can_edit_content boolean default false not null,
  is_lead boolean default false not null,
  granted_at timestamp with time zone default now() not null,
  granted_by uuid,  -- FK → profiles.id
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.trainer_payouts (
  user_id uuid,  -- FK → profiles.id
  stripe_connect_account_id text,
  stripe_onboarding_complete boolean default false,
  stripe_charges_enabled boolean default false,
  stripe_payouts_enabled boolean default false,
  kyc_status text default 'not_started',
  kyc_updated_at timestamp with time zone,
  revenue_share_pct numeric default 70,
  contract_signed_at timestamp with time zone,
  contract_url text,
  notes text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  primary key (user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.trainer_revenue_events (
  id uuid default gen_random_uuid(),
  trainer_user_id uuid not null,  -- FK → profiles.id
  module_id uuid,  -- FK → modules.id
  enrollment_id uuid,  -- FK → enrollments.id
  gross_amount_cents integer not null,
  platform_fee_cents integer not null,
  trainer_share_cents integer not null,
  stripe_session_id text,
  stripe_transfer_id text,
  status text default 'pending' not null,
  transferred_at timestamp with time zone,
  notes text,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.tutor_conversations (
  id uuid default gen_random_uuid(),
  user_id uuid not null,  -- FK → profiles.id
  title text,
  context_module_id uuid,  -- FK → modules.id
  context_formation_slug text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.tutor_messages (
  id uuid default gen_random_uuid(),
  conversation_id uuid not null,  -- FK → tutor_conversations.id
  role text not null,
  content text not null,
  citations jsonb,
  tokens_in integer,
  tokens_out integer,
  cost_cents integer,
  moderation_passed boolean,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.tutor_quotas (
  user_id uuid,  -- FK → profiles.id
  month date,
  messages_count integer default 0 not null,
  cost_cents integer default 0 not null,
  updated_at timestamp with time zone default now() not null,
  primary key (user_id, month)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.user_activity_summary (
  id uuid,
  email text,
  full_name text,
  group_id uuid,  -- FK → groups.id
  disabled boolean,
  last_sign_in_at timestamp with time zone,
  total_session_s integer,
  session_count integer,
  quiz_attempts_count bigint,
  lessons_completed_count bigint,
  avg_score numeric,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.user_badges (
  id uuid default gen_random_uuid(),
  user_id uuid not null,  -- FK → profiles.id
  badge_id uuid not null,  -- FK → badges.id
  earned_at timestamp with time zone default now() not null,
  context jsonb,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.user_consents (
  id uuid default gen_random_uuid(),
  user_id uuid not null,  -- FK → profiles.id
  kind text not null,
  granted boolean not null,
  granted_at timestamp with time zone default now() not null,
  ip_address inet,
  user_agent text,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.user_credits (
  id uuid default gen_random_uuid(),
  user_id uuid not null,  -- FK → profiles.id
  amount_cents integer not null,
  kind text not null,
  ref_id text,
  description text,
  created_at timestamp with time zone default now() not null,
  created_by uuid,  -- FK → profiles.id
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.user_gamification (
  user_id uuid,
  full_name text,
  email text,
  total_xp integer,
  level integer,
  active_days integer,
  last_xp_at timestamp with time zone,
  primary key (user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.user_last_activity (
  user_id uuid,
  full_name text,
  email text,
  last_activity_at timestamp with time zone,
  is_active_enrollment boolean,
  primary key (user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.user_loyalty_status (
  user_id uuid,
  full_name text,
  email text,
  paid_enrollments integer,
  tier text,
  enrollments_to_next_tier integer,
  next_discount_pct integer,
  final_certificates_count integer,
  primary key (user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.user_onboarding_status (
  user_id uuid,
  full_name text,
  email text,
  onboarding_completed_at timestamp with time zone,
  required_docs bigint,
  accepted_docs bigint,
  primary key (user_id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.user_sessions (
  id uuid default extensions.uuid_generate_v4(),
  user_id uuid not null,  -- FK → profiles.id
  started_at timestamp with time zone default now() not null,
  last_ping_at timestamp with time zone default now() not null,
  duration_s integer default 0 not null,
  path text,
  user_agent text,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.user_signatures (
  id uuid default gen_random_uuid(),
  user_id uuid not null,
  signature_data text not null,
  hash text,
  signed_at timestamp with time zone default now() not null,
  ip_address inet,
  user_agent text,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.user_training_summary (
  id uuid,
  email text,
  full_name text,
  enrolled_at timestamp with time zone,
  last_sign_in_at timestamp with time zone,
  total_session_s integer,
  session_count integer,
  lessons_completed bigint,
  lessons_viewed bigint,
  lesson_time_s bigint,
  quiz_attempts bigint,
  quiz_passed bigint,
  avg_score numeric,
  first_session timestamp with time zone,
  last_session timestamp with time zone,
  primary key (id)
);

-- ─────────────────────────────────────────────────────────────────────
create table if not exists public.xp_events (
  id uuid default extensions.uuid_generate_v4(),
  user_id uuid not null,  -- FK → profiles.id
  kind text not null,
  points integer not null,
  ref_id text,
  created_at timestamp with time zone default now() not null,
  primary key (id)
);

-- =====================================================================
-- VUES (32) — corps SQL dans les migrations, voir MIGRATIONS_INDEX.md
-- =====================================================================
--   • accessibility_overview (12 colonnes)
--   • acquisition_attribution (10 colonnes)
--   • crm_pipeline_counters (4 colonnes)
--   • formations_demand (7 colonnes)
--   • funder_overview (8 colonnes)
--   • funder_recent_events (8 colonnes)
--   • funder_student_details (26 colonnes)
--   • leaderboard_public (5 colonnes)
--   • pending_qr_corrections (14 colonnes)
--   • quiz_question_flag_rate (4 colonnes)
--   • search_top_queries (5 colonnes)
--   • survey_stats (8 colonnes)
--   • trainer_formation_overview (10 colonnes)
--   • trainer_my_students (10 colonnes)
--   • trainer_revenue_summary (8 colonnes)
--   • user_credit_balance (2 colonnes)
--   • user_daily_activity (6 colonnes)
--   • vw_admin_acquisition_daily (3 colonnes)
--   • vw_admin_activity_heatmap (3 colonnes)
--   • vw_admin_at_risk_students (11 colonnes)
--   • vw_admin_completion_by_formation (9 colonnes)
--   • vw_admin_funnel_by_utm (9 colonnes)
--   • vw_admin_funnel_conversion (5 colonnes)
--   • vw_admin_kpis_realtime (12 colonnes)
--   • vw_admin_qualiopi_indicators (7 colonnes)
--   • vw_admin_quiz_outliers (9 colonnes)
--   • vw_admin_revenue_by_formation_pack (9 colonnes)
--   • vw_admin_top_campaigns (6 colonnes)
--   • vw_admin_top_students (8 colonnes)
--   • vw_admin_trends_30d (4 colonnes)
--   • vw_admin_trends_by_formation (7 colonnes)
--   • vw_admin_upcoming_sessions_14d (13 colonnes)
