-- =====================================================================
-- PURGE AUTOMATIQUE (RGPD, minimisation) — 13/07/2026
--
-- Applique les durées de conservation VALIDÉES (voir
-- docs/RGPD-registre-traitements.md) aux catégories sûres et clairement
-- « journaux / mesure ». Les données à forte contrainte légale (pièces
-- comptables 10 ans, dossiers de financement, comptes stagiaires) ne sont
-- PAS purgées ici : elles relèvent d'un processus considéré (anonymisation
-- via anonymize_user()), pas d'un cron automatique.
--
-- La fonction est SECURITY DEFINER (search_path épinglé), n'est exécutable
-- que par le service_role (cron), journalise chaque passage, et est
-- idempotente (rejouable sans effet de bord).
--
-- À appliquer par l'admin dans le SQL editor Supabase.
-- =====================================================================

-- Journal des passages de purge (auditabilité).
CREATE TABLE IF NOT EXISTS public.retention_purge_runs (
  id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ran_at   timestamptz NOT NULL DEFAULT now(),
  summary  jsonb NOT NULL
);
ALTER TABLE public.retention_purge_runs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS retention_purge_runs_admin_read ON public.retention_purge_runs;
CREATE POLICY retention_purge_runs_admin_read ON public.retention_purge_runs
  FOR SELECT USING (public.is_admin());
REVOKE ALL ON public.retention_purge_runs FROM anon, authenticated;
GRANT SELECT ON public.retention_purge_runs TO authenticated;  -- RLS is_admin()

-- Fonction de purge.
CREATE OR REPLACE FUNCTION public.run_data_retention_purge()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $fn$
DECLARE
  result jsonb := '{}'::jsonb;
  c      bigint;
BEGIN
  -- Preuve de consentement : 13 mois (validité) + 3 ans (preuve) = 49 mois.
  IF to_regclass('public.consent_events') IS NOT NULL THEN
    DELETE FROM public.consent_events WHERE created_at < now() - interval '49 months';
    GET DIAGNOSTICS c = ROW_COUNT; result := result || jsonb_build_object('consent_events', c);
  END IF;

  -- Journaux d'audit / accès : 12 mois.
  IF to_regclass('public.audit_logs') IS NOT NULL THEN
    DELETE FROM public.audit_logs WHERE created_at < now() - interval '12 months';
    GET DIAGNOSTICS c = ROW_COUNT; result := result || jsonb_build_object('audit_logs', c);
  END IF;
  IF to_regclass('public.data_access_log') IS NOT NULL THEN
    DELETE FROM public.data_access_log WHERE created_at < now() - interval '12 months';
    GET DIAGNOSTICS c = ROW_COUNT; result := result || jsonb_build_object('data_access_log', c);
  END IF;

  -- Emails transactionnels : 12 mois.
  IF to_regclass('public.email_log') IS NOT NULL THEN
    DELETE FROM public.email_log WHERE created_at < now() - interval '12 months';
    GET DIAGNOSTICS c = ROW_COUNT; result := result || jsonb_build_object('email_log', c);
  END IF;

  -- Journaux de recherche : 12 mois.
  IF to_regclass('public.search_logs') IS NOT NULL THEN
    DELETE FROM public.search_logs WHERE created_at < now() - interval '12 months';
    GET DIAGNOSTICS c = ROW_COUNT; result := result || jsonb_build_object('search_logs', c);
  END IF;

  -- Mesure d'audience : 25 mois (recommandation CNIL statistiques).
  IF to_regclass('public.acquisition_events') IS NOT NULL THEN
    DELETE FROM public.acquisition_events WHERE occurred_at < now() - interval '25 months';
    GET DIAGNOSTICS c = ROW_COUNT; result := result || jsonb_build_object('acquisition_events', c);
  END IF;

  -- Notifications déjà lues : ménage à 12 mois (housekeeping, non sensible).
  IF to_regclass('public.notifications') IS NOT NULL THEN
    DELETE FROM public.notifications
     WHERE read_at IS NOT NULL AND created_at < now() - interval '12 months';
    GET DIAGNOSTICS c = ROW_COUNT; result := result || jsonb_build_object('notifications_read', c);
  END IF;

  INSERT INTO public.retention_purge_runs (summary) VALUES (result);
  RETURN result;
END;
$fn$;

-- Exécutable uniquement par le service_role (cron). Jamais par les clients.
REVOKE EXECUTE ON FUNCTION public.run_data_retention_purge() FROM public, anon, authenticated;

-- =====================================================================
-- CONTRÔLE / EXÉCUTION MANUELLE (optionnel)
-- =====================================================================
-- select public.run_data_retention_purge();   -- renvoie les compteurs
-- select ran_at, summary from public.retention_purge_runs order by ran_at desc limit 5;
