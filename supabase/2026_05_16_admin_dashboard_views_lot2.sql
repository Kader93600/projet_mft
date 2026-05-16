-- =====================================================================
-- 2026-05-16 · Dashboard admin — Vues SQL Lot 1 (enrichissements)
--
-- Ajoute 5 nouvelles vues pour enrichir /admin/analytics avec :
--   • vw_admin_at_risk_students       — liste détaillée stagiaires inactifs
--   • vw_admin_top_students           — top 10 stagiaires les plus actifs
--   • vw_admin_qualiopi_indicators    — heures formées, abandon, délais
--   • vw_admin_quiz_outliers          — quiz avec taux de réussite anormal
--   • vw_admin_revenue_by_formation_pack — CA par formation × pack
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Stagiaires à risque (>14j inactifs, inscrits actifs)
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS public.vw_admin_at_risk_students CASCADE;

CREATE VIEW public.vw_admin_at_risk_students
WITH (security_invoker = on)
AS
WITH last_activity AS (
  SELECT
    p.id            AS user_id,
    p.email,
    p.full_name,
    GREATEST(
      COALESCE((SELECT max(finished_at) FROM public.quiz_attempts WHERE user_id = p.id), '1970-01-01'::timestamptz),
      COALESCE((SELECT max(last_ping_at) FROM public.lesson_views WHERE user_id = p.id), '1970-01-01'::timestamptz),
      COALESCE((SELECT max(completed_at) FROM public.lesson_progress WHERE user_id = p.id), '1970-01-01'::timestamptz)
    ) AS last_active_at
  FROM public.profiles p
  WHERE p.role = 'student'
    AND p.disabled = false
)
SELECT
  e.user_id,
  la.email,
  la.full_name,
  f.slug          AS formation_slug,
  f.title         AS formation_title,
  f.code          AS formation_code,
  f.accent_color,
  e.pack,
  e.created_at    AS enrolled_at,
  la.last_active_at,
  CASE
    WHEN la.last_active_at = '1970-01-01'::timestamptz THEN
      EXTRACT(day FROM (now() - e.created_at))::int
    ELSE
      EXTRACT(day FROM (now() - la.last_active_at))::int
  END AS days_inactive
FROM public.enrollments e
JOIN public.formations f ON f.id = e.formation_id
JOIN last_activity la ON la.user_id = e.user_id
WHERE e.status = 'en_cours'
  AND (
    la.last_active_at < now() - interval '14 days'
    OR la.last_active_at = '1970-01-01'::timestamptz  -- jamais actif
  )
ORDER BY la.last_active_at ASC NULLS FIRST;

GRANT SELECT ON public.vw_admin_at_risk_students TO authenticated;

-- ---------------------------------------------------------------------
-- 2) Top 10 stagiaires actifs (sur 30 jours)
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS public.vw_admin_top_students CASCADE;

CREATE VIEW public.vw_admin_top_students
WITH (security_invoker = on)
AS
WITH activity AS (
  SELECT
    p.id            AS user_id,
    p.full_name,
    p.email,
    (
      SELECT count(*) FROM public.lesson_progress
      WHERE user_id = p.id
        AND completed = true
        AND completed_at >= now() - interval '30 days'
    )::int AS lessons_completed_30d,
    (
      SELECT count(*) FROM public.quiz_attempts
      WHERE user_id = p.id
        AND finished_at >= now() - interval '30 days'
    )::int AS quiz_attempts_30d,
    (
      SELECT count(*) FILTER (WHERE passed = true) FROM public.quiz_attempts
      WHERE user_id = p.id
        AND finished_at >= now() - interval '30 days'
    )::int AS quiz_passed_30d,
    (
      SELECT max(finished_at) FROM public.quiz_attempts
      WHERE user_id = p.id
    ) AS last_quiz_at
  FROM public.profiles p
  WHERE p.role = 'student' AND p.disabled = false
)
SELECT
  user_id,
  full_name,
  email,
  lessons_completed_30d,
  quiz_attempts_30d,
  quiz_passed_30d,
  last_quiz_at,
  (lessons_completed_30d + quiz_attempts_30d) AS activity_score
FROM activity
WHERE lessons_completed_30d > 0 OR quiz_attempts_30d > 0
ORDER BY activity_score DESC, quiz_passed_30d DESC
LIMIT 10;

GRANT SELECT ON public.vw_admin_top_students TO authenticated;

-- ---------------------------------------------------------------------
-- 3) Indicateurs Qualiopi
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS public.vw_admin_qualiopi_indicators CASCADE;

CREATE VIEW public.vw_admin_qualiopi_indicators
WITH (security_invoker = on)
AS
WITH
  -- Heures de formation cumulées : sum(durée des leçons complétées)
  hours_trained AS (
    SELECT coalesce(sum(l.duration_min), 0) / 60.0 AS hours
    FROM public.lesson_progress lp
    JOIN public.lessons l ON l.id = lp.lesson_id
    WHERE lp.completed = true
  ),
  hours_30d AS (
    SELECT coalesce(sum(l.duration_min), 0) / 60.0 AS hours
    FROM public.lesson_progress lp
    JOIN public.lessons l ON l.id = lp.lesson_id
    WHERE lp.completed = true
      AND lp.completed_at >= now() - interval '30 days'
  ),
  -- Taux d'abandon : enrollments status='abandon' / total enrollments terminés
  abandon AS (
    SELECT
      CASE
        WHEN count(*) FILTER (WHERE status IN ('termine', 'abandon')) = 0 THEN 0
        ELSE round(
          100.0 * count(*) FILTER (WHERE status = 'abandon')
          / NULLIF(count(*) FILTER (WHERE status IN ('termine', 'abandon')), 0),
          1
        )
      END::numeric AS rate
    FROM public.enrollments
  ),
  -- Délai moyen entre inscription et complétion (en jours)
  completion_delay AS (
    SELECT
      coalesce(round(avg(EXTRACT(day FROM (e.updated_at - e.created_at)))), 0)::int AS avg_days
    FROM public.enrollments e
    WHERE e.status = 'termine'
      AND e.updated_at IS NOT NULL
  ),
  -- Stagiaires ayant réussi au moins 1 examen blanc (Qualiopi : taux de réussite final)
  rncp_success AS (
    SELECT count(DISTINCT qa.user_id)::int AS n
    FROM public.quiz_attempts qa
    JOIN public.quizzes q ON q.id = qa.quiz_id
    WHERE q.is_mock_exam = true AND qa.passed = true
  ),
  -- Total stagiaires ayant tenté au moins 1 examen blanc
  rncp_attempted AS (
    SELECT count(DISTINCT qa.user_id)::int AS n
    FROM public.quiz_attempts qa
    JOIN public.quizzes q ON q.id = qa.quiz_id
    WHERE q.is_mock_exam = true
  )
