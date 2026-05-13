-- =====================================================================
-- 2026-05-14 · Banque questions : leçons + annexes PDF (Phase 6.2)
--
-- Deux ajouts liés à la demande client :
--
--   1. Rattachement à une LEÇON (en plus du module). Permet d'avoir des
--      questions ciblées sur "Module 1 — Leçon 1.3" plutôt que sur tout
--      un module. Optionnel ; quand NULL, la question reste rattachée
--      au module entier.
--
--   2. Capture des ANNEXES du PDF source : on stocke le PDF original
--      dans Supabase Storage et on enregistre, pour chaque question, les
--      numéros de pages d'annexe à afficher au stagiaire au moment où
--      il répond.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Colonne lesson_id sur question_bank
-- ---------------------------------------------------------------------
ALTER TABLE public.question_bank
  ADD COLUMN IF NOT EXISTS lesson_id uuid
    REFERENCES public.lessons(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS question_bank_lesson_idx
  ON public.question_bank(lesson_id) WHERE lesson_id IS NOT NULL;

COMMENT ON COLUMN public.question_bank.lesson_id IS
  'Rattachement optionnel à une leçon spécifique du module. NULL = module entier.';

-- ---------------------------------------------------------------------
-- 2) Annexes : référence vers le PDF source + pages liées
-- ---------------------------------------------------------------------

-- Sur question_imports : le path Storage du PDF source (utile pour
-- toutes les questions issues de cet import qui ont des annexes).
ALTER TABLE public.question_imports
  ADD COLUMN IF NOT EXISTS pdf_storage_path text,
  -- Pages détectées comme étant des annexes (numérotation à 1 = page 1).
  ADD COLUMN IF NOT EXISTS annex_pages int[] NOT NULL DEFAULT '{}',
  -- Référence textuelle associée à chaque annexe (même ordre que annex_pages).
  -- Ex. ['Annexe 1', 'Annexe 2 — barème'].
  ADD COLUMN IF NOT EXISTS annex_labels text[] NOT NULL DEFAULT '{}';

COMMENT ON COLUMN public.question_imports.pdf_storage_path IS
  'Path dans le bucket Storage "question-imports" du PDF source. '
  'NULL si l''import a été fait via paste de texte.';

-- Sur question_bank : pour chaque question, les pages d'annexe à afficher
-- au stagiaire (sous-ensemble des annexes du PDF source).
ALTER TABLE public.question_bank
  ADD COLUMN IF NOT EXISTS annex_pages int[] NOT NULL DEFAULT '{}',
  -- Étiquettes lisibles dans l'UI ("Annexe 1", "Tableau coûts d'exploitation")
  ADD COLUMN IF NOT EXISTS annex_labels text[] NOT NULL DEFAULT '{}';

COMMENT ON COLUMN public.question_bank.annex_pages IS
  'Numéros de pages du PDF source (lié via import_id → question_imports.pdf_storage_path) '
  'à afficher au stagiaire pendant qu''il répond à cette question.';

-- ---------------------------------------------------------------------
-- 3) Storage bucket "question-imports" (privé)
--
-- ⚠️ La création de bucket via SQL nécessite l'extension storage.
-- Si le bucket existe déjà, ce bloc est idempotent.
-- ---------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'question-imports',
  'question-imports',
  false, -- privé : on accède via signed URL côté stagiaire
  20 * 1024 * 1024, -- 20 MB max
  ARRAY['application/pdf']
)
ON CONFLICT (id) DO UPDATE
  SET file_size_limit = EXCLUDED.file_size_limit,
      allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Policies Storage : admin can upload/delete, authenticated can read
-- (la lecture est gatée par le code applicatif via signed URLs).
DROP POLICY IF EXISTS "question_imports_admin_all" ON storage.objects;
CREATE POLICY "question_imports_admin_all"
  ON storage.objects FOR ALL
  USING (bucket_id = 'question-imports' AND public.is_admin())
  WITH CHECK (bucket_id = 'question-imports' AND public.is_admin());

DROP POLICY IF EXISTS "question_imports_authenticated_read" ON storage.objects;
CREATE POLICY "question_imports_authenticated_read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'question-imports' AND auth.role() = 'authenticated');

-- ---------------------------------------------------------------------
-- 4) Vérif post-migration
-- ---------------------------------------------------------------------
DO $$
DECLARE
  v_has_lesson boolean;
  v_has_annex_pages boolean;
  v_has_pdf_path boolean;
  v_has_bucket boolean;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'question_bank'
      AND column_name = 'lesson_id'
  ) INTO v_has_lesson;

  SELECT EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'question_bank'
      AND column_name = 'annex_pages'
  ) INTO v_has_annex_pages;

  SELECT EXISTS(
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'question_imports'
      AND column_name = 'pdf_storage_path'
  ) INTO v_has_pdf_path;

  SELECT EXISTS(
    SELECT 1 FROM storage.buckets WHERE id = 'question-imports'
  ) INTO v_has_bucket;

  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Migration questions: leçons + annexes · Phase 6.2';
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE '  question_bank.lesson_id ................. %', v_has_lesson;
  RAISE NOTICE '  question_bank.annex_pages ............... %', v_has_annex_pages;
  RAISE NOTICE '  question_imports.pdf_storage_path ....... %', v_has_pdf_path;
  RAISE NOTICE '  Storage bucket "question-imports" ....... %', v_has_bucket;
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;
