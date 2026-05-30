-- =====================================================================
-- Correctif — QCM sans bonne réponse + champs de réponse vides en édition.
--
-- CAUSE RACINE
--   L'application attend des choix de QCM au format canonique :
--       {"id":"a","label":"16,50 m","is_correct":true}
--   (utilisé par les chapitres 1, 3, 5 … 17 et les modules CAPA).
--   Or les seeds des chapitres 2 et 4 avaient été générés avec d'autres
--   noms de clés :
--       {"key":"a","text":"16,50 m","correct":true}
--   Conséquences dans l'app :
--     - Liste « Banque de questions » : ne trouve aucun `is_correct`
--       => badge « aucune bonne réponse ».
--     - Éditeur de question : lit `id` / `label` => cases de réponse
--       A/B/C/D affichées VIDES.
--     - (Le player de quiz tolère les deux formats, donc le passage de
--       quiz n'était pas bloqué, mais la correction admin l'était.)
--
-- CE QUE FAIT CE SCRIPT
--   Réécrit la colonne jsonb `choices` au format canonique en
--   renommant les clés, SANS retranscrire aucune valeur à la main :
--       key      -> id
--       text     -> label
--       correct  -> is_correct
--   La valeur booléenne de la bonne réponse et les textes d'options sont
--   simplement déplacés sous le bon nom de clé. Zéro risque d'erreur de
--   saisie.
--
-- SÛRETÉ
--   - Ne touche QUE les QCM dont au moins une option utilise encore une
--     ancienne clé (key / text / correct).
--   - Ne supprime ni ne recrée aucune question / module / quiz : les ID,
--     liens de quiz, tentatives et progressions sont conservés.
--   - Idempotent : une fois normalisés, les choix n'ont plus d'ancienne
--     clé => le WHERE ne les resélectionne plus.
--   - Couvre les chapitres 2 et 4 et tout autre seed ayant la même
--     coquille.
--
-- À exécuter dans l'éditeur SQL Supabase, puis rafraîchir la page admin.
-- =====================================================================

-- 1) Aperçu AVANT (optionnel) : questions concernées, par série.
select split_part(source_ref, ':', 3) as chapitre,
       count(*) as questions_a_corriger
  from public.question_bank q
 where q.type = 'qcm'
   and q.choices is not null
   and exists (
     select 1
       from jsonb_array_elements(q.choices) e
      where (e ? 'key') or (e ? 'text') or (e ? 'correct')
   )
 group by 1
 order by 1;

-- 2) Correction : reconstruit chaque option au format {id,label,is_correct}.
update public.question_bank q
   set choices = (
         select jsonb_agg(
                  jsonb_build_object(
                    'id',         coalesce(elem -> 'id',         elem -> 'key'),
                    'label',      coalesce(elem -> 'label',      elem -> 'text'),
                    'is_correct', coalesce(elem -> 'is_correct', elem -> 'correct', 'false'::jsonb)
                  )
                  order by ord
                )
           from jsonb_array_elements(q.choices) with ordinality as t(elem, ord)
       ),
       updated_at = now()
 where q.type = 'qcm'
   and q.choices is not null
   and exists (
     select 1
       from jsonb_array_elements(q.choices) e
      where (e ? 'key') or (e ? 'text') or (e ? 'correct')
   );

-- 3) Vérification APRÈS : chaque QCM GOTRM ch02/ch04 doit avoir ok = true
--    et la bonne réponse lisible.
select q.source_ref,
       (select c ->> 'label'
          from jsonb_array_elements(q.choices) c
         where (c ->> 'is_correct')::boolean) as bonne_reponse,
       exists (
         select 1 from jsonb_array_elements(q.choices) c
          where (c ->> 'is_correct')::boolean
       ) as ok
  from public.question_bank q
 where q.source_ref like 'mft-2026-gotrm-livret:ch02:qcm:%'
    or q.source_ref like 'mft-2026-gotrm-livret:ch04:qcm:%'
 order by q.source_ref;
