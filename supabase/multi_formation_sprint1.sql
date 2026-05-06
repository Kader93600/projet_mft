-- =====================================================================
-- Multi-formations — Sprint 1 : verrouillage sécurité minimal viable
-- =====================================================================
-- Objectif :
--   1. Persister la "formation courante" sur le profil
--   2. Rattacher la progression (quiz_attempts, lesson_views) à une formation
--   3. Backfiller les lignes existantes
--   4. Helper SQL réutilisable user_has_formation()
--   5. RLS écriture : interdire d'enregistrer une progression pour une
--      formation où l'utilisateur n'est pas inscrit
--
-- Ce qui N'EST PAS fait dans ce sprint (volontairement) :
--   - RLS lecture du contenu (modules/lessons/quizzes) — sera Sprint 2
--   - UI switcher de formation — sera Sprint 2
--   - NOT NULL final — sera Sprint 2 après vérification du backfill
--
-- Idempotent : peut être rejoué sans casse.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Schéma : nouvelles colonnes
-- ---------------------------------------------------------------------

-- Formation courante du stagiaire (modifiable plus tard via switcher)
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS current_formation_id uuid
  REFERENCES public.formations(id) ON DELETE SET NULL;

-- Progression rattachée à la formation
ALTER TABLE public.quiz_attempts
  ADD COLUMN IF NOT EXISTS formation_id uuid
  REFERENCES public.formations(id) ON DELETE SET NULL;

ALTER TABLE public.lesson_views
  ADD COLUMN IF NOT EXISTS formation_id uuid
  REFERENCES public.formations(id) ON DELETE SET NULL;

-- Indexes utiles
CREATE INDEX IF NOT EXISTS quiz_attempts_user_formation_idx
  ON public.quiz_attempts(user_id, formation_id);

CREATE INDEX IF NOT EXISTS lesson_views_user_formation_idx
  ON public.lesson_views(user_id, formation_id);

CREATE INDEX IF NOT EXISTS profiles_current_formation_idx
  ON public.profiles(current_formation_id)
  WHERE current_formation_id IS NOT NULL;


-- ---------------------------------------------------------------------
-- 2) Helper : "le user est-il inscrit à cette formation ?"
-- ---------------------------------------------------------------------
-- SECURITY DEFINER pour pouvoir être utilisée dans une POLICY sans que
-- l'utilisateur ait besoin d'un SELECT direct sur enrollments.

CREATE OR REPLACE FUNCTION public.user_has_formation(p_formation uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
      FROM public.enrollments e
     WHERE e.user_id = auth.uid()
       AND e.formation_id = p_formation
       AND e.status NOT IN ('refuse', 'abandon')
  );
$$;

GRANT EXECUTE ON FUNCTION public.user_has_formation(uuid) TO authenticated;


-- ---------------------------------------------------------------------
-- 3) Backfill formation_id sur la progression existante
-- ---------------------------------------------------------------------
-- Pour chaque ligne sans formation_id, on prend la formation de
-- l'enrollment du user (priorité statut 'en_cours', sinon le plus récent
-- non-refusé/abandonné).
--
-- Stratégie en 2 passes : on calcule d'abord la formation "candidate"
-- par user, puis on UPDATE les lignes sans formation_id.

WITH candidate AS (
  SELECT DISTINCT ON (e.user_id)
         e.user_id,
         e.formation_id
    FROM public.enrollments e
   WHERE e.formation_id IS NOT NULL
     AND e.status NOT IN ('refuse', 'abandon')
   ORDER BY e.user_id,
            CASE WHEN e.status = 'en_cours' THEN 0 ELSE 1 END,
            e.created_at DESC
)
UPDATE public.quiz_attempts qa
   SET formation_id = c.formation_id
  FROM candidate c
 WHERE qa.user_id = c.user_id
   AND qa.formation_id IS NULL;

