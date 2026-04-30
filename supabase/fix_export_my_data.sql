-- =====================================================================
-- FIX — export_my_data() résilient
--
-- Ancienne version : si une seule table sur les ~10 référencées manquait
-- ou avait un schéma différent, l'ensemble de l'export plantait, ce qui
-- se traduisait par "erreur lors du téléchargement des données" sur
-- /mes-donnees.
--
-- Nouvelle version :
--   - chaque section est wrappée dans un BEGIN/EXCEPTION/END
--   - l'erreur d'une section est convertie en `_error: <message>` dans le JSON
--   - l'export reste réussi tant qu'au moins le profil est lisible
--   - to_regclass() vérifie l'existence des tables avant requête
-- =====================================================================

CREATE OR REPLACE FUNCTION public.export_my_data()
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  result jsonb := '{}'::jsonb;
  tmp jsonb;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'unauthenticated';
  END IF;

  -- Méta export
  result := jsonb_build_object(
    'exported_at', now(),
    'rgpd_notice',
      'Cet export est fourni au titre de l''article 15 du RGPD (droit d''accès).',
    'user_id', uid
  );

  -- Profil (critique, sans guard)
  BEGIN
    SELECT to_jsonb(p) INTO tmp FROM public.profiles p WHERE p.id = uid;
    result := result || jsonb_build_object('profile', coalesce(tmp, '{}'::jsonb));
  EXCEPTION WHEN OTHERS THEN
    result := result || jsonb_build_object('profile', jsonb_build_object('_error', SQLERRM));
  END;

  -- Lesson progress
  BEGIN
    IF to_regclass('public.lesson_progress') IS NOT NULL THEN
      SELECT coalesce(jsonb_agg(to_jsonb(lp)), '[]'::jsonb)
        INTO tmp
        FROM public.lesson_progress lp
       WHERE lp.user_id = uid;
      result := result || jsonb_build_object('lesson_progress', tmp);
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result := result || jsonb_build_object(
      'lesson_progress', jsonb_build_array(jsonb_build_object('_error', SQLERRM))
    );
  END;

  -- Quiz attempts
  BEGIN
    IF to_regclass('public.quiz_attempts') IS NOT NULL THEN
      SELECT coalesce(jsonb_agg(to_jsonb(qa)), '[]'::jsonb)
        INTO tmp
        FROM public.quiz_attempts qa
       WHERE qa.user_id = uid;
      result := result || jsonb_build_object('quiz_attempts', tmp);
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result := result || jsonb_build_object(
      'quiz_attempts', jsonb_build_array(jsonb_build_object('_error', SQLERRM))
    );
  END;

  -- User badges
  BEGIN
    IF to_regclass('public.user_badges') IS NOT NULL THEN
      SELECT coalesce(jsonb_agg(to_jsonb(ub)), '[]'::jsonb)
        INTO tmp
        FROM public.user_badges ub
       WHERE ub.user_id = uid;
      result := result || jsonb_build_object('user_badges', tmp);
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result := result || jsonb_build_object(
      'user_badges', jsonb_build_array(jsonb_build_object('_error', SQLERRM))
    );
  END;

  -- Certificates
  BEGIN
    IF to_regclass('public.certificates') IS NOT NULL THEN
      SELECT coalesce(jsonb_agg(to_jsonb(c)), '[]'::jsonb)
        INTO tmp
        FROM public.certificates c
       WHERE c.user_id = uid;
      result := result || jsonb_build_object('certificates', tmp);
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result := result || jsonb_build_object(
      'certificates', jsonb_build_array(jsonb_build_object('_error', SQLERRM))
    );
  END;

  -- Enrollments
  BEGIN
    IF to_regclass('public.enrollments') IS NOT NULL THEN
      SELECT coalesce(jsonb_agg(to_jsonb(e)), '[]'::jsonb)
        INTO tmp
        FROM public.enrollments e
       WHERE e.user_id = uid;
      result := result || jsonb_build_object('enrollments', tmp);
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result := result || jsonb_build_object(
      'enrollments', jsonb_build_array(jsonb_build_object('_error', SQLERRM))
    );
  END;

  -- Consents
  BEGIN
    IF to_regclass('public.user_consents') IS NOT NULL THEN
      SELECT coalesce(jsonb_agg(to_jsonb(uc)), '[]'::jsonb)
        INTO tmp
        FROM public.user_consents uc
       WHERE uc.user_id = uid;
      result := result || jsonb_build_object('consents', tmp);
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result := result || jsonb_build_object(
      'consents', jsonb_build_array(jsonb_build_object('_error', SQLERRM))
    );
  END;

  -- Accessibility requests
  BEGIN
    IF to_regclass('public.accessibility_requests') IS NOT NULL THEN
      SELECT coalesce(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
        INTO tmp
        FROM public.accessibility_requests r
       WHERE r.user_id = uid;
      result := result || jsonb_build_object('a11y_requests', tmp);
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result := result || jsonb_build_object(
      'a11y_requests', jsonb_build_array(jsonb_build_object('_error', SQLERRM))
    );
  END;

  -- Coaching sessions
  BEGIN
    IF to_regclass('public.coaching_sessions') IS NOT NULL THEN
      SELECT coalesce(jsonb_agg(to_jsonb(cs)), '[]'::jsonb)
        INTO tmp
        FROM public.coaching_sessions cs
       WHERE cs.user_id = uid;
      result := result || jsonb_build_object('coaching_sessions', tmp);
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result := result || jsonb_build_object(
      'coaching_sessions', jsonb_build_array(jsonb_build_object('_error', SQLERRM))
    );
  END;

  -- XP events
  BEGIN
    IF to_regclass('public.xp_events') IS NOT NULL THEN
      SELECT coalesce(jsonb_agg(to_jsonb(x)), '[]'::jsonb)
        INTO tmp
        FROM public.xp_events x
       WHERE x.user_id = uid;
      result := result || jsonb_build_object('xp_events', tmp);
    END IF;
  EXCEPTION WHEN OTHERS THEN
    result := result || jsonb_build_object(
      'xp_events', jsonb_build_array(jsonb_build_object('_error', SQLERRM))
    );
  END;

  -- Log de l'accès (best-effort, on ne casse pas l'export si log échoue)
  BEGIN
    IF to_regclass('public.data_access_log') IS NOT NULL THEN
      INSERT INTO public.data_access_log (user_id, actor_id, action, scope)
      VALUES (uid, uid, 'export', 'self_full');
    END IF;
  EXCEPTION WHEN OTHERS THEN
    -- silencieux
    NULL;
  END;

  RETURN result;
END;
$$;

GRANT EXECUTE ON FUNCTION public.export_my_data() TO authenticated;
