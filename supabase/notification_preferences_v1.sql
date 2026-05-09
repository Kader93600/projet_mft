-- ============================================================
-- INFRA - Notifications préférences par type
-- ============================================================
-- Stocke les types de notifications désactivés par utilisateur.
-- Modèle simple "opt-out" : par défaut tout est activé sur in_app
-- et push (les types apparaissent normalement dans le centre).
-- L'utilisateur peut désactiver des types ; ceux-ci sont stockés
-- dans des tableaux text[].
--
-- Schema :
--   user_id (PK)        : FK auth.users
--   in_app_disabled[]   : types ne devant PAS apparaître dans le centre
--   push_disabled[]     : types ne devant PAS déclencher de push (Phase C)
--   email_disabled[]    : réservé V2 — types ne devant PAS envoyer d'email
--
-- RPC :
--   set_notification_preference(type, channel, enabled)  -- toggle atomique
--   reset_notification_preferences()                      -- revient au défaut
--
-- RLS : self-only (lecture/insert/update/delete sur sa propre ligne).
--
-- Idempotent : ré-exécutable sans danger.
-- ============================================================

-- ------------------------------------------------------------
-- 1) Table
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.notification_preferences (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  in_app_disabled text[] NOT NULL DEFAULT ARRAY[]::text[],
  push_disabled   text[] NOT NULL DEFAULT ARRAY[]::text[],
  email_disabled  text[] NOT NULL DEFAULT ARRAY[]::text[],
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Index pour les futurs JOIN par publishers (RPC enqueue)
CREATE INDEX IF NOT EXISTS notif_prefs_in_app_idx
  ON public.notification_preferences USING gin (in_app_disabled);
CREATE INDEX IF NOT EXISTS notif_prefs_push_idx
  ON public.notification_preferences USING gin (push_disabled);

-- ------------------------------------------------------------
-- 2) RLS
-- ------------------------------------------------------------
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS notif_prefs_self_select ON public.notification_preferences;
CREATE POLICY notif_prefs_self_select ON public.notification_preferences
  FOR SELECT USING (user_id = auth.uid() OR public.is_admin());

DROP POLICY IF EXISTS notif_prefs_self_insert ON public.notification_preferences;
CREATE POLICY notif_prefs_self_insert ON public.notification_preferences
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS notif_prefs_self_update ON public.notification_preferences;
CREATE POLICY notif_prefs_self_update ON public.notification_preferences
  FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS notif_prefs_self_delete ON public.notification_preferences;
CREATE POLICY notif_prefs_self_delete ON public.notification_preferences
  FOR DELETE USING (user_id = auth.uid());

-- ------------------------------------------------------------
-- 3) RPC : set_notification_preference
--    Toggle atomique pour un (type, canal) donné.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.set_notification_preference(
  p_type text,
  p_channel text,
  p_enabled boolean
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_col text;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Non authentifié.';
  END IF;

  -- Liste blanche : doit matcher la contrainte CHECK de notifications
  IF p_type NOT IN (
    'announcement','message','system','quiz_result',
    'exam','achievement','course','admin',
    'coaching','badge','certificate'
  ) THEN
    RAISE EXCEPTION 'Type de notification invalide : %', p_type;
  END IF;

  IF p_channel NOT IN ('in_app', 'push', 'email') THEN
    RAISE EXCEPTION 'Canal invalide : %', p_channel;
  END IF;

  -- Crée la ligne si absente (avec valeurs par défaut)
  INSERT INTO public.notification_preferences (user_id)
       VALUES (v_uid)
  ON CONFLICT (user_id) DO NOTHING;

  v_col := p_channel || '_disabled';

  IF p_enabled THEN
    -- Active le type → on le RETIRE de la liste des désactivés
    EXECUTE format(
      'UPDATE public.notification_preferences
          SET %I = array_remove(%I, $1),
              updated_at = now()
        WHERE user_id = $2',
      v_col, v_col
    ) USING p_type, v_uid;
  ELSE
    -- Désactive le type → on l'AJOUTE à la liste des désactivés (sans doublon)
    EXECUTE format(
      'UPDATE public.notification_preferences
          SET %I = (
            SELECT COALESCE(array_agg(DISTINCT t), ARRAY[]::text[])
              FROM unnest(%I || ARRAY[$1]::text[]) t
          ),
              updated_at = now()
        WHERE user_id = $2',
      v_col, v_col
    ) USING p_type, v_uid;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION
  public.set_notification_preference(text, text, boolean)
  TO authenticated;

-- ------------------------------------------------------------
-- 4) RPC : reset_notification_preferences
--    Revient à l'état "tout activé".
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.reset_notification_preferences()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
BEGIN
  IF v_uid IS NULL THEN RETURN; END IF;
  DELETE FROM public.notification_preferences WHERE user_id = v_uid;
END;
$$;

GRANT EXECUTE ON FUNCTION public.reset_notification_preferences() TO authenticated;

-- ------------------------------------------------------------
-- 5) Helper : is_notification_enabled (pour les futurs publishers RPC)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_notification_enabled(
  p_user_id uuid,
  p_type text,
  p_channel text
)
RETURNS boolean
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_disabled text[];
BEGIN
  IF p_channel NOT IN ('in_app', 'push', 'email') THEN RETURN true; END IF;

  EXECUTE format(
    'SELECT %I FROM public.notification_preferences WHERE user_id = $1',
    p_channel || '_disabled'
  ) INTO v_disabled USING p_user_id;

  IF v_disabled IS NULL THEN RETURN true; END IF;
  RETURN NOT (p_type = ANY(v_disabled));
END;
$$;

GRANT EXECUTE ON FUNCTION
  public.is_notification_enabled(uuid, text, text)
  TO authenticated;

-- ------------------------------------------------------------
-- Vérification finale
-- ------------------------------------------------------------
DO $$
DECLARE
  v_table_ok boolean;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM information_schema.tables
     WHERE table_schema = 'public' AND table_name = 'notification_preferences'
  ) INTO v_table_ok;

  IF NOT v_table_ok THEN
    RAISE EXCEPTION 'Table notification_preferences introuvable.';
  END IF;

  RAISE NOTICE '╔════════════════════════════════════════════════════';
  RAISE NOTICE '║ ✓ Notifications préférences par type déployé';
  RAISE NOTICE '╠════════════════════════════════════════════════════';
  RAISE NOTICE '║ Table : public.notification_preferences';
  RAISE NOTICE '║ RPC   : set_notification_preference(type, channel, enabled)';
  RAISE NOTICE '║ RPC   : reset_notification_preferences()';
  RAISE NOTICE '║ RPC   : is_notification_enabled(user, type, channel)';
  RAISE NOTICE '║ RLS   : self-only';
  RAISE NOTICE '║ Defaut: tous types actifs sur in_app + push';
  RAISE NOTICE '╚════════════════════════════════════════════════════';
END $$;
