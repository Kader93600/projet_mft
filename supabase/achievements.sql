-- ============================================================
-- Point #9 — Certificats & badges de progression
--   - badges             : catalogue (admin)
--   - user_badges        : badges débloqués (stagiaire)
--   - certificates       : attestations par BC / fin de formation
--   - recompute_user_achievements(uuid) : calcule ce qui est acquis
--   - triggers sur quiz_attempts + lesson_progress → recompute
-- ============================================================

-- ------------------------------------------------------------
-- 1. Catalogue des badges
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.badges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text UNIQUE NOT NULL,                 -- ex. 'first_quiz_passed'
  name text NOT NULL,
  description text,
  icon text NOT NULL DEFAULT 'Award',        -- lucide icon name
  category text NOT NULL DEFAULT 'progression',  -- progression | maitrise | regularite | excellence
  tier text NOT NULL DEFAULT 'bronze',       -- bronze | silver | gold
  criteria jsonb NOT NULL DEFAULT '{}',      -- { type: 'quiz_passed_count', min: 5, bloc_id: 1, ... }
  points int NOT NULL DEFAULT 10,
  active boolean NOT NULL DEFAULT true,
  "order" int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'badges_category_check') THEN
    ALTER TABLE public.badges
      ADD CONSTRAINT badges_category_check
      CHECK (category IN ('progression','maitrise','regularite','excellence'));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'badges_tier_check') THEN
    ALTER TABLE public.badges
      ADD CONSTRAINT badges_tier_check
      CHECK (tier IN ('bronze','silver','gold'));
  END IF;
END $$;

-- ------------------------------------------------------------
-- 2. Badges débloqués par utilisateur
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_badges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  badge_id uuid NOT NULL REFERENCES public.badges(id) ON DELETE CASCADE,
  earned_at timestamptz NOT NULL DEFAULT now(),
  context jsonb,
  UNIQUE (user_id, badge_id)
);

CREATE INDEX IF NOT EXISTS user_badges_user_idx ON public.user_badges(user_id, earned_at DESC);

-- ------------------------------------------------------------
-- 3. Certificats (attestations par BC / fin de formation)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type text NOT NULL,                         -- 'bloc' | 'final'
  bloc_id int REFERENCES public.blocs(id) ON DELETE CASCADE,
  serial text NOT NULL,                       -- identifiant unique humainement lisible
  issued_at timestamptz NOT NULL DEFAULT now(),
  revoked_at timestamptz,
  score_snapshot jsonb,                       -- photo des scores au moment de l'émission
  UNIQUE (user_id, type, bloc_id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'certificates_type_check') THEN
    ALTER TABLE public.certificates
      ADD CONSTRAINT certificates_type_check
      CHECK (type IN ('bloc','final'));
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS certificates_user_idx ON public.certificates(user_id, issued_at DESC);

-- ------------------------------------------------------------
-- 4. RLS
-- ------------------------------------------------------------
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS badges_read ON public.badges;
CREATE POLICY badges_read ON public.badges
  FOR SELECT USING (auth.role() = 'authenticated');
DROP POLICY IF EXISTS badges_admin ON public.badges;
CREATE POLICY badges_admin ON public.badges
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS user_badges_self ON public.user_badges;
CREATE POLICY user_badges_self ON public.user_badges
  FOR SELECT USING (auth.uid() = user_id OR public.is_admin());
DROP POLICY IF EXISTS user_badges_admin ON public.user_badges;
CREATE POLICY user_badges_admin ON public.user_badges
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS certs_self ON public.certificates;
CREATE POLICY certs_self ON public.certificates
  FOR SELECT USING (auth.uid() = user_id OR public.is_admin());
