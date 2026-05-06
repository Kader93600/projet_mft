-- =====================================================================
-- MA FORMATION TRANSPORT — Point #15 : Gamification (XP, niveaux, streak, classement)
-- =====================================================================

-- 1. Table des événements XP -----------------------------------------
CREATE TABLE IF NOT EXISTS public.xp_events (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  kind text NOT NULL CHECK (kind IN (
    'lesson_completed','quiz_passed','quiz_perfect','mock_exam_passed',
    'streak_bonus','badge_earned','daily_login'
  )),
  points int NOT NULL,
  ref_id text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS xp_events_user_idx ON public.xp_events(user_id, created_at DESC);
-- garde-fou : 1 seule ligne par ref_id (évite les doubles comptages)
CREATE UNIQUE INDEX IF NOT EXISTS xp_events_unique_ref
  ON public.xp_events(user_id, kind, ref_id)
  WHERE ref_id IS NOT NULL;

ALTER TABLE public.xp_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS xp_events_read ON public.xp_events;
CREATE POLICY xp_events_read ON public.xp_events
  FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

-- 2. Fonction : niveau à partir d'un total XP -------------------------
-- Barème : chaque niveau requiert n*100 XP cumulés.
-- Niveau 1 = 0-99, 2 = 100-299, 3 = 300-599, 4 = 600-999, …
CREATE OR REPLACE FUNCTION public.xp_level(total int)
RETURNS int LANGUAGE sql IMMUTABLE AS $$
  SELECT GREATEST(1, floor((sqrt(1 + 8 * GREATEST(total,0) / 100.0) - 1) / 2)::int + 1);
$$;

CREATE OR REPLACE FUNCTION public.xp_for_next_level(lvl int)
RETURNS int LANGUAGE sql IMMUTABLE AS $$
  SELECT (lvl * (lvl + 1) / 2) * 100;
$$;

-- 3. Vue : stats par utilisateur --------------------------------------
CREATE OR REPLACE VIEW public.user_gamification AS
SELECT
  p.id AS user_id,
  p.full_name,
  p.email,
  COALESCE((SELECT sum(points) FROM public.xp_events e WHERE e.user_id = p.id), 0)::int AS total_xp,
  public.xp_level(
    COALESCE((SELECT sum(points) FROM public.xp_events e WHERE e.user_id = p.id), 0)::int
  ) AS level,
  (
    SELECT count(DISTINCT date_trunc('day', e.created_at)::date)
    FROM public.xp_events e WHERE e.user_id = p.id
  )::int AS active_days,
  (SELECT max(e.created_at) FROM public.xp_events e WHERE e.user_id = p.id) AS last_xp_at
FROM public.profiles p
WHERE p.role = 'student';

GRANT SELECT ON public.user_gamification TO authenticated;

-- 4. Streak (jours consécutifs avec activité) -------------------------
CREATE OR REPLACE FUNCTION public.user_streak(p_user uuid)
RETURNS TABLE (current_streak int, longest_streak int) LANGUAGE plpgsql STABLE AS $$
DECLARE
  days date[];
  cur int := 0;
  best int := 0;
  run int := 0;
  prev date;
  d date;
  today date := current_date;
BEGIN
  SELECT array_agg(DISTINCT day ORDER BY day DESC)
  INTO days
  FROM public.user_daily_activity
  WHERE user_id = p_user;

  IF days IS NULL OR array_length(days,1) IS NULL THEN
    RETURN QUERY SELECT 0, 0; RETURN;
  END IF;

  -- Streak courant : on remonte depuis aujourd'hui
  IF days[1] = today OR days[1] = today - INTERVAL '1 day' THEN
    prev := days[1];
    cur := 1;
    FOR i IN 2..array_length(days,1) LOOP
      IF days[i] = prev - INTERVAL '1 day' THEN
        cur := cur + 1;
        prev := days[i];
      ELSE
        EXIT;
      END IF;
    END LOOP;
  END IF;

  -- Meilleur streak historique
  prev := NULL;
  run := 0;
  FOREACH d IN ARRAY (SELECT array_agg(x ORDER BY x) FROM unnest(days) x) LOOP
    IF prev IS NULL OR d = prev + INTERVAL '1 day' THEN
      run := run + 1;
    ELSE
      run := 1;
    END IF;
    IF run > best THEN best := run; END IF;
    prev := d;
  END LOOP;

  RETURN QUERY SELECT cur, best;
END;
$$;

GRANT EXECUTE ON FUNCTION public.user_streak(uuid) TO authenticated;

-- 5. Classement anonymisé (top 50) ------------------------------------
CREATE OR REPLACE VIEW public.leaderboard_public AS
SELECT
  row_number() OVER (ORDER BY total_xp DESC) AS rank,
  user_id,
  CASE
    WHEN full_name IS NOT NULL AND length(full_name) > 0
      THEN regexp_replace(full_name, '(\S+)\s+(\S)\S*', '\1 \2.')
    ELSE split_part(email,'@',1)
  END AS display_name,
  total_xp,
  level
FROM public.user_gamification
ORDER BY total_xp DESC
LIMIT 50;

GRANT SELECT ON public.leaderboard_public TO authenticated;

-- 6. Triggers d'octroi XP ---------------------------------------------
-- Quiz
CREATE OR REPLACE FUNCTION public.tg_xp_quiz()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.finished_at IS NULL OR NEW.passed IS NOT TRUE THEN
    RETURN NEW;
  END IF;
  INSERT INTO public.xp_events(user_id, kind, points, ref_id)
  VALUES (NEW.user_id, 'quiz_passed', 20, NEW.id::text)
  ON CONFLICT DO NOTHING;
  IF NEW.percentage = 100 THEN
    INSERT INTO public.xp_events(user_id, kind, points, ref_id)
    VALUES (NEW.user_id, 'quiz_perfect', 15, NEW.id::text)
    ON CONFLICT DO NOTHING;
  END IF;
  -- Bonus examen blanc
  IF EXISTS (
    SELECT 1 FROM public.quizzes qz
    WHERE qz.id = NEW.quiz_id AND qz.is_mock_exam = true
  ) THEN
    INSERT INTO public.xp_events(user_id, kind, points, ref_id)
    VALUES (NEW.user_id, 'mock_exam_passed', 50, NEW.id::text)
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_xp_quiz ON public.quiz_attempts;
CREATE TRIGGER tg_xp_quiz
  AFTER INSERT OR UPDATE ON public.quiz_attempts
  FOR EACH ROW
  WHEN (NEW.finished_at IS NOT NULL)
  EXECUTE FUNCTION public.tg_xp_quiz();

-- Leçon
CREATE OR REPLACE FUNCTION public.tg_xp_lesson()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.completed IS TRUE AND (OLD IS NULL OR OLD.completed IS NOT TRUE) THEN
    INSERT INTO public.xp_events(user_id, kind, points, ref_id)
    VALUES (NEW.user_id, 'lesson_completed', 10, NEW.lesson_id::text)
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_xp_lesson ON public.lesson_progress;
CREATE TRIGGER tg_xp_lesson
  AFTER INSERT OR UPDATE ON public.lesson_progress
  FOR EACH ROW EXECUTE FUNCTION public.tg_xp_lesson();

-- Badge
CREATE OR REPLACE FUNCTION public.tg_xp_badge()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE pts int;
BEGIN
  SELECT points INTO pts FROM public.badges WHERE id = NEW.badge_id;
  IF pts IS NULL OR pts = 0 THEN pts := 10; END IF;
  INSERT INTO public.xp_events(user_id, kind, points, ref_id)
  VALUES (NEW.user_id, 'badge_earned', pts, NEW.badge_id::text)
  ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_xp_badge ON public.user_badges;
CREATE TRIGGER tg_xp_badge
  AFTER INSERT ON public.user_badges
  FOR EACH ROW EXECUTE FUNCTION public.tg_xp_badge();

-- 7. Backfill à partir de l'historique --------------------------------
DO $$
BEGIN
  -- Leçons complétées
  INSERT INTO public.xp_events(user_id, kind, points, ref_id, created_at)
  SELECT lp.user_id, 'lesson_completed', 10, lp.lesson_id::text, COALESCE(lp.completed_at, now())
  FROM public.lesson_progress lp
  WHERE lp.completed = true
  ON CONFLICT DO NOTHING;

  -- Quiz réussis
  INSERT INTO public.xp_events(user_id, kind, points, ref_id, created_at)
  SELECT qa.user_id, 'quiz_passed', 20, qa.id::text, COALESCE(qa.finished_at, now())
  FROM public.quiz_attempts qa
  WHERE qa.passed = true AND qa.finished_at IS NOT NULL
  ON CONFLICT DO NOTHING;

  -- Quiz parfaits
  INSERT INTO public.xp_events(user_id, kind, points, ref_id, created_at)
  SELECT qa.user_id, 'quiz_perfect', 15, qa.id::text, COALESCE(qa.finished_at, now())
  FROM public.quiz_attempts qa
  WHERE qa.percentage = 100 AND qa.finished_at IS NOT NULL
  ON CONFLICT DO NOTHING;

  -- Examens blancs réussis
  INSERT INTO public.xp_events(user_id, kind, points, ref_id, created_at)
  SELECT qa.user_id, 'mock_exam_passed', 50, qa.id::text, COALESCE(qa.finished_at, now())
  FROM public.quiz_attempts qa
  JOIN public.quizzes q ON q.id = qa.quiz_id
  WHERE qa.passed = true AND q.is_mock_exam = true AND qa.finished_at IS NOT NULL
  ON CONFLICT DO NOTHING;

  -- Badges gagnés
  INSERT INTO public.xp_events(user_id, kind, points, ref_id, created_at)
  SELECT ub.user_id, 'badge_earned', COALESCE(b.points, 10), ub.badge_id::text, ub.earned_at
  FROM public.user_badges ub
  JOIN public.badges b ON b.id = ub.badge_id
  ON CONFLICT DO NOTHING;
END $$;
