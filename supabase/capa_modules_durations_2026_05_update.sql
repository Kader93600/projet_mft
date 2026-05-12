-- =====================================================================
-- MIGRATION — Mise à jour des durées des modules Capacité ≤ 3,5 t
-- Date : 2026-05-12
-- Demande client : nouvelles durées officielles pour la formation
--   "capacite-3-5t" (modules A à F).
--
-- Source de vérité :
--   Module A → 540 min  (9 h)
--   Module B → 180 min  (3 h)         déjà à cette valeur
--   Module C → 630 min  (10 h 30)
--   Module D → 3 150 min (52 h 30)
--   Module E → 1 050 min (17 h 30)
--   Module F → 510 min  (8 h 30)
--   Total    : 6 060 min ≈ 101 h
--
-- Idempotent : UPDATE par slug — safe à rejouer plusieurs fois.
-- Ne touche QUE la formation 'capacite-3-5t' (filtrage par formation_id
-- via formation_modules pour zéro impact sur les autres formations qui
-- pourraient partager un slug homonyme).
-- =====================================================================

DO $capa_durations$
DECLARE
  v_formation uuid;
  v_changed int := 0;
BEGIN
  -- Trouver l'ID de la formation Capacité ≤ 3,5 t
  SELECT id INTO v_formation
  FROM public.formations
  WHERE slug = 'capacite-3-5t';

  IF v_formation IS NULL THEN
    RAISE EXCEPTION 'Formation "capacite-3-5t" introuvable — migration annulée';
  END IF;

  -- ─── Module A — Droit civil et commercial : 240 → 540 ─────────────
  UPDATE public.modules m
     SET duration_min = 540,
         updated_at  = now()
   WHERE m.slug = 'capa-droit-civil-commercial'
     AND EXISTS (
       SELECT 1 FROM public.formation_modules fm
        WHERE fm.module_id = m.id AND fm.formation_id = v_formation
     );
  GET DIAGNOSTICS v_changed = ROW_COUNT;
  RAISE NOTICE 'Module A — % ligne(s) mise(s) à jour à 540 min', v_changed;

  -- ─── Module B — Entreprise et activité commerciale : 180 → 180 ───
  -- Aucune modification nécessaire, valeur cible déjà en place.
  -- On exécute quand même pour idempotence et bumpage updated_at.
  UPDATE public.modules m
     SET duration_min = 180,
         updated_at  = now()
   WHERE m.slug = 'capa-entreprise-activite-commerciale'
     AND EXISTS (
       SELECT 1 FROM public.formation_modules fm
        WHERE fm.module_id = m.id AND fm.formation_id = v_formation
     );
  GET DIAGNOSTICS v_changed = ROW_COUNT;
  RAISE NOTICE 'Module B — % ligne(s) confirmée(s) à 180 min', v_changed;

  -- ─── Module C — Cadre réglementaire transport : 240 → 630 ────────
  UPDATE public.modules m
     SET duration_min = 630,
         updated_at  = now()
   WHERE m.slug = 'capa-cadre-reglementaire-transport'
     AND EXISTS (
       SELECT 1 FROM public.formation_modules fm
        WHERE fm.module_id = m.id AND fm.formation_id = v_formation
     );
  GET DIAGNOSTICS v_changed = ROW_COUNT;
  RAISE NOTICE 'Module C — % ligne(s) mise(s) à jour à 630 min', v_changed;

  -- ─── Module D — Activité financière : 240 → 3 150 ────────────────
  UPDATE public.modules m
     SET duration_min = 3150,
         updated_at  = now()
   WHERE m.slug = 'capa-activite-financiere'
     AND EXISTS (
       SELECT 1 FROM public.formation_modules fm
        WHERE fm.module_id = m.id AND fm.formation_id = v_formation
     );
  GET DIAGNOSTICS v_changed = ROW_COUNT;
  RAISE NOTICE 'Module D — % ligne(s) mise(s) à jour à 3150 min', v_changed;

  -- ─── Module E — Salariés et droit social : 210 → 1 050 ───────────
  UPDATE public.modules m
     SET duration_min = 1050,
         updated_at  = now()
   WHERE m.slug = 'capa-salaries-droit-social'
     AND EXISTS (
       SELECT 1 FROM public.formation_modules fm
        WHERE fm.module_id = m.id AND fm.formation_id = v_formation
     );
  GET DIAGNOSTICS v_changed = ROW_COUNT;
  RAISE NOTICE 'Module E — % ligne(s) mise(s) à jour à 1050 min', v_changed;

  -- ─── Module F — Sécurité : 200 → 510 ─────────────────────────────
  UPDATE public.modules m
     SET duration_min = 510,
         updated_at  = now()
   WHERE m.slug = 'capa-securite'
     AND EXISTS (
       SELECT 1 FROM public.formation_modules fm
        WHERE fm.module_id = m.id AND fm.formation_id = v_formation
     );
  GET DIAGNOSTICS v_changed = ROW_COUNT;
  RAISE NOTICE 'Module F — % ligne(s) mise(s) à jour à 510 min', v_changed;

  -- ─── Récap final : total Capacité ≤ 3,5 t ────────────────────────
  RAISE NOTICE '---';
  RAISE NOTICE 'Récap durées Capacité ≤ 3,5 t après migration :';
  FOR v_changed IN
    SELECT m.duration_min
      FROM public.modules m
      JOIN public.formation_modules fm ON fm.module_id = m.id
     WHERE fm.formation_id = v_formation
     ORDER BY fm.display_order
  LOOP
    RAISE NOTICE '  - %  min', v_changed;
  END LOOP;
END $capa_durations$;

-- Vérification post-migration (à exécuter manuellement après le DO block)
-- pour confirmer visuellement les nouvelles durées :
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
