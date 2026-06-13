-- =====================================================================
-- FIX DATA — Force la création d'enrollments GOTRM pour TOUS les
-- comptes admin/super_admin/trainer (Sfaxi x2, Nassim, Abdel).
--
-- Idempotent : ne crée que les enrollments manquants.
-- Force aussi tous les enrollments existants à status='en_cours'
-- pour qu'ils apparaissent dans le pipeline admin.
-- =====================================================================

DO $$
DECLARE
  v_gotrm_id uuid;
  v_capa_id uuid;
  v_user_id uuid;
  v_email text;
  v_inserted int := 0;
  v_updated int := 0;
BEGIN
  -- Récupère les formations principales
  SELECT id INTO v_gotrm_id FROM public.formations WHERE slug = 'gotrm';
  SELECT id INTO v_capa_id  FROM public.formations WHERE slug = 'capacite-3-5t';

  IF v_gotrm_id IS NULL THEN
    RAISE EXCEPTION 'Formation GOTRM introuvable.';
  END IF;

  -- Pour tous les comptes non-super-admin-funder (= comptes "humains"
  -- qui devraient avoir un enrollment de démo)
  FOR v_user_id, v_email IN
    SELECT id, email FROM public.profiles
     WHERE role IN ('student', 'admin', 'super_admin', 'trainer')
       AND email NOT LIKE '%@test.local'   -- skip les comptes E2E qui sont déjà OK
  LOOP
    -- Si pas d'enrollment GOTRM existant : crée
    IF NOT EXISTS (
      SELECT 1 FROM public.enrollments
       WHERE user_id = v_user_id
         AND (formation_id = v_gotrm_id OR formation_slug = 'gotrm')
    ) THEN
      INSERT INTO public.enrollments (
        user_id, formation_id, formation_slug,
        funding_kind, session_label, status, pack,
        total_amount_cents, paid_amount_cents,
        start_date
      ) VALUES (
        v_user_id, v_gotrm_id, 'gotrm',
        'auto',
        'gotrm-2026-demo-' || substring(v_user_id::text, 1, 8),
        'en_cours',
        'initial',
        1490 * 100,  -- 1490 €
        1490 * 100,  -- payé en totalité (démo)
        current_date - interval '14 days'  -- inscrit il y a 2 sem
      );
      v_inserted := v_inserted + 1;
      RAISE NOTICE '  ✓ % : enrollment GOTRM créé', v_email;
    ELSE
      -- Force le status en en_cours si jamais l'enrollment existait
      -- avec un autre statut (prospect, devis, etc.)
      UPDATE public.enrollments
         SET status = 'en_cours',
             paid_amount_cents = GREATEST(paid_amount_cents, total_amount_cents),
             total_amount_cents = GREATEST(total_amount_cents, 1490 * 100)
       WHERE user_id = v_user_id
         AND (formation_id = v_gotrm_id OR formation_slug = 'gotrm')
         AND status NOT IN ('en_cours','termine');
      IF FOUND THEN
        v_updated := v_updated + 1;
        RAISE NOTICE '  ↻ % : enrollment GOTRM forcé en en_cours', v_email;
      END IF;
    END IF;
  END LOOP;

  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE '  Enrollments créés ........................ %', v_inserted;
  RAISE NOTICE '  Enrollments forcés en en_cours ........... %', v_updated;
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
END $$;

-- Vérification finale — TOUS les enrollments avec leur user
SELECT
  p.email,
  p.role                          AS user_role,
  e.formation_slug,
  e.status,
  e.session_label,
  (e.total_amount_cents / 100)::int AS total_eur,
  (e.paid_amount_cents / 100)::int  AS paye_eur,
  e.created_at::date                AS cree_le
FROM public.enrollments e
JOIN public.profiles p ON p.id = e.user_id
ORDER BY p.email, e.created_at DESC;
