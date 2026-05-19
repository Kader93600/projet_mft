-- =====================================================================
-- P3 #3 / Sprint B — UTM tracking + funnel multi-touch (first-touch)
-- 2026-05-20
--
-- Décisions client (cf. docs/p3-3-marketing-data.md) :
--   • Attribution : first-touch (le premier canal qui a amené le visiteur)
--   • Cookie : visitor_id httpOnly 90j, traité comme essentiel au service
--     (intérêt légitime RGPD, mentionné dans la privacy)
--   • Périmètre : pages publiques uniquement
--
-- Tables :
--   • acquisition_events : 1 ligne par événement (landing, signup, etc.)
--
-- Vues :
--   • acquisition_attribution : first-touch par visitor_id
--   • vw_admin_funnel_by_utm  : funnel agrégé par source × medium
--
-- L'identité du visiteur :
--   • Pré-inscription : `visitor_id` (UUID dans cookie mft_vid 90j)
--   • Post-inscription : `user_id` (rempli lors du link visitor → user)
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- 1. Table acquisition_events
-- ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.acquisition_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Identité
  visitor_id text NOT NULL,                   -- UUID v4 généré côté serveur, stocké en cookie 90j
  user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  -- UTM (cf. Google Analytics standard)
  utm_source text,                            -- "instagram", "linkedin", "newsletter"
  utm_medium text,                            -- "social", "email", "cpc"
  utm_campaign text,                          -- "summer_2026"
  utm_content text,                           -- variation A/B
  utm_term text,                              -- mot-clé (Google Ads)
  -- Contexte
  referrer text,                              -- document.referrer (page d'origine)
  landing_page text NOT NULL,                 -- la page d'atterrissage (/, /tarifs, /formations/gotrm, …)
  user_agent text,                            -- pour filtrer les bots
  ip_country text,                            -- via Vercel geo (sans IP brute, RGPD-ok)
  -- Événement
  kind text NOT NULL CHECK (kind IN (
    'landing',       -- arrivée sur une page publique
    'contact_form',  -- formulaire de contact soumis
    'signup',        -- création de compte
    'enrollment'     -- inscription payée (lien Stripe webhook)
  )),
  occurred_at timestamptz NOT NULL DEFAULT now()
);

-- Index
CREATE INDEX IF NOT EXISTS acquisition_events_visitor_idx
  ON public.acquisition_events(visitor_id, occurred_at);
CREATE INDEX IF NOT EXISTS acquisition_events_user_idx
  ON public.acquisition_events(user_id, occurred_at)
  WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS acquisition_events_campaign_idx
  ON public.acquisition_events(utm_source, utm_campaign)
  WHERE utm_source IS NOT NULL;
CREATE INDEX IF NOT EXISTS acquisition_events_kind_idx
  ON public.acquisition_events(kind, occurred_at);

-- ─────────────────────────────────────────────────────────────────────
-- 2. RLS — admin only (les data sont sensibles côté marketing)
-- ─────────────────────────────────────────────────────────────────────
ALTER TABLE public.acquisition_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS acquisition_events_admin ON public.acquisition_events;
CREATE POLICY acquisition_events_admin ON public.acquisition_events
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Note : l'INSERT depuis le client public se fera via /api/acquisition/track
-- en service_role (bypass RLS), pas depuis RLS.

-- ─────────────────────────────────────────────────────────────────────
-- 3. Vue : attribution first-touch
-- ─────────────────────────────────────────────────────────────────────
-- Pour chaque visitor_id, retourne le PREMIER événement enregistré.
-- Ce sera la source d'acquisition "officielle" pour ce visiteur,
-- même si on a plusieurs visites ultérieures avec d'autres canaux.
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.acquisition_attribution
WITH (security_invoker = on)
AS
SELECT DISTINCT ON (visitor_id)
  visitor_id,
  user_id,
  utm_source,
  utm_medium,
  utm_campaign,
  utm_content,
  utm_term,
  referrer,
  landing_page,
  occurred_at AS first_touch_at
FROM public.acquisition_events
ORDER BY visitor_id, occurred_at ASC;

