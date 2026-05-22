-- ============================================================
-- Émargement : réutilisation de la signature de référence
--   - attendance_signatures.signature_data : image de la signature apposée
--     (copiée depuis user_signatures au moment de l'émargement).
--   - attendance_sign() : le stagiaire n'a plus à re-saisir son nom — le nom
--     vient du profil et la signature de référence est apposée automatiquement.
--
-- Signature de fonction inchangée (uuid, text, inet, text) → déploiement sûr :
-- l'ancien et le nouveau code d'appel fonctionnent.
-- ============================================================

ALTER TABLE public.attendance_signatures
  ADD COLUMN IF NOT EXISTS signature_data text;

CREATE OR REPLACE FUNCTION public.attendance_sign(
  p_session uuid,
  p_name    text,
  p_ip      inet,
  p_ua      text
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  uid uuid := auth.uid();
  ok  boolean;
  ts  timestamptz := now();
  hash text;
  sig_id uuid;
  v_name text;
  v_sig  text;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'unauthenticated'; END IF;

  -- Nom : paramètre fourni, sinon nom du profil (la signature de référence fait foi).
  v_name := nullif(btrim(coalesce(p_name, '')), '');
  IF v_name IS NULL OR length(v_name) < 2 THEN
    v_name := (SELECT full_name FROM public.profiles WHERE id = uid);
  END IF;
  IF v_name IS NULL OR length(btrim(v_name)) < 2 THEN
    RAISE EXCEPTION 'name_required';
  END IF;

  -- L'utilisateur doit être attendee ; session ouverte (start - 30 min → end + 24 h).
  SELECT EXISTS (
    SELECT 1
      FROM public.attendance_sessions s
      JOIN public.attendance_attendees a ON a.session_id = s.id
     WHERE s.id = p_session
       AND a.user_id = uid
       AND now() BETWEEN s.starts_at - INTERVAL '30 minutes'
                     AND s.ends_at + INTERVAL '24 hours'
  ) INTO ok;
  IF NOT ok THEN RAISE EXCEPTION 'session_not_signable'; END IF;

  -- Signature de référence (dessinée lors de la signature obligatoire).
  v_sig := (SELECT signature_data FROM public.user_signatures WHERE user_id = uid);

  hash := encode(
    digest(p_session::text || ':' || uid::text || ':' || ts::text || ':' || v_name, 'sha256'),
    'hex'
  );

  INSERT INTO public.attendance_signatures(
    session_id, user_id, signed_at, signature_name,
    signature_ip, signature_ua, signature_hash, signature_data
  ) VALUES (
    p_session, uid, ts, btrim(v_name), p_ip, p_ua, hash, v_sig
  )
  ON CONFLICT (session_id, user_id) DO UPDATE
    SET signed_at      = EXCLUDED.signed_at,
        signature_name = EXCLUDED.signature_name,
        signature_ip   = EXCLUDED.signature_ip,
        signature_ua   = EXCLUDED.signature_ua,
        signature_hash = EXCLUDED.signature_hash,
        signature_data = EXCLUDED.signature_data
  RETURNING id INTO sig_id;

  RETURN sig_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.attendance_sign(uuid, text, inet, text) TO authenticated;
