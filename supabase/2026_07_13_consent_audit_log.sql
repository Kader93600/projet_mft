-- =====================================================================
-- JOURNAL DE PREUVE DE CONSENTEMENT — 13/07/2026 (conformité CNIL)
--
-- Problème : la bannière cookies POST vers /api/me/consent, qui exige une
-- SESSION (401 pour les visiteurs anonymes). Résultat : le consentement des
-- visiteurs NON connectés (la majorité) n'était jamais tracé côté serveur,
-- seulement dans leur localStorage. Or la CNIL impose de pouvoir PROUVER
-- que le consentement a été recueilli (qui, quoi, quand, dans quelle version).
--
-- Solution : table d'audit append-only `consent_events`, alimentée pour TOUS
-- les visiteurs (anonymes inclus) via l'endpoint /api/consent/log (écriture
-- en service_role, jamais en direct par le client). Lecture réservée aux
-- admins.
--
-- Idempotent. À appliquer par l'admin dans le SQL editor Supabase.
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.consent_events (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Identifiant visiteur (cookie/localStorage première partie, aléatoire) :
  -- permet de relier plusieurs choix d'un même visiteur anonyme.
  visitor_id     text,
  -- Rattaché à l'utilisateur si une session existe au moment du choix.
  user_id        uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  -- Snapshot complet des choix : { essential, analytics, marketing,
  -- communications, newsletter }.
  choices        jsonb NOT NULL,
  -- Version de la politique/bannière au moment du consentement (traçabilité).
  policy_version text  NOT NULL DEFAULT 'v1',
  -- Éléments de preuve techniques.
  ip_address     text,
  user_agent     text,
  created_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS consent_events_visitor_idx
  ON public.consent_events (visitor_id, created_at DESC);
CREATE INDEX IF NOT EXISTS consent_events_user_idx
  ON public.consent_events (user_id, created_at DESC);

ALTER TABLE public.consent_events ENABLE ROW LEVEL SECURITY;

-- Lecture : admins uniquement (audit). Aucune écriture directe par le client
-- (anon/authenticated) : l'API insère en service_role, qui bypasse la RLS.
DROP POLICY IF EXISTS consent_events_admin_read ON public.consent_events;
CREATE POLICY consent_events_admin_read ON public.consent_events
  FOR SELECT USING (public.is_admin());

REVOKE ALL ON public.consent_events FROM anon, authenticated;
GRANT SELECT ON public.consent_events TO authenticated;  -- filtré par RLS is_admin()

-- =====================================================================
-- CONTRÔLE POST-EXÉCUTION
-- =====================================================================
-- select relrowsecurity from pg_class where oid='public.consent_events'::regclass; -- t
-- Après quelques passages sur la bannière :
--   select visitor_id, choices, policy_version, created_at
--     from public.consent_events order by created_at desc limit 10;
