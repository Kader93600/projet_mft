-- =====================================================================
-- Espace Formateur — ajout du rôle 'trainer' à l'enum user_role.
-- Helper public.is_trainer() + table d'affectation formateur ↔ stagiaire.
-- =====================================================================

-- 1) Étendre l'enum user_role pour ajouter 'trainer'
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum
    WHERE enumlabel = 'trainer'
      AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'user_role')
  ) THEN
    ALTER TYPE user_role ADD VALUE 'trainer';
  END IF;
END $$;

-- 2) Helper RLS pour vérifier si le user courant est formateur
CREATE OR REPLACE FUNCTION public.is_trainer()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS(
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'trainer'
  );
$$;

-- 3) Affectation formateurs ↔ stagiaires (un formateur peut suivre N stagiaires)
CREATE TABLE IF NOT EXISTS public.trainer_assignments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  trainer_id  uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  student_id  uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role        text NOT NULL DEFAULT 'main' CHECK (role IN ('main','support')),
  formation_slug text,
  assigned_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (trainer_id, student_id)
);

CREATE INDEX IF NOT EXISTS trainer_assignments_trainer_idx
  ON public.trainer_assignments(trainer_id);
CREATE INDEX IF NOT EXISTS trainer_assignments_student_idx
  ON public.trainer_assignments(student_id);

ALTER TABLE public.trainer_assignments ENABLE ROW LEVEL SECURITY;

-- Le formateur voit ses propres affectations ; admin voit tout
DROP POLICY IF EXISTS trainer_assignments_self_read ON public.trainer_assignments;
CREATE POLICY trainer_assignments_self_read ON public.trainer_assignments
  FOR SELECT USING (
    auth.uid() = trainer_id
    OR auth.uid() = student_id
    OR public.is_admin()
  );

-- Seul l'admin peut affecter / retirer
DROP POLICY IF EXISTS trainer_assignments_admin_write ON public.trainer_assignments;
CREATE POLICY trainer_assignments_admin_write ON public.trainer_assignments
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- 4) Vue pratique pour un formateur : ses stagiaires + dernière activité
CREATE OR REPLACE VIEW public.trainer_my_students AS
SELECT
  ta.trainer_id,
  ta.student_id,
  ta.role          AS assignment_role,
  ta.formation_slug,
  p.full_name,
  p.email,
  p.disabled,
  -- dernier événement XP comme proxy d'activité
  (SELECT max(created_at) FROM public.xp_events x
    WHERE x.user_id = p.id) AS last_activity_at,
  -- nb de leçons complétées
  (SELECT count(*) FROM public.lesson_progress lp
    WHERE lp.user_id = p.id AND lp.completed = true) AS lessons_done,
  -- nb de quiz réussis
  (SELECT count(*) FROM public.quiz_attempts qa
    WHERE qa.user_id = p.id AND qa.passed = true) AS quizzes_passed
FROM public.trainer_assignments ta
JOIN public.profiles p ON p.id = ta.student_id;

GRANT SELECT ON public.trainer_my_students TO authenticated;
