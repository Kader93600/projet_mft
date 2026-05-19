-- =====================================================================
-- DIAGNOSTIC #3 — Simule EXACTEMENT la requête du dashboard
-- pour ayman.sfaxi90@gmail.com
--
-- Si cette requête renvoie ≥ 1 ligne, alors la data est OK et le
-- problème est côté front (cache PWA / service worker).
-- Si elle renvoie 0 ligne, on a un autre souci RLS / data.
-- =====================================================================

WITH target AS (
  SELECT id FROM public.profiles
   WHERE email = 'ayman.sfaxi90@gmail.com'
)
SELECT
  '1. Enrollments retournés par le dashboard' AS step,
  e.id::text                                  AS detail,
  e.formation_slug                            AS info1,
  e.formation_id::text                        AS info2,
  e.status                                    AS info3
FROM public.enrollments e
WHERE e.user_id = (SELECT id FROM target)
  AND e.formation_id IS NOT NULL
  AND e.status NOT IN ('refuse','abandon')

UNION ALL

SELECT
  '2. formation_modules accessibles'           AS step,
  fm.module_id::text                           AS detail,
  m.title                                      AS info1,
  m.slug                                       AS info2,
  fm.formation_id::text                        AS info3
FROM public.formation_modules fm
JOIN public.modules m ON m.id = fm.module_id
WHERE fm.formation_id IN (
  SELECT formation_id
    FROM public.enrollments
   WHERE user_id = (SELECT id FROM target)
     AND formation_id IS NOT NULL
     AND status NOT IN ('refuse','abandon')
)
LIMIT 50;
