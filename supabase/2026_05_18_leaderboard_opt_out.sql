-- =====================================================================
-- Sprint 1 / Gamification — Opt-out classement public
-- 2026-05-18
--
-- Le stagiaire peut désormais choisir de ne plus apparaître dans le
-- classement public (/classement) et la vue leaderboard_public.
-- Sa progression individuelle reste évidemment visible pour lui (XP,
-- niveau, série, badges).
--
-- Implémentation :
--   1. Ajout d'une colonne `leaderboard_opt_out boolean` sur `profiles`.
--   2. La RPC `leaderboard(period, limit)` filtre les opt-out.
--   3. La vue `leaderboard_public` filtre également.
--   4. RPC `set_leaderboard_opt_out(bool)` pour basculer côté UI.
-- =====================================================================

-- 1. Colonne (par défaut : inscrit au classement)
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS leaderboard_opt_out boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.profiles.leaderboard_opt_out IS
  'Si true, le stagiaire est exclu du classement public.';

-- 2. Vue leaderboard_public — filtre les opt-out
DROP VIEW IF EXISTS public.leaderboard_public CASCADE;
CREATE VIEW public.leaderboard_public AS
SELECT
  row_number() OVER (ORDER BY ug.total_xp DESC) AS rank,
  ug.user_id,
  CASE
    WHEN ug.full_name IS NOT NULL AND length(ug.full_name) > 0
      THEN regexp_replace(ug.full_name, '(\S+)\s+(\S)\S*', '\1 \2.')
    ELSE split_part(ug.email,'@',1)
  END AS display_name,
  ug.total_xp,
  ug.level
FROM public.user_gamification ug
JOIN public.profiles p ON p.id = ug.user_id
WHERE COALESCE(p.leaderboard_opt_out, false) = false
ORDER BY ug.total_xp DESC
LIMIT 50;

GRANT SELECT ON public.leaderboard_public TO authenticated;

-- 3. RPC `leaderboard(period, limit)` — filtre les opt-out
CREATE OR REPLACE FUNCTION public.leaderboard(
  p_period text DEFAULT 'all',
  p_limit int DEFAULT 50
)
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
    WHERE p.role = 'student'
      AND COALESCE(p.disabled, false) = false
      AND COALESCE(p.leaderboard_opt_out, false) = false
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

-- 4. RPC de bascule pour le stagiaire courant
CREATE OR REPLACE FUNCTION public.set_leaderboard_opt_out(p_opt_out boolean)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user uuid := auth.uid();
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'Forbidden: not authenticated';
  END IF;
  UPDATE public.profiles
     SET leaderboard_opt_out = COALESCE(p_opt_out, false)
   WHERE id = v_user;
  RETURN COALESCE(p_opt_out, false);
END;
$$;

GRANT EXECUTE ON FUNCTION public.set_leaderboard_opt_out(boolean) TO authenticated;
