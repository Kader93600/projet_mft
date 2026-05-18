-- =====================================================================
-- Hotfix : quiz_attempts.percentage + passed nullables pour QR-only
-- 2026-05-18
--
-- Bug observé : un stagiaire soumet un quiz UNIQUEMENT QR (totalQcm = 0).
-- Le code app envoie `percentage = null` (et `passed = null` quand hasQr,
-- en attente de correction formateur), ce qui viole la contrainte NOT NULL
-- de la table d'origine (schema.sql).
--
-- L'architecture cible (depuis qr_grading.sql) utilise :
--   - `qcm_score`        : score auto QCM (nullable)
--   - `qr_score`         : score manuel cumulé QR (nullable, rempli par formateur)
--   - `final_percentage` : (qcm_score + qr_score) / max (nullable, rempli à la finalisation)
--   - `final_passed`     : booléen final (nullable, rempli à la finalisation)
--
-- Les anciennes colonnes `percentage` et `passed` étaient utilisées avant
-- l'arrivée des QR ; on les conserve pour la compatibilité descendante
-- (le code app les lit encore dans /stats et dashboard) mais elles
-- doivent être nullables.
--
-- Migration sûre : DROP NOT NULL ne perd aucune donnée existante.
-- =====================================================================

ALTER TABLE public.quiz_attempts
  ALTER COLUMN percentage DROP NOT NULL,
  ALTER COLUMN passed     DROP NOT NULL,
  ALTER COLUMN score      DROP NOT NULL,
  ALTER COLUMN total      DROP NOT NULL;

COMMENT ON COLUMN public.quiz_attempts.percentage IS
  'Score auto QCM (% bonnes réponses sur le total QCM). NULL si quiz QR-only.
   Pour le score FINAL (QCM + QR pondéré), voir final_percentage.';

COMMENT ON COLUMN public.quiz_attempts.passed IS
  'Réussite basée sur le seuil QCM. NULL si quiz QR-only (en attente de
   correction formateur). Pour la réussite FINALE, voir final_passed.';
