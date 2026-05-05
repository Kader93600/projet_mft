-- =====================================================================
-- NETTOYAGE COMPLET — Modules / Quizzes / Examens / Questions LEGACY
-- de la formation GOTRM (RNCP 40990) qui ont été ou seront remplacés
-- par les versions v2.
--
-- À jouer UNE FOIS dans Supabase Studio → SQL Editor :
--   - SOIT après avoir joué les 14 fichiers gotrm_module_X_v2.sql
--     (cleanup ciblé sur les slugs hors liste blanche)
--   - SOIT avant pour repartir sur une base totalement vide pour GOTRM
--     (en commentant l'AND m.slug NOT IN (...) pour tout effacer).
--
-- Conserve uniquement les 14 modules v2 :
--   BC01 (10 modules) :
--     - gotrm-bc01-01-demande-transport
--     - gotrm-bc01-02-contrat-cmr
--     - gotrm-bc01-03-cotation-offre
--     - gotrm-bc01-04-temps-conduite-r561
--     - gotrm-bc01-05-documents-douane
--     - gotrm-bc01-06-planification-tournees
--     - gotrm-bc01-07-transports-specifiques
--     - gotrm-bc01-08-relation-client-qualite
--     - gotrm-bc01-09-litiges-indemnisation
--     - gotrm-bc01-10-kpi-exploitation
--   BC02 (2 modules) :
--     - gotrm-bc02-01-appels-offres-soustraitance
--     - gotrm-bc02-02-suivi-audit-soustraitants
--   BC03 (2 modules) :
--     - gotrm-bc03-01-cout-revient-rentabilite
--     - gotrm-bc03-02-rse-transition-energetique
--
-- COUVRE :
--   ✓ Modules legacy
--   ✓ Quizzes attachés (cascade) + quizzes orphelins
--   ✓ Examens blancs legacy (mêmes tables que les quizzes)
--   ✓ Questions legacy de question_bank (source_ref ≠ mft-2026-gotrm:%)
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
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation gotrm introuvable.';
  END IF;

  RAISE NOTICE '🧹 Démarrage du cleanup GOTRM (RNCP 40990)...';

  -- ─── 1. Modules legacy ─────────────────────────────────────────────
  WITH deleted AS (
    DELETE FROM public.modules m
    USING public.formation_modules fm
    WHERE fm.module_id = m.id
      AND fm.formation_id = v_formation
      AND m.slug NOT IN (
        'gotrm-bc01-01-demande-transport',
        'gotrm-bc01-02-contrat-cmr',
        'gotrm-bc01-03-cotation-offre',
        'gotrm-bc01-04-temps-conduite-r561',
        'gotrm-bc01-05-documents-douane',
        'gotrm-bc01-06-planification-tournees',
        'gotrm-bc01-07-transports-specifiques',
        'gotrm-bc01-08-relation-client-qualite',
        'gotrm-bc01-09-litiges-indemnisation',
        'gotrm-bc01-10-kpi-exploitation',
        'gotrm-bc02-01-appels-offres-soustraitance',
        'gotrm-bc02-02-suivi-audit-soustraitants',
        'gotrm-bc03-01-cout-revient-rentabilite',
        'gotrm-bc03-02-rse-transition-energetique'
      )
    RETURNING m.id
  )
  SELECT count(*) INTO v_deleted_modules FROM deleted;
  RAISE NOTICE '   ✓ Modules legacy supprimés : %', v_deleted_modules;

  -- ─── 2. Quizzes orphelins ──────────────────────────────────────────
  WITH deleted AS (
    DELETE FROM public.quizzes q
    WHERE q.module_id IS NULL
       OR q.module_id NOT IN (SELECT id FROM public.modules)
    RETURNING q.id
  )
  SELECT count(*) INTO v_deleted_orphan_quizzes FROM deleted;
  RAISE NOTICE '   ✓ Quizzes orphelins supprimés : %', v_deleted_orphan_quizzes;

  -- ─── 3. Leçons orphelines ──────────────────────────────────────────
  WITH deleted AS (
    DELETE FROM public.lessons l
    WHERE l.module_id IS NULL
       OR l.module_id NOT IN (SELECT id FROM public.modules)
    RETURNING l.id
  )
  SELECT count(*) INTO v_deleted_orphan_lessons FROM deleted;
  RAISE NOTICE '   ✓ Leçons orphelines supprimées : %', v_deleted_orphan_lessons;

  -- ─── 4. Questions legacy (banque) ──────────────────────────────────
  -- Préfixe v2 GOTRM = mft-2026-gotrm:
  WITH deleted AS (
    DELETE FROM public.question_bank
    WHERE formation_id = v_formation
      AND (source_ref IS NULL OR source_ref NOT LIKE 'mft-2026-gotrm:%')
    RETURNING id
  )
  SELECT count(*) INTO v_deleted_qb_questions FROM deleted;
  RAISE NOTICE '   ✓ Questions legacy (banque) supprimées : %', v_deleted_qb_questions;

  -- ─── 5. Liens quiz_question_bank orphelins ─────────────────────────
  WITH deleted AS (
    DELETE FROM public.quiz_question_bank qqb
    WHERE qqb.quiz_id NOT IN (SELECT id FROM public.quizzes)
       OR qqb.question_id NOT IN (SELECT id FROM public.question_bank)
    RETURNING qqb.quiz_id
  )
  SELECT count(*) INTO v_deleted_qqb_links FROM deleted;
  RAISE NOTICE '   ✓ Liens quiz_question_bank orphelins supprimés : %', v_deleted_qqb_links;

  -- ─── 6. Questions orphelines (table legacy) ────────────────────────
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
    AND source_ref LIKE 'mft-2026-gotrm:%';

  RAISE NOTICE '════════════════════════════════════════════════════════════';
  RAISE NOTICE '🎯 RÉSULTAT FINAL pour la formation GOTRM :';
  RAISE NOTICE '   ▸ Modules conservés    : % (cible : 14)', v_kept_modules;
  RAISE NOTICE '   ▸ Quizzes conservés    : % (cible finale : ~70)', v_kept_quizzes;
  RAISE NOTICE '   ▸ Questions conservées : % (cible finale : ~450)', v_kept_qb_questions;
  RAISE NOTICE '════════════════════════════════════════════════════════════';
END
$cleanup$;
