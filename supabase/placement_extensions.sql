-- =====================================================================
-- Placement — extensions :
--   - qtype : type de question ('qcm' | 'qr' | 'image')
--   - image_url : URL de l'image (pour qtype='image')
--   - expected_answer : réponse-modèle pour qtype='qr' (correction manuelle)
--   - formation_id : rattachement obligatoire à une formation
--
-- Idempotent : peut être rejoué sans casse.
-- =====================================================================

-- 1) Nouvelles colonnes
ALTER TABLE public.placement_questions
  ADD COLUMN IF NOT EXISTS qtype text NOT NULL DEFAULT 'qcm';

ALTER TABLE public.placement_questions
  DROP CONSTRAINT IF EXISTS placement_questions_qtype_check;
ALTER TABLE public.placement_questions
  ADD CONSTRAINT placement_questions_qtype_check
  CHECK (qtype IN ('qcm', 'qr', 'image'));

ALTER TABLE public.placement_questions
  ADD COLUMN IF NOT EXISTS image_url text;

ALTER TABLE public.placement_questions
  ADD COLUMN IF NOT EXISTS expected_answer text;

-- 2) FK formation (nullable temporairement pour ne pas casser les questions
--    existantes ; à durcir en NOT NULL une fois migrées toutes les lignes).
ALTER TABLE public.placement_questions
  ADD COLUMN IF NOT EXISTS formation_id uuid
  REFERENCES public.formations(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS placement_q_formation_idx
  ON public.placement_questions(formation_id);

-- 3) Index combiné formation + bloc (pour le tirage du test stagiaire)
CREATE INDEX IF NOT EXISTS placement_q_formation_bloc_idx
  ON public.placement_questions(formation_id, bloc_id, "order")
  WHERE active = true;
