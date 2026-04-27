-- =====================================================================
-- Fix : recompute_user_achievements insère des notifications de type 'badge'
-- mais le CHECK initial ne le prévoyait pas.
-- On élargit le check pour inclure tous les types réellement utilisés.
-- =====================================================================

-- 1) Voir l'état actuel (debug, optionnel)
-- SELECT conname, pg_get_constraintdef(oid)
--   FROM pg_constraint
--  WHERE conrelid = 'public.notifications'::regclass
--    AND contype = 'c';

-- 2) Drop l'ancien check s'il existe
ALTER TABLE public.notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;

-- 3) Recréer avec la liste complète de types (souple : on accepte tout texte
--    non vide, l'application reste responsable des valeurs).
ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check
  CHECK (
    type IS NOT NULL
    AND length(btrim(type)) > 0
    AND type IN (
      'info',
      'success',
      'warning',
      'error',
      'badge',
      'certificate',
      'message',
      'announcement',
      'coaching',
      'enrollment',
      'deletion_request',
      'a11y_request',
      'system'
    )
  );
