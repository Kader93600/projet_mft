-- =====================================================================
-- AUDIT #10 — Tirage d'examen aléatoire stable (seed déterministe)
-- 2026-05-20
--
-- Problème : pour les quiz `random_from_bank`, generate_random_exam
-- utilisait ORDER BY random() → à chaque rechargement de la page
-- d'examen, un NOUVEAU set de questions était tiré. Si le stagiaire
-- rechargeait en cours d'épreuve, les questions changeaient et ses
-- réponses (indexées par question_id) ne correspondaient plus.
--
-- Approche retenue (minimale, sans refactor du runner ni changement de
-- schéma) : tirage DÉTERMINISTE via un seed. On ajoute un paramètre
-- p_seed optionnel ; quand il est fourni (= user_id:quiz_id côté
-- appelant), l'ordre est md5(question_id || seed) au lieu de random().
--
-- Conséquence : pour un (stagiaire, quiz) donné, le même set de
-- questions dans le même ordre est tiré à CHAQUE chargement → reload
-- en cours d'épreuve sans perte. Compromis assumé : un repassage de
-- l'examen par le même stagiaire retombe sur le même set (acceptable
-- pour un examen blanc adossé à une grande banque). Sans seed, le
-- comportement aléatoire d'origine est conservé (rétro-compat).
-- =====================================================================

CREATE OR REPLACE FUNCTION public.generate_random_exam(
  p_formation_slug text,
  p_qcm_count int DEFAULT 40,
  p_qr_count int DEFAULT 0,
  p_difficulty text[] DEFAULT NULL,
  p_module_ids uuid[] DEFAULT NULL,
  p_seed text DEFAULT NULL
)
RETURNS TABLE (id uuid, type text, statement text)
LANGUAGE plpgsql STABLE
SET search_path = public, auth, pg_temp
AS $$
DECLARE
  formation_uuid uuid;
BEGIN
  IF NOT public.has_formation_access(auth.uid(), p_formation_slug) THEN
    RAISE EXCEPTION 'forbidden_formation';
  END IF;

  SELECT f.id INTO formation_uuid
  FROM public.formations f
  WHERE f.slug = p_formation_slug;

  RETURN QUERY (
    -- QCM
    SELECT q.id, q.type, q.statement
    FROM public.question_bank q
    WHERE q.formation_id = formation_uuid
      AND q.type = 'qcm'
      AND q.active = true
      AND (p_difficulty IS NULL OR q.difficulty = ANY(p_difficulty))
      AND (p_module_ids IS NULL OR q.module_id = ANY(p_module_ids))
    ORDER BY
      CASE WHEN p_seed IS NULL THEN random()::text
           ELSE md5(q.id::text || p_seed) END
    LIMIT p_qcm_count
  )
  UNION ALL
  (
    -- QR
    SELECT q.id, q.type, q.statement
    FROM public.question_bank q
    WHERE q.formation_id = formation_uuid
      AND q.type = 'qr'
      AND q.active = true
      AND (p_difficulty IS NULL OR q.difficulty = ANY(p_difficulty))
      AND (p_module_ids IS NULL OR q.module_id = ANY(p_module_ids))
    ORDER BY
      CASE WHEN p_seed IS NULL THEN random()::text
           ELSE md5(q.id::text || p_seed) END
    LIMIT p_qr_count
  );
END;
$$;

-- Grant sur la nouvelle signature (6 args). On garde l'ancienne (5 args)
-- valide aussi par défaut de paramètre, mais on grant explicitement.
GRANT EXECUTE ON FUNCTION public.generate_random_exam(text, int, int, text[], uuid[], text)
  TO authenticated;

DO $$
BEGIN
  RAISE NOTICE '════════ AUDIT #10 — Tirage examen stable ════════';
  RAISE NOTICE '  generate_random_exam : param p_seed ajouté';
  RAISE NOTICE '  Tirage déterministe md5(id||seed) quand seed fourni';
  RAISE NOTICE '═══════════════════════════════════════════════════';
END $$;
