-- =====================================================================
-- P3 #3 / Sprint A — CRM léger (enrichissement enrollment_requests)
-- 2026-05-20
--
-- Décisions client (cf. docs/p3-3-marketing-data.md) :
--   • Assignation : self-assign ("Je prends ce lead")
--   • Notes : visibles entre admins (transparence)
--   • Relances : email seul (cron quotidien)
--   • Délai relance par défaut : 3 jours
--
-- Étend `enrollment_requests` avec :
--   - assigned_to_admin_id : qui s'occupe du lead
--   - next_followup_at     : date de prochaine relance
--   - snoozed_until        : mise en pause temporaire
--   - source               : provenance (form_contact, form_inscription, import…)
--   - tags                 : étiquettes libres (text[])
--
-- Nouvelles tables :
--   - lead_notes      : 1 lead = N notes manuelles (call, email, meeting, …)
--   - lead_activities : audit trail auto (status changed, assigned, etc.)
--
-- Vue : crm_my_queue (leads assignés à l'admin courant, triés par priorité)
--
-- ⚠️ ORDRE : tables d'abord, policies ensuite (cf. retex Sprint C P3 #2).
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- BLOC 1 — Création des tables (+ ALTER enrollment_requests)
-- ─────────────────────────────────────────────────────────────────────

ALTER TABLE public.enrollment_requests
  ADD COLUMN IF NOT EXISTS assigned_to_admin_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS next_followup_at timestamptz,
  ADD COLUMN IF NOT EXISTS snoozed_until timestamptz,
  ADD COLUMN IF NOT EXISTS source text DEFAULT 'form_contact',
  ADD COLUMN IF NOT EXISTS tags text[] NOT NULL DEFAULT '{}'::text[],
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS enrollment_requests_assigned_idx
  ON public.enrollment_requests(assigned_to_admin_id)
  WHERE assigned_to_admin_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS enrollment_requests_followup_idx
  ON public.enrollment_requests(next_followup_at)
  WHERE next_followup_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS enrollment_requests_status_idx
  ON public.enrollment_requests(status);

-- Trigger updated_at
CREATE OR REPLACE FUNCTION public.tg_enrollment_request_touch()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END $$;

DROP TRIGGER IF EXISTS tg_enrollment_requests_updated_at ON public.enrollment_requests;
CREATE TRIGGER tg_enrollment_requests_updated_at
  BEFORE UPDATE ON public.enrollment_requests
  FOR EACH ROW EXECUTE FUNCTION public.tg_enrollment_request_touch();

-- Table lead_notes : 1 lead = N notes manuelles
CREATE TABLE IF NOT EXISTS public.lead_notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  enrollment_request_id uuid NOT NULL REFERENCES public.enrollment_requests(id) ON DELETE CASCADE,
  author_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  kind text NOT NULL DEFAULT 'note'
    CHECK (kind IN ('call', 'email', 'sms', 'meeting', 'note')),
  body text NOT NULL,
  occurred_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS lead_notes_lead_idx
  ON public.lead_notes(enrollment_request_id, occurred_at DESC);

-- Table lead_activities : audit trail auto
CREATE TABLE IF NOT EXISTS public.lead_activities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  enrollment_request_id uuid NOT NULL REFERENCES public.enrollment_requests(id) ON DELETE CASCADE,
  author_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  kind text NOT NULL CHECK (kind IN (
    'created', 'status_changed', 'assigned', 'unassigned',
    'note_added', 'followup_scheduled', 'snoozed', 'unsnoozed',
    'email_sent', 'converted'
  )),
  details jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS lead_activities_lead_idx
  ON public.lead_activities(enrollment_request_id, created_at DESC);

-- ─────────────────────────────────────────────────────────────────────
-- BLOC 2 — RLS (toutes les tables CRM = admin only)
-- ─────────────────────────────────────────────────────────────────────

ALTER TABLE public.lead_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_activities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS lead_notes_admin ON public.lead_notes;
CREATE POLICY lead_notes_admin ON public.lead_notes
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS lead_activities_admin ON public.lead_activities;
CREATE POLICY lead_activities_admin ON public.lead_activities
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ─────────────────────────────────────────────────────────────────────
-- BLOC 3 — Audit trail automatique sur enrollment_requests
-- ─────────────────────────────────────────────────────────────────────
-- Trigger qui log les changements importants dans lead_activities :
--   • Insertion d'un lead         → kind='created'
--   • Changement de status        → kind='status_changed'
--   • Changement d'assignation    → kind='assigned' ou 'unassigned'
--   • next_followup_at posé       → kind='followup_scheduled'
--   • snoozed_until posé/retiré   → kind='snoozed' ou 'unsnoozed'
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.tg_lead_activity_log()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_actor uuid := auth.uid();
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.lead_activities (enrollment_request_id, author_id, kind, details)
    VALUES (NEW.id, v_actor, 'created', jsonb_build_object(
      'status', NEW.status,
      'source', NEW.source,
      'email', NEW.email
    ));
    RETURN NEW;
  END IF;

  -- UPDATE : on log chaque changement notable
  IF TG_OP = 'UPDATE' THEN
    IF NEW.status IS DISTINCT FROM OLD.status THEN
      INSERT INTO public.lead_activities (enrollment_request_id, author_id, kind, details)
      VALUES (NEW.id, v_actor, 'status_changed', jsonb_build_object(
        'from', OLD.status, 'to', NEW.status
      ));
    END IF;

    IF NEW.assigned_to_admin_id IS DISTINCT FROM OLD.assigned_to_admin_id THEN
      IF NEW.assigned_to_admin_id IS NULL THEN
        INSERT INTO public.lead_activities (enrollment_request_id, author_id, kind, details)
        VALUES (NEW.id, v_actor, 'unassigned',
          jsonb_build_object('previous_admin', OLD.assigned_to_admin_id));
      ELSE
        INSERT INTO public.lead_activities (enrollment_request_id, author_id, kind, details)
        VALUES (NEW.id, v_actor, 'assigned',
          jsonb_build_object('admin_id', NEW.assigned_to_admin_id));
      END IF;
    END IF;

    IF NEW.next_followup_at IS DISTINCT FROM OLD.next_followup_at
       AND NEW.next_followup_at IS NOT NULL THEN
      INSERT INTO public.lead_activities (enrollment_request_id, author_id, kind, details)
      VALUES (NEW.id, v_actor, 'followup_scheduled',
        jsonb_build_object('next_at', NEW.next_followup_at));
    END IF;

    IF NEW.snoozed_until IS DISTINCT FROM OLD.snoozed_until THEN
      IF NEW.snoozed_until IS NULL THEN
        INSERT INTO public.lead_activities (enrollment_request_id, author_id, kind, details)
        VALUES (NEW.id, v_actor, 'unsnoozed', '{}'::jsonb);
      ELSE
        INSERT INTO public.lead_activities (enrollment_request_id, author_id, kind, details)
        VALUES (NEW.id, v_actor, 'snoozed',
          jsonb_build_object('until', NEW.snoozed_until));
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_enrollment_requests_activity ON public.enrollment_requests;
CREATE TRIGGER tg_enrollment_requests_activity
  AFTER INSERT OR UPDATE ON public.enrollment_requests
  FOR EACH ROW EXECUTE FUNCTION public.tg_lead_activity_log();

-- Trigger : log auto quand une note est ajoutée
CREATE OR REPLACE FUNCTION public.tg_lead_note_log()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.lead_activities (enrollment_request_id, author_id, kind, details)
  VALUES (NEW.enrollment_request_id, NEW.author_id, 'note_added',
    jsonb_build_object('note_id', NEW.id, 'note_kind', NEW.kind));
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_lead_notes_activity ON public.lead_notes;
CREATE TRIGGER tg_lead_notes_activity
  AFTER INSERT ON public.lead_notes
  FOR EACH ROW EXECUTE FUNCTION public.tg_lead_note_log();

-- ─────────────────────────────────────────────────────────────────────
-- BLOC 4 — Vue : ma file CRM (admin courant)
-- ─────────────────────────────────────────────────────────────────────
-- Leads assignés à l'admin courant, triés par priorité :
--   1. Relance due (next_followup_at <= now()) en premier
--   2. Puis par date de relance ascendante
--   3. Snoozed non visible (sauf si snoozed_until <= now())
CREATE OR REPLACE VIEW public.crm_my_queue
WITH (security_invoker = on)
AS
SELECT
  er.*,
  -- Calculs utiles pour le tri UI
  CASE
    WHEN er.snoozed_until IS NOT NULL AND er.snoozed_until > now() THEN true
    ELSE false
  END AS is_snoozed,
  CASE
    WHEN er.next_followup_at IS NOT NULL AND er.next_followup_at <= now() THEN true
    ELSE false
  END AS followup_due,
  -- Compteur de notes
  (SELECT count(*)::int FROM public.lead_notes ln
    WHERE ln.enrollment_request_id = er.id) AS notes_count
FROM public.enrollment_requests er
WHERE er.assigned_to_admin_id = auth.uid()
  AND er.status NOT IN ('inscrit', 'refuse')
ORDER BY
  -- Snoozed en bas
  CASE WHEN er.snoozed_until IS NOT NULL AND er.snoozed_until > now() THEN 1 ELSE 0 END,
  -- Relance due en haut
  CASE WHEN er.next_followup_at IS NOT NULL AND er.next_followup_at <= now() THEN 0 ELSE 1 END,
  -- Puis date de relance ascendante
  er.next_followup_at NULLS LAST,
  er.created_at DESC;

GRANT SELECT ON public.crm_my_queue TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- BLOC 5 — Vue agrégée : pipeline (counters par statut)
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.crm_pipeline_counters
WITH (security_invoker = on)
AS
SELECT
  status,
  count(*)::int AS count,
  count(*) FILTER (WHERE assigned_to_admin_id IS NULL)::int AS unassigned_count,
  count(*) FILTER (WHERE next_followup_at IS NOT NULL AND next_followup_at <= now())::int AS overdue_count
FROM public.enrollment_requests
WHERE status NOT IN ('inscrit', 'refuse')  -- on garde uniquement actif
GROUP BY status;

GRANT SELECT ON public.crm_pipeline_counters TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- BLOC 6 — RPCs métier (sécurisées)
-- ─────────────────────────────────────────────────────────────────────

-- Self-assign : un admin "prend" un lead
CREATE OR REPLACE FUNCTION public.crm_self_assign_lead(p_lead_id uuid)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'forbidden';
  END IF;
  UPDATE public.enrollment_requests
     SET assigned_to_admin_id = auth.uid()
   WHERE id = p_lead_id
     AND (assigned_to_admin_id IS NULL OR assigned_to_admin_id = auth.uid());
END;
$$;
GRANT EXECUTE ON FUNCTION public.crm_self_assign_lead(uuid) TO authenticated;

-- Unassign : libérer le lead (le sien ou n'importe lequel si super_admin)
CREATE OR REPLACE FUNCTION public.crm_unassign_lead(p_lead_id uuid)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_current_admin uuid;
  v_role text;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'forbidden';
  END IF;
  SELECT assigned_to_admin_id INTO v_current_admin
    FROM public.enrollment_requests WHERE id = p_lead_id;
  SELECT role INTO v_role FROM public.profiles WHERE id = auth.uid();
  IF v_current_admin <> auth.uid() AND v_role <> 'super_admin' THEN
    RAISE EXCEPTION 'forbidden_not_owner';
  END IF;
  UPDATE public.enrollment_requests
     SET assigned_to_admin_id = NULL
   WHERE id = p_lead_id;
END;
$$;
GRANT EXECUTE ON FUNCTION public.crm_unassign_lead(uuid) TO authenticated;

-- Schedule followup : planifier la prochaine relance
CREATE OR REPLACE FUNCTION public.crm_schedule_followup(
  p_lead_id uuid,
  p_followup_at timestamptz
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'forbidden';
  END IF;
  UPDATE public.enrollment_requests
     SET next_followup_at = p_followup_at,
         snoozed_until = NULL  -- une relance plannifiée annule le snooze
   WHERE id = p_lead_id;
END;
$$;
GRANT EXECUTE ON FUNCTION public.crm_schedule_followup(uuid, timestamptz) TO authenticated;

-- Snooze : reporter un lead à plus tard
CREATE OR REPLACE FUNCTION public.crm_snooze_lead(
  p_lead_id uuid,
  p_until timestamptz
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'forbidden';
  END IF;
  UPDATE public.enrollment_requests
     SET snoozed_until = p_until
   WHERE id = p_lead_id;
END;
$$;
GRANT EXECUTE ON FUNCTION public.crm_snooze_lead(uuid, timestamptz) TO authenticated;
