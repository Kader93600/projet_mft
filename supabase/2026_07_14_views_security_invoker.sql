-- =====================================================================
-- FERMETURE DU DERNIER TROU DE SÉCURITÉ — 14/07/2026
-- Vues SECURITY DEFINER lisibles par tout compte authentifié
--
-- LE PROBLÈME
--   20 vues de reporting s'exécutent avec les droits de leur PROPRIÉTAIRE
--   (comportement par défaut) : elles IGNORENT donc la RLS de l'appelant.
--   Or `authenticated` a le droit de les lire. Conséquence : n'importe quel
--   stagiaire connecté peut interroger l'API PostgREST et lire des données
--   d'AUTRES stagiaires via ces vues (at_risk_students, pending_qr_corrections,
--   user_last_activity, funder_overview...). Fuite de PII inter-utilisateurs.
--   (L'accès `anon` avait déjà été coupé ; c'est le volet `authenticated` qui
--    restait ouvert. Advisor Supabase : 20 x security_definer_view, niveau ERROR.)
--
-- LE CORRECTIF
--   `security_invoker = on` : la vue s'exécute avec les droits de l'APPELANT,
--   donc la RLS des tables sous-jacentes s'applique enfin.
--     • un stagiaire ne voit plus que SES lignes ;
--     • un admin/formateur continue de tout voir (les tables sources ont
--       toutes une policy is_admin()/is_trainer()) ;
--     • les crons (service_role) ne sont pas affectés (ils bypassent la RLS).
--
-- VÉRIFICATIONS FAITES AVANT D'ÉCRIRE CE SCRIPT (lecture seule)
--   1. Les 20 vues : 100 % de leurs tables sources ont une policy admin/formateur
--      → aucune page admin ne se retrouvera vide.
--   2. Toutes les tables sources ont bien un GRANT SELECT à `authenticated`
--      → pas d'erreur « permission denied » (piège classique de security_invoker,
--        qui exige les droits sur les TABLES, pas seulement sur la vue).
--   3. Côté stagiaire, les 3 vues exposées (user_gamification, user_credit_balance,
--      user_daily_activity) sont TOUJOURS lues avec .eq("user_id", user.id)
--      → le comportement est inchangé pour eux.
--   4. Le classement (/classement) passe par la RPC `leaderboard` (SECURITY
--      DEFINER), pas par la vue → la visibilité inter-stagiaires du classement
--      est préservée.
--
-- Idempotent (rejouable). Transactionnel. À appliquer par l'admin.
-- =====================================================================

BEGIN;

ALTER VIEW public.accessibility_overview     SET (security_invoker = on);
ALTER VIEW public.at_risk_students           SET (security_invoker = on);
ALTER VIEW public.attendance_summary         SET (security_invoker = on);
ALTER VIEW public.formations_demand          SET (security_invoker = on);
ALTER VIEW public.funder_overview            SET (security_invoker = on);
ALTER VIEW public.inactivity_alerts          SET (security_invoker = on);
ALTER VIEW public.leaderboard_public         SET (security_invoker = on);
ALTER VIEW public.pending_qr_corrections     SET (security_invoker = on);
ALTER VIEW public.quiz_question_flag_rate    SET (security_invoker = on);
ALTER VIEW public.search_top_queries         SET (security_invoker = on);
ALTER VIEW public.survey_stats               SET (security_invoker = on);
ALTER VIEW public.trainer_formation_overview SET (security_invoker = on);
ALTER VIEW public.trainer_my_students        SET (security_invoker = on);
ALTER VIEW public.user_activity_summary      SET (security_invoker = on);
ALTER VIEW public.user_credit_balance        SET (security_invoker = on);
ALTER VIEW public.user_daily_activity        SET (security_invoker = on);
ALTER VIEW public.user_gamification          SET (security_invoker = on);
ALTER VIEW public.user_last_activity         SET (security_invoker = on);
ALTER VIEW public.user_onboarding_status     SET (security_invoker = on);
ALTER VIEW public.user_training_summary      SET (security_invoker = on);

COMMIT;

-- =====================================================================
-- CONTRÔLE POST-EXÉCUTION
-- =====================================================================
-- 1) Doit renvoyer 0 : plus aucune vue en SECURITY DEFINER.
--    SELECT count(*) FROM pg_class c
--      JOIN pg_namespace n ON n.oid = c.relnamespace
--     WHERE n.nspname = 'public' AND c.relkind = 'v'
--       AND coalesce((SELECT option_value FROM pg_options_to_table(c.reloptions)
--                      WHERE option_name = 'security_invoker'), 'off') <> 'on';
--
-- 2) Relancer l'advisor sécurité : les 20 `security_definer_view` (ERROR)
--    doivent disparaître.
--
-- 3) ⚠️ À TESTER DANS L'APP après application (les pages qui lisent ces vues) :
--    /admin/coaching · /admin/formations · /admin/enrollments · /admin/reports
--    /admin/accessibilite · /admin/analytics/search · /formateur (et /corrections)
--    /classement · /parrainage · /stats
--    Attendu : aucun changement pour admin/formateur ; le stagiaire ne voit
--    toujours que ses propres données.
