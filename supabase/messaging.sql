-- ============================================================
-- Communication & notifications
--   - notifications : boîte de réception par utilisateur
--   - announcements : annonces diffusables (all / group)
--   - conversations + messages : messagerie directe admin ↔ stagiaire
-- ============================================================

-- ------------------------------------------------------------
-- 1. Notifications (boîte par utilisateur)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type text NOT NULL DEFAULT 'system' CHECK (type IN ('announcement', 'message', 'system', 'quiz_result')),
  title text NOT NULL,
  body text,
  link_url text,
  read_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Migration : schéma existant (read boolean, link text) → nouveau (read_at timestamptz, link_url text, type)
ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS type text,
  ADD COLUMN IF NOT EXISTS link_url text,
  ADD COLUMN IF NOT EXISTS read_at timestamptz;

-- Si la colonne "link" existe encore, on recopie dans link_url
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
     WHERE table_schema = 'public' AND table_name = 'notifications' AND column_name = 'link'
  ) THEN
    EXECUTE 'UPDATE public.notifications SET link_url = COALESCE(link_url, link) WHERE link IS NOT NULL';
    EXECUTE 'ALTER TABLE public.notifications DROP COLUMN link';
  END IF;
END $$;

-- Si la colonne "read" (boolean) existe, on migre vers read_at et on la supprime
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
     WHERE table_schema = 'public' AND table_name = 'notifications' AND column_name = 'read'
  ) THEN
    EXECUTE 'UPDATE public.notifications SET read_at = COALESCE(read_at, created_at) WHERE read = true AND read_at IS NULL';
    EXECUTE 'ALTER TABLE public.notifications DROP COLUMN read';
  END IF;
END $$;

-- Remplir type par défaut et contrainte
UPDATE public.notifications SET type = 'system' WHERE type IS NULL;
ALTER TABLE public.notifications ALTER COLUMN type SET NOT NULL;
ALTER TABLE public.notifications ALTER COLUMN type SET DEFAULT 'system';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'notifications_type_check'
  ) THEN
    ALTER TABLE public.notifications
      ADD CONSTRAINT notifications_type_check
      CHECK (type IN ('announcement', 'message', 'system', 'quiz_result'));
  END IF;
END $$;

-- Remplacer l'ancienne policy "notifs_self_all" (si elle existe) par des policies granulaires
DROP POLICY IF EXISTS "notifs_self_all" ON public.notifications;

CREATE INDEX IF NOT EXISTS notif_user_idx
  ON public.notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS notif_unread_idx
  ON public.notifications(user_id) WHERE read_at IS NULL;

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS notif_own_read ON public.notifications;
CREATE POLICY notif_own_read ON public.notifications
  FOR SELECT USING (user_id = auth.uid() OR public.is_admin());

DROP POLICY IF EXISTS notif_own_update ON public.notifications;
CREATE POLICY notif_own_update ON public.notifications
  FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- L'insertion passe uniquement par les RPC security definer (jamais depuis le client)

-- ------------------------------------------------------------
-- 2. Annonces
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.announcements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  body_md text NOT NULL DEFAULT '',
  audience text NOT NULL DEFAULT 'all' CHECK (audience IN ('all', 'group')),
  group_id uuid REFERENCES public.groups(id) ON DELETE SET NULL,
  pinned boolean NOT NULL DEFAULT false,
  published_at timestamptz,
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ann_published_idx
  ON public.announcements(published_at DESC) WHERE published_at IS NOT NULL;

ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

-- Lecture : admin voit tout ; stagiaire voit les publiées pertinentes
DROP POLICY IF EXISTS ann_read ON public.announcements;
CREATE POLICY ann_read ON public.announcements
  FOR SELECT USING (
    public.is_admin()
    OR (
      published_at IS NOT NULL
      AND (
        audience = 'all'
        OR (
          audience = 'group'
          AND group_id = (SELECT group_id FROM public.profiles WHERE id = auth.uid())
        )
      )
    )
  );

DROP POLICY IF EXISTS ann_write ON public.announcements;
CREATE POLICY ann_write ON public.announcements
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ------------------------------------------------------------
-- 3. RPC : publier une annonce + notifier
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.publish_announcement(p_id uuid)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_ann record;
  v_count int := 0;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Accès refusé';
  END IF;

  SELECT * INTO v_ann FROM public.announcements WHERE id = p_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Annonce introuvable'; END IF;

  UPDATE public.announcements
     SET published_at = coalesce(published_at, now())
   WHERE id = p_id;

  -- Notifier l'audience
  INSERT INTO public.notifications (user_id, type, title, body, link_url)
  SELECT
    p.id,
    'announcement',
    v_ann.title,
    left(coalesce(v_ann.body_md, ''), 280),
    '/notifications'
  FROM public.profiles p
  WHERE p.role = 'student'
    AND p.disabled = false
    AND (v_ann.audience = 'all' OR p.group_id = v_ann.group_id);

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

GRANT EXECUTE ON FUNCTION public.publish_announcement(uuid) TO authenticated;

