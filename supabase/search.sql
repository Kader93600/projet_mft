-- =====================================================================
-- MA FORMATION TRANSPORT — Point #13 : Recherche globale
-- =====================================================================
-- RPC global_search(q text, max_per_kind int) qui renvoie :
--   kind | id | title | subtitle | url | rank
-- Couvre : modules, lessons, quizzes, glossary_terms.
-- S'appuie sur pg_trgm (déjà activé) + GIN indexes.
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX IF NOT EXISTS modules_title_trgm
  ON public.modules USING gin (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS modules_summary_trgm
  ON public.modules USING gin (summary gin_trgm_ops);

CREATE INDEX IF NOT EXISTS lessons_title_trgm
  ON public.lessons USING gin (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS lessons_content_trgm
  ON public.lessons USING gin (content_md gin_trgm_ops);

CREATE INDEX IF NOT EXISTS quizzes_title_trgm
  ON public.quizzes USING gin (title gin_trgm_ops);

-- Fonction principale
CREATE OR REPLACE FUNCTION public.global_search(
  q text,
  max_per_kind int DEFAULT 5
)
RETURNS TABLE (
  kind text,
  id text,
  title text,
  subtitle text,
  url text,
  bloc_code text,
  rank real
)
LANGUAGE sql
STABLE
SECURITY INVOKER
AS $$
  WITH qn AS (SELECT trim(q) AS qt)
  -- Modules
  SELECT * FROM (
    SELECT
      'module'::text AS kind,
      m.id::text AS id,
      m.title AS title,
      b.title AS subtitle,
      ('/modules/' || m.slug) AS url,
      b.code AS bloc_code,
      greatest(
        similarity(m.title, (SELECT qt FROM qn)),
        similarity(coalesce(m.summary,''), (SELECT qt FROM qn)) * 0.6
      ) AS rank
    FROM public.modules m
    JOIN public.blocs b ON b.id = m.bloc_id
    WHERE m.title ILIKE '%' || (SELECT qt FROM qn) || '%'
       OR coalesce(m.summary,'') ILIKE '%' || (SELECT qt FROM qn) || '%'
    ORDER BY rank DESC
    LIMIT max_per_kind
  ) modsub
  UNION ALL
  -- Lessons
  SELECT * FROM (
    SELECT
      'lesson'::text AS kind,
      l.id::text AS id,
      l.title AS title,
      m.title AS subtitle,
      ('/modules/' || m.slug || '#' || l.slug) AS url,
      b.code AS bloc_code,
      greatest(
        similarity(l.title, (SELECT qt FROM qn)),
        similarity(left(coalesce(l.content_md,''), 4000), (SELECT qt FROM qn)) * 0.4
      ) AS rank
    FROM public.lessons l
    JOIN public.modules m ON m.id = l.module_id
    JOIN public.blocs b ON b.id = m.bloc_id
    WHERE l.title ILIKE '%' || (SELECT qt FROM qn) || '%'
       OR coalesce(l.content_md,'') ILIKE '%' || (SELECT qt FROM qn) || '%'
    ORDER BY rank DESC
    LIMIT max_per_kind
  ) lsub
  UNION ALL
  -- Quizzes
  SELECT * FROM (
    SELECT
      'quiz'::text AS kind,
      qz.id::text AS id,
      qz.title AS title,
      coalesce(m.title, 'Quiz transversal') AS subtitle,
      ('/quiz/' || qz.id) AS url,
      coalesce(b.code, '—') AS bloc_code,
      similarity(qz.title, (SELECT qt FROM qn)) AS rank
    FROM public.quizzes qz
    LEFT JOIN public.modules m ON m.id = qz.module_id
    LEFT JOIN public.blocs b ON b.id = m.bloc_id
    WHERE qz.title ILIKE '%' || (SELECT qt FROM qn) || '%'
    ORDER BY rank DESC
    LIMIT max_per_kind
  ) qsub
  UNION ALL
  -- Glossary
  SELECT * FROM (
    SELECT
      'glossary'::text AS kind,
      g.id::text AS id,
      g.term AS title,
      left(coalesce(g.definition_md,''), 160) AS subtitle,
      ('/glossaire#' || g.id) AS url,
      coalesce(b.code, '—') AS bloc_code,
      greatest(
        similarity(g.term, (SELECT qt FROM qn)),
        similarity(left(coalesce(g.definition_md,''), 2000), (SELECT qt FROM qn)) * 0.5
      ) AS rank
    FROM public.glossary_terms g
    LEFT JOIN public.blocs b ON b.id = g.bloc_id
    WHERE g.term ILIKE '%' || (SELECT qt FROM qn) || '%'
       OR coalesce(g.definition_md,'') ILIKE '%' || (SELECT qt FROM qn) || '%'
       OR EXISTS (
         SELECT 1 FROM unnest(coalesce(g.synonyms, ARRAY[]::text[])) syn
         WHERE syn ILIKE '%' || (SELECT qt FROM qn) || '%'
       )
    ORDER BY rank DESC
    LIMIT max_per_kind
  ) gsub
  ORDER BY rank DESC;
$$;

GRANT EXECUTE ON FUNCTION public.global_search(text, int) TO authenticated;
