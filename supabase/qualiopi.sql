-- ============================================================
-- Qualiopi : preuves complémentaires
--   - formation_settings : paramètres du programme de formation (1 seule ligne)
--   - satisfaction_surveys : évaluations à chaud & à froid
-- ============================================================

-- ------------------------------------------------------------
-- 1. Formation settings (singleton)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.formation_settings (
  id boolean PRIMARY KEY DEFAULT true CHECK (id),  -- singleton row
  -- Identité organisme
  organisme_nom text NOT NULL DEFAULT 'MA FORMATION TRANSPORT',
  organisme_siret text,
  organisme_num_da text,       -- numéro de déclaration d'activité
  organisme_adresse text,
  organisme_email text,
  organisme_telephone text,
  organisme_responsable text,  -- nom du responsable pédagogique

  -- Programme
  formation_titre text NOT NULL DEFAULT 'Titre professionnel Gestionnaire des Opérations de Transport Routier de Marchandises',
  formation_rncp text NOT NULL DEFAULT 'RNCP 40990',
  formation_duree_h integer NOT NULL DEFAULT 700,
  formation_public text DEFAULT 'Demandeurs d''emploi, salariés en reconversion, personnes souhaitant accéder au métier de gestionnaire de transport.',
  formation_prerequis text DEFAULT 'Niveau baccalauréat ou équivalent. Maîtrise du français écrit et oral.',
  formation_objectifs text DEFAULT E'- Organiser et planifier des opérations de transport routier de marchandises\n- Gérer l''exploitation d''une unité de transport\n- Concevoir et commercialiser des solutions de transport\n- Piloter la performance économique et sociale d''une unité',
  formation_methodes text DEFAULT E'- Formation 100% à distance (e-learning asynchrone)\n- Leçons interactives, quiz d''entraînement, examens blancs\n- Accompagnement pédagogique et suivi personnalisé\n- Plateforme accessible 24h/24 et 7j/7',
  formation_evaluation text DEFAULT E'- Évaluations formatives tout au long du parcours (quiz par leçon)\n- Examens blancs en conditions réelles\n- Évaluation à chaud et à froid de la satisfaction\n- Épreuves officielles du titre professionnel devant un jury (hors plateforme)',
  formation_handicap text DEFAULT 'Les personnes en situation de handicap sont invitées à contacter notre référent handicap afin d''étudier les adaptations nécessaires au bon déroulement de la formation.',
  formation_referent_handicap text,
  formation_tarif text,
  formation_delai_acces text DEFAULT '7 jours ouvrés entre la demande d''inscription et l''entrée en formation.',

  -- Indicateurs
  indicateur_satisfaction numeric(4,2),  -- ex: 4.2
  indicateur_reussite numeric(5,2),      -- ex: 85.50

  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by uuid REFERENCES auth.users(id)
);

-- Seed : une ligne par défaut
INSERT INTO public.formation_settings (id) VALUES (true)
ON CONFLICT (id) DO NOTHING;

ALTER TABLE public.formation_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS fs_read ON public.formation_settings;
CREATE POLICY fs_read ON public.formation_settings
  FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS fs_write ON public.formation_settings;
CREATE POLICY fs_write ON public.formation_settings
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());


-- ------------------------------------------------------------
-- 2. Enquêtes de satisfaction
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.satisfaction_surveys (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('chaud', 'froid')),
  -- Notes sur 5
  note_globale integer CHECK (note_globale BETWEEN 1 AND 5),
  note_contenu integer CHECK (note_contenu BETWEEN 1 AND 5),
  note_pedagogie integer CHECK (note_pedagogie BETWEEN 1 AND 5),
  note_plateforme integer CHECK (note_plateforme BETWEEN 1 AND 5),
  note_accompagnement integer CHECK (note_accompagnement BETWEEN 1 AND 5),
  -- Commentaires libres
  points_forts text,
  points_ameliorer text,
  recommandation integer CHECK (recommandation BETWEEN 0 AND 10),  -- NPS
  -- Spécifique à froid (insertion pro)
  situation_pro text,  -- 'emploi' | 'formation' | 'recherche' | 'autre'
  situation_detail text,
  submitted_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, type)
);

CREATE INDEX IF NOT EXISTS ss_user_idx ON public.satisfaction_surveys(user_id);
CREATE INDEX IF NOT EXISTS ss_type_idx ON public.satisfaction_surveys(type);

ALTER TABLE public.satisfaction_surveys ENABLE ROW LEVEL SECURITY;

-- Stagiaire : voir et soumettre sa propre enquête
DROP POLICY IF EXISTS ss_own_read ON public.satisfaction_surveys;
CREATE POLICY ss_own_read ON public.satisfaction_surveys
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS ss_own_insert ON public.satisfaction_surveys;
CREATE POLICY ss_own_insert ON public.satisfaction_surveys
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- Pas de update/delete stagiaire : une enquête = immuable (preuve Qualiopi)

-- Admin : lecture seule globale (pas d'altération des preuves)
DROP POLICY IF EXISTS ss_admin_read ON public.satisfaction_surveys;
CREATE POLICY ss_admin_read ON public.satisfaction_surveys
  FOR SELECT USING (public.is_admin());

-- ------------------------------------------------------------
-- 3. Vue agrégée enquêtes (pour dashboard admin)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW public.survey_stats AS
SELECT
  type,
  count(*) AS total,
  round(avg(note_globale)::numeric, 2) AS avg_globale,
  round(avg(note_contenu)::numeric, 2) AS avg_contenu,
  round(avg(note_pedagogie)::numeric, 2) AS avg_pedagogie,
  round(avg(note_plateforme)::numeric, 2) AS avg_plateforme,
  round(avg(note_accompagnement)::numeric, 2) AS avg_accompagnement,
  round(avg(recommandation)::numeric, 2) AS avg_nps
FROM public.satisfaction_surveys
GROUP BY type;

GRANT SELECT ON public.survey_stats TO authenticated;
