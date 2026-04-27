-- =====================================================================
-- Permissions v2 — ÉTAPE 1 : ajout de 'super_admin' à l'enum user_role.
-- À jouer SEUL, puis exécuter permissions_v2_step2.sql dans une seconde
-- requête (Postgres exige un commit entre l'ajout enum et son usage).
-- =====================================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum
    WHERE enumlabel = 'super_admin'
      AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'user_role')
  ) THEN
    ALTER TYPE user_role ADD VALUE 'super_admin';
  END IF;
END $$;
