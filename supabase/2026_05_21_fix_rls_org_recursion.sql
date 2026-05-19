-- =====================================================================
-- HOTFIX — RLS récursion infinie sur organization_members
-- 2026-05-19
--
-- Cause exacte (confirmée via /api/debug/rls + diagnostic SQL) :
--   ERROR 42P17: infinite recursion detected in policy for relation
--   "organization_members"
--
-- Les policies suivantes faisaient une sous-requête EXISTS sur la
-- même table `organization_members` qu'elles protègent :
--   - organization_members_org_admin
--   - organization_members_self_read
--   - enrollments_org_admin (qui interroge transitivement organization_members)
--   - organizations_member_read (idem)
--
-- Postgres détecte la récursion entre policies (pas dans la query) et
-- avorte avec 42P17. Côté Supabase JS, la query renvoie silencieusement
-- `null` → toute requête SELECT sur enrollments échoue côté session
-- (alors qu'elle marche en service_role qui bypass RLS).
--
-- FIX : on encapsule les lookups dans 2 fonctions SECURITY DEFINER :
--   - public.is_org_admin_of(uuid) : auth.uid() est-il org_admin de
--     cette orga ?
--   - public.is_org_member_of(uuid) : auth.uid() est-il membre de
--     cette orga (n'importe quel rôle) ?
--
-- Ces fonctions s'exécutent avec les droits de postgres → bypass des
-- RLS sur organization_members → pas de récursion.
-- =====================================================================

-- ─── 1) Helpers SECURITY DEFINER (avec SET search_path obligatoire) ───

CREATE OR REPLACE FUNCTION public.is_org_admin_of(p_org_id uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
  SELECT EXISTS(
    SELECT 1 FROM public.organization_members m
    WHERE m.organization_id = p_org_id
      AND m.user_id = auth.uid()
      AND m.role = 'org_admin'
  );
$$;

CREATE OR REPLACE FUNCTION public.is_org_member_of(p_org_id uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
  SELECT EXISTS(
    SELECT 1 FROM public.organization_members m
    WHERE m.organization_id = p_org_id
      AND m.user_id = auth.uid()
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_org_admin_of(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_org_member_of(uuid) TO authenticated;

-- ─── 2) Recrée les policies sans récursion ────────────────────────────

-- ─ organizations : un membre voit son orga
DROP POLICY IF EXISTS organizations_member_read ON public.organizations;
CREATE POLICY organizations_member_read ON public.organizations
  FOR SELECT USING (
    public.is_org_member_of(organizations.id)
  );

-- ─ organization_members : un org_admin gère SON orga
DROP POLICY IF EXISTS organization_members_org_admin ON public.organization_members;
CREATE POLICY organization_members_org_admin ON public.organization_members
  FOR ALL
  USING (public.is_org_admin_of(organization_members.organization_id))
  WITH CHECK (public.is_org_admin_of(organization_members.organization_id));

-- ─ organization_members : tout membre voit la liste de son orga
DROP POLICY IF EXISTS organization_members_self_read ON public.organization_members;
CREATE POLICY organization_members_self_read ON public.organization_members
  FOR SELECT USING (
    user_id = auth.uid()
    OR public.is_org_member_of(organization_members.organization_id)
  );

-- ─ enrollments : un membre orga (admin OU viewer) voit les enrollments
--   de SON orga. On recrée avec la fonction is_org_member_of pour
--   éviter la récursion transitive.
DROP POLICY IF EXISTS enrollments_org_admin ON public.enrollments;
CREATE POLICY enrollments_org_admin ON public.enrollments
  FOR SELECT USING (
    organization_id IS NOT NULL
    AND public.is_org_member_of(enrollments.organization_id)
  );

-- ─── 3) Vérification ──────────────────────────────────────────────────

DO $$
DECLARE
  n_policies int;
  n_helpers int;
BEGIN
  SELECT count(*) INTO n_policies
    FROM pg_policies
   WHERE schemaname = 'public'
     AND tablename IN ('enrollments', 'organization_members', 'organizations');

  SELECT count(*) INTO n_helpers
    FROM pg_proc
   WHERE proname IN ('is_org_admin_of', 'is_org_member_of')
     AND pronamespace = 'public'::regnamespace;

  RAISE NOTICE '════════ HOTFIX RLS org récursion ════════';
  RAISE NOTICE '  Helpers créés (is_org_*) ................. %', n_helpers;
  RAISE NOTICE '  Total policies (enr+org+org_members) ..... %', n_policies;
  RAISE NOTICE '════════════════════════════════════════════';
  RAISE NOTICE '  Test rapide à jouer ensuite :';
  RAISE NOTICE '    1. Visite /api/debug/rls (super_admin)';
  RAISE NOTICE '    2. enrollments_via_session_client doit valoir 6';
  RAISE NOTICE '       (au lieu de null avant ce fix)';
END $$;

-- ─── 4) Bloc de test optionnel (à dérouler manuellement) ──────────────
-- BEGIN;
--   SET LOCAL role = 'authenticated';
--   SET LOCAL request.jwt.claims =
--     '{"sub":"e06f3696-0d89-4472-9404-11cd817303cc","role":"authenticated"}';
--   SELECT count(*) FROM public.enrollments;  -- attendu : 6 (toutes visibles via is_admin)
--   SELECT count(*) FROM public.organization_members;  -- attendu : 0 ou N sans crash
-- ROLLBACK;
