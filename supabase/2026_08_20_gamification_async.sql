-- =====================================================================
-- Gamification asynchrone — tenue en charge des examens
--
-- Problème : tg_ach_quiz_attempts exécutait recompute_user_achievements()
-- (~38 agrégats count(*)) EN SYNCHRONE dans la transaction de chaque
-- INSERT/UPDATE de quiz_attempts, deux fois par copie QR. Un examen
-- passé par des centaines de stagiaires synchronisés sur la même minute
-- déclenchait une rafale de dizaines de milliers d'agrégats.
--
-- Solution : le trigger empile désormais l'user_id dans une file
-- dédupliquée (1 ligne par utilisateur, coût = 1 upsert trivial) ;
-- un job pg_cron consomme la file toutes les 15 s et exécute UN
-- recalcul par utilisateur, hors du chemin de soumission.
--
-- Impact fonctionnel : un badge apparaît au plus ~15-20 s après
-- l'action qui le débloque (aucune UI ne lit les badges dans le flux
-- de soumission de quiz ; ils s'affichent sur dashboard/fidélité).
-- L'action admin « recalculer les badges » (app/admin/badges) continue
-- d'appeler recompute_user_achievements() directement, en synchrone.
-- =====================================================================

-- 1) File d'attente dédupliquée par utilisateur
create table if not exists public.achievements_recompute_queue (
  user_id   uuid primary key references public.profiles(id) on delete cascade,
  queued_at timestamptz not null default now()
);

alter table public.achievements_recompute_queue enable row level security;
-- Aucune policy : la table n'est accessible qu'aux fonctions SECURITY
-- DEFINER (owner) et au service_role. Jamais exposée aux clients.

-- 2) Le trigger n'exécute plus le recalcul : il empile (upsert trivial)
create or replace function public.tg_achievements_recompute()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $$
begin
  insert into public.achievements_recompute_queue (user_id)
  values (new.user_id)
  on conflict (user_id) do update set queued_at = now();
  return new;
end $$;

-- 3) Consommateur : traite la file par lots, un recalcul par utilisateur.
--    FOR UPDATE SKIP LOCKED : plusieurs exécutions concurrentes du job
--    ne traitent jamais le même utilisateur deux fois.
create or replace function public.process_achievements_queue(p_max integer default 200)
returns integer
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  v_ids uuid[];
  v_id  uuid;
  v_ok  integer := 0;
begin
  with picked as (
    select user_id
    from public.achievements_recompute_queue
    order by queued_at
    limit p_max
    for update skip locked
  ),
  removed as (
    delete from public.achievements_recompute_queue q
    using picked p
    where q.user_id = p.user_id
    returning q.user_id
  )
  select array_agg(user_id) into v_ids from removed;

  if v_ids is null then
    return 0;
  end if;

  foreach v_id in array v_ids loop
    begin
      perform public.recompute_user_achievements(v_id);
      v_ok := v_ok + 1;
    exception when others then
      -- Échec isolé : on réempile pour retenter au prochain passage,
      -- sans bloquer le reste du lot.
      insert into public.achievements_recompute_queue (user_id)
      values (v_id)
      on conflict (user_id) do nothing;
    end;
  end loop;

  return v_ok;
end $$;

-- 4) Planification : pg_cron toutes les 15 secondes
create extension if not exists pg_cron;

select cron.schedule(
  'achievements-queue',
  '15 seconds',
  $$select public.process_achievements_queue();$$
);

-- 5) Hygiène : à 4 exécutions/minute, l'historique pg_cron grossit vite
--    (~5 800 lignes/jour). Purge quotidienne au-delà de 7 jours.
select cron.schedule(
  'purge-cron-history',
  '0 3 * * *',
  $$delete from cron.job_run_details where end_time < now() - interval '7 days';$$
);
