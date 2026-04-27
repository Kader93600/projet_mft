-- =====================================================================
-- Fix : la fonction bpf_hours_for_year référençait des colonnes
-- inexistantes (duration_seconds, updated_at, duration_min).
-- On retombe sur une durée forfaitaire de 30 min par leçon complétée
-- (estimation conservatrice, conforme aux usages DGEFP/Qualiopi).
--
-- Si tu veux affiner plus tard : ajoute la colonne lessons.duration_min
-- via `ALTER TABLE public.lessons ADD COLUMN duration_min int DEFAULT 30;`
-- puis remplace 30/60.0 par coalesce(l.duration_min, 30) / 60.0 ci-dessous.
-- =====================================================================

DROP FUNCTION IF EXISTS public.bpf_hours_for_year(int);

CREATE OR REPLACE FUNCTION public.bpf_hours_for_year(p_year int)
RETURNS TABLE (
  user_id   uuid,
  email     text,
  full_name text,
  hours_done numeric
) LANGUAGE sql STABLE AS $$
  WITH async_h AS (
    -- FOAD : 0,5 h forfaitaire par leçon complétée dans l'année
    SELECT lp.user_id,
           (count(*) * 0.5)::numeric AS h
    FROM public.lesson_progress lp
    WHERE lp.completed = true
      AND lp.completed_at IS NOT NULL
      AND EXTRACT(YEAR FROM lp.completed_at)::int = p_year
    GROUP BY lp.user_id
  ),
  sync_h AS (
    -- Synchrone : durée réelle des sessions signées
    SELECT a.user_id,
           sum(EXTRACT(EPOCH FROM (s.ends_at - s.starts_at)) / 3600.0) AS h
    FROM public.attendance_signatures a
    JOIN public.attendance_sessions s ON s.id = a.session_id
    WHERE EXTRACT(YEAR FROM a.signed_at)::int = p_year
    GROUP BY a.user_id
  )
  SELECT
    p.id        AS user_id,
    p.email,
    p.full_name,
    round(coalesce(async_h.h, 0) + coalesce(sync_h.h, 0), 1)::numeric AS hours_done
  FROM public.profiles p
  LEFT JOIN async_h ON async_h.user_id = p.id
  LEFT JOIN sync_h  ON sync_h.user_id  = p.id
  WHERE p.role = 'student'
    AND (async_h.h IS NOT NULL OR sync_h.h IS NOT NULL);
$$;

GRANT EXECUTE ON FUNCTION public.bpf_hours_for_year(int) TO authenticated;
