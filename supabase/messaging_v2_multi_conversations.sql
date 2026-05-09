-- ============================================================
-- INFRA - Messagerie v2 multi-conversations
-- ============================================================
-- Refonte complète du modèle de messagerie :
--   AVANT : 1 stagiaire = 1 conversation unique (UNIQUE user_id)
--           → impossible de choisir le destinataire, tout admin/formateur
--           voit la même boîte commune.
--   APRÈS : 1 user = N conversations (DM ou groupes), avec participants
--           explicites. Le destinataire est choisi à la création.
--
-- Concepts :
--   - kind = 'dm' | 'group'
--   - scope (groupes uniquement) : 'admin_team' | 'class' | 'custom'
--   - conversation_participants : qui peut lire/écrire
--   - class_writable : pour les classes en mode annonce vs chat libre
--
-- Migration des données existantes :
--   Chaque conversation existante (modèle 1-stagiaire) devient une
--   conversation 'group' avec scope='admin_team' et participants =
--   le stagiaire + tous les admins actuels.
--
-- Pré-requis : messaging.sql + messaging_trainer.sql doivent avoir
-- été chargés (création initiale des tables).
--
-- Idempotent : ré-exécutable sans danger.
-- ============================================================

-- ------------------------------------------------------------
-- 1) Extensions de la table `conversations`
-- ------------------------------------------------------------
ALTER TABLE public.conversations
  ADD COLUMN IF NOT EXISTS kind text,
  ADD COLUMN IF NOT EXISTS scope text,
  ADD COLUMN IF NOT EXISTS group_id uuid,
  ADD COLUMN IF NOT EXISTS title text,
  ADD COLUMN IF NOT EXISTS created_by uuid,
  ADD COLUMN IF NOT EXISTS archived_at timestamptz,
  ADD COLUMN IF NOT EXISTS class_writable boolean NOT NULL DEFAULT false;

-- FK group_id (si pas déjà posée)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
     WHERE constraint_name = 'conversations_group_id_fkey'
  ) THEN
    ALTER TABLE public.conversations
      ADD CONSTRAINT conversations_group_id_fkey
      FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE SET NULL;
  END IF;
END $$;

-- FK created_by
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
     WHERE constraint_name = 'conversations_created_by_fkey'
  ) THEN
    ALTER TABLE public.conversations
      ADD CONSTRAINT conversations_created_by_fkey
      FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Valeurs par défaut sur les anciennes conversations
UPDATE public.conversations
   SET kind = 'group',
       scope = 'admin_team'
 WHERE kind IS NULL;

-- Maintenant on peut poser les contraintes
ALTER TABLE public.conversations
  ALTER COLUMN kind SET NOT NULL,
  ALTER COLUMN kind SET DEFAULT 'dm';

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'conversations_kind_check') THEN
    ALTER TABLE public.conversations
      ADD CONSTRAINT conversations_kind_check CHECK (kind IN ('dm', 'group'));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'conversations_scope_check') THEN
    ALTER TABLE public.conversations
      ADD CONSTRAINT conversations_scope_check
      CHECK (scope IS NULL OR scope IN ('admin_team', 'class', 'custom'));
  END IF;
END $$;

-- Suppression de la contrainte UNIQUE(user_id) qui empêche les conversations multiples
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
     WHERE conname = 'conversations_user_id_key'
        OR conname = 'conversations_user_id_unique'
  ) THEN
    EXECUTE 'ALTER TABLE public.conversations DROP CONSTRAINT IF EXISTS conversations_user_id_key';
    EXECUTE 'ALTER TABLE public.conversations DROP CONSTRAINT IF EXISTS conversations_user_id_unique';
  END IF;
END $$;

-- La colonne user_id (du modèle v1) reste pour rétro-compat mais devient nullable :
-- les nouvelles conversations DM/groupe n'en ont pas besoin.
ALTER TABLE public.conversations ALTER COLUMN user_id DROP NOT NULL;

