-- =====================================================================
-- HOTFIX UX — Ajout des champs adresse à enrollment_requests
-- 2026-05-19
--
-- Le formulaire public /contact ne collectait pas adresse/CP/ville,
-- ce qui forçait l'admin à les redemander au prospect quand il
-- créait son compte stagiaire (champ obligatoire pour la facturation
-- et les attestations Qualiopi).
--
-- Cette migration ajoute les 3 colonnes pour que le formulaire public
-- puisse les capturer dès le 1er contact → pré-remplissage automatique
-- du formulaire admin /admin/users/new lors de la conversion du lead.
-- =====================================================================

ALTER TABLE public.enrollment_requests
  ADD COLUMN IF NOT EXISTS adresse text,
  ADD COLUMN IF NOT EXISTS code_postal text,
  ADD COLUMN IF NOT EXISTS ville text;

DO $$
DECLARE
  n_total int;
BEGIN
  SELECT count(*) INTO n_total FROM public.enrollment_requests;
  RAISE NOTICE '════════ enrollment_requests : adresse/CP/ville ════════';
  RAISE NOTICE '  Total des leads existants .................... %', n_total;
  RAISE NOTICE '  Les nouveaux leads seront capturés avec adresse';
  RAISE NOTICE '═══════════════════════════════════════════════════════';
END $$;
