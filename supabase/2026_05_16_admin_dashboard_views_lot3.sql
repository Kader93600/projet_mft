-- =====================================================================
-- 2026-05-16 · Dashboard admin — Vues SQL Lot 2
--
-- Ajoute les vues/fonctions pour :
--   • vw_admin_funnel_conversion       — funnel signup → 1ère leçon → 1er quiz → 1er paiement
--   • vw_admin_activity_heatmap        — 7 jours × 24 heures (activité quiz)
--   • vw_admin_trends_by_formation     — trends 30j par formation
--   • vw_admin_upcoming_sessions_14d   — sessions live à venir (14j)
--   • get_admin_kpis_for_period(p_days) — KPIs paramétriques avec comparaison
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Funnel de conversion stagiaire (tous-temps)
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS public.vw_admin_funnel_conversion CASCADE;

CREATE VIEW public.vw_admin_funnel_conversion
WITH (security_invoker = on)
AS
WITH base AS (
  SELECT id, created_at
  FROM public.profiles
  WHERE role = 'student'
),
steps AS (
  SELECT
    -- Étape 1 : signup (tous les stagiaires)
    (SELECT count(*) FROM base)::int AS signups,
    -- Étape 2 : a vu au moins 1 leçon
    (
      SELECT count(DISTINCT p.id)::int
      FROM base p
      WHERE EXISTS (
        SELECT 1 FROM public.lesson_views lv WHERE lv.user_id = p.id
      )
    ) AS lesson_viewers,
    -- Étape 3 : a tenté au moins 1 quiz
    (
      SELECT count(DISTINCT p.id)::int
      FROM base p
      WHERE EXISTS (
        SELECT 1 FROM public.quiz_attempts qa WHERE qa.user_id = p.id
      )
    ) AS quiz_attempters,
    -- Étape 4 : a passé au moins 1 quiz avec succès
    (
      SELECT count(DISTINCT p.id)::int
      FROM base p
      WHERE EXISTS (
        SELECT 1 FROM public.quiz_attempts qa
        WHERE qa.user_id = p.id AND qa.passed = true
      )
    ) AS quiz_passers,
    -- Étape 5 : a payé au moins une fois
    (
      SELECT count(DISTINCT e.user_id)::int
      FROM public.enrollments e
      WHERE e.paid_amount_cents > 0
    ) AS payers
)
SELECT * FROM steps;

GRANT SELECT ON public.vw_admin_funnel_conversion TO authenticated;

-- ---------------------------------------------------------------------
-- 2) Activity heatmap : 7 jours × 24 heures (90 derniers jours agrégés)
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS public.vw_admin_activity_heatmap CASCADE;

CREATE VIEW public.vw_admin_activity_heatmap
WITH (security_invoker = on)
AS
WITH grid AS (
  SELECT
    dow::int  AS day_of_week,  -- 0=dimanche, 1=lundi, ..., 6=samedi
    hour::int AS hour_of_day
  FROM generate_series(0, 6) dow
  CROSS JOIN generate_series(0, 23) hour
),
events AS (
  SELECT
    EXTRACT(dow FROM finished_at)::int  AS day_of_week,
    EXTRACT(hour FROM finished_at)::int AS hour_of_day,
    count(*)::int                        AS n
  FROM public.quiz_attempts
  WHERE finished_at >= now() - interval '90 days'
  GROUP BY 1, 2
)
SELECT
  g.day_of_week,
  g.hour_of_day,
  coalesce(e.n, 0) AS attempts
FROM grid g
LEFT JOIN events e
  ON e.day_of_week = g.day_of_week AND e.hour_of_day = g.hour_of_day
ORDER BY g.day_of_week, g.hour_of_day;

GRANT SELECT ON public.vw_admin_activity_heatmap TO authenticated;

-- ---------------------------------------------------------------------
-- 3) Trends par formation (30 derniers jours)
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS public.vw_admin_trends_by_formation CASCADE;

CREATE VIEW public.vw_admin_trends_by_formation
WITH (security_invoker = on)
AS
WITH days AS (
  SELECT generate_series(
    (now() - interval '29 days')::date,
    now()::date,
    interval '1 day'
  )::date AS d
),
formations AS (
  SELECT id, slug, title, code, accent_color
  FROM public.formations
  WHERE active = true
),
quiz_per_day AS (
  SELECT
    qa.finished_at::date AS d,
    fq.formation_id,
    count(*)::int AS n
  FROM public.quiz_attempts qa
  JOIN public.quizzes q ON q.id = qa.quiz_id
  LEFT JOIN public.formation_quizzes fq ON fq.quiz_id = q.id
  WHERE qa.finished_at >= now() - interval '30 days'
    AND fq.formation_id IS NOT NULL
  GROUP BY 1, 2
)
SELECT
  f.id           AS formation_id,
  f.slug         AS formation_slug,
  f.title        AS formation_title,
  f.code         AS formation_code,
  f.accent_color,
  d.d            AS day,
  coalesce(qpd.n, 0) AS quiz_attempts
