-- =====================================================================
-- FIX RLS SILENCIEUX — 2026-05-21
--
-- Bug observé : depuis 2026-05-19, les SELECT/UPDATE/INSERT venant des
-- Server Components Next 14 (client supabase/ssr créé depuis cookies)
-- sont bloqués silencieusement par RLS sur enrollments, modules, lessons,
-- quizzes, profiles — y compris pour les super_admin.
--
-- Symptômes :
--   - Dashboard student vide pour les super_admin (alors qu'ils ont des
--     enrollments valides)
--   - 404 sur /modules/[slug], /modules/[slug]/[lesson], /quiz/[id]
--   - /admin/enrollments affiche "Aucun dossier" alors qu'il y a 7 lignes
--   - Workaround temporaire dans 17 fichiers : on bascule sur
--     createAdminClient() (service_role qui bypass RLS)
--
-- ─── Cause racine identifiée (H2 + effet H1 dérivé) ────────────────────
--
-- TOUTES les fonctions helpers de permissions (is_admin, is_super_admin,
-- is_staff, has_formation_access, is_enrolled_in) ont été créées en
-- `SECURITY DEFINER STABLE` SANS `SET search_path`.
--
-- Quand PostgreSQL exécute une fonction SECURITY DEFINER appelée depuis
-- une policy RLS, il prend le search_path de l'OWNER de la fonction
-- (généralement `postgres` ou `supabase_admin`). Si cet owner n'a pas
-- `auth` dans son search_path, alors :
--   - `auth.uid()` à l'intérieur de la function retourne NULL silencieusement
--   - `is_admin()` retourne FALSE pour tout le monde (y compris super_admin)
--   - Toutes les policies qui dépendent de is_admin() rejettent la ligne
--   - L'écart "session client = 0 ligne / service_role = N lignes" est confirmé
--
-- C'est H2 (function buggy) qui se manifeste comme H1 (auth.uid() = null)
-- mais UNIQUEMENT à l'intérieur des helpers SECURITY DEFINER. En
-- dehors (= en SQL direct dans une policy comme `auth.uid() = user_id`),
-- la résolution de `auth` fonctionne via le search_path par défaut de la
-- session `authenticated`. D'où le bug observé : `enrollments_self`
-- (`auth.uid() = user_id OR is_admin()`) :
--   - branche gauche (`auth.uid() = user_id`) marche pour le user → il voit
--     ses propres enrollments
--   - branche droite (`is_admin()`) renvoie false même pour les staff
--     → ils ne voient QUE leurs propres enrollments aussi
--   - Et pour modules/lessons/quizzes, les policies passent par
--     `has_formation_access()` qui ne marche pas non plus
--   → tout staff devient invisible.
--
-- Le fix : ajouter `SET search_path = public, auth, pg_temp` à toutes
-- les helpers SECURITY DEFINER. C'est la pratique officielle Supabase
-- (cf. https://supabase.com/docs/guides/database/functions#security-definer-functions)
-- et c'est aussi un durcissement sécurité (anti search_path hijack).
--
-- En bonus, on consolide les 4 policies enrollments_* pour s'assurer
-- qu'elles couvrent bien tous les cas (PERMISSIVE OR explicite) — fix
-- H3 défensif.
--
-- ─── Idempotence ──────────────────────────────────────────────────────
-- Toutes les commandes utilisent CREATE OR REPLACE / DROP IF EXISTS.
-- Rejouable autant de fois que nécessaire.
-- =====================================================================

-- ─── 1) is_admin() avec search_path explicite ─────────────────────────
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
  SELECT EXISTS(
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
      AND role IN ('admin', 'super_admin')
  );
$$;

-- ─── 2) is_super_admin() ──────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
  SELECT EXISTS(
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'super_admin'
  );
$$;

-- ─── 3) is_staff() ────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.is_staff()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
  SELECT public.is_admin();
$$;

-- ─── 4) has_formation_access(uuid, text) ──────────────────────────────
-- On reprend la version étendue (slug OU formation_id) du fichier
-- 2026_05_20_fix_formation_slug_and_views.sql, mais avec search_path.
CREATE OR REPLACE FUNCTION public.has_formation_access(
  p_user uuid,
  p_slug text
) RETURNS boolean
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
  is_st boolean;
  has_enrollment boolean;
  has_habilitation boolean;
