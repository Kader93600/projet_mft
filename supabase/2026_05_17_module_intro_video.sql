-- =====================================================================
-- 2026-05-17 · Vidéos d'introduction par module
--
-- Ajoute la possibilité d'attacher une vidéo MP4 d'introduction au début
-- d'un module. Cas d'usage initial : 6 vidéos intro pour les modules
-- Capacité ≤ 3,5 t (modules A à F), une par module.
--
-- Architecture :
--   - Colonne modules.intro_video_path : storage_path dans le bucket
--     "module-intro-videos" (privé, signed URL 1h pour le stagiaire).
--   - Colonne modules.intro_video_label : titre court affiché sous la vidéo
--     ("Découvrez le module en 3 minutes", etc.).
--   - Colonne modules.intro_video_duration_s : durée informationnelle
--     pour pré-afficher au stagiaire avant qu'il lance la lecture.
--
-- Idempotent : ADD COLUMN IF NOT EXISTS + INSERT bucket ON CONFLICT.
-- =====================================================================

ALTER TABLE public.modules
  ADD COLUMN IF NOT EXISTS intro_video_path text NULL,
  ADD COLUMN IF NOT EXISTS intro_video_label text NULL,
  ADD COLUMN IF NOT EXISTS intro_video_duration_s int NULL;

COMMENT ON COLUMN public.modules.intro_video_path IS
  'Chemin storage dans le bucket "module-intro-videos" (ex: capa/module-a.mp4). NULL = pas de vidéo intro.';
COMMENT ON COLUMN public.modules.intro_video_label IS
  'Libellé court affiché sous la vidéo intro côté stagiaire.';
COMMENT ON COLUMN public.modules.intro_video_duration_s IS
  'Durée de la vidéo en secondes (informationnel, affichage UI).';

-- ---------------------------------------------------------------------
-- Bucket Storage "module-intro-videos"
-- Privé : signed URL pour les stagiaires inscrits à la formation
-- ---------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'module-intro-videos',
  'module-intro-videos',
  false,
  100 * 1024 * 1024, -- 100 MB max par vidéo (large marge pour <50 MB)
  ARRAY[
    'video/mp4',
    'video/webm',
    'video/quicktime'
  ]
)
ON CONFLICT (id) DO UPDATE
  SET file_size_limit = EXCLUDED.file_size_limit,
      allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ---------------------------------------------------------------------
-- Policies Storage : lecture stagiaire (si inscrit à la formation du module)
-- ---------------------------------------------------------------------
-- Note : nettoyage des anciennes policies si rerun
DROP POLICY IF EXISTS module_intro_videos_student_read ON storage.objects;
CREATE POLICY module_intro_videos_student_read ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'module-intro-videos'
    AND auth.role() = 'authenticated'
    AND EXISTS (
      SELECT 1
      FROM public.modules m
      JOIN public.formation_modules fm ON fm.module_id = m.id
      JOIN public.formations f ON f.id = fm.formation_id
      WHERE m.intro_video_path = storage.objects.name
        AND public.has_formation_access(auth.uid(), f.slug)
    )
  );

-- Lecture admin : tout
DROP POLICY IF EXISTS module_intro_videos_admin_read ON storage.objects;
CREATE POLICY module_intro_videos_admin_read ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'module-intro-videos'
    AND public.is_admin()
  );

-- Écriture (upload/update/delete) : staff uniquement
DROP POLICY IF EXISTS module_intro_videos_admin_write ON storage.objects;
CREATE POLICY module_intro_videos_admin_write ON storage.objects
  FOR ALL
  USING (
    bucket_id = 'module-intro-videos'
    AND public.is_admin()
  )
  WITH CHECK (
    bucket_id = 'module-intro-videos'
    AND public.is_admin()
  );
