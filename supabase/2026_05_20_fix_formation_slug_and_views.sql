-- =====================================================================
-- HOTFIX — Pipeline admin à 0 + stagiaires sans modules visibles
-- 2026-05-19
--
-- Diagnostic :
--
-- 1. `enrollments.formation_slug` n'a jamais été backfillé pour les
--    inscriptions existantes. Seul un trigger BEFORE INSERT/UPDATE OF
--    formation_slug peuple `formation_id` à partir du slug, mais
--    l'inverse n'existe pas. Conséquence :
--
--    a) La RLS `modules_read_scoped` (rls_formation_scoping.sql) appelle
--       `has_formation_access(auth.uid(), f.slug)` qui filtre
--       `enrollments WHERE formation_slug = p_slug`. Si formation_slug
--       est NULL, le stagiaire ne voit AUCUN module rattaché à une
--       formation → "Aucun module disponible" partout côté apprenant.
--
--    b) Le composant `components/admin/formation-pipeline.tsx` lit
--       `enrollments` avec `.not("formation_slug","is",null)` → 0 ligne
--       → tout le pipeline admin affiche 0 stagiaires actifs / 0 €.
--
-- 2. La vue `formations_demand` est référencée par 2 endroits côté code
--    (formation-pipeline.tsx:47, app/admin/formations/page.tsx:24) mais
--    n'a JAMAIS été créée dans /supabase/. Le `.from("formations_demand")`
--    retourne donc systématiquement vide → "Demandes 30j" = 0 sur toutes
--    les formations.
--
-- Fix en 3 étapes ordonnées :
--   1) Backfill enrollments.formation_slug depuis formation_id
--   2) Ajouter trigger inverse (formation_id → formation_slug) pour
--      conserver la cohérence sur les futures insertions/updates
--   3) Étendre has_formation_access pour reconnaître AUSSI le chemin
--      formation_id (ceinture + bretelles si un enrollment futur arrive
--      sans slug)
--   4) Créer la vue formations_demand attendue par le code
-- =====================================================================

-- ─── 1a) Backfill enrollments.formation_slug (depuis formation_id) ──────
-- Pour chaque enrollment ayant formation_id mais pas formation_slug,
-- on récupère le slug depuis la table formations.
UPDATE public.enrollments e
   SET formation_slug = f.slug
  FROM public.formations f
 WHERE e.formation_id = f.id
   AND e.formation_slug IS NULL;

-- ─── 1b) Backfill enrollments.formation_id (depuis formation_slug) ──────
-- Symétrique : pour chaque enrollment ayant formation_slug mais pas
-- formation_id, on remonte vers la formation. C'est ce backfill-ci qui
-- débloque le dashboard stagiaire (app/dashboard/page.tsx:50 filtre
-- `.not("formation_id","is",null)`).
--
-- Cas observé : Sfaxi a un enrollment legacy avec formation_slug='gotrm'
-- (visible dans la section "Mes formations" qui lit le slug) mais
-- formation_id NULL → dashboard.allowedModuleIds = [] → "Aucun module
-- disponible".
UPDATE public.enrollments e
   SET formation_id = f.id
  FROM public.formations f
 WHERE e.formation_slug = f.slug
   AND e.formation_id IS NULL;

-- ─── 2) Trigger inverse : formation_id → formation_slug ─────────────────
-- L'existant `tg_enrollment_resolve_formation` ne se déclenche que sur
-- UPDATE OF formation_slug. On ajoute le symétrique : si formation_id
-- est posé sans slug, on remplit le slug.
CREATE OR REPLACE FUNCTION public.tg_enrollment_resolve_slug()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.formation_id IS NOT NULL AND NEW.formation_slug IS NULL THEN
    SELECT slug INTO NEW.formation_slug
      FROM public.formations
     WHERE id = NEW.formation_id;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_enrollment_resolve_slug ON public.enrollments;
CREATE TRIGGER tg_enrollment_resolve_slug
  BEFORE INSERT OR UPDATE OF formation_id ON public.enrollments
  FOR EACH ROW EXECUTE FUNCTION public.tg_enrollment_resolve_slug();

-- ─── 3) Étendre has_formation_access (tolère slug OU id) ────────────────
-- On garde l'ancienne logique mais on ajoute un OR sur formation_id ↔
-- formations.slug. Permet de couvrir le cas d'un enrollment futur qui
-- aurait été inséré sans passer par le trigger (RPC, seed, etc.).
CREATE OR REPLACE FUNCTION public.has_formation_access(
  p_user uuid,
  p_slug text
) RETURNS boolean
LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
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

