-- =====================================================================
-- Finition C / P3 #1 — RPCs admin pour le monitoring tuteur IA
-- 2026-05-18
--
-- Vues alimentant la page /admin/tutor :
--   • admin_tutor_top_consumers(days, limit) : top N stagiaires par coût
--   • admin_tutor_daily_cost(days)            : coût agrégé par jour
--
-- Sécurité : SECURITY DEFINER + check explicite is_admin/is_trainer pour
-- empêcher un utilisateur lambda d'invoquer la fonction (les RPCs sont
-- exposées à `authenticated` par défaut).
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- 1. Top consommateurs (chat tuteur uniquement, pas QR correction)
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.admin_tutor_top_consumers(
  p_days int DEFAULT 30,
  p_limit int DEFAULT 10
)
RETURNS TABLE (
  user_id uuid,
  full_name text,
  email text,
  messages_count bigint,
  cost_cents bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NOT (public.is_admin() OR public.is_trainer()) THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  RETURN QUERY
  SELECT
    p.id AS user_id,
    p.full_name,
    p.email,
    count(m.id) AS messages_count,
    coalesce(sum(m.cost_cents), 0)::bigint AS cost_cents
  FROM public.tutor_messages m
  JOIN public.tutor_conversations c ON c.id = m.conversation_id
  JOIN public.profiles p ON p.id = c.user_id
  WHERE m.role = 'assistant'
    AND m.created_at >= now() - make_interval(days => p_days)
  GROUP BY p.id, p.full_name, p.email
  ORDER BY cost_cents DESC, messages_count DESC
  LIMIT p_limit;
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_tutor_top_consumers(int, int) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 2. Coût journalier (chat + QR correction agrégés)
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.admin_tutor_daily_cost(p_days int DEFAULT 30)
RETURNS TABLE (
  day date,
  messages_count bigint,
  chat_cost_cents bigint,
  qr_cost_cents bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NOT (public.is_admin() OR public.is_trainer()) THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  RETURN QUERY
  WITH days_series AS (
    SELECT generate_series(
      (current_date - (p_days - 1) * interval '1 day')::date,
      current_date,
      interval '1 day'
    )::date AS day
  ),
  chat_agg AS (
    SELECT
      date_trunc('day', m.created_at)::date AS day,
      count(*)::bigint AS msg_count,
      coalesce(sum(m.cost_cents), 0)::bigint AS cost
    FROM public.tutor_messages m
    WHERE m.role = 'assistant'
      AND m.created_at >= now() - make_interval(days => p_days)
    GROUP BY 1
  ),
  qr_agg AS (
    SELECT
      date_trunc('day', q.ai_graded_at)::date AS day,
      coalesce(sum(q.ai_cost_cents), 0)::bigint AS cost
    FROM public.qr_responses q
    WHERE q.ai_graded_at IS NOT NULL
      AND q.ai_graded_at >= now() - make_interval(days => p_days)
    GROUP BY 1
  )
  SELECT
    d.day,
    coalesce(c.msg_count, 0)::bigint AS messages_count,
    coalesce(c.cost, 0)::bigint AS chat_cost_cents,
    coalesce(q.cost, 0)::bigint AS qr_cost_cents
  FROM days_series d
  LEFT JOIN chat_agg c ON c.day = d.day
  LEFT JOIN qr_agg  q ON q.day = d.day
  ORDER BY d.day DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_tutor_daily_cost(int) TO authenticated;
