-- =====================================================================
-- Émargement digital signé — sessions synchrones (live, webinaires, jury)
-- Complément à l'émargement FOAD asynchrone (basé sur lesson_progress).
-- Indicateur Qualiopi 11 (suivi de l'exécution).
-- =====================================================================

-- 1. Sessions planifiées
CREATE TABLE IF NOT EXISTS public.attendance_sessions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  starts_at timestamptz NOT NULL,
  ends_at timestamptz NOT NULL,
  half_day text NOT NULL CHECK (half_day IN ('matin','apres_midi','journee')),
  modality text NOT NULL CHECK (modality IN ('presentiel','distanciel','mixte')) DEFAULT 'distanciel',
  location text,
  trainer_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  trainer_signed_at timestamptz,
  trainer_signature_name text,
  topic text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (ends_at > starts_at)
);

CREATE INDEX IF NOT EXISTS attendance_sessions_starts_idx
  ON public.attendance_sessions(starts_at DESC);

-- 2. Stagiaires inscrits à une session (peut être backfill via promo/cohorte)
CREATE TABLE IF NOT EXISTS public.attendance_attendees (
  session_id uuid NOT NULL REFERENCES public.attendance_sessions(id) ON DELETE CASCADE,
  user_id    uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  PRIMARY KEY (session_id, user_id)
);

-- 3. Signatures (1 ligne par stagiaire+session)
CREATE TABLE IF NOT EXISTS public.attendance_signatures (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id uuid NOT NULL REFERENCES public.attendance_sessions(id) ON DELETE CASCADE,
  user_id    uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  signed_at  timestamptz NOT NULL DEFAULT now(),
  signature_name text NOT NULL,    -- saisie « Lu et signé par … »
  signature_ip   inet,
  signature_ua   text,
  signature_hash text,             -- SHA-256(session_id|user_id|signed_at|name) pour preuve
  UNIQUE (session_id, user_id)
);

CREATE INDEX IF NOT EXISTS attendance_signatures_session_idx
  ON public.attendance_signatures(session_id);

-- ---------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------
ALTER TABLE public.attendance_sessions   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_attendees  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_signatures ENABLE ROW LEVEL SECURITY;

-- Sessions : lecture pour tout authentifié, écriture admin
DROP POLICY IF EXISTS as_read ON public.attendance_sessions;
CREATE POLICY as_read ON public.attendance_sessions
  FOR SELECT USING (auth.role() = 'authenticated');
DROP POLICY IF EXISTS as_admin ON public.attendance_sessions;
CREATE POLICY as_admin ON public.attendance_sessions
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Attendees : lecture si concerné OU admin ; écriture admin
DROP POLICY IF EXISTS aa_read ON public.attendance_attendees;
CREATE POLICY aa_read ON public.attendance_attendees
  FOR SELECT USING (auth.uid() = user_id OR public.is_admin());
DROP POLICY IF EXISTS aa_admin ON public.attendance_attendees;
CREATE POLICY aa_admin ON public.attendance_attendees
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Signatures : le stagiaire signe pour lui-même (et seulement s'il est attendee)
DROP POLICY IF EXISTS sig_self_read ON public.attendance_signatures;
CREATE POLICY sig_self_read ON public.attendance_signatures
  FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS sig_self_insert ON public.attendance_signatures;
CREATE POLICY sig_self_insert ON public.attendance_signatures
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.attendance_attendees a
       WHERE a.session_id = session_id AND a.user_id = auth.uid()
    )
  );

-- Pas d'UPDATE/DELETE stagiaire : signature immuable.

-- ---------------------------------------------------------------------
-- RPC : signature stagiaire (calcule le hash + IP + UA)
-- ---------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;

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
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'unauthenticated'; END IF;
  IF p_name IS NULL OR length(btrim(p_name)) < 2 THEN
    RAISE EXCEPTION 'name_required';
  END IF;

  -- L'utilisateur doit être attendee ; la session doit être ouverte (entre starts_at - 30 min et ends_at + 24 h)
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

  hash := encode(digest(p_session::text || ':' || uid::text || ':' || ts::text || ':' || p_name, 'sha256'), 'hex');

  INSERT INTO public.attendance_signatures(
    session_id, user_id, signed_at, signature_name, signature_ip, signature_ua, signature_hash
  ) VALUES (
    p_session, uid, ts, btrim(p_name), p_ip, p_ua, hash
  )
  ON CONFLICT (session_id, user_id) DO UPDATE
    SET signed_at = EXCLUDED.signed_at,
        signature_name = EXCLUDED.signature_name,
        signature_ip   = EXCLUDED.signature_ip,
        signature_ua   = EXCLUDED.signature_ua,
        signature_hash = EXCLUDED.signature_hash
  RETURNING id INTO sig_id;

  RETURN sig_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.attendance_sign(uuid, text, inet, text) TO authenticated;

-- ---------------------------------------------------------------------
-- Vue : taux de présence par session
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW public.attendance_summary AS
SELECT
  s.id,
  s.title,
  s.starts_at,
  s.ends_at,
  s.half_day,
  (SELECT count(*) FROM public.attendance_attendees a WHERE a.session_id = s.id) AS expected,
  (SELECT count(*) FROM public.attendance_signatures sg WHERE sg.session_id = s.id) AS signed,
  s.trainer_signed_at IS NOT NULL AS trainer_signed
FROM public.attendance_sessions s;

GRANT SELECT ON public.attendance_summary TO authenticated;
