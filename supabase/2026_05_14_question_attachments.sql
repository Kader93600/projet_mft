-- =====================================================================
-- 2026-05-14 · Annexes libres attachées à une question (Phase 6.4)
--
-- Complète le système d'annexes-pages issu de l'import en lot :
--   - annex_pages / annex_labels  : pages d'un PDF source (import)
--   - question_attachments (new)  : fichiers libres uploadés à la main
--                                   par l'admin depuis la fiche question
--
-- Cas d'usage typique : un admin reçoit une image (tableau de coûts,
-- carte de tournée, schéma logistique) qui clarifie une question
-- existante → il la glisse-dépose depuis /admin/banque-questions/
-- validation-qr et c'est ajouté à la question instantanément.
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.question_attachments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  question_id uuid NOT NULL
    REFERENCES public.question_bank(id) ON DELETE CASCADE,

  -- Path dans le bucket Storage "question-attachments"
  storage_path text NOT NULL,
  file_name text NOT NULL,
  mime_type text NOT NULL,
  size_bytes int,

  -- Catégorie d'affichage côté stagiaire (image inline, iframe PDF,
  -- lien de téléchargement pour le reste).
  kind text NOT NULL DEFAULT 'other'
    CHECK (kind IN ('image', 'pdf', 'document', 'other')),

  -- Libellé optionnel ("Tableau coûts d'exploitation", "Schéma ADR")
  label text,
  display_order int NOT NULL DEFAULT 100,

  created_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS question_attachments_question_idx
  ON public.question_attachments(question_id, display_order);

ALTER TABLE public.question_attachments ENABLE ROW LEVEL SECURITY;

-- Lecture stagiaire : seulement si la question est accessible
-- (mêmes règles que question_bank — formation à laquelle il est inscrit).
DROP POLICY IF EXISTS qattach_student_read ON public.question_attachments;
CREATE POLICY qattach_student_read ON public.question_attachments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.question_bank q
      WHERE q.id = question_attachments.question_id
        AND q.active = true
        AND q.formation_id IS NOT NULL
        AND EXISTS (
          SELECT 1 FROM public.formations f
          WHERE f.id = q.formation_id
            AND public.has_formation_access(auth.uid(), f.slug)
        )
    )
  );

-- Lecture staff : tout
DROP POLICY IF EXISTS qattach_admin_read ON public.question_attachments;
CREATE POLICY qattach_admin_read ON public.question_attachments
  FOR SELECT USING (public.is_admin());

-- Écriture : staff uniquement
DROP POLICY IF EXISTS qattach_admin_write ON public.question_attachments;
CREATE POLICY qattach_admin_write ON public.question_attachments
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------------
-- Storage bucket "question-attachments"
-- ---------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'question-attachments',
  'question-attachments',
  false, -- privé, accès via signed URL
  15 * 1024 * 1024, -- 15 MB max par fichier
  ARRAY[
    'application/pdf',
    'image/png',
    'image/jpeg',
    'image/webp',
    'image/gif',
    'image/svg+xml',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/plain',
    'text/csv'
  ]
)
ON CONFLICT (id) DO UPDATE
  SET file_size_limit = EXCLUDED.file_size_limit,
      allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Policies Storage
DROP POLICY IF EXISTS "question_attach_admin_all" ON storage.objects;
CREATE POLICY "question_attach_admin_all"
  ON storage.objects FOR ALL
  USING (bucket_id = 'question-attachments' AND public.is_admin())
  WITH CHECK (bucket_id = 'question-attachments' AND public.is_admin());

DROP POLICY IF EXISTS "question_attach_auth_read" ON storage.objects;
CREATE POLICY "question_attach_auth_read"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'question-attachments'
    AND auth.role() = 'authenticated'
  );

-- ---------------------------------------------------------------------
-- Vérif post-migration
-- ---------------------------------------------------------------------
DO $$
DECLARE
  v_has_table boolean;
  v_has_bucket boolean;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'question_attachments'
  ) INTO v_has_table;

  SELECT EXISTS(
    SELECT 1 FROM storage.buckets WHERE id = 'question-attachments'
  ) INTO v_has_bucket;

  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Migration question_attachments · Phase 6.4';
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE '  Table question_attachments ............ %', v_has_table;
  RAISE NOTICE '  Storage bucket "question-attachments" . %', v_has_bucket;
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;
