-- ============================================================
-- INFRA - Messagerie v2.3 attachments + reactions
-- ============================================================
-- Ajoute deux features Phase C :
--
--   1) Pièces jointes (message_attachments)
--      - 1 message peut avoir N pièces jointes
--      - Le fichier est stocké dans le bucket Storage 'message-attachments'
--      - storage_path = chemin relatif dans le bucket (ex:
--        '<conversation_id>/<message_id>/<filename>')
--      - On stocke aussi mime_type, size_bytes, original_name, et
--        width/height pour les images (preview UI sans téléchargement)
--
--   2) Réactions emoji (message_reactions)
--      - PK composite (message_id, user_id, emoji)
--      - 1 user peut poser plusieurs emojis distincts sur 1 message
--      - 2 users peuvent poser le même emoji → comptés ensemble
--      - RPC toggle_reaction : ajoute si absent, supprime si déjà posé
--
-- ⚠️ Prérequis Storage :
--   Avant de tester l'upload, créer un bucket 'message-attachments' dans
--   Supabase Dashboard → Storage → New bucket.
--   - Public bucket : NON (privé, RLS gère l'accès)
--   - File size limit : 10 MB (recommandé)
--   - Allowed MIME types : laisser vide ou restreindre côté client.
--   Les RLS Storage sont créés à la fin de ce script.
--
-- Idempotent — peut être rejoué plusieurs fois sans casse.
-- Pré-requis SQL : messaging_v2_multi_conversations + v2.1 + v2.2.
-- ============================================================

-- ------------------------------------------------------------
-- 1) Table message_attachments
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.message_attachments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id uuid NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
  storage_path text NOT NULL UNIQUE,
  mime_type text NOT NULL,
  size_bytes bigint NOT NULL,
  original_name text NOT NULL,
  width int,
  height int,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS msg_att_msg_idx ON public.message_attachments(message_id);

ALTER TABLE public.message_attachments ENABLE ROW LEVEL SECURITY;

-- Lecture : participant de la conv parente OU staff
DROP POLICY IF EXISTS msg_att_read ON public.message_attachments;
CREATE POLICY msg_att_read ON public.message_attachments
  FOR SELECT USING (
    public.is_staff()
    OR EXISTS (
      SELECT 1 FROM public.messages m
       WHERE m.id = message_attachments.message_id
         AND public.is_my_conversation(m.conversation_id)
    )
  );

-- Insert : auteur du message uniquement
DROP POLICY IF EXISTS msg_att_insert ON public.message_attachments;
CREATE POLICY msg_att_insert ON public.message_attachments
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.messages m
       WHERE m.id = message_id
         AND m.sender_id = auth.uid()
    )
  );

-- Delete : auteur du message OU staff
DROP POLICY IF EXISTS msg_att_delete ON public.message_attachments;
CREATE POLICY msg_att_delete ON public.message_attachments
  FOR DELETE USING (
    public.is_staff()
    OR EXISTS (
      SELECT 1 FROM public.messages m
       WHERE m.id = message_attachments.message_id
         AND m.sender_id = auth.uid()
    )
  );

-- ------------------------------------------------------------
-- 2) Table message_reactions
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.message_reactions (
  message_id uuid NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  emoji text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (message_id, user_id, emoji)
);

CREATE INDEX IF NOT EXISTS msg_react_msg_idx
  ON public.message_reactions(message_id);

ALTER TABLE public.message_reactions ENABLE ROW LEVEL SECURITY;

-- Lecture : participant de la conv parente OU staff
DROP POLICY IF EXISTS msg_react_read ON public.message_reactions;
CREATE POLICY msg_react_read ON public.message_reactions
  FOR SELECT USING (
    public.is_staff()
    OR EXISTS (
      SELECT 1 FROM public.messages m
       WHERE m.id = message_reactions.message_id
         AND public.is_my_conversation(m.conversation_id)
    )
  );

-- Insert / delete : passe par RPC toggle_reaction (SECURITY DEFINER)

-- ------------------------------------------------------------
-- 3) RPC : toggle_reaction
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.toggle_reaction(
  p_message_id uuid,
  p_emoji text
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_conv_id uuid;
  v_existed boolean;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Non authentifié';
  END IF;

  IF length(trim(p_emoji)) = 0 OR length(p_emoji) > 16 THEN
    RAISE EXCEPTION 'Emoji invalide';
  END IF;

  -- Récupère la conv du message
  SELECT conversation_id INTO v_conv_id
    FROM public.messages
   WHERE id = p_message_id;
  IF v_conv_id IS NULL THEN
    RAISE EXCEPTION 'Message introuvable';
  END IF;

  -- Vérifie que l'utilisateur est participant de la conv
  IF NOT public.is_my_conversation(v_conv_id) AND NOT public.is_staff() THEN
    RAISE EXCEPTION 'Vous n''êtes pas participant';
  END IF;

  -- Toggle
  SELECT EXISTS (
    SELECT 1 FROM public.message_reactions
     WHERE message_id = p_message_id
       AND user_id = v_uid
       AND emoji = p_emoji
  ) INTO v_existed;

  IF v_existed THEN
    DELETE FROM public.message_reactions
     WHERE message_id = p_message_id
       AND user_id = v_uid
       AND emoji = p_emoji;
    RETURN false; -- réaction retirée
  ELSE
    INSERT INTO public.message_reactions (message_id, user_id, emoji)
    VALUES (p_message_id, v_uid, p_emoji);
    RETURN true; -- réaction ajoutée
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.toggle_reaction(uuid, text) TO authenticated;

-- ------------------------------------------------------------
-- 4) Realtime : ajouter les tables à la publication
-- ------------------------------------------------------------
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    BEGIN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.message_attachments;
    EXCEPTION
      WHEN duplicate_object THEN NULL;
    END;
    BEGIN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.message_reactions;
    EXCEPTION
      WHEN duplicate_object THEN NULL;
    END;
  END IF;
