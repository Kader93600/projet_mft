-- =====================================================================
-- P3 #2 / Sprint C — Multi-tenant entreprise (MVP v1)
-- 2026-05-19 (rev. 2026-05-19 — fix ordre de création tables/policies)
--
-- Décision client : 1 facture/stagiaire (Option A) en v1.
-- Donc PAS de Stripe Customer par org, on rattache l'enrollment via
-- enrollments.organization_id (nullable).
--
-- Tables :
--   • organizations : entreprise cliente
--   • organization_members : N-N user × org avec rôle
--
-- Rôles dans l'org :
--   • org_admin   : gère membres + invitations + voit progression
--   • org_viewer  : lecture seule (RH consultatif, sponsor)
--   • org_learner : stagiaire de l'orga (ne voit que sa formation)
--
-- 1 user = 1 orga max (UNIQUE sur organization_members.user_id).
--
-- ⚠️ ORDRE CRITIQUE : on crée d'abord TOUTES les tables, puis seulement
-- on ajoute les policies RLS (parce que certaines policies se référencent
-- mutuellement entre organizations et organization_members).
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- BLOC 1 — Création des tables (sans policies)
-- ─────────────────────────────────────────────────────────────────────

-- Table organizations
CREATE TABLE IF NOT EXISTS public.organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  name text NOT NULL,
  legal_name text,
  siret text,
  vat_number text,
  billing_email text NOT NULL,
  billing_address jsonb,
  logo_url text,
  primary_color text,
  contact_full_name text,
  contact_phone text,
  status text NOT NULL DEFAULT 'active'
    CHECK (status IN ('trial', 'active', 'suspended', 'churned')),
  trial_ends_at timestamptz,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS organizations_status_idx ON public.organizations(status);

CREATE OR REPLACE FUNCTION public.tg_organization_touch()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END $$;

DROP TRIGGER IF EXISTS tg_organizations_updated_at ON public.organizations;
CREATE TRIGGER tg_organizations_updated_at
  BEFORE UPDATE ON public.organizations
  FOR EACH ROW EXECUTE FUNCTION public.tg_organization_touch();

-- Table organization_members
CREATE TABLE IF NOT EXISTS public.organization_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role text NOT NULL DEFAULT 'org_learner'
    CHECK (role IN ('org_admin', 'org_viewer', 'org_learner')),
  invited_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  joined_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS organization_members_org_idx
  ON public.organization_members(organization_id, role);
CREATE INDEX IF NOT EXISTS organization_members_user_idx
  ON public.organization_members(user_id);

-- Lien enrollments ↔ organization (ALTER, indépendant des policies)
ALTER TABLE public.enrollments
  ADD COLUMN IF NOT EXISTS organization_id uuid REFERENCES public.organizations(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS seats_reserved boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN public.enrollments.organization_id IS
  'Si cet enrollment a été payé par une entreprise cliente. NULL = paiement individuel.';
COMMENT ON COLUMN public.enrollments.seats_reserved IS
  'TRUE = place réservée par l''orga sans user_id encore assigné.';

CREATE INDEX IF NOT EXISTS enrollments_org_idx
  ON public.enrollments(organization_id)
  WHERE organization_id IS NOT NULL;

-- ─────────────────────────────────────────────────────────────────────
-- BLOC 2 — RLS sur organizations (maintenant que organization_members existe)
-- ─────────────────────────────────────────────────────────────────────

ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS organizations_admin ON public.organizations;
CREATE POLICY organizations_admin ON public.organizations
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Les membres de l'orga peuvent la lire
DROP POLICY IF EXISTS organizations_member_read ON public.organizations;
CREATE POLICY organizations_member_read ON public.organizations
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.organization_members m
      WHERE m.organization_id = organizations.id
        AND m.user_id = auth.uid()
    )
  );

-- ─────────────────────────────────────────────────────────────────────
-- BLOC 3 — RLS sur organization_members
-- ─────────────────────────────────────────────────────────────────────

ALTER TABLE public.organization_members ENABLE ROW LEVEL SECURITY;

-- Admin MFT : tout
DROP POLICY IF EXISTS organization_members_admin ON public.organization_members;
CREATE POLICY organization_members_admin ON public.organization_members
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Org_admin de l'orga : voit + gère les membres de SON orga
-- ATTENTION : la sous-requête référence la même table → on doit
-- utiliser un alias clair pour éviter une boucle infinie.
DROP POLICY IF EXISTS organization_members_org_admin ON public.organization_members;
CREATE POLICY organization_members_org_admin ON public.organization_members
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.organization_members m
      WHERE m.organization_id = organization_members.organization_id
        AND m.user_id = auth.uid()
        AND m.role = 'org_admin'
    )
  ) WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.organization_members m
      WHERE m.organization_id = organization_members.organization_id
        AND m.user_id = auth.uid()
        AND m.role = 'org_admin'
    )
  );

-- Tout membre voit la liste des membres de SON orga
DROP POLICY IF EXISTS organization_members_self_read ON public.organization_members;
CREATE POLICY organization_members_self_read ON public.organization_members
  FOR SELECT USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.organization_members m
      WHERE m.organization_id = organization_members.organization_id
        AND m.user_id = auth.uid()
    )
  );

-- ─────────────────────────────────────────────────────────────────────
-- BLOC 4 — RLS additionnelle sur enrollments (org_admin/viewer)
-- ─────────────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS enrollments_org_admin ON public.enrollments;
CREATE POLICY enrollments_org_admin ON public.enrollments
  FOR SELECT USING (
    organization_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM public.organization_members m
      WHERE m.organization_id = enrollments.organization_id
        AND m.user_id = auth.uid()
        AND m.role IN ('org_admin', 'org_viewer')
    )
  );

