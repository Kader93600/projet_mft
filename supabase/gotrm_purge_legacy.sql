-- =====================================================================
-- PURGE GOTRM LEGACY — préparation à la refonte v4 livret CCP1
--
-- Supprime intégralement les modules GOTRM existants (versions v2 et v3)
-- pour permettre la production d'une nouvelle architecture alignée sur
-- le Livret CCP1 GOTRM V2 (17 chapitres = 17 modules).
--
-- Pré-requis client (validé) :
--   ✓ Perte définitive de toute progression stagiaire actuelle sur GOTRM
--   ✓ Conservation du module Capa 3,5 t (intact)
--   ✓ Conservation du glossaire GOTRM (sera mis à jour, pas supprimé)
--
-- Fonctionnement :
--   1) Identifie tous les modules dont le slug commence par "gotrm-"
--   2) Récupère les IDs liés (lessons, quizzes)
--   3) DELETE en cascade :
--      - quiz_question_bank (lien quizzes ↔ banque)
--      - quiz_attempts (tentatives stagiaires)
--      - quizzes (les évaluations)
--      - lesson_views (consultations stagiaires)
--      - lesson_progress (progression)
--      - lessons (contenu pédagogique)
--      - formation_modules (rattachement formation)
--      - question_bank (questions GOTRM par tags)
--      - modules (les modules eux-mêmes)
--   4) RAISE NOTICE avec le décompte des suppressions
--
-- Idempotent : ré-exécutable sans danger (toute purge supplémentaire = 0).
-- =====================================================================

DO $purge_gotrm$
DECLARE
  v_formation uuid;
  v_module_ids uuid[];
  v_lesson_ids uuid[];
  v_quiz_ids uuid[];
  v_count_modules int := 0;
  v_count_lessons int := 0;
  v_count_quizzes int := 0;
  v_count_qb int := 0;
  v_count_qqb int := 0;
  v_count_attempts int := 0;
  v_count_progress int := 0;
  v_count_views int := 0;
