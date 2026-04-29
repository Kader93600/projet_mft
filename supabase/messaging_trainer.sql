-- =====================================================================
-- Messagerie : extension formateur ↔ stagiaire
--
-- Évolutions :
--   - sender_role accepte désormais 'trainer' (en plus de 'student'/'admin')
--   - RLS conversations + messages : un formateur voit les conversations
--     des stagiaires inscrits sur l'une des formations qu'il anime
--   - send_message : accepte le rôle trainer après vérification que le
--     formateur est bien rattaché à au moins une formation du stagiaire
--   - mark_conversation_read : gère le rôle trainer
--   - Notifications : quand un stagiaire écrit, on notifie aussi les
--     formateurs rattachés à au moins une de ses formations
--
-- Idempotent — peut être rejoué plusieurs fois sans casse.
-- =====================================================================

-- 1) Mise à jour du CHECK sender_role
ALTER TABLE public.messages DROP CONSTRAINT IF EXISTS messages_sender_role_check;
ALTER TABLE public.messages
  ADD CONSTRAINT messages_sender_role_check
  CHECK (sender_role IN ('student', 'admin', 'trainer'));

-- 2) Helper : un formateur partage-t-il une formation avec un stagiaire ?
CREATE OR REPLACE FUNCTION public.trainer_shares_formation_with(
  p_trainer uuid,
  p_student uuid
) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $fn$
  SELECT EXISTS (
    SELECT 1
    FROM public.trainer_formations tf
    JOIN public.enrollments e
      ON e.formation_id = tf.formation_id
      OR e.formation_slug = (SELECT slug FROM public.formations WHERE id = tf.formation_id)
    WHERE tf.trainer_id = p_trainer
      AND e.user_id = p_student
  );
$fn$;

GRANT EXECUTE ON FUNCTION public.trainer_shares_formation_with(uuid, uuid) TO authenticated;

-- 3) RLS : conversations accessibles aux formateurs concernés
DROP POLICY IF EXISTS conv_read ON public.conversations;
CREATE POLICY conv_read ON public.conversations
  FOR SELECT USING (
    user_id = auth.uid()
    OR public.is_admin()
    OR (
      public.is_trainer()
      AND public.trainer_shares_formation_with(auth.uid(), user_id)
    )
  );

-- 4) RLS messages : idem
DROP POLICY IF EXISTS msg_read ON public.messages;
CREATE POLICY msg_read ON public.messages
  FOR SELECT USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.conversations c
       WHERE c.id = conversation_id AND c.user_id = auth.uid()
    )
    OR (
      public.is_trainer()
      AND EXISTS (
        SELECT 1 FROM public.conversations c
         WHERE c.id = conversation_id
           AND public.trainer_shares_formation_with(auth.uid(), c.user_id)
      )
    )
  );

-- 5) send_message : accepte trainer + notifications enrichies
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

  -- Stagiaire : seulement sa conversation
  IF v_role = 'student' AND v_conv.user_id <> v_uid THEN
    RAISE EXCEPTION 'Accès refusé';
  END IF;

  -- Formateur : doit être rattaché à au moins une formation du stagiaire
  IF v_role = 'trainer'
     AND NOT public.trainer_shares_formation_with(v_uid, v_conv.user_id) THEN
    RAISE EXCEPTION 'Vous ne suivez pas ce stagiaire';
  END IF;

  -- sender_role normalisé : student | trainer | admin
  INSERT INTO public.messages (conversation_id, sender_id, sender_role, body)
  VALUES (
    p_conversation_id,
    v_uid,
    CASE
      WHEN v_role = 'student' THEN 'student'
      WHEN v_role = 'trainer' THEN 'trainer'
      ELSE 'admin'
    END,
    trim(p_body)
  )
  RETURNING id INTO v_msg_id;

  IF v_role = 'student' THEN
    UPDATE public.conversations
       SET last_message_at = now(),
           admin_unread = admin_unread + 1
     WHERE id = p_conversation_id;

    -- Notifie les formateurs rattachés à une des formations du stagiaire
    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    SELECT DISTINCT tf.trainer_id, 'message',
           'Nouveau message d''un stagiaire',
           left(p_body, 200),
           '/formateur/messages/' || p_conversation_id
    FROM public.trainer_formations tf
    JOIN public.enrollments e
      ON (e.formation_id = tf.formation_id
          OR e.formation_slug = (SELECT slug FROM public.formations WHERE id = tf.formation_id))
    WHERE e.user_id = v_conv.user_id;
  ELSE
    SELECT full_name INTO v_sender_name FROM public.profiles WHERE id = v_uid;
    UPDATE public.conversations
       SET last_message_at = now(),
           user_unread = user_unread + 1
     WHERE id = p_conversation_id;

    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    VALUES (
      v_conv.user_id,
      'message',
      CASE WHEN v_role = 'trainer'
           THEN 'Nouveau message de votre formateur' || coalesce(' ' || v_sender_name, '')
           ELSE 'Nouveau message' || coalesce(' de ' || v_sender_name, '')
      END,
      left(p_body, 200),
      '/messages'
    );
  END IF;

  RETURN v_msg_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.send_message(uuid, text) TO authenticated;

-- 6) mark_conversation_read : gère trainer
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
       AND sender_role IN ('admin','trainer')
       AND read_at IS NULL;
    UPDATE public.conversations SET user_unread = 0 WHERE id = p_conversation_id;

  ELSIF v_role IN ('admin','trainer') THEN
    -- Formateur : autorisé seulement s'il partage une formation
    IF v_role = 'trainer'
       AND NOT public.trainer_shares_formation_with(v_uid, v_conv.user_id) THEN
      RETURN;
    END IF;
    UPDATE public.messages SET read_at = now()
     WHERE conversation_id = p_conversation_id
       AND sender_role = 'student'
       AND read_at IS NULL;
    UPDATE public.conversations SET admin_unread = 0 WHERE id = p_conversation_id;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.mark_conversation_read(uuid) TO authenticated;

-- 7) RPC : liste des conversations visibles par un formateur
CREATE OR REPLACE FUNCTION public.list_trainer_conversations()
RETURNS TABLE (
  conversation_id uuid,
  student_id uuid,
  student_name text,
  student_email text,
  formation_slug text,
  last_message_at timestamptz,
  admin_unread int,
  last_message_preview text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    c.id,
    p.id,
    p.full_name,
    p.email,
    (
      SELECT e.formation_slug
      FROM public.enrollments e
      JOIN public.trainer_formations tf
        ON tf.trainer_id = auth.uid()
       AND (tf.formation_id = e.formation_id
            OR (SELECT slug FROM public.formations WHERE id = tf.formation_id) = e.formation_slug)
      WHERE e.user_id = p.id
      ORDER BY e.created_at DESC
      LIMIT 1
    ),
    c.last_message_at,
    c.admin_unread,
    (
      SELECT left(m.body, 160)
      FROM public.messages m
      WHERE m.conversation_id = c.id
      ORDER BY m.created_at DESC
      LIMIT 1
    )
  FROM public.conversations c
  JOIN public.profiles p ON p.id = c.user_id
  WHERE public.is_trainer()
    AND public.trainer_shares_formation_with(auth.uid(), c.user_id)
  ORDER BY c.last_message_at DESC;
$$;

GRANT EXECUTE ON FUNCTION public.list_trainer_conversations() TO authenticated;
