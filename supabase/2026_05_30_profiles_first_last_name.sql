-- =====================================================================
-- Profiles : Prénom / Nom séparés (en plus de full_name).
--
-- Contexte : l'app ne stockait que `full_name`. On ajoute `first_name`
-- et `last_name` pour l'identité civile (Qualiopi / CPF / conventions),
-- tout en CONSERVANT `full_name` comme champ d'affichage (utilisé par la
-- recherche, le tri, les initiales, les emails). À l'enregistrement,
-- l'app recompose full_name = first_name + ' ' + last_name.
--
-- Backfill best-effort : on découpe l'existant `full_name` en
--   - first_name = 1er mot
--   - last_name  = le reste
-- C'est une heuristique : les noms composés pourront être corrigés à la
-- main dans la fiche utilisateur. full_name reste la source d'affichage,
-- donc aucun risque de régression visuelle.
--
-- À exécuter dans l'éditeur SQL Supabase, puis :
--   node scripts/introspect-schema.mjs
-- =====================================================================

alter table public.profiles
  add column if not exists first_name text,
  add column if not exists last_name  text;

-- Backfill uniquement les lignes non encore renseignées, à partir de
-- full_name nettoyé (espaces multiples réduits).
update public.profiles
   set first_name = nullif(split_part(regexp_replace(trim(full_name), '\s+', ' ', 'g'), ' ', 1), ''),
       last_name  = nullif(
         trim(substr(
           regexp_replace(trim(full_name), '\s+', ' ', 'g'),
           position(' ' in regexp_replace(trim(full_name), '\s+', ' ', 'g')) + 1
         )),
         ''
       )
 where full_name is not null
   and trim(full_name) <> ''
   and first_name is null
   and last_name is null;

comment on column public.profiles.first_name is 'Prénom (identité civile). full_name reste le champ d''affichage recomposé.';
comment on column public.profiles.last_name  is 'Nom de famille (identité civile). full_name reste le champ d''affichage recomposé.';

-- Vérification (optionnel) : aperçu du découpage.
select id, full_name, first_name, last_name
  from public.profiles
 order by created_at desc
 limit 20;
