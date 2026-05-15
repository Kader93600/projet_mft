-- =====================================================================
-- 2026-05-16 · QR-only scoring + fix notifications formateur
--
-- Deux bugs sur les quiz qui ne contiennent QUE des questions rédigées
-- (aucun QCM) :
--
-- Bug #1 (visible) — Mauvaise pondération
--   Le calcul appliquait toujours 70 % QCM + 30 % QR, même quand le quiz
--   n'avait aucun QCM. Résultat : un stagiaire qui obtient 2,75/8 (34 %)
--   se voit attribuer 10 % final (0,7 × 0 + 0,3 × 34 = 10).
--   → Si qcm_score IS NULL et qu'il y a des QR, on fait 100 % QR.
--
-- Bug #2 (silencieux) — Notification "Copie à corriger" jamais envoyée
--   mark_attempt_awaiting_review insérait type='info' mais la CHECK
--   constraint sur notifications.type n'autorise que
--   ('announcement','message','system','quiz_result'). L'erreur était
--   avalée par le bloc EXCEPTION → les formateurs ne recevaient JAMAIS
--   les notifications de nouvelles copies à corriger.
--   → Utilisation de 'system' (la copie est une notif système).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Fix finalize_quiz_grading : pondération QR-only
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.finalize_quiz_grading(
  p_attempt uuid,
  p_global_comment text DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_qcm numeric;
  v_qr_total numeric;
  v_qr_max numeric;
  v_pct numeric;
  v_pass_threshold numeric;
  v_passed boolean;
  v_attempt_owner uuid;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'unauthenticated'; END IF;
  IF NOT (public.is_trainer() OR public.is_admin()) THEN
    RAISE EXCEPTION 'must_be_trainer_or_admin';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.qr_responses
    WHERE attempt_id = p_attempt AND graded_at IS NULL
  ) THEN
    RAISE EXCEPTION 'qr_responses_pending';
  END IF;

  SELECT a.qcm_score, a.user_id, q.pass_threshold
  INTO v_qcm, v_attempt_owner, v_pass_threshold
  FROM public.quiz_attempts a
  JOIN public.quizzes q ON q.id = a.quiz_id
  WHERE a.id = p_attempt;
  IF v_attempt_owner IS NULL THEN RAISE EXCEPTION 'attempt_not_found'; END IF;

  SELECT
    coalesce(sum(trainer_score), 0),
    coalesce(sum(max_score), 0)
  INTO v_qr_total, v_qr_max
  FROM public.qr_responses WHERE attempt_id = p_attempt;

  -- Pondération adaptative :
  --   QR-only   (qcm_score IS NULL)   → 100 % QR
  --   Mixte     (qcm_score + QR)      → 70 % QCM + 30 % QR
  --   QCM-only  (pas de QR)           → 100 % QCM
  IF v_qcm IS NULL AND v_qr_max > 0 THEN
    v_pct := v_qr_total / v_qr_max * 100;
  ELSIF v_qr_max > 0 THEN
    v_pct := 0.7 * coalesce(v_qcm, 0) + 0.3 * (v_qr_total / v_qr_max * 100);
  ELSE
    v_pct := coalesce(v_qcm, 0);
  END IF;

  v_pct := round(v_pct::numeric, 1);
  v_passed := v_pct >= coalesce(v_pass_threshold, 70);

  UPDATE public.quiz_attempts
  SET status = 'graded',
      qr_score = v_qr_total,
      final_percentage = v_pct,
      final_passed = v_passed,
      percentage = v_pct,
      passed = v_passed,
      graded_at = now(),
      graded_by = v_uid,
      trainer_global_comment = COALESCE(p_global_comment, trainer_global_comment)
  WHERE id = p_attempt;

  BEGIN
    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    VALUES (
      v_attempt_owner,
      'quiz_result',
      'Votre copie a été corrigée',
      'Découvrez votre note et les commentaires du formateur.',
      '/quiz/results/' || p_attempt::text
    );
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;
END;
$$;

GRANT EXECUTE ON FUNCTION public.finalize_quiz_grading(uuid, text)
  TO authenticated;

-- ---------------------------------------------------------------------
-- 2) Fix mark_attempt_awaiting_review : type notif autorisé par CHECK
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.mark_attempt_awaiting_review(
  p_attempt uuid,
  p_qcm_score numeric DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_attempt_owner uuid;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'unauthenticated'; END IF;

  SELECT user_id INTO v_attempt_owner
  FROM public.quiz_attempts WHERE id = p_attempt;
  IF v_attempt_owner != v_uid THEN RAISE EXCEPTION 'forbidden'; END IF;

  UPDATE public.quiz_attempts
  SET status = 'awaiting_review',
      qcm_score = COALESCE(p_qcm_score, qcm_score),
      finished_at = COALESCE(finished_at, now())
  WHERE id = p_attempt;

  -- Notification aux formateurs habilités (type='system' = autorisé par CHECK)
  BEGIN
    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    SELECT
      tf.trainer_id,
      'system',
      'Copie à corriger',
      'Une nouvelle copie est en attente de correction.',
      '/formateur/corrections/' || p_attempt::text
    FROM public.quiz_attempts a
    JOIN public.quizzes q ON q.id = a.quiz_id
    JOIN public.formation_quizzes fq ON fq.quiz_id = q.id
    JOIN public.trainer_formations tf ON tf.formation_id = fq.formation_id
    WHERE a.id = p_attempt
      AND tf.can_grade = true;
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;
END;
$$;

GRANT EXECUTE ON FUNCTION public.mark_attempt_awaiting_review(uuid, numeric)
  TO authenticated;

-- ---------------------------------------------------------------------
-- 3) Vérification post-migration
-- ---------------------------------------------------------------------
DO $$
BEGIN
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Fix QR-only scoring + notifications formateur';
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE '  finalize_quiz_grading : pondération adaptative';
  RAISE NOTICE '    • QR-only   → 100 %% QR';
  RAISE NOTICE '    • Mixte     → 70 %% QCM + 30 %% QR';
  RAISE NOTICE '    • QCM-only  → 100 %% QCM';
  RAISE NOTICE '  mark_attempt_awaiting_review : type notif "system"';
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;
