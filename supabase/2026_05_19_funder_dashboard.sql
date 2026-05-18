-- =====================================================================
-- P3 #2 / Sprint B — Dashboard financeur enrichi
-- 2026-05-19
--
-- Étend l'existant (table funders + funder_overview + RLS portail).
-- Ajoute :
--   • Vue funder_student_details : drill-down stagiaire par stagiaire
--   • Vue funder_recent_events : timeline d'événements (entrée formation,
--     1er examen blanc, certification)
--   • Triggers de notification au financeur sur jalons
--   • RPC d'aggregation pour les KPIs temps réel
--
-- Décisions client (cf. docs/p3-2-business.md) — par défaut :
--   • Notification : email + dashboard
--   • Granularité : pas de messages stagiaire ↔ formateur (RGPD)
--   • Exports : PDF + CSV + JSON
--   • Cofinancement : pas géré en v1 (1 financeur par enrollment)
-- =====================================================================

-- ─────────────────────────────────────────────────────────────────────
-- 1. Vue funder_student_details : drill-down par stagiaire
-- ─────────────────────────────────────────────────────────────────────
-- Sécurité : on définit la vue avec security_invoker pour que la RLS
-- existante sur enrollments (enrollments_funder_read) s'applique
-- automatiquement.
CREATE OR REPLACE VIEW public.funder_student_details
WITH (security_invoker = on)
AS
SELECT
  e.id AS enrollment_id,
  e.funder_id,
  p.id AS user_id,
  p.full_name,
  p.email,
  p.phone,
  f.title AS formation_title,
  f.slug AS formation_slug,
  f.code AS formation_code,
  e.pack,
  e.status,
  e.funding_kind,
  e.total_amount_cents,
  e.paid_amount_cents,
  e.created_at AS enrollment_created_at,
  e.start_date,
  e.end_date,
  e.session_label,
  e.cpf_dossier_ref,
  -- Progression pédagogique : nombre de leçons faites sur le total
  (
    SELECT count(*)::int
    FROM public.lesson_progress lp
    JOIN public.lessons l ON l.id = lp.lesson_id
    JOIN public.modules m ON m.id = l.module_id
    JOIN public.formation_modules fm ON fm.module_id = m.id
    WHERE lp.user_id = p.id
      AND lp.completed = true
      AND fm.formation_id = f.id
  ) AS lessons_done,
  (
    SELECT count(*)::int
    FROM public.lessons l
    JOIN public.modules m ON m.id = l.module_id
    JOIN public.formation_modules fm ON fm.module_id = m.id
    WHERE fm.formation_id = f.id
  ) AS lessons_total,
  -- Score moyen sur les attempts de la formation (% sur les quiz avec percentage non null)
  (
    SELECT round(avg(percentage))::int
    FROM public.quiz_attempts qa
    WHERE qa.user_id = p.id
      AND qa.formation_id = f.id
      AND qa.percentage IS NOT NULL
  ) AS avg_score,
  -- Examen blanc passé ?
  EXISTS (
    SELECT 1 FROM public.quiz_attempts qa
    JOIN public.quizzes qz ON qz.id = qa.quiz_id
    WHERE qa.user_id = p.id
      AND qa.formation_id = f.id
      AND qz.is_mock_exam = true
      AND qa.finished_at IS NOT NULL
  ) AS mock_exam_attempted,
  -- Certification finale obtenue ?
  EXISTS (
    SELECT 1 FROM public.certificates c
    WHERE c.user_id = p.id
      AND c.type = 'final'
      AND c.revoked_at IS NULL
  ) AS certified,
  -- Dernière activité (lesson_views)
  (
    SELECT max(last_ping_at)
    FROM public.lesson_views
    WHERE user_id = p.id
  ) AS last_active_at,
  -- Jours depuis la dernière activité
  CASE
    WHEN (SELECT max(last_ping_at) FROM public.lesson_views WHERE user_id = p.id) IS NULL THEN NULL
    ELSE EXTRACT(DAY FROM now() - (SELECT max(last_ping_at) FROM public.lesson_views WHERE user_id = p.id))::int
  END AS days_since_last_activity
FROM public.enrollments e
JOIN public.profiles p ON p.id = e.user_id
JOIN public.formations f ON f.id = e.formation_id
WHERE e.status NOT IN ('refuse', 'abandon');

