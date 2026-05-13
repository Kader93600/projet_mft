-- =====================================================================
-- 2026-05-14 · Inscription : enregistrer le pack choisi par le visiteur
--
-- Lors de Phase 3, la page /inscription affiche un sélecteur Initial /
-- Medium / Premium. Le choix doit transiter dans le lead (enrollment_request)
-- pour qu'un admin puisse créer l'enrollment final avec le bon pack
-- (et le bon prix DB-driven) sans avoir à redemander au stagiaire.
--
-- - Ajoute `pack_slug` (text, nullable, check enum 'initial'|'medium'|'premium')
-- - Ajoute `formation_slug` si la colonne n'existe pas encore (legacy)
-- - Garde l'historique : un lead sans pack reste valide (NULL = pas exprimé)
-- =====================================================================

-- 1. formation_slug : ajouté si manquant (certaines instances ont déjà
-- la colonne, créée hors migration). On la rend nullable pour ne pas
-- casser les leads anciens.
ALTER TABLE public.enrollment_requests
  ADD COLUMN IF NOT EXISTS formation_slug text;

-- 2. pack_slug : nouveau, optionnel, contraint à l'enum applicatif.
ALTER TABLE public.enrollment_requests
  ADD COLUMN IF NOT EXISTS pack_slug text;

-- Contrainte CHECK enum-like (alignée sur le type pack_slug applicatif).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'enrollment_requests_pack_slug_check'
  ) THEN
    ALTER TABLE public.enrollment_requests
      ADD CONSTRAINT enrollment_requests_pack_slug_check
      CHECK (pack_slug IS NULL OR pack_slug IN ('initial','medium','premium'));
  END IF;
END $$;

-- 3. Index léger pour les requêtes admin (filtrer par formation / pack).
CREATE INDEX IF NOT EXISTS enrollment_requests_formation_slug_idx
  ON public.enrollment_requests (formation_slug)
  WHERE formation_slug IS NOT NULL;

CREATE INDEX IF NOT EXISTS enrollment_requests_pack_slug_idx
  ON public.enrollment_requests (pack_slug)
  WHERE pack_slug IS NOT NULL;

-- 4. Vérification post-migration
DO $$
DECLARE
  v_has_formation_slug boolean;
  v_has_pack_slug boolean;
  v_has_check boolean;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'enrollment_requests'
      AND column_name = 'formation_slug'
  ) INTO v_has_formation_slug;

  SELECT EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'enrollment_requests'
      AND column_name = 'pack_slug'
  ) INTO v_has_pack_slug;

  SELECT EXISTS(
    SELECT 1 FROM pg_constraint
    WHERE conname = 'enrollment_requests_pack_slug_check'
  ) INTO v_has_check;

  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Migration enrollment_requests · packs Phase 3';
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE '  formation_slug column .................. %', v_has_formation_slug;
  RAISE NOTICE '  pack_slug column ....................... %', v_has_pack_slug;
  RAISE NOTICE '  pack_slug CHECK constraint ............. %', v_has_check;
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;
