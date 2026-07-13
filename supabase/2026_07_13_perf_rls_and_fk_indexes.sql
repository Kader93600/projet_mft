-- =====================================================================
-- PERFORMANCE BASE — 13/07/2026 (audit perf, advisors Supabase)
--
-- 3 volets, tous SANS impact fonctionnel (comportement identique) :
--   1. 58 index sur clés étrangères non indexées  (jointures + DELETE)
--   2. ~110 policies RLS : auth.uid() nu -> (select auth.uid())  (init-plan)
--   3. DIAGNOSTIC des « multiple permissive policies » (357) — NON auto-fixé
--
-- Idempotent (IF NOT EXISTS / guards). À appliquer par l'admin dans le SQL
-- editor Supabase. Généré par introspection LIVE de la base (pas à l'aveugle).
-- =====================================================================


-- =====================================================================
-- VOLET 1 — INDEX SUR CLÉS ÉTRANGÈRES NON INDEXÉES (58)
--
-- Une FK sans index rend lents : (a) les jointures sur la FK, (b) surtout
-- les DELETE/UPDATE sur la table PARENT (Postgres scanne la table enfant
-- entière pour vérifier l'intégrité). Gain sûr, coût quasi nul à ce volume.
-- Advisor : unindexed_foreign_keys.
-- =====================================================================
CREATE INDEX IF NOT EXISTS accessibility_requests_referent_id_idx ON accessibility_requests (referent_id);
CREATE INDEX IF NOT EXISTS announcements_created_by_idx ON announcements (created_by);
CREATE INDEX IF NOT EXISTS announcements_group_id_idx ON announcements (group_id);
CREATE INDEX IF NOT EXISTS attendance_attendees_user_id_idx ON attendance_attendees (user_id);
CREATE INDEX IF NOT EXISTS attendance_sessions_trainer_id_idx ON attendance_sessions (trainer_id);
CREATE INDEX IF NOT EXISTS attendance_signatures_user_id_idx ON attendance_signatures (user_id);
CREATE INDEX IF NOT EXISTS certificates_bloc_id_idx ON certificates (bloc_id);
CREATE INDEX IF NOT EXISTS choices_question_id_idx ON choices (question_id);
CREATE INDEX IF NOT EXISTS coaching_notes_trainer_id_idx ON coaching_notes (trainer_id);
CREATE INDEX IF NOT EXISTS conversations_created_by_idx ON conversations (created_by);
CREATE INDEX IF NOT EXISTS conversations_user_id_idx ON conversations (user_id);
CREATE INDEX IF NOT EXISTS conversations_group_id_idx ON conversations (group_id);
CREATE INDEX IF NOT EXISTS data_access_log_actor_id_idx ON data_access_log (actor_id);
CREATE INDEX IF NOT EXISTS document_acceptances_document_id_idx ON document_acceptances (document_id);
CREATE INDEX IF NOT EXISTS email_log_related_user_id_idx ON email_log (related_user_id);
CREATE INDEX IF NOT EXISTS enrollment_requests_user_id_idx ON enrollment_requests (user_id);
CREATE INDEX IF NOT EXISTS formation_pack_prices_updated_by_idx ON formation_pack_prices (updated_by);
CREATE INDEX IF NOT EXISTS formation_settings_updated_by_idx ON formation_settings (updated_by);
CREATE INDEX IF NOT EXISTS funders_portal_user_id_idx ON funders (portal_user_id);
CREATE INDEX IF NOT EXISTS lead_activities_author_id_idx ON lead_activities (author_id);
CREATE INDEX IF NOT EXISTS lead_notes_author_id_idx ON lead_notes (author_id);
CREATE INDEX IF NOT EXISTS lesson_progress_lesson_version_id_idx ON lesson_progress (lesson_version_id);
CREATE INDEX IF NOT EXISTS lesson_progress_lesson_id_idx ON lesson_progress (lesson_id);
CREATE INDEX IF NOT EXISTS lesson_versions_edited_by_idx ON lesson_versions (edited_by);
CREATE INDEX IF NOT EXISTS lesson_views_formation_id_idx ON lesson_views (formation_id);
CREATE INDEX IF NOT EXISTS live_sessions_module_id_idx ON live_sessions (module_id);
CREATE INDEX IF NOT EXISTS live_sessions_created_by_idx ON live_sessions (created_by);
CREATE INDEX IF NOT EXISTS message_reactions_user_id_idx ON message_reactions (user_id);
CREATE INDEX IF NOT EXISTS messages_sender_id_idx ON messages (sender_id);
CREATE INDEX IF NOT EXISTS messages_reply_to_id_idx ON messages (reply_to_id);
CREATE INDEX IF NOT EXISTS modules_bloc_id_idx ON modules (bloc_id);
CREATE INDEX IF NOT EXISTS modules_marketplace_reviewer_id_idx ON modules (marketplace_reviewer_id);
CREATE INDEX IF NOT EXISTS onboarding_documents_updated_by_idx ON onboarding_documents (updated_by);
CREATE INDEX IF NOT EXISTS organization_members_invited_by_idx ON organization_members (invited_by);
CREATE INDEX IF NOT EXISTS pinned_messages_message_id_idx ON pinned_messages (message_id);
CREATE INDEX IF NOT EXISTS pinned_messages_pinned_by_idx ON pinned_messages (pinned_by);
CREATE INDEX IF NOT EXISTS placement_results_recommended_bloc_id_idx ON placement_results (recommended_bloc_id);
CREATE INDEX IF NOT EXISTS qr_responses_graded_by_idx ON qr_responses (graded_by);
CREATE INDEX IF NOT EXISTS qr_responses_question_id_idx ON qr_responses (question_id);
CREATE INDEX IF NOT EXISTS question_attachments_created_by_idx ON question_attachments (created_by);
CREATE INDEX IF NOT EXISTS question_bank_created_by_idx ON question_bank (created_by);
CREATE INDEX IF NOT EXISTS question_bank_reformulated_by_idx ON question_bank (reformulated_by);
CREATE INDEX IF NOT EXISTS question_imports_created_by_idx ON question_imports (created_by);
CREATE INDEX IF NOT EXISTS question_imports_module_id_idx ON question_imports (module_id);
CREATE INDEX IF NOT EXISTS questions_quiz_id_idx ON questions (quiz_id);
CREATE INDEX IF NOT EXISTS quiz_attempts_formation_id_idx ON quiz_attempts (formation_id);
CREATE INDEX IF NOT EXISTS quiz_attempts_graded_by_idx ON quiz_attempts (graded_by);
CREATE INDEX IF NOT EXISTS quizzes_module_id_idx ON quizzes (module_id);
CREATE INDEX IF NOT EXISTS referrals_enrollment_id_idx ON referrals (enrollment_id);
CREATE INDEX IF NOT EXISTS referrals_rewarded_by_idx ON referrals (rewarded_by);
CREATE INDEX IF NOT EXISTS search_logs_user_id_idx ON search_logs (user_id);
CREATE INDEX IF NOT EXISTS session_attendance_validated_by_idx ON session_attendance (validated_by);
CREATE INDEX IF NOT EXISTS trainer_formations_granted_by_idx ON trainer_formations (granted_by);
CREATE INDEX IF NOT EXISTS trainer_revenue_events_enrollment_id_idx ON trainer_revenue_events (enrollment_id);
CREATE INDEX IF NOT EXISTS trainer_revenue_events_module_id_idx ON trainer_revenue_events (module_id);
CREATE INDEX IF NOT EXISTS tutor_conversations_context_module_id_idx ON tutor_conversations (context_module_id);
CREATE INDEX IF NOT EXISTS user_badges_badge_id_idx ON user_badges (badge_id);
CREATE INDEX IF NOT EXISTS user_credits_created_by_idx ON user_credits (created_by);


-- =====================================================================
-- VOLET 2 — RLS init-plan : auth.uid()/role()/jwt() nu -> (select ...)
--
-- Quand une policy appelle `auth.uid()` nu, Postgres le RÉ-ÉVALUE pour
-- CHAQUE ligne scannée. En l'enveloppant dans un sous-select
-- `(select auth.uid())`, le planificateur le calcule UNE fois par requête
-- (« initPlan »). Résultat identique, gros gain sur les tables volumineuses.
-- Advisor : auth_rls_initplan (~110 policies).
--
-- Transformation vérifiée sur échantillon. Guards : ne touche que les
-- policies contenant un appel NU (pas déjà `(select auth.…)`), donc rejouable.
-- =====================================================================
DO $mft$
DECLARE
  r         record;
  new_qual  text;
  new_check text;
  n         int := 0;
BEGIN
  FOR r IN
    SELECT schemaname, tablename, policyname, qual, with_check
    FROM pg_policies
    WHERE schemaname = 'public'
      AND (
        (qual       ~ 'auth\.(uid|role|jwt|email)\(\)' AND qual       !~* 'select\s+auth\.')
        OR
        (with_check ~ 'auth\.(uid|role|jwt|email)\(\)' AND with_check !~* 'select\s+auth\.')
      )
  LOOP
    -- Enveloppe chaque côté seulement s'il contient un appel nu.
    new_qual := CASE
      WHEN r.qual ~ 'auth\.(uid|role|jwt|email)\(\)' AND r.qual !~* 'select\s+auth\.'
      THEN regexp_replace(r.qual, 'auth\.(uid|role|jwt|email)\(\)', '(select auth.\1())', 'g')
      ELSE r.qual END;
    new_check := CASE
      WHEN r.with_check ~ 'auth\.(uid|role|jwt|email)\(\)' AND r.with_check !~* 'select\s+auth\.'
      THEN regexp_replace(r.with_check, 'auth\.(uid|role|jwt|email)\(\)', '(select auth.\1())', 'g')
      ELSE r.with_check END;

    EXECUTE format(
      'ALTER POLICY %I ON %I.%I%s%s',
      r.policyname, r.schemaname, r.tablename,
      CASE WHEN r.qual       IS NOT NULL THEN format(' USING (%s)',      new_qual)  ELSE '' END,
      CASE WHEN r.with_check IS NOT NULL THEN format(' WITH CHECK (%s)', new_check) ELSE '' END
    );
    n := n + 1;
    RAISE NOTICE 'RLS optimisée : %.% / %', r.schemaname, r.tablename, r.policyname;
  END LOOP;
  RAISE NOTICE '=== % policy(ies) optimisée(s) ===', n;
END $mft$;


-- =====================================================================
-- VOLET 3 — MULTIPLE PERMISSIVE POLICIES (357) — DIAGNOSTIC SEULEMENT
--
-- ⚠️ NON auto-corrigé : quand plusieurs policies PERMISSIVE existent pour le
-- même (rôle, action) sur une table, Postgres les évalue TOUTES et les
-- combine en OR à chaque ligne (léger surcoût). Les FUSIONNER change la
-- SÉMANTIQUE des accès : c'est un travail table par table, à faire en
-- connaissance de cause (jamais par script aveugle — risque d'ouvrir ou
-- fermer un accès par erreur). Advisor : multiple_permissive_policies.
--
-- La requête ci-dessous liste les cibles à consolider, des plus « lourdes »
-- (nombre de policies redondantes) aux plus légères. À traiter ensuite.
-- =====================================================================
-- SELECT tablename, cmd, roles, count(*) AS nb_policies,
--        string_agg(policyname, ', ' ORDER BY policyname) AS policies
--   FROM pg_policies
--  WHERE schemaname = 'public' AND permissive = 'PERMISSIVE'
--  GROUP BY tablename, cmd, roles
-- HAVING count(*) > 1
--  ORDER BY count(*) DESC, tablename;


-- =====================================================================
-- CONTRÔLE POST-EXÉCUTION
-- =====================================================================
-- Relancer l'advisor performance : unindexed_foreign_keys doit tomber à ~0
-- et auth_rls_initplan à ~0. multiple_permissive_policies restera (volet 3,
-- à traiter séparément).
