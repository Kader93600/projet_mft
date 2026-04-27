-- =====================================================================
-- Fix : le trigger tg_lesson_snapshot était en BEFORE INSERT, ce qui
-- viole la FK lesson_versions.lesson_id → lessons.id (la ligne n'existe
-- pas encore dans lessons au moment où on insère dans lesson_versions).
--
-- Solution : passer le trigger en AFTER INSERT pour les nouvelles lignes
-- (la ligne est alors présente). On garde BEFORE pour les UPDATE car on
-- veut snapshoter l'état AVANT la modification.
-- =====================================================================

-- Drop l'ancien trigger
DROP TRIGGER IF EXISTS tg_lesson_snapshot ON public.lessons;

-- Recrée 2 triggers distincts :
--   - AFTER INSERT  : snapshot la version 1 dès la création
--   - BEFORE UPDATE : snapshot la version courante avant la modification
CREATE TRIGGER tg_lesson_snapshot_after_insert
  AFTER INSERT ON public.lessons
  FOR EACH ROW EXECUTE FUNCTION public.tg_lesson_snapshot();

CREATE TRIGGER tg_lesson_snapshot_before_update
  BEFORE UPDATE OF content_md, summary_md, title, video_url ON public.lessons
  FOR EACH ROW EXECUTE FUNCTION public.tg_lesson_snapshot();
