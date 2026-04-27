-- =====================================================================
-- Workflow correction différée pour les questions rédigées (QR)
--
-- Principe :
--   1) Le stagiaire termine un quiz contenant des QR
--   2) Le score auto QCM est calculé immédiatement, mais le stagiaire
--      voit "En attente de correction" — pas de note finale
--   3) Le formateur habilité corrige chaque QR (note + commentaire)
--   4) Le formateur "finalise" la copie → note totale calculée, statut
--      passé à 'graded', le stagiaire reçoit une notification
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Statut enrichi sur quiz_attempts
-- ---------------------------------------------------------------------
ALTER TABLE public.quiz_attempts
  ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'completed'
    CHECK (status IN ('in_progress', 'completed', 'awaiting_review', 'graded')),
  ADD COLUMN IF NOT EXISTS qcm_score numeric,        -- score auto sur les QCM
  ADD COLUMN IF NOT EXISTS qr_score numeric,         -- score manuel cumulé sur les QR
  ADD COLUMN IF NOT EXISTS final_percentage numeric, -- (qcm_score + qr_score) / max
  ADD COLUMN IF NOT EXISTS final_passed boolean,
  ADD COLUMN IF NOT EXISTS graded_at timestamptz,
  ADD COLUMN IF NOT EXISTS graded_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS trainer_global_comment text;

-- Backfill : les anciennes tentatives finies sans QR sont 'graded'
UPDATE public.quiz_attempts
SET status = 'graded'
WHERE status = 'completed'
  AND finished_at IS NOT NULL;

-- ---------------------------------------------------------------------
-- 2) Réponses des QR (1 ligne par QR de chaque tentative)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.qr_responses (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  attempt_id uuid NOT NULL REFERENCES public.quiz_attempts(id) ON DELETE CASCADE,
  question_id uuid NOT NULL REFERENCES public.question_bank(id) ON DELETE CASCADE,

  -- Réponse rédigée du stagiaire
  student_answer text,

  -- Correction par le formateur
  trainer_score numeric,        -- 0 → max_score
  max_score numeric NOT NULL DEFAULT 1,
  trainer_comment text,
  graded_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  graded_at timestamptz,

  submitted_at timestamptz NOT NULL DEFAULT now(),

  UNIQUE (attempt_id, question_id)
);

CREATE INDEX IF NOT EXISTS qr_responses_attempt_idx
  ON public.qr_responses(attempt_id);
CREATE INDEX IF NOT EXISTS qr_responses_pending_idx
  ON public.qr_responses(attempt_id)
  WHERE graded_at IS NULL;

ALTER TABLE public.qr_responses ENABLE ROW LEVEL SECURITY;

-- Lecture stagiaire : ses propres réponses, mais score/commentaire visibles
-- UNIQUEMENT si la copie est gradée (status='graded' sur l'attempt parent)
DROP POLICY IF EXISTS qr_responses_self_read ON public.qr_responses;
CREATE POLICY qr_responses_self_read ON public.qr_responses
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.quiz_attempts a
      WHERE a.id = qr_responses.attempt_id
        AND a.user_id = auth.uid()
    )
  );

-- Lecture formateur : copies des stagiaires des formations qu'il encadre
DROP POLICY IF EXISTS qr_responses_trainer_read ON public.qr_responses;
CREATE POLICY qr_responses_trainer_read ON public.qr_responses
  FOR SELECT USING (
    public.is_trainer() OR public.is_admin()
  );

-- Insertion : faite par RPC `submit_quiz_attempt` (SECURITY DEFINER), pas par le client.
-- Modification : staff/formateur via RPC `grade_qr_response`.
-- On ferme donc INSERT/UPDATE/DELETE direct au stagiaire.

-- ---------------------------------------------------------------------
-- 3) RPC : enregistrer une réponse QR (lors du submit du quiz)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.submit_qr_response(
  p_attempt uuid,
  p_question uuid,
  p_answer text
) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  uid uuid := auth.uid();
  attempt_owner uuid;
  q_max numeric;
  resp_id uuid;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'unauthenticated'; END IF;

  SELECT user_id INTO attempt_owner
  FROM public.quiz_attempts WHERE id = p_attempt;
  IF attempt_owner IS NULL THEN
    RAISE EXCEPTION 'attempt_not_found';
  END IF;
  IF attempt_owner != uid THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  SELECT max_score INTO q_max
  FROM public.question_bank WHERE id = p_question AND type = 'qr';
  IF q_max IS NULL THEN
    RAISE EXCEPTION 'qr_question_not_found';
  END IF;

  INSERT INTO public.qr_responses (attempt_id, question_id, student_answer, max_score)
  VALUES (p_attempt, p_question, p_answer, q_max)
  ON CONFLICT (attempt_id, question_id) DO UPDATE
    SET student_answer = EXCLUDED.student_answer,
        submitted_at = now()
  RETURNING id INTO resp_id;

  RETURN resp_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_qr_response(uuid, uuid, text)
  TO authenticated;