-- ------------------------------------------------------------
-- 2) Table `conversation_participants`
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.conversation_participants (
  conversation_id uuid NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role_in_conv text NOT NULL DEFAULT 'member' CHECK (role_in_conv IN ('member', 'admin', 'owner')),
  joined_at timestamptz NOT NULL DEFAULT now(),
  last_read_at timestamptz,
  pinned_at timestamptz,
  muted boolean NOT NULL DEFAULT false,
  archived_at timestamptz,
  PRIMARY KEY (conversation_id, user_id)
);

CREATE INDEX IF NOT EXISTS conv_part_user_idx
  ON public.conversation_participants(user_id, conversation_id);
CREATE INDEX IF NOT EXISTS conv_part_pinned_idx
  ON public.conversation_participants(user_id, pinned_at DESC) WHERE pinned_at IS NOT NULL;

ALTER TABLE public.conversation_participants ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------
-- 3) Migration des données existantes
--    Pour chaque conversation legacy (avec user_id non null), on crée
--    les participants : le stagiaire + tous les admins actuels.
-- ------------------------------------------------------------
DO $migrate$
DECLARE
  v_conv record;
BEGIN
  FOR v_conv IN
    SELECT c.id, c.user_id
      FROM public.conversations c
     WHERE c.user_id IS NOT NULL
       AND c.scope = 'admin_team'
  LOOP
    -- Insère le stagiaire propriétaire de la conv
    INSERT INTO public.conversation_participants (conversation_id, user_id, role_in_conv)
    VALUES (v_conv.id, v_conv.user_id, 'owner')
    ON CONFLICT (conversation_id, user_id) DO NOTHING;

    -- Insère tous les admins/super_admin actuels
    INSERT INTO public.conversation_participants (conversation_id, user_id, role_in_conv)
    SELECT v_conv.id, p.id, 'member'
      FROM public.profiles p
     WHERE p.role IN ('admin', 'super_admin')
    ON CONFLICT (conversation_id, user_id) DO NOTHING;
  END LOOP;
END;
$migrate$;

-- ------------------------------------------------------------
-- 4) Extension table `messages`
-- ------------------------------------------------------------
ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS reply_to_id uuid,
  ADD COLUMN IF NOT EXISTS edited_at timestamptz,
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
     WHERE constraint_name = 'messages_reply_to_fkey'
  ) THEN
    ALTER TABLE public.messages
      ADD CONSTRAINT messages_reply_to_fkey
      FOREIGN KEY (reply_to_id) REFERENCES public.messages(id) ON DELETE SET NULL;
  END IF;
END $$;

-- ------------------------------------------------------------
-- 5) RLS sur `conversation_participants`
-- ------------------------------------------------------------
DROP POLICY IF EXISTS conv_part_self_read ON public.conversation_participants;
CREATE POLICY conv_part_self_read ON public.conversation_participants
  FOR SELECT USING (
    user_id = auth.uid()
    OR public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.conversation_participants me
       WHERE me.conversation_id = conversation_participants.conversation_id
         AND me.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS conv_part_self_update ON public.conversation_participants;
CREATE POLICY conv_part_self_update ON public.conversation_participants
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- INSERT/DELETE uniquement via RPC SECURITY DEFINER

-- ------------------------------------------------------------
-- 6) RLS revue sur `conversations`
--    Lecture : participant OR admin
-- ------------------------------------------------------------
DROP POLICY IF EXISTS conv_read ON public.conversations;
CREATE POLICY conv_read ON public.conversations
  FOR SELECT USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.conversation_participants cp
       WHERE cp.conversation_id = conversations.id
         AND cp.user_id = auth.uid()
    )
  );

-- ------------------------------------------------------------
-- 7) RLS revue sur `messages`
--    Lecture : participant de la conv OR admin
-- ------------------------------------------------------------
DROP POLICY IF EXISTS msg_read ON public.messages;
CREATE POLICY msg_read ON public.messages
  FOR SELECT USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.conversation_participants cp
       WHERE cp.conversation_id = messages.conversation_id
         AND cp.user_id = auth.uid()
    )
  );

