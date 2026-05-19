-- =====================================================================
-- DIAGNOSTIC RLS SILENCIEUX — 2026-05-21
--
-- À jouer dans Supabase Studio (SQL Editor) en tant que `postgres`.
--
-- 3 sections :
--   PART A — Installation des RPCs auxiliaires utilisées par
--            /api/debug/rls/route.ts (debug_whoami, debug_list_policies)
--   PART B — Diagnostics SQL pédagogiques en lecture (lit pg_policies +
--            teste les helpers is_admin/has_formation_access)
--   PART C — Simulation d'une session authentifiée (SET LOCAL role +
--            request.jwt.claims) pour reproduire le bug RLS hors HTTP.
--
-- N'altère AUCUNE policy. Aucun risque de production.
-- =====================================================================

-- ─── PART A — RPCs auxiliaires ────────────────────────────────────────

-- 1) debug_whoami : permet à /api/debug/rls de comparer auth.uid() vu
-- depuis PostgreSQL (à travers le JWT) avec user.id vu depuis Next.
-- SECURITY INVOKER explicite : on veut le comportement avec le JWT du
-- caller, pas du postgres owner.
CREATE OR REPLACE FUNCTION public.debug_whoami()
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public, auth
AS $$
  SELECT jsonb_build_object(
    'uid', auth.uid(),
    'role', auth.role(),
    'jwt_sub', current_setting('request.jwt.claims', true)::jsonb ->> 'sub'
  );
$$;

GRANT EXECUTE ON FUNCTION public.debug_whoami() TO authenticated;

