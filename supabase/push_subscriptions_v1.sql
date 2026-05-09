-- ============================================================
-- INFRA - Push notifications subscriptions
-- ============================================================
-- Stocke les abonnements Web Push (PushSubscription) des utilisateurs.
-- Un même utilisateur peut avoir plusieurs abonnements (un par device
-- ou navigateur).
--
-- Schema :
--   id             : PK
--   user_id        : FK auth.users
--   endpoint       : URL unique du push service (FCM, Mozilla, etc.)
--                    UNIQUE → upsert idempotent
--   p256dh, auth   : clés ECDH du client (envoyées au push service)
--   user_agent     : libellé du navigateur (debug + réinscription)
--   created_at     : date d'inscription
--   last_used_at   : dernière fois que le serveur a réussi à pousser
--
-- RLS : self-only (CRUD sur ses propres souscriptions). Le service
-- role bypass RLS pour l'envoi (côté API route /api/push/send).
--
-- Idempotent : ré-exécutable sans danger.
-- ============================================================

-- ------------------------------------------------------------
-- 1) Table
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.push_subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  endpoint text NOT NULL UNIQUE,
  p256dh text NOT NULL,
  auth text NOT NULL,
  user_agent text,
  created_at timestamptz NOT NULL DEFAULT now(),
  last_used_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS push_subs_user_idx
  ON public.push_subscriptions(user_id);

-- ------------------------------------------------------------
-- 2) RLS
-- ------------------------------------------------------------
ALTER TABLE public.push_subscriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS push_subs_self_select ON public.push_subscriptions;
CREATE POLICY push_subs_self_select ON public.push_subscriptions
  FOR SELECT USING (user_id = auth.uid() OR public.is_admin());

DROP POLICY IF EXISTS push_subs_self_insert ON public.push_subscriptions;
CREATE POLICY push_subs_self_insert ON public.push_subscriptions
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS push_subs_self_update ON public.push_subscriptions;
CREATE POLICY push_subs_self_update ON public.push_subscriptions
  FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS push_subs_self_delete ON public.push_subscriptions;
CREATE POLICY push_subs_self_delete ON public.push_subscriptions
  FOR DELETE USING (user_id = auth.uid());

-- ------------------------------------------------------------
-- 3) Vérification finale
-- ------------------------------------------------------------
DO $$
DECLARE
  v_table_ok boolean;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM information_schema.tables
     WHERE table_schema = 'public' AND table_name = 'push_subscriptions'
  ) INTO v_table_ok;

  IF NOT v_table_ok THEN
    RAISE EXCEPTION 'Table push_subscriptions introuvable.';
  END IF;

  RAISE NOTICE '╔════════════════════════════════════════════════════';
  RAISE NOTICE '║ ✓ Push subscriptions déployé';
  RAISE NOTICE '╠════════════════════════════════════════════════════';
  RAISE NOTICE '║ Table : public.push_subscriptions';
  RAISE NOTICE '║ RLS   : self-only (admin bypass via is_admin())';
  RAISE NOTICE '║ Index : push_subs_user_idx (user_id)';
  RAISE NOTICE '╠════════════════════════════════════════════════════';
  RAISE NOTICE '║ ÉTAPE SUIVANTE : configurer une Database Webhook dans';
  RAISE NOTICE '║ Supabase Dashboard pour POST automatique vers';
  RAISE NOTICE '║ /api/push/send à l''INSERT sur notifications.';
  RAISE NOTICE '║ Voir README ou guide post-déploiement.';
  RAISE NOTICE '╚════════════════════════════════════════════════════';
END $$;
