-- Version courte : juste l'état de enrollments
-- ─────────────────────────────────────────────────
SELECT
  count(*)                                            AS total_lignes,
  count(*) FILTER (WHERE status = 'en_cours')        AS en_cours,
  count(*) FILTER (WHERE status = 'prospect')        AS prospect,
  count(*) FILTER (WHERE status NOT IN ('refuse','abandon')) AS actifs
FROM public.enrollments;

-- Détail (max 20)
SELECT
  e.id::text                  AS enrollment_id,
  p.email,
  e.status,
  e.formation_slug,
  e.session_label,
  e.created_at::date
FROM public.enrollments e
LEFT JOIN public.profiles p ON p.id = e.user_id
ORDER BY e.created_at DESC
LIMIT 20;
