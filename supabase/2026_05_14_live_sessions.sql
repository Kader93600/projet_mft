-- =====================================================================
-- 2026-05-14 · Sessions présentielles & distancielles (Phase 7.1)
--
-- Architecture :
--   - live_sessions       : session planifiée (présentiel, distanciel, hybride)
--   - session_enrollments : inscriptions stagiaires (invité, confirmé, etc.)
--   - session_attendance  : émargement effectif (signature horodatée)
--
-- Gating : feature réservée aux stagiaires avec pack 'premium' sur la
-- formation associée (via la table enrollments + colonne pack).
-- L'admin et le formateur (habilité sur la formation) peuvent gérer
-- toutes les sessions.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Table live_sessions
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.live_sessions (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Métadonnées
  title text NOT NULL,
  description text,

  -- Rattachement pédagogique
  formation_id uuid NOT NULL
    REFERENCES public.formations(id) ON DELETE CASCADE,
  module_id uuid REFERENCES public.modules(id) ON DELETE SET NULL,

  -- Mode
  kind text NOT NULL DEFAULT 'distanciel'
    CHECK (kind IN ('presentiel', 'distanciel', 'hybride')),

  -- Date / durée
  start_at timestamptz NOT NULL,
  end_at timestamptz NOT NULL,
  CHECK (end_at > start_at),

  -- Lieu (présentiel ou hybride)
  location text,

  -- Visioconférence (distanciel ou hybride)
  meeting_provider text
    CHECK (meeting_provider IN ('zoom', 'teams', 'meet', 'other')),
  meeting_url text,
  meeting_password text,

  -- Capacité
  max_participants int CHECK (max_participants IS NULL OR max_participants > 0),

  -- Formateur référent
  trainer_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,

  -- État
  status text NOT NULL DEFAULT 'scheduled'
    CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),

  -- Notes internes (admin only)
  notes_internal text,

  -- Audit
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS live_sessions_formation_idx
  ON public.live_sessions(formation_id);
CREATE INDEX IF NOT EXISTS live_sessions_start_idx
  ON public.live_sessions(start_at DESC);
CREATE INDEX IF NOT EXISTS live_sessions_status_idx
  ON public.live_sessions(status);
CREATE INDEX IF NOT EXISTS live_sessions_trainer_idx
  ON public.live_sessions(trainer_id) WHERE trainer_id IS NOT NULL;

-- Trigger : maj updated_at
CREATE OR REPLACE FUNCTION public.tg_live_sessions_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS tg_live_sessions_updated_at_bu ON public.live_sessions;
CREATE TRIGGER tg_live_sessions_updated_at_bu
  BEFORE UPDATE ON public.live_sessions
  FOR EACH ROW EXECUTE FUNCTION public.tg_live_sessions_updated_at();

-- ---------------------------------------------------------------------
-- 2) Table session_enrollments — inscriptions des stagiaires
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.session_enrollments (
  session_id uuid NOT NULL
    REFERENCES public.live_sessions(id) ON DELETE CASCADE,
  user_id uuid NOT NULL
    REFERENCES public.profiles(id) ON DELETE CASCADE,

  status text NOT NULL DEFAULT 'confirmed'
    CHECK (status IN ('invited', 'confirmed', 'cancelled', 'no_show')),

  registered_at timestamptz NOT NULL DEFAULT now(),
  cancelled_at timestamptz,
  cancellation_reason text,

  PRIMARY KEY (session_id, user_id)
);

CREATE INDEX IF NOT EXISTS session_enrollments_user_idx
  ON public.session_enrollments(user_id);
CREATE INDEX IF NOT EXISTS session_enrollments_status_idx
  ON public.session_enrollments(status);