-- 2) debug_list_policies : retourne la liste des policies actives sur
-- les tables sensibles. Réservé aux admins pour ne pas exposer la
-- structure RLS au tout-venant.
CREATE OR REPLACE FUNCTION public.debug_list_policies()
RETURNS TABLE (
  schemaname text,
  tablename  text,
  policyname text,
  cmd        text,
  permissive text,
  roles      text[],
  qual       text,
  with_check text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  RETURN QUERY
    SELECT
      p.schemaname::text,
      p.tablename::text,
      p.policyname::text,
      p.cmd::text,
      p.permissive::text,
      p.roles::text[],
      p.qual::text,
      p.with_check::text
    FROM pg_policies p
    WHERE p.schemaname = 'public'
      AND p.tablename IN (
        'enrollments','modules','lessons','quizzes','profiles',
        'formation_modules','formations','organization_members'
      )
    ORDER BY p.tablename, p.policyname;
END;
$$;

GRANT EXECUTE ON FUNCTION public.debug_list_policies() TO authenticated;


-- ─── PART B — Lectures diagnostiques ──────────────────────────────────

-- B.1 — État de chaque function helper : owner, security, search_path
SELECT
  n.nspname        AS schema,
  p.proname        AS function,
  CASE p.prosecdef WHEN true THEN 'DEFINER' ELSE 'INVOKER' END AS security,
  CASE p.provolatile WHEN 's' THEN 'STABLE' WHEN 'i' THEN 'IMMUTABLE' WHEN 'v' THEN 'VOLATILE' END AS volatility,
  -- search_path explicite (SET search_path = ...) si configuré
  array_to_string(p.proconfig, ' | ') AS proconfig_set,
  pg_get_userbyid(p.proowner)         AS owner
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND p.proname IN (
    'is_admin','is_super_admin','is_staff','is_trainer',
    'has_formation_access','is_enrolled_in'
  )
ORDER BY p.proname;

-- B.2 — Policies actives sur enrollments + modules + lessons
SELECT
  tablename, policyname, cmd, permissive,
  qual        AS using_expr,
  with_check  AS with_check_expr
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('enrollments','modules','lessons','quizzes','profiles')
ORDER BY tablename, policyname;

-- B.3 — Test direct des helpers SANS contexte JWT (= depuis postgres)
-- ⚠️ Depuis Studio, auth.uid() retourne NULL car pas de JWT.
-- On teste donc en mode "donné un user explicite".
DO $diag$
DECLARE
  v_super uuid;
  v_count_enrollments int;
  v_has_access boolean;
BEGIN
  SELECT id INTO v_super FROM public.profiles WHERE role = 'super_admin' LIMIT 1;
  IF v_super IS NULL THEN
    RAISE NOTICE 'Aucun super_admin trouvé en base — skip diagnostic ciblé.';
    RETURN;
  END IF;

  SELECT count(*) INTO v_count_enrollments FROM public.enrollments;
  SELECT public.has_formation_access(v_super, 'gotrm') INTO v_has_access;

  RAISE NOTICE '═════ DIAGNOSTIC RLS — vue postgres (sans JWT) ════════════';
  RAISE NOTICE '  super_admin testé .......................... %', v_super;
  RAISE NOTICE '  count(enrollments) ........................ %', v_count_enrollments;
  RAISE NOTICE '  has_formation_access(super, gotrm) ........ %', v_has_access;
  RAISE NOTICE '════════════════════════════════════════════════════════════';
  RAISE NOTICE 'Pour tester le comportement RLS RÉEL, voir PART C ci-dessous.';
END $diag$;


-- ─── PART C — Simulation d'une session authentifiée ────────────────────
--
-- Pour reproduire ce que voit le user X depuis Next, on simule son JWT.
-- C'est LE test décisif : il bypass entièrement la couche HTTP/Next.
--
-- ⚠️ À adapter :
--   1) Remplacer <UUID_SUPER_ADMIN> par l'UUID d'un super_admin réel
--      (récupéré via : SELECT id, email FROM profiles WHERE role='super_admin')
--   2) Décommenter le bloc BEGIN...COMMIT pour exécuter.
--   3) ROLLBACK à la fin pour ne rien polluer.
--
-- BEGIN;
--   SET LOCAL role = 'authenticated';
--   SET LOCAL request.jwt.claims = '{"sub":"<UUID_SUPER_ADMIN>","role":"authenticated"}';
--
--   -- Test 1 : auth.uid() retourne-t-il l'UUID attendu ?
--   SELECT auth.uid() AS uid_vu_par_postgres;
--
--   -- Test 2 : is_admin() / is_super_admin() retournent-elles true ?
--   SELECT
--     public.is_admin()       AS is_admin,
--     public.is_super_admin() AS is_super_admin,
--     public.is_staff()       AS is_staff;
--
--   -- Test 3 : combien d'enrollments le super_admin voit-il ?
--   -- (devrait être ALL — toutes les inscriptions)
--   SELECT count(*) AS enrollments_visibles FROM public.enrollments;
--
--   -- Test 4 : combien de modules ?
--   SELECT count(*) AS modules_visibles FROM public.modules;
--
--   -- Test 5 : has_formation_access(self, 'gotrm') ?
--   SELECT public.has_formation_access(auth.uid(), 'gotrm') AS access_gotrm;
--
-- ROLLBACK;
--
-- ─── Cas spécial — tester un STUDENT ───────────────────────────────────
--
-- BEGIN;
--   SET LOCAL role = 'authenticated';
--   SET LOCAL request.jwt.claims = '{"sub":"<UUID_STUDENT>","role":"authenticated"}';
--
--   SELECT auth.uid();
--   SELECT public.is_admin();
--   SELECT count(*) FROM public.enrollments;
--   -- Doit retourner uniquement les enrollments du student (policy enrollments_self)
--
--   SELECT count(*) FROM public.modules;
--   -- Doit retourner les modules des formations où le student est inscrit
--
-- ROLLBACK;

-- ─── PART D — Détection des fonctions sans SET search_path ────────────
-- Trouve toutes les fonctions SECURITY DEFINER de public qui n'ont PAS
-- de SET search_path explicite. C'est typiquement la cause racine du
-- bug RLS silencieux (le search_path par défaut ne contient pas `auth`,
-- donc `auth.uid()` retourne NULL à l'intérieur de la function).
SELECT
  n.nspname AS schema,
  p.proname AS function,
  CASE WHEN p.proconfig IS NULL THEN 'AUCUN'
       WHEN NOT EXISTS (SELECT 1 FROM unnest(p.proconfig) c WHERE c LIKE 'search_path=%') THEN 'AUTRE CONFIG MAIS PAS search_path'
       ELSE array_to_string(p.proconfig, ' | ')
  END AS search_path_config,
  '⚠ À CORRIGER' AS status
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND p.prosecdef = true
  AND (
    p.proconfig IS NULL
    OR NOT EXISTS (SELECT 1 FROM unnest(p.proconfig) c WHERE c LIKE 'search_path=%')
  )
ORDER BY p.proname;