WITH candidate AS (
  SELECT DISTINCT ON (e.user_id)
         e.user_id,
         e.formation_id
    FROM public.enrollments e
   WHERE e.formation_id IS NOT NULL
     AND e.status NOT IN ('refuse', 'abandon')
   ORDER BY e.user_id,
            CASE WHEN e.status = 'en_cours' THEN 0 ELSE 1 END,
            e.created_at DESC
)
UPDATE public.lesson_views lv
   SET formation_id = c.formation_id
  FROM candidate c
 WHERE lv.user_id = c.user_id
   AND lv.formation_id IS NULL;

-- Et on initialise current_formation_id sur les profils vides
WITH candidate AS (
  SELECT DISTINCT ON (e.user_id)
         e.user_id,
         e.formation_id
    FROM public.enrollments e
   WHERE e.formation_id IS NOT NULL
     AND e.status NOT IN ('refuse', 'abandon')
   ORDER BY e.user_id,
            CASE WHEN e.status = 'en_cours' THEN 0 ELSE 1 END,
            e.created_at DESC
)
UPDATE public.profiles p
   SET current_formation_id = c.formation_id
  FROM candidate c
 WHERE p.id = c.user_id
   AND p.current_formation_id IS NULL;


-- ---------------------------------------------------------------------
-- 4) RLS écriture — gate par formation
-- ---------------------------------------------------------------------
-- On ajoute des policies WITH CHECK pour INSERT/UPDATE qui exigent que
-- la formation_id (si fournie) corresponde à une inscription du user.
-- NULL est toléré ici pour ne pas casser les écritures legacy ; le
-- code applicatif passera désormais toujours formation_id.

-- ── quiz_attempts ────────────────────────────────────────────────────
DROP POLICY IF EXISTS quiz_attempts_insert_self ON public.quiz_attempts;
CREATE POLICY quiz_attempts_insert_self ON public.quiz_attempts
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND (
      formation_id IS NULL
      OR public.user_has_formation(formation_id)
    )
  );

DROP POLICY IF EXISTS quiz_attempts_update_self ON public.quiz_attempts;
CREATE POLICY quiz_attempts_update_self ON public.quiz_attempts
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (
    auth.uid() = user_id
    AND (
      formation_id IS NULL
      OR public.user_has_formation(formation_id)
    )
  );

-- ── lesson_views ─────────────────────────────────────────────────────
DROP POLICY IF EXISTS lesson_views_insert_self ON public.lesson_views;
CREATE POLICY lesson_views_insert_self ON public.lesson_views
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND (
      formation_id IS NULL
      OR public.user_has_formation(formation_id)
    )
  );

DROP POLICY IF EXISTS lesson_views_update_self ON public.lesson_views;
CREATE POLICY lesson_views_update_self ON public.lesson_views
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (
    auth.uid() = user_id
    AND (
      formation_id IS NULL
      OR public.user_has_formation(formation_id)
    )
  );


-- ---------------------------------------------------------------------
-- 5) Auto-fill formation_id côté écriture (trigger + RPC)
-- ---------------------------------------------------------------------
-- Si le client n'envoie pas formation_id, on le remplit automatiquement
-- depuis profiles.current_formation_id. Évite de devoir refactor tout
-- le code client à plusieurs endroits.

CREATE OR REPLACE FUNCTION public.tg_autofill_formation_id()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.formation_id IS NULL THEN
    SELECT current_formation_id INTO NEW.formation_id
      FROM public.profiles
     WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_qa_autofill_formation_id ON public.quiz_attempts;
CREATE TRIGGER tg_qa_autofill_formation_id
  BEFORE INSERT ON public.quiz_attempts
  FOR EACH ROW EXECUTE FUNCTION public.tg_autofill_formation_id();

DROP TRIGGER IF EXISTS tg_lv_autofill_formation_id ON public.lesson_views;
CREATE TRIGGER tg_lv_autofill_formation_id
  BEFORE INSERT ON public.lesson_views
  FOR EACH ROW EXECUTE FUNCTION public.tg_autofill_formation_id();

-- Mise à jour de la RPC ping_lesson_view : on populate formation_id
-- au INSERT côté serveur (le trigger le fait déjà, mais on rend
-- l'intention explicite + on bénéficie d'une seule lecture profil).

