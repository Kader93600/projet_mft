-- ============================================================
-- Enrichissement pédagogique (Point #7)
--   - video_url sur lessons (intro vidéo)
--   - lesson_resources : PDF, liens, documents, vidéos externes
--   - glossary_terms : glossaire RNCP transversal
-- ============================================================

ALTER TABLE public.lessons
  ADD COLUMN IF NOT EXISTS video_url text;

-- ------------------------------------------------------------
-- 1. Ressources attachées à une leçon
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.lesson_resources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id uuid NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  kind text NOT NULL CHECK (kind IN ('pdf', 'video', 'link', 'doc', 'image')),
  title text NOT NULL,
  url text NOT NULL,
  description text,
  size_kb int,
  "order" int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS lesson_res_lesson_idx
  ON public.lesson_resources(lesson_id, "order");

ALTER TABLE public.lesson_resources ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS lesson_res_read ON public.lesson_resources;
CREATE POLICY lesson_res_read ON public.lesson_resources
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS lesson_res_admin ON public.lesson_resources;
CREATE POLICY lesson_res_admin ON public.lesson_resources
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ------------------------------------------------------------
-- 2. Glossaire RNCP
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.glossary_terms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  term text NOT NULL,
  definition_md text NOT NULL,
  bloc_id int REFERENCES public.blocs(id) ON DELETE SET NULL,
  synonyms text[] NOT NULL DEFAULT '{}',
  source text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS glossary_term_unique
  ON public.glossary_terms(lower(term));

CREATE INDEX IF NOT EXISTS glossary_bloc_idx ON public.glossary_terms(bloc_id);

-- Index trigram pour accélérer la recherche ILIKE côté app
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX IF NOT EXISTS glossary_term_trgm
  ON public.glossary_terms USING gin (term gin_trgm_ops);
CREATE INDEX IF NOT EXISTS glossary_def_trgm
  ON public.glossary_terms USING gin (definition_md gin_trgm_ops);

ALTER TABLE public.glossary_terms ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS glossary_read ON public.glossary_terms;
CREATE POLICY glossary_read ON public.glossary_terms
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS glossary_admin ON public.glossary_terms;
CREATE POLICY glossary_admin ON public.glossary_terms
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Trigger updated_at
CREATE OR REPLACE FUNCTION public.tg_glossary_bump()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS glossary_updated_at ON public.glossary_terms;
CREATE TRIGGER glossary_updated_at
  BEFORE UPDATE ON public.glossary_terms
  FOR EACH ROW EXECUTE FUNCTION public.tg_glossary_bump();
