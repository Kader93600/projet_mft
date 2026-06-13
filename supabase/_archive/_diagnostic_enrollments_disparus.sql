-- =====================================================================
-- DIAGNOSTIC URGENT — Pourquoi les enrollments ont-ils disparu ?
-- À jouer dans Supabase Studio → SQL Editor
-- =====================================================================

-- 1. État brut de la table enrollments (bypass RLS car postgres admin)
SELECT
  '1. ENROLLMENTS BRUT (toutes lignes, tous statuts)' AS section,
  count(*)                                              AS total,
  count(*) FILTER (WHERE status = 'en_cours')         AS en_cours,
  count(*) FILTER (WHERE status = 'prospect')         AS prospect,
  count(*) FILTER (WHERE status = 'refuse')           AS refuse,
  count(*) FILTER (WHERE status = 'abandon')          AS abandon
FROM public.enrollments;

-- 2. Détail de chaque enrollment (s'il y en a)
SELECT
  '2. DÉTAIL ENROLLMENTS' AS section,
  e.id::text                       AS enrollment_id,
  p.email,
  e.status,
  e.formation_slug,
  e.formation_id::text             AS formation_id_uuid,
  e.session_label,
  e.created_at::date               AS cree_le
FROM public.enrollments e
LEFT JOIN public.profiles p ON p.id = e.user_id
ORDER BY e.created_at DESC;

-- 3. État RLS : combien de policies actives sur enrollments ?
SELECT
  '3. POLICIES ACTIVES ENROLLMENTS' AS section,
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'enrollments';

-- 4. Rôles des 6 stagiaires (rappel)
SELECT
  '4. RÔLES' AS section,
  email,
  role,
  full_name
FROM public.profiles
ORDER BY created_at DESC;
