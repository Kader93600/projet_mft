-- ============================================================
-- Onboarding stagiaire & documents d'entrée en formation
--   - onboarding_documents : convention, règlement intérieur, livret d'accueil
--   - document_acceptances : signature électronique horodatée
--   - profiles.onboarding_completed_at : flag de complétion
-- ============================================================

-- ------------------------------------------------------------
-- 1. Flag onboarding sur profiles
-- ------------------------------------------------------------
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS onboarding_completed_at timestamptz;

-- ------------------------------------------------------------
-- 2. Documents d'entrée (un document par type, versionné)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.onboarding_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text NOT NULL CHECK (type IN ('convention', 'reglement', 'livret')),
  title text NOT NULL,
  version integer NOT NULL DEFAULT 1,
  content_md text NOT NULL DEFAULT '',
  published boolean NOT NULL DEFAULT false,
  -- Un seul doc publié par type (index unique partiel)
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by uuid REFERENCES auth.users(id)
);

CREATE UNIQUE INDEX IF NOT EXISTS onboarding_doc_one_published_per_type
  ON public.onboarding_documents(type)
  WHERE published;

-- Seed : 3 documents vides par défaut
INSERT INTO public.onboarding_documents (type, title, content_md, published)
VALUES
  ('convention', 'Convention de formation',
   E'## Convention de formation professionnelle\n\n### Article 1 — Objet\nLa présente convention a pour objet...\n\n### Article 2 — Dispositions financières\n...\n\n### Article 3 — Modalités\n...\n\n*Document à compléter par le responsable pédagogique.*',
   false),
  ('reglement', 'Règlement intérieur',
   E'## Règlement intérieur\n\n### 1. Dispositions générales\nLe présent règlement s''applique à tous les stagiaires...\n\n### 2. Hygiène et sécurité\n...\n\n### 3. Discipline\n...\n\n*Document à compléter par le responsable pédagogique.*',
   false),
  ('livret', 'Livret d''accueil du stagiaire',
   E'## Bienvenue à la formation\n\nCe livret d''accueil vous accompagne tout au long de votre parcours.\n\n### Organisation de la formation\n...\n\n### Vos interlocuteurs\n...\n\n### Ressources mises à disposition\n...\n\n*Document à compléter par le responsable pédagogique.*',
   false)
ON CONFLICT DO NOTHING;

ALTER TABLE public.onboarding_documents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS od_read ON public.onboarding_documents;
CREATE POLICY od_read ON public.onboarding_documents
  FOR SELECT USING (auth.uid() IS NOT NULL AND (published OR public.is_admin()));

DROP POLICY IF EXISTS od_write ON public.onboarding_documents;
CREATE POLICY od_write ON public.onboarding_documents
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ------------------------------------------------------------
-- 3. Acceptations (signature électronique)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.document_acceptances (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  document_id uuid NOT NULL REFERENCES public.onboarding_documents(id) ON DELETE RESTRICT,
  document_type text NOT NULL,
  document_version integer NOT NULL,
  accepted_at timestamptz NOT NULL DEFAULT now(),
  ip_address inet,
  user_agent text,
  UNIQUE (user_id, document_id)
);

CREATE INDEX IF NOT EXISTS da_user_idx ON public.document_acceptances(user_id);

ALTER TABLE public.document_acceptances ENABLE ROW LEVEL SECURITY;

-- Stagiaire : voir ses propres acceptations + insérer
DROP POLICY IF EXISTS da_own_read ON public.document_acceptances;
CREATE POLICY da_own_read ON public.document_acceptances
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS da_own_insert ON public.document_acceptances;
CREATE POLICY da_own_insert ON public.document_acceptances
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- Pas de update/delete : l'acceptation est immuable (preuve légale)

-- Admin : lecture globale
DROP POLICY IF EXISTS da_admin_read ON public.document_acceptances;
CREATE POLICY da_admin_read ON public.document_acceptances
  FOR SELECT USING (public.is_admin());

-- ------------------------------------------------------------
-- 4. RPC : accepter un document et mettre à jour profiles.onboarding_completed_at
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.accept_document(
  p_document_id uuid,
  p_user_agent text DEFAULT NULL
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

  INSERT INTO public.document_acceptances
    (user_id, document_id, document_type, document_version, user_agent)
  VALUES
    (v_uid, v_doc.id, v_doc.type, v_doc.version, p_user_agent)
  ON CONFLICT (user_id, document_id) DO UPDATE SET accepted_at = document_acceptances.accepted_at
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

GRANT EXECUTE ON FUNCTION public.accept_document(uuid, text) TO authenticated;

-- ------------------------------------------------------------
-- 5. Vue pour l'admin : état d'onboarding par stagiaire
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW public.user_onboarding_status AS
SELECT
  p.id AS user_id,
  p.full_name,
  p.email,
  p.onboarding_completed_at,
  (SELECT count(*) FROM public.onboarding_documents WHERE published) AS required_docs,
  (SELECT count(*) FROM public.document_acceptances a
     JOIN public.onboarding_documents d ON d.id = a.document_id
    WHERE a.user_id = p.id AND d.published) AS accepted_docs
FROM public.profiles p
WHERE p.role = 'student';

GRANT SELECT ON public.user_onboarding_status TO authenticated;