SELECT
  round(ht.hours, 1)::numeric AS hours_trained_total,
  round(h30.hours, 1)::numeric AS hours_trained_30d,
  a.rate AS abandon_rate_pct,
  cd.avg_days AS avg_completion_days,
  rs.n AS rncp_success_count,
  ra.n AS rncp_attempted_count,
  CASE
    WHEN ra.n = 0 THEN 0
    ELSE round(100.0 * rs.n / ra.n, 1)
  END::numeric AS rncp_success_rate_pct
FROM hours_trained ht
CROSS JOIN hours_30d h30
CROSS JOIN abandon a
CROSS JOIN completion_delay cd
CROSS JOIN rncp_success rs
CROSS JOIN rncp_attempted ra;

GRANT SELECT ON public.vw_admin_qualiopi_indicators TO authenticated;

-- ---------------------------------------------------------------------
-- 4) Quiz à difficulté anormale (taux <30% ou >95%)
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS public.vw_admin_quiz_outliers CASCADE;

CREATE VIEW public.vw_admin_quiz_outliers
WITH (security_invoker = on)
AS
WITH quiz_stats AS (
  SELECT
    q.id           AS quiz_id,
    q.title        AS quiz_title,
    q.is_mock_exam,
    q.pass_threshold,
    count(*)::int  AS attempts_count,
    count(*) FILTER (WHERE qa.passed = true)::int AS passed_count,
    round(avg(qa.percentage), 1)::numeric AS avg_score,
    CASE
      WHEN count(*) FILTER (WHERE qa.passed IS NOT NULL) = 0 THEN NULL
      ELSE round(
        100.0 * count(*) FILTER (WHERE qa.passed = true)
        / count(*) FILTER (WHERE qa.passed IS NOT NULL),
        1
      )
    END::numeric AS pass_rate_pct
  FROM public.quizzes q
  JOIN public.quiz_attempts qa ON qa.quiz_id = q.id
  WHERE qa.finished_at >= now() - interval '90 days'
  GROUP BY q.id, q.title, q.is_mock_exam, q.pass_threshold
  HAVING count(*) >= 5  -- au moins 5 tentatives pour stat significative
)
SELECT
  quiz_id,
  quiz_title,
  is_mock_exam,
  pass_threshold,
  attempts_count,
  passed_count,
  avg_score,
  pass_rate_pct,
  CASE
    WHEN pass_rate_pct IS NULL THEN 'unknown'
    WHEN pass_rate_pct < 30 THEN 'too_hard'
    WHEN pass_rate_pct > 95 THEN 'too_easy'
    ELSE 'normal'
  END AS difficulty_flag
FROM quiz_stats
WHERE pass_rate_pct IS NOT NULL
  AND (pass_rate_pct < 30 OR pass_rate_pct > 95)
ORDER BY pass_rate_pct ASC;

GRANT SELECT ON public.vw_admin_quiz_outliers TO authenticated;

-- ---------------------------------------------------------------------
-- 5) CA par formation × pack
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS public.vw_admin_revenue_by_formation_pack CASCADE;

CREATE VIEW public.vw_admin_revenue_by_formation_pack
WITH (security_invoker = on)
AS
SELECT
  f.id            AS formation_id,
  f.slug          AS formation_slug,
  f.title         AS formation_title,
  f.code          AS formation_code,
  f.accent_color,
  e.pack,
  count(*)::int                              AS enrollments_count,
  coalesce(sum(e.paid_amount_cents), 0)::bigint AS revenue_cents,
  coalesce(sum(e.total_amount_cents), 0)::bigint AS commitment_cents
FROM public.enrollments e
JOIN public.formations f ON f.id = e.formation_id
WHERE e.created_at >= now() - interval '12 months'
  AND e.status NOT IN ('refuse', 'abandon')
GROUP BY f.id, f.slug, f.title, f.code, f.accent_color, e.pack
ORDER BY f.display_order, e.pack;

GRANT SELECT ON public.vw_admin_revenue_by_formation_pack TO authenticated;

-- ---------------------------------------------------------------------
-- 6) Vérification
-- ---------------------------------------------------------------------
DO $$
BEGIN
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Dashboard admin — vues Lot 1 créées';
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE '  vw_admin_at_risk_students          — liste stagiaires inactifs';
  RAISE NOTICE '  vw_admin_top_students              — top 10 actifs 30j';
  RAISE NOTICE '  vw_admin_qualiopi_indicators       — heures formées, abandon, RNCP';
  RAISE NOTICE '  vw_admin_quiz_outliers             — quiz <30%% ou >95%% réussite';
  RAISE NOTICE '  vw_admin_revenue_by_formation_pack — CA par formation × pack';
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;
