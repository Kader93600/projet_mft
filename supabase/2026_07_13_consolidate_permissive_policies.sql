-- =====================================================================
-- CONSOLIDATION DES POLICIES PERMISSIVES — 13/07/2026 (audit perf)
--
-- Advisor : multiple_permissive_policies (357 constats, qui se réduisent à
-- 12 GROUPES réels : une même table/action/rôles couverte par 2 policies
-- permissives). Postgres évalue TOUTES les policies permissives et les
-- combine en OR à chaque ligne → surcoût. On les fusionne en UNE policy
-- par groupe avec `USING (q1 OR q2)` (+ `WITH CHECK` fusionné pour les ALL).
--
-- ✅ ÉQUIVALENCE STRICTE : plusieurs policies permissives = déjà un OR
--    logique. Fusionner en une seule policy OR ne change RIEN aux accès,
--    seulement le nombre d'évaluations. Quals repris VERBATIM depuis la base.
--
-- Transaction atomique (jamais de fenêtre sans policy). Idempotent
-- (DROP ... IF EXISTS). À appliquer par l'admin dans le SQL editor Supabase.
-- =====================================================================

BEGIN;

-- ── 1. document_acceptances (SELECT) : admin OR propriétaire ──────────
DROP POLICY IF EXISTS da_admin_read ON public.document_acceptances;
DROP POLICY IF EXISTS da_own_read   ON public.document_acceptances;
CREATE POLICY da_read ON public.document_acceptances
  FOR SELECT TO public
  USING (is_admin() OR (user_id = (SELECT auth.uid())));

-- ── 2. enrollments (SELECT, authenticated) : self/admin OR financeur ──
DROP POLICY IF EXISTS enrollments_funder_read ON public.enrollments;
DROP POLICY IF EXISTS enrollments_self        ON public.enrollments;
CREATE POLICY enrollments_read ON public.enrollments
  FOR SELECT TO authenticated
  USING (
    (((SELECT auth.uid()) = user_id) OR is_admin())
    OR (funder_id IN (
      SELECT funders.id FROM funders
      WHERE (funders.portal_user_id = (SELECT auth.uid()))
    ))
  );

-- ── 3. formation_pack_prices (SELECT) : public actif OR admin ─────────
DROP POLICY IF EXISTS fpp_admin_read_all ON public.formation_pack_prices;
DROP POLICY IF EXISTS fpp_public_read    ON public.formation_pack_prices;
CREATE POLICY fpp_read ON public.formation_pack_prices
  FOR SELECT TO public
  USING (
    (active = true)
    OR (EXISTS (
      SELECT 1 FROM profiles
      WHERE ((profiles.id = (SELECT auth.uid()))
        AND (profiles.role = ANY (ARRAY['admin'::user_role, 'super_admin'::user_role])))
    ))
  );

-- ── 4. live_sessions (SELECT) : staff OR étudiant premium ─────────────
DROP POLICY IF EXISTS live_sessions_staff_read   ON public.live_sessions;
DROP POLICY IF EXISTS live_sessions_student_read ON public.live_sessions;
CREATE POLICY live_sessions_read ON public.live_sessions
  FOR SELECT TO public
  USING (
    (is_admin() OR user_has_trainer_access((SELECT auth.uid()), formation_id))
    OR user_has_premium_for_formation((SELECT auth.uid()), formation_id)
  );

-- ── 5. organization_members (ALL) : admin OR org-admin ────────────────
DROP POLICY IF EXISTS organization_members_admin     ON public.organization_members;
DROP POLICY IF EXISTS organization_members_org_admin ON public.organization_members;
CREATE POLICY organization_members_manage ON public.organization_members
  FOR ALL TO public
  USING (is_admin() OR is_org_admin_of(organization_id))
  WITH CHECK (is_admin() OR is_org_admin_of(organization_id));

-- ── 6. payments_log (SELECT) : admin OR propriétaire ──────────────────
DROP POLICY IF EXISTS payments_log_admin_read ON public.payments_log;
DROP POLICY IF EXISTS payments_log_self_read  ON public.payments_log;
CREATE POLICY payments_log_read ON public.payments_log
  FOR SELECT TO public
  USING (is_admin() OR ((SELECT auth.uid()) = user_id));

