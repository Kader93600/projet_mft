-- ============================================================
-- INFRA - Notifications v2 premium (types étendus + delete)
-- ============================================================
-- Étend le système de notifications pour le centre de notifications
-- premium (dropdown topbar) :
--   1) Élargit le CHECK type à 11 catégories : 8 catégories métier
--      du centre premium + 3 types legacy déjà émis par d'autres
--      modules (coaching, badge, certificate) — non-cassant.
--   2) Ajoute une policy DELETE — l'utilisateur peut supprimer ses
--      notifications individuellement ou en masse.
--   3) Ajoute un RPC delete_notifications(p_ids uuid[]) idempotent —
--      null = tout supprimer pour l'utilisateur courant.
--
-- Pré-requis : messaging.sql doit avoir été chargé (table notifications
-- + index + RPC mark_notifications_read).
--
-- Idempotent : ré-exécutable sans danger.
-- ============================================================

-- ------------------------------------------------------------
-- 0) Diagnostic : remonter les types non standard pour info
-- ------------------------------------------------------------
DO $$
DECLARE
  v_unknown text;
BEGIN
  SELECT string_agg(DISTINCT t || ' (' || c || ')', ', ' ORDER BY t || ' (' || c || ')')
    INTO v_unknown
    FROM (
      SELECT type AS t, count(*)::text AS c
        FROM public.notifications
       WHERE type NOT IN (
         'announcement','message','system','quiz_result',
         'exam','achievement','course','admin',
         'coaching','badge','certificate'
       )
       GROUP BY type
    ) s;

  IF v_unknown IS NOT NULL THEN
    RAISE NOTICE 'Types non-standard détectés (seront remappés vers system) : %', v_unknown;
  END IF;
END $$;

-- ------------------------------------------------------------
-- 1) Normaliser les types résiduels qui ne rentreraient dans
--    aucune catégorie connue (sécurité — fallback "system")
-- ------------------------------------------------------------
UPDATE public.notifications
   SET type = 'system'
 WHERE type IS NULL
    OR type NOT IN (
      'announcement','message','system','quiz_result',
      'exam','achievement','course','admin',
      'coaching','badge','certificate'
    );

-- ------------------------------------------------------------
-- 2) Élargir la contrainte CHECK type
--    Avant : announcement, message, system, quiz_result (4 types)
--    Après : 11 types (8 nouveaux + 3 legacy emis par d'autres modules)
-- ------------------------------------------------------------
ALTER TABLE public.notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check
  CHECK (type IN (
    -- Catégories du centre premium
    'announcement',
    'message',
    'system',
    'quiz_result',
    'exam',
    'achievement',
    'course',
    'admin',
    -- Types legacy déjà émis par d'autres modules (non-cassants)
    'coaching',     -- coaching.sql : rendez-vous d'accompagnement
    'badge',        -- achievements.sql : badge débloqué
    'certificate'   -- achievements.sql : certificat délivré
  ));

-- ------------------------------------------------------------
-- 3) Policy DELETE : l'utilisateur peut supprimer SES notifications
--    (et l'admin peut tout supprimer pour le support)
-- ------------------------------------------------------------
DROP POLICY IF EXISTS notif_own_delete ON public.notifications;
CREATE POLICY notif_own_delete ON public.notifications
  FOR DELETE USING (user_id = auth.uid() OR public.is_admin());

-- ------------------------------------------------------------
-- 4) RPC delete_notifications(p_ids uuid[])
--    p_ids = NULL  → supprime toutes les notifications de l'utilisateur
--    p_ids = liste → supprime uniquement les ids fournis (et seulement
--                    ceux qui appartiennent à l'utilisateur, double sécurité)
--    Retourne le nombre de lignes supprimées.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.delete_notifications(p_ids uuid[] DEFAULT NULL)
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
    DELETE FROM public.notifications
     WHERE user_id = v_uid;
  ELSE
    DELETE FROM public.notifications
     WHERE user_id = v_uid
       AND id = ANY(p_ids);
  END IF;

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_notifications(uuid[]) TO authenticated;

-- ------------------------------------------------------------
-- Vérification finale
-- ------------------------------------------------------------
DO $$
DECLARE
  v_constraint_ok boolean;
  v_total int;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM pg_constraint WHERE conname = 'notifications_type_check'
  ) INTO v_constraint_ok;

  SELECT count(*) INTO v_total FROM public.notifications;

  IF NOT v_constraint_ok THEN
    RAISE EXCEPTION 'Contrainte notifications_type_check introuvable.';
  END IF;

  RAISE NOTICE '╔════════════════════════════════════════════════════';
  RAISE NOTICE '║ ✓ Notifications v2 premium déployé';
  RAISE NOTICE '╠════════════════════════════════════════════════════';
  RAISE NOTICE '║ Types autorisés (11) :';
  RAISE NOTICE '║   announcement, message, system, quiz_result,';
  RAISE NOTICE '║   exam, achievement, course, admin,';
  RAISE NOTICE '║   coaching, badge, certificate (legacy)';
  RAISE NOTICE '║ Policy DELETE   : notif_own_delete (active)';
  RAISE NOTICE '║ RPC             : delete_notifications(uuid[])';
  RAISE NOTICE '║ Lignes en base  : %', v_total;
  RAISE NOTICE '╚════════════════════════════════════════════════════';
END $$;