-- ---------------------------------------------------------------------
-- 4) RPC : marquer une tentative en attente de correction
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.mark_attempt_awaiting_review(
  p_attempt uuid,
  p_qcm_score numeric DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  uid uuid := auth.uid();
  attempt_owner uuid;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'unauthenticated'; END IF;

  SELECT user_id INTO attempt_owner
  FROM public.quiz_attempts WHERE id = p_attempt;
  IF attempt_owner != uid THEN RAISE EXCEPTION 'forbidden'; END IF;

  UPDATE public.quiz_attempts
  SET status = 'awaiting_review',
      qcm_score = COALESCE(p_qcm_score, qcm_score),
      finished_at = COALESCE(finished_at, now())
  WHERE id = p_attempt;

  -- Notifier les formateurs habilités sur la formation correspondante
  -- (best-effort, ne bloque pas le submit en cas d'échec)
  BEGIN
    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    SELECT
      tf.trainer_id,
      'info',
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
    -- on ignore (notif non bloquante)
    NULL;
  END;
END;
$$;

GRANT EXECUTE ON FUNCTION public.mark_attempt_awaiting_review(uuid, numeric)
  TO authenticated;

-- ---------------------------------------------------------------------
-- 5) RPC : noter une réponse QR (formateur)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.grade_qr_response(
  p_response uuid,
  p_score numeric,
  p_comment text DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  uid uuid := auth.uid();
  q_max numeric;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'unauthenticated'; END IF;
  IF NOT (public.is_trainer() OR public.is_admin()) THEN
    RAISE EXCEPTION 'must_be_trainer_or_admin';
  END IF;

  SELECT max_score INTO q_max FROM public.qr_responses WHERE id = p_response;
  IF q_max IS NULL THEN RAISE EXCEPTION 'response_not_found'; END IF;
  IF p_score < 0 OR p_score > q_max THEN
    RAISE EXCEPTION 'score_out_of_range';
  END IF;

  UPDATE public.qr_responses
  SET trainer_score = p_score,
      trainer_comment = p_comment,
      graded_by = uid,
      graded_at = now()
  WHERE id = p_response;
END;
$$;

GRANT EXECUTE ON FUNCTION public.grade_qr_response(uuid, numeric, text)
  TO authenticated;

-- ---------------------------------------------------------------------
-- 6) RPC : finaliser la correction d'une tentative
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.finalize_quiz_grading(
  p_attempt uuid,
  p_global_comment text DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  uid uuid := auth.uid();
  qcm numeric;
  qr_total numeric;
  qr_max numeric;
  total numeric;
  total_max numeric;
  pct numeric;
  pass_threshold numeric;
  passed boolean;
  attempt_owner uuid;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'unauthenticated'; END IF;
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
  INTO qcm, attempt_owner, pass_threshold
  FROM public.quiz_attempts a
  JOIN public.quizzes q ON q.id = a.quiz_id
  WHERE a.id = p_attempt;
  IF attempt_owner IS NULL THEN RAISE EXCEPTION 'attempt_not_found'; END IF;

  -- Cumul QR
  SELECT
    coalesce(sum(trainer_score), 0),
    coalesce(sum(max_score), 0)
  INTO qr_total, qr_max
  FROM public.qr_responses WHERE attempt_id = p_attempt;

  -- Score total : QCM auto + QR manuel
  -- qcm_score est déjà en pourcentage (0-100) ; on le convertit en pondération
  -- en assumant que la pondération QCM représente (1 - qr_max/total_max)
  -- Plus simple : on utilise qcm_score comme % et on calcule un score final pondéré
  -- en supposant que QR vaut 30% si qr_max > 0 et 0% sinon. C'est un MVP — l'admin
  -- pourra définir un poids personnalisé plus tard.
  IF qr_max > 0 THEN
    -- 70% QCM + 30% QR (par défaut)
    pct := 0.7 * coalesce(qcm, 0) + 0.3 * (qr_total / qr_max * 100);
  ELSE
    pct := coalesce(qcm, 0);
  END IF;

  pct := round(pct::numeric, 1);
  passed := pct >= coalesce(pass_threshold, 70);

  UPDATE public.quiz_attempts
  SET status = 'graded',
      qr_score = qr_total,
      final_percentage = pct,
      final_passed = passed,
      percentage = pct,         -- compat affichages existants
      passed = passed,           -- compat affichages existants
      graded_at = now(),
      graded_by = uid,
      trainer_global_comment = COALESCE(p_global_comment, trainer_global_comment)
  WHERE id = p_attempt;

  -- Notifier le stagiaire
  BEGIN
    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    VALUES (
      attempt_owner,
      'success',
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
-- 7) Vue : copies en attente de correction (pour le formateur)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW public.pending_qr_corrections AS
SELECT
  a.id AS attempt_id,
  a.user_id AS student_id,
  p.full_name AS student_name,
  p.email AS student_email,
  a.quiz_id,
  q.title AS quiz_title,
  q.is_mock_exam,
  a.finished_at,
  a.status,
  fq.formation_id,
  f.slug AS formation_slug,
  f.code AS formation_code,
  (SELECT count(*) FROM public.qr_responses r
    WHERE r.attempt_id = a.id) AS qr_total,
  (SELECT count(*) FROM public.qr_responses r
    WHERE r.attempt_id = a.id AND r.graded_at IS NULL) AS qr_pending
FROM public.quiz_attempts a
JOIN public.profiles p ON p.id = a.user_id
JOIN public.quizzes q ON q.id = a.quiz_id
LEFT JOIN public.formation_quizzes fq ON fq.quiz_id = q.id
LEFT JOIN public.formations f ON f.id = fq.formation_id
WHERE a.status = 'awaiting_review';

GRANT SELECT ON public.pending_qr_corrections TO authenticated;