-- ── 7. qr_responses (SELECT) : propriétaire corrigé OR formateur/admin ─
DROP POLICY IF EXISTS qr_responses_self_read    ON public.qr_responses;
DROP POLICY IF EXISTS qr_responses_trainer_read ON public.qr_responses;
CREATE POLICY qr_responses_read ON public.qr_responses
  FOR SELECT TO public
  USING (
    (is_trainer() OR is_admin())
    OR (EXISTS (
      SELECT 1 FROM quiz_attempts a
      WHERE ((a.id = qr_responses.attempt_id)
        AND (a.user_id = (SELECT auth.uid()))
        AND (a.status = 'graded'::text))
    ))
  );

-- ── 8. question_attachments (SELECT) : admin OR étudiant avec accès ───
DROP POLICY IF EXISTS qattach_admin_read   ON public.question_attachments;
DROP POLICY IF EXISTS qattach_student_read ON public.question_attachments;
CREATE POLICY qattach_read ON public.question_attachments
  FOR SELECT TO public
  USING (
    is_admin()
    OR (EXISTS (
      SELECT 1 FROM question_bank q
      WHERE ((q.id = question_attachments.question_id)
        AND (q.active = true)
        AND (q.formation_id IS NOT NULL)
        AND (EXISTS (
          SELECT 1 FROM formations f
          WHERE ((f.id = q.formation_id)
            AND has_formation_access((SELECT auth.uid()), f.slug))
        )))
    ))
  );

-- ── 9. question_bank (SELECT) : admin OR étudiant avec accès ──────────
DROP POLICY IF EXISTS qbank_admin_read   ON public.question_bank;
DROP POLICY IF EXISTS qbank_student_read ON public.question_bank;
CREATE POLICY qbank_read ON public.question_bank
  FOR SELECT TO public
  USING (
    is_admin()
    OR ((active = true)
      AND (formation_id IS NOT NULL)
      AND (EXISTS (
        SELECT 1 FROM formations f
        WHERE ((f.id = question_bank.formation_id)
          AND has_formation_access((SELECT auth.uid()), f.slug))
      )))
  );

-- ── 10. satisfaction_surveys (SELECT) : admin OR propriétaire ─────────
DROP POLICY IF EXISTS ss_admin_read ON public.satisfaction_surveys;
DROP POLICY IF EXISTS ss_own_read   ON public.satisfaction_surveys;
CREATE POLICY ss_read ON public.satisfaction_surveys
  FOR SELECT TO public
  USING (is_admin() OR (user_id = (SELECT auth.uid())));

-- ── 11. session_enrollments (ALL) : self OR staff ────────────────────
DROP POLICY IF EXISTS session_enrollments_self_write  ON public.session_enrollments;
DROP POLICY IF EXISTS session_enrollments_staff_write ON public.session_enrollments;
CREATE POLICY session_enrollments_manage ON public.session_enrollments
  FOR ALL TO public
  USING (
    (user_id = (SELECT auth.uid()))
    OR (is_admin() OR (EXISTS (
      SELECT 1 FROM live_sessions ls
      WHERE ((ls.id = session_enrollments.session_id)
        AND user_has_trainer_access((SELECT auth.uid()), ls.formation_id))
    )))
  )
  WITH CHECK (
    ((user_id = (SELECT auth.uid())) AND (EXISTS (
      SELECT 1 FROM live_sessions ls
      WHERE ((ls.id = session_enrollments.session_id)
        AND user_has_premium_for_formation((SELECT auth.uid()), ls.formation_id))
    )))
    OR (is_admin() OR (EXISTS (
      SELECT 1 FROM live_sessions ls
      WHERE ((ls.id = session_enrollments.session_id)
        AND user_has_trainer_access((SELECT auth.uid()), ls.formation_id))
    )))
  );

-- ── 12. user_signatures (SELECT) : admin OR propriétaire ──────────────
DROP POLICY IF EXISTS us_admin_read ON public.user_signatures;
DROP POLICY IF EXISTS us_own_read   ON public.user_signatures;
CREATE POLICY us_read ON public.user_signatures
  FOR SELECT TO public
  USING (is_admin() OR (user_id = (SELECT auth.uid())));

COMMIT;

-- =====================================================================
-- CONTRÔLE POST-EXÉCUTION
-- =====================================================================
-- Doit renvoyer 0 (plus aucun groupe table/action/rôles à >1 permissive) :
--   SELECT tablename, cmd, roles FROM pg_policies
--    WHERE schemaname='public' AND permissive='PERMISSIVE'
--    GROUP BY tablename, cmd, roles HAVING count(*) > 1;
-- Puis relancer l'advisor perf : multiple_permissive_policies doit chuter.
