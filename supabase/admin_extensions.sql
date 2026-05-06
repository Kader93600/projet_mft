-- =====================================================================
-- MA FORMATION TRANSPORT — Extensions schema pour l'espace admin
-- À exécuter APRÈS schema.sql dans le SQL Editor Supabase
-- Idempotent : peut être ré-exécuté sans casse
-- =====================================================================

-- =====================================================================
-- 1. TABLE GROUPS (classes / promotions)
-- =====================================================================
create table if not exists groups (
  id uuid primary key default uuid_generate_v4(),
  name text not null unique,
  description text,
  academic_year text,        -- ex. "2025-2026"
  color text default 'navy', -- navy | gold | emerald | rose | violet
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table groups enable row level security;
drop policy if exists "groups_read_authed" on groups;
drop policy if exists "groups_admin_all" on groups;
create policy "groups_read_authed" on groups for select using (auth.role() = 'authenticated');
create policy "groups_admin_all" on groups for all using (public.is_admin());

-- =====================================================================
-- 2. EXTENSIONS PROFILES
-- =====================================================================
alter table profiles add column if not exists group_id uuid references groups(id) on delete set null;
alter table profiles add column if not exists disabled boolean not null default false;
alter table profiles add column if not exists phone text;
alter table profiles add column if not exists notes text;
alter table profiles add column if not exists last_sign_in_at timestamptz;
alter table profiles add column if not exists total_session_s integer not null default 0;
alter table profiles add column if not exists session_count integer not null default 0;

-- =====================================================================
-- 3. TABLE USER_SESSIONS (tracking activité)
-- =====================================================================
create table if not exists user_sessions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  started_at timestamptz not null default now(),
  last_ping_at timestamptz not null default now(),
  duration_s integer not null default 0,
  path text,
  user_agent text
);

create index if not exists user_sessions_user_id_idx on user_sessions(user_id);
create index if not exists user_sessions_started_at_idx on user_sessions(started_at desc);

alter table user_sessions enable row level security;
drop policy if exists "sessions_self_all" on user_sessions;
drop policy if exists "sessions_admin_read" on user_sessions;
create policy "sessions_self_all" on user_sessions for all using (auth.uid() = user_id);
create policy "sessions_admin_read" on user_sessions for select using (public.is_admin());

-- =====================================================================
-- 4. EXTENSIONS CONTENU (images, timer)
-- =====================================================================
alter table lessons add column if not exists cover_url text;
alter table questions add column if not exists image_url text;
alter table quizzes add column if not exists timer_enabled boolean not null default true;
alter table modules add column if not exists cover_url text;

-- =====================================================================
-- 5. FONCTION : mise à jour last_sign_in_at
-- =====================================================================
create or replace function public.touch_last_sign_in()
returns void language sql security definer as $$
  update profiles set last_sign_in_at = now() where id = auth.uid();
$$;

-- =====================================================================
-- 6. FONCTION : agrégat activité (pour dashboard admin)
-- =====================================================================
create or replace view public.user_activity_summary as
select
  p.id,
  p.email,
  p.full_name,
  p.group_id,
  p.disabled,
  p.last_sign_in_at,
  p.total_session_s,
  p.session_count,
  coalesce((select count(*) from quiz_attempts qa where qa.user_id = p.id), 0) as quiz_attempts_count,
  coalesce((select count(*) from lesson_progress lp where lp.user_id = p.id and lp.completed), 0) as lessons_completed_count,
  coalesce((select round(avg(percentage)) from quiz_attempts qa where qa.user_id = p.id), 0) as avg_score
from profiles p;

-- =====================================================================
-- 7. STORAGE : bucket public pour images pédagogiques
-- =====================================================================
-- À CRÉER MANUELLEMENT dans Supabase Dashboard → Storage :
--   Name: content-media
--   Public: true
--   File size limit: 5 MB
-- Puis policy "Authenticated users can upload" (insert)
-- Et policy "Anyone can view" (select)
