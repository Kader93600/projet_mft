-- =====================================================================
-- ROLLBACK — Marketplace formateurs externes (P3 #2 Sprint D)
-- 2026-05-20
--
-- Décision client : abandon de la feature Marketplace de formateurs
-- externes. On annule donc la migration 2026_05_19_marketplace.sql.
--
-- Ce script :
--   1. Supprime les tables marketplace (trainer_payouts, trainer_revenue_events)
--   2. Supprime la vue trainer_revenue_summary
--   3. Supprime les colonnes marketplace_* + created_by sur modules
--
-- ⚠️ Si des données existent en prod (peu probable car aucun trainer
-- partenaire n'avait été activé), elles seront perdues. Pas d'usage
-- détecté côté client → safe à exécuter.
-- =====================================================================

-- 1. Drop la vue agrégée
DROP VIEW IF EXISTS public.trainer_revenue_summary;

-- 2. Drop les tables
DROP TABLE IF EXISTS public.trainer_revenue_events;
DROP TABLE IF EXISTS public.trainer_payouts;

-- 3. Drop les colonnes sur modules
ALTER TABLE public.modules
  DROP COLUMN IF EXISTS created_by,
  DROP COLUMN IF EXISTS marketplace_status,
  DROP COLUMN IF EXISTS marketplace_price_cents,
  DROP COLUMN IF EXISTS marketplace_published_at,
  DROP COLUMN IF EXISTS marketplace_reviewer_id,
  DROP COLUMN IF EXISTS marketplace_review_notes;

-- 4. Drop les index dépendants (si pas déjà supprimés via DROP COLUMN)
DROP INDEX IF EXISTS public.modules_created_by_idx;
DROP INDEX IF EXISTS public.modules_marketplace_idx;
