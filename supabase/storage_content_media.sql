-- =====================================================================
-- STORAGE — bucket content-media (uploads images modules / quiz / questions)
--
-- Crée le bucket s'il n'existe pas + policies d'upload pour le staff
-- (admin/super_admin) et les formateurs (trainer).
-- Lecture publique (les URLs sont consommées sur les pages stagiaire).
--
-- Idempotent : INSERT ON CONFLICT, CREATE POLICY ... DROP IF EXISTS d'abord.
-- =====================================================================

-- 1) Bucket public (lecture libre, écriture gardée par RLS)
INSERT INTO storage.buckets (id, name, public)
VALUES ('content-media', 'content-media', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2) Lecture : tout le monde (les images sont publiques)
DROP POLICY IF EXISTS "content_media_read" ON storage.objects;
CREATE POLICY "content_media_read"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'content-media');

-- 3) Upload (INSERT) : staff OU trainer uniquement
DROP POLICY IF EXISTS "content_media_upload_staff_or_trainer" ON storage.objects;
CREATE POLICY "content_media_upload_staff_or_trainer"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'content-media'
    AND auth.uid() IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
        AND p.disabled = false
        AND p.role IN ('admin', 'super_admin', 'trainer')
    )
  );

-- 4) Suppression : staff OU trainer (le contrôle de propriété se fait
--    en TS via les actions de modules/questions qui appellent deleteMedia)
DROP POLICY IF EXISTS "content_media_delete_staff_or_trainer" ON storage.objects;
CREATE POLICY "content_media_delete_staff_or_trainer"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'content-media'
    AND auth.uid() IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
        AND p.disabled = false
        AND p.role IN ('admin', 'super_admin', 'trainer')
    )
  );

-- 5) Update (renommage / metadata) : staff seulement
DROP POLICY IF EXISTS "content_media_update_staff" ON storage.objects;
CREATE POLICY "content_media_update_staff"
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'content-media'
    AND auth.uid() IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
        AND p.role IN ('admin', 'super_admin')
    )
  )
  WITH CHECK (
    bucket_id = 'content-media'
    AND auth.uid() IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
        AND p.role IN ('admin', 'super_admin')
    )
  );
