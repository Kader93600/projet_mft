-- =====================================================================
-- 2026-05-16 · Vues SQL pour le Dashboard admin temps réel
--
-- Objectif : matérialiser les KPIs coûteux dans 2 vues que la page
-- /admin/analytics peut SELECT en une seule requête sans calculer côté
-- TypeScript. Tous les agrégats sont fait Postgres-side pour la perf.
--
-- Sécurité : les vues sont créées avec security_invoker → elles héritent
-- des permissions de la session courante (RLS appliquée). Seul un admin
-- peut accéder à la page /admin/analytics donc pas de risque de leak.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) vw_admin_kpis_realtime — KPIs agrégés instantanés
-- ---------------------------------------------------------------------
-- Une seule ligne avec toutes les valeurs. La page SELECT * et affiche.
-- Toutes les fenêtres temporelles sont calculées par rapport à now().
DROP VIEW IF EXISTS public.vw_admin_kpis_realtime CASCADE;

CREATE VIEW public.vw_admin_kpis_realtime
WITH (security_invoker = on)
AS
WITH
  -- Stagiaires actifs (7 jours) : ont fait au moins UNE action récente
  active_7d AS (
    SELECT count(DISTINCT user_id)::int AS n
    FROM (
      SELECT user_id FROM public.quiz_attempts
        WHERE finished_at >= now() - interval '7 days'
      UNION
      SELECT user_id FROM public.lesson_views
        WHERE last_ping_at >= now() - interval '7 days'
      UNION
      SELECT user_id FROM public.lesson_progress
        WHERE completed_at >= now() - interval '7 days'
    ) u
  ),
  -- Stagiaires inactifs (>14 j) ET inscrits actifs : à risque de décrochage
  at_risk AS (
    SELECT count(*)::int AS n
    FROM public.enrollments e
    WHERE e.status = 'en_cours'
      AND NOT EXISTS (
        SELECT 1 FROM public.quiz_attempts qa
        WHERE qa.user_id = e.user_id
          AND qa.finished_at >= now() - interval '14 days'
        UNION
        SELECT 1 FROM public.lesson_views lv
        WHERE lv.user_id = e.user_id
          AND lv.last_ping_at >= now() - interval '14 days'
      )
  ),
  -- Quiz tentés cette semaine
  quiz_attempts_7d AS (
    SELECT count(*)::int AS n
    FROM public.quiz_attempts
    WHERE finished_at >= now() - interval '7 days'
  ),
  -- Sessions Premium ce mois
  live_sessions_30d AS (
    SELECT
      count(*) FILTER (WHERE status IN ('scheduled','in_progress'))::int AS scheduled,
      count(*) FILTER (WHERE status = 'completed' AND end_at >= now() - interval '30 days')::int AS completed
    FROM public.live_sessions
  ),
  -- Inscriptions actives (toutes formations confondues)
  active_enrollments AS (
    SELECT count(*)::int AS n
    FROM public.enrollments
    WHERE status = 'en_cours'
  ),
  -- Chiffre d'affaires 30j
  revenue_30d AS (
    SELECT coalesce(sum(paid_amount_cents), 0)::bigint AS cents
    FROM public.enrollments
    WHERE created_at >= now() - interval '30 days'
      AND paid_amount_cents > 0
  ),
  -- Nouveaux stagiaires 7j (compte auth.users)
  new_users_7d AS (
    SELECT count(*)::int AS n
    FROM public.profiles
    WHERE created_at >= now() - interval '7 days'
      AND role = 'student'
  ),
  -- Taux de réussite moyen 30j (sur tentatives finalisées)
  pass_rate_30d AS (
    SELECT
      CASE
        WHEN count(*) = 0 THEN 0
        ELSE round(100.0 * count(*) FILTER (WHERE passed = true) / count(*), 1)
      END::numeric AS pct
    FROM public.quiz_attempts
    WHERE finished_at >= now() - interval '30 days'
      AND passed IS NOT NULL
  ),
  -- Examens blancs passés 30j
  mock_exams_30d AS (
    SELECT count(*)::int AS n
    FROM public.quiz_attempts qa
    JOIN public.quizzes q ON q.id = qa.quiz_id
    WHERE qa.finished_at >= now() - interval '30 days'
      AND q.is_mock_exam = true
  ),
  -- Copies en attente de correction (formateurs)
  pending_corrections AS (
    SELECT count(*)::int AS n
    FROM public.quiz_attempts
    WHERE status = 'awaiting_review'
  )
SELECT
  a.n   AS active_students_7d,
  r.n   AS at_risk_students,
  qa.n  AS quiz_attempts_7d,
  ls.scheduled AS live_sessions_scheduled,
  ls.completed AS live_sessions_completed_30d,
  ae.n  AS active_enrollments,
  rev.cents AS revenue_30d_cents,
  nu.n  AS new_users_7d,
  pr.pct AS pass_rate_30d,
  me.n  AS mock_exams_30d,
  pc.n  AS pending_corrections,
  now() AS computed_at
