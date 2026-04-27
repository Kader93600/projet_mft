-- =====================================================================
-- Espace Formateur — ÉTAPE 1 : ajout de la valeur 'trainer' à l'enum.
-- À jouer SEUL, puis exécuter trainer_role_step2.sql dans une seconde
-- requête (Postgres exige un commit entre l'ajout enum et son usage).
-- =====================================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum
    WHERE enumlabel = 'trainer'
      AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'user_role')
  ) THEN
    ALTER TYPE user_role ADD VALUE 'trainer';
  END IF;
END $$;
