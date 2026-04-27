-- =====================================================================
-- Multi-formations v2 — modèle de données.
--
-- Architecture :
--   formations           ← catalogue en BDD (mirror du config TS)
--   formation_modules    ← N-N : un module peut servir plusieurs formations
--   formation_quizzes    ← idem pour quiz
--   trainer_formations   ← habilitations formateur (avec capacités fines)
--   enrollments          ← +formation_id (FK propre, en plus du slug)
--
-- À jouer APRÈS permissions_v2_step1.sql + permissions_v2_step2.sql.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Catalogue des formations
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.formations (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug text UNIQUE NOT NULL,
  code text NOT NULL,
  title text NOT NULL,
  tagline text,
  category text NOT NULL CHECK (category IN
    ('marchandises','voyageurs','enseignement','capacite','autre')),
  level int CHECK (level BETWEEN 3 AND 6),
  rncp_code text,
  duration text,
  modality text CHECK (modality IN ('presentiel','distanciel','mixte')),
  active boolean NOT NULL DEFAULT true,
  display_order int NOT NULL DEFAULT 100,
  accent_color text,
  icon_name text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS formations_slug_idx ON public.formations(slug);
CREATE INDEX IF NOT EXISTS formations_category_idx ON public.formations(category);

ALTER TABLE public.formations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS formations_read_all ON public.formations;
CREATE POLICY formations_read_all ON public.formations
  FOR SELECT USING (true);  -- catalogue public

DROP POLICY IF EXISTS formations_admin_write ON public.formations;
CREATE POLICY formations_admin_write ON public.formations
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------------
-- 2) Jointure formation × modules (N-N)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.formation_modules (
  formation_id uuid NOT NULL REFERENCES public.formations(id) ON DELETE CASCADE,
  module_id    uuid NOT NULL REFERENCES public.modules(id) ON DELETE CASCADE,
  display_order int NOT NULL DEFAULT 100,
  required boolean NOT NULL DEFAULT true,
  PRIMARY KEY (formation_id, module_id)
);

CREATE INDEX IF NOT EXISTS formation_modules_formation_idx
  ON public.formation_modules(formation_id);
CREATE INDEX IF NOT EXISTS formation_modules_module_idx
  ON public.formation_modules(module_id);

ALTER TABLE public.formation_modules ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS formation_modules_read ON public.formation_modules;
CREATE POLICY formation_modules_read ON public.formation_modules
  FOR SELECT USING (
    -- Tout user authentifié peut voir le mapping (lecture seule)
    auth.role() = 'authenticated'
  );

DROP POLICY IF EXISTS formation_modules_admin_write ON public.formation_modules;
CREATE POLICY formation_modules_admin_write ON public.formation_modules
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------------
-- 3) Jointure formation × quiz (N-N)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.formation_quizzes (
  formation_id uuid NOT NULL REFERENCES public.formations(id) ON DELETE CASCADE,
  quiz_id      uuid NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
  is_mock_exam boolean NOT NULL DEFAULT false,
  display_order int NOT NULL DEFAULT 100,
  PRIMARY KEY (formation_id, quiz_id)
);

CREATE INDEX IF NOT EXISTS formation_quizzes_formation_idx
  ON public.formation_quizzes(formation_id);
CREATE INDEX IF NOT EXISTS formation_quizzes_quiz_idx
  ON public.formation_quizzes(quiz_id);

ALTER TABLE public.formation_quizzes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS formation_quizzes_read ON public.formation_quizzes;
CREATE POLICY formation_quizzes_read ON public.formation_quizzes
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS formation_quizzes_admin_write ON public.formation_quizzes;
CREATE POLICY formation_quizzes_admin_write ON public.formation_quizzes
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------------
-- 4) Habilitations formateurs ↔ formations
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.trainer_formations (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  trainer_id   uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  formation_id uuid NOT NULL REFERENCES public.formations(id) ON DELETE CASCADE,
  -- Capacités fines : permet d'avoir des formateurs "lecture seule" vs
  -- des formateurs "auteurs" qui peuvent éditer les contenus.
  can_grade        boolean NOT NULL DEFAULT true,
  can_edit_content boolean NOT NULL DEFAULT false,
  is_lead          boolean NOT NULL DEFAULT false,
  granted_at  timestamptz NOT NULL DEFAULT now(),
  granted_by  uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  UNIQUE (trainer_id, formation_id)
);

CREATE INDEX IF NOT EXISTS trainer_formations_trainer_idx
  ON public.trainer_formations(trainer_id);
CREATE INDEX IF NOT EXISTS trainer_formations_formation_idx
  ON public.trainer_formations(formation_id);

ALTER TABLE public.trainer_formations ENABLE ROW LEVEL SECURITY;

-- Lecture : le formateur voit ses propres habilitations, le staff voit tout
DROP POLICY IF EXISTS trainer_formations_read ON public.trainer_formations;
CREATE POLICY trainer_formations_read ON public.trainer_formations
  FOR SELECT USING (
    auth.uid() = trainer_id OR public.is_admin()
  );

