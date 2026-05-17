-- =====================================================================
-- Sprint 3 / P3 #1 — IA tuteur RAG (Claude Sonnet 4 + pgvector)
-- 2026-05-18
--
-- Objectif : permettre au stagiaire Premium d'interroger un chatbot
-- pédagogique qui répond avec des citations sourcées dans les leçons
-- de la formation. Et permettre à terme la correction des QR.
--
-- Stack :
--   • Embeddings : OpenAI text-embedding-3-small (1536 dim)
--   • LLM        : Anthropic Claude Sonnet 4 (côté code app uniquement)
--   • Vector DB  : pgvector sur Supabase (extension officielle)
--
-- Tables :
--   • lesson_chunks       : chunks de leçons + embeddings (search RAG)
--   • tutor_conversations : 1 conversation par fil
--   • tutor_messages      : messages user/assistant/system d'une conv
--   • tutor_quotas        : compteurs anti-abus par stagiaire et par mois
--
-- RPC :
--   • search_lesson_chunks(query_embedding, match_count, formation_filter)
--     → top-N chunks pertinents pour la question
-- =====================================================================

-- 1. Extension pgvector (idempotent)
CREATE EXTENSION IF NOT EXISTS vector;

-- ─────────────────────────────────────────────────────────────────────
-- 2. lesson_chunks
-- ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.lesson_chunks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id uuid NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  chunk_index int NOT NULL,
  content text NOT NULL,
  token_count int,
  embedding vector(1536),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (lesson_id, chunk_index)
);

COMMENT ON TABLE public.lesson_chunks IS
  'Chunks de leçons embeddés (RAG). Re-générés par scripts/ingest-lessons-embeddings.ts';

-- Index ivfflat pour la similarité cosinus (à recalculer après import massif)
CREATE INDEX IF NOT EXISTS lesson_chunks_embedding_ivfflat_idx
  ON public.lesson_chunks
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);

CREATE INDEX IF NOT EXISTS lesson_chunks_lesson_idx
  ON public.lesson_chunks(lesson_id);

-- RLS : lecture pour tout authentifié (le contenu provient déjà des leçons
-- publiques au sein de la formation du stagiaire)
ALTER TABLE public.lesson_chunks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS lesson_chunks_read ON public.lesson_chunks;
CREATE POLICY lesson_chunks_read ON public.lesson_chunks
  FOR SELECT
  TO authenticated
  USING (true);

DROP POLICY IF EXISTS lesson_chunks_admin ON public.lesson_chunks;
CREATE POLICY lesson_chunks_admin ON public.lesson_chunks
  FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ─────────────────────────────────────────────────────────────────────
-- 3. tutor_conversations
-- ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tutor_conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title text,
  -- Contexte (optionnel) : la conv est-elle lancée depuis un module spécifique ?
  context_module_id uuid REFERENCES public.modules(id) ON DELETE SET NULL,
  context_formation_slug text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS tutor_conversations_user_idx
  ON public.tutor_conversations(user_id, updated_at DESC);

ALTER TABLE public.tutor_conversations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tutor_conv_self ON public.tutor_conversations;
CREATE POLICY tutor_conv_self ON public.tutor_conversations
  FOR ALL
  USING (auth.uid() = user_id OR public.is_admin())
  WITH CHECK (auth.uid() = user_id OR public.is_admin());

-- ─────────────────────────────────────────────────────────────────────
-- 4. tutor_messages
-- ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tutor_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES public.tutor_conversations(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content text NOT NULL,
  -- Citations utilisées par l'assistant : tableau JSON de
  -- [{ lesson_id, chunk_id, lesson_title, similarity, snippet }]
  citations jsonb,
  -- Métriques coût + modération
  tokens_in int,
  tokens_out int,
  cost_cents int,
  moderation_passed boolean,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS tutor_messages_conv_idx
  ON public.tutor_messages(conversation_id, created_at);

ALTER TABLE public.tutor_messages ENABLE ROW LEVEL SECURITY;

-- L'utilisateur peut lire ses propres messages (via la conv jointe)
DROP POLICY IF EXISTS tutor_msg_self ON public.tutor_messages;
CREATE POLICY tutor_msg_self ON public.tutor_messages
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.tutor_conversations c
      WHERE c.id = tutor_messages.conversation_id
        AND (c.user_id = auth.uid() OR public.is_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.tutor_conversations c
      WHERE c.id = tutor_messages.conversation_id
        AND (c.user_id = auth.uid() OR public.is_admin())
    )
  );

