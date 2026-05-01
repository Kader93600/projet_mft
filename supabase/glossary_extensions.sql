-- =====================================================================
-- GLOSSARY — extensions multi-formations
--
-- Ajoute formation_id pour filtrer les termes par formation côté UI
-- (en complément du filtre bloc existant). Idempotent.
-- =====================================================================

ALTER TABLE public.glossary_terms
  ADD COLUMN IF NOT EXISTS formation_id uuid
  REFERENCES public.formations(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS glossary_formation_idx
  ON public.glossary_terms(formation_id);

CREATE INDEX IF NOT EXISTS glossary_formation_term_idx
  ON public.glossary_terms(formation_id, lower(term));
