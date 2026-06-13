-- =====================================================================
-- DIAGNOSTIC #2 — Pourquoi UN seul student dans le résultat ?
-- À jouer dans Supabase Studio
-- =====================================================================

-- A. Distribution des rôles
SELECT
  'A. RÔLES' AS section,
  role,
  count(*)
FROM public.profiles
GROUP BY role
ORDER BY count(*) DESC;

-- B. Détail Sfaxi : role + enrollments
SELECT
  'B. DÉTAIL PROFILS SFAXI' AS section,
  p.id,
  p.email,
  p.full_name,
  p.role,
  p.created_at::date AS profil_cree
FROM public.profiles p
WHERE p.email ILIKE '%sfaxi%'
   OR p.full_name ILIKE '%sfaxi%'
ORDER BY p.created_at DESC;

-- C. Enrollments des Sfaxi (tous statuts confondus)
SELECT
  'C. ENROLLMENTS SFAXI' AS section,
  p.email,
  e.id              AS enrollment_id,
  e.status,
  e.formation_slug,
  e.formation_id,
  f.title           AS formation_title,
  e.created_at::date
FROM public.profiles p
LEFT JOIN public.enrollments e ON e.user_id = p.id
LEFT JOIN public.formations f  ON f.id = e.formation_id
WHERE p.email ILIKE '%sfaxi%'
   OR p.full_name ILIKE '%sfaxi%'
ORDER BY p.email, e.created_at DESC;

-- D. État global des enrollments (combien existent ? combien actifs ?)
SELECT
  'D. ENROLLMENTS GLOBAL' AS section,
  count(*)                                                   AS total,
  count(*) FILTER (WHERE status = 'en_cours')               AS en_cours,
  count(*) FILTER (WHERE status = 'prospect')               AS prospect,
  count(*) FILTER (WHERE status NOT IN ('refuse','abandon')) AS actifs,
  count(*) FILTER (WHERE formation_id IS NOT NULL)          AS avec_formation_id,
  count(*) FILTER (WHERE formation_slug IS NOT NULL)        AS avec_formation_slug
FROM public.enrollments;

-- E. formation_modules : est-ce que les formations ont bien des modules ?
SELECT
  'E. MODULES PAR FORMATION' AS section,
  f.slug,
  f.title,
  f.active,
  count(fm.module_id) AS nb_modules
FROM public.formations f
LEFT JOIN public.formation_modules fm ON fm.formation_id = f.id
GROUP BY f.id, f.slug, f.title, f.active
ORDER BY f.code;
