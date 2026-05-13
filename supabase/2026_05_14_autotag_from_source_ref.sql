-- =====================================================================
-- 2026-05-14 · Auto-tagging des questions depuis leur source_ref
--
-- Quand des questions ont été importées via les seeds historiques
-- (gotrm_ch03_v4_livret.sql, capa_module_a_v3_dense.sql, etc.) ou par
-- l'import en lot PDF, leur `source_ref` contient déjà l'information
-- de chapitre / module :
--
--   - GOTRM : `mft-2026-gotrm-livret:ch03:qcm:1`   → chapitre 3
--   - Capa  : `mft-2026:moduleA:qcm:5`             → module a
--   - Import: `import:<uuid>#LIVRET_..._CCP1.pdf`  → pas exploitable
--
-- Cette migration parse ces patterns et ajoute le tag correspondant
-- (`chapitre-N` ou `module-X`) à la colonne tags[] de question_bank,
-- SANS écraser les tags existants et SANS dupliquer.
--
-- Idempotente : peut être rejouée sans effet de bord.
-- =====================================================================

DO $$
DECLARE
  v_rec RECORD;
  v_chapter text;
  v_module text;
  v_new_tag text;
  v_updates_chapitre int := 0;
  v_updates_module int := 0;
  v_already_tagged int := 0;
  v_skipped int := 0;
BEGIN
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Auto-tagging depuis source_ref';
  RAISE NOTICE '────────────────────────────────────────────────────────';

  FOR v_rec IN
    SELECT id, source_ref, tags
      FROM public.question_bank
     WHERE source_ref IS NOT NULL
  LOOP
    v_new_tag := NULL;

    -- Pattern 1 : chXX (GOTRM livret)
    -- Extrait "ch03" → "3" (strip leading zero)
    v_chapter := substring(v_rec.source_ref FROM ':ch(\d{1,3})');
    IF v_chapter IS NOT NULL THEN
      -- Retire le 0 de tête : '03' → '3', '12' → '12'
      v_chapter := ltrim(v_chapter, '0');
      IF v_chapter = '' THEN v_chapter := '0'; END IF;
      v_new_tag := 'chapitre-' || v_chapter;

      -- Skip si le tag est déjà présent
      IF v_rec.tags @> ARRAY[v_new_tag] THEN
        v_already_tagged := v_already_tagged + 1;
      ELSE
        -- Retire d'éventuels chapitre-* différents pour éviter les
        -- conflits (on fait confiance au source_ref comme source de
        -- vérité pour le chapitre)
        UPDATE public.question_bank
           SET tags = (
             SELECT array_agg(t)
               FROM unnest(tags) t
              WHERE t NOT LIKE 'chapitre-%'
           ) || ARRAY[v_new_tag]
         WHERE id = v_rec.id;
        v_updates_chapitre := v_updates_chapitre + 1;
      END IF;

    ELSE
      -- Pattern 2 : moduleX (Capa)
      v_module := substring(v_rec.source_ref FROM ':module([A-Za-z])');
      IF v_module IS NOT NULL THEN
        v_module := lower(v_module);
        v_new_tag := 'module-' || v_module;

        IF v_rec.tags @> ARRAY[v_new_tag] THEN
          v_already_tagged := v_already_tagged + 1;
        ELSE
          UPDATE public.question_bank
             SET tags = (
               SELECT array_agg(t)
                 FROM unnest(tags) t
                WHERE t NOT LIKE 'module-%'
             ) || ARRAY[v_new_tag]
           WHERE id = v_rec.id;
          v_updates_module := v_updates_module + 1;
        END IF;
      ELSE
        v_skipped := v_skipped + 1;
      END IF;
    END IF;
  END LOOP;

  RAISE NOTICE '  ✓ Chapitres affectés .................. %', v_updates_chapitre;
  RAISE NOTICE '  ✓ Modules affectés .................... %', v_updates_module;
  RAISE NOTICE '  · Déjà taggées (skip) ................. %', v_already_tagged;
  RAISE NOTICE '  ⚠ Source_ref non parsable (skip) ...... %', v_skipped;
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;

-- ---------------------------------------------------------------------
-- Stats finales : combien de questions sont maintenant taggées
-- ---------------------------------------------------------------------
DO $$
DECLARE
  v_rec RECORD;
BEGIN
  RAISE NOTICE 'Répartition par formation après auto-tagging :';
  FOR v_rec IN
    SELECT
      f.slug,
      f.code,
      COUNT(*) FILTER (WHERE EXISTS (
        SELECT 1 FROM unnest(q.tags) t WHERE t LIKE 'chapitre-%' OR t LIKE 'module-%'
      )) AS tagged,
      COUNT(*) AS total
    FROM public.question_bank q
    JOIN public.formations f ON f.id = q.formation_id
    GROUP BY f.slug, f.code
    ORDER BY f.code
  LOOP
    RAISE NOTICE '  %-22s (%) : %/% taggées',
      v_rec.slug, v_rec.code, v_rec.tagged, v_rec.total;
  END LOOP;
END $$;
