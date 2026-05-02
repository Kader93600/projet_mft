-- =====================================================================
-- MIGRATION — champs étendus sur profiles pour la création stagiaire
-- par admin / super-admin.
--
-- Ajoute les informations personnelles, pédagogiques et administratives
-- nécessaires à un dossier stagiaire complet (Qualiopi).
--
-- Idempotent : ALTER TABLE ... ADD COLUMN IF NOT EXISTS.
-- =====================================================================

-- ─── Informations personnelles ───────────────────────────────────────
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS date_naissance date,
  ADD COLUMN IF NOT EXISTS adresse text,
  ADD COLUMN IF NOT EXISTS code_postal text,
  ADD COLUMN IF NOT EXISTS ville text,
  ADD COLUMN IF NOT EXISTS pays text DEFAULT 'France';

-- ─── Informations pédagogiques (rappel : referent_id existe déjà) ───
-- formateur principal assigné au stagiaire
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS trainer_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  -- Date d'entrée en formation (différente de la création de compte)
  ADD COLUMN IF NOT EXISTS entry_date date,
  -- Statut administratif du dossier (info libre, à structurer si besoin)
  ADD COLUMN IF NOT EXISTS dossier_status text;

-- ─── Index utiles pour les recherches admin ─────────────────────────
CREATE INDEX IF NOT EXISTS profiles_trainer_idx
  ON public.profiles(trainer_id) WHERE trainer_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS profiles_referent_idx
  ON public.profiles(referent_id) WHERE referent_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS profiles_ville_idx
  ON public.profiles(ville);
