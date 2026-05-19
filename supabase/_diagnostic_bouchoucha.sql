-- =====================================================================
-- DIAGNOSTIC — Cas BOUCHOUCHA JOUNAIDI : pourquoi pas de contenu ?
-- À jouer dans Supabase Studio
-- =====================================================================

-- 1. Profil + enrollment de BOUCHOUCHA
SELECT
  '1. PROFIL & ENROLLMENT' AS section,
  p.email,
  p.full_name,
  p.role,
  e.status         AS enrollment_status,
  e.formation_slug,
  e.formation_id::text  AS formation_id,
  e.session_label,
  e.created_at::date    AS enroll_cree_le
FROM public.profiles p
LEFT JOIN public.enrollments e ON e.user_id = p.id
WHERE p.full_name ILIKE '%bouchoucha%'
   OR p.full_name ILIKE '%jounaidi%'
   OR p.email ILIKE '%bouchoucha%'
   OR p.email ILIKE '%jounaidi%';

-- 2. Vérification : la formation de BOUCHOUCHA a-t-elle des modules ?
SELECT
  '2. MODULES DE SA FORMATION' AS section,
  f.slug,
  f.title,
  f.active,
  count(fm.module_id) AS nb_modules_rattaches
FROM public.formations f
LEFT JOIN public.formation_modules fm ON fm.formation_id = f.id
WHERE f.id IN (
  SELECT e.formation_id
    FROM public.enrollments e
    JOIN public.profiles p ON p.id = e.user_id
   WHERE p.full_name ILIKE '%bouchoucha%'
      OR p.full_name ILIKE '%jounaidi%'
)
GROUP BY f.id, f.slug, f.title, f.active;

-- 3. État global des formations (rappel)
SELECT
  '3. CATALOGUE COMPLET' AS section,
  f.slug,
  f.title,
  count(fm.module_id) AS nb_modules
FROM public.formations f
LEFT JOIN public.formation_modules fm ON fm.formation_id = f.id
WHERE f.active = true
GROUP BY f.id, f.slug, f.title
ORDER BY f.code;
