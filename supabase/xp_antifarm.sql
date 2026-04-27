-- =====================================================================
-- Anti-farming XP : on n'octroie l'XP qu'à la PREMIÈRE réussite par quiz
-- (au lieu de chaque tentative). Idem pour les quiz parfaits et examens.
-- =====================================================================

-- Le ref_id devient quiz_id (au lieu de attempt.id) → ON CONFLICT bloque
-- les attributions répétées. Les répétitions de quiz n'octroient plus de XP.
CREATE OR REPLACE FUNCTION public.tg_xp_quiz()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.finished_at IS NULL OR NEW.passed IS NOT TRUE THEN
    RETURN NEW;
  END IF;

  -- 1ère réussite du quiz : +20 XP
  INSERT INTO public.xp_events(user_id, kind, points, ref_id)
  VALUES (NEW.user_id, 'quiz_passed', 20, NEW.quiz_id::text)
  ON CONFLICT DO NOTHING;

  -- 1er score parfait : +15 XP supplémentaires
  IF NEW.percentage = 100 THEN
    INSERT INTO public.xp_events(user_id, kind, points, ref_id)
    VALUES (NEW.user_id, 'quiz_perfect', 15, NEW.quiz_id::text)
    ON CONFLICT DO NOTHING;
  END IF;

  -- 1ère réussite d'un examen blanc : +50 XP
  IF EXISTS (
    SELECT 1 FROM public.quizzes qz
    WHERE qz.id = NEW.quiz_id AND qz.is_mock_exam = true
  ) THEN
    INSERT INTO public.xp_events(user_id, kind, points, ref_id)
    VALUES (NEW.user_id, 'mock_exam_passed', 50, NEW.quiz_id::text)
    ON CONFLICT DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$;

-- Nettoyage de l'historique : on déduplique les événements existants
-- en gardant le plus ancien par (user, kind, quiz_id résolu).
-- Étape 1 : remplacer les ref_id (= ancien attempt.id) par le quiz_id
UPDATE public.xp_events x
   SET ref_id = qa.quiz_id::text
  FROM public.quiz_attempts qa
 WHERE x.kind IN ('quiz_passed','quiz_perfect','mock_exam_passed')
   AND x.ref_id = qa.id::text;

-- Étape 2 : supprimer les doublons exposés par la déduplication
DELETE FROM public.xp_events x
USING public.xp_events y
WHERE x.kind = y.kind
  AND x.user_id = y.user_id
  AND x.ref_id = y.ref_id
  AND x.kind IN ('quiz_passed','quiz_perfect','mock_exam_passed')
  AND x.created_at > y.created_at;

-- L'index unique (user_id, kind, ref_id) garantit désormais l'unicité.
