-- =====================================================================
-- HOTFIX — RPC run_inactivity_check utilisait colonne "kind" inexistante
-- 2026-05-19
--
-- Symptôme Sentry (JAVASCRIPT-NEXTJS-4) :
--   Error: column "kind" of relation "notifications" does not exist
--   [code=42703]
--
-- Cause : la RPC tentait INSERT INTO notifications(user_id, kind, ...)
-- alors que la colonne s'appelle `type` (cf. supabase/messaging.sql:14
-- "type text NOT NULL DEFAULT 'system' CHECK ...").
--
-- Le cron quotidien /api/cron/inactivity échouait avec un 500, donc
-- AUCUN stagiaire inactif n'était notifié.
--
-- Fix : on recrée la RPC avec le bon nom de colonne.
-- =====================================================================

CREATE OR REPLACE FUNCTION public.run_inactivity_check()
RETURNS TABLE(notified_users int) LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  r record;
  notified int := 0;
BEGIN
  IF NOT public.is_admin() AND NOT pg_has_role(current_user, 'service_role', 'MEMBER') THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  FOR r IN
    SELECT a.user_id, a.full_name, a.email, a.days_inactive
      FROM public.inactivity_alerts a
      LEFT JOIN public.inactivity_pings p ON p.user_id = a.user_id
     WHERE p.last_pinged_at IS NULL
        OR p.last_pinged_at < now() - INTERVAL '7 days'
  LOOP
    -- 1) Notification au stagiaire
    INSERT INTO public.notifications(user_id, type, title, body, link_url)
    VALUES (
      r.user_id,
      'system',
      'On vous attend !',
      format(
        'Votre dernière activité remonte à %s jours. Reprenez là où vous vous étiez arrêté(e).',
        round(r.days_inactive)::text
      ),
      '/dashboard'
    );

    -- 2) Notification à tous les admins
    INSERT INTO public.notifications(user_id, type, title, body, link_url)
    SELECT
      ad.id,
      'system',
      'Stagiaire inactif',
      format('%s n''est plus actif depuis %s jours.', coalesce(r.full_name, r.email), round(r.days_inactive)::text),
      '/admin/users'
    FROM public.profiles ad WHERE ad.role IN ('admin','super_admin');

    -- 3) Marquage idempotent
    INSERT INTO public.inactivity_pings(user_id, last_pinged_at, ping_count)
    VALUES (r.user_id, now(), 1)
    ON CONFLICT (user_id) DO UPDATE
      SET last_pinged_at = now(),
          ping_count = public.inactivity_pings.ping_count + 1;

    notified := notified + 1;
  END LOOP;

  RETURN QUERY SELECT notified;
END;
$$;

GRANT EXECUTE ON FUNCTION public.run_inactivity_check() TO authenticated;

-- Vérification
DO $$
BEGIN
  RAISE NOTICE '════════ HOTFIX run_inactivity_check ════════';
  RAISE NOTICE '  RPC mise à jour : notifications.type au lieu de notifications.kind';
  RAISE NOTICE '  + élargi la cible admin à role IN (admin, super_admin)';
  RAISE NOTICE '════════════════════════════════════════════';
END $$;
