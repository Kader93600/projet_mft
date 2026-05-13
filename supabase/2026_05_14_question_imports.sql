-- =====================================================================
-- 2026-05-14 · Audit des imports de banque de questions (Phase 6)
--
-- Chaque tentative d'import PDF crée une ligne dans `question_imports`,
-- ce qui permet à l'admin de :
--   - retrouver l'origine d'une question (via question_bank.source_ref)
--   - relancer un import partiel
--   - voir l'historique d'enrichissement de la banque
--
-- Un import = un fichier source = N questions insérées.
-- Le `source_ref` posé sur chaque question pointe sur cet import_id +
-- le nom du fichier original.
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.question_imports (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Métadonnées du fichier source
  file_name text NOT NULL,
  file_size_bytes int,
  file_kind text NOT NULL DEFAULT 'pdf'
    CHECK (file_kind IN ('pdf', 'docx', 'txt', 'paste')),

  -- Rattachement pédagogique
  formation_id uuid REFERENCES public.formations(id) ON DELETE CASCADE,
  module_id    uuid REFERENCES public.modules(id) ON DELETE SET NULL,
  -- Type majoritaire des questions du PDF ('qcm', 'qr', 'mixed', 'exam')
  expected_type text NOT NULL DEFAULT 'mixed'
    CHECK (expected_type IN ('qcm', 'qr', 'mixed', 'exam')),

  -- État de l'import
  status text NOT NULL DEFAULT 'extracted'
    CHECK (status IN ('extracted', 'parsed', 'inserted', 'failed', 'aborted')),
  questions_count int NOT NULL DEFAULT 0,
  errors_count int NOT NULL DEFAULT 0,

  -- Texte brut extrait du PDF (gardé pour relancer un parsing différent)
  raw_text text,
  -- Notes admin (ex. "Examens blancs 2024 fournis par MFT le 12 mai")
  notes text,

  created_at timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS question_imports_formation_idx
  ON public.question_imports(formation_id);
CREATE INDEX IF NOT EXISTS question_imports_status_idx
  ON public.question_imports(status);
CREATE INDEX IF NOT EXISTS question_imports_created_at_idx
  ON public.question_imports(created_at DESC);

-- RLS : admin only
ALTER TABLE public.question_imports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS qimp_admin_all ON public.question_imports;
CREATE POLICY qimp_admin_all ON public.question_imports
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------------
-- Lien remontant question_bank → import (optionnel mais utile)
-- ---------------------------------------------------------------------
ALTER TABLE public.question_bank
  ADD COLUMN IF NOT EXISTS import_id uuid
    REFERENCES public.question_imports(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS question_bank_import_idx
  ON public.question_bank(import_id) WHERE import_id IS NOT NULL;

COMMENT ON COLUMN public.question_bank.import_id IS
  'ID de l''import en lot d''où provient cette question. NULL = saisie manuelle.';

-- ---------------------------------------------------------------------
-- Vérif post-migration
-- ---------------------------------------------------------------------
DO $$
DECLARE
  v_has_table boolean;
  v_has_col boolean;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'question_imports'
  ) INTO v_has_table;

  SELECT EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'question_bank'
      AND column_name = 'import_id'
  ) INTO v_has_col;

  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Migration question_imports · Phase 6';
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE '  question_imports table ................. %', v_has_table;
  RAISE NOTICE '  question_bank.import_id column ......... %', v_has_col;
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;
