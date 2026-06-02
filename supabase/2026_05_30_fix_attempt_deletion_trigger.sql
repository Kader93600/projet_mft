-- =====================================================================
-- Correctif suppression d'utilisateur (suite) — trigger de log sur
-- quiz_attempts qui faisait échouer la cascade.
--
-- SYMPTÔME persistant
--   « Database error deleting user » même après correction des FK.
--   Touche uniquement les comptes AYANT passé des quiz.
--
-- CAUSE
--   Supprimer un compte -> cascade -> suppression de ses quiz_attempts.
--   Chaque suppression de tentative déclenche le trigger BEFORE DELETE
--   public.log_attempt_deletion(), qui fait :
--       insert into audit_log (actor_id, ...) values (auth.uid(), ...)
--   Pendant la cascade :
--     - auth.uid() peut être NULL (suppression via service-role) ;
--     - ou pointer un profil supprimé dans la même transaction
--       -> violation de la FK audit_log.actor_id -> profiles(id).
--   Un trigger BEFORE DELETE qui lève une exception ANNULE toute la
--   suppression. D'où l'échec.
--
-- CORRECTIF
--   On réécrit la fonction pour qu'elle :
--     1. n'enregistre actor_id que s'il existe encore dans profiles
--        (sinon NULL) -> jamais de violation de FK ;
--     2. avale toute exception (bloc EXCEPTION) -> le log reste
--        « best-effort » et ne peut JAMAIS bloquer une suppression.
--   Le trigger lui-même est conservé (la journalisation applicative dans
--   l'action deleteUser continue d'exister par ailleurs).
--
-- Idempotent. À exécuter dans l'éditeur SQL Supabase.
-- =====================================================================

create or replace function public.log_attempt_deletion()
returns trigger
language plpgsql
security definer
as $$
declare
  v_actor uuid;
  v_email text;
begin
  -- N'utilise l'acteur que s'il existe encore (évite la violation de FK
  -- audit_log.actor_id -> profiles pendant une cascade de suppression).
  select p.id, p.email
    into v_actor, v_email
    from public.profiles p
   where p.id = auth.uid();

  begin
    insert into public.audit_log
      (actor_id, actor_email, action, target_type, target_id, metadata)
    values (
      v_actor,                       -- NULL si l'acteur n'existe plus
      v_email,
      'delete_attempt',
      'quiz_attempt',
      old.id::text,
      jsonb_build_object(
        'user_id', old.user_id,
        'quiz_id', old.quiz_id,
        'percentage', old.percentage,
        'passed', old.passed,
        'finished_at', old.finished_at
      )
    );
  exception when others then
    -- Journalisation best-effort : ne JAMAIS faire échouer la suppression.
    null;
  end;

  return old;
end;
$$;

-- Le trigger existant pointe déjà vers cette fonction ; rien d'autre à faire.
-- (Conservé : before delete on quiz_attempts for each row.)
