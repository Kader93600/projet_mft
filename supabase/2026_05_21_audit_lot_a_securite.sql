-- =====================================================================
-- AUDIT LOT A — Corrections sécurité & légal
-- 2026-05-20
--
-- Regroupe 4 fixes SQL identifiés par l'audit technique :
--   #3 — Policies INSERT contradictoires sur quiz_attempts
--   #6 — Fuite RLS : note QR lisible avant publication
--   #7 — BPF cassé (colonnes inexistantes sur lesson_progress)
--   #8 — Triggers handicap/RGPD bloqués (colonne kind inexistante)
-- =====================================================================


-- ─────────────────────────────────────────────────────────────────────
-- #3 — quiz_attempts : supprime la policy INSERT permissive en doublon
-- ─────────────────────────────────────────────────────────────────────
-- Deux policies INSERT coexistaient :
--   - attempts_self_insert (security.sql)  : with check (auth.uid()=user_id)
--   - quiz_attempts_insert_self (multi_formation_sprint1) : + contrainte
--     formation via user_has_formation(formation_id)
-- Les policies PERMISSIVE se cumulent en OR → la plus permissive
-- (sans contrainte formation) l'emportait, neutralisant l'isolation.
-- Fix : on garde uniquement la version avec contrainte formation.

DROP POLICY IF EXISTS "attempts_self_insert" ON public.quiz_attempts;

-- On s'assure que la bonne policy existe (idempotent)
DROP POLICY IF EXISTS quiz_attempts_insert_self ON public.quiz_attempts;
CREATE POLICY quiz_attempts_insert_self ON public.quiz_attempts
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND (
      formation_id IS NULL
      OR public.user_has_formation(formation_id)
    )
  );


-- ─────────────────────────────────────────────────────────────────────
-- #6 — qr_responses : ne pas exposer la note avant publication
-- ─────────────────────────────────────────────────────────────────────
-- La policy qr_responses_self_read laissait le stagiaire lire TOUTES
-- les colonnes (dont trainer_score, trainer_comment, ai_*) dès que
-- l'attempt lui appartenait, sans attendre status='graded'. Un
-- stagiaire requêtant l'API directement voyait sa note/correction
-- avant validation formateur.
--
-- Fix : on restreint la lecture aux copies finalisées (graded). Pendant
-- l'attente de correction, le stagiaire ne lit plus ses qr_responses
-- via l'API (le quiz-runner garde ses réponses en mémoire locale
-- juste après soumission, donc pas de régression d'affichage immédiat).

DROP POLICY IF EXISTS qr_responses_self_read ON public.qr_responses;
CREATE POLICY qr_responses_self_read ON public.qr_responses
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.quiz_attempts a
      WHERE a.id = qr_responses.attempt_id
        AND a.user_id = auth.uid()
        AND a.status = 'graded'
    )
  );


-- ─────────────────────────────────────────────────────────────────────
-- #7 — BPF : bpf_hours_for_year référençait des colonnes inexistantes
-- ─────────────────────────────────────────────────────────────────────
-- lesson_progress ne contient que: completed, completed_at (pas de
-- duration_seconds, updated_at, created_at). La fonction crashait
-- avec 42703 → export BPF + dashboard BPF non générables (obligation
-- légale DGEFP).
--
-- Fix : estimation conservatrice 0.5h par leçon complétée, filtre
-- année via completed_at uniquement. La part "présentiel" via
-- attendance_signatures reste inchangée (colonnes valides).

CREATE OR REPLACE FUNCTION public.bpf_hours_for_year(p_year int)
RETURNS TABLE (
  user_id uuid,
  email text,
  full_name text,
  hours_done numeric
) LANGUAGE sql STABLE
SET search_path = public, auth, pg_temp
AS $$
  WITH lessons AS (
    SELECT lp.user_id,
           sum(CASE WHEN lp.completed THEN 0.5 ELSE 0 END) AS h
    FROM public.lesson_progress lp
    WHERE lp.completed_at IS NOT NULL
      AND EXTRACT(YEAR FROM lp.completed_at)::int = p_year
    GROUP BY lp.user_id
  ),
  attendance AS (
    SELECT a.user_id,
           sum(EXTRACT(EPOCH FROM (s.ends_at - s.starts_at)) / 3600.0) AS h
    FROM public.attendance_signatures a
    JOIN public.attendance_sessions s ON s.id = a.session_id
    WHERE EXTRACT(YEAR FROM a.signed_at)::int = p_year
    GROUP BY a.user_id
  )
  SELECT
    p.id        AS user_id,
    p.email,
    p.full_name,
    coalesce((SELECT h FROM lessons WHERE lessons.user_id = p.id), 0)
      + coalesce((SELECT h FROM attendance WHERE attendance.user_id = p.id), 0)
      AS hours_done
  FROM public.profiles p
  WHERE p.role = 'student';
