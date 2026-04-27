-- =====================================================================
-- Tracking des recherches (insights pédagogiques)
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.search_logs (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  query text NOT NULL,
  query_norm text GENERATED ALWAYS AS (lower(btrim(query))) STORED,
  results_count int NOT NULL DEFAULT 0,
  kind_filter text, -- 'modules' | 'lessons' | 'quizzes' | 'glossary' | NULL = global
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS search_logs_query_norm_idx
  ON public.search_logs(query_norm);
CREATE INDEX IF NOT EXISTS search_logs_created_at_idx
  ON public.search_logs(created_at DESC);

ALTER TABLE public.search_logs ENABLE ROW LEVEL SECURITY;

-- Lecture admin uniquement (insights). Insertion : owner.
DROP POLICY IF EXISTS search_logs_admin_read ON public.search_logs;
CREATE POLICY search_logs_admin_read ON public.search_logs
  FOR SELECT USING (public.is_admin());

DROP POLICY IF EXISTS search_logs_self_insert ON public.search_logs;
CREATE POLICY search_logs_self_insert ON public.search_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Vue : top requêtes des 30 derniers jours, avec taux d'échec (0 résultat)
CREATE OR REPLACE VIEW public.search_top_queries AS
SELECT
  query_norm                                        AS query,
  count(*)::int                                     AS searches,
  count(*) FILTER (WHERE results_count = 0)::int    AS empty_results,
  round(
    100.0 * count(*) FILTER (WHERE results_count = 0)::numeric
         / NULLIF(count(*), 0),
    1
  )::numeric                                        AS empty_rate_pct,
  max(created_at)                                   AS last_searched_at
FROM public.search_logs
WHERE created_at >= now() - INTERVAL '30 days'
  AND length(query_norm) >= 2
GROUP BY query_norm
ORDER BY searches DESC, empty_results DESC;

GRANT SELECT ON public.search_top_queries TO authenticated;
