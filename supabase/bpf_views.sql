-- =====================================================================
-- Vues d'aide pour le Bilan Pédagogique et Financier (DGEFP, annuel)
-- Pré-formatées pour faciliter le report dans le formulaire CERFA.
-- =====================================================================

-- Heures réalisées par stagiaire sur l'année écoulée
-- (estimation conservatrice : 0.5 h par leçon + durée signature présente)
CREATE OR REPLACE FUNCTION public.bpf_hours_for_year(p_year int)
RETURNS TABLE (
  user_id uuid,
  email text,
  full_name text,
  hours_done numeric
) LANGUAGE sql STABLE AS $$
  WITH lessons AS (
    SELECT lp.user_id,
           sum(CASE
             WHEN lp.completed THEN COALESCE(lp.duration_seconds / 3600.0, 0.5)
             ELSE COALESCE(lp.duration_seconds / 3600.0, 0)
           END) AS h
    FROM public.lesson_progress lp
    WHERE EXTRACT(YEAR FROM coalesce(lp.completed_at, lp.updated_at, lp.created_at))::int = p_year
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

-- Recettes par financeur sur l'année (à partir de payment_schedule.paid_at)
CREATE OR REPLACE VIEW public.bpf_revenue_by_funder AS
SELECT
  EXTRACT(YEAR FROM ps.paid_at)::int AS year,
  COALESCE(f.kind, e.funding_kind, 'auto') AS funding_kind,
  COALESCE(f.name, 'Auto-financement / particulier') AS funder_name,
  count(DISTINCT e.user_id)  AS stagiaires_count,
  sum(ps.paid_amount_cents)  AS revenue_cents
FROM public.payment_schedule ps
JOIN public.enrollments e ON e.id = ps.enrollment_id
LEFT JOIN public.funders f ON f.id = e.funder_id
WHERE ps.paid_at IS NOT NULL
GROUP BY year, funding_kind, funder_name
ORDER BY year DESC, revenue_cents DESC;

GRANT SELECT ON public.bpf_revenue_by_funder TO authenticated;

-- Synthèse annuelle (1 ligne par année) — chiffres clés du BPF
CREATE OR REPLACE FUNCTION public.bpf_summary(p_year int)
RETURNS jsonb LANGUAGE plpgsql STABLE AS $$
DECLARE
  res jsonb;
BEGIN
  SELECT jsonb_build_object(
    'year', p_year,
    'stagiaires_total', (
      SELECT count(DISTINCT user_id)
      FROM public.bpf_hours_for_year(p_year)
      WHERE hours_done > 0
    ),
    'heures_realisees', (
      SELECT round(sum(hours_done)::numeric, 1)
      FROM public.bpf_hours_for_year(p_year)
    ),
    'recettes_par_financeur', (
      SELECT coalesce(jsonb_agg(jsonb_build_object(
        'kind', funding_kind,
        'name', funder_name,
        'stagiaires', stagiaires_count,
        'recette_eur', round(revenue_cents / 100.0, 2)
      )), '[]'::jsonb)
      FROM public.bpf_revenue_by_funder
      WHERE year = p_year
    ),
    'recette_totale_eur', (
      SELECT coalesce(round(sum(revenue_cents) / 100.0, 2), 0)
      FROM public.bpf_revenue_by_funder
      WHERE year = p_year
    )
  ) INTO res;
  RETURN res;
END;
$$;

GRANT EXECUTE ON FUNCTION public.bpf_summary(int) TO authenticated;
