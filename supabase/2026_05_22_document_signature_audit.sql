-- ============================================================
-- Renforcement de la piste d'audit des signatures de documents
--   - document_acceptances.signature_name : nom saisi au moment de signer
--   - accept_document() : capture désormais l'IP et le nom de signature
--
-- ⚠️ ORDRE DE DÉPLOIEMENT : appliquer CETTE migration AVANT de déployer le
--    code qui passe `p_ip` / `p_signature_name`. Les nouveaux paramètres ont
--    une valeur par défaut → l'ancien code (qui n'envoie que p_document_id +
--    p_user_agent) continue de fonctionner pendant la transition. Aucune
--    coupure de l'onboarding.
-- ============================================================

-- 1. Colonne nom de signature (immuable comme le reste de la ligne)
ALTER TABLE public.document_acceptances
  ADD COLUMN IF NOT EXISTS signature_name text;

-- 2. RPC enrichie : capture user_agent + IP + nom de signature
--    On supprime l'ancienne signature (uuid, text) puis on recrée en (uuid,
--    text, text, text) avec défauts → résolution PostgREST par paramètres
--    nommés, rétro-compatible.
DROP FUNCTION IF EXISTS public.accept_document(uuid, text);

CREATE OR REPLACE FUNCTION public.accept_document(
  p_document_id uuid,
  p_user_agent text DEFAULT NULL,
  p_ip text DEFAULT NULL,
  p_signature_name text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_doc record;
  v_acc_id uuid;
  v_published_count int;
  v_accepted_count int;
  v_ip inet;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Non authentifié';
  END IF;

  SELECT id, type, version, published
    INTO v_doc
    FROM public.onboarding_documents
   WHERE id = p_document_id;

  IF NOT FOUND OR NOT v_doc.published THEN
    RAISE EXCEPTION 'Document indisponible';
  END IF;

  -- Cast IP défensif : on ignore une valeur mal formée plutôt que d'échouer.
  BEGIN
    v_ip := nullif(trim(p_ip), '')::inet;
  EXCEPTION WHEN others THEN
    v_ip := NULL;
  END;

  INSERT INTO public.document_acceptances
    (user_id, document_id, document_type, document_version,
     user_agent, ip_address, signature_name)
  VALUES
    (v_uid, v_doc.id, v_doc.type, v_doc.version,
     p_user_agent, v_ip, nullif(trim(p_signature_name), ''))
  ON CONFLICT (user_id, document_id) DO UPDATE
    SET accepted_at = document_acceptances.accepted_at
  RETURNING id INTO v_acc_id;

  -- Si tous les documents publiés sont acceptés, compléter l'onboarding
  SELECT count(*) INTO v_published_count
    FROM public.onboarding_documents
   WHERE published;

  SELECT count(DISTINCT d.id) INTO v_accepted_count
    FROM public.onboarding_documents d
    JOIN public.document_acceptances a
      ON a.document_id = d.id AND a.user_id = v_uid
   WHERE d.published;

  IF v_accepted_count >= v_published_count AND v_published_count > 0 THEN
    UPDATE public.profiles
       SET onboarding_completed_at = coalesce(onboarding_completed_at, now())
     WHERE id = v_uid;
  END IF;

  RETURN v_acc_id;
END;
$$;

GRANT EXECUTE ON FUNCTION
  public.accept_document(uuid, text, text, text) TO authenticated;
