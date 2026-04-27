-- =====================================================================
-- Fix : la vue user_last_activity utilisait `lp.updated_at` (inexistante)
-- et combinait des sous-requêtes corrélées dans GREATEST() de façon
-- mal supportée par le planner. On réécrit avec des LEFT JOIN agrégés.
-- =====================================================================

DROP VIEW IF EXISTS public.inactivity_alerts;
DROP VIEW IF EXISTS public.user_last_activity;

CREATE OR REPLACE VIEW public.user_last_activity AS
SELECT
  p.id AS user_id,
  p.full_name,
  p.email,
  GREATEST(
    COALESCE(lp.max_at, 'epoch'::timestamptz),
    COALESCE(qa.max_at, 'epoch'::timestamptz),
    COALESCE(xe.max_at, 'epoch'::timestamptz),
    COALESCE(sg.max_at, 'epoch'::timestamptz)
  ) AS last_activity_at,
  EXISTS (
    SELECT 1 FROM public.enrollments e
     WHERE e.user_id = p.id AND e.status IN ('a_payer','en_cours')
  ) AS is_active_enrollment
FROM public.profiles p
LEFT JOIN (
  SELECT user_id, max(completed_at) AS max_at
    FROM public.lesson_progress
   WHERE completed_at IS NOT NULL
   GROUP BY user_id
) lp ON lp.user_id = p.id
LEFT JOIN (
  SELECT user_id, max(finished_at) AS max_at
    FROM public.quiz_attempts
   WHERE finished_at IS NOT NULL
   GROUP BY user_id
) qa ON qa.user_id = p.id
LEFT JOIN (
  SELECT user_id, max(created_at) AS max_at
    FROM public.xp_events
   GROUP BY user_id
) xe ON xe.user_id = p.id
LEFT JOIN (
  SELECT user_id, max(signed_at) AS max_at
    FROM public.attendance_signatures
   GROUP BY user_id
) sg ON sg.user_id = p.id
WHERE p.role = 'student'
  AND COALESCE(p.disabled, false) = false;

GRANT SELECT ON public.user_last_activity TO authenticated;

-- Recrée la vue dérivée
CREATE OR REPLACE VIEW public.inactivity_alerts AS
SELECT
  u.user_id,
  u.full_name,
  u.email,
  u.last_activity_at,
  EXTRACT(EPOCH FROM (now() - u.last_activity_at)) / 86400.0 AS days_inactive
FROM public.user_last_activity u
WHERE u.is_active_enrollment = true
  AND u.last_activity_at < now() - INTERVAL '7 days'
ORDER BY u.last_activity_at ASC;

GRANT SELECT ON public.inactivity_alerts TO authenticated;