FROM formations f
CROSS JOIN days d
LEFT JOIN quiz_per_day qpd ON qpd.formation_id = f.id AND qpd.d = d.d
ORDER BY f.id, d.d;

GRANT SELECT ON public.vw_admin_trends_by_formation TO authenticated;

-- ---------------------------------------------------------------------
-- 4) Sessions live à venir (14j)
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS public.vw_admin_upcoming_sessions_14d CASCADE;

CREATE VIEW public.vw_admin_upcoming_sessions_14d
WITH (security_invoker = on)
AS
SELECT
  ls.id,
  ls.title,
  ls.kind,
  ls.start_at,
  ls.end_at,
  ls.status,
  ls.max_participants,
  ls.meeting_provider,
  f.slug          AS formation_slug,
  f.title         AS formation_title,
  f.code          AS formation_code,
  f.accent_color,
  (
    SELECT count(*)::int FROM public.session_enrollments se
    WHERE se.session_id = ls.id
      AND se.status IN ('confirmed', 'invited')
  ) AS enrolled_count
FROM public.live_sessions ls
JOIN public.formations f ON f.id = ls.formation_id
WHERE ls.start_at >= now()
  AND ls.start_at < now() + interval '14 days'
  AND ls.status != 'cancelled'
ORDER BY ls.start_at;

GRANT SELECT ON public.vw_admin_upcoming_sessions_14d TO authenticated;

-- ---------------------------------------------------------------------
-- 5) Fonction KPIs paramétriques avec comparaison période précédente
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.get_admin_kpis_for_period(int);

CREATE OR REPLACE FUNCTION public.get_admin_kpis_for_period(p_days int)
RETURNS TABLE (
  -- Période courante
  signups             int,
  quiz_attempts       int,
  payments            int,
  revenue_cents       bigint,
  -- Période précédente (pour delta)
  signups_prev        int,
  quiz_attempts_prev  int,
  payments_prev       int,
  revenue_cents_prev  bigint
)
LANGUAGE sql STABLE AS $$
  WITH
    -- Période courante
    cur AS (
      SELECT
        (SELECT count(*)::int FROM public.profiles
         WHERE role = 'student'
           AND created_at >= now() - (p_days || ' days')::interval) AS s,
        (SELECT count(*)::int FROM public.quiz_attempts
         WHERE finished_at >= now() - (p_days || ' days')::interval) AS qa,
        (SELECT count(*)::int FROM public.enrollments
         WHERE created_at >= now() - (p_days || ' days')::interval
           AND paid_amount_cents > 0) AS p,
        (SELECT coalesce(sum(paid_amount_cents), 0)::bigint FROM public.enrollments
         WHERE created_at >= now() - (p_days || ' days')::interval
           AND paid_amount_cents > 0) AS r
    ),
    -- Période précédente (même durée)
    prev AS (
      SELECT
        (SELECT count(*)::int FROM public.profiles
         WHERE role = 'student'
           AND created_at >= now() - (2 * p_days || ' days')::interval
           AND created_at <  now() - (p_days || ' days')::interval) AS s,
        (SELECT count(*)::int FROM public.quiz_attempts
         WHERE finished_at >= now() - (2 * p_days || ' days')::interval
           AND finished_at <  now() - (p_days || ' days')::interval) AS qa,
        (SELECT count(*)::int FROM public.enrollments
         WHERE created_at >= now() - (2 * p_days || ' days')::interval
           AND created_at <  now() - (p_days || ' days')::interval
           AND paid_amount_cents > 0) AS p,
        (SELECT coalesce(sum(paid_amount_cents), 0)::bigint FROM public.enrollments
         WHERE created_at >= now() - (2 * p_days || ' days')::interval
           AND created_at <  now() - (p_days || ' days')::interval
           AND paid_amount_cents > 0) AS r
    )
  SELECT
    cur.s, cur.qa, cur.p, cur.r,
    prev.s, prev.qa, prev.p, prev.r
  FROM cur, prev;
$$;

GRANT EXECUTE ON FUNCTION public.get_admin_kpis_for_period(int) TO authenticated;

-- ---------------------------------------------------------------------
-- 6) Vérification
-- ---------------------------------------------------------------------
DO $$
BEGIN
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Dashboard admin — vues Lot 2 créées';
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE '  vw_admin_funnel_conversion       — funnel 5 étapes';
  RAISE NOTICE '  vw_admin_activity_heatmap        — 7×24 heatmap';
  RAISE NOTICE '  vw_admin_trends_by_formation     — trends par formation';
  RAISE NOTICE '  vw_admin_upcoming_sessions_14d   — sessions live 14j';
  RAISE NOTICE '  get_admin_kpis_for_period(int)   — KPIs + delta';
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;