-- ---------------------------------------------------------------------
-- 3) Table session_attendance — émargement
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.session_attendance (
  session_id uuid NOT NULL
    REFERENCES public.live_sessions(id) ON DELETE CASCADE,
  user_id uuid NOT NULL
    REFERENCES public.profiles(id) ON DELETE CASCADE,

  -- Émargement : timestamp + méthode
  signed_at timestamptz NOT NULL DEFAULT now(),
  method text NOT NULL DEFAULT 'online_click'
    CHECK (method IN ('online_click', 'qr_code', 'manual', 'signature_pad')),

  -- Audit IP (pour Qualiopi)
  ip_address inet,
  user_agent text,

  -- Signature en image (optionnel — pour le pad)
  signature_storage_path text,

  -- Validation formateur (le formateur peut annoter)
  validated_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  validated_at timestamptz,
  notes text,

  PRIMARY KEY (session_id, user_id)
);

CREATE INDEX IF NOT EXISTS session_attendance_user_idx
  ON public.session_attendance(user_id);

-- ---------------------------------------------------------------------
-- 4) RLS — Row Level Security
-- ---------------------------------------------------------------------
ALTER TABLE public.live_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_attendance ENABLE ROW LEVEL SECURITY;

-- Helper : un stagiaire a-t-il accès à la formation (pack premium) ?
CREATE OR REPLACE FUNCTION public.user_has_premium_for_formation(
  p_user_id uuid,
  p_formation_id uuid
) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1
      FROM public.enrollments e
     WHERE e.user_id = p_user_id
       AND e.formation_id = p_formation_id
       AND e.pack = 'premium'
       AND e.status NOT IN ('refuse', 'abandon')
  );
$$;

-- Helper : un formateur est-il habilité sur la formation ?
-- (mirror du SQL utilisé dans toutes les politiques pédagogiques)
CREATE OR REPLACE FUNCTION public.user_has_trainer_access(
  p_user_id uuid,
  p_formation_id uuid
) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1
      FROM public.trainer_formations tf
     WHERE tf.trainer_id = p_user_id
       AND tf.formation_id = p_formation_id
  );
$$;

-- ===== Live sessions =====
-- Lecture stagiaire : sessions des formations où il a pack premium
DROP POLICY IF EXISTS live_sessions_student_read ON public.live_sessions;
CREATE POLICY live_sessions_student_read ON public.live_sessions
  FOR SELECT USING (
    public.user_has_premium_for_formation(auth.uid(), formation_id)
  );

-- Lecture staff (admin + super_admin + formateur sur sa formation)
DROP POLICY IF EXISTS live_sessions_staff_read ON public.live_sessions;
CREATE POLICY live_sessions_staff_read ON public.live_sessions
  FOR SELECT USING (
    public.is_admin()
    OR public.user_has_trainer_access(auth.uid(), formation_id)
  );

-- Écriture staff uniquement
DROP POLICY IF EXISTS live_sessions_staff_write ON public.live_sessions;
CREATE POLICY live_sessions_staff_write ON public.live_sessions
  FOR ALL USING (
    public.is_admin()
    OR public.user_has_trainer_access(auth.uid(), formation_id)
  ) WITH CHECK (
    public.is_admin()
    OR public.user_has_trainer_access(auth.uid(), formation_id)
  );

-- ===== Session enrollments =====
DROP POLICY IF EXISTS session_enrollments_student_read ON public.session_enrollments;
CREATE POLICY session_enrollments_student_read ON public.session_enrollments
  FOR SELECT USING (
    user_id = auth.uid()
    OR public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.live_sessions ls
       WHERE ls.id = session_enrollments.session_id
         AND public.user_has_trainer_access(auth.uid(), ls.formation_id)
    )
  );

-- Le stagiaire peut s'auto-inscrire / se désinscrire
DROP POLICY IF EXISTS session_enrollments_self_write ON public.session_enrollments;
CREATE POLICY session_enrollments_self_write ON public.session_enrollments
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.live_sessions ls
       WHERE ls.id = session_enrollments.session_id
         AND public.user_has_premium_for_formation(auth.uid(), ls.formation_id)
    )
  );

