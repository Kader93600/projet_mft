-- =====================================================================
-- Versioning des leçons (Qualiopi indicateur 11 — adaptation des contenus)
-- Snapshot automatique à chaque modification + lien depuis lesson_progress
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.lesson_versions (
  id          uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  lesson_id   uuid NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  version     int NOT NULL,
  title       text,
  content_md  text,
  summary_md  text,
  video_url   text,
  edited_by   uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  edited_at   timestamptz NOT NULL DEFAULT now(),
  change_note text,
  UNIQUE (lesson_id, version)
);

CREATE INDEX IF NOT EXISTS lesson_versions_lesson_idx
  ON public.lesson_versions(lesson_id, version DESC);

ALTER TABLE public.lesson_versions ENABLE ROW LEVEL SECURITY;

-- Lecture : tout authentifié (les stagiaires doivent pouvoir vérifier
-- la version qu'ils ont suivie). Écriture : admins uniquement.
DROP POLICY IF EXISTS lv_read ON public.lesson_versions;
CREATE POLICY lv_read ON public.lesson_versions
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS lv_admin_write ON public.lesson_versions;
CREATE POLICY lv_admin_write ON public.lesson_versions
  FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- Numéro de version courant sur la table lessons (pour pin rapide)
ALTER TABLE public.lessons
  ADD COLUMN IF NOT EXISTS current_version int NOT NULL DEFAULT 1;

-- Lien stagiaire → version suivie
ALTER TABLE public.lesson_progress
  ADD COLUMN IF NOT EXISTS lesson_version_id uuid REFERENCES public.lesson_versions(id);

-- ---------------------------------------------------------------------
-- Trigger : snapshoter la leçon à chaque INSERT/UPDATE significatif
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tg_lesson_snapshot()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  next_v int;
  changed boolean;
BEGIN
  IF TG_OP = 'UPDATE' THEN
    changed :=
      (NEW.title       IS DISTINCT FROM OLD.title)       OR
      (NEW.content_md  IS DISTINCT FROM OLD.content_md)  OR
      (NEW.summary_md  IS DISTINCT FROM OLD.summary_md)  OR
      (NEW.video_url   IS DISTINCT FROM OLD.video_url);
    IF NOT changed THEN
      RETURN NEW;
    END IF;
  END IF;

  SELECT coalesce(max(version), 0) + 1
    INTO next_v
    FROM public.lesson_versions
   WHERE lesson_id = NEW.id;

  INSERT INTO public.lesson_versions(
    lesson_id, version, title, content_md, summary_md, video_url, edited_by
  )
  VALUES (
    NEW.id, next_v, NEW.title, NEW.content_md, NEW.summary_md,
    NEW.video_url, auth.uid()
  );

  NEW.current_version := next_v;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_lesson_snapshot ON public.lessons;
CREATE TRIGGER tg_lesson_snapshot
  BEFORE INSERT OR UPDATE ON public.lessons
  FOR EACH ROW EXECUTE FUNCTION public.tg_lesson_snapshot();

-- ---------------------------------------------------------------------
-- Pinning : à la complétion, on enregistre la version vue
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.tg_lesson_progress_pin_version()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v uuid;
BEGIN
  IF NEW.lesson_version_id IS NOT NULL THEN
    RETURN NEW;
  END IF;
  SELECT id INTO v
    FROM public.lesson_versions lv
   WHERE lv.lesson_id = NEW.lesson_id
   ORDER BY version DESC
   LIMIT 1;
  IF v IS NOT NULL THEN
    NEW.lesson_version_id := v;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_lesson_progress_pin_version ON public.lesson_progress;
CREATE TRIGGER tg_lesson_progress_pin_version
  BEFORE INSERT OR UPDATE ON public.lesson_progress
  FOR EACH ROW EXECUTE FUNCTION public.tg_lesson_progress_pin_version();

-- ---------------------------------------------------------------------
-- Backfill : crée une v1 pour toutes les leçons existantes sans version
-- ---------------------------------------------------------------------
INSERT INTO public.lesson_versions (lesson_id, version, title, content_md, summary_md, video_url)
SELECT l.id, 1, l.title, l.content_md, l.summary_md, l.video_url
FROM public.lessons l
WHERE NOT EXISTS (
  SELECT 1 FROM public.lesson_versions lv WHERE lv.lesson_id = l.id
);

UPDATE public.lessons l
   SET current_version = lv.version
  FROM (
    SELECT lesson_id, max(version) AS version
      FROM public.lesson_versions
     GROUP BY lesson_id
  ) lv
 WHERE lv.lesson_id = l.id;

-- Backfill des progressions sans version
UPDATE public.lesson_progress lp
   SET lesson_version_id = lv.id
  FROM public.lesson_versions lv
 WHERE lv.lesson_id = lp.lesson_id
   AND lv.version = 1
   AND lp.lesson_version_id IS NULL;
