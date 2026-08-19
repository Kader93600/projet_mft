# Index des migrations Supabase

> Généré le 2026-08-19 par `scripts/gen-migrations-index.mjs`.
> La structure des **tables** fait foi dans `supabase/schema.sql` (baseline introspecté).
> Ce fichier documente l'historique : **212 migrations** (vues, fonctions, RLS, triggers, données).

## ⚠️ Provisioning d'une base neuve
1. Jouer les migrations horodatées dans l'ordre chronologique ci-dessous.
2. Puis les fichiers thématiques (seed contenu, formations, etc.).
3. `schema.sql` sert de **référence de lecture** du modèle de données, pas de script de création unique.

---

## Migrations horodatées (71)

| Fichier | Description |
|---|---|
| `2026_05_13_pack_pricing.sql` | MIGRATION — Pricing matrix (formation × pack) éditable par admin |
| `2026_05_13_packs_architecture.sql` | MIGRATION — Architecture des 3 packs (Initial / Medium / Premium) |
| `2026_05_14_attach_orphan_modules.sql` | 2026-05-14 · Rattachement automatique des modules orphelins |
| `2026_05_14_autotag_from_source_ref.sql` | 2026-05-14 · Auto-tagging des questions depuis leur source_ref |
| `2026_05_14_enrollment_requests_pack.sql` | 2026-05-14 · Inscription : enregistrer le pack choisi par le visiteur |
| `2026_05_14_live_sessions.sql` | 2026-05-14 · Sessions présentielles & distancielles (Phase 7.1) |
| `2026_05_14_question_attachments.sql` | 2026-05-14 · Annexes libres attachées à une question (Phase 6.4) |
| `2026_05_14_question_imports.sql` | 2026-05-14 · Audit des imports de banque de questions (Phase 6) |
| `2026_05_14_questions_lessons_annexes.sql` | 2026-05-14 · Banque questions : leçons + annexes PDF (Phase 6.2) |
| `2026_05_16_admin_dashboard_views.sql` | 2026-05-16 · Vues SQL pour le Dashboard admin temps réel |
| `2026_05_16_admin_dashboard_views_lot2.sql` | 2026-05-16 · Dashboard admin — Vues SQL Lot 1 (enrichissements) |
| `2026_05_16_admin_dashboard_views_lot3.sql` | 2026-05-16 · Dashboard admin — Vues SQL Lot 2 |
| `2026_05_16_finalize_quiz_grading_fix.sql` | 2026-05-16 · Fix finalize_quiz_grading |
| `2026_05_16_qr_only_scoring.sql` | 2026-05-16 · QR-only scoring + fix notifications formateur |
| `2026_05_16_recompute_qr_only_attempts.sql` | 2026-05-16 · Recompute one-shot des tentatives QR-only |
| `2026_05_17_module_intro_video.sql` | 2026-05-17 · Vidéos d'introduction par module |
| `2026_05_17_module_intro_video_relax_policy.sql` | 2026-05-17 · Relax policy module-intro-videos |
| `2026_05_18_admin_tutor_views.sql` | Finition C / P3 #1 — RPCs admin pour le monitoring tuteur IA |
| `2026_05_18_daily_login_streak.sql` | Sprint 1 / Gamification — Daily login + streak bonus |
| `2026_05_18_ia_tutor.sql` | Sprint 3 / P3 #1 — IA tuteur RAG (Claude Sonnet 4 + pgvector) |
| `2026_05_18_leaderboard_opt_out.sql` | Sprint 1 / Gamification — Opt-out classement public |
| `2026_05_18_qr_ai_grading.sql` | Sprint 3.3 / P3 #1 — Correction QR automatique par Claude |
| `2026_05_18_qr_only_nullable_percentage.sql` | Hotfix : quiz_attempts.percentage + passed nullables pour QR-only |
| `2026_05_18_quiz_offline_sync.sql` | Sprint 2 / PWA — Quiz offline + sync différée |
| `2026_05_19_funder_dashboard.sql` | P3 #2 / Sprint B — Dashboard financeur enrichi |
| `2026_05_19_organizations.sql` | P3 #2 / Sprint C — Multi-tenant entreprise (MVP v1) |
| `2026_05_19_referrals.sql` | P3 #2 / Sprint A — Programme de parrainage |
| `2026_05_20_acquisition.sql` | P3 #3 / Sprint B — UTM tracking + funnel multi-touch (first-touch) |
| `2026_05_20_crm.sql` | P3 #3 / Sprint A — CRM léger (enrichissement enrollment_requests) |
| `2026_05_20_enrollment_requests_address.sql` | HOTFIX UX — Ajout des champs adresse à enrollment_requests |
| `2026_05_20_fix_formation_slug_and_views.sql` | HOTFIX — Pipeline admin à 0 + stagiaires sans modules visibles |
| `2026_05_20_fix_inactivity_check_kind_to_type.sql` | HOTFIX — RPC run_inactivity_check utilisait colonne "kind" inexistante |
| `2026_05_20_loyalty.sql` | P3 #3 / Loyalty — Programme de fidélité |
| `2026_05_20_marketplace_rollback.sql` | ROLLBACK — Marketplace formateurs externes (P3 #2 Sprint D) |
| `2026_05_21_audit_10_exam_seed.sql` | AUDIT #10 — Tirage d'examen aléatoire stable (seed déterministe) |
| `2026_05_21_audit_lot_a_securite.sql` | AUDIT LOT A — Corrections sécurité & légal |
| `2026_05_21_audit_lot_b_pedagogie.sql` | AUDIT LOT B — Corrections pédagogiques |
| `2026_05_21_audit_lot_c_data.sql` | AUDIT LOT C — Corrections data/reporting |
| `2026_05_21_edof_dossiers.sql` | 2026-05-21 · Intégration EDOF (Mon Compte Formation / Caisse des Dépôts) |
| `2026_05_21_fix_rls_org_recursion.sql` | HOTFIX — RLS récursion infinie sur organization_members |
| `2026_05_21_fix_rls_silencieux.sql` | FIX RLS SILENCIEUX — 2026-05-21 |
| `2026_05_22_attendance_signature_reuse.sql` | Émargement : réutilisation de la signature de référence |
| `2026_05_22_document_signature_audit.sql` | Renforcement de la piste d'audit des signatures de documents |
| `2026_05_22_onboarding_documents_custom.sql` | Documents d'accueil : autoriser des types personnalisés |
| `2026_05_22_signature_obligatoire.sql` | Signature obligatoire à la première connexion + signature de référence |
| `2026_05_24_student_documents.sql` | MA FORMATION TRANSPORT — Documents importés par le stagiaire |
| `2026_05_29_email_log.sql` | Journal des emails envoyés depuis la plateforme (composer interne). |
| `2026_05_30_email_inbox.sql` | Boîte de réception : ajoute direction / état de lecture / attribution / |
| `2026_05_30_fix_attempt_deletion_trigger.sql` | Correctif suppression d'utilisateur (suite) — trigger de log sur |
| `2026_05_30_fix_delete_user_fk.sql` | Correctif suppression d'utilisateur — FK bloquantes vers auth.users. |
| `2026_05_30_fix_qcm_is_correct_key.sql` | Correctif — QCM sans bonne réponse + champs de réponse vides en édition. |
| `2026_05_30_profiles_first_last_name.sql` | Profiles : Prénom / Nom séparés (en plus de full_name). |
| `2026_06_02_acquisition_click_ids.sql` | Marketing acquisition — Phase 0 : capture des click-IDs publicitaires |
| `2026_07_13_consent_audit_log.sql` | JOURNAL DE PREUVE DE CONSENTEMENT — 13/07/2026 (conformité CNIL) |
| `2026_07_13_consolidate_permissive_policies.sql` | CONSOLIDATION DES POLICIES PERMISSIVES — 13/07/2026 (audit perf) |
| `2026_07_13_corriges_qr_capa_leger.sql` | CORRIGÉS QR — CAPACITÉ LÉGÈRE (≤ 3,5 t) — 13/07/2026 |
| `2026_07_13_data_retention_purge.sql` | PURGE AUTOMATIQUE (RGPD, minimisation) — 13/07/2026 |
| `2026_07_13_drop_unused_indexes.sql` | NETTOYAGE DES INDEX INUTILISÉS — 13/07/2026 (quick win audit perf) |
| `2026_07_13_perf_rls_and_fk_indexes.sql` | PERFORMANCE BASE — 13/07/2026 (audit perf, advisors Supabase) |
| `2026_07_13_pin_function_search_path.sql` | DURCISSEMENT SÉCURITÉ — search_path des fonctions (13/07/2026) |
| `2026_07_13_security_consent_and_view_grants.sql` | CORRECTIFS SÉCURITÉ (audit 13/07/2026) — 2 points |
| `2026_07_14_corriges_qr_6formations.sql` | CORRIGÉS QR + ACTIVATION — 6 formations — 14/07/2026 |
| `2026_07_14_corriges_qr_gotrm.sql` | CORRIGÉS QR — GOTRM (RNCP 40990, CCP1) — 14/07/2026 |
| `2026_07_14_views_security_invoker.sql` | FERMETURE DU DERNIER TROU DE SÉCURITÉ — 14/07/2026 |
| `2026_07_21_quiz_scoring_server.sql` | 2026-07-21 — QUIZ-03 : fermeture des écritures client sur les scores |
| `2026_07_21_rate_limit.sql` | 2026-07-21 — SEC-RL : rate limiting partagé (backend Postgres) |
| `2026_07_21_security_rpc_hardening.sql` | 2026-07-21 — Durcissement des RPC sensibles (audit pré-livraison) |
| `2026_07_21_stripe_idempotency.sql` | 2026-07-21 — PAY-01 : idempotence du webhook Stripe |
| `2026_07_22_fix_profiles_policy_recursion.sql` | 2026-07-22 — HOTFIX : récursion infinie de policy sur profiles |
| `2026_08_14_convocations.sql` | 2026-08-14 — Module « Convocations PDF » (candidats + jurys) |
| `2026_08_20_gamification_async.sql` | Gamification asynchrone — tenue en charge des examens |

## Fichiers thématiques / contenu (141)

| Fichier | Description |
|---|---|
| `accessibility.sql` | MA FORMATION TRANSPORT — Point #12 : Accessibilité & handicap (RGAA) |
| `achievements.sql` | Point #9 — Certificats & badges de progression |
| `admin_extensions.sql` | MA FORMATION TRANSPORT — Extensions schema pour l'espace admin |
| `attendance_signed.sql` | Émargement digital signé — sessions synchrones (live, webinaires, jury) |
| `bpf_views.sql` | Vues d'aide pour le Bilan Pédagogique et Financier (DGEFP, annuel) |
| `capa_examen_blanc_final.sql` | CAPACITÉ ≤ 3,5 T — EXAMEN BLANC FINAL TRANSVERSAL |
| `capa_lourd_module_a_v1.sql` | CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : MODULE A : DROIT CIVIL : v1 |
| `capa_lourd_module_b_v1.sql` | CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : MODULE B : DROIT COMMERCIAL |
| `capa_lourd_module_c_v1.sql` | CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : MODULE C : DROIT SOCIAL : v1 |
| `capa_lourd_module_d_v1.sql` | CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : MODULE D : DROIT FISCAL : v1 |
| `capa_lourd_module_e_v1.sql` | CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : MODULE E : GESTION |
| `capa_lourd_module_f_v1.sql` | CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : MODULE F : ACCÈS À LA |
| `capa_lourd_module_g_v1.sql` | CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : MODULE G : NORMES TECHNIQUES |
| `capa_lourd_module_h_v1.sql` | CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : MODULE H : SÉCURITÉ ROUTIÈRE |
| `capa_lourd_module_m0_m9_v1.sql` | CAPACITÉ DE TRANSPORT > 3,5 T (LOURD) : LOT 9 (FINAL) : |
| `capa_module_a_v3_dense.sql` | MODULE A — DROIT CIVIL ET COMMERCIAL (Capacité de transport ≤ 3,5 T) |
| `capa_module_b_v3_dense.sql` | MODULE B — L'ENTREPRISE ET SON ACTIVITÉ COMMERCIALE (Capacité ≤ 3,5 T) |
| `capa_module_c_v3_dense.sql` | MODULE C — CADRE RÉGLEMENTAIRE DU TRANSPORT (Capacité ≤ 3,5 T) |
| `capa_module_d_v3_dense.sql` | MODULE D — ACTIVITÉ FINANCIÈRE (Capacité ≤ 3,5 T) |
| `capa_module_e_v3_dense.sql` | MODULE E — SALARIÉS ET DROIT SOCIAL (Capacité ≤ 3,5 T) |
| `capa_module_f_v3_dense.sql` | MODULE F — SÉCURITÉ (Capacité ≤ 3,5 T) |
| `capa_modules_cleanup_2026_05_update.sql` | MIGRATION — Nettoyage post-update durées modules Capacité ≤ 3,5 t |
| `capa_modules_durations_2026_05_update.sql` | MIGRATION — Mise à jour des durées des modules Capacité ≤ 3,5 t |
| `coaching.sql` | Point #10 — Accompagnement formateur |
| `comm_module_1_v1.sql` | COMMISSIONNAIRE DE TRANSPORT : MODULE 1 : LE MÉTIER ET SON CADRE |
| `comm_module_2_v1.sql` | COMMISSIONNAIRE DE TRANSPORT : MODULE 2 : LE CONTRAT DE COMMISSION |
| `comm_module_3_v1.sql` | COMMISSIONNAIRE DE TRANSPORT : MODULE 3, ORGANISER LE TRANSPORT |
| `comm_module_4_v1.sql` | COMMISSIONNAIRE DE TRANSPORT : MODULE 4 : INCOTERMS ET DOUANE |
| `comm_module_5_v1.sql` | COMMISSIONNAIRE DE TRANSPORT : MODULE 5 : GESTION, AFFRÈTEMENT |
| `comm_module_6_v1.sql` | COMMISSIONNAIRE DE TRANSPORT : MODULE 6 (FINAL) |
| `e2e_seed.sql` | E2E SEED — Provisionne les fixtures pour les tests Playwright |
| `ecsr_module_1_v1.sql` | ECSR : MODULE 1 : LE MÉTIER ET LE TITRE ECSR |
| `ecsr_module_2_v1.sql` | ECSR : MODULE 2 : LE REMC ET LES PARCOURS DE FORMATION |
| `ecsr_module_3_v1.sql` | ECSR : MODULE 3 : ENSEIGNER EN VOITURE : LA SÉANCE INDIVIDUELLE |
| `ecsr_module_4_v1.sql` | ECSR (TITRE PRO ENSEIGNANT DE LA CONDUITE ET DE LA SÉCURITÉ ROUTIÈRE) |
| `ecsr_module_5_v1.sql` | TITRE PRO ECSR : MODULE 5 : SENSIBILISER TOUS LES PUBLICS (CCP2) |
| `ecsr_module_6_v1.sql` | TITRE PROFESSIONNEL ECSR : MODULE 6 : PRÉPARER LA SESSION DU TITRE |
| `enrollment.sql` | MA FORMATION TRANSPORT — Point #16 : Inscription, paiement, CPF, financeur |
| `enrollment_extras.sql` | Extras pour la convention de formation Qualiopi |
| `ertv_module_1_v1.sql` | ERTV (Exploitant en transport routier de voyageurs) |
| `ertv_module_2_v1.sql` | ERTV : EXPLOITANT EN TRANSPORT ROUTIER DE VOYAGEURS |
| `ertv_module_3_v1.sql` | ERTV : EXPLOITANT EN TRANSPORT ROUTIER DE VOYAGEURS |
| `ertv_module_4_v1.sql` | ERTV : EXPLOITANT EN TRANSPORT ROUTIER DE VOYAGEURS |
| `ertv_module_5_v1.sql` | ERTV : EXPLOITANT EN TRANSPORT ROUTIER DE VOYAGEURS |
| `ertv_module_6_v1.sql` | ERTV : EXPLOITANT EN TRANSPORT ROUTIER DE VOYAGEURS |
| `exam_v2.sql` | Simulateur d'examen v2 — drapeaux + relecture |
| `fimo_module_0_v1.sql` | FIMO / FCO MARCHANDISES : MODULE 0 : LA QUALIFICATION DES |
| `fimo_module_m5_v1.sql` | FIMO / FCO MARCHANDISES : MODULE 5 : PRÉPARATION À L'ÉVALUATION |
| `fimo_module_t1_v1.sql` | FIMO / FCO MARCHANDISES : THÈME 1 : CONDUITE RATIONNELLE AXÉE |
| `fimo_module_t2_v1.sql` | FIMO / FCO MARCHANDISES : THÈME 2 : RÉGLEMENTATIONS DU TRANSPORT |
| `fimo_module_t3_v1.sql` | FIMO / FCO MARCHANDISES : THÈME 3 : SANTÉ, SÉCURITÉ ROUTIÈRE ET |
| `fimo_module_t4_v1.sql` | FIMO / FCO MARCHANDISES : THÈME 4 : SERVICE, LOGISTIQUE ET IMAGE |
| `formation_settings_multi.sql` | MIGRATION — formation_settings : singleton → multi-formations |
| `formations_v2.sql` | Multi-formations v2 — modèle de données. |
| `funder_signature.sql` | Signature électronique simple côté financeur (eIDAS niveau 1). |
| `gamification.sql` | MA FORMATION TRANSPORT — Point #15 : Gamification (XP, niveaux, streak, classement) |
| `glossary_capa.sql` | GLOSSAIRE — Capacité de transport léger (-3,5T) |
| `glossary_capa_plus.sql` | GLOSSAIRE — Capacité de transport lourd (+3,5T) |
| `glossary_commissionnaire.sql` | GLOSSAIRE — Commissionnaire de transport |
| `glossary_ecsr.sql` | GLOSSAIRE — ECSR (Enseignant de la Conduite et de la Sécurité Routière) |
| `glossary_ertv.sql` | GLOSSAIRE — ERTV (Exploitant en Transport Routier de Voyageurs) |
| `glossary_extensions.sql` | GLOSSARY — extensions multi-formations |
| `glossary_fimo_fco.sql` | GLOSSAIRE — FIMO / FCO (Formation Initiale et Continue Obligatoires |
| `glossary_gotrm.sql` | GLOSSAIRE — GOTRM (Gestionnaire des Opérations de Transport Routier |
| `glossary_gotrm_v4_livret_refresh.sql` | GLOSSAIRE GOTRM — refresh v4 livret CCP1 (mai 2026) |
| `glossary_taxi_vtc.sql` | GLOSSAIRE — Taxi / VTC (Voiture de Transport avec Chauffeur) |
| `gotrm_ccp1_examen_blanc_final.sql` | GOTRM (RNCP 40990) — EXAMEN BLANC FINAL TRANSVERSAL CCP1 |
| `gotrm_ccp1_qr_v2.sql` | COURS GOTRM CCP1 — Questions Rédigées (QR) v2 [BACKUP SQL] |
| `gotrm_ccp2_cours.sql` | COURS GOTRM CCP2 — Piloter les trafics réguliers sous contrat de |
| `gotrm_ccp3_cours.sql` | COURS GOTRM CCP3 — Optimiser l'ensemble des moyens liés à l'activité |
| `gotrm_ch01_v4_livret.sql` | GOTRM — Chapitre 1 : L'environnement du transport routier de marchandises |
| `gotrm_ch02_v4_livret.sql` | GOTRM — Chapitre 2 : Les véhicules, les carrosseries et les marchandises |
| `gotrm_ch03_v4_livret.sql` | GOTRM — CHAPITRE 3 : Analyser une demande et vérifier la faisabilité |
| `gotrm_ch04_v4_livret.sql` | GOTRM — Chapitre 4 : Calculer le coût de revient et tarifer une prestation |
| `gotrm_ch05_v4_livret.sql` | GOTRM — Chapitre 5 : Rédiger une offre commerciale |
| `gotrm_ch06_v4_livret.sql` | GOTRM — Chapitre 6 : Choisir et affecter les moyens matériels et humains |
| `gotrm_ch07_v4_livret.sql` | GOTRM — Chapitre 7 : Les documents de transport |
| `gotrm_ch08_v4_livret.sql` | GOTRM — Chapitre 8 : Planifier et optimiser les opérations |
| `gotrm_ch09_v4_livret.sql` | GOTRM — Chapitre 9 : La réglementation sociale européenne (RSE) |
| `gotrm_ch10_v4_livret.sql` | GOTRM — Chapitre 10 : Encadrer une équipe de conducteurs |
| `gotrm_ch11_v4_livret.sql` | GOTRM — Chapitre 11 : Le suivi d'exploitation et la gestion des aléas |
| `gotrm_ch12_v4_livret.sql` | GOTRM — Chapitre 12 : Facturation, litiges et clôture des dossiers |
| `gotrm_ch13_v4_livret.sql` | GOTRM — Chapitre 13 : Qualité, indicateurs de performance et analyse financière |
| `gotrm_ch14_v4_livret.sql` | GOTRM — Chapitre 14 : Obligations environnementales et RSE entreprise |
| `gotrm_ch15_v4_livret.sql` | GOTRM — Chapitre 15 : Transport international opérationnel |
| `gotrm_ch16_v4_livret.sql` | GOTRM — Chapitre 16 : Gestion des supports de charge |
| `gotrm_ch17_v4_livret.sql` | GOTRM — Chapitre 17 : L'anglais professionnel en transport |
| `gotrm_purge_legacy.sql` | PURGE GOTRM LEGACY — préparation à la refonte v4 livret CCP1 |
| `inactivity_alerts.sql` | Suivi de l'inactivité — indicateur Qualiopi 22 (suivi pédagogique) |
| `leaderboard_periods.sql` | Classement par fenêtre temporelle (semaine / mois / total) |
| `lesson_versions.sql` | Versioning des leçons (Qualiopi indicateur 11 — adaptation des contenus) |
| `messaging.sql` | Communication & notifications |
| `messaging_trainer.sql` | Messagerie : extension formateur ↔ stagiaire |
| `messaging_v2_1_fix_rls_recursion.sql` | INFRA - Messagerie v2.1 fix RLS recursion |
| `messaging_v2_2_leave_delete.sql` | INFRA - Messagerie v2.2 leave + delete conversation |
| `messaging_v2_3_attachments_reactions.sql` | INFRA - Messagerie v2.3 attachments + reactions |
| `messaging_v2_4_search_pin_messages.sql` | INFRA - Messagerie v2.4 search + pin messages |
| `messaging_v2_multi_conversations.sql` | INFRA - Messagerie v2 multi-conversations |
| `mock_exam.sql` | Examen blanc officiel (Point #8) |
| `multi_formation_sprint1.sql` | Multi-formations — Sprint 1 : verrouillage sécurité minimal viable |
| `multi_formation_sprint2.sql` | Multi-formations — Sprint 2 : verrouillage RLS lecture du contenu |
| `notification_preferences_v1.sql` | INFRA - Notifications préférences par type |
| `notifications_v2_premium.sql` | INFRA - Notifications v2 premium (types étendus + delete) |
| `onboarding.sql` | Onboarding stagiaire & documents d'entrée en formation |
| `onboarding_documents_content.sql` | Contenu des 3 documents d'accueil stagiaire |
| `p2_indexes_and_hardening.sql` | P2 — Indexes composites + durcissement formation_id |
| `payments_log.sql` | Journal des paiements Stripe (idempotent — clé sur stripe_session_id) |
| `pedagogy.sql` | Enrichissement pédagogique (Point #7) |
| `permissions_v2_step1.sql` | Permissions v2 — ÉTAPE 1 : ajout de 'super_admin' à l'enum user_role. |
| `permissions_v2_step2.sql` | Permissions v2 — ÉTAPE 2 : helpers + audit_logs. |
| `placement.sql` | Positionnement initial (Point #6) |
| `placement_extensions.sql` | Placement — extensions : |
| `placement_filter_by_formation.sql` | Placement — filtrage par formation du stagiaire |
| `placement_questions_seed.sql` | Test de positionnement — banque de questions pour les 8 formations |
| `privacy.sql` | MA FORMATION TRANSPORT — Point #17 : i18n + RGPD avancé |
| `profiles_student_fields.sql` | MIGRATION — champs étendus sur profiles pour la création stagiaire |
| `push_subscriptions_v1.sql` | INFRA - Push notifications subscriptions |
| `qr_grading.sql` | Workflow correction différée pour les questions rédigées (QR) |
| `qualiopi.sql` | Qualiopi : preuves complémentaires |
| `question_bank.sql` | Banque de questions multi-formations (QCM + QR rédigées) |
| `quiz_attempts_passed_nullable.sql` | INFRA - Quiz attempts passed nullable (fix mixte) |
| `quiz_attempts_trainer_read.sql` | INFRA - Quiz attempts : lecture par les formateurs |
| `realtime.sql` | Active la publication Realtime sur les notifications |
| `rls_formation_scoping.sql` | Restriction d'accès par formation — RLS sur modules / lessons / quizzes |
| `search.sql` | MA FORMATION TRANSPORT — Point #13 : Recherche globale |
| `search_logs.sql` | Tracking des recherches (insights pédagogiques) |
| `security.sql` | MA FORMATION TRANSPORT — Durcissement sécurité |
| `seed.sql` | MA FORMATION TRANSPORT — Données pédagogiques enrichies |
| `storage_content_media.sql` | STORAGE — bucket content-media (uploads images modules / quiz / questions) |
| `taxi_module_1_v1.sql` | TAXI / VTC (T3P) : MODULE 1 : LE CADRE DU T3P ET L'ACCÈS AU MÉTIER |
| `taxi_module_2_v1.sql` | TAXI / VTC (T3P) : MODULE 2 : TAXI ET VTC, DEUX RÉGIMES À MAÎTRISER |
| `taxi_module_3_v1.sql` | TAXI / VTC (T3P) : MODULE 3 : GÉRER SON ACTIVITÉ T3P |
| `taxi_module_4_v1.sql` | TAXI / VTC (T3P) : MODULE 4 : SÉCURITÉ ROUTIÈRE DU CONDUCTEUR T3P |
| `taxi_module_5_v1.sql` | TAXI / VTC : MODULE 5 : RÉUSSIR LE FRANÇAIS ET L'ANGLAIS DE L'EXAMEN |
| `taxi_module_6_v1.sql` | TAXI / VTC (T3P) : MODULE 6 : CONNAISSANCE DU TERRITOIRE ET ITINÉRAIRES |
| `taxi_module_7_v1.sql` | TAXI / VTC : MODULE 7 : SPÉCIFIQUE TAXI (ADS, TAXIMÈTRE, TARIFS) |
| `taxi_module_8_v1.sql` | TAXI / VTC (T3P) : MODULE 8 : SPÉCIFIQUE VTC : REGISTRE, RÉSERVATION |
| `taxi_module_9_v1.sql` | TAXI / VTC : MODULE 9 : PRÉPARATION À L'EXAMEN + 2 EXAMENS BLANCS |
| `tracking.sql` | MA FORMATION TRANSPORT — Tracking temps réel & Qualiopi |
| `trainer_role.sql` | Espace Formateur — ajout du rôle 'trainer' à l'enum user_role. |
| `xp_antifarm.sql` | Anti-farming XP : on n'octroie l'XP qu'à la PREMIÈRE réussite par quiz |
