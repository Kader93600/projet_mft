-- =====================================================================
-- Sprint 1 / Gamification — Daily login + streak bonus
-- 2026-05-18
--
-- Objectif : récompenser la régularité du stagiaire.
--
--   - `daily_login`  : +5 XP la première fois qu'on appelle la RPC du jour
--                      (déduplication par ref_id = current_date)
--   - `streak_bonus` : si le streak courant ≥ 3 jours consécutifs,
--                      bonus = min(streak * 5, 50) XP, ajouté une seule
--                      fois par jour (ref_id = current_date || '-streak')
--
-- La déduplication s'appuie sur l'index UNIQUE existant
-- `xp_events_unique_ref (user_id, kind, ref_id) WHERE ref_id IS NOT NULL`
-- déjà présent depuis gamification.sql.
--
-- Les `kind` 'daily_login' et 'streak_bonus' sont déjà autorisés par la
-- contrainte CHECK de xp_events (vérifié dans gamification.sql).
-- =====================================================================

CREATE OR REPLACE FUNCTION public.award_daily_login_xp(p_user uuid)
RETURNS TABLE (
  awarded_login int,
  awarded_streak int,
  current_streak int,
  longest_streak int
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_today text := current_date::text;
  v_login_inserted int := 0;
  v_streak_inserted int := 0;
  v_streak_row record;
  v_streak_points int := 0;
BEGIN
  -- Sécurité : seul l'utilisateur courant peut s'auto-attribuer son XP
  -- (ou un admin via RPC sans auth.uid()).
  IF auth.uid() IS NOT NULL AND auth.uid() <> p_user THEN
    RAISE EXCEPTION 'Forbidden: cannot award XP for another user';
  END IF;

  -- 1. +5 XP daily login (idempotent par jour)
  WITH ins AS (
    INSERT INTO public.xp_events(user_id, kind, points, ref_id)
    VALUES (p_user, 'daily_login', 5, v_today)
    ON CONFLICT DO NOTHING
    RETURNING 1
  )
  SELECT COALESCE(sum(1)::int, 0) INTO v_login_inserted FROM ins;

  -- 2. Calcul du streak courant via la RPC existante
  SELECT * INTO v_streak_row FROM public.user_streak(p_user);

  -- 3. Bonus de série : à partir de 3 jours consécutifs
  --    Formule : min(streak * 5, 50). Ex : 3j=15, 5j=25, 10j=50, 30j=50.
  IF v_streak_row.current_streak >= 3 THEN
    v_streak_points := LEAST(v_streak_row.current_streak * 5, 50);

    WITH ins AS (
      INSERT INTO public.xp_events(user_id, kind, points, ref_id)
      VALUES (
        p_user,
        'streak_bonus',
        v_streak_points,
        v_today || '-streak'
      )
      ON CONFLICT DO NOTHING
      RETURNING 1
    )
    SELECT COALESCE(sum(1)::int, 0) INTO v_streak_inserted FROM ins;
  END IF;

  RETURN QUERY SELECT
    (CASE WHEN v_login_inserted > 0 THEN 5 ELSE 0 END)::int AS awarded_login,
    (CASE WHEN v_streak_inserted > 0 THEN v_streak_points ELSE 0 END)::int AS awarded_streak,
    v_streak_row.current_streak,
    v_streak_row.longest_streak;
END;
$$;

GRANT EXECUTE ON FUNCTION public.award_daily_login_xp(uuid) TO authenticated;

-- =====================================================================
-- Test rapide (à supprimer en prod si besoin) :
--   SELECT * FROM public.award_daily_login_xp(auth.uid());
-- =====================================================================
