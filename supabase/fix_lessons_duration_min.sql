-- =====================================================================
-- FIX — ajout de la colonne duration_min sur public.lessons
--
-- Les seeds capa_module_*_enriched.sql attendent cette colonne pour
-- indiquer la durée estimée de chaque leçon (utilisée par /modules pour
-- afficher le temps de lecture, et /stats pour la progression).
--
-- La table existante n'avait pas ce champ. Migration idempotente.
-- =====================================================================

ALTER TABLE public.lessons
  ADD COLUMN IF NOT EXISTS duration_min int NOT NULL DEFAULT 30;

-- Cover URL (utilisée par les modules enrichis si on ajoute une image)
ALTER TABLE public.lessons
  ADD COLUMN IF NOT EXISTS cover_url text;

-- Video URL (lecture vidéo embarquée — déjà utilisée dans certains seeds)
ALTER TABLE public.lessons
  ADD COLUMN IF NOT EXISTS video_url text;

-- Index utile : tri par durée pour parcours pédagogique optimisé
CREATE INDEX IF NOT EXISTS lessons_duration_idx
  ON public.lessons(duration_min)
  WHERE duration_min IS NOT NULL;
