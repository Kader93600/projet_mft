-- ============================================================
-- INFRA - Messagerie v2.2 leave + delete conversation
-- ============================================================
-- Ajoute deux RPC pour quitter/supprimer une conversation :
--
--   leave_conversation(p_conversation_id) :
--     Retire l'utilisateur courant de la conversation. Les autres
--     participants la conservent. Si plus aucun participant n'est
--     présent après le retrait, la conversation orpheline est
--     supprimée automatiquement (cascade des messages).
--     Accessible à TOUS les participants.
--
--   delete_conversation(p_conversation_id) :
--     Détruit la conversation pour tout le monde, y compris l'historique
--     des messages (cascade FK ON DELETE).
--     Accessible UNIQUEMENT aux admins/super_admins (et à l'owner de
--     la conv s'il en existe un).
--
-- Idempotent — peut être rejoué plusieurs fois sans casse.
-- Pré-requis : messaging_v2_multi_conversations.sql + v2.1 fix.
-- ============================================================

-- ------------------------------------------------------------
-- 1) leave_conversation
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.leave_conversation(p_conversation_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_remaining int;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Non authentifié';
  END IF;

  -- Retire le participant
  DELETE FROM public.conversation_participants
   WHERE conversation_id = p_conversation_id
     AND user_id = v_uid;

  -- Si plus aucun participant : supprime la conv orpheline
  -- (les messages cascade automatiquement via FK ON DELETE CASCADE)
  SELECT count(*) INTO v_remaining
    FROM public.conversation_participants
   WHERE conversation_id = p_conversation_id;

  IF v_remaining = 0 THEN
    DELETE FROM public.conversations WHERE id = p_conversation_id;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.leave_conversation(uuid) TO authenticated;

-- ------------------------------------------------------------
-- 2) delete_conversation (admin / owner uniquement)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.delete_conversation(p_conversation_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_is_staff boolean;
  v_is_owner boolean;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Non authentifié';
  END IF;

  -- Staff ?
  SELECT public.is_staff() INTO v_is_staff;

  -- Owner de la conv ?
  SELECT EXISTS (
    SELECT 1 FROM public.conversation_participants
     WHERE conversation_id = p_conversation_id
       AND user_id = v_uid
       AND role_in_conv = 'owner'
  ) INTO v_is_owner;

  IF NOT (v_is_staff OR v_is_owner) THEN
    RAISE EXCEPTION 'Vous n''êtes pas autorisé à supprimer cette conversation pour tous';
  END IF;

  -- Cascade : supprime conv → cascade messages + participants
  DELETE FROM public.conversations WHERE id = p_conversation_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_conversation(uuid) TO authenticated;

-- ------------------------------------------------------------
-- 3) Policy DELETE sur conversations (filet de sécurité côté SQL)
--    Les RPC ci-dessus sont SECURITY DEFINER donc bypass RLS,
--    mais on ajoute quand même une policy explicite pour les rares
--    cas d'accès direct en client (jamais utilisé en pratique).
-- ------------------------------------------------------------
DROP POLICY IF EXISTS conv_delete ON public.conversations;
CREATE POLICY conv_delete ON public.conversations
  FOR DELETE USING (
    public.is_staff()
    OR EXISTS (
      SELECT 1 FROM public.conversation_participants cp
       WHERE cp.conversation_id = conversations.id
         AND cp.user_id = auth.uid()
         AND cp.role_in_conv = 'owner'
    )
  );

-- ------------------------------------------------------------
-- 4) Vérification finale
-- ------------------------------------------------------------
DO $$
DECLARE
  v_count int;
BEGIN
  SELECT count(*) INTO v_count
    FROM pg_proc
   WHERE proname IN ('leave_conversation', 'delete_conversation');

  IF v_count < 2 THEN
    RAISE EXCEPTION 'RPC manquants (% trouvés, attendu 2)', v_count;
  END IF;

  RAISE NOTICE '╔════════════════════════════════════════════════════';
  RAISE NOTICE '║ ✓ Leave / Delete conversation déployé';
  RAISE NOTICE '╠════════════════════════════════════════════════════';
  RAISE NOTICE '║ RPC : leave_conversation(uuid) — auto-clean orphelins';
  RAISE NOTICE '║ RPC : delete_conversation(uuid) — staff/owner only';
  RAISE NOTICE '║ Policy : conv_delete (staff OU owner)';
  RAISE NOTICE '╚════════════════════════════════════════════════════';
END $$;