BEGIN
  -- Staff = accès à tout
  SELECT EXISTS(
    SELECT 1 FROM public.profiles
    WHERE id = p_user AND role IN ('admin','super_admin')
  ) INTO is_st;
  IF is_st THEN RETURN true; END IF;

  -- Trainer = accès à tout (même policy que staff côté lecture pédagogique)
  SELECT EXISTS(
    SELECT 1 FROM public.profiles
    WHERE id = p_user AND role = 'trainer'
  ) INTO is_st;
  IF is_st THEN RETURN true; END IF;

  -- Stagiaire inscrit — via slug OU via FK formation_id
  SELECT EXISTS(
    SELECT 1
      FROM public.enrollments e
 LEFT JOIN public.formations f ON f.id = e.formation_id
     WHERE e.user_id = p_user
       AND e.status NOT IN ('refuse','abandon')
       AND (
         e.formation_slug = p_slug
         OR f.slug = p_slug
       )
  ) INTO has_enrollment;
  IF has_enrollment THEN RETURN true; END IF;

  -- Formateur habilité (tolère absence de la table)
  BEGIN
    SELECT EXISTS(
      SELECT 1
        FROM public.trainer_formations tf
        JOIN public.formations f ON f.id = tf.formation_id
       WHERE tf.trainer_id = p_user AND f.slug = p_slug
    ) INTO has_habilitation;
    IF has_habilitation THEN RETURN true; END IF;
  EXCEPTION WHEN undefined_table THEN
    NULL;
  END;

  RETURN false;
END;
$$;

GRANT EXECUTE ON FUNCTION public.has_formation_access(uuid, text) TO authenticated;

-- ─── 5) is_enrolled_in(uuid, text) ────────────────────────────────────
CREATE OR REPLACE FUNCTION public.is_enrolled_in(
  p_user uuid,
  p_slug text
) RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
  SELECT EXISTS(
    SELECT 1 FROM public.enrollments
    WHERE user_id = p_user
      AND formation_slug = p_slug
      AND status NOT IN ('refuse','abandon')
  );
$$;

-- ─── 6) Tant qu'on y est, on durcit aussi is_trainer() au cas où ──────
-- (créé en step1 — on tolère son absence si la migration n'est pas jouée)
DO $patch_trainer$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND p.proname = 'is_trainer'
  ) THEN
    EXECUTE $f$
      CREATE OR REPLACE FUNCTION public.is_trainer()
      RETURNS boolean
      LANGUAGE sql
      STABLE
      SECURITY DEFINER
      SET search_path = public, auth, pg_temp
      AS $body$
        SELECT EXISTS(
          SELECT 1 FROM public.profiles
          WHERE id = auth.uid() AND role = 'trainer'
        );
      $body$;
    $f$;
    RAISE NOTICE 'is_trainer() : search_path patché.';
  ELSE
    RAISE NOTICE 'is_trainer() : non présente, skip.';
  END IF;
END $patch_trainer$;

-- ─── 7) Recréation des policies enrollments (fix H3 défensif) ─────────
-- Toutes les policies SELECT sont PERMISSIVE par défaut → leurs USING
-- sont combinés via OR. On ré-affirme les 4 policies pour garantir que
-- :
--   • enrollments_self        → user voit ses propres lignes
--   • enrollments_admin       → staff voit tout (ALL → SELECT+ins+upd+del)
--   • enrollments_funder_read → financeur voit ses dossiers
--   • enrollments_org_admin   → org_admin/org_viewer voit son orga
--
-- IMPORTANT : aucune policy n'est RESTRICTIVE ici. Postgres combine les
-- PERMISSIVE en OR. Une seule doit matcher pour que la ligne soit visible.

DROP POLICY IF EXISTS enrollments_self ON public.enrollments;
CREATE POLICY enrollments_self ON public.enrollments
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS enrollments_admin ON public.enrollments;
CREATE POLICY enrollments_admin ON public.enrollments
  FOR ALL TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS enrollments_funder_read ON public.enrollments;
CREATE POLICY enrollments_funder_read ON public.enrollments
  FOR SELECT TO authenticated
  USING (
    funder_id IN (
      SELECT id FROM public.funders WHERE portal_user_id = auth.uid()
    )
  );

-- enrollments_org_admin n'est créée que si la table organization_members
-- existe (la migration organizations.sql l'a déjà jouée — sinon skip).
DO $org$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'organization_members'
  ) THEN
    EXECUTE 'DROP POLICY IF EXISTS enrollments_org_admin ON public.enrollments';
    EXECUTE $$
      CREATE POLICY enrollments_org_admin ON public.enrollments
        FOR SELECT TO authenticated
        USING (
          organization_id IS NOT NULL
          AND EXISTS (
            SELECT 1 FROM public.organization_members m
            WHERE m.organization_id = enrollments.organization_id
              AND m.user_id = auth.uid()
              AND m.role IN ('org_admin', 'org_viewer')
          )
        );
    $$;
    RAISE NOTICE 'enrollments_org_admin : recréée.';
  ELSE
    RAISE NOTICE 'enrollments_org_admin : table organization_members absente, skip.';
  END IF;