-- ─── 4) Vue formations_demand ───────────────────────────────────────────
-- Agrège les demandes d'inscription par formation_slug sur la fenêtre
-- glissante 30 jours, plus le total en attente de traitement.
-- Consommée par :
--   - components/admin/formation-pipeline.tsx:47
--   - app/admin/formations/page.tsx:24
--
-- DROP préalable obligatoire : une version antérieure de la vue peut
-- exister avec des noms de colonnes différents (ex: "requests" au lieu
-- de "requests_30d"). PostgreSQL refuse CREATE OR REPLACE quand un
-- nom de colonne change, d'où le drop forcé en CASCADE.
DROP VIEW IF EXISTS public.formations_demand CASCADE;

CREATE VIEW public.formations_demand AS
SELECT
  er.formation_slug,
  -- Total lifetime des demandes (alias historique conservé pour compat
  -- avec app/admin/formations/page.tsx qui lit "requests")
  count(*)                                        AS requests,
  -- Fenêtre glissante 30 jours (nouveau nom utilisé partout)
  count(*) FILTER (WHERE er.created_at >= now() - interval '30 days') AS requests_30d,
  -- En attente de traitement : statuts non terminaux, et seulement
  -- les demandes encore "chaudes" (≤ 90j)
  count(*) FILTER (
    WHERE er.status IN ('nouveau','contacte','devis_envoye')
      AND er.created_at >= now() - interval '90 days'
  ) AS pending,
  count(*) FILTER (WHERE er.status = 'inscrit') AS converted,
  count(*) FILTER (WHERE er.status = 'refuse')   AS refused,
  max(er.created_at)                             AS last_request_at
FROM public.enrollment_requests er
WHERE er.formation_slug IS NOT NULL
GROUP BY er.formation_slug;

GRANT SELECT ON public.formations_demand TO authenticated;

-- ─── 5) Vérification (RAISE NOTICE pour relecture dans Studio) ──────────
DO $$
DECLARE
  n_enrollments_total int;
  n_enrollments_with_slug int;
  n_enrollments_with_id int;
  n_enrollments_complete int;
  n_formations_demand int;
  n_modules_via_formations int;
BEGIN
  SELECT count(*) INTO n_enrollments_total FROM public.enrollments;
  SELECT count(*) INTO n_enrollments_with_slug FROM public.enrollments
   WHERE formation_slug IS NOT NULL;
  SELECT count(*) INTO n_enrollments_with_id FROM public.enrollments
   WHERE formation_id IS NOT NULL;
  SELECT count(*) INTO n_enrollments_complete FROM public.enrollments
   WHERE formation_slug IS NOT NULL AND formation_id IS NOT NULL;
  SELECT count(*) INTO n_formations_demand FROM public.formations_demand;
  SELECT count(DISTINCT module_id) INTO n_modules_via_formations
    FROM public.formation_modules;

  RAISE NOTICE '════════ HOTFIX formation_slug + formation_id ════════════';
  RAISE NOTICE '  enrollments total ........................ %', n_enrollments_total;
  RAISE NOTICE '  enrollments avec formation_slug .......... %', n_enrollments_with_slug;
  RAISE NOTICE '  enrollments avec formation_id ............ %', n_enrollments_with_id;
  RAISE NOTICE '  enrollments avec les deux (complets) ..... %', n_enrollments_complete;
  RAISE NOTICE '  modules rattachés à une formation ........ %', n_modules_via_formations;
  RAISE NOTICE '  lignes dans formations_demand ............ %', n_formations_demand;
  RAISE NOTICE '═══════════════════════════════════════════════════════════';

  IF n_enrollments_with_id < n_enrollments_total THEN
    RAISE WARNING '⚠ % enrollment(s) n''ont toujours pas de formation_id — leur formation_slug pointe sans doute vers une formation inexistante ou supprimée. À investiguer manuellement.',
      n_enrollments_total - n_enrollments_with_id;
  END IF;

  IF n_modules_via_formations = 0 THEN
    RAISE WARNING '⚠ AUCUN module n''est rattaché à une formation via formation_modules. Le dashboard restera vide même avec un enrollment valide. Vérifier la table formation_modules.';
  END IF;
END $$;