CREATE OR REPLACE FUNCTION public.ping_lesson_view(
  p_lesson_id uuid,
  p_completed boolean default false
) RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_formation_id uuid;
  v_view_id uuid;
  v_started timestamptz;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Non authentifié';
  END IF;

  SELECT current_formation_id INTO v_formation_id
    FROM public.profiles WHERE id = v_user_id;

  -- Vue active récente (< 3 min) : on update
  SELECT id, started_at INTO v_view_id, v_started
    FROM public.lesson_views
   WHERE user_id = v_user_id
     AND lesson_id = p_lesson_id
     AND last_ping_at > now() - interval '3 minutes'
   ORDER BY last_ping_at DESC
   LIMIT 1;

  IF v_view_id IS NOT NULL THEN
    UPDATE public.lesson_views
       SET last_ping_at = now(),
           duration_s = greatest(duration_s, extract(epoch from (now() - v_started))::integer),
           completed = lesson_views.completed OR p_completed,
           formation_id = COALESCE(formation_id, v_formation_id)
     WHERE id = v_view_id;
  ELSE
    INSERT INTO public.lesson_views (user_id, lesson_id, completed, formation_id)
    VALUES (v_user_id, p_lesson_id, p_completed, v_formation_id)
    RETURNING id INTO v_view_id;
  END IF;

  RETURN v_view_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.ping_lesson_view(uuid, boolean) TO authenticated;


-- ---------------------------------------------------------------------
-- 6) RPC : changer la formation courante
-- ---------------------------------------------------------------------
-- Le user ne peut sélectionner que parmi ses formations. Empêche un
-- mauvais acteur de pointer current_formation_id sur une formation où
-- il n'est pas inscrit en jouant sur un UPDATE direct côté client.

CREATE OR REPLACE FUNCTION public.set_current_formation(p_formation uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Non authentifié';
  END IF;

  IF p_formation IS NOT NULL AND NOT public.user_has_formation(p_formation) THEN
    RAISE EXCEPTION 'Vous n''êtes pas inscrit à cette formation';
  END IF;

  UPDATE public.profiles
     SET current_formation_id = p_formation,
         updated_at = now()
   WHERE id = v_uid;
END;
$$;

GRANT EXECUTE ON FUNCTION public.set_current_formation(uuid) TO authenticated;


-- ---------------------------------------------------------------------
-- 7) Notes pour Sprint 2 (à NE PAS jouer maintenant)
-- ---------------------------------------------------------------------
--   - ALTER TABLE quiz_attempts  ALTER COLUMN formation_id SET NOT NULL;
--   - ALTER TABLE lesson_views   ALTER COLUMN formation_id SET NOT NULL;
--   - DROP POLICY content_read_authed ON modules / lessons / quizzes;
--     puis recréer avec USING (public.user_has_formation(...))
--   - UI switcher dans AppShell + page /mes-formations

-- =====================================================================
-- Rapport
-- =====================================================================
DO $$
DECLARE
  v_qa_total int;
  v_qa_filled int;
  v_lv_total int;
  v_lv_filled int;
  v_profiles_filled int;
BEGIN
  SELECT count(*) INTO v_qa_total FROM public.quiz_attempts;
  SELECT count(*) INTO v_qa_filled FROM public.quiz_attempts WHERE formation_id IS NOT NULL;
  SELECT count(*) INTO v_lv_total FROM public.lesson_views;
  SELECT count(*) INTO v_lv_filled FROM public.lesson_views WHERE formation_id IS NOT NULL;
  SELECT count(*) INTO v_profiles_filled FROM public.profiles WHERE current_formation_id IS NOT NULL;

  RAISE NOTICE 'Sprint 1 multi-formation OK';
  RAISE NOTICE '  quiz_attempts.formation_id : % / % lignes', v_qa_filled, v_qa_total;
  RAISE NOTICE '  lesson_views.formation_id  : % / % lignes', v_lv_filled, v_lv_total;
  RAISE NOTICE '  profiles.current_formation_id : % lignes initialisées', v_profiles_filled;
END $$;
