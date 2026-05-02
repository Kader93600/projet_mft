-- =====================================================================
-- MIGRATION — formation_settings : singleton → multi-formations
--
-- Avant : 1 seule ligne (id boolean = true) pour TOUT l'organisme.
--         → impossible de gérer un programme par formation.
--
-- Après : 1 ligne par formation (PK = formation_id, FK → formations).
--         → /admin/settings/formation peut gérer les 8 formations.
--
-- Idempotent : peut être rejoué sans casse.
-- =====================================================================

-- ─── 1) Ajout de la colonne formation_id ──────────────────────────────
ALTER TABLE public.formation_settings
  ADD COLUMN IF NOT EXISTS formation_id uuid
  REFERENCES public.formations(id) ON DELETE CASCADE;

-- ─── 2) Migration de la ligne singleton existante vers GOTRM ────────
DO $mig$
DECLARE
  v_gotrm uuid;
  v_existing_count int;
BEGIN
  SELECT id INTO v_gotrm FROM public.formations WHERE slug = 'gotrm';

  -- Compter les lignes existantes
  SELECT count(*) INTO v_existing_count FROM public.formation_settings;

  IF v_existing_count = 1 AND v_gotrm IS NOT NULL THEN
    -- Si on a la ligne singleton historique sans formation_id, on la rattache à GOTRM
    UPDATE public.formation_settings
       SET formation_id = v_gotrm
     WHERE formation_id IS NULL;
  END IF;
END $mig$;

-- ─── 3) Suppression de l'ancienne contrainte PK singleton ───────────
DO $pk$
BEGIN
  -- Drop l'ancien check 'id boolean PRIMARY KEY DEFAULT true'
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'formation_settings_pkey'
      AND conrelid = 'public.formation_settings'::regclass
  ) THEN
    ALTER TABLE public.formation_settings DROP CONSTRAINT formation_settings_pkey;
  END IF;

  -- La colonne id est obsolète — on la conserve par sécurité mais elle
  -- n'est plus utilisée. Supprimer le check si présent.
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.formation_settings'::regclass
      AND contype = 'c'
  ) THEN
    -- (Pas de drop générique — on laisse Postgres gérer)
    NULL;
  END IF;
END $pk$;

-- ─── 4) Nouvelle PK : formation_id ───────────────────────────────────
DO $newpk$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.formation_settings'::regclass
      AND contype = 'p'
  ) THEN
    -- Avant la PK, formation_id doit être NOT NULL et unique
    UPDATE public.formation_settings
       SET formation_id = (SELECT id FROM public.formations WHERE slug = 'gotrm')
     WHERE formation_id IS NULL;

    ALTER TABLE public.formation_settings
      ALTER COLUMN formation_id SET NOT NULL;

    ALTER TABLE public.formation_settings
      ADD CONSTRAINT formation_settings_pkey PRIMARY KEY (formation_id);
  END IF;
END $newpk$;

-- ─── 5) Initialiser les paramètres pour les 7 autres formations ─────
-- Crée une ligne par formation manquante avec des valeurs par défaut
-- inspirées du catalogue (formations-config.ts).
DO $seed$
DECLARE
  f record;
BEGIN
  FOR f IN
    SELECT id, slug, code, title, level
      FROM public.formations
     WHERE active = true
     ORDER BY code
  LOOP
    INSERT INTO public.formation_settings (
      formation_id,
      organisme_nom,
      formation_titre,
      formation_rncp,
      formation_duree_h,
      formation_public,
      formation_prerequis,
      formation_objectifs,
      formation_methodes,
      formation_evaluation,
      formation_handicap,
      formation_delai_acces
    )
    VALUES (
      f.id,
      'MA FORMATION TRANSPORT',
      f.title,
      CASE WHEN f.level IS NOT NULL THEN
        'Formation niveau ' || f.level::text || ' (' || f.code || ')'
      ELSE
        'Formation professionnelle ' || f.code
      END,
      CASE f.slug
        WHEN 'gotrm' THEN 700
        WHEN 'capacite-3-5t' THEN 105
        WHEN 'capacite-plus-3-5t' THEN 140
        WHEN 'fimo-fco' THEN 140
        WHEN 'ertv' THEN 105
        WHEN 'ecsr' THEN 1200
        WHEN 'taxi-vtc' THEN 250
        WHEN 'commissionnaire' THEN 105
        ELSE 100
      END,
      'Demandeurs d''emploi, salariés en évolution, créateurs et repreneurs d''entreprise du secteur transport.',
      'Niveau de connaissances de base en gestion. Maîtrise du français écrit et oral.',
      E'À définir selon les compétences visées par la formation.\n\nVoir page publique pour le détail.',
      E'- Formation mixte : présentiel + plateforme e-learning\n- Cours interactifs, quiz, examens blancs\n- Accompagnement pédagogique personnalisé\n- Plateforme accessible 24h/24 et 7j/7',
      E'- Évaluations formatives en cours de parcours (quiz)\n- Examens blancs en conditions réelles\n- Évaluation à chaud et à froid de la satisfaction\n- Épreuves officielles devant jury (selon référentiel)',
      'Les personnes en situation de handicap sont invitées à contacter notre référent handicap afin d''étudier les adaptations nécessaires au bon déroulement de la formation.',
      '7 jours ouvrés entre la demande d''inscription et l''entrée en formation.'
    )
    ON CONFLICT (formation_id) DO NOTHING;
  END LOOP;

  RAISE NOTICE 'formation_settings : initialisé pour toutes les formations actives.';
END $seed$;

-- ─── 6) Index sur formation_id (PK couvre déjà mais explicite) ──────
CREATE INDEX IF NOT EXISTS formation_settings_formation_idx
  ON public.formation_settings(formation_id);
