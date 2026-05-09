-- ============================================================
-- INFRA - Messagerie v2.4 search + pin messages
-- ============================================================
-- Phase D :
--
--   1) Pin de messages individuels (à ne pas confondre avec le pin
--      de conversation). Permet d'épingler 1 ou plusieurs messages
--      importants en haut du thread, visibles par tous les participants.
--      - Table pinned_messages (PK composite conversation_id+message_id)
--      - RPC toggle_pinned_message (toggle par n'importe quel participant)
--
--   2) Support recherche full-text :
--      Pour MVP on utilise simplement messages.select().ilike() côté client.
--      RLS filtre automatiquement aux convs du user (via is_my_conversation).
--      On ajoute optionnellement un index trigram pour accélérer si la
--      banque de messages grossit (extension pg_trgm).
--
-- Idempotent — peut être rejoué sans casse.
-- Pré-requis : messaging v2 + v2.1.
-- ============================================================

-- ------------------------------------------------------------
-- 1) Table pinned_messages
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.pinned_messages (
  conversation_id uuid NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  message_id uuid NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
  pinned_by uuid NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  pinned_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (conversation_id, message_id)
);

CREATE INDEX IF NOT EXISTS pinned_msg_conv_idx
  ON public.pinned_messages(conversation_id, pinned_at DESC);

ALTER TABLE public.pinned_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS pinned_msg_read ON public.pinned_messages;
CREATE POLICY pinned_msg_read ON public.pinned_messages
  FOR SELECT USING (
    public.is_staff()
    OR public.is_my_conversation(conversation_id)
  );

-- Insert / Delete : passe par RPC SECURITY DEFINER

-- ------------------------------------------------------------
-- 2) RPC : toggle_pinned_message
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.toggle_pinned_message(
  p_conversation_id uuid,
  p_message_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_existed boolean;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Non authentifié';
  END IF;

  -- Vérifie que le user est bien participant (ou staff)
  IF NOT (public.is_my_conversation(p_conversation_id) OR public.is_staff()) THEN
    RAISE EXCEPTION 'Vous n''êtes pas participant de cette conversation';
  END IF;

  -- Vérifie cohérence : le message doit appartenir à la conv
  IF NOT EXISTS (
    SELECT 1 FROM public.messages
     WHERE id = p_message_id AND conversation_id = p_conversation_id
  ) THEN
    RAISE EXCEPTION 'Message introuvable dans cette conversation';
  END IF;

  -- Toggle
  SELECT EXISTS (
    SELECT 1 FROM public.pinned_messages
     WHERE conversation_id = p_conversation_id
       AND message_id = p_message_id
  ) INTO v_existed;

  IF v_existed THEN
    DELETE FROM public.pinned_messages
     WHERE conversation_id = p_conversation_id
       AND message_id = p_message_id;
    RETURN false;
  ELSE
    INSERT INTO public.pinned_messages (conversation_id, message_id, pinned_by)
    VALUES (p_conversation_id, p_message_id, v_uid);
    RETURN true;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.toggle_pinned_message(uuid, uuid) TO authenticated;

-- ------------------------------------------------------------
-- 3) Realtime : ajouter à la publication
-- ------------------------------------------------------------
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    BEGIN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.pinned_messages;
    EXCEPTION
      WHEN duplicate_object THEN NULL;
    END;
  END IF;
END $$;

ALTER TABLE public.pinned_messages REPLICA IDENTITY FULL;

-- ------------------------------------------------------------
-- 4) Index trigram pour la recherche (optionnel, accélère ILIKE)
--    pg_trgm est disponible par défaut sur Supabase Pro.
-- ------------------------------------------------------------
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_available_extensions WHERE name = 'pg_trgm'
  ) THEN
    CREATE EXTENSION IF NOT EXISTS pg_trgm;
    -- Index trigram sur le body des messages (case-insensitive)
    BEGIN
      CREATE INDEX IF NOT EXISTS msg_body_trgm_idx
        ON public.messages USING gin (lower(body) gin_trgm_ops);
    EXCEPTION
      WHEN OTHERS THEN
        -- Si gin_trgm_ops n'existe pas (extension pas activée), on ignore
        NULL;
    END;
  END IF;
END $$;

-- ------------------------------------------------------------
-- 5) Vérification finale
-- ------------------------------------------------------------
DO $$
DECLARE
  v_table boolean;
  v_rpc boolean;
  v_index boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
     WHERE table_schema = 'public' AND table_name = 'pinned_messages'
  ) INTO v_table;
  SELECT EXISTS (
    SELECT 1 FROM pg_proc WHERE proname = 'toggle_pinned_message'
  ) INTO v_rpc;
  SELECT EXISTS (
    SELECT 1 FROM pg_indexes
     WHERE schemaname = 'public' AND indexname = 'msg_body_trgm_idx'
  ) INTO v_index;

  RAISE NOTICE '╔════════════════════════════════════════════════════';
  RAISE NOTICE '║ ✓ Phase D — search + pin messages';
  RAISE NOTICE '╠════════════════════════════════════════════════════';
  RAISE NOTICE '║ Table pinned_messages    : %', CASE WHEN v_table THEN 'OK' ELSE 'MANQUE' END;
  RAISE NOTICE '║ RPC toggle_pinned_message: %', CASE WHEN v_rpc THEN 'OK' ELSE 'MANQUE' END;
  RAISE NOTICE '║ Index trigram (search)   : %', CASE WHEN v_index THEN 'OK' ELSE 'absent (pas bloquant)' END;
  RAISE NOTICE '╚════════════════════════════════════════════════════';
END $$;
