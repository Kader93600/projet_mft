-- =====================================================================
-- 2026-05-16 · Fix finalize_quiz_grading
--
-- Bug #1 (critique) : la variable PL/pgSQL "passed" (boolean) entre en
--   conflit de nommage avec la colonne quiz_attempts.passed. Postgres
--   rejette l'UPDATE avec "column reference passed is ambiguous", ce qui
--   fait échouer la finalisation côté formateur (page de correction).
--   → Renommage en v_passed (et autres locales en v_* pour la cohérence).
--
-- Bug #2 (silencieux) : la notification utilisait type='success' alors
--   que la CHECK constraint sur notifications.type n'autorise que
--   ('announcement', 'message', 'system', 'quiz_result').
--   → Utilisation de 'quiz_result' (sémantiquement correct).
-- =====================================================================

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

  -- Toutes les QR doivent être corrigées
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

  -- Cumul QR
  SELECT
    coalesce(sum(trainer_score), 0),
    coalesce(sum(max_score), 0)
  INTO v_qr_total, v_qr_max
  FROM public.qr_responses WHERE attempt_id = p_attempt;

  -- Score total : QCM auto + QR manuel
  -- 70% QCM + 30% QR si présence de QR, sinon 100% QCM.
  IF v_qr_max > 0 THEN
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
      percentage = v_pct,         -- compat affichages existants
      passed = v_passed,          -- compat affichages existants
      graded_at = now(),
      graded_by = v_uid,
      trainer_global_comment = COALESCE(p_global_comment, trainer_global_comment)
  WHERE id = p_attempt;

  -- Notifier le stagiaire (type 'quiz_result' = valeur autorisée par CHECK)
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

-- Vérification post-migration
DO $$
DECLARE
  v_signature text;
BEGIN
  SELECT pg_get_function_identity_arguments(p.oid)
    INTO v_signature
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = 'public' AND p.proname = 'finalize_quiz_grading';

  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Fix finalize_quiz_grading appliqué';
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE '  Signature : %', v_signature;
  RAISE NOTICE '  Variables locales renommées en v_* (plus de conflit)';
  RAISE NOTICE '  Notification type : quiz_result (au lieu de success)';
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;
