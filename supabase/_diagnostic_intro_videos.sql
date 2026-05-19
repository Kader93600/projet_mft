-- =====================================================================
-- DIAGNOSTIC — Vidéos d'intro module par module / par CCP
-- À jouer dans Supabase Studio
-- =====================================================================

-- 1. Pour chaque module GOTRM, quelle vidéo d'intro est attachée ?
SELECT
  '1. MODULES GOTRM AVEC VIDÉO' AS section,
  m.slug,
  m.title,
  b.code AS bloc_code,
  m.intro_video_path,
  m.intro_video_label,
  m.intro_video_duration_s,
  m."order"
FROM public.modules m
LEFT JOIN public.blocs b ON b.id = m.bloc_id
WHERE m.id IN (
  SELECT fm.module_id
    FROM public.formation_modules fm
    JOIN public.formations f ON f.id = fm.formation_id
   WHERE f.slug = 'gotrm'
)
ORDER BY b."order", m."order";

-- 2. Idem pour Capacité ≤ 3,5t (sanity check)
SELECT
  '2. MODULES CAPA' AS section,
  m.slug,
  m.title,
  m.intro_video_path,
  m.intro_video_label
FROM public.modules m
WHERE m.id IN (
  SELECT fm.module_id
    FROM public.formation_modules fm
    JOIN public.formations f ON f.id = fm.formation_id
   WHERE f.slug = 'capacite-3-5t'
)
ORDER BY m."order";

-- 3. Récap : combien de modules ont une vidéo intro ?
SELECT
  '3. RÉCAP VIDÉOS' AS section,
  f.slug AS formation,
  count(*) FILTER (WHERE m.intro_video_path IS NOT NULL) AS modules_avec_video,
  count(*) AS total_modules
FROM public.modules m
JOIN public.formation_modules fm ON fm.module_id = m.id
JOIN public.formations f ON f.id = fm.formation_id
GROUP BY f.slug
ORDER BY f.slug;
