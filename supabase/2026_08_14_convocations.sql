-- =====================================================================
-- 2026-08-14 — Module « Convocations PDF » (candidats + jurys)
-- =====================================================================
-- Deux tables :
--   convocation_locations : lieux d'examen réutilisables (centre, salle,
--     accès), avec le centre de Meaux en seed.
--   convocations : historique des convocations générées (statuts,
--     snapshot complet du contenu en jsonb pour régénérer le PDF à
--     l'identique même si les données sources évoluent).
-- Accès : staff uniquement (is_admin()), aucune exposition stagiaire.
-- Idempotent.
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.convocation_locations (
  id          uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  name        text NOT NULL,
  address     text NOT NULL,
  postal_code text NOT NULL,
  city        text NOT NULL,
  room        text,
  floor       text,
  access_info text,
  created_by  uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.convocations (
  id              uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  kind            text NOT NULL CHECK (kind IN ('candidat', 'jury')),
  status          text NOT NULL DEFAULT 'brouillon'
                  CHECK (status IN ('brouillon','generee','envoyee','confirmee','annulee','modifiee')),
  reference       text NOT NULL,
  -- Snapshot complet du document (destinataire, épreuve, horaires, lieu,
  -- consignes, template...) : la source de vérité du PDF.
  payload         jsonb NOT NULL,
  template        text NOT NULL DEFAULT 'moderne'
                  CHECK (template IN ('classique','moderne','compact')),
  file_name       text NOT NULL,
  -- Rattachements optionnels pour les filtres de l'historique
  related_user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  formation_id    uuid REFERENCES public.formations(id) ON DELETE SET NULL,
  session_label   text,
  exam_date       date,
  batch_id        uuid,
  created_by      uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS convocations_created_at_idx ON public.convocations (created_at DESC);
CREATE INDEX IF NOT EXISTS convocations_kind_status_idx ON public.convocations (kind, status);
CREATE INDEX IF NOT EXISTS convocations_batch_idx ON public.convocations (batch_id) WHERE batch_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS convocations_related_user_idx ON public.convocations (related_user_id);
CREATE INDEX IF NOT EXISTS convocations_formation_idx ON public.convocations (formation_id);

ALTER TABLE public.convocation_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.convocations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS convocation_locations_staff ON public.convocation_locations;
CREATE POLICY convocation_locations_staff ON public.convocation_locations
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS convocations_staff ON public.convocations;
CREATE POLICY convocations_staff ON public.convocations
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Seed : le centre de Meaux (aucun doublon si relancé)
INSERT INTO public.convocation_locations (name, address, postal_code, city, access_info)
SELECT 'MA FORMATION TRANSPORT — Centre de Meaux', '39 avenue des Sablons Bouillants', '77100', 'MEAUX',
       'Accueil au rez-de-chaussée. Se présenter muni de la convocation.'
WHERE NOT EXISTS (
  SELECT 1 FROM public.convocation_locations WHERE city = 'MEAUX' AND postal_code = '77100'
);

-- ── Vérifications post-application ───────────────────────────────────
-- SELECT count(*) FROM public.convocation_locations;  → 1 (seed Meaux)
-- SELECT count(*) FROM public.convocations;           → 0