FROM active_7d a
CROSS JOIN at_risk r
CROSS JOIN quiz_attempts_7d qa
CROSS JOIN live_sessions_30d ls
CROSS JOIN active_enrollments ae
CROSS JOIN revenue_30d rev
CROSS JOIN new_users_7d nu
CROSS JOIN pass_rate_30d pr
CROSS JOIN mock_exams_30d me
CROSS JOIN pending_corrections pc;

GRANT SELECT ON public.vw_admin_kpis_realtime TO authenticated;

-- ---------------------------------------------------------------------
-- 2) vw_admin_trends_30d — Séries temporelles sur 30 jours
-- ---------------------------------------------------------------------
-- Une ligne par jour avec les 3 métriques principales pour le line chart.
DROP VIEW IF EXISTS public.vw_admin_trends_30d CASCADE;

CREATE VIEW public.vw_admin_trends_30d
WITH (security_invoker = on)
AS
WITH days AS (
  SELECT generate_series(
    (now() - interval '29 days')::date,
    now()::date,
    interval '1 day'
  )::date AS d
),
signups AS (
  SELECT created_at::date AS d, count(*)::int AS n
  FROM public.profiles
  WHERE created_at >= now() - interval '30 days'
    AND role = 'student'
  GROUP BY 1
),
quiz_attempts AS (
  SELECT finished_at::date AS d, count(*)::int AS n
  FROM public.quiz_attempts
  WHERE finished_at >= now() - interval '30 days'
  GROUP BY 1
),
payments AS (
  SELECT created_at::date AS d, count(*)::int AS n
  FROM public.enrollments
  WHERE created_at >= now() - interval '30 days'
    AND paid_amount_cents > 0
  GROUP BY 1
)
SELECT
  d.d AS day,
  coalesce(s.n, 0)  AS signups,
  coalesce(qa.n, 0) AS quiz_attempts,
  coalesce(p.n, 0)  AS payments
FROM days d
LEFT JOIN signups s       ON s.d = d.d
LEFT JOIN quiz_attempts qa ON qa.d = d.d
LEFT JOIN payments p      ON p.d = d.d
ORDER BY d.d;

GRANT SELECT ON public.vw_admin_trends_30d TO authenticated;

-- ---------------------------------------------------------------------
-- 3) vw_admin_completion_by_formation — Taux de complétion par formation
-- ---------------------------------------------------------------------
-- Permet d'identifier les formations où les stagiaires décrochent le plus.
DROP VIEW IF EXISTS public.vw_admin_completion_by_formation CASCADE;

CREATE VIEW public.vw_admin_completion_by_formation
WITH (security_invoker = on)
AS
WITH formation_progress AS (
  SELECT
    f.id           AS formation_id,
    f.slug         AS formation_slug,
    f.title        AS formation_title,
    f.code         AS formation_code,
    f.accent_color,
    e.user_id,
    (
      SELECT count(DISTINCT lp.lesson_id)
      FROM public.lesson_progress lp
      JOIN public.lessons l ON l.id = lp.lesson_id
      JOIN public.modules m ON m.id = l.module_id
      JOIN public.formation_modules fm ON fm.module_id = m.id
      WHERE fm.formation_id = f.id
        AND lp.user_id = e.user_id
        AND lp.completed = true
    )::int AS lessons_done,
    (
      SELECT count(*)
      FROM public.lessons l
      JOIN public.modules m ON m.id = l.module_id
      JOIN public.formation_modules fm ON fm.module_id = m.id
      WHERE fm.formation_id = f.id
    )::int AS lessons_total
  FROM public.formations f
  JOIN public.enrollments e ON e.formation_id = f.id
  WHERE e.status = 'en_cours'
    AND f.active = true
)
SELECT
  formation_id,
  formation_slug,
  formation_title,
  formation_code,
  accent_color,
  count(DISTINCT user_id)::int AS enrolled_count,
  CASE
    WHEN sum(lessons_total) = 0 THEN 0
    ELSE round(100.0 * sum(lessons_done) / sum(lessons_total), 1)
  END::numeric AS completion_pct,
  sum(lessons_done)::int  AS total_lessons_done,
  sum(lessons_total)::int AS total_lessons_available
FROM formation_progress
GROUP BY formation_id, formation_slug, formation_title, formation_code, accent_color
ORDER BY enrolled_count DESC, completion_pct DESC;

GRANT SELECT ON public.vw_admin_completion_by_formation TO authenticated;

-- ---------------------------------------------------------------------
-- 4) Vérification
-- ---------------------------------------------------------------------
DO $$
DECLARE
  v_count int;
BEGIN
  SELECT count(*) INTO v_count FROM public.vw_admin_kpis_realtime;
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Dashboard admin — vues SQL créées';
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE '  vw_admin_kpis_realtime ........... % ligne(s) (doit être 1)', v_count;

  SELECT count(*) INTO v_count FROM public.vw_admin_trends_30d;
  RAISE NOTICE '  vw_admin_trends_30d .............. % ligne(s) (doit être 30)', v_count;

  SELECT count(*) INTO v_count FROM public.vw_admin_completion_by_formation;
  RAISE NOTICE '  vw_admin_completion_by_formation . % ligne(s) (= nb formations)', v_count;
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;
