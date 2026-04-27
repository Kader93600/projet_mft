-- =====================================================================
-- Classement par fenêtre temporelle (semaine / mois / total)
-- Recalculé à la volée depuis xp_events.
-- =====================================================================

-- Fonction paramétrable : période 'week' | 'month' | 'all'
CREATE OR REPLACE FUNCTION public.leaderboard(p_period text DEFAULT 'all', p_limit int DEFAULT 50)
RETURNS TABLE (
  rank int,
  user_id uuid,
  display_name text,
  total_xp int,
  level int
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  cutoff timestamptz;
BEGIN
  cutoff := CASE p_period
    WHEN 'week'  THEN date_trunc('week', now())
    WHEN 'month' THEN date_trunc('month', now())
    ELSE 'epoch'::timestamptz
  END;

  RETURN QUERY
  WITH agg AS (
    SELECT
      e.user_id,
      sum(e.points)::int AS xp
    FROM public.xp_events e
    WHERE e.created_at >= cutoff
    GROUP BY e.user_id
  ),
  joined AS (
    SELECT
      a.user_id,
      a.xp,
      p.full_name,
      p.email
    FROM agg a
    JOIN public.profiles p ON p.id = a.user_id
    WHERE p.role = 'student' AND COALESCE(p.disabled, false) = false
  )
  SELECT
    (row_number() OVER (ORDER BY j.xp DESC))::int AS rank,
    j.user_id,
    CASE
      WHEN j.full_name IS NOT NULL AND length(j.full_name) > 0
        THEN regexp_replace(j.full_name, '(\S+)\s+(\S)\S*', '\1 \2.')
      ELSE split_part(j.email, '@', 1)
    END AS display_name,
    j.xp AS total_xp,
    public.xp_level(j.xp) AS level
  FROM joined j
  ORDER BY j.xp DESC
  LIMIT p_limit;
END;
$$;

GRANT EXECUTE ON FUNCTION public.leaderboard(text, int) TO authenticated;

-- XP gagné par l'utilisateur courant sur la période (pour situer son rang)
CREATE OR REPLACE FUNCTION public.my_period_xp(p_period text DEFAULT 'all')
RETURNS int LANGUAGE plpgsql STABLE AS $$
DECLARE
  cutoff timestamptz;
  uid uuid := auth.uid();
  v int;
BEGIN
  IF uid IS NULL THEN RETURN 0; END IF;
  cutoff := CASE p_period
    WHEN 'week'  THEN date_trunc('week', now())
    WHEN 'month' THEN date_trunc('month', now())
    ELSE 'epoch'::timestamptz
  END;
  SELECT coalesce(sum(points), 0)::int INTO v
  FROM public.xp_events
  WHERE user_id = uid AND created_at >= cutoff;
  RETURN v;
END;
$$;

GRANT EXECUTE ON FUNCTION public.my_period_xp(text) TO authenticated;