DROP POLICY IF EXISTS certs_admin ON public.certificates;
CREATE POLICY certs_admin ON public.certificates
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ------------------------------------------------------------
-- 5. Fonction : recomposition des badges + certificats
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.recompute_user_achievements(p_user uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  b record;
  v_count int;
  v_ok boolean;
  v_crit_type text;
  v_min int;
  v_bloc int;
  v_serial text;
  bloc_rec record;
  total_lessons_bc int;
  done_lessons_bc int;
  passed_exam_bc int;
BEGIN
  IF p_user IS NULL THEN RETURN; END IF;

  -- ----- Parcours des badges actifs -----
  FOR b IN SELECT * FROM public.badges WHERE active LOOP
    v_crit_type := b.criteria->>'type';
    v_min := COALESCE((b.criteria->>'min')::int, 1);
    v_bloc := NULLIF(b.criteria->>'bloc_id','')::int;
    v_ok := false;

    IF v_crit_type = 'first_quiz_passed' THEN
      SELECT count(*) INTO v_count FROM public.quiz_attempts
       WHERE user_id = p_user AND passed = true;
      v_ok := v_count >= 1;

    ELSIF v_crit_type = 'quiz_passed_count' THEN
      SELECT count(DISTINCT quiz_id) INTO v_count FROM public.quiz_attempts
       WHERE user_id = p_user AND passed = true;
      v_ok := v_count >= v_min;

    ELSIF v_crit_type = 'perfect_score' THEN
      SELECT count(*) INTO v_count FROM public.quiz_attempts
       WHERE user_id = p_user AND percentage = 100;
      v_ok := v_count >= v_min;

    ELSIF v_crit_type = 'mock_exam_passed' THEN
      SELECT count(*) INTO v_count FROM public.quiz_attempts qa
        JOIN public.quizzes q ON q.id = qa.quiz_id
       WHERE qa.user_id = p_user AND qa.passed = true AND q.is_mock_exam = true;
      v_ok := v_count >= v_min;

    ELSIF v_crit_type = 'lessons_completed' THEN
      SELECT count(*) INTO v_count FROM public.lesson_progress
       WHERE user_id = p_user AND completed = true;
      v_ok := v_count >= v_min;

    ELSIF v_crit_type = 'bloc_mastered' AND v_bloc IS NOT NULL THEN
      -- toutes les leçons du BC complétées ET au moins un quiz du BC réussi
      SELECT count(*) INTO total_lessons_bc
        FROM public.lessons l
        JOIN public.modules m ON m.id = l.module_id
       WHERE m.bloc_id = v_bloc;
      SELECT count(*) INTO done_lessons_bc
        FROM public.lesson_progress lp
        JOIN public.lessons l ON l.id = lp.lesson_id
        JOIN public.modules m ON m.id = l.module_id
       WHERE lp.user_id = p_user AND lp.completed = true AND m.bloc_id = v_bloc;
      SELECT count(*) INTO passed_exam_bc
        FROM public.quiz_attempts qa
        JOIN public.quizzes q ON q.id = qa.quiz_id
        JOIN public.modules m ON m.id = q.module_id
       WHERE qa.user_id = p_user AND qa.passed = true AND m.bloc_id = v_bloc;
      v_ok := total_lessons_bc > 0
          AND done_lessons_bc >= total_lessons_bc
          AND passed_exam_bc >= 1;
    END IF;

    IF v_ok THEN
      INSERT INTO public.user_badges (user_id, badge_id, context)
        VALUES (p_user, b.id, b.criteria)
        ON CONFLICT (user_id, badge_id) DO NOTHING;

      -- Notification seulement si on vient de l'acquérir
      IF FOUND THEN
        INSERT INTO public.notifications (user_id, type, title, body, link_url)
          VALUES (
            p_user,
            'badge',
            'Nouveau badge : ' || b.name,
            COALESCE(b.description, ''),
            '/reussites'
          );
      END IF;
    END IF;
  END LOOP;

  -- ----- Certificats par BC (attestation de réussite d'un bloc) -----
  FOR bloc_rec IN SELECT id, code, title FROM public.blocs LOOP
    SELECT count(*) INTO total_lessons_bc
      FROM public.lessons l
      JOIN public.modules m ON m.id = l.module_id
     WHERE m.bloc_id = bloc_rec.id;
    SELECT count(*) INTO done_lessons_bc
      FROM public.lesson_progress lp
      JOIN public.lessons l ON l.id = lp.lesson_id
      JOIN public.modules m ON m.id = l.module_id
     WHERE lp.user_id = p_user AND lp.completed = true AND m.bloc_id = bloc_rec.id;
    SELECT count(*) INTO passed_exam_bc
      FROM public.quiz_attempts qa
      JOIN public.quizzes q ON q.id = qa.quiz_id
      JOIN public.modules m ON m.id = q.module_id
     WHERE qa.user_id = p_user AND qa.passed = true AND m.bloc_id = bloc_rec.id;

    IF total_lessons_bc > 0
       AND done_lessons_bc >= total_lessons_bc
       AND passed_exam_bc >= 1
    THEN
      v_serial := 'GOTRM-'
        || bloc_rec.code
        || '-' || to_char(now(),'YYYYMMDD')
        || '-' || substr(replace(p_user::text,'-',''),1,6);

      INSERT INTO public.certificates (user_id, type, bloc_id, serial, score_snapshot)
        VALUES (
          p_user,
          'bloc',
          bloc_rec.id,
          v_serial,
          jsonb_build_object(
            'lessons_done', done_lessons_bc,
            'lessons_total', total_lessons_bc,
            'exams_passed', passed_exam_bc
          )
        )
        ON CONFLICT (user_id, type, bloc_id) DO NOTHING;

      IF FOUND THEN
        INSERT INTO public.notifications (user_id, type, title, body, link_url)
          VALUES (
            p_user,
            'certificate',
            'Attestation disponible : ' || bloc_rec.title,
            'Votre bloc de compétence est validé.',
            '/certificats'
          );
      END IF;
    END IF;
  END LOOP;

  -- ----- Certificat final (tous les BC validés) -----
  IF NOT EXISTS (
    SELECT 1 FROM public.blocs bl
    WHERE NOT EXISTS (
      SELECT 1 FROM public.certificates c
      WHERE c.user_id = p_user AND c.type = 'bloc' AND c.bloc_id = bl.id
    )
  ) AND EXISTS (SELECT 1 FROM public.blocs) THEN
    v_serial := 'GOTRM-RNCP40990-'
      || to_char(now(),'YYYYMMDD')
      || '-' || substr(replace(p_user::text,'-',''),1,6);
    INSERT INTO public.certificates (user_id, type, bloc_id, serial)
      VALUES (p_user, 'final', NULL, v_serial)
      ON CONFLICT (user_id, type, bloc_id) DO NOTHING;

    IF FOUND THEN
      INSERT INTO public.notifications (user_id, type, title, body, link_url)
        VALUES (
          p_user,
          'certificate',
          'Certificat de fin de formation délivré',
          'Tous les blocs de compétence sont validés.',
          '/certificats'
        );
    END IF;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.recompute_user_achievements(uuid) TO authenticated;

-- ------------------------------------------------------------
-- 6. Triggers : recompute après progression & tentatives
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tg_achievements_recompute()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  PERFORM public.recompute_user_achievements(NEW.user_id);
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS tg_ach_quiz_attempts ON public.quiz_attempts;
CREATE TRIGGER tg_ach_quiz_attempts
  AFTER INSERT OR UPDATE ON public.quiz_attempts
  FOR EACH ROW
  WHEN (NEW.finished_at IS NOT NULL)
  EXECUTE FUNCTION public.tg_achievements_recompute();

DROP TRIGGER IF EXISTS tg_ach_lesson_progress ON public.lesson_progress;
CREATE TRIGGER tg_ach_lesson_progress
  AFTER INSERT OR UPDATE ON public.lesson_progress
  FOR EACH ROW
  WHEN (NEW.completed = true)
  EXECUTE FUNCTION public.tg_achievements_recompute();

-- ------------------------------------------------------------
-- 7. Seed : catalogue de base
-- ------------------------------------------------------------
INSERT INTO public.badges (code, name, description, icon, category, tier, criteria, points, "order")
VALUES
  ('first_quiz_passed', 'Premier quiz réussi',
   'Votre première validation au-dessus du seuil.',
   'Sparkles', 'progression', 'bronze',
   '{"type":"first_quiz_passed"}'::jsonb, 10, 1),

  ('five_quiz_passed', '5 quiz validés',
   'Cinq quiz différents franchis.',
   'Medal', 'progression', 'silver',
   '{"type":"quiz_passed_count","min":5}'::jsonb, 25, 2),

  ('fifteen_quiz_passed', '15 quiz validés',
   'La régularité paie : 15 quiz franchis.',
   'Trophy', 'regularite', 'gold',
   '{"type":"quiz_passed_count","min":15}'::jsonb, 50, 3),

  ('perfect_score', 'Score parfait',
   'Un 100 % sur un quiz : la rigueur absolue.',
   'Star', 'excellence', 'gold',
   '{"type":"perfect_score","min":1}'::jsonb, 40, 4),

  ('mock_exam_passed', 'Examen blanc réussi',
   'Vous avez passé un examen blanc officiel.',
   'ShieldCheck', 'excellence', 'gold',
   '{"type":"mock_exam_passed","min":1}'::jsonb, 60, 5),

  ('ten_lessons', '10 leçons complétées',
   'Vous avancez dans le parcours.',
   'BookOpen', 'progression', 'bronze',
   '{"type":"lessons_completed","min":10}'::jsonb, 15, 6),

  ('fifty_lessons', '50 leçons complétées',
   'Vous êtes sur tous les fronts.',
   'Library', 'regularite', 'silver',
   '{"type":"lessons_completed","min":50}'::jsonb, 35, 7)
ON CONFLICT (code) DO NOTHING;

-- ------------------------------------------------------------
-- 8. Backfill (optionnel) : recalcule pour tous les stagiaires existants
-- ------------------------------------------------------------
DO $$
DECLARE u record;
BEGIN
  FOR u IN SELECT id FROM public.profiles WHERE role = 'student' LOOP
    PERFORM public.recompute_user_achievements(u.id);
  END LOOP;
END $$;
