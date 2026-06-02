-- =====================================================================
-- Correctif suppression d'utilisateur — FK bloquantes vers auth.users.
--
-- CAUSE
--   Trois colonnes d'audit référençaient auth.users(id) SANS clause
--   ON DELETE (donc NO ACTION = blocage) :
--     - public.announcements.created_by
--     - public.onboarding_documents.updated_by
--     - public.formation_settings.updated_by
--   Quand on supprimait un compte staff ayant créé une annonce ou modifié
--   un document d'entrée / les paramètres Qualiopi, Postgres refusait la
--   suppression de auth.users -> l'action serveur levait une erreur,
--   masquée en prod par Next (« An error occurred in the Server Components
--   render… »). D'où le bug intermittent (« de temps en temps »).
--
-- CORRECTIF
--   On bascule ces 3 FK en ON DELETE SET NULL : on conserve la ligne
--   (annonce, document, paramètres) mais on oublie qui l'a créée/modifiée.
--   C'est le comportement attendu pour des champs « créé par / modifié par ».
--
-- Idempotent : on drop la contrainte si elle existe puis on la recrée.
-- À exécuter dans l'éditeur SQL Supabase, puis :
--   node scripts/introspect-schema.mjs
-- =====================================================================

-- Helper : retrouve et recrée la FK avec ON DELETE SET NULL, quel que
-- soit le nom auto-généré de la contrainte existante.
do $$
declare
  r record;
begin
  -- 1) announcements.created_by → auth.users
  for r in
    select conname
      from pg_constraint
     where conrelid = 'public.announcements'::regclass
       and contype = 'f'
       and conname like '%created_by%'
  loop
    execute format('alter table public.announcements drop constraint %I', r.conname);
  end loop;
  alter table public.announcements
    add constraint announcements_created_by_fkey
    foreign key (created_by) references auth.users(id) on delete set null;

  -- 2) onboarding_documents.updated_by → auth.users
  for r in
    select conname
      from pg_constraint
     where conrelid = 'public.onboarding_documents'::regclass
       and contype = 'f'
       and conname like '%updated_by%'
  loop
    execute format('alter table public.onboarding_documents drop constraint %I', r.conname);
  end loop;
  alter table public.onboarding_documents
    add constraint onboarding_documents_updated_by_fkey
    foreign key (updated_by) references auth.users(id) on delete set null;

  -- 3) formation_settings.updated_by → auth.users
  for r in
    select conname
      from pg_constraint
     where conrelid = 'public.formation_settings'::regclass
       and contype = 'f'
       and conname like '%updated_by%'
  loop
    execute format('alter table public.formation_settings drop constraint %I', r.conname);
  end loop;
  alter table public.formation_settings
    add constraint formation_settings_updated_by_fkey
    foreign key (updated_by) references auth.users(id) on delete set null;
end $$;

-- Vérification : les 3 contraintes doivent être confdeltype = 'n' (SET NULL).
select conrelid::regclass as table_name,
       conname,
       confdeltype  -- 'n' = SET NULL, 'a' = NO ACTION, 'c' = CASCADE
  from pg_constraint
 where contype = 'f'
   and conrelid in (
     'public.announcements'::regclass,
     'public.onboarding_documents'::regclass,
     'public.formation_settings'::regclass
   )
   and (conname like '%created_by%' or conname like '%updated_by%')
 order by 1;