-- ------------------------------------------------------------
-- 4. Messagerie directe : conversations 1-1 stagiaire ↔ admin
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  last_message_at timestamptz NOT NULL DEFAULT now(),
  user_unread int NOT NULL DEFAULT 0,
  admin_unread int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS conv_last_idx ON public.conversations(last_message_at DESC);

ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS conv_read ON public.conversations;
CREATE POLICY conv_read ON public.conversations
  FOR SELECT USING (user_id = auth.uid() OR public.is_admin());

CREATE TABLE IF NOT EXISTS public.messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  sender_role text NOT NULL CHECK (sender_role IN ('student', 'admin')),
  body text NOT NULL,
  read_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS msg_conv_idx
  ON public.messages(conversation_id, created_at);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Un participant de la conversation peut lire les messages
DROP POLICY IF EXISTS msg_read ON public.messages;
CREATE POLICY msg_read ON public.messages
  FOR SELECT USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.conversations c
       WHERE c.id = conversation_id AND c.user_id = auth.uid()
    )
  );

-- Insertion/update via RPC uniquement

-- ------------------------------------------------------------
-- 5. RPC : envoyer un message + notifier le destinataire
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.send_message(
  p_conversation_id uuid,
  p_body text
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_role text;
  v_conv record;
  v_msg_id uuid;
  v_sender_name text;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Non authentifié'; END IF;
  IF length(trim(p_body)) = 0 THEN RAISE EXCEPTION 'Message vide'; END IF;
  IF length(p_body) > 5000 THEN RAISE EXCEPTION 'Message trop long'; END IF;

  SELECT role INTO v_role FROM public.profiles WHERE id = v_uid;
  IF v_role IS NULL THEN RAISE EXCEPTION 'Profil introuvable'; END IF;

  SELECT * INTO v_conv FROM public.conversations WHERE id = p_conversation_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Conversation introuvable'; END IF;

  -- Stagiaire ne peut écrire que dans sa propre conversation
  IF v_role = 'student' AND v_conv.user_id <> v_uid THEN
    RAISE EXCEPTION 'Accès refusé';
  END IF;

  INSERT INTO public.messages (conversation_id, sender_id, sender_role, body)
  VALUES (p_conversation_id, v_uid, v_role, trim(p_body))
  RETURNING id INTO v_msg_id;

  -- Compteurs + notification au destinataire
  IF v_role = 'student' THEN
    UPDATE public.conversations
       SET last_message_at = now(),
           admin_unread = admin_unread + 1
     WHERE id = p_conversation_id;
    -- Pas de notification par admin individuel (beaucoup d'admins possibles)
  ELSE
    SELECT full_name INTO v_sender_name FROM public.profiles WHERE id = v_uid;
    UPDATE public.conversations
       SET last_message_at = now(),
           user_unread = user_unread + 1
     WHERE id = p_conversation_id;
    -- Notifie le stagiaire
    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    VALUES (
      v_conv.user_id,
      'message',
      'Nouveau message' || coalesce(' de ' || v_sender_name, ''),
      left(p_body, 200),
      '/messages'
    );
  END IF;

  RETURN v_msg_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.send_message(uuid, text) TO authenticated;

-- ------------------------------------------------------------
-- 6. RPC : créer ou récupérer la conversation du stagiaire
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_or_create_my_conversation()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_id uuid;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Non authentifié'; END IF;
  SELECT id INTO v_id FROM public.conversations WHERE user_id = v_uid;
  IF v_id IS NOT NULL THEN RETURN v_id; END IF;
  INSERT INTO public.conversations (user_id) VALUES (v_uid) RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_or_create_my_conversation() TO authenticated;

-- ------------------------------------------------------------
-- 7. RPC : marquer messages lus par le destinataire
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.mark_conversation_read(p_conversation_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_role text;
  v_conv record;
BEGIN
  IF v_uid IS NULL THEN RETURN; END IF;
  SELECT role INTO v_role FROM public.profiles WHERE id = v_uid;
  SELECT * INTO v_conv FROM public.conversations WHERE id = p_conversation_id;
  IF NOT FOUND THEN RETURN; END IF;

  IF v_role = 'student' AND v_conv.user_id = v_uid THEN
    UPDATE public.messages SET read_at = now()
     WHERE conversation_id = p_conversation_id
       AND sender_role = 'admin'
       AND read_at IS NULL;
    UPDATE public.conversations SET user_unread = 0 WHERE id = p_conversation_id;
  ELSIF v_role = 'admin' THEN
    UPDATE public.messages SET read_at = now()
     WHERE conversation_id = p_conversation_id
       AND sender_role = 'student'
       AND read_at IS NULL;
    UPDATE public.conversations SET admin_unread = 0 WHERE id = p_conversation_id;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.mark_conversation_read(uuid) TO authenticated;

-- ------------------------------------------------------------
-- 8. RPC : marquer notifications lues
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.mark_notifications_read(p_ids uuid[] DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_count int;
BEGIN
  IF v_uid IS NULL THEN RETURN 0; END IF;
  IF p_ids IS NULL THEN
    UPDATE public.notifications SET read_at = now()
     WHERE user_id = v_uid AND read_at IS NULL;
  ELSE
    UPDATE public.notifications SET read_at = now()
     WHERE user_id = v_uid AND read_at IS NULL AND id = ANY(p_ids);
  END IF;
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

GRANT EXECUTE ON FUNCTION public.mark_notifications_read(uuid[]) TO authenticated;
