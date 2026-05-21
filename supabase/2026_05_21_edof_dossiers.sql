-- =====================================================================
-- 2026-05-21 · Intégration EDOF (Mon Compte Formation / Caisse des Dépôts)
--
-- Tables de SUIVI des dossiers CPF synchronisés depuis EDOF + état de la
-- synchro incrémentale. Inertes tant que l'API EDOF n'est pas branchée
-- (cf. lib/edof/*). RLS : admin uniquement (le service_role bypass pour
-- le cron de synchro).
--
-- Idempotent : rejouable sans risque.
-- =====================================================================

-- 1. Dossiers EDOF -----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.cpf_edof_dossiers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Rattachement à l'inscription MFT (peut être NULL avant réconciliation)
  enrollment_id uuid REFERENCES public.enrollments(id) ON DELETE SET NULL,
  -- Identifiant du dossier côté EDOF (clé d'idempotence de la synchro)
  edof_dossier_id text NOT NULL,
  status text NOT NULL DEFAULT 'recu',
  learner_full_name text,
  learner_email text,
  formation_label text,
  amount_cents integer,
  -- Payload brut EDOF conservé pour audit/debug
  raw jsonb,
  -- Horodatage de la dernière synchro de CE dossier
  last_synced_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT cpf_edof_dossiers_edof_id_unique UNIQUE (edof_dossier_id)
);

CREATE INDEX IF NOT EXISTS idx_cpf_edof_dossiers_enrollment
  ON public.cpf_edof_dossiers (enrollment_id);
CREATE INDEX IF NOT EXISTS idx_cpf_edof_dossiers_status
  ON public.cpf_edof_dossiers (status);

-- 2. État de la synchro (singleton) -----------------------------------
CREATE TABLE IF NOT EXISTS public.edof_sync_state (
  id boolean PRIMARY KEY DEFAULT true,
  -- Curseur incrémental : on ne récupère que les dossiers maj après cette date
  last_pulled_at timestamptz,
  last_run_at timestamptz,
  last_result jsonb,
  CONSTRAINT edof_sync_state_singleton CHECK (id = true)
);

-- 3. Trigger updated_at ------------------------------------------------
CREATE OR REPLACE FUNCTION public.tg_edof_touch()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END $$;

DROP TRIGGER IF EXISTS tg_cpf_edof_dossiers_updated_at ON public.cpf_edof_dossiers;
CREATE TRIGGER tg_cpf_edof_dossiers_updated_at
  BEFORE UPDATE ON public.cpf_edof_dossiers
  FOR EACH ROW EXECUTE FUNCTION public.tg_edof_touch();

-- 4. RLS : admin uniquement -------------------------------------------
ALTER TABLE public.cpf_edof_dossiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.edof_sync_state ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS cpf_edof_dossiers_admin ON public.cpf_edof_dossiers;
CREATE POLICY cpf_edof_dossiers_admin ON public.cpf_edof_dossiers
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS edof_sync_state_admin ON public.edof_sync_state;
CREATE POLICY edof_sync_state_admin ON public.edof_sync_state
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

COMMENT ON TABLE public.cpf_edof_dossiers IS
  'Suivi des dossiers CPF synchronisés depuis EDOF (CDC). Voir lib/edof/.';