-- Écriture : staff uniquement
DROP POLICY IF EXISTS trainer_formations_admin_write ON public.trainer_formations;
CREATE POLICY trainer_formations_admin_write ON public.trainer_formations
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------------
-- 5) FK propre sur enrollments (en plus du slug existant)
-- ---------------------------------------------------------------------
ALTER TABLE public.enrollments
  ADD COLUMN IF NOT EXISTS formation_id uuid REFERENCES public.formations(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS enrollments_formation_id_idx
  ON public.enrollments(formation_id);

-- Trigger : si formation_slug est posé, peupler formation_id automatiquement
CREATE OR REPLACE FUNCTION public.tg_enrollment_resolve_formation()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.formation_slug IS NOT NULL AND NEW.formation_id IS NULL THEN
    SELECT id INTO NEW.formation_id
    FROM public.formations
    WHERE slug = NEW.formation_slug;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_enrollment_resolve_formation
  ON public.enrollments;
CREATE TRIGGER tg_enrollment_resolve_formation
  BEFORE INSERT OR UPDATE OF formation_slug ON public.enrollments
  FOR EACH ROW EXECUTE FUNCTION public.tg_enrollment_resolve_formation();

-- ---------------------------------------------------------------------
-- 6) Vues d'aide
-- ---------------------------------------------------------------------

-- Vue : formations habilitées d'un formateur (avec ses stats)
CREATE OR REPLACE VIEW public.trainer_formation_overview AS
SELECT
  tf.trainer_id,
  f.id            AS formation_id,
  f.slug,
  f.code,
  f.title,
  f.category,
  tf.is_lead,
  tf.can_grade,
  tf.can_edit_content,
  (SELECT count(*) FROM public.enrollments e
    WHERE e.formation_id = f.id
      AND e.status IN ('a_payer','en_cours','accord_financeur')) AS active_students
FROM public.trainer_formations tf
JOIN public.formations f ON f.id = tf.formation_id;

GRANT SELECT ON public.trainer_formation_overview TO authenticated;

-- ---------------------------------------------------------------------
-- 7) SEED — les 8 formations du catalogue marketing
-- ---------------------------------------------------------------------
-- Idempotent : ON CONFLICT (slug) DO UPDATE pour repropager les
-- évolutions du catalogue marketing dans la BDD.

INSERT INTO public.formations
  (slug, code, title, tagline, category, level, rncp_code, duration, modality, accent_color, icon_name, display_order)
VALUES
  ('gotrm', 'GOTRM',
   'Gestionnaire des Opérations de Transport Routier de Marchandises',
   'Le titre pro de référence pour piloter une activité transport marchandises.',
   'marchandises', 5, 'RNCP 40990',
   '8 à 16 semaines selon formule', 'mixte',
   '#9FE220', 'Truck', 10),
  ('ertv', 'ERTV',
   'Exploitant en Régulation du Transport de Voyageurs',
   'Pilotez les opérations de transport de personnes en autocar et urbain.',
   'voyageurs', 4, NULL,
   '12 semaines', 'mixte',
   '#5C6AF2', 'Bus', 20),
  ('ecsr', 'ECSR',
   'Enseignant de la Conduite et de la Sécurité Routière',
   'Devenez moniteur d''auto-école et formateur agréé.',
   'enseignement', 5, NULL,
   '8 à 12 mois', 'presentiel',
   '#3845E5', 'GraduationCap', 30),
  ('fimo-fco', 'FIMO / FCO',
   'FIMO Marchandises & FCO obligatoire',
   'Formation initiale et continue obligatoires pour les conducteurs pros.',
   'marchandises', NULL, NULL,
   'FIMO : 140 h · FCO : 35 h tous les 5 ans', 'presentiel',
   '#A8D729', 'Truck', 40),
  ('taxi-vtc', 'Taxi & VTC',
   'Préparation aux examens Taxi et VTC',
   'Obtenez votre carte professionnelle Taxi ou VTC.',
   'voyageurs', NULL, NULL,
   '150 à 250 h selon formule', 'mixte',
   '#F59E0B', 'Car', 50),
  ('commissionnaire', 'Commissionnaire',
   'Préparation à l''examen national Commissionnaire de transport',
   'L''attestation pour exercer en tant qu''organisateur de transport.',
   'marchandises', NULL, NULL,
   '8 semaines intensives', 'mixte',
   '#7EBE17', 'Briefcase', 60),
  ('capacite-3-5t', 'Capacité ≤ 3,5 t',
   'Attestation de capacité professionnelle — véhicules ≤ 3,5 t',
   'Créez votre entreprise de transport léger en toute conformité.',
   'capacite', NULL, NULL,
   '105 h', 'mixte',
   '#BEE74E', 'Package', 70),
  ('capacite-plus-3-5t', 'Capacité > 3,5 t',
   'Capacité de transport > 3,5 t — Préparation à l''examen national',
   'L''attestation indispensable pour gérer une entreprise de transport lourd.',
   'capacite', NULL, NULL,
   '12 semaines (105 h théorie + 35 h pratique)', 'mixte',
   '#2530D9', 'ShieldCheck', 80)
ON CONFLICT (slug) DO UPDATE SET
  code            = EXCLUDED.code,
  title           = EXCLUDED.title,
  tagline         = EXCLUDED.tagline,
  category        = EXCLUDED.category,
  level           = EXCLUDED.level,
  rncp_code       = EXCLUDED.rncp_code,
  duration        = EXCLUDED.duration,
  modality        = EXCLUDED.modality,
  accent_color    = EXCLUDED.accent_color,
  icon_name       = EXCLUDED.icon_name,
  display_order   = EXCLUDED.display_order,
  updated_at      = now();

-- Backfill : pour les enrollments existants qui ont déjà un slug,
-- résoudre la FK formation_id automatiquement.
UPDATE public.enrollments e
   SET formation_id = f.id
  FROM public.formations f
 WHERE e.formation_slug = f.slug
   AND e.formation_id IS NULL;
