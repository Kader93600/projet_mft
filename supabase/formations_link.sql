-- =====================================================================
-- Multi-formations : on attache un slug de formation aux dossiers
-- (côté demande de prospect ET côté inscription confirmée).
-- Le slug pointe vers le catalogue de lib/formations-config.ts.
-- =====================================================================

ALTER TABLE public.enrollments
  ADD COLUMN IF NOT EXISTS formation_slug text;

ALTER TABLE public.enrollment_requests
  ADD COLUMN IF NOT EXISTS formation_slug text;

CREATE INDEX IF NOT EXISTS enrollments_formation_slug_idx
  ON public.enrollments(formation_slug);
CREATE INDEX IF NOT EXISTS enrollment_requests_formation_slug_idx
  ON public.enrollment_requests(formation_slug);

-- Vue d'aide pour l'admin : compter les demandes par formation
CREATE OR REPLACE VIEW public.formations_demand AS
SELECT
  coalesce(formation_slug, 'unspecified') AS formation_slug,
  count(*)::int                            AS requests,
  count(*) FILTER (WHERE created_at >= now() - INTERVAL '30 days')::int AS requests_30d,
  count(*) FILTER (WHERE status = 'nouveau')::int AS pending
FROM public.enrollment_requests
GROUP BY 1
ORDER BY requests DESC;

GRANT SELECT ON public.formations_demand TO authenticated;