GRANT SELECT ON public.funder_student_details TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 2. RPC : funder_dashboard_kpis (résumé temps réel pour /financeur)
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.funder_dashboard_kpis(p_funder_id uuid DEFAULT NULL)
RETURNS TABLE (
  enrollments_total int,
  enrollments_active int,
  enrollments_done int,
  enrollments_at_risk int,           -- inactifs > 14j
  certified_count int,
  avg_progress_pct int,
  avg_score int,
  total_budget_cents int,
  total_paid_cents int
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
  v_funder uuid := p_funder_id;
BEGIN
  -- Si pas d'id fourni, on cherche le funder du user courant
  IF v_funder IS NULL THEN
    SELECT id INTO v_funder FROM public.funders WHERE portal_user_id = auth.uid() LIMIT 1;
  END IF;

  IF v_funder IS NULL AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'funder_not_found';
  END IF;

  RETURN QUERY
  SELECT
    count(*)::int,
    count(*) FILTER (WHERE status = 'en_cours')::int,
    count(*) FILTER (WHERE status = 'termine')::int,
    count(*) FILTER (
      WHERE status = 'en_cours'
        AND (days_since_last_activity IS NULL OR days_since_last_activity > 14)
    )::int,
    count(*) FILTER (WHERE certified = true)::int,
    CASE
      WHEN sum(lessons_total) > 0 THEN
        round((sum(lessons_done)::numeric / sum(lessons_total)::numeric) * 100)::int
      ELSE 0
    END,
    round(avg(avg_score))::int,
    COALESCE(sum(total_amount_cents), 0)::int,
    COALESCE(sum(paid_amount_cents), 0)::int
  FROM public.funder_student_details
  WHERE (v_funder IS NULL AND public.is_admin())
     OR funder_id = v_funder;
END;
$$;

GRANT EXECUTE ON FUNCTION public.funder_dashboard_kpis(uuid) TO authenticated;

-- ─────────────────────────────────────────────────────────────────────
-- 3. Notifications financeur sur jalons
-- ─────────────────────────────────────────────────────────────────────
-- Trigger : quand un stagiaire d'un funder atteint un jalon, on insère
-- une notification destinée au portal_user_id du funder.
-- Jalons :
--   • Premier ping de lesson_view (entrée en formation)
--   • Premier examen blanc passé
--   • Certificat final délivré

CREATE OR REPLACE FUNCTION public.tg_funder_milestone_lesson_view()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_first_ever boolean;
  v_funder_portal uuid;
  v_student_name text;
  v_formation_title text;
BEGIN
  -- Est-ce le tout 1er ping de cet utilisateur ?
  SELECT NOT EXISTS (
    SELECT 1 FROM public.lesson_views lv
    WHERE lv.user_id = NEW.user_id
      AND lv.id <> NEW.id
  ) INTO v_first_ever;

  IF NOT v_first_ever THEN RETURN NEW; END IF;

  -- Cherche un enrollment 'en_cours' avec un funder qui a un portal_user_id
  SELECT f.portal_user_id, p.full_name, fm.title
    INTO v_funder_portal, v_student_name, v_formation_title
    FROM public.enrollments e
    JOIN public.funders f ON f.id = e.funder_id
    JOIN public.profiles p ON p.id = e.user_id
    JOIN public.formations fm ON fm.id = e.formation_id
    WHERE e.user_id = NEW.user_id
      AND e.status = 'en_cours'
      AND f.portal_user_id IS NOT NULL
    LIMIT 1;

  IF v_funder_portal IS NULL THEN RETURN NEW; END IF;

  INSERT INTO public.notifications (user_id, type, title, body, link_url)
  VALUES (
    v_funder_portal,
    'announcement',
    'Démarrage en formation',
    COALESCE(v_student_name, 'Un stagiaire') || ' a démarré sa formation : ' || COALESCE(v_formation_title, 'inscription'),
    '/financeur/stagiaires'
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_funder_milestone_lesson_view ON public.lesson_views;
CREATE TRIGGER tg_funder_milestone_lesson_view
  AFTER INSERT ON public.lesson_views
  FOR EACH ROW EXECUTE FUNCTION public.tg_funder_milestone_lesson_view();

-- Trigger : premier examen blanc réussi
CREATE OR REPLACE FUNCTION public.tg_funder_milestone_mock_exam()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_is_mock boolean;
  v_funder_portal uuid;
  v_student_name text;
  v_formation_title text;
  v_already_notified boolean;
BEGIN
  -- Le quiz est-il un examen blanc ?
  SELECT is_mock_exam INTO v_is_mock FROM public.quizzes WHERE id = NEW.quiz_id;
  IF v_is_mock IS NOT true THEN RETURN NEW; END IF;
  IF NEW.finished_at IS NULL THEN RETURN NEW; END IF;

  -- Déjà notifié pour cet utilisateur ?
  SELECT EXISTS (
    SELECT 1 FROM public.quiz_attempts qa2
    JOIN public.quizzes qz ON qz.id = qa2.quiz_id
    WHERE qa2.user_id = NEW.user_id
      AND qa2.id <> NEW.id
      AND qz.is_mock_exam = true
      AND qa2.finished_at IS NOT NULL
  ) INTO v_already_notified;
  IF v_already_notified THEN RETURN NEW; END IF;

  -- Funder ?
  SELECT f.portal_user_id, p.full_name, fm.title
    INTO v_funder_portal, v_student_name, v_formation_title
    FROM public.enrollments e
    JOIN public.funders f ON f.id = e.funder_id
    JOIN public.profiles p ON p.id = e.user_id
    JOIN public.formations fm ON fm.id = e.formation_id
    WHERE e.user_id = NEW.user_id
      AND f.portal_user_id IS NOT NULL
    LIMIT 1;
  IF v_funder_portal IS NULL THEN RETURN NEW; END IF;

  INSERT INTO public.notifications (user_id, type, title, body, link_url)
  VALUES (
    v_funder_portal,
    'announcement',
    'Premier examen blanc',
    COALESCE(v_student_name, 'Un stagiaire') || ' vient de passer son premier examen blanc.',
    '/financeur/stagiaires'
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_funder_milestone_mock_exam ON public.quiz_attempts;
CREATE TRIGGER tg_funder_milestone_mock_exam
  AFTER INSERT OR UPDATE ON public.quiz_attempts
  FOR EACH ROW EXECUTE FUNCTION public.tg_funder_milestone_mock_exam();

-- Trigger : certificat final
CREATE OR REPLACE FUNCTION public.tg_funder_milestone_certificate()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_funder_portal uuid;
  v_student_name text;
BEGIN
  IF NEW.type <> 'final' THEN RETURN NEW; END IF;

  SELECT f.portal_user_id, p.full_name
    INTO v_funder_portal, v_student_name
    FROM public.enrollments e
    JOIN public.funders f ON f.id = e.funder_id
    JOIN public.profiles p ON p.id = e.user_id
    WHERE e.user_id = NEW.user_id
      AND f.portal_user_id IS NOT NULL
    LIMIT 1;
  IF v_funder_portal IS NULL THEN RETURN NEW; END IF;

  INSERT INTO public.notifications (user_id, type, title, body, link_url)
  VALUES (
    v_funder_portal,
    'certificate',
    'Stagiaire certifié',
    COALESCE(v_student_name, 'Un stagiaire') || ' a obtenu sa certification finale.',
    '/financeur/stagiaires'
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_funder_milestone_certificate ON public.certificates;
CREATE TRIGGER tg_funder_milestone_certificate
  AFTER INSERT ON public.certificates
  FOR EACH ROW EXECUTE FUNCTION public.tg_funder_milestone_certificate();

-- ─────────────────────────────────────────────────────────────────────
-- 4. Vue récente : événements (pour la timeline du dashboard)
-- ─────────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW public.funder_recent_events
WITH (security_invoker = on)
AS
-- Inscriptions récentes
SELECT
  'enrollment' AS event_kind,
  e.id::text AS ref_id,
  e.funder_id,
  e.user_id,
  e.created_at AS occurred_at,
  p.full_name AS student_name,
  f.title AS formation_title,
  e.status
FROM public.enrollments e
JOIN public.profiles p ON p.id = e.user_id
JOIN public.formations f ON f.id = e.formation_id
WHERE e.created_at >= now() - INTERVAL '90 days'
  AND e.status NOT IN ('refuse', 'abandon')

UNION ALL

-- Certifications récentes
SELECT
  'certificate' AS event_kind,
  c.id::text AS ref_id,
  e.funder_id,
  c.user_id,
  c.issued_at AS occurred_at,
  p.full_name AS student_name,
  fo.title AS formation_title,
  'certified' AS status
FROM public.certificates c
JOIN public.profiles p ON p.id = c.user_id
JOIN public.enrollments e ON e.user_id = c.user_id
JOIN public.formations fo ON fo.id = e.formation_id
WHERE c.type = 'final'
  AND c.issued_at >= now() - INTERVAL '90 days'
  AND c.revoked_at IS NULL;

GRANT SELECT ON public.funder_recent_events TO authenticated;
