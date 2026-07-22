-- =====================================================================
-- 2026-07-22 — HOTFIX : récursion infinie de policy sur profiles
-- =====================================================================
-- CONSIGNATION : DÉJÀ APPLIQUÉ en production le 22/07 (via MCP, vérifié).
-- Ré-exécutable sans dégât (DROP IF EXISTS + CREATE).
--
-- SYMPTÔME : « An error occurred in the Server Components render » sur
-- /admin/users/[id] dès qu'un admin modifiait la fiche d'un stagiaire.
-- Logs Vercel : `infinite recursion detected in policy for relation
-- "profiles"` (digest 547659223). Toute écriture sur profiles via une
-- session utilisateur était touchée (admin ET self-update stagiaire).
--
-- CAUSE : la policy profiles_self_update (issue de la consolidation du
-- 2026_07_13) portait un garde anti-élévation écrit avec des sous-requêtes
-- SUR profiles DANS une policy DE profiles :
--   role = (SELECT role FROM profiles WHERE id = auth.uid())
-- Postgres interdit cette auto-référence (le rewriter devrait ré-appliquer
-- les policies de la table en boucle) → 42P17 à chaque UPDATE.
--
-- CORRECTIF : même sémantique, mais la lecture passe par une fonction
-- SECURITY DEFINER (opaque pour le moteur de policies, comme is_admin()).
--
-- VÉRIFIÉ après application, en simulant une session authenticated :
--   ✅ UPDATE full_name par le propriétaire → passe (plus de récursion)
--   ✅ UPDATE role = 'admin' par le propriétaire → bloqué (42501)
--   ✅ aucune autre policy auto-référencée dans le schéma (balayage)
-- =====================================================================

BEGIN;

DROP FUNCTION IF EXISTS public.my_role_and_disabled();

-- Lit le rôle/disabled ACTUELS de l'appelant sans déclencher la RLS de
-- profiles (SECURITY DEFINER → pas d'expansion de policy, pas de récursion).
CREATE FUNCTION public.my_role_and_disabled()
RETURNS TABLE (role public.user_role, disabled boolean)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path TO 'public','auth','pg_temp'
AS $$ SELECT role, disabled FROM public.profiles WHERE id = auth.uid(); $$;

REVOKE EXECUTE ON FUNCTION public.my_role_and_disabled() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.my_role_and_disabled() TO authenticated, service_role;

DROP POLICY IF EXISTS profiles_self_update ON public.profiles;
CREATE POLICY profiles_self_update ON public.profiles
FOR UPDATE
USING ((SELECT auth.uid()) = id)
WITH CHECK (
  ((SELECT auth.uid()) = id)
  -- Garde anti-élévation inchangé : un utilisateur ne peut pas modifier
  -- son propre role ni son propre disabled.
  AND role IS NOT DISTINCT FROM (SELECT r.role FROM public.my_role_and_disabled() r)
  AND disabled IS NOT DISTINCT FROM (SELECT r.disabled FROM public.my_role_and_disabled() r)
);

COMMIT;
