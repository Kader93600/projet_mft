-- =====================================================================
-- Extras pour la convention de formation Qualiopi
-- =====================================================================

ALTER TABLE public.enrollments
  ADD COLUMN IF NOT EXISTS hours_total int,
  ADD COLUMN IF NOT EXISTS modality    text
    CHECK (modality IN ('presentiel','distanciel','mixte')) DEFAULT 'distanciel',
  ADD COLUMN IF NOT EXISTS location    text,
  ADD COLUMN IF NOT EXISTS objectives  text,
  ADD COLUMN IF NOT EXISTS prerequisites text;
