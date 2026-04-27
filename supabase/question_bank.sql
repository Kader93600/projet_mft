-- =====================================================================
-- Banque de questions multi-formations (QCM + QR rédigées)
--
-- Architecture : un POOL de questions rattachées à formation_id + module_id
-- (optionnel). Les quiz sont des SÉLECTIONS de cette banque (statiques ou
-- dynamiques). Évite la duplication, permet la rotation, infinité d'examens
-- blancs et statistiques fines par question.
--
-- Compatible avec la table `questions` existante (qui restera liée aux
-- quiz historiques). À terme, on migrera tout vers la banque.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Table question_bank
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.question_bank (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  formation_id uuid REFERENCES public.formations(id) ON DELETE CASCADE,
  module_id    uuid REFERENCES public.modules(id) ON DELETE SET NULL,

  -- 'qcm' = choix multiples (correction auto)
  -- 'qr'  = question rédigée (correction manuelle par formateur)
  type text NOT NULL CHECK (type IN ('qcm', 'qr')),

  statement text NOT NULL,
  -- Pour QCM uniquement : tableau JSON [{id, label, is_correct}, ...]
  choices jsonb,
  -- Pour QR : réponse-modèle / éléments attendus (visible formateur uniquement)
  expected_answer text,
  -- Pour QR : barème détaillé (ex. "Définition 2pts + exemple 1pt + 2 conditions 2pts")
  scoring_grid text,
  max_score numeric NOT NULL DEFAULT 1,

  difficulty text NOT NULL DEFAULT 'moyen'
    CHECK (difficulty IN ('facile', 'moyen', 'difficile')),
  tags text[] NOT NULL DEFAULT '{}',
  explanation text,

  -- Traçabilité de l'origine (PDF, livre, etc.) — non visible stagiaire
  source_ref text,
  -- A-t-on retravaillé l'énoncé pour éviter le copier-coller brut ?
  reformulated_at timestamptz,
  reformulated_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,

  active boolean NOT NULL DEFAULT true,

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS question_bank_formation_idx
  ON public.question_bank(formation_id);
CREATE INDEX IF NOT EXISTS question_bank_module_idx
  ON public.question_bank(module_id);
CREATE INDEX IF NOT EXISTS question_bank_type_idx
  ON public.question_bank(type);
CREATE INDEX IF NOT EXISTS question_bank_difficulty_idx
  ON public.question_bank(difficulty);
CREATE INDEX IF NOT EXISTS question_bank_tags_gin
  ON public.question_bank USING GIN (tags);
CREATE INDEX IF NOT EXISTS question_bank_active_idx
  ON public.question_bank(active) WHERE active = true;

-- Recherche plein texte sur l'énoncé
CREATE INDEX IF NOT EXISTS question_bank_statement_trgm
  ON public.question_bank USING GIN (statement gin_trgm_ops);

ALTER TABLE public.question_bank ENABLE ROW LEVEL SECURITY;

-- Lecture stagiaire : seulement les questions des formations où il est inscrit
DROP POLICY IF EXISTS qbank_student_read ON public.question_bank;
CREATE POLICY qbank_student_read ON public.question_bank
  FOR SELECT USING (
    active = true
    AND formation_id IS NOT NULL
    AND EXISTS (
      SELECT 1 FROM public.formations f
      WHERE f.id = question_bank.formation_id
        AND public.has_formation_access(auth.uid(), f.slug)
    )
  );

-- Lecture staff : tout
DROP POLICY IF EXISTS qbank_admin_read ON public.question_bank;
CREATE POLICY qbank_admin_read ON public.question_bank
  FOR SELECT USING (public.is_admin());

-- Écriture : staff uniquement
DROP POLICY IF EXISTS qbank_admin_write ON public.question_bank;
CREATE POLICY qbank_admin_write ON public.question_bank
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------------
-- 2) Lien quiz ↔ banque (sélection statique ou dynamique)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.quiz_question_bank (
  quiz_id uuid NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
  question_id uuid NOT NULL REFERENCES public.question_bank(id) ON DELETE CASCADE,
  display_order int NOT NULL DEFAULT 100,
  PRIMARY KEY (quiz_id, question_id)
);

