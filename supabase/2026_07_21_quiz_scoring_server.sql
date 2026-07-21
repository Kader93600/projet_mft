-- =====================================================================
-- 2026-07-21 — QUIZ-03 : fermeture des écritures client sur les scores
-- =====================================================================
-- ⚠️ ORDRE D'APPLICATION : exécuter ce script UNIQUEMENT APRÈS avoir
-- déployé le commit "scoring serveur des quiz" (server action
-- submitQuizAttempt + sync-offline en service-role). Avant ce déploiement,
-- l'ancien runner client a besoin des policies supprimées ici.
--
-- Contexte : les scores de quiz étaient calculés côté navigateur et
-- insérés par le client (policies RLS insert/update self). Un stagiaire
-- pouvait donc falsifier score / percentage / passed via l'API REST,
-- y compris en mode examen. Le code calcule désormais tout côté serveur ;
-- ce script ferme le chemin d'écriture direct.
-- =====================================================================

-- 1) Plus d'INSERT direct par le client : la server action (service-role)
--    est le seul point d'entrée. Idem pour l'UPDATE (aucun flux client
--    ne modifiait quiz_attempts ; les RPC SECURITY DEFINER et les server
--    actions service-role ne sont pas affectées).
DROP POLICY IF EXISTS quiz_attempts_insert_self ON public.quiz_attempts;
DROP POLICY IF EXISTS quiz_attempts_update_self ON public.quiz_attempts;

-- 2) mark_attempt_awaiting_review : le paramètre p_qcm_score était écrit
--    tel quel dans la tentative → un stagiaire pouvait forger son score
--    QCM (70 % de la note finale) en appelant la RPC directement.
--    Le qcm_score est désormais posé par le serveur à l'INSERT : la RPC
--    conserve sa signature (compat appels existants) mais IGNORE le
--    paramètre.
CREATE OR REPLACE FUNCTION public.mark_attempt_awaiting_review(p_attempt uuid, p_qcm_score numeric DEFAULT NULL::numeric)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'auth', 'pg_temp'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_attempt_owner uuid;
  v_quiz uuid;
  v_module uuid;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'unauthenticated'; END IF;

  SELECT user_id, quiz_id INTO v_attempt_owner, v_quiz
  FROM public.quiz_attempts WHERE id = p_attempt;
  IF v_attempt_owner != v_uid THEN RAISE EXCEPTION 'forbidden'; END IF;

  -- p_qcm_score volontairement IGNORÉ (le score serveur fait foi).
  UPDATE public.quiz_attempts
  SET status = 'awaiting_review',
      finished_at = COALESCE(finished_at, now())
  WHERE id = p_attempt;

  SELECT module_id INTO v_module FROM public.quizzes WHERE id = v_quiz;

  -- Notification aux formateurs habilités, via les 2 chemins de
  -- rattachement, dédupliqués (DISTINCT).
  BEGIN
    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    SELECT DISTINCT
      tf.trainer_id,
      'system',
      'Copie à corriger',
      'Une nouvelle copie est en attente de correction.',
      '/formateur/corrections/' || p_attempt::text
    FROM public.trainer_formations tf
    WHERE tf.can_grade = true
      AND (
        -- Chemin 1 : quiz global rattaché via formation_quizzes
        tf.formation_id IN (
          SELECT fq.formation_id
          FROM public.formation_quizzes fq
          WHERE fq.quiz_id = v_quiz
        )
        OR
        -- Chemin 2 : quiz de bloc rattaché via module → formation_modules
        (v_module IS NOT NULL AND tf.formation_id IN (
          SELECT fm.formation_id
          FROM public.formation_modules fm
          WHERE fm.module_id = v_module
        ))
      );
  EXCEPTION WHEN OTHERS THEN
    -- On loggue mais on ne bloque pas la mise en awaiting_review
    RAISE WARNING 'mark_attempt_awaiting_review notif failed: %', SQLERRM;
  END;
END;
$function$;

-- ── Vérifications post-application ───────────────────────────────────
-- a) Plus de policies INSERT/UPDATE self :
--    SELECT policyname, cmd FROM pg_policies WHERE tablename='quiz_attempts';
--    → attendu : attempts_admin_delete (DELETE) + attempts_self_read (SELECT)
-- b) Un stagiaire connecté ne peut plus insérer :
--    (depuis le SQL editor, en simulant le rôle authenticated, l'INSERT
--    dans quiz_attempts doit échouer avec "row-level security policy")
-- c) Passer un quiz d'entraînement ET un examen depuis l'UI : la
--    tentative apparaît dans /stats avec le bon score.
