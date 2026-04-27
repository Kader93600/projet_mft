-- ============================================================
-- Positionnement initial (Point #6)
--   - Banque de questions réparties par bloc (BC1/BC2/BC3)
--   - Résultat unique par stagiaire : scores par BC + bloc recommandé
--   - Preuve d'individualisation (Qualiopi indicateur 11)
-- ============================================================

-- Flag dans profiles : date du positionnement
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS placement_completed_at timestamptz;

-- ------------------------------------------------------------
-- 1. Banque de questions de positionnement
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.placement_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bloc_id int NOT NULL REFERENCES public.blocs(id) ON DELETE CASCADE,
  prompt text NOT NULL,
  choices jsonb NOT NULL,                -- ["choix A", "choix B", ...]
  correct_index int NOT NULL,            -- 0-based
  difficulty text NOT NULL DEFAULT 'standard'
    CHECK (difficulty IN ('facile', 'standard', 'difficile')),
  "order" int NOT NULL DEFAULT 0,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS placement_q_bloc_idx
  ON public.placement_questions(bloc_id, "order") WHERE active = true;

ALTER TABLE public.placement_questions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS placement_q_read ON public.placement_questions;
CREATE POLICY placement_q_read ON public.placement_questions
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS placement_q_admin ON public.placement_questions;
CREATE POLICY placement_q_admin ON public.placement_questions
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ------------------------------------------------------------
-- 2. Résultat du positionnement (1 par stagiaire)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.placement_results (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  scores jsonb NOT NULL,                 -- { "BC1": 60, "BC2": 40, "BC3": 80 }
  level_per_bloc jsonb NOT NULL,         -- { "BC1": "intermediaire", ... }
  recommended_bloc_id int REFERENCES public.blocs(id) ON DELETE SET NULL,
  answers jsonb,                         -- { question_id: choice_index }
  duration_s int,
  taken_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.placement_results ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS placement_r_self ON public.placement_results;
CREATE POLICY placement_r_self ON public.placement_results
  FOR SELECT USING (user_id = auth.uid() OR public.is_admin());

-- Écriture uniquement via RPC

-- ------------------------------------------------------------
-- 3. RPC : soumettre le positionnement
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.submit_placement(
  p_answers jsonb,          -- { question_id (uuid): choice_index (int) }
  p_duration_s int DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_scores jsonb := '{}'::jsonb;
  v_levels jsonb := '{}'::jsonb;
  v_recommended int;
  v_lowest_code text;
  v_lowest_pct numeric := 200;
  r record;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Non authentifié'; END IF;
  IF p_answers IS NULL OR jsonb_typeof(p_answers) <> 'object' THEN
    RAISE EXCEPTION 'Réponses invalides';
  END IF;

  -- Calcul score par bloc
  FOR r IN
    SELECT b.id AS bloc_id,
           b.code AS code,
           count(*) FILTER (WHERE q.id IS NOT NULL) AS total,
           count(*) FILTER (
             WHERE q.id IS NOT NULL
               AND (p_answers -> q.id::text)::text::int = q.correct_index
           ) AS correct
      FROM public.blocs b
      LEFT JOIN public.placement_questions q
             ON q.bloc_id = b.id AND q.active = true
     GROUP BY b.id, b.code
  LOOP
    DECLARE
      v_pct int := CASE WHEN r.total > 0 THEN round(100.0 * r.correct / r.total)::int ELSE 0 END;
      v_level text := CASE
        WHEN v_pct >= 75 THEN 'avance'
        WHEN v_pct >= 45 THEN 'intermediaire'
        ELSE 'debutant'
      END;
    BEGIN
      v_scores := v_scores || jsonb_build_object(r.code, v_pct);
      v_levels := v_levels || jsonb_build_object(r.code, v_level);
      IF r.total > 0 AND v_pct < v_lowest_pct THEN
        v_lowest_pct := v_pct;
        v_lowest_code := r.code;
        v_recommended := r.bloc_id;
      END IF;
    END;
  END LOOP;

  INSERT INTO public.placement_results
    (user_id, scores, level_per_bloc, recommended_bloc_id, answers, duration_s, taken_at)
  VALUES
    (v_uid, v_scores, v_levels, v_recommended, p_answers, p_duration_s, now())
  ON CONFLICT (user_id) DO UPDATE
    SET scores = EXCLUDED.scores,
        level_per_bloc = EXCLUDED.level_per_bloc,
        recommended_bloc_id = EXCLUDED.recommended_bloc_id,
        answers = EXCLUDED.answers,
        duration_s = EXCLUDED.duration_s,
        taken_at = now();

  UPDATE public.profiles
     SET placement_completed_at = now()
   WHERE id = v_uid;

  -- Notification info
  INSERT INTO public.notifications (user_id, type, title, body, link_url)
  VALUES (
    v_uid,
    'system',
    'Positionnement enregistré',
    'Votre profil de compétences est prêt. Consultez vos recommandations.',
    '/positionnement'
  );

  RETURN jsonb_build_object(
    'scores', v_scores,
    'levels', v_levels,
    'recommended_bloc_id', v_recommended,
    'lowest_code', v_lowest_code
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_placement(jsonb, int) TO authenticated;
