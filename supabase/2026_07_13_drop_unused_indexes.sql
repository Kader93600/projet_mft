-- =====================================================================
-- NETTOYAGE DES INDEX INUTILISÉS — 13/07/2026 (quick win audit perf)
--
-- Source : advisor perf Supabase (54 unused_index + 1 duplicate_index)
-- analysés en lecture seule (pg_stat_user_indexes, idx_scan = 0).
--
-- ⚠️ SUPPRESSION D'INDEX = IRRÉVERSIBLE (mais recréable). Ce script ne
--    supprime QUE les index à gain réel et faible risque :
--      1. le doublon strict sur lesson_progress(user_id)
--      2. les 13 index de recherche (trigram/vector/gin) ~14 Mo, sur une
--         feature de recherche plein-texte/sémantique NON branchée
--         (search_logs = 1 ligne). Tables petites → un scan séquentiel
--         reste rapide si la recherche est réactivée un jour.
--
--    Les ~40 autres index « inutilisés » (8-16 kB chacun) sont laissés :
--    ils ne coûtent quasi rien en espace et servent des fonctionnalités
--    pas encore lancées (enrollment_requests, imports, organizations…).
--    Les supprimer ferait gagner ~0 Mo pour un risque de requête lente
--    dès que la feature tourne. Voir la liste commentée en fin de fichier.
--
-- Idempotent : DROP INDEX IF EXISTS. Rejouable sans erreur.
-- À exécuter par l'admin dans le SQL editor Supabase.
-- =====================================================================

-- ─── 1. Doublon strict : lesson_progress(user_id) indexé deux fois ───
-- lesson_progress_user_id_idx ET lesson_progress_user_idx sont deux
-- btree(user_id) identiques. On garde le premier, on supprime le second.
DROP INDEX IF EXISTS public.lesson_progress_user_idx;

-- ─── 2. Index de recherche non utilisés (~14 Mo) ─────────────────────
-- Recherche plein-texte (pg_trgm) + sémantique (ivfflat vector) + GIN
-- tags : 0 scan, feature non branchée. Recréables si la recherche est
-- un jour activée (voir les migrations d'origine).
DROP INDEX IF EXISTS public.lesson_chunks_embedding_ivfflat_idx;  -- 8.3 Mo (vector)
DROP INDEX IF EXISTS public.lessons_content_trgm;                 -- 2.7 Mo
DROP INDEX IF EXISTS public.question_bank_statement_trgm;         -- 1.7 Mo
DROP INDEX IF EXISTS public.glossary_def_trgm;                    -- 456 kB
DROP INDEX IF EXISTS public.modules_summary_trgm;                 -- 272 kB
DROP INDEX IF EXISTS public.lessons_title_trgm;                   -- 208 kB
DROP INDEX IF EXISTS public.glossary_term_trgm;                   -- 152 kB
DROP INDEX IF EXISTS public.quizzes_title_trgm;                   -- 144 kB
DROP INDEX IF EXISTS public.modules_title_trgm;                   -- 104 kB
DROP INDEX IF EXISTS public.question_bank_tags_gin;               -- 104 kB (GIN)
DROP INDEX IF EXISTS public.msg_body_trgm_idx;                    -- 40 kB
DROP INDEX IF EXISTS public.profiles_email_trgm;                  -- 24 kB
DROP INDEX IF EXISTS public.profiles_fullname_trgm;               -- 24 kB

-- =====================================================================
-- CONTRÔLE POST-EXÉCUTION
-- =====================================================================
-- Vérifier l'espace récupéré et l'absence des index supprimés :
--   select indexrelname, pg_size_pretty(pg_relation_size(indexrelid))
--     from pg_stat_user_indexes
--    where schemaname='public' and indexrelname like '%_trgm'
--       or indexrelname = 'lesson_chunks_embedding_ivfflat_idx';
--   → doit renvoyer 0 ligne.

-- =====================================================================
-- OPTIONNEL — index de fonctionnalités non lancées (NON supprimés)
-- =====================================================================
-- Ces index (8-16 kB) sont inutilisés AUJOURD'HUI mais probablement
-- nécessaires dès que la fonctionnalité correspondante tournera. Gain
-- d'espace ~nul. Ne les supprimer QUE si vous abandonnez la feature.
-- Décommenter au cas par cas, en connaissance de cause :
--
-- DROP INDEX IF EXISTS public.enrollment_requests_formation_slug_idx;
-- DROP INDEX IF EXISTS public.enrollment_requests_pack_slug_idx;
-- DROP INDEX IF EXISTS public.enrollment_requests_assigned_idx;
-- DROP INDEX IF EXISTS public.enrollment_requests_visitor_idx;
-- DROP INDEX IF EXISTS public.enrollment_requests_followup_idx;
-- DROP INDEX IF EXISTS public.question_imports_formation_idx;
-- DROP INDEX IF EXISTS public.question_imports_status_idx;
-- DROP INDEX IF EXISTS public.fpp_formation_idx;
-- DROP INDEX IF EXISTS public.fpp_active_idx;
-- DROP INDEX IF EXISTS public.organizations_status_idx;
-- DROP INDEX IF EXISTS public.organization_members_org_idx;
-- DROP INDEX IF EXISTS public.session_enrollments_status_idx;
-- DROP INDEX IF EXISTS public.attendance_signatures_session_idx;
-- DROP INDEX IF EXISTS public.ss_type_idx;
-- DROP INDEX IF EXISTS public.payments_log_email_idx;
-- DROP INDEX IF EXISTS public.conv_part_pinned_idx;
-- DROP INDEX IF EXISTS public.a11y_req_status_idx;
-- DROP INDEX IF EXISTS public.enrollments_org_idx;
-- DROP INDEX IF EXISTS public.deletion_requests_status_idx;
-- DROP INDEX IF EXISTS public.modules_marketplace_idx;
-- DROP INDEX IF EXISTS public.acquisition_events_campaign_idx;
-- DROP INDEX IF EXISTS public.qr_responses_ai_pending_idx;
-- DROP INDEX IF EXISTS public.conv_last_idx;
-- DROP INDEX IF EXISTS public.student_documents_status_idx;
-- DROP INDEX IF EXISTS public.student_documents_formation_idx;
-- DROP INDEX IF EXISTS public.audit_logs_target_idx;
-- DROP INDEX IF EXISTS public.audit_logs_action_idx;
-- DROP INDEX IF EXISTS public.audit_log_action_idx;
-- DROP INDEX IF EXISTS public.formations_category_idx;
-- DROP INDEX IF EXISTS public.question_bank_import_idx;
-- DROP INDEX IF EXISTS public.search_logs_query_norm_idx;
-- DROP INDEX IF EXISTS public.profiles_trainer_idx;
-- DROP INDEX IF EXISTS public.profiles_ville_idx;
-- DROP INDEX IF EXISTS public.profiles_current_formation_idx;
-- DROP INDEX IF EXISTS public.profiles_group_id_idx;
-- DROP INDEX IF EXISTS public.ann_published_idx;
-- DROP INDEX IF EXISTS public.lessons_duration_idx;
-- DROP INDEX IF EXISTS public.enrollments_funder_idx;
-- DROP INDEX IF EXISTS public.glossary_formation_term_idx;
-- DROP INDEX IF EXISTS public.notif_prefs_in_app_idx;
-- DROP INDEX IF EXISTS public.notif_prefs_push_idx;