-- L'admin / formateur peut tout faire
DROP POLICY IF EXISTS session_enrollments_staff_write ON public.session_enrollments;
CREATE POLICY session_enrollments_staff_write ON public.session_enrollments
  FOR ALL USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.live_sessions ls
       WHERE ls.id = session_enrollments.session_id
         AND public.user_has_trainer_access(auth.uid(), ls.formation_id)
    )
  ) WITH CHECK (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.live_sessions ls
       WHERE ls.id = session_enrollments.session_id
         AND public.user_has_trainer_access(auth.uid(), ls.formation_id)
    )
  );

-- ===== Session attendance =====
DROP POLICY IF EXISTS session_attendance_student_read ON public.session_attendance;
CREATE POLICY session_attendance_student_read ON public.session_attendance
  FOR SELECT USING (
    user_id = auth.uid()
    OR public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.live_sessions ls
       WHERE ls.id = session_attendance.session_id
         AND public.user_has_trainer_access(auth.uid(), ls.formation_id)
    )
  );

-- Le stagiaire peut émarger lui-même (si inscrit + session in_progress)
DROP POLICY IF EXISTS session_attendance_self_sign ON public.session_attendance;
CREATE POLICY session_attendance_self_sign ON public.session_attendance
  FOR INSERT WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.session_enrollments se
       WHERE se.session_id = session_attendance.session_id
         AND se.user_id = auth.uid()
         AND se.status IN ('confirmed', 'invited')
    )
  );

-- Admin / formateur peut tout faire
DROP POLICY IF EXISTS session_attendance_staff_write ON public.session_attendance;
CREATE POLICY session_attendance_staff_write ON public.session_attendance
  FOR ALL USING (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.live_sessions ls
       WHERE ls.id = session_attendance.session_id
         AND public.user_has_trainer_access(auth.uid(), ls.formation_id)
    )
  ) WITH CHECK (
    public.is_admin()
    OR EXISTS (
      SELECT 1 FROM public.live_sessions ls
       WHERE ls.id = session_attendance.session_id
         AND public.user_has_trainer_access(auth.uid(), ls.formation_id)
    )
  );

-- ---------------------------------------------------------------------
-- 5) Storage bucket pour signatures manuscrites (optionnel)
-- ---------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'session-signatures',
  'session-signatures',
  false,
  2 * 1024 * 1024,
  ARRAY['image/png', 'image/jpeg']
)
ON CONFLICT (id) DO UPDATE
  SET file_size_limit = EXCLUDED.file_size_limit,
      allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS session_signatures_admin_all ON storage.objects;
CREATE POLICY session_signatures_admin_all ON storage.objects
  FOR ALL USING (bucket_id = 'session-signatures' AND public.is_admin())
  WITH CHECK (bucket_id = 'session-signatures' AND public.is_admin());

DROP POLICY IF EXISTS session_signatures_auth_read ON storage.objects;
CREATE POLICY session_signatures_auth_read ON storage.objects
  FOR SELECT USING (
    bucket_id = 'session-signatures' AND auth.role() = 'authenticated'
  );

-- ---------------------------------------------------------------------
-- 6) Vérification post-migration
-- ---------------------------------------------------------------------
DO $$
DECLARE
  v_has_sessions boolean;
  v_has_enrollments boolean;
  v_has_attendance boolean;
  v_has_bucket boolean;
BEGIN
  SELECT EXISTS(SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'live_sessions')
    INTO v_has_sessions;
  SELECT EXISTS(SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'session_enrollments')
    INTO v_has_enrollments;
  SELECT EXISTS(SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'session_attendance')
    INTO v_has_attendance;
  SELECT EXISTS(SELECT 1 FROM storage.buckets WHERE id = 'session-signatures')
    INTO v_has_bucket;

  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE 'Migration sessions présentielles/distancielles · Phase 7.1';
  RAISE NOTICE '────────────────────────────────────────────────────────';
  RAISE NOTICE '  live_sessions ............... %', v_has_sessions;
  RAISE NOTICE '  session_enrollments ......... %', v_has_enrollments;
  RAISE NOTICE '  session_attendance .......... %', v_has_attendance;
  RAISE NOTICE '  bucket session-signatures ... %', v_has_bucket;
  RAISE NOTICE '────────────────────────────────────────────────────────';
END $$;