-- Update de ses propres messages (édition / soft delete)
DROP POLICY IF EXISTS msg_self_update ON public.messages;
CREATE POLICY msg_self_update ON public.messages
  FOR UPDATE USING (sender_id = auth.uid())
  WITH CHECK (sender_id = auth.uid());

-- ------------------------------------------------------------
-- 8) RPC : send_message v2
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.send_message(
  p_conversation_id uuid,
  p_body text,
  p_reply_to uuid DEFAULT NULL
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
  v_clean text;
  v_sender_name text;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Non authentifié'; END IF;
  v_clean := trim(p_body);
  IF length(v_clean) = 0 THEN RAISE EXCEPTION 'Message vide'; END IF;
  IF length(v_clean) > 5000 THEN RAISE EXCEPTION 'Message trop long (max 5000)'; END IF;

  -- Vérifie que l'utilisateur est participant
  IF NOT EXISTS (
    SELECT 1 FROM public.conversation_participants
     WHERE conversation_id = p_conversation_id AND user_id = v_uid
  ) THEN
    RAISE EXCEPTION 'Vous n''êtes pas participant de cette conversation';
  END IF;

  SELECT * INTO v_conv FROM public.conversations WHERE id = p_conversation_id;

  -- Si conversation 'class' en mode annonce : seuls trainer/admin peuvent écrire
  IF v_conv.kind = 'group' AND v_conv.scope = 'class' AND NOT v_conv.class_writable THEN
    SELECT role INTO v_role FROM public.profiles WHERE id = v_uid;
    IF v_role = 'student' THEN
      RAISE EXCEPTION 'Cette classe est en mode annonce (lecture seule)';
    END IF;
  END IF;

  -- Récupère le rôle global (pour sender_role legacy)
  IF v_role IS NULL THEN
    SELECT role INTO v_role FROM public.profiles WHERE id = v_uid;
  END IF;

  -- Insertion du message
  INSERT INTO public.messages (conversation_id, sender_id, sender_role, body, reply_to_id)
  VALUES (
    p_conversation_id,
    v_uid,
    CASE
      WHEN v_role = 'student' THEN 'student'
      WHEN v_role = 'trainer' THEN 'trainer'
      ELSE 'admin'
    END,
    v_clean,
    p_reply_to
  )
  RETURNING id INTO v_msg_id;

  -- Met à jour la conversation
  UPDATE public.conversations
     SET last_message_at = now()
   WHERE id = p_conversation_id;

  -- Notifie tous les autres participants non mutés
  SELECT full_name INTO v_sender_name FROM public.profiles WHERE id = v_uid;

  INSERT INTO public.notifications (user_id, type, title, body, link_url)
  SELECT
    cp.user_id,
    'message',
    CASE
      WHEN v_conv.kind = 'dm' THEN
        'Nouveau message' || coalesce(' de ' || v_sender_name, '')
      WHEN v_conv.scope = 'class' THEN
        coalesce(v_conv.title, 'Nouvelle annonce de classe')
      ELSE
        coalesce(v_conv.title, 'Nouveau message') ||
        coalesce(' — ' || v_sender_name, '')
    END,
    left(v_clean, 200),
    '/messages?c=' || p_conversation_id::text
  FROM public.conversation_participants cp
  WHERE cp.conversation_id = p_conversation_id
    AND cp.user_id <> v_uid
    AND NOT cp.muted;

  RETURN v_msg_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.send_message(uuid, text, uuid) TO authenticated;

-- ------------------------------------------------------------
-- 9) RPC : mark_conversation_read (v2 — basé sur participants)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.mark_conversation_read(p_conversation_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
BEGIN
  IF v_uid IS NULL THEN RETURN; END IF;
  UPDATE public.conversation_participants
     SET last_read_at = now()
   WHERE conversation_id = p_conversation_id
     AND user_id = v_uid;
END;
$$;

GRANT EXECUTE ON FUNCTION public.mark_conversation_read(uuid) TO authenticated;

-- ------------------------------------------------------------
-- 10) RPC : create_or_get_dm
--     Crée (ou retourne) un DM 1-1 entre auth.uid() et p_target.
--     Vérifie la matrice de communication selon les rôles.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.create_or_get_dm(p_target_user_id uuid)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_my_role text;
  v_target_role text;
  v_existing uuid;
  v_new_id uuid;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Non authentifié'; END IF;
  IF v_uid = p_target_user_id THEN RAISE EXCEPTION 'Auto-DM impossible'; END IF;

  SELECT role INTO v_my_role FROM public.profiles WHERE id = v_uid;
  SELECT role INTO v_target_role FROM public.profiles WHERE id = p_target_user_id;
  IF v_target_role IS NULL THEN RAISE EXCEPTION 'Destinataire introuvable'; END IF;

  -- Matrice de communication
  --   student → trainer : OK si trainer suit le stagiaire
  --   student → admin/super_admin : OK
  --   student → student : INTERDIT
  --   trainer → student : OK si trainer suit le stagiaire
  --   trainer → admin/super_admin : OK
  --   trainer → trainer : OK
  --   admin/super_admin → quiconque : OK
  IF v_my_role = 'student' AND v_target_role = 'student' THEN
    RAISE EXCEPTION 'Les stagiaires ne peuvent pas se contacter directement';
  END IF;

  IF v_my_role = 'student' AND v_target_role = 'trainer' THEN
    IF NOT public.trainer_shares_formation_with(p_target_user_id, v_uid) THEN
      RAISE EXCEPTION 'Ce formateur ne suit pas vos formations';
    END IF;
  END IF;

  IF v_my_role = 'trainer' AND v_target_role = 'student' THEN
    IF NOT public.trainer_shares_formation_with(v_uid, p_target_user_id) THEN
      RAISE EXCEPTION 'Vous ne suivez pas ce stagiaire';
    END IF;
  END IF;

  -- DM existant ?
  SELECT c.id INTO v_existing
    FROM public.conversations c
   WHERE c.kind = 'dm'
     AND EXISTS (SELECT 1 FROM public.conversation_participants WHERE conversation_id = c.id AND user_id = v_uid)
     AND EXISTS (SELECT 1 FROM public.conversation_participants WHERE conversation_id = c.id AND user_id = p_target_user_id)
     AND (SELECT count(*) FROM public.conversation_participants WHERE conversation_id = c.id) = 2
   LIMIT 1;

  IF v_existing IS NOT NULL THEN RETURN v_existing; END IF;

  -- Création
  INSERT INTO public.conversations (kind, created_by)
  VALUES ('dm', v_uid)
  RETURNING id INTO v_new_id;

  INSERT INTO public.conversation_participants (conversation_id, user_id, role_in_conv)
  VALUES
    (v_new_id, v_uid, 'owner'),
    (v_new_id, p_target_user_id, 'member');

  RETURN v_new_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_or_get_dm(uuid) TO authenticated;

