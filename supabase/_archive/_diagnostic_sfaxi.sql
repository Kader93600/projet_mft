-- =====================================================================
-- DIAGNOSTIC — Pourquoi le stagiaire ne voit aucun module ?
-- À jouer dans Supabase Studio → SQL Editor
--
-- Cette requête liste TOUT ce qui détermine la visibilité des modules
-- pour les stagiaires. Aucune mutation, lecture seule.
-- =====================================================================

-- 1. ÉTAT DES ENROLLMENTS
SELECT
  '1. ENROLLMENTS' AS section,
  p.email,
  p.full_name,
  e.id              AS enrollment_id,
  e.status,
  e.formation_id,
  e.formation_slug,
  f.slug            AS formation_slug_via_id,
  f.title           AS formation_title,
  f.active          AS formation_active,
  e.created_at::date
FROM public.profiles p
LEFT JOIN public.enrollments e ON e.user_id = p.id
LEFT JOIN public.formations f  ON f.id = e.formation_id
WHERE p.role = 'student'
ORDER BY p.created_at DESC;

-- 2. ÉTAT DE formation_modules (chaque formation a-t-elle des modules ?)
SELECT
  '2. FORMATION_MODULES' AS section,
  f.slug,
  f.title,
  f.active,
  count(fm.module_id) AS nb_modules_rattaches
FROM public.formations f
LEFT JOIN public.formation_modules fm ON fm.formation_id = f.id
GROUP BY f.id, f.slug, f.title, f.active
ORDER BY f.code;

-- 3. ÉTAT DES MODULES (combien existent ? combien rattachés à au moins une formation ?)
SELECT
  '3. MODULES' AS section,
  count(*)                                          AS total_modules,
  count(*) FILTER (WHERE EXISTS (
    SELECT 1 FROM public.formation_modules fm WHERE fm.module_id = m.id
  ))                                                AS rattaches_a_une_formation,
  count(*) FILTER (WHERE NOT EXISTS (
    SELECT 1 FROM public.formation_modules fm WHERE fm.module_id = m.id
  ))                                                AS orphelins_sans_formation
FROM public.modules m;

-- 4. ÉTAT DE formations_demand
SELECT
  '4. FORMATIONS_DEMAND' AS section,
  *
FROM public.formations_demand
ORDER BY formation_slug;

-- 5. POUR CHAQUE STAGIAIRE : combien de modules SONT ACCESSIBLES via la chaîne
--    enrollment → formation → formation_modules → modules ?
SELECT
  '5. ACCÈS THÉORIQUE PAR STAGIAIRE' AS section,
  p.email,
  p.full_name,
  count(DISTINCT fm.module_id) AS nb_modules_accessibles,
  string_agg(DISTINCT f.slug, ', ') AS formations_via_enrollment
FROM public.profiles p
LEFT JOIN public.enrollments e ON e.user_id = p.id
  AND e.status NOT IN ('refuse','abandon')
LEFT JOIN public.formations f ON f.id = e.formation_id
LEFT JOIN public.formation_modules fm ON fm.formation_id = f.id
WHERE p.role = 'student'
GROUP BY p.id, p.email, p.full_name
ORDER BY p.created_at DESC;
