-- =====================================================================
-- NETTOYAGE COMPLET — Modules / Quizzes / Examens / Questions LEGACY
-- de la formation Capacité ≤ 3,5 T qui ont été remplacés par les v2.
--
-- À jouer UNE FOIS dans Supabase Studio → SQL Editor APRÈS avoir joué
-- les 6 fichiers capa_module_X_v2.sql.
--
-- Conserve uniquement les 6 modules v2 :
--   - capa-droit-civil-commercial (Module A)
--   - capa-activite-commerciale   (Module B)
--   - capa-cadre-reglementaire    (Module C)
--   - capa-activite-financiere    (Module D)
--   - capa-salaries-droit-social  (Module E)
--   - capa-securite               (Module F)
--
-- COUVRE :
--   ✓ Modules legacy (slugs hors liste blanche)
--   ✓ Quizzes attachés aux modules legacy (cascade)
--   ✓ Quizzes orphelins (module_id NULL ou pointant vers un module
--     supprimé)
--   ✓ Examens blancs legacy (is_mock_exam = true sans rattachement v2)
--   ✓ Questions legacy de question_bank (source_ref ≠ mft-2026:%)
--   ✓ Liens quiz_question_bank orphelins
--   ✓ Lessons orphelines
--   ✓ Questions / choices orphelins (table questions legacy)
--
-- Idempotent : safe à rejouer.
-- =====================================================================