-- ------------------------------------------------------------
-- 11) RPC : create_admin_team_conversation
--     Crée (ou retourne) la conv "Équipe admin" pour le stagiaire.
--     C'est en réalité une conv 'group' scope='admin_team'.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.create_or_get_admin_team_conv()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_role text;
  v_existing uuid;
  v_new_id uuid;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Non authentifié'; END IF;
  SELECT role INTO v_role FROM public.profiles WHERE id = v_uid;

  -- Conv existante ?
  SELECT c.id INTO v_existing
    FROM public.conversations c
    JOIN public.conversation_participants cp ON cp.conversation_id = c.id
   WHERE c.kind = 'group'
     AND c.scope = 'admin_team'
     AND cp.user_id = v_uid
   LIMIT 1;

  IF v_existing IS NOT NULL THEN
    -- S'assure que TOUS les admins actuels sont participants (synchro auto)
    INSERT INTO public.conversation_participants (conversation_id, user_id, role_in_conv)
    SELECT v_existing, p.id, 'member'
      FROM public.profiles p
     WHERE p.role IN ('admin', 'super_admin')
    ON CONFLICT (conversation_id, user_id) DO NOTHING;
    RETURN v_existing;
  END IF;

  -- Création (si user = stagiaire ou trainer ; les admins passent par DM individuels)
  INSERT INTO public.conversations (kind, scope, title, created_by)
  VALUES ('group', 'admin_team', 'Équipe admin', v_uid)
  RETURNING id INTO v_new_id;

  -- Participants : moi + tous les admins
  INSERT INTO public.conversation_participants (conversation_id, user_id, role_in_conv)
  VALUES (v_new_id, v_uid, 'owner');

  INSERT INTO public.conversation_participants (conversation_id, user_id, role_in_conv)
  SELECT v_new_id, p.id, 'member'
    FROM public.profiles p
   WHERE p.role IN ('admin', 'super_admin')
     AND p.id <> v_uid
  ON CONFLICT (conversation_id, user_id) DO NOTHING;

  RETURN v_new_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_or_get_admin_team_conv() TO authenticated;

