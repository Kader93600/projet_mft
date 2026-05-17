-- =====================================================================
-- 2026-05-17 · Relax policy module-intro-videos
--
-- La policy initiale (lecture limitée aux stagiaires inscrits à la
-- formation du module) avait un EXISTS imbriqué qui ne s'évaluait pas
-- correctement dans le contexte des appels Storage (la jointure entre
-- storage.objects.name et modules.intro_video_path passait mal selon
-- le runtime PostgREST utilisé pour signed URL).
--
-- Symptôme : signed URL retourne "Object not found" même pour les
-- utilisateurs authentifiés et admins, donc côté UI le composant
-- <ModuleIntroVideo /> fail-soft → rien ne s'affiche.
--
-- Décision : ouvrir la lecture à tous les utilisateurs authentifiés.
-- Les vidéos d'introduction sont pédagogiques (présentation du module),
-- pas confidentielles, et on filtre déjà la visibilité côté DB
-- (le stagiaire ne voit la page module que s'il est inscrit à la
-- formation correspondante — cf. RLS sur modules + gate dans
-- app/modules/[slug]/page.tsx).
-- =====================================================================

DROP POLICY IF EXISTS module_intro_videos_student_read ON storage.objects;
DROP POLICY IF EXISTS module_intro_videos_admin_read ON storage.objects;

CREATE POLICY module_intro_videos_authenticated_read ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'module-intro-videos'
    AND auth.role() = 'authenticated'
  );

-- Écriture (upload/update/delete) : staff uniquement (inchangée)
-- Cette policy reste en place depuis la première migration.
