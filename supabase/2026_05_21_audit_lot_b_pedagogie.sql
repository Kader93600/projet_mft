-- =====================================================================
-- AUDIT LOT B — Corrections pédagogiques
-- 2026-05-20
--
-- #4 — Notification "copie à corriger" jamais envoyée pour les
--      examens blancs rattachés à un MODULE (et non via formation_quizzes)
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- #4 — mark_attempt_awaiting_review : couvrir les 2 chemins de
--      rattachement quiz → formation
-- ─────────────────────────────────────────────────────────────────────
-- Avant : la notification aux formateurs joignait UNIQUEMENT via
-- formation_quizzes. Or les examens blancs de bloc sont rattachés via
-- quizzes.module_id → formation_modules. Pour ces quiz, le JOIN ne
-- ramenait rien → aucun formateur notifié → copie QR jamais corrigée
-- (orpheline de fait). Le bloc EXCEPTION WHEN OTHERS masquait le tout.
--
-- Fix : on résout les formation_id du quiz par les DEUX chemins
-- (formation_quizzes OU module → formation_modules), puis on notifie
-- tous les formateurs habilités (can_grade) de ces formations.

CREATE OR REPLACE FUNCTION public.mark_attempt_awaiting_review(
  p_attempt uuid,
  p_qcm_score numeric DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_attempt_owner uuid;
  v_quiz uuid;
  v_module uuid;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'unauthenticated'; END IF;

  SELECT user_id, quiz_id INTO v_attempt_owner, v_quiz
  FROM public.quiz_attempts WHERE id = p_attempt;
  IF v_attempt_owner != v_uid THEN RAISE EXCEPTION 'forbidden'; END IF;

  UPDATE public.quiz_attempts
  SET status = 'awaiting_review',
      qcm_score = COALESCE(p_qcm_score, qcm_score),
      finished_at = COALESCE(finished_at, now())
  WHERE id = p_attempt;

  SELECT module_id INTO v_module FROM public.quizzes WHERE id = v_quiz;

  -- Notification aux formateurs habilités, via les 2 chemins de
  -- rattachement, dédupliqués (DISTINCT).
  BEGIN
    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    SELECT DISTINCT
      tf.trainer_id,
      'system',
      'Copie à corriger',
      'Une nouvelle copie est en attente de correction.',
      '/formateur/corrections/' || p_attempt::text
    FROM public.trainer_formations tf
    WHERE tf.can_grade = true
      AND (
        -- Chemin 1 : quiz global rattaché via formation_quizzes
        tf.formation_id IN (
          SELECT fq.formation_id
          FROM public.formation_quizzes fq
          WHERE fq.quiz_id = v_quiz
        )
        OR
        -- Chemin 2 : quiz de bloc rattaché via module → formation_modules
        (v_module IS NOT NULL AND tf.formation_id IN (
          SELECT fm.formation_id
          FROM public.formation_modules fm
          WHERE fm.module_id = v_module
        ))
      );
  EXCEPTION WHEN OTHERS THEN
    -- On loggue mais on ne bloque pas la mise en awaiting_review
    RAISE WARNING 'mark_attempt_awaiting_review notif failed: %', SQLERRM;
  END;
END;
$$;

GRANT EXECUTE ON FUNCTION public.mark_attempt_awaiting_review(uuid, numeric)
  TO authenticated;

DO $$
BEGIN
  RAISE NOTICE '════════ AUDIT LOT B — Pédagogie ════════';
  RAISE NOTICE '  mark_attempt_awaiting_review : notifie via formation_quizzes';
  RAISE NOTICE '  ET via module → formation_modules (examens de bloc)';
  RAISE NOTICE '═════════════════════════════════════════';
END $$;