-- ------------------------------------------------------------
-- 12) RPC : create_or_get_class_conv (formateur/admin uniquement)
--     Conv de classe : tous les stagiaires inscrits aux formations
--     que le groupe représente, + tous les formateurs concernés,
--     + tous les admins.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.create_or_get_class_conv(
  p_group_id uuid,
  p_writable boolean DEFAULT false
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_role text;
  v_existing uuid;
  v_new_id uuid;
  v_group_name text;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Non authentifié'; END IF;
  SELECT role INTO v_role FROM public.profiles WHERE id = v_uid;

  IF v_role NOT IN ('admin', 'super_admin', 'trainer') THEN
    RAISE EXCEPTION 'Réservé aux formateurs et admins';
  END IF;

  SELECT name INTO v_group_name FROM public.groups WHERE id = p_group_id;
  IF v_group_name IS NULL THEN RAISE EXCEPTION 'Classe introuvable'; END IF;

  SELECT id INTO v_existing
    FROM public.conversations
   WHERE kind = 'group' AND scope = 'class' AND group_id = p_group_id
   LIMIT 1;

  IF v_existing IS NOT NULL THEN
    -- Synchronise les participants (stagiaires du groupe + admins + trainers)
    INSERT INTO public.conversation_participants (conversation_id, user_id, role_in_conv)
    SELECT v_existing, p.id,
           CASE WHEN p.role IN ('admin','super_admin','trainer') THEN 'admin' ELSE 'member' END
      FROM public.profiles p
     WHERE p.group_id = p_group_id
        OR p.role IN ('admin','super_admin')
    ON CONFLICT (conversation_id, user_id) DO NOTHING;
    RETURN v_existing;
  END IF;

  INSERT INTO public.conversations (kind, scope, group_id, title, created_by, class_writable)
  VALUES ('group', 'class', p_group_id, v_group_name, v_uid, p_writable)
  RETURNING id INTO v_new_id;

  -- Participants : tous les stagiaires du groupe + admins + le créateur
  INSERT INTO public.conversation_participants (conversation_id, user_id, role_in_conv)
  SELECT v_new_id, p.id,
         CASE WHEN p.role IN ('admin','super_admin','trainer') THEN 'admin' ELSE 'member' END
    FROM public.profiles p
   WHERE p.group_id = p_group_id
      OR p.role IN ('admin','super_admin')
  ON CONFLICT (conversation_id, user_id) DO NOTHING;

  -- S'assure que le créateur est dedans (cas trainer non rattaché au groupe)
  INSERT INTO public.conversation_participants (conversation_id, user_id, role_in_conv)
  VALUES (v_new_id, v_uid, 'owner')
  ON CONFLICT (conversation_id, user_id) DO UPDATE SET role_in_conv = 'owner';

  RETURN v_new_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_or_get_class_conv(uuid, boolean) TO authenticated;

-- ------------------------------------------------------------
-- 13) RPC : list_my_conversations
--     Renvoie les conversations visibles avec metadata utiles UI.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.list_my_conversations()
RETURNS TABLE (
  id uuid,
  kind text,
  scope text,
  title text,
  group_id uuid,
  class_writable boolean,
  archived_at timestamptz,
  pinned_at timestamptz,
  muted boolean,
  last_read_at timestamptz,
  last_message_at timestamptz,
  last_message_preview text,
  last_message_sender_id uuid,
  unread_count int,
  participants_count int,
  other_participant_id uuid,
  other_participant_name text,
  other_participant_role text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  WITH my_convs AS (
    SELECT c.*, cp.pinned_at, cp.muted, cp.last_read_at, cp.archived_at AS my_archived_at
      FROM public.conversations c
      JOIN public.conversation_participants cp
        ON cp.conversation_id = c.id
     WHERE cp.user_id = auth.uid()
  ),
  enriched AS (
    SELECT
      mc.*,
      (
        SELECT count(*)::int FROM public.conversation_participants
         WHERE conversation_id = mc.id
      ) AS p_count,
      (
        SELECT m.body FROM public.messages m
         WHERE m.conversation_id = mc.id
           AND m.deleted_at IS NULL
         ORDER BY m.created_at DESC LIMIT 1
      ) AS last_msg_body,
      (
        SELECT m.sender_id FROM public.messages m
         WHERE m.conversation_id = mc.id
           AND m.deleted_at IS NULL
         ORDER BY m.created_at DESC LIMIT 1
      ) AS last_msg_sender,
      (
        SELECT count(*)::int FROM public.messages m
         WHERE m.conversation_id = mc.id
           AND m.deleted_at IS NULL
           AND m.created_at > coalesce(mc.last_read_at, '1970-01-01'::timestamptz)
           AND m.sender_id <> auth.uid()
      ) AS unread,
      (
        SELECT cp2.user_id
          FROM public.conversation_participants cp2
         WHERE cp2.conversation_id = mc.id
           AND cp2.user_id <> auth.uid()
         LIMIT 1
      ) AS other_id
    FROM my_convs mc
  )
  SELECT
    e.id,
    e.kind,
    e.scope,
    COALESCE(
      e.title,
      CASE WHEN e.kind = 'dm' THEN
        (SELECT p.full_name FROM public.profiles p WHERE p.id = e.other_id)
      END
    ) AS title,
    e.group_id,
    e.class_writable,
    e.my_archived_at,
    e.pinned_at,
    e.muted,
    e.last_read_at,
    e.last_message_at,
    left(e.last_msg_body, 200),
    e.last_msg_sender,
    e.unread,
    e.p_count,
    e.other_id,
    (SELECT p.full_name FROM public.profiles p WHERE p.id = e.other_id),
    (SELECT p.role FROM public.profiles p WHERE p.id = e.other_id)
  FROM enriched e
  ORDER BY
    e.pinned_at DESC NULLS LAST,
    e.last_message_at DESC;
$$;

GRANT EXECUTE ON FUNCTION public.list_my_conversations() TO authenticated;

-- ------------------------------------------------------------
-- 14) RPC : list_recipients
--     Renvoie la liste des destinataires possibles selon le rôle :
--     - Stagiaire : ses formateurs + entrée 'admin_team' virtuelle
--     - Formateur : ses stagiaires + ses classes + autres formateurs
--                   + admins + 'admin_team'
--     - Admin : tous les users + toutes les classes + 'admin_team'
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.list_recipients()
RETURNS TABLE (
  kind text,             -- 'user' | 'class' | 'admin_team'
  user_id uuid,          -- pour kind='user'
  group_id uuid,         -- pour kind='class'
  display_name text,
  user_role text,        -- pour kind='user'
  subtitle text          -- info secondaire (ex: nom du formateur, nom de la formation)
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_role text;
BEGIN
  IF v_uid IS NULL THEN RETURN; END IF;
  SELECT role INTO v_role FROM public.profiles WHERE id = v_uid;

  -- Toujours en premier : "Équipe admin"
  RETURN QUERY
    SELECT 'admin_team'::text, NULL::uuid, NULL::uuid,
           'Équipe admin'::text, NULL::text,
           'Tous les administrateurs'::text;

  IF v_role = 'student' THEN
    -- Formateurs qui suivent le stagiaire
    RETURN QUERY
      SELECT DISTINCT 'user'::text, p.id, NULL::uuid,
             coalesce(p.full_name, p.email)::text, p.role::text,
             'Formateur'::text
        FROM public.profiles p
        JOIN public.trainer_formations tf ON tf.trainer_id = p.id
        JOIN public.enrollments e
          ON (e.formation_id = tf.formation_id
              OR e.formation_slug = (SELECT slug FROM public.formations WHERE id = tf.formation_id))
       WHERE p.role = 'trainer'
         AND e.user_id = v_uid
       ORDER BY 4;
    RETURN;
  END IF;

  IF v_role = 'trainer' THEN
    -- Stagiaires que le formateur suit
    RETURN QUERY
      SELECT DISTINCT 'user'::text, p.id, NULL::uuid,
             coalesce(p.full_name, p.email)::text, p.role::text,
             'Stagiaire'::text
        FROM public.profiles p
        JOIN public.enrollments e ON e.user_id = p.id
        JOIN public.trainer_formations tf ON tf.trainer_id = v_uid
       WHERE p.role = 'student'
         AND (e.formation_id = tf.formation_id
              OR e.formation_slug = (SELECT slug FROM public.formations WHERE id = tf.formation_id))
       ORDER BY 4;

    -- Classes du formateur (groupes des stagiaires qu'il suit)
    RETURN QUERY
      SELECT DISTINCT 'class'::text, NULL::uuid, g.id,
             g.name::text, NULL::text,
             coalesce(g.academic_year, 'Classe')::text
        FROM public.groups g
       WHERE EXISTS (
         SELECT 1 FROM public.profiles p
         JOIN public.enrollments e ON e.user_id = p.id
         JOIN public.trainer_formations tf ON tf.trainer_id = v_uid
          WHERE p.group_id = g.id
            AND p.role = 'student'
            AND (e.formation_id = tf.formation_id
                 OR e.formation_slug = (SELECT slug FROM public.formations WHERE id = tf.formation_id))
       )
       ORDER BY 4;

    -- Autres formateurs
    RETURN QUERY
      SELECT 'user'::text, p.id, NULL::uuid,
             coalesce(p.full_name, p.email)::text, p.role::text,
             'Formateur'::text
        FROM public.profiles p
       WHERE p.role = 'trainer'
         AND p.id <> v_uid
       ORDER BY 4;

    -- Admins
    RETURN QUERY
      SELECT 'user'::text, p.id, NULL::uuid,
             coalesce(p.full_name, p.email)::text, p.role::text,
             'Admin'::text
        FROM public.profiles p
       WHERE p.role IN ('admin', 'super_admin')
       ORDER BY 4;
    RETURN;
  END IF;

  -- Admin / super_admin : tout
  IF v_role IN ('admin', 'super_admin') THEN
    RETURN QUERY
      SELECT 'user'::text, p.id, NULL::uuid,
             coalesce(p.full_name, p.email)::text, p.role::text,
             CASE p.role
               WHEN 'student' THEN 'Stagiaire'
               WHEN 'trainer' THEN 'Formateur'
               ELSE 'Admin'
             END::text
        FROM public.profiles p
       WHERE p.id <> v_uid
       ORDER BY 4;

    RETURN QUERY
      SELECT 'class'::text, NULL::uuid, g.id,
             g.name::text, NULL::text,
             coalesce(g.academic_year, 'Classe')::text
        FROM public.groups g
       ORDER BY 4;
    RETURN;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.list_recipients() TO authenticated;

-- ------------------------------------------------------------
-- 15) RPC : pin / archive / mute
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_conversation_pinned(
  p_conversation_id uuid,
  p_pinned boolean
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN RETURN; END IF;
  UPDATE public.conversation_participants
     SET pinned_at = CASE WHEN p_pinned THEN now() ELSE NULL END
   WHERE conversation_id = p_conversation_id
     AND user_id = auth.uid();
END;
$$;
GRANT EXECUTE ON FUNCTION public.set_conversation_pinned(uuid, boolean) TO authenticated;

CREATE OR REPLACE FUNCTION public.set_conversation_archived(
  p_conversation_id uuid,
  p_archived boolean
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN RETURN; END IF;
  UPDATE public.conversation_participants
     SET archived_at = CASE WHEN p_archived THEN now() ELSE NULL END
   WHERE conversation_id = p_conversation_id
     AND user_id = auth.uid();
END;
$$;
GRANT EXECUTE ON FUNCTION public.set_conversation_archived(uuid, boolean) TO authenticated;

CREATE OR REPLACE FUNCTION public.set_conversation_muted(
  p_conversation_id uuid,
  p_muted boolean
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN RETURN; END IF;
  UPDATE public.conversation_participants
     SET muted = p_muted
   WHERE conversation_id = p_conversation_id
     AND user_id = auth.uid();
END;
$$;
GRANT EXECUTE ON FUNCTION public.set_conversation_muted(uuid, boolean) TO authenticated;

-- ------------------------------------------------------------
-- 16) Realtime : ajouter la table participants à la publication
-- ------------------------------------------------------------
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    BEGIN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.conversation_participants;
    EXCEPTION
      WHEN duplicate_object THEN NULL;
    END;
    BEGIN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;
    EXCEPTION
      WHEN duplicate_object THEN NULL;
    END;
    BEGIN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
    EXCEPTION
      WHEN duplicate_object THEN NULL;
    END;
  END IF;
END $$;

ALTER TABLE public.conversation_participants REPLICA IDENTITY FULL;
ALTER TABLE public.conversations REPLICA IDENTITY FULL;
ALTER TABLE public.messages REPLICA IDENTITY FULL;

-- ------------------------------------------------------------
-- 17) Vérification finale
-- ------------------------------------------------------------
DO $$
DECLARE
  v_conv_count int;
  v_part_count int;
  v_orphan_count int;
BEGIN
  SELECT count(*) INTO v_conv_count FROM public.conversations;
  SELECT count(*) INTO v_part_count FROM public.conversation_participants;
  SELECT count(*) INTO v_orphan_count
    FROM public.conversations c
   WHERE NOT EXISTS (
     SELECT 1 FROM public.conversation_participants cp
      WHERE cp.conversation_id = c.id
   );

  RAISE NOTICE '╔════════════════════════════════════════════════════';
  RAISE NOTICE '║ ✓ Messagerie v2 multi-conversations déployée';
  RAISE NOTICE '╠════════════════════════════════════════════════════';
  RAISE NOTICE '║ Tables modifiées : conversations, messages';
  RAISE NOTICE '║ Table créée      : conversation_participants';
  RAISE NOTICE '║ RPC              : send_message v2, mark_conversation_read v2,';
  RAISE NOTICE '║                    create_or_get_dm, create_or_get_admin_team_conv,';
  RAISE NOTICE '║                    create_or_get_class_conv, list_my_conversations,';
  RAISE NOTICE '║                    list_recipients, set_conversation_(pinned|archived|muted)';
  RAISE NOTICE '╠════════════════════════════════════════════════════';
  RAISE NOTICE '║ Stats migration :';
  RAISE NOTICE '║   Conversations : %', v_conv_count;
  RAISE NOTICE '║   Participants  : %', v_part_count;
  RAISE NOTICE '║   Orphelines    : %', v_orphan_count;
  RAISE NOTICE '╚════════════════════════════════════════════════════';

  IF v_orphan_count > 0 THEN
    RAISE WARNING 'Il reste % conversations sans participant — à investiguer', v_orphan_count;
  END IF;
END $$;
