# Index des migrations Supabase

> Généré le 2026-05-20 par `scripts/gen-migrations-index.mjs`.
> La structure des **tables** fait foi dans `supabase/schema.sql` (baseline introspecté).
> Ce fichier documente l'historique : **151 migrations** (vues, fonctions, RLS, triggers, données).

## ⚠️ Provisioning d'une base neuve
1. Jouer les migrations horodatées dans l'ordre chronologique ci-dessous.
2. Puis les fichiers thématiques (seed contenu, formations, etc.).
3. `schema.sql` sert de **référence de lecture** du modèle de données, pas de script de création unique.

---

## Migrations horodatées (40)

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
| `2026_05_21_fix_rls_org_recursion.sql` | HOTFIX — RLS récursion infinie sur organization_members |
| `2026_05_21_fix_rls_silencieux.sql` | FIX RLS SILENCIEUX — 2026-05-21 |

## Fichiers thématiques / contenu (111)

| Fichier | Description |
|---|---|
| `_diagnostic_bouchoucha.sql` | DIAGNOSTIC — Cas BOUCHOUCHA JOUNAIDI : pourquoi pas de contenu ? |
| `_diagnostic_enrollments_disparus.sql` | DIAGNOSTIC URGENT — Pourquoi les enrollments ont-ils disparu ? |
| `_diagnostic_enrollments_only.sql` | Version courte : juste l'état de enrollments |
| `_diagnostic_enrollments_org_policy.sql` | DIAGNOSTIC URGENT — Pourquoi enrollments.SELECT retourne NULL |
| `_diagnostic_intro_videos.sql` | DIAGNOSTIC — Vidéos d'intro module par module / par CCP |
| `_diagnostic_intro_videos_ccp.sql` | Version courte : pour chaque CCP GOTRM, combien de modules ont |
| `_diagnostic_rls.sql` | DIAGNOSTIC RLS SILENCIEUX — 2026-05-21 |
| `_diagnostic_sfaxi.sql` | DIAGNOSTIC — Pourquoi le stagiaire ne voit aucun module ? |
| `_diagnostic_sfaxi_2.sql` | DIAGNOSTIC #2 — Pourquoi UN seul student dans le résultat ? |
| `_diagnostic_sfaxi_3.sql` | DIAGNOSTIC #3 — Simule EXACTEMENT la requête du dashboard |
| `_fix_create_enrollment_sfaxi.sql` | FIX DATA — Crée un enrollment GOTRM pour les comptes Sfaxi |
| `_fix_create_enrollments_admins.sql` | FIX DATA — Force la création d'enrollments GOTRM pour TOUS les |
| `accessibility.sql` | MA FORMATION TRANSPORT — Point #12 : Accessibilité & handicap (RGAA) |
| `achievements.sql` | Point #9 — Certificats & badges de progression |
| `admin_extensions.sql` | MA FORMATION TRANSPORT — Extensions schema pour l'espace admin |
| `attendance_signed.sql` | Émargement digital signé — sessions synchrones (live, webinaires, jury) |
| `bpf_views.sql` | Vues d'aide pour le Bilan Pédagogique et Financier (DGEFP, annuel) |
| `capa_examen_blanc_final.sql` | CAPACITÉ ≤ 3,5 T — EXAMEN BLANC FINAL TRANSVERSAL |
| `capa_module_a_v3_dense.sql` | MODULE A — DROIT CIVIL ET COMMERCIAL (Capacité de transport ≤ 3,5 T) |
| `capa_module_b_v3_dense.sql` | MODULE B — L'ENTREPRISE ET SON ACTIVITÉ COMMERCIALE (Capacité ≤ 3,5 T) |
| `capa_module_c_v3_dense.sql` | MODULE C — CADRE RÉGLEMENTAIRE DU TRANSPORT (Capacité ≤ 3,5 T) |
| `capa_module_d_v3_dense.sql` | MODULE D — ACTIVITÉ FINANCIÈRE (Capacité ≤ 3,5 T) |
| `capa_module_e_v3_dense.sql` | MODULE E — SALARIÉS ET DROIT SOCIAL (Capacité ≤ 3,5 T) |
| `capa_module_f_v3_dense.sql` | MODULE F — SÉCURITÉ (Capacité ≤ 3,5 T) |
| `capa_modules_cleanup_2026_05_update.sql` | MIGRATION — Nettoyage post-update durées modules Capacité ≤ 3,5 t |
| `capa_modules_durations_2026_05_update.sql` | MIGRATION — Mise à jour des durées des modules Capacité ≤ 3,5 t |
| `coaching.sql` | Point #10 — Accompagnement formateur |
| `e2e_seed.sql` | E2E SEED — Provisionne les fixtures pour les tests Playwright |
| `enrollment.sql` | MA FORMATION TRANSPORT — Point #16 : Inscription, paiement, CPF, financeur |
| `enrollment_extras.sql` | Extras pour la convention de formation Qualiopi |
| `exam_v2.sql` | Simulateur d'examen v2 — drapeaux + relecture |
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
| `tracking.sql` | MA FORMATION TRANSPORT — Tracking temps réel & Qualiopi |
| `trainer_role.sql` | Espace Formateur — ajout du rôle 'trainer' à l'enum user_role. |
| `xp_antifarm.sql` | Anti-farming XP : on n'octroie l'XP qu'à la PREMIÈRE réussite par quiz |
