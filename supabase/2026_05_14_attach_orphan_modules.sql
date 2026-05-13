-- =====================================================================
-- 2026-05-14 · Rattachement automatique des modules orphelins
--
-- Contexte : la table `modules` est rattachée aux `blocs` (BC1, BC2, BC3)
-- mais pas directement aux formations. La liaison N-N
-- `formation_modules` doit être renseignée explicitement, ce qui n'a
-- pas été fait pour les modules historiques (seed.sql initial).
-- Conséquence : sur /admin/banque-questions/import les sélecteurs
-- Module/Leçon restaient vides faute de mapping.
--
-- Cette migration :
--   1. Trouve tous les modules sans aucune entrée dans `formation_modules`
--   2. Tente un rattachement automatique via le slug du module :
--      - 'gotrm-*' / 'gotrm_*'                  → formation 'gotrm'
--      - 'capa-*' / 'capacite-*' / 'capa_*'     → 'capacite-3-5t'
--      - 'capacite-plus-*'                      → 'capacite-plus-3-5t'
--      - 'fimo-*' / 'fco-*' / 'fimo-fco-*'      → 'fimo-fco'
--      - 'taxi-*' / 'vtc-*' / 'taxi-vtc-*'      → 'taxi-vtc'
--      - 'commissionnaire-*' / 'comm-*'         → 'commissionnaire'
--      - 'ertv-*' / 'enseignant-route-*'        → 'ertv'
--      - 'ecsr-*' / 'enseignant-csr-*'          → 'ecsr'
--   3. Pour les modules historiques du seed (BC1/BC2/BC3 partagés)
--      qui ne matchent aucun préfixe → fallback sur 'gotrm' (le seed
--      d'origine étant le programme RNCP 40990 GOTRM).
--   4. Affiche un NOTICE détaillé : modules rattachés + restants orphelins
--      pour traitement manuel via /admin/modules.
-- =====================================================================

DO $$
DECLARE
  v_f_gotrm uuid;
  v_f_capa uuid;
  v_f_capa_plus uuid;
  v_f_fimo uuid;
  v_f_taxi uuid;
  v_f_comm uuid;
  v_f_ertv uuid;
  v_f_ecsr uuid;
  v_rec RECORD;
  v_target uuid;
  v_rule text;
  v_attached int := 0;
  v_orphans int := 0;
  v_order int;
BEGIN
  -- Cache les IDs de formations (peuvent être NULL si la formation
  -- n'a pas encore été créée — dans ce cas on skip le mapping)
  SELECT id INTO v_f_gotrm    FROM public.formations WHERE slug = 'gotrm';
  SELECT id INTO v_f_capa     FROM public.formations WHERE slug = 'capacite-3-5t';
  SELECT id INTO v_f_capa_plus FROM public.formations WHERE slug = 'capacite-plus-3-5t';
  SELECT id INTO v_f_fimo     FROM public.formations WHERE slug = 'fimo-fco';
  SELECT id INTO v_f_taxi     FROM public.formations WHERE slug = 'taxi-vtc';
  SELECT id INTO v_f_comm     FROM public.formations WHERE slug = 'commissionnaire';
  SELECT id INTO v_f_ertv     FROM public.formations WHERE slug = 'ertv';
  SELECT id INTO v_f_ecsr     FROM public.formations WHERE slug = 'ecsr';

  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Rattachement automatique des modules orphelins';
  RAISE NOTICE '────────────────────────────────────────────────────────';

  -- Parcourt les modules sans aucun rattachement dans formation_modules
  FOR v_rec IN
    SELECT m.id, m.slug, m.title
      FROM public.modules m
     WHERE NOT EXISTS (
       SELECT 1
         FROM public.formation_modules fm
        WHERE fm.module_id = m.id
     )
     ORDER BY m."order", m.slug
  LOOP
    v_target := NULL;
    v_rule := NULL;

    -- ─── Heuristique 1 : préfixe explicite ─────────────────────────
    IF v_rec.slug LIKE 'gotrm-%' OR v_rec.slug LIKE 'gotrm_%' THEN
      v_target := v_f_gotrm; v_rule := 'préfixe gotrm';
    ELSIF v_rec.slug LIKE 'capacite-plus-%' THEN
      v_target := v_f_capa_plus; v_rule := 'préfixe capacite-plus';
    ELSIF v_rec.slug LIKE 'capa-%'
       OR v_rec.slug LIKE 'capa_%'
       OR v_rec.slug LIKE 'capacite-%' THEN
      v_target := v_f_capa; v_rule := 'préfixe capa';
    ELSIF v_rec.slug LIKE 'fimo-%'
       OR v_rec.slug LIKE 'fco-%'
       OR v_rec.slug LIKE 'fimo-fco-%' THEN
      v_target := v_f_fimo; v_rule := 'préfixe fimo/fco';
    ELSIF v_rec.slug LIKE 'taxi-%'
       OR v_rec.slug LIKE 'vtc-%'
       OR v_rec.slug LIKE 'taxi-vtc-%' THEN
      v_target := v_f_taxi; v_rule := 'préfixe taxi/vtc';
    ELSIF v_rec.slug LIKE 'commissionnaire-%'
       OR v_rec.slug LIKE 'comm-%' THEN
      v_target := v_f_comm; v_rule := 'préfixe commissionnaire';
    ELSIF v_rec.slug LIKE 'ertv-%'
       OR v_rec.slug LIKE 'enseignant-route-%' THEN
      v_target := v_f_ertv; v_rule := 'préfixe ertv';
    ELSIF v_rec.slug LIKE 'ecsr-%'
       OR v_rec.slug LIKE 'enseignant-csr-%' THEN
      v_target := v_f_ecsr; v_rule := 'préfixe ecsr';

    -- ─── Heuristique 2 : fallback seed initial → GOTRM ─────────────
    -- Les modules historiques du seed.sql (planification-tournees,
    -- reglementation-transport, etc.) ne portent pas de préfixe car
    -- le seed d'origine était le programme RNCP 40990 GOTRM.
    ELSIF v_f_gotrm IS NOT NULL THEN
      v_target := v_f_gotrm; v_rule := 'fallback seed initial → GOTRM';
    END IF;

    IF v_target IS NOT NULL THEN
      -- Calcule un display_order incrémental (100, 101, 102…)
      SELECT COALESCE(MAX(display_order), 99) + 1 INTO v_order
        FROM public.formation_modules
       WHERE formation_id = v_target;

      INSERT INTO public.formation_modules
        (formation_id, module_id, display_order, required)
      VALUES (v_target, v_rec.id, v_order, true)
      ON CONFLICT (formation_id, module_id) DO NOTHING;

      v_attached := v_attached + 1;
      RAISE NOTICE '  ✓ % → formation % (%)',
        v_rec.slug,
        (SELECT slug FROM public.formations WHERE id = v_target),
        v_rule;
    ELSE
      v_orphans := v_orphans + 1;
      RAISE NOTICE '  ⚠ % — aucune règle ne matche (à rattacher manuellement)',
        v_rec.slug;
    END IF;
  END LOOP;

  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Bilan : % rattaché(s), % orphelin(s) restant(s)',
    v_attached, v_orphans;
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;

-- ---------------------------------------------------------------------
-- Vérification post-migration : combien de modules par formation ?
-- ---------------------------------------------------------------------
DO $$
DECLARE
  v_rec RECORD;
BEGIN
  RAISE NOTICE 'État final modules / formation :';
  FOR v_rec IN
    SELECT f.slug,
           f.code,
           COUNT(fm.module_id) AS nb_modules
      FROM public.formations f
      LEFT JOIN public.formation_modules fm ON fm.formation_id = f.id
     GROUP BY f.id, f.slug, f.code
     ORDER BY f.slug
  LOOP
    RAISE NOTICE '  %-22s (%) : % module(s)',
      v_rec.slug, v_rec.code, v_rec.nb_modules;
  END LOOP;
END $$;
