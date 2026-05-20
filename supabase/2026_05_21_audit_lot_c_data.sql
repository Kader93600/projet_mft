-- =====================================================================
-- AUDIT LOT C — Corrections data/reporting
-- 2026-05-20
--
--   #15 — quiz_attempts ON DELETE CASCADE → RESTRICT (preuves examen)
--   #20 — Incohérence comptage "à risque" KPI vs liste (INNER → LEFT)
--   #26 — Trends par formation : sous-comptage (formation_quizzes only)
-- =====================================================================


-- ─────────────────────────────────────────────────────────────────────
-- #15 — Protéger les tentatives d'examen contre la suppression d'un quiz
-- ─────────────────────────────────────────────────────────────────────
-- Avant : quiz_attempts.quiz_id ON DELETE CASCADE → supprimer un quiz
-- effaçait toutes les tentatives associées (preuves Qualiopi/RNCP).
-- Fix : RESTRICT — la suppression d'un quiz ayant des tentatives est
-- désormais bloquée. L'admin doit d'abord archiver/gérer les tentatives.

ALTER TABLE public.quiz_attempts
  DROP CONSTRAINT IF EXISTS quiz_attempts_quiz_id_fkey;

ALTER TABLE public.quiz_attempts
  ADD CONSTRAINT quiz_attempts_quiz_id_fkey
  FOREIGN KEY (quiz_id) REFERENCES public.quizzes(id) ON DELETE RESTRICT;


-- ─────────────────────────────────────────────────────────────────────
-- #20 — vw_admin_at_risk_students : LEFT JOIN formations
-- ─────────────────────────────────────────────────────────────────────
-- Le KPI at_risk (vw_admin_kpis_realtime) compte les enrollments en_cours
-- inactifs SANS jointure formations. La liste détaillée faisait un INNER
-- JOIN → les inscriptions à formation_id NULL étaient comptées dans le
-- KPI mais absentes de la liste (le bandeau dépassait la liste affichée).
-- Fix : LEFT JOIN + fallback libellé "Formation non précisée".

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
  COALESCE(f.title, 'Formation non précisée') AS formation_title,
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
LEFT JOIN public.formations f ON f.id = e.formation_id
JOIN last_activity la ON la.user_id = e.user_id
WHERE e.status = 'en_cours'
  AND (
    la.last_active_at < now() - interval '14 days'
    OR la.last_active_at = '1970-01-01'::timestamptz
  )
ORDER BY la.last_active_at ASC NULLS FIRST;

GRANT SELECT ON public.vw_admin_at_risk_students TO authenticated;


-- ─────────────────────────────────────────────────────────────────────
-- #26 — vw_admin_trends_by_formation : compter les 2 chemins de rattachement
-- ─────────────────────────────────────────────────────────────────────
-- Avant : quiz_per_day résolvait la formation du quiz via formation_quizzes
-- uniquement → les tentatives sur des quiz de MODULE (rattachés via
-- module_id → formation_modules) n'étaient pas comptées (sous-comptage
-- silencieux de l'activité). Fix : résolution par les 2 chemins (UNION).

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
    qf.formation_id,
    count(*)::int AS n
  FROM public.quiz_attempts qa
  JOIN public.quizzes q ON q.id = qa.quiz_id
  JOIN LATERAL (
    SELECT DISTINCT z.formation_id FROM (
      SELECT fq.formation_id
      FROM public.formation_quizzes fq WHERE fq.quiz_id = q.id
      UNION
      SELECT fm.formation_id
      FROM public.formation_modules fm WHERE fm.module_id = q.module_id
    ) z
    WHERE z.formation_id IS NOT NULL
  ) qf ON true
  WHERE qa.finished_at >= now() - interval '30 days'
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


DO $$
BEGIN
  RAISE NOTICE '════════ AUDIT LOT C — Data/reporting ════════';
  RAISE NOTICE '  quiz_attempts.quiz_id : ON DELETE RESTRICT';
  RAISE NOTICE '  vw_admin_at_risk_students : LEFT JOIN formations';
  RAISE NOTICE '  vw_admin_trends_by_formation : 2 chemins de rattachement';
  RAISE NOTICE '══════════════════════════════════════════════';
END $$;
