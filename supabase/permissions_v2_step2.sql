-- =====================================================================
-- Permissions v2 — ÉTAPE 2 : helpers + audit_logs.
-- À jouer APRÈS permissions_v2_step1.sql (commit entre les deux requis).
--
-- Modèle de rôles :
--   student       : stagiaire, accès ses propres données
--   trainer       : formateur, accès ses formations habilitées
--   admin         : opérationnel (users, contenus, affectations)
--   super_admin   : régalien (rôles, audit, config plateforme)
--
-- Helpers fournis :
--   public.is_admin()          ← admin OR super_admin (rétro-compat)
--   public.is_super_admin()    ← uniquement super_admin
--   public.is_staff()          ← admin OR super_admin (alias plus clair)
--   public.is_trainer()        ← trainer (créé en S1 précédent)
--   public.has_formation_access(uuid, text)
--                              ← user a accès à cette formation slug ?
--   public.is_enrolled_in(uuid, text)
--                              ← user est-il inscrit à cette formation ?
-- =====================================================================

-- 1) Mise à jour de is_admin pour inclure super_admin (rétro-compat)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS(
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
      AND role IN ('admin', 'super_admin')
  );
$$;

-- 2) Strict super_admin (régalien : gestion des rôles, audit sensible)
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS(
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'super_admin'
  );
$$;

-- 3) Alias clair "personnel salarié" (admin + super_admin)
CREATE OR REPLACE FUNCTION public.is_staff()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT public.is_admin();
$$;

-- 4) Accès à une formation : user inscrit OU formateur habilité OU staff
--    (la table trainer_formations sera créée en S1.3 ; on tolère son
--     absence le temps de la migration)
CREATE OR REPLACE FUNCTION public.has_formation_access(
  p_user uuid,
  p_slug text
) RETURNS boolean
LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
  is_st boolean;
  has_enrollment boolean;
  has_habilitation boolean;
BEGIN
  -- Staff = accès à tout
  SELECT EXISTS(
    SELECT 1 FROM public.profiles
    WHERE id = p_user AND role IN ('admin','super_admin')
  ) INTO is_st;
  IF is_st THEN RETURN true; END IF;

  -- Stagiaire inscrit (via slug ou via FK formation_id)
  SELECT EXISTS(
    SELECT 1 FROM public.enrollments e
    WHERE e.user_id = p_user
      AND (e.formation_slug = p_slug)
      AND e.status NOT IN ('refuse','abandon')
  ) INTO has_enrollment;
  IF has_enrollment THEN RETURN true; END IF;

  -- Formateur habilité — on tolère l'absence de la table en cas de migration partielle
  BEGIN
    SELECT EXISTS(
      SELECT 1
        FROM public.trainer_formations tf
        JOIN public.formations f ON f.id = tf.formation_id
       WHERE tf.trainer_id = p_user AND f.slug = p_slug
    ) INTO has_habilitation;
    IF has_habilitation THEN RETURN true; END IF;
  EXCEPTION WHEN undefined_table THEN
    NULL; -- tables pas encore créées : on ignore
  END;

  RETURN false;
END;
$$;

-- 5) Inscription stagiaire à une formation
CREATE OR REPLACE FUNCTION public.is_enrolled_in(
  p_user uuid,
  p_slug text
) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS(
    SELECT 1 FROM public.enrollments
    WHERE user_id = p_user
      AND formation_slug = p_slug
      AND status NOT IN ('refuse','abandon')
  );
$$;

-- =====================================================================
-- Audit logs — traçabilité des actions sensibles (super_admin, role changes)
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.audit_logs (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  action text NOT NULL,
  target_type text,
  target_id text,
  payload jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS audit_logs_actor_idx
  ON public.audit_logs(actor_id, created_at DESC);
CREATE INDEX IF NOT EXISTS audit_logs_action_idx
  ON public.audit_logs(action, created_at DESC);
CREATE INDEX IF NOT EXISTS audit_logs_target_idx
  ON public.audit_logs(target_type, target_id);

ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Lecture : super_admin uniquement (action sensible)
DROP POLICY IF EXISTS audit_logs_super_admin_read ON public.audit_logs;
CREATE POLICY audit_logs_super_admin_read ON public.audit_logs
  FOR SELECT USING (public.is_super_admin());

-- Insertion : tout user authentifié (les RPC sécurisées loggent leur propre action)
DROP POLICY IF EXISTS audit_logs_insert ON public.audit_logs;
CREATE POLICY audit_logs_insert ON public.audit_logs
  FOR INSERT WITH CHECK (auth.uid() = actor_id OR public.is_admin());

-- =====================================================================
-- RPC : changer le rôle d'un utilisateur (réservée super_admin)
-- =====================================================================

CREATE OR REPLACE FUNCTION public.update_user_role(
  p_user uuid,
  p_role user_role
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  uid uuid := auth.uid();
  old_role user_role;
BEGIN
  IF NOT public.is_super_admin() THEN
    RAISE EXCEPTION 'Seul un super_admin peut modifier les rôles';
  END IF;
  IF p_user IS NULL OR p_role IS NULL THEN
    RAISE EXCEPTION 'Paramètres invalides';
  END IF;
  IF p_user = uid THEN
    RAISE EXCEPTION 'Impossible de modifier son propre rôle';
  END IF;

  SELECT role INTO old_role FROM public.profiles WHERE id = p_user;

  UPDATE public.profiles SET role = p_role WHERE id = p_user;

  INSERT INTO public.audit_logs (actor_id, action, target_type, target_id, payload)
  VALUES (
    uid,
    'role_changed',
    'profiles',
    p_user::text,
    jsonb_build_object('from', old_role, 'to', p_role)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.update_user_role(uuid, user_role) TO authenticated;
