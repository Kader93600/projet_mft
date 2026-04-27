-- =====================================================================
-- Simulateur d'examen v2 — drapeaux + relecture
-- =====================================================================

-- Liste des questions marquées "à revoir" lors de la tentative
ALTER TABLE public.quiz_attempts
  ADD COLUMN IF NOT EXISTS flagged_questions text[] NOT NULL DEFAULT '{}';

-- Vue : agrégation des questions les plus marquées (utile au formateur)
CREATE OR REPLACE VIEW public.quiz_question_flag_rate AS
SELECT
  q.id            AS quiz_id,
  q.title         AS quiz_title,
  unnest(qa.flagged_questions) AS question_id,
  count(*)        AS times_flagged
FROM public.quiz_attempts qa
JOIN public.quizzes q ON q.id = qa.quiz_id
WHERE qa.flagged_questions IS NOT NULL
  AND array_length(qa.flagged_questions, 1) > 0
GROUP BY q.id, q.title, unnest(qa.flagged_questions);

GRANT SELECT ON public.quiz_question_flag_rate TO authenticated;