END $$;

ALTER TABLE public.message_attachments REPLICA IDENTITY FULL;
ALTER TABLE public.message_reactions REPLICA IDENTITY FULL;

-- ------------------------------------------------------------
-- 5) Storage RLS : bucket 'message-attachments'
--    À jouer APRÈS création du bucket via Dashboard.
--    Si le bucket n'existe pas, le bloc est silencieusement ignoré.
-- ------------------------------------------------------------
DO $$
DECLARE
  v_bucket_exists boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM storage.buckets WHERE id = 'message-attachments'
  ) INTO v_bucket_exists;

  IF NOT v_bucket_exists THEN
    RAISE NOTICE '⚠ Bucket "message-attachments" introuvable.';
    RAISE NOTICE '   Crée-le dans Supabase Dashboard → Storage → New bucket :';
    RAISE NOTICE '   Name: message-attachments · Public: NO · File size: 10 MB';
    RAISE NOTICE '   Puis relance ce script (les policies seront ajoutées).';
    RETURN;
  END IF;

  -- Lecture : tout participant d'une conv ayant un message lié à ce path
  -- Convention : storage_path = '<conversation_id>/<message_id>/<filename>'
  -- → 1er segment = conversation_id
  EXECUTE $policy$
    DROP POLICY IF EXISTS "msg_attachments_read" ON storage.objects;
    CREATE POLICY "msg_attachments_read" ON storage.objects
      FOR SELECT
      USING (
        bucket_id = 'message-attachments'
        AND (
          public.is_staff()
          OR public.is_my_conversation((storage.foldername(name))[1]::uuid)
        )
      );
  $policy$;

  -- Insert : utilisateur authentifié, qui doit aussi être participant
  -- de la conv ciblée (1er segment du path)
  EXECUTE $policy$
    DROP POLICY IF EXISTS "msg_attachments_insert" ON storage.objects;
    CREATE POLICY "msg_attachments_insert" ON storage.objects
      FOR INSERT
      WITH CHECK (
        bucket_id = 'message-attachments'
        AND auth.uid() IS NOT NULL
        AND public.is_my_conversation((storage.foldername(name))[1]::uuid)
      );
  $policy$;

  -- Delete : auteur de l'attachment OU staff
  EXECUTE $policy$
    DROP POLICY IF EXISTS "msg_attachments_delete" ON storage.objects;
    CREATE POLICY "msg_attachments_delete" ON storage.objects
      FOR DELETE
      USING (
        bucket_id = 'message-attachments'
        AND (
          public.is_staff()
          OR EXISTS (
            SELECT 1
              FROM public.message_attachments ma
              JOIN public.messages m ON m.id = ma.message_id
             WHERE ma.storage_path = storage.objects.name
               AND m.sender_id = auth.uid()
          )
        )
      );
  $policy$;

  RAISE NOTICE '✓ Storage policies bucket "message-attachments" appliquées';
END $$;

-- ------------------------------------------------------------
-- 6) Vérification finale
-- ------------------------------------------------------------
DO $$
DECLARE
  v_attachments_table boolean;
  v_reactions_table boolean;
  v_bucket boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
     WHERE table_schema = 'public' AND table_name = 'message_attachments'
  ) INTO v_attachments_table;
  SELECT EXISTS (
    SELECT 1 FROM information_schema.tables
     WHERE table_schema = 'public' AND table_name = 'message_reactions'
  ) INTO v_reactions_table;
  SELECT EXISTS (
    SELECT 1 FROM storage.buckets WHERE id = 'message-attachments'
  ) INTO v_bucket;

  RAISE NOTICE '╔════════════════════════════════════════════════════';
  RAISE NOTICE '║ ✓ Phase C — attachments + reactions';
  RAISE NOTICE '╠════════════════════════════════════════════════════';
  RAISE NOTICE '║ Table message_attachments  : %', CASE WHEN v_attachments_table THEN 'OK' ELSE 'MANQUE' END;
  RAISE NOTICE '║ Table message_reactions    : %', CASE WHEN v_reactions_table THEN 'OK' ELSE 'MANQUE' END;
  RAISE NOTICE '║ Bucket message-attachments : %', CASE WHEN v_bucket THEN 'OK' ELSE 'À CRÉER' END;
  RAISE NOTICE '║ RPC toggle_reaction        : OK';
  RAISE NOTICE '╠════════════════════════════════════════════════════';
  IF NOT v_bucket THEN
    RAISE NOTICE '║ ⚠ Bucket à créer dans Dashboard → Storage';
    RAISE NOTICE '║   puis re-run ce script pour appliquer les RLS';
  END IF;
  RAISE NOTICE '╚════════════════════════════════════════════════════';
END $$;
