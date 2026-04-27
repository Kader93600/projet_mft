-- =====================================================================
-- GOTRM Academy — Point #17 : i18n + RGPD avancé
-- =====================================================================

-- 1. Locale stagiaire -------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS locale text NOT NULL DEFAULT 'fr'
    CHECK (locale IN ('fr','en'));

-- 2. Consentements (cookies, analytics, etc.) -------------------------
CREATE TABLE IF NOT EXISTS public.user_consents (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  kind text NOT NULL CHECK (kind IN (
    'essential','analytics','communications','newsletter'
  )),
  granted boolean NOT NULL,
  granted_at timestamptz NOT NULL DEFAULT now(),
  ip_address inet,
  user_agent text,
  UNIQUE (user_id, kind)
);

ALTER TABLE public.user_consents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS consents_self ON public.user_consents;
CREATE POLICY consents_self ON public.user_consents
  FOR ALL USING (auth.uid() = user_id OR public.is_admin())
  WITH CHECK (auth.uid() = user_id OR public.is_admin());

-- 3. Demandes de suppression de compte -------------------------------
CREATE TABLE IF NOT EXISTS public.deletion_requests (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reason text,
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','approved','executed','refused','cancelled')),
  requested_at timestamptz NOT NULL DEFAULT now(),
  resolved_at timestamptz,
  admin_note text,
  UNIQUE (user_id, status) DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX IF NOT EXISTS deletion_requests_status_idx
  ON public.deletion_requests(status);

ALTER TABLE public.deletion_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS del_req_self ON public.deletion_requests;
CREATE POLICY del_req_self ON public.deletion_requests
  FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS del_req_insert ON public.deletion_requests;
CREATE POLICY del_req_insert ON public.deletion_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS del_req_update_self ON public.deletion_requests;
CREATE POLICY del_req_update_self ON public.deletion_requests
  FOR UPDATE USING (auth.uid() = user_id AND status = 'pending')
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS del_req_admin ON public.deletion_requests;
CREATE POLICY del_req_admin ON public.deletion_requests
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Notif admins sur nouvelle demande
CREATE OR REPLACE FUNCTION public.tg_deletion_notify()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE a record;
BEGIN
  FOR a IN SELECT id FROM public.profiles WHERE role = 'admin' LOOP
    INSERT INTO public.notifications (user_id, kind, title, body, link_url)
    VALUES (
      a.id,
      'deletion_request',
      'Demande de suppression de compte',
      'Un utilisateur a demandé l''effacement de ses données (RGPD art. 17).',
      '/admin/rgpd'
    );
  END LOOP;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_deletion_notify ON public.deletion_requests;
CREATE TRIGGER tg_deletion_notify
  AFTER INSERT ON public.deletion_requests
  FOR EACH ROW EXECUTE FUNCTION public.tg_deletion_notify();

-- 4. Journal d'accès aux données personnelles ------------------------
CREATE TABLE IF NOT EXISTS public.data_access_log (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  actor_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  action text NOT NULL CHECK (action IN ('export','view','update','delete')),
  scope text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS data_access_log_user_idx
  ON public.data_access_log(user_id, created_at DESC);

ALTER TABLE public.data_access_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS dal_self ON public.data_access_log;
CREATE POLICY dal_self ON public.data_access_log
  FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

-- 5. RPC export portable (right to access — Art. 15) ------------------
CREATE OR REPLACE FUNCTION public.export_my_data()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  uid uuid := auth.uid();
  result jsonb;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'unauthenticated'; END IF;

  SELECT jsonb_build_object(
    'exported_at', now(),
    'rgpd_notice',
      'Cet export est fourni au titre de l''article 15 du RGPD (droit d''accès).',
    'profile', (SELECT to_jsonb(p) FROM public.profiles p WHERE p.id = uid),
    'lesson_progress', (
      SELECT coalesce(jsonb_agg(to_jsonb(lp)), '[]'::jsonb)
      FROM public.lesson_progress lp WHERE lp.user_id = uid
    ),
    'quiz_attempts', (
      SELECT coalesce(jsonb_agg(to_jsonb(qa)), '[]'::jsonb)
      FROM public.quiz_attempts qa WHERE qa.user_id = uid
    ),
    'user_badges', (
      SELECT coalesce(jsonb_agg(to_jsonb(ub)), '[]'::jsonb)
      FROM public.user_badges ub WHERE ub.user_id = uid
    ),
    'certificates', (
      SELECT coalesce(jsonb_agg(to_jsonb(c)), '[]'::jsonb)
      FROM public.certificates c WHERE c.user_id = uid
    ),
    'enrollments', (
      SELECT coalesce(jsonb_agg(to_jsonb(e)), '[]'::jsonb)
      FROM public.enrollments e WHERE e.user_id = uid
    ),
    'consents', (
      SELECT coalesce(jsonb_agg(to_jsonb(uc)), '[]'::jsonb)
      FROM public.user_consents uc WHERE uc.user_id = uid
    ),
    'a11y_requests', (
      SELECT coalesce(jsonb_agg(to_jsonb(r)), '[]'::jsonb)
      FROM public.accessibility_requests r WHERE r.user_id = uid
    ),
    'coaching_sessions', (
      SELECT coalesce(jsonb_agg(to_jsonb(cs)), '[]'::jsonb)
      FROM public.coaching_sessions cs WHERE cs.user_id = uid
    ),
    'xp_events', (
      SELECT coalesce(jsonb_agg(to_jsonb(x)), '[]'::jsonb)
      FROM public.xp_events x WHERE x.user_id = uid
    )
  ) INTO result;

  INSERT INTO public.data_access_log (user_id, actor_id, action, scope)
  VALUES (uid, uid, 'export', 'self_full');

  RETURN result;
END;
$$;

GRANT EXECUTE ON FUNCTION public.export_my_data() TO authenticated;

-- 6. RPC anonymisation (right to erasure — Art. 17) -------------------
-- Préserve les statistiques agrégées en remplaçant les PII.
CREATE OR REPLACE FUNCTION public.anonymize_user(p_user uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'admin required';
  END IF;

  UPDATE public.profiles
     SET full_name = NULL,
         email = 'deleted-' || p_user::text || '@anonymized.local',
         phone = NULL,
         notes = NULL,
         a11y_notes = NULL,
         disabled = true
   WHERE id = p_user;

  -- supprimer messages personnels, ressources non agrégées
  DELETE FROM public.coaching_notes WHERE user_id = p_user;
  DELETE FROM public.accessibility_requests WHERE user_id = p_user;
  DELETE FROM public.notifications WHERE user_id = p_user;

  -- marquer la demande comme exécutée
  UPDATE public.deletion_requests
     SET status = 'executed', resolved_at = now()
   WHERE user_id = p_user AND status IN ('pending','approved');

  INSERT INTO public.data_access_log (user_id, actor_id, action, scope)
  VALUES (p_user, auth.uid(), 'delete', 'rgpd_anonymize');
END;
$$;

GRANT EXECUTE ON FUNCTION public.anonymize_user(uuid) TO authenticated;
