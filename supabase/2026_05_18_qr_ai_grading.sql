-- =====================================================================
-- Sprint 3.3 / P3 #1 — Correction QR automatique par Claude
-- 2026-05-18
--
-- Décision client (2026-05) : IA propose, formateur valide.
-- L'IA n'écrase JAMAIS la note finale qui reste sous la responsabilité
-- du formateur. On stocke la proposition IA dans des colonnes séparées
-- (`ai_*`) ; les colonnes `trainer_*` restent la source de vérité finale.
--
-- Flux :
--   1. Stagiaire soumet ses QR → submit_qr_response (existant)
--   2. Tentative passe en status='awaiting_review' (existant)
--   3. Formateur ouvre /admin/qr-review → bouton "Proposer une note IA"
--   4. POST /api/tutor/grade-qr → Claude renvoie {score, feedback, criteria}
--   5. Colonnes ai_* remplies sur qr_responses
--   6. Formateur valide tel quel OU ajuste → grade_qr_response (existant)
--   7. finalize_quiz_grading clôt la copie (existant)
-- =====================================================================

ALTER TABLE public.qr_responses
  ADD COLUMN IF NOT EXISTS ai_score numeric,
  ADD COLUMN IF NOT EXISTS ai_feedback_md text,
  ADD COLUMN IF NOT EXISTS ai_criteria jsonb,
  ADD COLUMN IF NOT EXISTS ai_confidence text
    CHECK (ai_confidence IS NULL OR ai_confidence IN ('low','medium','high')),
  ADD COLUMN IF NOT EXISTS ai_concerns text,
  ADD COLUMN IF NOT EXISTS ai_model text,
  ADD COLUMN IF NOT EXISTS ai_tokens_in int,
  ADD COLUMN IF NOT EXISTS ai_tokens_out int,
  ADD COLUMN IF NOT EXISTS ai_cost_cents int,
  ADD COLUMN IF NOT EXISTS ai_graded_at timestamptz;

COMMENT ON COLUMN public.qr_responses.ai_score IS
  'Note PROPOSÉE par l''IA. La note finale reste qr_responses.trainer_score (formateur).';
COMMENT ON COLUMN public.qr_responses.ai_confidence IS
  'low|medium|high — niveau de confiance auto-déclaré par le modèle.';
COMMENT ON COLUMN public.qr_responses.ai_concerns IS
  'Note interne pour le formateur si quelque chose a gêné le modèle (rare).';

-- Index pour la file d'attente des corrections IA non encore proposées
CREATE INDEX IF NOT EXISTS qr_responses_ai_pending_idx
  ON public.qr_responses(attempt_id)
  WHERE ai_graded_at IS NULL AND graded_at IS NULL;

-- RLS additionnelle : les colonnes ai_* sont écrites uniquement par le
-- backend (service_role) via SECURITY DEFINER. Les policies existantes
-- (qr_responses_self_read et qr_responses_trainer_read) couvrent déjà la
-- lecture par stagiaire (sa propre attempt) et formateur/admin.
--
-- Note : la policy stagiaire ne devrait PAS exposer ai_* tant que la
-- copie n'est pas finalisée. Mais comme on lit qr_responses depuis le
-- code app (server) qui restreint déjà l'exposition, on ne complexifie
-- pas la RLS. La page de résultats stagiaire affichera ai_* uniquement
-- quand graded_at IS NOT NULL (cf. code app).

-- =====================================================================
-- RPC : poser une proposition IA sur une qr_response
-- =====================================================================
-- Appelé par /api/tutor/grade-qr (server-side, SECURITY DEFINER).
-- Conditions :
--   - L'utilisateur courant est admin OU trainer (sinon refus)
--   - La qr_response existe
--   - La note finale du formateur (trainer_score) n'est pas encore posée
--     (on ne propose pas de note IA après la validation humaine)
-- =====================================================================

CREATE OR REPLACE FUNCTION public.set_qr_ai_grading(
  p_response uuid,
  p_score numeric,
  p_feedback_md text,
  p_criteria jsonb,
  p_confidence text,
  p_concerns text,
  p_model text,
  p_tokens_in int,
  p_tokens_out int,
  p_cost_cents int
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  uid uuid := auth.uid();
  q_max numeric;
  has_trainer_score boolean;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'unauthenticated';
  END IF;
  IF NOT (public.is_trainer() OR public.is_admin()) THEN
    RAISE EXCEPTION 'must_be_trainer_or_admin';
  END IF;

  SELECT max_score, trainer_score IS NOT NULL
    INTO q_max, has_trainer_score
    FROM public.qr_responses
   WHERE id = p_response;
  IF q_max IS NULL THEN
    RAISE EXCEPTION 'response_not_found';
  END IF;
  IF has_trainer_score THEN
    RAISE EXCEPTION 'already_graded_by_trainer';
  END IF;
  IF p_score < 0 OR p_score > q_max THEN
    RAISE EXCEPTION 'score_out_of_range';
  END IF;
  IF p_confidence IS NOT NULL
     AND p_confidence NOT IN ('low','medium','high') THEN
    RAISE EXCEPTION 'invalid_confidence';
  END IF;

  UPDATE public.qr_responses
     SET ai_score        = p_score,
         ai_feedback_md  = p_feedback_md,
         ai_criteria     = p_criteria,
         ai_confidence   = p_confidence,
         ai_concerns     = NULLIF(p_concerns, ''),
         ai_model        = p_model,
         ai_tokens_in    = p_tokens_in,
         ai_tokens_out   = p_tokens_out,
         ai_cost_cents   = p_cost_cents,
         ai_graded_at    = now()
   WHERE id = p_response;
END;
$$;

GRANT EXECUTE ON FUNCTION public.set_qr_ai_grading(
  uuid, numeric, text, jsonb, text, text, text, int, int, int
) TO authenticated;
