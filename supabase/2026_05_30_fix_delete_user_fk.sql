-- =====================================================================
-- Correctif suppression d'utilisateur — FK bloquantes vers auth.users.
--
-- SYMPTÔME
--   « Database error deleting user » (Supabase Auth) / en prod côté app :
--   « An error occurred in the Server Components render… ».
--   Supprimer un compte est refusé par Postgres car des colonnes
--   référencent auth.users(id) (ou public.profiles(id)) avec une règle
--   ON DELETE = NO ACTION (le défaut) : la suppression est alors bloquée
--   dès qu'une ligne liée existe.
--
-- APPROCHE GÉNÉRIQUE (robuste)
--   On ne se contente pas de corriger 3 FK connues : on balaie TOUTES les
--   FK qui pointent vers auth.users et public.profiles avec confdeltype
--   = 'a' (NO ACTION) ou 'r' (RESTRICT), et on les recrée :
--     - colonne NOT NULL  -> ON DELETE CASCADE (la ligne dépend du user)
--     - colonne NULLABLE  -> ON DELETE SET NULL (champ d'audit « par qui »)
--   Cela couvre aussi d'éventuelles FK créées directement dans Supabase
--   (hors dépôt).
--
-- SÛRETÉ
--   - N'altère que les FK problématiques (ignore CASCADE / SET NULL déjà ok).
--   - Idempotent : relançable sans effet une fois tout corrigé.
--   - Ne touche jamais la PK profiles.id -> auth.users (déjà gérée par
--     Supabase) ni les contraintes système du schéma auth.
--
-- À exécuter dans l'éditeur SQL Supabase, puis :
--   node scripts/introspect-schema.mjs
-- =====================================================================

-- 1) DIAGNOSTIC (avant) : liste les FK bloquantes vers auth.users / profiles.
select
  con.conrelid::regclass            as table_concernee,
  att.attname                       as colonne,
  con.confrelid::regclass           as reference_vers,
  con.conname                       as contrainte,
  case con.confdeltype
    when 'a' then 'NO ACTION (bloque)'
    when 'r' then 'RESTRICT (bloque)'
    when 'c' then 'CASCADE'
    when 'n' then 'SET NULL'
    when 'd' then 'SET DEFAULT'
  end                               as regle_actuelle
from pg_constraint con
join pg_attribute att
  on att.attrelid = con.conrelid
 and att.attnum = con.conkey[1]
where con.contype = 'f'
  and con.confrelid in ('auth.users'::regclass, 'public.profiles'::regclass)
  and con.confdeltype in ('a', 'r')          -- uniquement les bloquantes
  and array_length(con.conkey, 1) = 1        -- FK mono-colonne
order by 1, 2;

-- 2) CORRECTION automatique de toutes les FK bloquantes ci-dessus.
do $$
declare
  r            record;
  v_is_notnull boolean;
  v_action     text;
  v_col        text;
begin
  for r in
    select con.oid,
           con.conrelid,
           con.conrelid::regclass as tbl,
           con.confrelid::regclass as ref,
           con.conname,
           con.conkey[1]          as attnum
      from pg_constraint con
     where con.contype = 'f'
       and con.confrelid in ('auth.users'::regclass, 'public.profiles'::regclass)
       and con.confdeltype in ('a', 'r')
       and array_length(con.conkey, 1) = 1
  loop
    -- Nom de la colonne portant la FK
    select attname, attnotnull
      into v_col, v_is_notnull
      from pg_attribute
     where attrelid = r.conrelid
       and attnum = r.attnum;

    -- NOT NULL -> CASCADE (la ligne n'a pas de sens sans le user)
    -- NULLABLE -> SET NULL (champ d'audit : on garde la ligne, on oublie l'auteur)
    v_action := case when v_is_notnull then 'cascade' else 'set null' end;

    execute format('alter table %s drop constraint %I', r.tbl, r.conname);
    execute format(
      'alter table %s add constraint %I foreign key (%I) references %s(id) on delete %s',
      r.tbl, r.conname, v_col, r.ref, v_action
    );

    raise notice 'FK corrigée : %.% -> % (ON DELETE %)',
      r.tbl, v_col, r.ref, upper(v_action);
  end loop;
end $$;

-- 3) VÉRIFICATION (après) : plus aucune ligne ne doit ressortir ici.
select
  con.conrelid::regclass  as table_concernee,
  con.conname             as contrainte_encore_bloquante
from pg_constraint con
where con.contype = 'f'
  and con.confrelid in ('auth.users'::regclass, 'public.profiles'::regclass)
  and con.confdeltype in ('a', 'r')
  and array_length(con.conkey, 1) = 1
order by 1;