DO $cleanup$
DECLARE
  v_formation uuid;
  v_deleted_modules int;
  v_deleted_orphan_quizzes int;
  v_deleted_orphan_lessons int;
  v_deleted_orphan_questions int;
  v_deleted_qb_questions int;
  v_deleted_qqb_links int;
  v_kept_modules int;
  v_kept_quizzes int;
  v_kept_qb_questions int;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'capacite-3-5t';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation capacite-3-5t introuvable.';
  END IF;

  RAISE NOTICE '🧹 Démarrage du cleanup Capa ≤ 3,5 T...';

  -- ─── 1. Suppression des modules legacy ──────────────────────────────
  -- ON DELETE CASCADE sur : lessons, quizzes, formation_modules.
  -- Et quizzes → CASCADE sur questions, choices, quiz_attempts,
  -- quiz_question_bank.
  WITH deleted AS (
    DELETE FROM public.modules m
    USING public.formation_modules fm
    WHERE fm.module_id = m.id
      AND fm.formation_id = v_formation
      AND m.slug NOT IN (
        'capa-droit-civil-commercial',
        'capa-activite-commerciale',
        'capa-cadre-reglementaire',
        'capa-activite-financiere',
        'capa-salaries-droit-social',
        'capa-securite'
      )
    RETURNING m.id
  )
  SELECT count(*) INTO v_deleted_modules FROM deleted;
  RAISE NOTICE '   ✓ Modules legacy supprimés : %', v_deleted_modules;

  -- ─── 2. Suppression des quizzes orphelins ───────────────────────────
  -- Un quiz devient orphelin si son module_id est NULL ou pointe vers
  -- un module qui n'existe plus (rare car cascade, mais possible si
  -- contrainte FK manquante ou import désordonné dans le passé).
  WITH deleted AS (
    DELETE FROM public.quizzes q
    WHERE q.module_id IS NULL
       OR q.module_id NOT IN (SELECT id FROM public.modules)
    RETURNING q.id
  )
  SELECT count(*) INTO v_deleted_orphan_quizzes FROM deleted;
  RAISE NOTICE '   ✓ Quizzes orphelins supprimés : %', v_deleted_orphan_quizzes;

  -- ─── 3. Suppression des leçons orphelines ──────────────────────────
  WITH deleted AS (
    DELETE FROM public.lessons l
    WHERE l.module_id IS NULL
       OR l.module_id NOT IN (SELECT id FROM public.modules)
    RETURNING l.id
  )
  SELECT count(*) INTO v_deleted_orphan_lessons FROM deleted;
  RAISE NOTICE '   ✓ Leçons orphelines supprimées : %', v_deleted_orphan_lessons;

  -- ─── 4. Suppression des questions legacy (table question_bank) ──────
  -- On supprime toutes les question_bank de la formation capa-3-5t qui
  -- n'ont PAS le préfixe v2 'mft-2026:'.
  -- Cascade sur quiz_question_bank et exam_attempts.
  WITH deleted AS (
    DELETE FROM public.question_bank
    WHERE formation_id = v_formation
      AND (source_ref IS NULL OR source_ref NOT LIKE 'mft-2026:%')
    RETURNING id
  )
  SELECT count(*) INTO v_deleted_qb_questions FROM deleted;
  RAISE NOTICE '   ✓ Questions legacy (banque) supprimées : %', v_deleted_qb_questions;

  -- ─── 5. Suppression des liens quiz_question_bank orphelins ─────────
  -- Si un lien pointe vers un quiz inexistant ou une question inexistante.
  WITH deleted AS (
    DELETE FROM public.quiz_question_bank qqb
    WHERE qqb.quiz_id NOT IN (SELECT id FROM public.quizzes)
       OR qqb.question_id NOT IN (SELECT id FROM public.question_bank)
    RETURNING qqb.quiz_id
  )
  SELECT count(*) INTO v_deleted_qqb_links FROM deleted;
  RAISE NOTICE '   ✓ Liens quiz_question_bank orphelins supprimés : %', v_deleted_qqb_links;

  -- ─── 6. Suppression des questions orphelines (table legacy) ────────
  -- La table 'questions' (différente de question_bank) est l'ancien
  -- modèle où les questions étaient directement attachées au quiz.
  -- Cascade depuis quizzes les nettoie déjà, mais on s'assure.
  WITH deleted AS (
    DELETE FROM public.questions q
    WHERE q.quiz_id NOT IN (SELECT id FROM public.quizzes)
    RETURNING q.id
  )
  SELECT count(*) INTO v_deleted_orphan_questions FROM deleted;
  RAISE NOTICE '   ✓ Questions orphelines (table legacy) supprimées : %', v_deleted_orphan_questions;

  -- ─── 7. Vérification finale ────────────────────────────────────────
  SELECT count(*) INTO v_kept_modules
  FROM public.modules m
  JOIN public.formation_modules fm ON fm.module_id = m.id
  WHERE fm.formation_id = v_formation;

  SELECT count(*) INTO v_kept_quizzes
  FROM public.quizzes q
  JOIN public.modules m ON m.id = q.module_id
  JOIN public.formation_modules fm ON fm.module_id = m.id
  WHERE fm.formation_id = v_formation;

  SELECT count(*) INTO v_kept_qb_questions
  FROM public.question_bank
  WHERE formation_id = v_formation
    AND source_ref LIKE 'mft-2026:%';

  RAISE NOTICE '════════════════════════════════════════════════════════════';
  RAISE NOTICE '🎯 RÉSULTAT FINAL pour la formation Capa ≤ 3,5 T :';
  RAISE NOTICE '   ▸ Modules conservés    : % (attendu : 6)', v_kept_modules;
  RAISE NOTICE '   ▸ Quizzes conservés    : % (attendu : ~30)', v_kept_quizzes;
  RAISE NOTICE '   ▸ Questions conservées : % (attendu : ~185)', v_kept_qb_questions;
  RAISE NOTICE '════════════════════════════════════════════════════════════';

  IF v_kept_modules <> 6 THEN
    RAISE WARNING '⚠️ Anomalie : % modules conservés au lieu de 6. Vérifier que les 6 fichiers v2 ont bien été joués.', v_kept_modules;
  END IF;

  IF v_kept_quizzes < 25 OR v_kept_quizzes > 35 THEN
    RAISE WARNING '⚠️ Anomalie : % quizzes conservés (attendu entre 25 et 35).', v_kept_quizzes;
  END IF;

  IF v_kept_qb_questions < 150 THEN
    RAISE WARNING '⚠️ Anomalie : seulement % questions v2 (attendu ≥ 150). Vérifier les v2.', v_kept_qb_questions;
  END IF;
END
$cleanup$;
