-- =====================================================================
-- 2026-05-16 · Recompute one-shot des tentatives QR-only
--
-- Contexte : avant le fix 2026-05-16, finalize_quiz_grading appliquait
-- toujours la pondération 70 % QCM + 30 % QR, même quand le quiz ne
-- contenait AUCUN QCM. Conséquence : un stagiaire qui obtient 2,75/8
-- (34 %) se voyait attribuer 10 % final. Le bug est corrigé pour les
-- prochaines tentatives, mais les tentatives DÉJÀ finalisées en base
-- conservent leur ancien score erroné.
--
-- Ce script :
--   1) Identifie les tentatives "graded" dont le quiz n'a aucun QCM
--      (ni dans la table legacy `questions`, ni dans `quiz_question_bank`
--      jointe à `question_bank.type = 'qcm'`).
--   2) Recalcule final_percentage / final_passed / percentage / passed
--      avec la formule QR-only (100 % QR).
--   3) Met aussi qcm_score à NULL pour ces tentatives (sémantique correcte :
--      pas de score QCM puisqu'il n'y a pas de QCM dans le quiz).
--
-- Idempotent : peut être rejoué sans risque.
-- =====================================================================

DO $$
DECLARE
  v_count_before int;
  v_count_after int;
  v_count_capped int;
BEGIN
  -- ─────────────────────────────────────────────────────────────────
  -- 1) Diagnostic AVANT
  -- ─────────────────────────────────────────────────────────────────
  SELECT count(*) INTO v_count_before
  FROM public.quiz_attempts a
  WHERE a.status = 'graded'
    AND EXISTS (SELECT 1 FROM public.qr_responses r WHERE r.attempt_id = a.id)
    AND a.qcm_score = 0
    AND NOT EXISTS (
      SELECT 1 FROM public.questions q WHERE q.quiz_id = a.quiz_id
    )
    AND NOT EXISTS (
      SELECT 1
      FROM public.quiz_question_bank qqb
      JOIN public.question_bank qb ON qb.id = qqb.question_id
      WHERE qqb.quiz_id = a.quiz_id AND qb.type = 'qcm'
    );

  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Recompute tentatives QR-only — début';
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE '  Tentatives à recalculer : %', v_count_before;

  -- ─────────────────────────────────────────────────────────────────
  -- 2) Recompute
  -- ─────────────────────────────────────────────────────────────────
  WITH qr_only_attempts AS (
    SELECT
      a.id                   AS attempt_id,
      a.quiz_id,
      q.pass_threshold,
      COALESCE(sum(r.trainer_score), 0) AS qr_total,
      COALESCE(sum(r.max_score), 0)     AS qr_max
    FROM public.quiz_attempts a
    JOIN public.quizzes q     ON q.id = a.quiz_id
    JOIN public.qr_responses r ON r.attempt_id = a.id
    WHERE a.status = 'graded'
      AND a.qcm_score = 0
      AND NOT EXISTS (
        SELECT 1 FROM public.questions qq WHERE qq.quiz_id = a.quiz_id
      )
      AND NOT EXISTS (
        SELECT 1
        FROM public.quiz_question_bank qqb
        JOIN public.question_bank qb ON qb.id = qqb.question_id
        WHERE qqb.quiz_id = a.quiz_id AND qb.type = 'qcm'
      )
    GROUP BY a.id, a.quiz_id, q.pass_threshold
  ),
  recomputed AS (
    SELECT
      attempt_id,
      qr_total,
      qr_max,
      pass_threshold,
      CASE
        WHEN qr_max > 0 THEN round((qr_total / qr_max * 100)::numeric, 1)
        ELSE 0
      END AS new_pct
    FROM qr_only_attempts
  )
  UPDATE public.quiz_attempts a
  SET
    qcm_score        = NULL,
    qr_score         = rc.qr_total,
    final_percentage = rc.new_pct,
    final_passed     = rc.new_pct >= COALESCE(rc.pass_threshold, 70),
    percentage       = rc.new_pct,
    passed           = rc.new_pct >= COALESCE(rc.pass_threshold, 70)
  FROM recomputed rc
  WHERE a.id = rc.attempt_id;

  GET DIAGNOSTICS v_count_after = ROW_COUNT;

  -- ─────────────────────────────────────────────────────────────────
  -- 3) Cas particulier : tentatives "awaiting_review" en attente
  --     → on remet aussi leur qcm_score à NULL pour cohérence (n'affecte
  --       que l'affichage, pas la note finale qui n'est pas encore calculée).
  -- ─────────────────────────────────────────────────────────────────
  UPDATE public.quiz_attempts a
  SET qcm_score = NULL
  WHERE a.status = 'awaiting_review'
    AND a.qcm_score = 0
    AND NOT EXISTS (
      SELECT 1 FROM public.questions q WHERE q.quiz_id = a.quiz_id
    )
    AND NOT EXISTS (
      SELECT 1
      FROM public.quiz_question_bank qqb
      JOIN public.question_bank qb ON qb.id = qqb.question_id
      WHERE qqb.quiz_id = a.quiz_id AND qb.type = 'qcm'
    );

  GET DIAGNOSTICS v_count_capped = ROW_COUNT;

  -- ─────────────────────────────────────────────────────────────────
  -- 4) Diagnostic APRÈS
  -- ─────────────────────────────────────────────────────────────────
  RAISE NOTICE '  Tentatives recalculées (graded) ... %', v_count_after;
  RAISE NOTICE '  Tentatives nettoyées (awaiting)  ... %', v_count_capped;
  RAISE NOTICE '────────────────────────────────────────────────────────';

  IF v_count_after != v_count_before THEN
    RAISE WARNING 'Mismatch entre diagnostic (% ) et UPDATE (% ) — vérifier manuellement',
      v_count_before, v_count_after;
  ELSE
    RAISE NOTICE '  ✓ Recompute terminé avec succès';
  END IF;
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;

-- ---------------------------------------------------------------------
-- 5) Aperçu post-migration (info, ne modifie rien)
--    Affiche les 10 tentatives QR-only les plus récentes.
-- ---------------------------------------------------------------------
DO $$
DECLARE
  rec record;
BEGIN
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Aperçu : 10 dernières tentatives QR-only recalculées';
  RAISE NOTICE '────────────────────────────────────────────────────────';
  FOR rec IN
    SELECT
      a.id,
      p.email AS student,
      q.title AS quiz,
      a.qr_score,
      a.final_percentage,
      a.final_passed
    FROM public.quiz_attempts a
    JOIN public.profiles p ON p.id = a.user_id
    JOIN public.quizzes q  ON q.id = a.quiz_id
    WHERE a.status = 'graded'
      AND a.qcm_score IS NULL
      AND EXISTS (SELECT 1 FROM public.qr_responses r WHERE r.attempt_id = a.id)
    ORDER BY a.graded_at DESC NULLS LAST
    LIMIT 10
  LOOP
    RAISE NOTICE '  % | %  → % %% (passé : %)',
      rpad(rec.student, 30),
      rpad(rec.quiz, 25),
      rec.final_percentage,
      rec.final_passed;
  END LOOP;
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;