BEGIN
  SELECT id INTO v_formation
    FROM public.formations
   WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE NOTICE 'Formation gotrm introuvable — rien à purger.';
    RETURN;
  END IF;

  -- ─── 1. Récupération des IDs des modules GOTRM existants ─────────
  -- Tous les slugs commençant par "gotrm-" SAUF le glossaire (qui n'est
  -- pas un module mais des entrées dans glossary_terms).
  SELECT ARRAY_AGG(id) INTO v_module_ids
    FROM public.modules
   WHERE slug LIKE 'gotrm-%';

  IF v_module_ids IS NULL OR array_length(v_module_ids, 1) IS NULL THEN
    RAISE NOTICE 'Aucun module GOTRM trouvé — rien à purger.';
    RETURN;
  END IF;

  v_count_modules := array_length(v_module_ids, 1);
  RAISE NOTICE '→ % modules GOTRM identifiés pour purge.', v_count_modules;

  -- ─── 2. Récupération des IDs des leçons et quizzes liés ──────────
  SELECT ARRAY_AGG(id) INTO v_lesson_ids
    FROM public.lessons
   WHERE module_id = ANY(v_module_ids);

  SELECT ARRAY_AGG(id) INTO v_quiz_ids
    FROM public.quizzes
   WHERE module_id = ANY(v_module_ids);

  v_count_lessons := COALESCE(array_length(v_lesson_ids, 1), 0);
  v_count_quizzes := COALESCE(array_length(v_quiz_ids, 1), 0);

  -- ─── 3. Suppressions en cascade ─────────────────────────────────────

  -- 3a. quiz_question_bank (liens quiz ↔ banque)
  IF v_quiz_ids IS NOT NULL THEN
    WITH del AS (
      DELETE FROM public.quiz_question_bank
       WHERE quiz_id = ANY(v_quiz_ids)
       RETURNING 1
    )
    SELECT COUNT(*) INTO v_count_qqb FROM del;
  END IF;

  -- 3b. quiz_attempts (tentatives stagiaires) — perte de progression
  IF v_quiz_ids IS NOT NULL THEN
    WITH del AS (
      DELETE FROM public.quiz_attempts
       WHERE quiz_id = ANY(v_quiz_ids)
       RETURNING 1
    )
    SELECT COUNT(*) INTO v_count_attempts FROM del;
  END IF;

  -- 3c. quizzes
  IF v_quiz_ids IS NOT NULL THEN
    DELETE FROM public.quizzes
     WHERE id = ANY(v_quiz_ids);
  END IF;

  -- 3d. lesson_views (consultations) si la table existe
  IF v_lesson_ids IS NOT NULL THEN
    BEGIN
      WITH del AS (
        DELETE FROM public.lesson_views
         WHERE lesson_id = ANY(v_lesson_ids)
         RETURNING 1
      )
      SELECT COUNT(*) INTO v_count_views FROM del;
    EXCEPTION WHEN undefined_table THEN
      v_count_views := 0;
    END;
  END IF;

  -- 3e. lesson_progress (progression stagiaire) si la table existe
  IF v_lesson_ids IS NOT NULL THEN
    BEGIN
      WITH del AS (
        DELETE FROM public.lesson_progress
         WHERE lesson_id = ANY(v_lesson_ids)
         RETURNING 1
      )
      SELECT COUNT(*) INTO v_count_progress FROM del;
    EXCEPTION WHEN undefined_table THEN
      v_count_progress := 0;
    END;
  END IF;

  -- 3f. lessons
  IF v_lesson_ids IS NOT NULL THEN
    DELETE FROM public.lessons
     WHERE id = ANY(v_lesson_ids);
  END IF;

  -- 3g. formation_modules (rattachements)
  DELETE FROM public.formation_modules
   WHERE module_id = ANY(v_module_ids);

  -- 3h. question_bank — toutes les questions GOTRM
  -- Stratégie : par formation_id ET par module_id (déjà à NULL via ON DELETE
  -- SET NULL) — on cible les questions liées aux modules GOTRM via tags
  -- ou source_ref. Sécurité : on cible UNIQUEMENT formation_id GOTRM ET
  -- module_id appartenant à la liste GOTRM (ou source_ref typé GOTRM).
  WITH del AS (
    DELETE FROM public.question_bank
     WHERE formation_id = v_formation
       AND (
         module_id = ANY(v_module_ids)
         OR source_ref LIKE 'mft-2026-gotrm:%'
         OR source_ref LIKE 'gotrm-%'
         OR 'gotrm' = ANY(tags)
       )
     RETURNING 1
  )
  SELECT COUNT(*) INTO v_count_qb FROM del;

  -- 3i. modules
  DELETE FROM public.modules
   WHERE id = ANY(v_module_ids);

  -- ─── 4. Récap ───────────────────────────────────────────────────────
  RAISE NOTICE '╔══════════════════════════════════════════════════════════';
  RAISE NOTICE '║ ✓ PURGE GOTRM TERMINÉE';
  RAISE NOTICE '╠══════════════════════════════════════════════════════════';
  RAISE NOTICE '║ Modules supprimés          : %', v_count_modules;
  RAISE NOTICE '║ Leçons supprimées          : %', v_count_lessons;
  RAISE NOTICE '║ Quizzes supprimés          : %', v_count_quizzes;
  RAISE NOTICE '║ Questions banque purgées   : %', v_count_qb;
  RAISE NOTICE '║ Liens quiz↔banque purgés   : %', v_count_qqb;
  RAISE NOTICE '║ Tentatives stagiaires      : % (perte de progression)', v_count_attempts;
  RAISE NOTICE '║ Vues de leçon supprimées   : %', v_count_views;
  RAISE NOTICE '║ Progressions supprimées    : %', v_count_progress;
  RAISE NOTICE '╠══════════════════════════════════════════════════════════';
  RAISE NOTICE '║ Le glossaire GOTRM est conservé (sera mis à jour ensuite).';
  RAISE NOTICE '║ La formation Capa 3,5 t est intacte.';
  RAISE NOTICE '║ Prêt pour la production des 17 modules CCP1 du livret v4.';
  RAISE NOTICE '╚══════════════════════════════════════════════════════════';

END $purge_gotrm$;
