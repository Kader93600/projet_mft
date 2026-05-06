-- =====================================================================
-- Placement — filtrage par formation du stagiaire
-- =====================================================================
-- Adapte la RPC submit_placement pour ne calculer les scores que sur
-- les questions de la formation à laquelle l'utilisateur est inscrit.
--
-- Pré-requis :
--   - placement.sql (version initiale de submit_placement)
--   - placement_extensions.sql (colonne formation_id sur placement_questions)
--   - formations_v2.sql (table formations + enrollments.formation_id)
--
-- Idempotent : CREATE OR REPLACE FUNCTION.
-- =====================================================================

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
  v_formation_id uuid;
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

  -- Résolution de la formation active du stagiaire (la plus récente)
  SELECT formation_id INTO v_formation_id
    FROM public.enrollments
   WHERE user_id = v_uid
     AND formation_id IS NOT NULL
   ORDER BY
     CASE WHEN status = 'en_cours' THEN 0 ELSE 1 END,
     created_at DESC
   LIMIT 1;

  IF v_formation_id IS NULL THEN
    RAISE EXCEPTION 'Aucune formation active trouvée pour ce compte. Contactez votre référent.';
  END IF;

  -- Calcul score par bloc — limité aux questions de la formation
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
             ON q.bloc_id = b.id
            AND q.active = true
            AND q.formation_id = v_formation_id
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
      -- On n'inscrit le bloc dans les scores que s'il a des questions
      -- pour cette formation (sinon BC1/BC2/BC3 vides pollueraient l'UI).
      IF r.total > 0 THEN
        v_scores := v_scores || jsonb_build_object(r.code, v_pct);
        v_levels := v_levels || jsonb_build_object(r.code, v_level);
        IF v_pct < v_lowest_pct THEN
          v_lowest_pct := v_pct;
          v_lowest_code := r.code;
          v_recommended := r.bloc_id;
        END IF;
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
    'lowest_code', v_lowest_code,
    'formation_id', v_formation_id
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_placement(jsonb, int) TO authenticated;