$$;

GRANT EXECUTE ON FUNCTION public.bpf_hours_for_year(int) TO authenticated;


-- ─────────────────────────────────────────────────────────────────────
-- #8 — Triggers handicap & RGPD : colonne kind → type + valeur valide
-- ─────────────────────────────────────────────────────────────────────
-- tg_a11y_notify (accessibility.sql) et tg_deletion_notify (privacy.sql)
-- font INSERT INTO notifications(user_id, kind, ...) alors que la
-- colonne s'appelle `type`, ET utilisent des valeurs ('a11y_request',
-- 'deletion_request') hors du CHECK (type IN ('announcement','message',
-- 'system','quiz_result')). Double échec → impossible de soumettre une
-- demande d'adaptation handicap ou une suppression RGPD (art. 17).
--
-- Fix : on recrée les 2 fonctions avec type='system' (valeur valide)
-- et le bon nom de colonne. On préfixe le titre pour garder le contexte.

-- a11y : on préserve INTÉGRALEMENT la logique d'origine (branches
-- INSERT + UPDATE avec set resolved_at). On change uniquement :
--   - colonne kind → type
--   - valeur 'a11y_request' → 'system' (conforme au CHECK)
--   - role='admin' → role IN ('admin','super_admin') (sinon les
--     super_admin ne reçoivent rien — cas client actuel)
CREATE OR REPLACE FUNCTION public.tg_a11y_notify()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE
  a record;
BEGIN
  IF TG_OP = 'INSERT' THEN
    FOR a IN
      SELECT id FROM public.profiles WHERE role IN ('admin', 'super_admin')
    LOOP
      INSERT INTO public.notifications (user_id, type, title, body, link_url)
      VALUES (
        a.id,
        'system',
        'Nouvelle demande d''adaptation',
        'Un stagiaire a soumis une demande auprès du référent handicap.',
        '/admin/accessibilite'
      );
    END LOOP;
  ELSIF TG_OP = 'UPDATE' AND NEW.status IS DISTINCT FROM OLD.status THEN
    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    VALUES (
      NEW.user_id,
      'system',
      'Demande d''adaptation mise à jour',
      'Votre demande est désormais : ' || NEW.status,
      '/accessibilite'
    );
    IF NEW.status IN ('valide','refuse','clos') AND NEW.resolved_at IS NULL THEN
      NEW.resolved_at := now();
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

-- RGPD : même logique d'origine, kind→type + 'deletion_request'→'system'
-- + élargissement super_admin.
CREATE OR REPLACE FUNCTION public.tg_deletion_notify()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, auth, pg_temp
AS $$
DECLARE a record;
BEGIN
  FOR a IN
    SELECT id FROM public.profiles WHERE role IN ('admin', 'super_admin')
  LOOP
    INSERT INTO public.notifications (user_id, type, title, body, link_url)
    VALUES (
      a.id,
      'system',
      'Demande de suppression de compte',
      'Un utilisateur a demandé l''effacement de ses données (RGPD art. 17).',
      '/admin/rgpd'
    );
  END LOOP;
  RETURN NEW;
END;
$$;


-- ─────────────────────────────────────────────────────────────────────
-- Vérification
-- ─────────────────────────────────────────────────────────────────────
DO $$
DECLARE
  n_insert_policies int;
BEGIN
  SELECT count(*) INTO n_insert_policies
    FROM pg_policies
   WHERE schemaname = 'public'
     AND tablename = 'quiz_attempts'
     AND cmd = 'INSERT';

  RAISE NOTICE '════════ AUDIT LOT A — Sécurité ════════';
  RAISE NOTICE '  Policies INSERT sur quiz_attempts : % (attendu 1)', n_insert_policies;
  RAISE NOTICE '  qr_responses_self_read : gate status=graded ajouté';
  RAISE NOTICE '  bpf_hours_for_year : recréée (0.5h/leçon, completed_at)';
  RAISE NOTICE '  tg_a11y_notify + tg_deletion_notify : type au lieu de kind';
  RAISE NOTICE '═══════════════════════════════════════';
  IF n_insert_policies > 1 THEN
    RAISE WARNING 'Il reste % policies INSERT — vérifier les doublons', n_insert_policies;
  END IF;
END $$;
