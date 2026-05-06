-- =====================================================================
-- MA FORMATION TRANSPORT — Durcissement sécurité
-- À exécuter APRÈS schema.sql et admin_extensions.sql
-- Idempotent
-- =====================================================================

-- =====================================================================
-- 1. STORAGE : policies stricte sur content-media
-- =====================================================================
-- Lecture publique (les images doivent être accessibles sans auth
--                  car embarquées dans du markdown public).
-- Écriture réservée aux admins uniquement.

drop policy if exists "content_media_read_public" on storage.objects;
drop policy if exists "content_media_admin_write" on storage.objects;
drop policy if exists "content_media_admin_update" on storage.objects;
drop policy if exists "content_media_admin_delete" on storage.objects;

create policy "content_media_read_public"
  on storage.objects for select
  using (bucket_id = 'content-media');

create policy "content_media_admin_write"
  on storage.objects for insert
  with check (bucket_id = 'content-media' and public.is_admin());

create policy "content_media_admin_update"
  on storage.objects for update
  using (bucket_id = 'content-media' and public.is_admin());

create policy "content_media_admin_delete"
  on storage.objects for delete
  using (bucket_id = 'content-media' and public.is_admin());

-- =====================================================================
-- 2. AUDIT LOG (traçabilité des actions sensibles)
-- =====================================================================
create table if not exists audit_log (
  id uuid primary key default uuid_generate_v4(),
  actor_id uuid references profiles(id) on delete set null,
  actor_email text,
  action text not null,        -- ex. "delete_attempt", "disable_user"
  target_type text,            -- ex. "quiz_attempt", "profile", "module"
  target_id text,
  metadata jsonb,
  ip_address text,
  user_agent text,
  created_at timestamptz not null default now()
);

create index if not exists audit_log_actor_id_idx on audit_log(actor_id);
create index if not exists audit_log_action_idx on audit_log(action);
create index if not exists audit_log_created_at_idx on audit_log(created_at desc);

alter table audit_log enable row level security;
drop policy if exists "audit_admin_read" on audit_log;
drop policy if exists "audit_system_write" on audit_log;
create policy "audit_admin_read" on audit_log for select using (public.is_admin());
-- Le write passe par une fonction security definer pour garantir l'intégrité
create policy "audit_admin_write" on audit_log for insert with check (public.is_admin());

-- =====================================================================
-- 3. FONCTION : logger une action
-- =====================================================================
create or replace function public.log_admin_action(
  p_action text,
  p_target_type text,
  p_target_id text,
  p_metadata jsonb default null
) returns void
language plpgsql
security definer
as $$
declare
  v_email text;
begin
  select email into v_email from profiles where id = auth.uid();
  insert into audit_log (actor_id, actor_email, action, target_type, target_id, metadata)
  values (auth.uid(), v_email, p_action, p_target_type, p_target_id, p_metadata);
end;
$$;

-- =====================================================================
-- 4. RENFORCEMENT quiz_attempts : préserver l'intégrité pédagogique
-- =====================================================================
-- Bloque la modification des tentatives (immuable après création)
-- Seule la suppression explicite par admin reste possible (et est auditée).

drop policy if exists "attempts_no_update" on quiz_attempts;
drop policy if exists "attempts_self_insert" on quiz_attempts;
drop policy if exists "attempts_self_read" on quiz_attempts;
drop policy if exists "attempts_admin_delete" on quiz_attempts;

-- On remplace les policies existantes par un set plus granulaire
drop policy if exists "attempts_self_all" on quiz_attempts;
drop policy if exists "attempts_admin_read" on quiz_attempts;

create policy "attempts_self_read" on quiz_attempts
  for select using (auth.uid() = user_id or public.is_admin());

create policy "attempts_self_insert" on quiz_attempts
  for insert with check (auth.uid() = user_id);

-- Pas de policy UPDATE = aucune modification possible (immuable)
-- Seul l'admin peut supprimer (et ça sera loggé côté app)
create policy "attempts_admin_delete" on quiz_attempts
  for delete using (public.is_admin());

-- =====================================================================
-- 5. TRIGGER : log automatique des suppressions de tentatives
-- =====================================================================
create or replace function public.log_attempt_deletion()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into audit_log (actor_id, actor_email, action, target_type, target_id, metadata)
  values (
    auth.uid(),
    (select email from profiles where id = auth.uid()),
    'delete_attempt',
    'quiz_attempt',
    old.id::text,
    jsonb_build_object(
      'user_id', old.user_id,
      'quiz_id', old.quiz_id,
      'percentage', old.percentage,
      'passed', old.passed,
      'finished_at', old.finished_at
    )
  );
  return old;
end;
$$;

drop trigger if exists trg_log_attempt_deletion on quiz_attempts;
create trigger trg_log_attempt_deletion
  before delete on quiz_attempts
  for each row execute function public.log_attempt_deletion();

-- =====================================================================
-- 6. RENFORCEMENT profiles : bloquer self-escalation de rôle
-- =====================================================================
-- Un utilisateur ne peut pas changer son propre rôle ni son statut disabled
drop policy if exists "profiles_self_update" on profiles;
create policy "profiles_self_update" on profiles
  for update using (auth.uid() = id)
  with check (
    auth.uid() = id
    and role = (select role from profiles where id = auth.uid())
    and disabled = (select disabled from profiles where id = auth.uid())
  );

-- =====================================================================
-- 7. INDEX utiles pour les perfs en prod
-- =====================================================================
create index if not exists quiz_attempts_user_id_idx on quiz_attempts(user_id);
create index if not exists quiz_attempts_quiz_id_idx on quiz_attempts(quiz_id);
create index if not exists quiz_attempts_finished_at_idx on quiz_attempts(finished_at desc);
create index if not exists lesson_progress_user_id_idx on lesson_progress(user_id);
create index if not exists profiles_role_idx on profiles(role);
create index if not exists profiles_group_id_idx on profiles(group_id);
