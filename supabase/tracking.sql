-- =====================================================================
-- MA FORMATION TRANSPORT — Tracking temps réel & Qualiopi
-- À exécuter APRÈS admin_extensions.sql
-- Idempotent
-- =====================================================================

-- =====================================================================
-- 1. VUES DE LEÇONS (engagement pédagogique mesurable)
-- =====================================================================
create table if not exists lesson_views (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  lesson_id uuid not null references lessons(id) on delete cascade,
  started_at timestamptz not null default now(),
  last_ping_at timestamptz not null default now(),
  duration_s integer not null default 0,
  completed boolean not null default false
);

create index if not exists lesson_views_user_idx on lesson_views(user_id);
create index if not exists lesson_views_lesson_idx on lesson_views(lesson_id);
create index if not exists lesson_views_started_idx on lesson_views(started_at desc);

alter table lesson_views enable row level security;
drop policy if exists "lesson_views_self_all" on lesson_views;
drop policy if exists "lesson_views_admin_read" on lesson_views;
create policy "lesson_views_self_all" on lesson_views for all using (auth.uid() = user_id);
create policy "lesson_views_admin_read" on lesson_views for select using (public.is_admin());

-- =====================================================================
-- 2. FONCTION : ping de session (appelée toutes les 30s depuis le client)
-- =====================================================================
-- Crée une session si aucune active dans les 5 dernières minutes,
-- sinon met à jour la session existante.
create or replace function public.ping_session(
  p_path text default null,
  p_user_agent text default null
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_session_id uuid;
  v_last_ping timestamptz;
  v_started timestamptz;
begin
  if v_user_id is null then
    raise exception 'Non authentifié';
  end if;

  -- Chercher une session active récente (< 5 min d'inactivité)
  select id, last_ping_at, started_at into v_session_id, v_last_ping, v_started
  from user_sessions
  where user_id = v_user_id
    and last_ping_at > now() - interval '5 minutes'
  order by last_ping_at desc
  limit 1;

  if v_session_id is not null then
    -- Mise à jour de la session active
    update user_sessions
    set last_ping_at = now(),
        duration_s = greatest(duration_s, extract(epoch from (now() - v_started))::integer),
        path = coalesce(p_path, path)
    where id = v_session_id;
  else
    -- Nouvelle session
    insert into user_sessions (user_id, path, user_agent)
    values (v_user_id, p_path, p_user_agent)
    returning id into v_session_id;

    -- Incrémenter le compteur + last_sign_in_at
    update profiles
    set session_count = coalesce(session_count, 0) + 1,
        last_sign_in_at = now()
    where id = v_user_id;
  end if;

  -- Mettre à jour le total cumulé (best effort, pas critique si inexact)
  update profiles p
  set total_session_s = (
    select coalesce(sum(duration_s), 0)::integer from user_sessions where user_id = v_user_id
  )
  where p.id = v_user_id;

  return v_session_id;
end;
$$;

-- =====================================================================
-- 3. FONCTION : ping de vue de leçon
-- =====================================================================
create or replace function public.ping_lesson_view(
  p_lesson_id uuid,
  p_completed boolean default false
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_view_id uuid;
  v_started timestamptz;
begin
  if v_user_id is null then
    raise exception 'Non authentifié';
  end if;

  -- Chercher une vue active récente sur cette leçon (< 3 min)
  select id, started_at into v_view_id, v_started
  from lesson_views
  where user_id = v_user_id
    and lesson_id = p_lesson_id
    and last_ping_at > now() - interval '3 minutes'
  order by last_ping_at desc
  limit 1;

  if v_view_id is not null then
    update lesson_views
    set last_ping_at = now(),
        duration_s = greatest(duration_s, extract(epoch from (now() - v_started))::integer),
        completed = lesson_views.completed or p_completed
    where id = v_view_id;
  else
    insert into lesson_views (user_id, lesson_id, completed)
    values (v_user_id, p_lesson_id, p_completed)
    returning id into v_view_id;
  end if;

  return v_view_id;
end;
$$;

-- =====================================================================
-- 4. VUE : activité quotidienne par utilisateur
--    Utilisée par les feuilles de présence et rapports Qualiopi.
-- =====================================================================
create or replace view public.user_daily_activity as
select
  us.user_id,
  date_trunc('day', us.started_at)::date as day,
  count(*)::int as sessions,
  sum(us.duration_s)::int as total_seconds,
  min(us.started_at) as first_connection,
  max(us.last_ping_at) as last_activity
from user_sessions us
group by us.user_id, date_trunc('day', us.started_at);

-- =====================================================================
-- 5. VUE : résumé pédagogique complet par utilisateur
-- =====================================================================
create or replace view public.user_training_summary as
select
  p.id,
  p.email,
  p.full_name,
  p.created_at as enrolled_at,
  p.last_sign_in_at,
  coalesce(p.total_session_s, 0) as total_session_s,
  coalesce(p.session_count, 0) as session_count,
  (select count(*) from lesson_progress lp where lp.user_id = p.id and lp.completed) as lessons_completed,
  (select count(distinct lv.lesson_id) from lesson_views lv where lv.user_id = p.id) as lessons_viewed,
  (select coalesce(sum(duration_s), 0) from lesson_views lv where lv.user_id = p.id) as lesson_time_s,
  (select count(*) from quiz_attempts qa where qa.user_id = p.id) as quiz_attempts,
  (select count(*) from quiz_attempts qa where qa.user_id = p.id and qa.passed) as quiz_passed,
  (select coalesce(round(avg(percentage)), 0) from quiz_attempts qa where qa.user_id = p.id) as avg_score,
  (select min(started_at) from user_sessions us where us.user_id = p.id) as first_session,
  (select max(last_ping_at) from user_sessions us where us.user_id = p.id) as last_session
from profiles p;