-- ─────────────────────────────────────────────────────────────────────
-- BLOC 5 — Vue dashboard orga
-- ─────────────────────────────────────────────────────────────────────

CREATE OR REPLACE VIEW public.organization_dashboard
WITH (security_invoker = on)
AS
SELECT
  o.id AS organization_id,
  o.name,
  o.slug,
  o.status,
  (SELECT count(*)::int FROM public.organization_members m
    WHERE m.organization_id = o.id) AS members_total,
  (SELECT count(*)::int FROM public.organization_members m
    WHERE m.organization_id = o.id AND m.role = 'org_admin') AS admins_count,
  (SELECT count(*)::int FROM public.organization_members m
    WHERE m.organization_id = o.id AND m.role = 'org_learner') AS learners_count,
  (SELECT count(*)::int FROM public.enrollments e
    WHERE e.organization_id = o.id) AS enrollments_total,
  (SELECT count(*)::int FROM public.enrollments e
    WHERE e.organization_id = o.id AND e.status = 'en_cours') AS enrollments_active,
  (SELECT count(*)::int FROM public.enrollments e
    WHERE e.organization_id = o.id AND e.seats_reserved = true) AS seats_pending,
  (SELECT COALESCE(sum(e.total_amount_cents), 0)::int FROM public.enrollments e
    WHERE e.organization_id = o.id) AS total_budget_cents,
  (SELECT COALESCE(sum(e.paid_amount_cents), 0)::int FROM public.enrollments e
    WHERE e.organization_id = o.id) AS total_paid_cents
FROM public.organizations o;

GRANT SELECT ON public.organization_dashboard TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- BLOC 6 — RPCs
-- ─────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.my_organization()
RETURNS TABLE (
  organization_id uuid,
  organization_name text,
  organization_slug text,
  role text,
  joined_at timestamptz
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT o.id, o.name, o.slug, m.role, m.joined_at
  FROM public.organization_members m
  JOIN public.organizations o ON o.id = m.organization_id
  WHERE m.user_id = auth.uid()
  LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.my_organization() TO authenticated;

CREATE OR REPLACE FUNCTION public.admin_create_organization(
  p_name text,
  p_legal_name text,
  p_siret text,
  p_billing_email text,
  p_contact_full_name text,
  p_contact_user_id uuid,
  p_slug text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_org_id uuid;
  v_slug text;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'forbidden';
  END IF;
  IF coalesce(trim(p_name), '') = '' THEN
    RAISE EXCEPTION 'name_required';
  END IF;
  IF coalesce(trim(p_billing_email), '') = '' THEN
    RAISE EXCEPTION 'billing_email_required';
  END IF;

  v_slug := COALESCE(p_slug, lower(regexp_replace(p_name, '[^a-zA-Z0-9]+', '-', 'g')));
  v_slug := trim(both '-' from v_slug);

  INSERT INTO public.organizations (
    slug, name, legal_name, siret, billing_email,
    contact_full_name, status
  )
  VALUES (
    v_slug, p_name, NULLIF(p_legal_name, ''), NULLIF(p_siret, ''),
    p_billing_email, NULLIF(p_contact_full_name, ''), 'active'
  )
  RETURNING id INTO v_org_id;

  IF p_contact_user_id IS NOT NULL THEN
    INSERT INTO public.organization_members (organization_id, user_id, role, invited_by)
    VALUES (v_org_id, p_contact_user_id, 'org_admin', auth.uid())
    ON CONFLICT (user_id) DO NOTHING;
  END IF;

  RETURN v_org_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_create_organization(
  text, text, text, text, text, uuid, text
) TO authenticated;

CREATE OR REPLACE FUNCTION public.add_organization_member(
  p_organization_id uuid,
  p_user_id uuid,
  p_role text DEFAULT 'org_learner'
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_member_id uuid;
  v_is_org_admin boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM public.organization_members
    WHERE organization_id = p_organization_id
      AND user_id = auth.uid()
      AND role = 'org_admin'
  ) INTO v_is_org_admin;

  IF NOT public.is_admin() AND NOT v_is_org_admin THEN
    RAISE EXCEPTION 'forbidden';
  END IF;
  IF p_role NOT IN ('org_admin', 'org_viewer', 'org_learner') THEN
    RAISE EXCEPTION 'invalid_role';
  END IF;

  INSERT INTO public.organization_members (
    organization_id, user_id, role, invited_by
  )
  VALUES (p_organization_id, p_user_id, p_role, auth.uid())
  ON CONFLICT (user_id) DO UPDATE
    SET organization_id = EXCLUDED.organization_id,
        role = EXCLUDED.role,
        invited_by = EXCLUDED.invited_by
  RETURNING id INTO v_member_id;

  RETURN v_member_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.add_organization_member(uuid, uuid, text) TO authenticated;

CREATE OR REPLACE FUNCTION public.remove_organization_member(p_member_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_org_id uuid;
  v_is_org_admin boolean;
BEGIN
  SELECT organization_id INTO v_org_id FROM public.organization_members WHERE id = p_member_id;
  IF v_org_id IS NULL THEN RAISE EXCEPTION 'member_not_found'; END IF;

  SELECT EXISTS (
    SELECT 1 FROM public.organization_members
    WHERE organization_id = v_org_id
      AND user_id = auth.uid()
      AND role = 'org_admin'
  ) INTO v_is_org_admin;

  IF NOT public.is_admin() AND NOT v_is_org_admin THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  DELETE FROM public.organization_members WHERE id = p_member_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.remove_organization_member(uuid) TO authenticated;
