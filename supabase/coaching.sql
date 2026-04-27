-- ============================================================
-- Point #10 — Accompagnement formateur
--   - profiles.referent_id : formateur attribué à chaque stagiaire
--   - coaching_sessions    : rendez-vous individuels
--   - coaching_notes       : notes pédagogiques (privées ou partagées)
--   - Vue at_risk_students : stagiaires inactifs / en difficulté
--   - Notifications auto à la programmation d'une session
-- ============================================================

-- ------------------------------------------------------------
-- 1. Référent pédagogique (formateur)
-- ------------------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS referent_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS profiles_referent_idx ON public.profiles(referent_id);

-- ------------------------------------------------------------
-- 2. Sessions d'accompagnement (rendez-vous 1 à 1)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.coaching_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  trainer_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  scheduled_at timestamptz NOT NULL,
  duration_min int NOT NULL DEFAULT 30,
  mode text NOT NULL DEFAULT 'visio',
  meeting_url text,
  location text,
  status text NOT NULL DEFAULT 'prevue',
  agenda text,
  summary text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'coaching_mode_check') THEN
    ALTER TABLE public.coaching_sessions
      ADD CONSTRAINT coaching_mode_check
      CHECK (mode IN ('visio','presentiel','tel'));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'coaching_status_check') THEN
    ALTER TABLE public.coaching_sessions
      ADD CONSTRAINT coaching_status_check
      CHECK (status IN ('prevue','tenue','annulee','no_show'));
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS coaching_sessions_user_idx
  ON public.coaching_sessions(user_id, scheduled_at DESC);
CREATE INDEX IF NOT EXISTS coaching_sessions_trainer_idx
  ON public.coaching_sessions(trainer_id, scheduled_at DESC);

-- ------------------------------------------------------------
-- 3. Notes pédagogiques
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.coaching_notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  trainer_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  body_md text NOT NULL,
  visible_to_student boolean NOT NULL DEFAULT false,
  pinned boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS coaching_notes_user_idx
  ON public.coaching_notes(user_id, created_at DESC);

-- ------------------------------------------------------------
-- 4. RLS
-- ------------------------------------------------------------
ALTER TABLE public.coaching_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coaching_notes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS coaching_sess_read ON public.coaching_sessions;
CREATE POLICY coaching_sess_read ON public.coaching_sessions
  FOR SELECT USING (
    auth.uid() = user_id
    OR auth.uid() = trainer_id
    OR public.is_admin()
  );

DROP POLICY IF EXISTS coaching_sess_admin ON public.coaching_sessions;
CREATE POLICY coaching_sess_admin ON public.coaching_sessions
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Notes : le stagiaire voit uniquement celles marquées partagées
DROP POLICY IF EXISTS coaching_notes_read ON public.coaching_notes;
CREATE POLICY coaching_notes_read ON public.coaching_notes
  FOR SELECT USING (
    public.is_admin()
    OR auth.uid() = trainer_id
    OR (auth.uid() = user_id AND visible_to_student = true)
  );

DROP POLICY IF EXISTS coaching_notes_admin ON public.coaching_notes;
CREATE POLICY coaching_notes_admin ON public.coaching_notes
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ------------------------------------------------------------
-- 5. Trigger updated_at
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tg_coaching_bump()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END $$;

DROP TRIGGER IF EXISTS coaching_sessions_updated ON public.coaching_sessions;
CREATE TRIGGER coaching_sessions_updated
  BEFORE UPDATE ON public.coaching_sessions
  FOR EACH ROW EXECUTE FUNCTION public.tg_coaching_bump();

DROP TRIGGER IF EXISTS coaching_notes_updated ON public.coaching_notes;
CREATE TRIGGER coaching_notes_updated
  BEFORE UPDATE ON public.coaching_notes
  FOR EACH ROW EXECUTE FUNCTION public.tg_coaching_bump();

-- ------------------------------------------------------------
-- 6. Trigger notification : session programmée ou reprogrammée
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tg_coaching_notify()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_trainer_name text;
BEGIN
  IF TG_OP = 'INSERT'
     OR (TG_OP = 'UPDATE' AND (OLD.scheduled_at <> NEW.scheduled_at OR OLD.status <> NEW.status))
  THEN
    SELECT COALESCE(full_name, email) INTO v_trainer_name
      FROM public.profiles WHERE id = NEW.trainer_id;

    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    VALUES (
      NEW.user_id,
      'coaching',
      CASE NEW.status
        WHEN 'annulee' THEN 'Rendez-vous annulé'
        WHEN 'tenue' THEN 'Rendez-vous terminé'
        ELSE 'Rendez-vous d''accompagnement'
      END,
      'Avec ' || COALESCE(v_trainer_name,'votre référent')
        || ' le '
        || to_char(NEW.scheduled_at AT TIME ZONE 'Europe/Paris', 'DD/MM/YYYY à HH24h MI'),
      '/accompagnement'
    );
  END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS coaching_sessions_notify ON public.coaching_sessions;
CREATE TRIGGER coaching_sessions_notify
  AFTER INSERT OR UPDATE ON public.coaching_sessions
  FOR EACH ROW EXECUTE FUNCTION public.tg_coaching_notify();

-- Notification : nouvelle note partagée
CREATE OR REPLACE FUNCTION public.tg_coaching_note_notify()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NEW.visible_to_student = true
     AND (TG_OP = 'INSERT' OR OLD.visible_to_student = false)
  THEN
    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    VALUES (
      NEW.user_id,
      'coaching',
      'Nouveau retour de votre référent',
      left(NEW.body_md, 160),
      '/accompagnement'
    );
  END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS coaching_notes_notify ON public.coaching_notes;
CREATE TRIGGER coaching_notes_notify
  AFTER INSERT OR UPDATE ON public.coaching_notes
  FOR EACH ROW EXECUTE FUNCTION public.tg_coaching_note_notify();

-- ------------------------------------------------------------
-- 7. Vue : stagiaires "à risque" (inactivité / scores faibles)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW public.at_risk_students AS
SELECT
  p.id,
  p.full_name,
  p.email,
  p.referent_id,
  p.group_id,
  (SELECT max(started_at) FROM public.quiz_attempts qa WHERE qa.user_id = p.id)   AS last_attempt_at,
  (SELECT max(completed_at) FROM public.lesson_progress lp WHERE lp.user_id = p.id AND lp.completed) AS last_lesson_at,
  (SELECT round(avg(percentage))::int FROM public.quiz_attempts qa WHERE qa.user_id = p.id) AS avg_score,
  CASE
    WHEN (SELECT max(started_at) FROM public.quiz_attempts qa WHERE qa.user_id = p.id) IS NULL
     AND (SELECT max(completed_at) FROM public.lesson_progress lp WHERE lp.user_id = p.id AND lp.completed) IS NULL
    THEN 'jamais_actif'
    WHEN GREATEST(
           coalesce((SELECT max(started_at) FROM public.quiz_attempts qa WHERE qa.user_id = p.id), 'epoch'::timestamptz),
           coalesce((SELECT max(completed_at) FROM public.lesson_progress lp WHERE lp.user_id = p.id AND lp.completed), 'epoch'::timestamptz)
         ) < now() - interval '14 days'
    THEN 'inactif_14j'
    WHEN (SELECT avg(percentage) FROM public.quiz_attempts qa WHERE qa.user_id = p.id) < 50
    THEN 'score_faible'
    ELSE NULL
  END AS risk_flag
FROM public.profiles p
WHERE p.role = 'student'
  AND p.disabled IS NOT TRUE;

GRANT SELECT ON public.at_risk_students TO authenticated;