END $org$;

-- ─── 8) GRANT EXECUTE sur les helpers (paranoïa — déjà fait ailleurs) ─
GRANT EXECUTE ON FUNCTION public.is_admin()        TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_super_admin()  TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_staff()        TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_enrolled_in(uuid, text) TO authenticated;

-- ─── 9) Vérification (RAISE NOTICE) ───────────────────────────────────
DO $verify$
DECLARE
  n_sans_search_path int;
  rec record;
BEGIN
  SELECT count(*) INTO n_sans_search_path
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = 'public'
    AND p.proname IN ('is_admin','is_super_admin','is_staff','is_trainer','has_formation_access','is_enrolled_in')
    AND p.prosecdef = true
    AND (
      p.proconfig IS NULL
      OR NOT EXISTS (SELECT 1 FROM unnest(p.proconfig) c WHERE c LIKE 'search_path=%')
    );

  RAISE NOTICE '════ FIX RLS SILENCIEUX ════════════════════════════════════';
  RAISE NOTICE '  Helpers SECURITY DEFINER sans search_path : %', n_sans_search_path;
  RAISE NOTICE '  (devrait être 0 ; si > 0 : functions non patchées)';
  RAISE NOTICE '';
  RAISE NOTICE '  Détail des helpers après patch :';

  FOR rec IN
    SELECT p.proname,
           CASE WHEN p.proconfig IS NULL THEN '∅'
                ELSE array_to_string(p.proconfig, ' | ') END AS cfg
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.proname IN ('is_admin','is_super_admin','is_staff','is_trainer','has_formation_access','is_enrolled_in')
    ORDER BY p.proname
  LOOP
    RAISE NOTICE '    • %  →  %', rpad(rec.proname, 24), rec.cfg;
  END LOOP;

  RAISE NOTICE '════════════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE 'PROCHAINE ÉTAPE :';
  RAISE NOTICE '  1. Appeler /api/debug/rls connecté comme super_admin.';
  RAISE NOTICE '  2. Vérifier que :';
  RAISE NOTICE '       rpc_results.is_admin == true';
  RAISE NOTICE '       rls_visible_data.enrollments_via_session_client == enrollments_via_service_role';
  RAISE NOTICE '  3. Si OK, retirer progressivement les workarounds createAdminClient()';
  RAISE NOTICE '     (voir tableau dans rapport CLAUDE).';
END $verify$;

-- =====================================================================
-- TESTS — à dérouler manuellement dans Studio APRÈS application
-- =====================================================================
--
-- ⚠️ Avant de jouer, récupérer un UUID de super_admin :
--   SELECT id, email FROM profiles WHERE role='super_admin' LIMIT 1;
-- Puis remplacer <UUID_SUPER_ADMIN> ci-dessous.
--
-- ─── Test 1 : simulation session super_admin ───────────────────────────
-- BEGIN;
--   SET LOCAL role = 'authenticated';
--   SET LOCAL request.jwt.claims = '{"sub":"<UUID_SUPER_ADMIN>","role":"authenticated"}';
--
--   -- ATTENDU : uid = <UUID_SUPER_ADMIN> (non null !)
--   SELECT auth.uid() AS uid;
--
--   -- ATTENDU : tous true
--   SELECT public.is_admin(), public.is_super_admin(), public.is_staff();
--
--   -- ATTENDU : count = nombre total d'enrollments (7+ pour MFT)
--   SELECT count(*) FROM public.enrollments;
--
--   -- ATTENDU : count = nombre total de modules (48+ pour MFT)
--   SELECT count(*) FROM public.modules;
--
--   -- ATTENDU : true (super_admin a accès à toutes les formations)
--   SELECT public.has_formation_access(auth.uid(), 'gotrm');
-- ROLLBACK;
--
-- ─── Test 2 : simulation session student ───────────────────────────────
-- BEGIN;
--   SET LOCAL role = 'authenticated';
--   SET LOCAL request.jwt.claims = '{"sub":"<UUID_STUDENT>","role":"authenticated"}';
--
--   -- ATTENDU : tous false
--   SELECT public.is_admin(), public.is_super_admin();
--
--   -- ATTENDU : count = nb enrollments du student (1 ou 2)
--   SELECT count(*) FROM public.enrollments;
--
--   -- ATTENDU : count = nb modules des formations où le student est inscrit
--   SELECT count(*) FROM public.modules;
-- ROLLBACK;