CREATE INDEX IF NOT EXISTS quiz_question_bank_quiz_idx
  ON public.quiz_question_bank(quiz_id);
CREATE INDEX IF NOT EXISTS quiz_question_bank_question_idx
  ON public.quiz_question_bank(question_id);

ALTER TABLE public.quiz_question_bank ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS qqb_read ON public.quiz_question_bank;
CREATE POLICY qqb_read ON public.quiz_question_bank
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS qqb_admin_write ON public.quiz_question_bank;
CREATE POLICY qqb_admin_write ON public.quiz_question_bank
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ---------------------------------------------------------------------
-- 3) Configuration de génération aléatoire (examens blancs dynamiques)
-- ---------------------------------------------------------------------
ALTER TABLE public.quizzes
  ADD COLUMN IF NOT EXISTS generation_mode text NOT NULL DEFAULT 'static'
    CHECK (generation_mode IN ('static', 'random_from_bank')),
  ADD COLUMN IF NOT EXISTS bank_filters jsonb,
  -- Ex. {"formation_id":"...","modules":["m1","m2"],"difficulties":["moyen","difficile"],"qcm_count":40,"qr_count":2}
  ADD COLUMN IF NOT EXISTS requires_manual_grading boolean NOT NULL DEFAULT false;

-- Quand un quiz contient des QR, requires_manual_grading = true
-- Sera mis à jour par trigger lorsqu'on lie une QR à un quiz.

-- ---------------------------------------------------------------------
-- 4) Trigger : maj requires_manual_grading
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tg_quiz_check_manual_grading()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  has_qr boolean;
BEGIN
  -- Considère le quiz_id selon l'opération
  SELECT EXISTS (
    SELECT 1
    FROM public.quiz_question_bank qqb
    JOIN public.question_bank q ON q.id = qqb.question_id
    WHERE qqb.quiz_id = COALESCE(NEW.quiz_id, OLD.quiz_id)
      AND q.type = 'qr'
  ) INTO has_qr;

  UPDATE public.quizzes
  SET requires_manual_grading = has_qr
  WHERE id = COALESCE(NEW.quiz_id, OLD.quiz_id);

  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS tg_qqb_manual_grading_aiu
  ON public.quiz_question_bank;
CREATE TRIGGER tg_qqb_manual_grading_aiu
  AFTER INSERT OR UPDATE OR DELETE ON public.quiz_question_bank
  FOR EACH ROW EXECUTE FUNCTION public.tg_quiz_check_manual_grading();

-- ---------------------------------------------------------------------
-- 5) RPC : génération dynamique d'un examen blanc à partir des filtres
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.generate_random_exam(
  p_formation_slug text,
  p_qcm_count int DEFAULT 40,
  p_qr_count int DEFAULT 0,
  p_difficulty text[] DEFAULT NULL,
  p_module_ids uuid[] DEFAULT NULL
)
RETURNS TABLE (id uuid, type text, statement text)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  formation_uuid uuid;
BEGIN
  IF NOT public.has_formation_access(auth.uid(), p_formation_slug) THEN
    RAISE EXCEPTION 'forbidden_formation';
  END IF;

  SELECT f.id INTO formation_uuid
  FROM public.formations f
  WHERE f.slug = p_formation_slug;

  RETURN QUERY (
    -- QCM
    SELECT q.id, q.type, q.statement
    FROM public.question_bank q
    WHERE q.formation_id = formation_uuid
      AND q.type = 'qcm'
      AND q.active = true
      AND (p_difficulty IS NULL OR q.difficulty = ANY(p_difficulty))
      AND (p_module_ids IS NULL OR q.module_id = ANY(p_module_ids))
    ORDER BY random()
    LIMIT p_qcm_count
  )
  UNION ALL
  (
    -- QR
    SELECT q.id, q.type, q.statement
    FROM public.question_bank q
    WHERE q.formation_id = formation_uuid
      AND q.type = 'qr'
      AND q.active = true
      AND (p_difficulty IS NULL OR q.difficulty = ANY(p_difficulty))
      AND (p_module_ids IS NULL OR q.module_id = ANY(p_module_ids))
    ORDER BY random()
    LIMIT p_qr_count
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.generate_random_exam(text, int, int, text[], uuid[])
  TO authenticated;