GRANT SELECT ON public.acquisition_attribution TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 4. Vue : funnel par utm_source / medium (admin)
-- ─────────────────────────────────────────────────────────────────────
-- Métriques par canal :
--   • visitors    : nombre de visiteurs uniques (anonymes ou identifiés)
--   • signups     : nombre qui ont créé un compte
--   • enrollments : nombre qui ont payé une inscription
--   • conversion_pct : taux signup → enrollment
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.vw_admin_funnel_by_utm
WITH (security_invoker = on)
AS
WITH attrib AS (
  SELECT * FROM public.acquisition_attribution
),
signups AS (
  -- Tous les visitors qui ont fini par avoir un user_id (créé un compte)
  SELECT DISTINCT visitor_id, user_id
  FROM public.acquisition_events
  WHERE user_id IS NOT NULL
),
enrolled AS (
  -- Tous les users qui ont une enrollment non-refusée
  SELECT DISTINCT user_id
  FROM public.enrollments
  WHERE status NOT IN ('refuse', 'abandon')
)
SELECT
  COALESCE(a.utm_source, 'direct') AS source,
  COALESCE(a.utm_medium, '(none)') AS medium,
  COALESCE(a.utm_campaign, '(none)') AS campaign,
  count(DISTINCT a.visitor_id)::int AS visitors,
  count(DISTINCT s.visitor_id)::int AS signups,
  count(DISTINCT e.user_id)::int AS enrollments,
  CASE
    WHEN count(DISTINCT s.visitor_id) > 0
    THEN round(100.0 * count(DISTINCT e.user_id)
              / NULLIF(count(DISTINCT s.visitor_id), 0), 1)
    ELSE NULL
  END AS conversion_pct,
  -- Date du premier événement par source (pour tri chronologique)
  min(a.first_touch_at) AS first_seen_at,
  max(a.first_touch_at) AS last_seen_at
FROM attrib a
LEFT JOIN signups s ON s.visitor_id = a.visitor_id
LEFT JOIN enrolled e ON e.user_id = a.user_id OR e.user_id = s.user_id
GROUP BY 1, 2, 3
ORDER BY enrollments DESC NULLS LAST, signups DESC NULLS LAST, visitors DESC;

GRANT SELECT ON public.vw_admin_funnel_by_utm TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 5. Vue : top campagnes (entonnoir par campaign)
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.vw_admin_top_campaigns
WITH (security_invoker = on)
AS
SELECT
  COALESCE(a.utm_campaign, '(none)') AS campaign,
  COALESCE(a.utm_source, 'direct') AS source,
  count(DISTINCT a.visitor_id)::int AS visitors,
  count(DISTINCT a.user_id)::int AS signups,
  min(a.first_touch_at) AS started_at,
  max(a.first_touch_at) AS last_seen_at
FROM public.acquisition_attribution a
WHERE a.utm_campaign IS NOT NULL
GROUP BY 1, 2
ORDER BY signups DESC, visitors DESC;

GRANT SELECT ON public.vw_admin_top_campaigns TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 6. Vue : volume journalier 30j (pour la courbe)
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.vw_admin_acquisition_daily
WITH (security_invoker = on)
AS
WITH days AS (
  SELECT generate_series(
    (current_date - INTERVAL '30 days')::date,
    current_date,
    INTERVAL '1 day'
  )::date AS day
),
landings AS (
  SELECT
    date_trunc('day', occurred_at)::date AS day,
    COALESCE(utm_source, 'direct') AS source,
    count(DISTINCT visitor_id)::int AS visitors
  FROM public.acquisition_events
  WHERE kind = 'landing'
    AND occurred_at >= now() - INTERVAL '30 days'
  GROUP BY 1, 2
)
SELECT d.day, l.source, COALESCE(l.visitors, 0) AS visitors
FROM days d
LEFT JOIN landings l ON l.day = d.day
ORDER BY d.day DESC, l.source;

GRANT SELECT ON public.vw_admin_acquisition_daily TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 7. RPC : link visitor_id → user_id (appelé à signup)
-- ─────────────────────────────────────────────────────────────────────
-- Quand un user crée son compte, on transforme tous ses anciens
-- événements anonymes en événements identifiés. Appelé côté serveur.
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.link_visitor_to_user(
  p_visitor_id text,
  p_user_id uuid
)
RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_updated int;
BEGIN
  IF p_visitor_id IS NULL OR p_user_id IS NULL THEN
    RETURN 0;
  END IF;
  UPDATE public.acquisition_events
     SET user_id = p_user_id
   WHERE visitor_id = p_visitor_id
     AND user_id IS NULL;
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RETURN v_updated;
END;
$$;

GRANT EXECUTE ON FUNCTION public.link_visitor_to_user(text, uuid) TO authenticated, service_role;
