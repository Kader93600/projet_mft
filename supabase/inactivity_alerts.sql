-- =====================================================================
-- Suivi de l'inactivité — indicateur Qualiopi 22 (suivi pédagogique)
-- Vue + RPC ; déclenchement par cron quotidien (route Next).
-- =====================================================================

-- Nettoyage des anciennes versions (si présentes en base) :
-- CREATE OR REPLACE VIEW refuse de modifier la structure d'une vue
-- existante. DROP CASCADE force la recréation propre.
DROP VIEW IF EXISTS public.inactivity_alerts CASCADE;
DROP VIEW IF EXISTS public.user_last_activity CASCADE;

-- Vue : dernière activité par stagiaire
CREATE OR REPLACE VIEW public.user_last_activity AS
SELECT
  p.id AS user_id,
  p.full_name,
  p.email,
  GREATEST(
    COALESCE((SELECT max(updated_at) FROM public.lesson_progress lp WHERE lp.user_id = p.id), 'epoch'::timestamptz),
    COALESCE((SELECT max(finished_at) FROM public.quiz_attempts qa WHERE qa.user_id = p.id), 'epoch'::timestamptz),
    COALESCE((SELECT max(created_at) FROM public.xp_events xe WHERE xe.user_id = p.id), 'epoch'::timestamptz),
    COALESCE((SELECT max(signed_at) FROM public.attendance_signatures sg WHERE sg.user_id = p.id), 'epoch'::timestamptz)
  ) AS last_activity_at,
  EXISTS (
    SELECT 1 FROM public.enrollments e
     WHERE e.user_id = p.id AND e.status IN ('a_payer','en_cours')
  ) AS is_active_enrollment
FROM public.profiles p
WHERE p.role = 'student'
  AND COALESCE(p.disabled, false) = false;

GRANT SELECT ON public.user_last_activity TO authenticated;

-- Vue : alertes (>= 7 jours sans activité, parcours en cours)
CREATE OR REPLACE VIEW public.inactivity_alerts AS
SELECT
  u.user_id,
  u.full_name,
  u.email,
  u.last_activity_at,
  EXTRACT(EPOCH FROM (now() - u.last_activity_at)) / 86400.0 AS days_inactive
FROM public.user_last_activity u
WHERE u.is_active_enrollment = true
  AND u.last_activity_at < now() - INTERVAL '7 days'
ORDER BY u.last_activity_at ASC;

GRANT SELECT ON public.inactivity_alerts TO authenticated;

-- ---------------------------------------------------------------------
-- RPC : crée des notifications pour les inactifs
-- (idempotente sur 24h via une table dédiée pour éviter le spam)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.inactivity_pings (
  user_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  last_pinged_at timestamptz NOT NULL DEFAULT now(),
  ping_count int NOT NULL DEFAULT 1
);

ALTER TABLE public.inactivity_pings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS ip_admin ON public.inactivity_pings;
CREATE POLICY ip_admin ON public.inactivity_pings
  FOR SELECT USING (public.is_admin());

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
    INSERT INTO public.notifications(user_id, kind, title, body, link_url)
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
    INSERT INTO public.notifications(user_id, kind, title, body, link_url)
    SELECT
      ad.id,
      'system',
      'Stagiaire inactif',
      format('%s n''est plus actif depuis %s jours.', coalesce(r.full_name, r.email), round(r.days_inactive)::text),
      '/admin/users'
    FROM public.profiles ad WHERE ad.role = 'admin';

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
