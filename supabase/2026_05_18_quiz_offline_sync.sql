-- =====================================================================
-- Sprint 2 / PWA — Quiz offline + sync différée
-- 2026-05-18
--
-- Objectif : permettre au stagiaire de passer un quiz d'entraînement
-- QCM (pas QR, pas examen blanc) sans connexion. La tentative est
-- stockée dans IndexedDB côté client, puis renvoyée au serveur dès
-- que la connectivité revient (event `online` + Background Sync API).
--
-- Pour éviter les doublons en cas de retry ou de reconnexion multiple :
-- chaque tentative client porte un identifiant `client_attempt_id`
-- (uuid v4 généré localement). L'index UNIQUE empêche un même
-- client_attempt_id d'être inséré deux fois.
--
-- NB : aucune logique RLS spécifique : les policies existantes sur
-- quiz_attempts (l'utilisateur peut INSERT sur ses propres lignes)
-- couvrent déjà ce flux.
-- =====================================================================

ALTER TABLE public.quiz_attempts
  ADD COLUMN IF NOT EXISTS client_attempt_id text;

COMMENT ON COLUMN public.quiz_attempts.client_attempt_id IS
  'Identifiant généré côté client (uuid v4) pour dédupliquer les sync
   offline. NULL pour les tentatives passées en ligne (flux normal).';

-- Index UNIQUE conditionnel : ne s'applique qu'aux tentatives offline.
-- Les tentatives normales (client_attempt_id IS NULL) sont autorisées
-- sans contrainte d'unicité.
CREATE UNIQUE INDEX IF NOT EXISTS quiz_attempts_client_attempt_id_uidx
  ON public.quiz_attempts(client_attempt_id)
  WHERE client_attempt_id IS NOT NULL;
