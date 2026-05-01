-- =====================================================================
-- FIX — ajout d'une contrainte UNIQUE sur question_bank.source_ref
--
-- Nécessaire pour que les seeds (capa_questions_premium.sql,
-- capa_questions_examen_blanc.sql) puissent utiliser
-- ON CONFLICT (source_ref) DO NOTHING (idempotence).
--
-- Idempotent : peut être rejoué sans casse.
-- =====================================================================

-- 1) Nettoyage : si plusieurs lignes partagent le même source_ref non-NULL,
--    on garde la 1ère (par id) et on supprime les doublons. Cela permet à
--    la contrainte UNIQUE d'être créée sans erreur.
DELETE FROM public.question_bank q
USING public.question_bank q2
WHERE q.id > q2.id
  AND q.source_ref IS NOT NULL
  AND q.source_ref = q2.source_ref;

-- 2) Création de la contrainte UNIQUE (uniquement sur les valeurs non-NULL).
--    Postgres autorise plusieurs NULL dans une contrainte UNIQUE classique.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'question_bank_source_ref_unique'
      AND conrelid = 'public.question_bank'::regclass
  ) THEN
    ALTER TABLE public.question_bank
      ADD CONSTRAINT question_bank_source_ref_unique
      UNIQUE (source_ref);
  END IF;
END $$;
