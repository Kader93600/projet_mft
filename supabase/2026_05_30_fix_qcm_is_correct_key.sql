-- =====================================================================
-- Correctif — QCM sans bonne réponse affichée (« aucune bonne réponse »).
--
-- CAUSE RACINE
--   L'application lit la bonne réponse via la clé JSON `is_correct`
--   (page liste banque de questions, éditeur, quiz runner, validations).
--   Or certains seeds GOTRM (chapitres 2 et 4) ont stocké les choix avec
--   la clé `correct` au lieu de `is_correct` :
--       {"key":"a","text":"16,50 m","correct":true}      <- non reconnu
--   au lieu de la forme attendue (chapitres 1, 3, 5 … 17) :
--       {"key":"a","text":"16,50 m","is_correct":true}   <- correct
--   Résultat : l'app ne trouve aucune option « is_correct » → l'admin
--   affiche « aucune bonne réponse » et le scoring ne peut pas marquer
--   la bonne case.
--
-- CE QUE FAIT CE SCRIPT
--   Renomme, dans la colonne jsonb `choices`, la clé `correct` en
--   `is_correct` pour chaque option concernée, EN CONSERVANT la valeur
--   booléenne déjà présente. Aucune réponse n'est retranscrite à la main :
--   on déplace simplement la clé. Donc aucun risque d'erreur de saisie.
--
-- SÛRETÉ
--   - Ne touche QUE les options ayant `correct` sans `is_correct`.
--   - Ne supprime ni ne recrée aucune question / module / quiz : les ID,
--     liens de quiz, tentatives et progressions sont conservés.
--   - Idempotent : relançable sans effet (le WHERE ne sélectionne plus
--     rien une fois corrigé).
--   - Portée : tous les QCM concernés (corrige chapitres 2 ET 4 d'un coup,
--     ainsi que tout autre seed ayant la même coquille).
--
-- À exécuter dans l'éditeur SQL Supabase, puis rafraîchir la page admin.
-- =====================================================================

-- 1) Aperçu AVANT (optionnel) : combien d'options sont à corriger, par série.
select split_part(source_ref, ':', 3) as chapitre,
       count(*) as questions_concernees
  from public.question_bank q
 where q.type = 'qcm'
   and q.choices is not null
   and exists (
     select 1
       from jsonb_array_elements(q.choices) e
      where (e ? 'correct') and not (e ? 'is_correct')
   )
 group by 1
 order by 1;

-- 2) Correction : renomme la clé `correct` -> `is_correct` option par option.
update public.question_bank q
   set choices = (
         select jsonb_agg(
                  case
                    when (elem ? 'correct') and not (elem ? 'is_correct')
                    then (elem - 'correct')
                         || jsonb_build_object('is_correct', elem -> 'correct')
                    else elem
                  end
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
      where (e ? 'correct') and not (e ? 'is_correct')
   );

-- 3) Vérification APRÈS : chaque QCM GOTRM ch02/ch04 doit avoir ok = true
--    et la bonne réponse lisible.
select q.source_ref,
       (select c ->> 'text'
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
