-- ============================================================
-- Examen blanc officiel (Point #8)
--   - Flags sur quizzes (mock, tentatives, délai, shuffle, fullscreen)
--   - Mode + tracking anti-triche sur quiz_attempts
--   - Fonction check_attempt_state : tentatives restantes + délai
-- ============================================================

-- ------------------------------------------------------------
-- 1. Extensions quizzes
-- ------------------------------------------------------------
ALTER TABLE public.quizzes
  ADD COLUMN IF NOT EXISTS is_mock_exam boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS max_attempts int,
  ADD COLUMN IF NOT EXISTS retake_delay_hours int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS shuffle_questions boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS shuffle_choices boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS require_fullscreen boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS show_explanations_mode text NOT NULL DEFAULT 'always';

-- Contrainte sur le mode d'affichage des corrections
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'quizzes_show_exp_check'
  ) THEN
    ALTER TABLE public.quizzes
      ADD CONSTRAINT quizzes_show_exp_check
      CHECK (show_explanations_mode IN ('always', 'after_pass', 'never'));
  END IF;
END $$;

-- ------------------------------------------------------------
-- 2. Extensions quiz_attempts
-- ------------------------------------------------------------
ALTER TABLE public.quiz_attempts
  ADD COLUMN IF NOT EXISTS focus_loss_count int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS mode text NOT NULL DEFAULT 'entrainement';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'attempts_mode_check'
  ) THEN
    ALTER TABLE public.quiz_attempts
      ADD CONSTRAINT attempts_mode_check
      CHECK (mode IN ('entrainement', 'examen', 'blanc'));
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS attempts_user_quiz_idx
  ON public.quiz_attempts(user_id, quiz_id, finished_at DESC);

-- ------------------------------------------------------------
-- 3. Fonction : état des tentatives pour un stagiaire
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.quiz_attempt_state(
  p_quiz_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_quiz record;
  v_count int;
  v_last timestamptz;
  v_next_available timestamptz;
  v_allowed boolean := true;
  v_reason text := null;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('allowed', false, 'reason', 'anon');
  END IF;

  SELECT id, max_attempts, retake_delay_hours, is_mock_exam
    INTO v_quiz
    FROM public.quizzes WHERE id = p_quiz_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('allowed', false, 'reason', 'not_found');
  END IF;

  SELECT count(*), max(finished_at)
    INTO v_count, v_last
    FROM public.quiz_attempts
   WHERE user_id = v_uid
     AND quiz_id = p_quiz_id
     AND finished_at IS NOT NULL;

  IF v_quiz.max_attempts IS NOT NULL AND v_count >= v_quiz.max_attempts THEN
    v_allowed := false;
    v_reason := 'max_attempts';
  END IF;

  IF v_quiz.retake_delay_hours > 0 AND v_last IS NOT NULL THEN
    v_next_available := v_last + (v_quiz.retake_delay_hours || ' hours')::interval;
    IF v_next_available > now() AND v_allowed THEN
      v_allowed := false;
      v_reason := 'retake_delay';
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'allowed', v_allowed,
    'reason', v_reason,
    'attempts_used', v_count,
    'attempts_max', v_quiz.max_attempts,
    'next_available_at', v_next_available,
    'last_attempt_at', v_last
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.quiz_attempt_state(uuid) TO authenticated;
