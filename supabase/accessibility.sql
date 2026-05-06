-- =====================================================================
-- MA FORMATION TRANSPORT — Point #12 : Accessibilité & handicap (RGAA)
-- =====================================================================
-- - Préférences stagiaire (taille, police dyslexia, contraste, motion)
-- - Demandes d'adaptation (référent handicap)
-- - Vue admin synthèse
-- =====================================================================

-- 1. Colonnes prefs sur profiles ---------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS a11y_font_scale numeric(3,2) NOT NULL DEFAULT 1.00
    CHECK (a11y_font_scale BETWEEN 0.85 AND 1.60),
  ADD COLUMN IF NOT EXISTS a11y_dyslexia_font boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS a11y_high_contrast boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS a11y_reduced_motion boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS a11y_underline_links boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS a11y_notes text,
  ADD COLUMN IF NOT EXISTS a11y_rqth boolean NOT NULL DEFAULT false;

-- 2. Table des demandes d'adaptation -----------------------------------
CREATE TABLE IF NOT EXISTS public.accessibility_requests (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  category text NOT NULL CHECK (category IN (
    'visuel', 'auditif', 'moteur', 'cognitif', 'dys', 'autre'
  )),
  description text NOT NULL,
  adaptations_requested text,
  status text NOT NULL DEFAULT 'nouveau'
    CHECK (status IN ('nouveau', 'en_cours', 'valide', 'refuse', 'clos')),
  admin_response text,
  referent_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  resolved_at timestamptz
);

CREATE INDEX IF NOT EXISTS a11y_req_user_idx
  ON public.accessibility_requests(user_id);
CREATE INDEX IF NOT EXISTS a11y_req_status_idx
  ON public.accessibility_requests(status);

ALTER TABLE public.accessibility_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS a11y_req_self ON public.accessibility_requests;
CREATE POLICY a11y_req_self ON public.accessibility_requests
  FOR SELECT USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS a11y_req_insert ON public.accessibility_requests;
CREATE POLICY a11y_req_insert ON public.accessibility_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS a11y_req_update_self ON public.accessibility_requests;
CREATE POLICY a11y_req_update_self ON public.accessibility_requests
  FOR UPDATE USING (auth.uid() = user_id AND status = 'nouveau')
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS a11y_req_admin ON public.accessibility_requests;
CREATE POLICY a11y_req_admin ON public.accessibility_requests
  FOR ALL USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- updated_at trigger
CREATE OR REPLACE FUNCTION public.tg_a11y_touch_updated()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END $$;

DROP TRIGGER IF EXISTS a11y_req_updated_at ON public.accessibility_requests;
CREATE TRIGGER a11y_req_updated_at
  BEFORE UPDATE ON public.accessibility_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.tg_a11y_touch_updated();

-- Notifications : quand une demande est soumise (admins) et quand son statut change (user)
CREATE OR REPLACE FUNCTION public.tg_a11y_notify()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  a record;
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- notifier tous les admins
    FOR a IN SELECT id FROM public.profiles WHERE role = 'admin' LOOP
      INSERT INTO public.notifications (user_id, kind, title, body, link_url)
      VALUES (
        a.id,
        'a11y_request',
        'Nouvelle demande d''adaptation',
        'Un stagiaire a soumis une demande auprès du référent handicap.',
        '/admin/accessibilite'
      );
    END LOOP;
  ELSIF TG_OP = 'UPDATE' AND NEW.status IS DISTINCT FROM OLD.status THEN
    INSERT INTO public.notifications (user_id, kind, title, body, link_url)
    VALUES (
      NEW.user_id,
      'a11y_request',
      'Demande d''adaptation mise à jour',
      'Votre demande est désormais : ' || NEW.status,
      '/accessibilite'
    );
    IF NEW.status IN ('valide','refuse','clos') AND NEW.resolved_at IS NULL THEN
      NEW.resolved_at := now();
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_a11y_notify_ins ON public.accessibility_requests;
CREATE TRIGGER tg_a11y_notify_ins
  AFTER INSERT ON public.accessibility_requests
  FOR EACH ROW EXECUTE FUNCTION public.tg_a11y_notify();

DROP TRIGGER IF EXISTS tg_a11y_notify_upd ON public.accessibility_requests;
CREATE TRIGGER tg_a11y_notify_upd
  BEFORE UPDATE ON public.accessibility_requests
  FOR EACH ROW EXECUTE FUNCTION public.tg_a11y_notify();

-- 3. Vue synthèse admin -------------------------------------------------
CREATE OR REPLACE VIEW public.accessibility_overview AS
SELECT
  p.id AS user_id,
  p.full_name,
  p.email,
  p.a11y_rqth,
  p.a11y_font_scale,
  p.a11y_dyslexia_font,
  p.a11y_high_contrast,
  p.a11y_reduced_motion,
  p.a11y_underline_links,
  p.a11y_notes,
  (
    SELECT count(*) FROM public.accessibility_requests r
    WHERE r.user_id = p.id AND r.status IN ('nouveau','en_cours')
  ) AS open_requests,
  (
    SELECT max(created_at) FROM public.accessibility_requests r
    WHERE r.user_id = p.id
  ) AS last_request_at
FROM public.profiles p
WHERE p.role = 'student';

GRANT SELECT ON public.accessibility_overview TO authenticated;
