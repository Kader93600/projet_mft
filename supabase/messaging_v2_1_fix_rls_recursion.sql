-- ============================================================
-- INFRA - Messagerie v2.1 fix RLS recursion
-- ============================================================
-- Correctif sur la migration messaging_v2_multi_conversations.sql.
--
-- Problème détecté :
--   La policy `msg_read` sur public.messages utilise un EXISTS sur
--   public.conversation_participants. Or `conversation_participants`
--   a sa propre policy `conv_part_self_read` qui contient elle-même
--   un EXISTS récursif sur la même table. PostgreSQL ne résout pas
--   la récursion et retourne `false` → l'utilisateur ne voit pas
--   ses messages alors qu'il est bien participant.
--
-- Fix :
--   Remplacer les EXISTS récursifs par des fonctions
--   SECURITY DEFINER (qui bypassent la RLS au sein de la fonction).
--
-- Idempotent — peut être rejoué plusieurs fois sans casse.
-- Pré-requis : messaging_v2_multi_conversations.sql doit avoir été chargé.
-- ============================================================

-- ------------------------------------------------------------
-- 1) Helper : suis-je participant de cette conversation ?
--    SECURITY DEFINER → l'inner SELECT bypasse RLS.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_my_conversation(p_conv_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.conversation_participants
     WHERE conversation_id = p_conv_id
       AND user_id = auth.uid()
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_my_conversation(uuid) TO authenticated;

-- ------------------------------------------------------------
-- 2) Helper : is_admin élargi (compat super_admin)
--    L'is_admin() initial ne couvre que 'admin'. On ajoute une
--    version élargie incluant super_admin (sans casser l'existant).
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_staff()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
     WHERE id = auth.uid()
       AND role IN ('admin', 'super_admin')
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_staff() TO authenticated;

-- ------------------------------------------------------------
-- 3) Réécriture des policies sans EXISTS récursif
-- ------------------------------------------------------------

-- conversations.SELECT : moi participant OU staff
DROP POLICY IF EXISTS conv_read ON public.conversations;
CREATE POLICY conv_read ON public.conversations
  FOR SELECT USING (
    public.is_staff()
    OR public.is_my_conversation(id)
  );

-- messages.SELECT : participant OU staff
DROP POLICY IF EXISTS msg_read ON public.messages;
CREATE POLICY msg_read ON public.messages
  FOR SELECT USING (
    public.is_staff()
    OR public.is_my_conversation(conversation_id)
  );

-- messages.UPDATE : auteur uniquement (édition / soft delete)
DROP POLICY IF EXISTS msg_self_update ON public.messages;
CREATE POLICY msg_self_update ON public.messages
  FOR UPDATE USING (sender_id = auth.uid())
  WITH CHECK (sender_id = auth.uid());

-- conversation_participants.SELECT : moi OU même conv que moi OU staff
DROP POLICY IF EXISTS conv_part_self_read ON public.conversation_participants;
CREATE POLICY conv_part_self_read ON public.conversation_participants
  FOR SELECT USING (
    user_id = auth.uid()
    OR public.is_staff()
    OR public.is_my_conversation(conversation_id)
  );

-- conversation_participants.UPDATE : ses propres flags (pin, mute, archive, last_read_at)
DROP POLICY IF EXISTS conv_part_self_update ON public.conversation_participants;
CREATE POLICY conv_part_self_update ON public.conversation_participants
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ------------------------------------------------------------
-- 4) Vérification finale
-- ------------------------------------------------------------
DO $$
DECLARE
  v_helper_count int;
BEGIN
  SELECT count(*) INTO v_helper_count
    FROM pg_proc
   WHERE proname IN ('is_my_conversation', 'is_staff');

  IF v_helper_count < 2 THEN
    RAISE EXCEPTION 'Helpers manquants (% trouvés, attendu 2)', v_helper_count;
  END IF;

  RAISE NOTICE '╔════════════════════════════════════════════════════';
  RAISE NOTICE '║ ✓ Fix RLS recursion appliqué';
  RAISE NOTICE '╠════════════════════════════════════════════════════';
  RAISE NOTICE '║ Helpers : is_my_conversation(uuid), is_staff()';
  RAISE NOTICE '║ Policies réécrites : conv_read, msg_read,';
  RAISE NOTICE '║                      msg_self_update,';
  RAISE NOTICE '║                      conv_part_self_(read|update)';
  RAISE NOTICE '║ Plus de récursion RLS — les messages sont visibles';
  RAISE NOTICE '║ par tous les participants.';
  RAISE NOTICE '╚════════════════════════════════════════════════════';
END $$;
