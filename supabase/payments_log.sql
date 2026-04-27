-- =====================================================================
-- Journal des paiements Stripe (idempotent — clé sur stripe_session_id)
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.payments_log (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  stripe_session_id text UNIQUE NOT NULL,
  user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  email text,
  plan_id text,
  amount_cents int NOT NULL DEFAULT 0,
  status text NOT NULL CHECK (status IN ('paid','refunded','failed','pending')),
  payload jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS payments_log_user_idx
  ON public.payments_log(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS payments_log_email_idx
  ON public.payments_log(email);

ALTER TABLE public.payments_log ENABLE ROW LEVEL SECURITY;

-- Lecture : admin uniquement (PII + montants)
DROP POLICY IF EXISTS payments_log_admin_read ON public.payments_log;
CREATE POLICY payments_log_admin_read ON public.payments_log
  FOR SELECT USING (public.is_admin());

-- L'utilisateur connecté peut lire SES propres paiements
DROP POLICY IF EXISTS payments_log_self_read ON public.payments_log;
CREATE POLICY payments_log_self_read ON public.payments_log
  FOR SELECT USING (auth.uid() = user_id);
