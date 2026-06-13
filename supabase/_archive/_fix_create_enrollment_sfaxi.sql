-- =====================================================================
-- FIX DATA — Crée un enrollment GOTRM pour les comptes Sfaxi
-- À jouer dans Supabase Studio UNIQUEMENT SI sections B/C du diagnostic
-- confirment que Sfaxi n'a pas d'enrollment.
--
-- Idempotent : si un enrollment existe déjà pour ce user_id sur GOTRM,
-- ne fait rien (UNIQUE (user_id, session_label) sur enrollments).
-- =====================================================================

DO $$
DECLARE
  v_gotrm_id uuid;
  v_user_id uuid;
  v_inserted int := 0;
  v_skipped int := 0;
  v_email text;
BEGIN
  -- Récupère l'id GOTRM
  SELECT id INTO v_gotrm_id
    FROM public.formations
   WHERE slug = 'gotrm' AND active = true;

  IF v_gotrm_id IS NULL THEN
    RAISE EXCEPTION 'Formation GOTRM introuvable ou inactive — abort.';
  END IF;

  -- Pour chaque profil Sfaxi (par email), crée un enrollment GOTRM
  -- si pas déjà présent. session_label = 'gotrm-2026' pour respecter
  -- la contrainte UNIQUE (user_id, session_label).
  FOR v_user_id, v_email IN
    SELECT id, email FROM public.profiles
     WHERE email ILIKE '%sfaxi%'
        OR full_name ILIKE '%sfaxi%'
  LOOP
    -- Aussi : promouvoir en role='student' si pas déjà admin/super_admin
    -- (sinon le user resterait coincé sur sa session sans pouvoir
    --  accéder au dashboard stagiaire avec un parcours réel)
    UPDATE public.profiles
       SET role = 'student'
     WHERE id = v_user_id
       AND role NOT IN ('admin','super_admin','trainer');

    -- Vérifie si un enrollment GOTRM existe déjà
    IF EXISTS (
      SELECT 1 FROM public.enrollments
       WHERE user_id = v_user_id
         AND (formation_id = v_gotrm_id OR formation_slug = 'gotrm')
    ) THEN
      v_skipped := v_skipped + 1;
      RAISE NOTICE '  ⏭  % : enrollment GOTRM déjà existant', v_email;
      CONTINUE;
    END IF;

    -- Crée l'enrollment (statut en_cours pour accès immédiat)
    INSERT INTO public.enrollments (
      user_id,
      formation_id,
      formation_slug,
      funding_kind,
      session_label,
      status,
      pack,
      total_amount_cents,
      paid_amount_cents
    ) VALUES (
      v_user_id,
      v_gotrm_id,
      'gotrm',
      'auto',
      'gotrm-2026-hotfix',
      'en_cours',
      'initial',
      0,
      0
    );

    v_inserted := v_inserted + 1;
    RAISE NOTICE '  ✓ % : enrollment GOTRM créé', v_email;
  END LOOP;

  RAISE NOTICE '═══════════════════════════════════════════════════════════';
  RAISE NOTICE '  Enrollments créés ........................ %', v_inserted;
  RAISE NOTICE '  Déjà existants (skippés) ................. %', v_skipped;
  RAISE NOTICE '═══════════════════════════════════════════════════════════';
END $$;

-- Vérification finale
SELECT
  p.email,
  p.role,
  e.formation_slug,
  e.formation_id IS NOT NULL AS has_formation_id,
  e.status,
  e.session_label
FROM public.profiles p
LEFT JOIN public.enrollments e ON e.user_id = p.id
WHERE p.email ILIKE '%sfaxi%' OR p.full_name ILIKE '%sfaxi%'
ORDER BY p.email, e.created_at DESC;
