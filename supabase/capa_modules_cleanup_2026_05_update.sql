-- =====================================================================
-- MIGRATION — Nettoyage post-update durées modules Capacité ≤ 3,5 t
-- Date : 2026-05-13
--
-- Constat post-migration (capa_modules_durations_2026_05_update.sql) :
--   1. Un module "test" (slug='test', 30 min, display_order=100) traîne
--      en BDD prod — sans doute un module de debug créé puis oublié.
--      → À SUPPRIMER (cleanup).
--   2. Module A "capa-droit-civil-commercial" a display_order=100 dans
--      formation_modules au lieu de 10 (la valeur du seed).
--      → Conséquence : Module A s'affiche en DERNIER au lieu de PREMIER.
--      → À CORRIGER : remettre display_order=10.
--
-- Idempotent : safe à rejouer. Pas de risque sur les autres formations.
-- =====================================================================

DO $capa_cleanup$
DECLARE
  v_formation_capa uuid;
  v_module_test uuid;
  v_changed int := 0;
BEGIN
  -- ─── Trouver la formation Capacité ≤ 3,5 t ───────────────────────
  SELECT id INTO v_formation_capa
  FROM public.formations
  WHERE slug = 'capacite-3-5t';

  IF v_formation_capa IS NULL THEN
    RAISE EXCEPTION 'Formation "capacite-3-5t" introuvable — migration annulée';
  END IF;

  -- ──────────────────────────────────────────────────────────────────
  -- FIX 1 : Module A display_order  100 → 10 (premier module)
  -- ──────────────────────────────────────────────────────────────────
  UPDATE public.formation_modules
     SET display_order = 10
   WHERE formation_id = v_formation_capa
     AND module_id IN (
       SELECT id FROM public.modules
        WHERE slug = 'capa-droit-civil-commercial'
     );
  GET DIAGNOSTICS v_changed = ROW_COUNT;
  RAISE NOTICE 'Fix 1 — Module A display_order remis à 10 : % ligne(s)', v_changed;

  -- ──────────────────────────────────────────────────────────────────
  -- FIX 2 : Supprimer le module fantôme "test"
  --
  -- On supprime CASCADE :
  --   - formation_modules (rattachement à des formations)
  --   - lessons rattachées (si présentes)
  --   - quizzes / questions rattachés (si présents)
  --
  -- ATTENTION : DELETE FROM modules a un ON DELETE CASCADE en schema,
  --   donc tous les enfants partent automatiquement.
  -- ──────────────────────────────────────────────────────────────────
  SELECT id INTO v_module_test
  FROM public.modules
  WHERE slug = 'test'
  LIMIT 1;

  IF v_module_test IS NOT NULL THEN
    -- Petit audit avant suppression : qui rattache ce module ?
    RAISE NOTICE 'Module fantôme "test" trouvé : id=%, suppression en cascade...', v_module_test;

    DELETE FROM public.modules WHERE id = v_module_test;
    RAISE NOTICE 'Fix 2 — Module fantôme "test" supprimé (cascade : leçons + quizzes + rattachements)';
  ELSE
    RAISE NOTICE 'Fix 2 — Aucun module "test" en base, rien à supprimer';
  END IF;

  -- ──────────────────────────────────────────────────────────────────
  -- Récap final : ordre des modules Capacité ≤ 3,5 t après cleanup
  -- ──────────────────────────────────────────────────────────────────
  RAISE NOTICE '---';
  RAISE NOTICE 'Récap ordre Capacité ≤ 3,5 t après cleanup :';
  FOR v_changed IN
    SELECT fm.display_order
      FROM public.modules m
      JOIN public.formation_modules fm ON fm.module_id = m.id
     WHERE fm.formation_id = v_formation_capa
     ORDER BY fm.display_order
  LOOP
    RAISE NOTICE '  - display_order = %', v_changed;
  END LOOP;
END $capa_cleanup$;

-- Vérification post-migration (à exécuter à part) :
--
-- SELECT
--   m.slug,
--   m.title,
--   m.duration_min,
--   ROUND(m.duration_min / 60.0, 1) AS hours,
--   fm.display_order
-- FROM public.modules m
-- JOIN public.formation_modules fm ON fm.module_id = m.id
-- JOIN public.formations f ON f.id = fm.formation_id
-- WHERE f.slug = 'capacite-3-5t'
-- ORDER BY fm.display_order;
--
-- Attendu :
--   capa-droit-civil-commercial      | Module A | 540  | 9.0  | 10
--   capa-entreprise-activite-commerc.| Module B | 180  | 3.0  | 20
--   capa-cadre-reglementaire-transp. | Module C | 630  | 10.5 | 30
--   capa-activite-financiere         | Module D | 3150 | 52.5 | 40
--   capa-salaries-droit-social       | Module E | 1050 | 17.5 | 50
--   capa-securite                    | Module F | 510  | 8.5  | 60
