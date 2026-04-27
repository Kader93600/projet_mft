-- =====================================================================
-- Signature électronique simple côté financeur (eIDAS niveau 1).
-- Capture nom + email + IP + horodatage + hash du document signé.
-- =====================================================================

ALTER TABLE public.enrollments
  ADD COLUMN IF NOT EXISTS funder_signed_at        timestamptz,
  ADD COLUMN IF NOT EXISTS funder_signed_by_name   text,
  ADD COLUMN IF NOT EXISTS funder_signed_by_email  text,
  ADD COLUMN IF NOT EXISTS funder_signature_ip     inet,
  ADD COLUMN IF NOT EXISTS funder_signature_hash   text;

-- RPC : un financeur signe son dossier (RLS s'assure qu'il y a accès)
CREATE OR REPLACE FUNCTION public.funder_sign_enrollment(
  p_enrollment uuid,
  p_name       text,
  p_email      text,
  p_ip         inet
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  uid uuid := auth.uid();
  ok  boolean;
  hash text;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'unauthenticated'; END IF;
  IF p_name IS NULL OR length(btrim(p_name)) = 0 THEN
    RAISE EXCEPTION 'name_required';
  END IF;

  -- L'utilisateur doit être lié au financeur du dossier
  SELECT EXISTS (
    SELECT 1
      FROM public.enrollments e
      JOIN public.funders f ON f.id = e.funder_id
     WHERE e.id = p_enrollment
       AND f.portal_user_id = uid
  ) INTO ok;
  IF NOT ok THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  -- Hash de preuve : (id, montant, dates, signataire, ts)
  SELECT encode(
    digest(
      e.id::text || ':' ||
      coalesce(e.total_amount_cents, 0)::text || ':' ||
      coalesce(e.start_date::text, '') || ':' ||
      coalesce(e.end_date::text, '') || ':' ||
      p_name || ':' ||
      coalesce(p_email, '') || ':' ||
      now()::text,
      'sha256'
    ),
    'hex'
  )
  INTO hash
  FROM public.enrollments e WHERE e.id = p_enrollment;

  UPDATE public.enrollments
     SET funder_signed_at       = now(),
         funder_signed_by_name  = p_name,
         funder_signed_by_email = p_email,
         funder_signature_ip    = p_ip,
         funder_signature_hash  = hash,
         status                 = CASE
           WHEN status IN ('prospect','devis') THEN 'accord_financeur'
           ELSE status
         END
   WHERE id = p_enrollment;

  -- Trace dans le journal d'accès (vue admin)
  INSERT INTO public.data_access_log(user_id, actor_id, action, scope)
  SELECT e.user_id, uid, 'update', 'funder_signature'
  FROM public.enrollments e WHERE e.id = p_enrollment;

  RETURN p_enrollment;
END;
$$;

-- pgcrypto pour digest(); installé sur Supabase mais on garantit
CREATE EXTENSION IF NOT EXISTS pgcrypto;

GRANT EXECUTE ON FUNCTION public.funder_sign_enrollment(uuid, text, text, inet) TO authenticated;