-- Met à jour `updated_at` sur la conv quand un message est ajouté
CREATE OR REPLACE FUNCTION public.tg_tutor_conv_touch()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  UPDATE public.tutor_conversations
     SET updated_at = now()
   WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_tutor_conv_touch ON public.tutor_messages;
CREATE TRIGGER tg_tutor_conv_touch
  AFTER INSERT ON public.tutor_messages
  FOR EACH ROW EXECUTE FUNCTION public.tg_tutor_conv_touch();

-- ─────────────────────────────────────────────────────────────────────
-- 5. tutor_quotas
-- ─────────────────────────────────────────────────────────────────────
-- Compteur mensuel par utilisateur. Reset implicite via `month`.
-- En décision client 2026-05 : IA tuteur = Premium uniquement, donc
-- pas de quota strict pour la v1 — on monitore. Mais la table est
-- prête pour brancher un plafond plus tard.
CREATE TABLE IF NOT EXISTS public.tutor_quotas (
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  month date NOT NULL,            -- premier du mois (date_trunc('month', now()))
  messages_count int NOT NULL DEFAULT 0,
  cost_cents int NOT NULL DEFAULT 0,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, month)
);

ALTER TABLE public.tutor_quotas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tutor_quotas_self ON public.tutor_quotas;
CREATE POLICY tutor_quotas_self ON public.tutor_quotas
  FOR SELECT
  USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS tutor_quotas_admin ON public.tutor_quotas;
CREATE POLICY tutor_quotas_admin ON public.tutor_quotas
  FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- RPC pour incrémenter de manière atomique (utilisé après chaque message
-- assistant inséré). Le code app s'en sert avec security definer.
CREATE OR REPLACE FUNCTION public.bump_tutor_quota(
  p_user uuid,
  p_messages int DEFAULT 1,
  p_cost_cents int DEFAULT 0
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.tutor_quotas (user_id, month, messages_count, cost_cents)
  VALUES (p_user, date_trunc('month', now())::date, p_messages, p_cost_cents)
  ON CONFLICT (user_id, month)
  DO UPDATE SET
    messages_count = tutor_quotas.messages_count + EXCLUDED.messages_count,
    cost_cents = tutor_quotas.cost_cents + EXCLUDED.cost_cents,
    updated_at = now();
END;
$$;

GRANT EXECUTE ON FUNCTION public.bump_tutor_quota(uuid, int, int) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 6. RPC search_lesson_chunks
-- ─────────────────────────────────────────────────────────────────────
-- Cherche les N chunks les plus proches d'un embedding donné, optionnellement
-- filtrés par formation_slug. Utilisé par /api/tutor/ask juste après
-- l'embedding de la question utilisateur.
--
-- Retourne :
--   - chunk_id, lesson_id, content
--   - similarity (1 - cosine distance, plus c'est haut mieux c'est)
--   - lesson_title, module_slug, module_title (pour les citations UI)
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.search_lesson_chunks(
  query_embedding vector(1536),
  match_count int DEFAULT 6,
  formation_filter text DEFAULT NULL
)
RETURNS TABLE (
  chunk_id uuid,
  lesson_id uuid,
  content text,
  similarity float,
  lesson_title text,
  module_slug text,
  module_title text
)
LANGUAGE sql STABLE
AS $$
  SELECT
    c.id AS chunk_id,
    c.lesson_id,
    c.content,
    1 - (c.embedding <=> query_embedding) AS similarity,
    l.title AS lesson_title,
    m.slug  AS module_slug,
    m.title AS module_title
  FROM public.lesson_chunks c
  JOIN public.lessons l ON l.id = c.lesson_id
  JOIN public.modules m ON m.id = l.module_id
  WHERE formation_filter IS NULL
     OR EXISTS (
       SELECT 1
         FROM public.formation_modules fm
         JOIN public.formations f ON f.id = fm.formation_id
        WHERE fm.module_id = m.id
          AND f.slug = formation_filter
     )
  ORDER BY c.embedding <=> query_embedding
  LIMIT match_count;
$$;

GRANT EXECUTE ON FUNCTION public.search_lesson_chunks(vector(1536), int, text) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 7. Maintenance : index ivfflat reconstruct (utilitaire)
-- ─────────────────────────────────────────────────────────────────────
-- À lancer après un import massif (>10k chunks) pour ré-équilibrer les listes.
--   REINDEX INDEX public.lesson_chunks_embedding_ivfflat_idx;
-- Une migration ultérieure pourra basculer sur hnsw si pgvector le supporte
-- dans la version de Postgres déployée par Supabase.
