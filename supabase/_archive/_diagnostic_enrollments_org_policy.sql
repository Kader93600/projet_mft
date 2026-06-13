-- =====================================================================
-- DIAGNOSTIC URGENT — Pourquoi enrollments.SELECT retourne NULL
-- À jouer dans Supabase Studio
-- =====================================================================

-- 1. La colonne organization_id existe-t-elle sur enrollments ?
SELECT
  '1. COLONNE organization_id' AS section,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'enrollments'
  AND column_name IN ('organization_id', 'seats_reserved');

-- 2. La table organization_members existe-t-elle ?
SELECT
  '2. TABLE organization_members' AS section,
  table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('organizations', 'organization_members');

-- 3. Liste toutes les policies actives sur enrollments
SELECT
  '3. POLICIES ENROLLMENTS' AS section,
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'enrollments'
ORDER BY policyname;

-- 4. Simulation : lance le SELECT en tant que super_admin
-- (Remplace l'UUID par celui de Sfaxi/Abdel, vu dans le JSON debug)
BEGIN;
  SET LOCAL role = 'authenticated';
  SET LOCAL request.jwt.claims = '{"sub":"e06f3696-0d89-4472-9404-11cd817303cc","role":"authenticated"}';
  -- Essai SELECT
  SELECT '4. SELECT TEST' AS section, count(*) FROM public.enrollments;
ROLLBACK;
