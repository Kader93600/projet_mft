-- =====================================================================
-- GOTRM Academy — Point #16 : Inscription, paiement, CPF, financeur
-- =====================================================================

-- 1. Financeurs (OPCO, CPF/MonCompteFormation, employeur, auto-financé) --
CREATE TABLE IF NOT EXISTS public.funders (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  kind text NOT NULL CHECK (kind IN ('opco','cpf','employeur','pole_emploi','auto','autre')),
  contact_email text,
  contact_phone text,
  siret text,
  portal_user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.funders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS funders_admin ON public.funders;
CREATE POLICY funders_admin ON public.funders
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS funders_portal_read ON public.funders;
CREATE POLICY funders_portal_read ON public.funders
  FOR SELECT USING (auth.uid() = portal_user_id);

-- 2. Inscriptions ------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.enrollments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  funder_id uuid REFERENCES public.funders(id) ON DELETE SET NULL,
  funding_kind text NOT NULL DEFAULT 'auto'
    CHECK (funding_kind IN ('opco','cpf','employeur','pole_emploi','auto','autre')),
  session_label text,
  start_date date,
  end_date date,
  total_amount_cents int NOT NULL DEFAULT 0,
  paid_amount_cents int NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'prospect'
    CHECK (status IN ('prospect','devis','accord_financeur','a_payer','en_cours','termine','abandon','refuse')),
  contract_url text,
  convention_url text,
  cpf_dossier_ref text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, session_label)
);

CREATE INDEX IF NOT EXISTS enrollments_user_idx ON public.enrollments(user_id);
CREATE INDEX IF NOT EXISTS enrollments_funder_idx ON public.enrollments(funder_id);
CREATE INDEX IF NOT EXISTS enrollments_status_idx ON public.enrollments(status);

ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS enrollments_self ON public.enrollments;
CREATE POLICY enrollments_self ON public.enrollments
  FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS enrollments_admin ON public.enrollments;
CREATE POLICY enrollments_admin ON public.enrollments
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Financeur voit les inscriptions qu'il finance
DROP POLICY IF EXISTS enrollments_funder_read ON public.enrollments;
CREATE POLICY enrollments_funder_read ON public.enrollments
  FOR SELECT USING (
    funder_id IN (SELECT id FROM public.funders WHERE portal_user_id = auth.uid())
  );

CREATE OR REPLACE FUNCTION public.tg_enrollment_touch()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END $$;

DROP TRIGGER IF EXISTS tg_enrollments_updated_at ON public.enrollments;
CREATE TRIGGER tg_enrollments_updated_at
  BEFORE UPDATE ON public.enrollments
  FOR EACH ROW EXECUTE FUNCTION public.tg_enrollment_touch();

-- 3. Échéances / paiements --------------------------------------------
CREATE TABLE IF NOT EXISTS public.payment_schedule (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  enrollment_id uuid NOT NULL REFERENCES public.enrollments(id) ON DELETE CASCADE,
  due_date date NOT NULL,
  amount_cents int NOT NULL,
  paid_at timestamptz,
  paid_amount_cents int DEFAULT 0,
  method text CHECK (method IN ('virement','carte','prelevement','cpf','opco','autre')),
  reference text,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS payment_schedule_enrollment_idx
  ON public.payment_schedule(enrollment_id);

ALTER TABLE public.payment_schedule ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS payment_schedule_read ON public.payment_schedule;
CREATE POLICY payment_schedule_read ON public.payment_schedule
  FOR SELECT USING (
    public.is_admin()
    OR enrollment_id IN (SELECT id FROM public.enrollments WHERE user_id = auth.uid())
    OR enrollment_id IN (
      SELECT e.id FROM public.enrollments e
      JOIN public.funders f ON f.id = e.funder_id
      WHERE f.portal_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS payment_schedule_admin ON public.payment_schedule;
CREATE POLICY payment_schedule_admin ON public.payment_schedule
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- 4. Demandes d'inscription (leads avant création du compte admin) ---
CREATE TABLE IF NOT EXISTS public.enrollment_requests (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  full_name text NOT NULL,
  email text NOT NULL,
  phone text,
  funding_kind text NOT NULL CHECK (funding_kind IN ('opco','cpf','employeur','pole_emploi','auto','autre')),
  message text,
  status text NOT NULL DEFAULT 'nouveau'
    CHECK (status IN ('nouveau','contacte','devis_envoye','inscrit','refuse')),
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.enrollment_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS enroll_req_self ON public.enrollment_requests;
CREATE POLICY enroll_req_self ON public.enrollment_requests
  FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS enroll_req_insert ON public.enrollment_requests;
CREATE POLICY enroll_req_insert ON public.enrollment_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id OR auth.uid() IS NULL);

DROP POLICY IF EXISTS enroll_req_admin ON public.enrollment_requests;
CREATE POLICY enroll_req_admin ON public.enrollment_requests
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- 5. Vue synthèse financeur -------------------------------------------
CREATE OR REPLACE VIEW public.funder_overview AS
SELECT
  f.id AS funder_id,
  f.name AS funder_name,
  f.portal_user_id,
  count(DISTINCT e.id)::int AS enrollments_total,
  count(DISTINCT e.id) FILTER (WHERE e.status = 'en_cours')::int AS enrollments_active,
  count(DISTINCT e.id) FILTER (WHERE e.status = 'termine')::int AS enrollments_done,
  COALESCE(sum(e.total_amount_cents), 0)::int AS budget_total_cents,
  COALESCE(sum(e.paid_amount_cents), 0)::int AS budget_paid_cents
FROM public.funders f
LEFT JOIN public.enrollments e ON e.funder_id = f.id
GROUP BY f.id;

GRANT SELECT ON public.funder_overview TO authenticated;

-- 6. Trigger : tenir à jour paid_amount_cents ------------------------
CREATE OR REPLACE FUNCTION public.tg_enrollment_paid_rollup()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE eid uuid;
BEGIN
  eid := COALESCE(NEW.enrollment_id, OLD.enrollment_id);
  UPDATE public.enrollments
     SET paid_amount_cents = (
       SELECT COALESCE(sum(paid_amount_cents), 0)
       FROM public.payment_schedule
       WHERE enrollment_id = eid AND paid_at IS NOT NULL
     )
   WHERE id = eid;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_payment_rollup ON public.payment_schedule;
CREATE TRIGGER tg_payment_rollup
  AFTER INSERT OR UPDATE OR DELETE ON public.payment_schedule
  FOR EACH ROW EXECUTE FUNCTION public.tg_enrollment_paid_rollup();
