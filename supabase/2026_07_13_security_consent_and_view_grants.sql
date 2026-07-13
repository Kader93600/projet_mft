-- =====================================================================
-- CORRECTIFS SÉCURITÉ (audit 13/07/2026) — 2 points
--   1. Bug preuve de consentement « marketing » (RGPD)
--   2. Exposition des vues SECURITY DEFINER au rôle anon
--
-- À APPLIQUER dans le SQL editor Supabase. Idempotent, sans risque
-- applicatif (voir justification par point). Rien ne touche les données.
-- =====================================================================


-- ─────────────────────────────────────────────────────────────────────
-- 1. CONSENTEMENT « marketing » — corrige un bug RGPD
--
-- Symptôme : la bannière cookies et app/api/me/consent/route.ts envoient
-- kind='marketing', mais la contrainte CHECK ne l'autorisait pas
-- (essential/analytics/communications/newsletter uniquement). L'upsert
-- échouait donc en silence (avalé par le .catch()), et le choix
-- « marketing » de l'utilisateur n'était JAMAIS enregistré côté serveur
-- → impossible de prouver le consentement (exigence CNIL).
--
-- Fix : ajouter 'marketing' aux valeurs autorisées.
-- ─────────────────────────────────────────────────────────────────────
ALTER TABLE public.user_consents
  DROP CONSTRAINT IF EXISTS user_consents_kind_check;

ALTER TABLE public.user_consents
  ADD CONSTRAINT user_consents_kind_check
  CHECK (kind IN (
    'essential', 'analytics', 'communications', 'newsletter', 'marketing'
  ));


-- ─────────────────────────────────────────────────────────────────────
-- 2. VUES SECURITY DEFINER — retirer l'accès au rôle « anon »
--
-- Contexte : 20 vues d'agrégat/reporting sont en SECURITY DEFINER (elles
-- s'exécutent avec les droits du propriétaire et IGNORENT la RLS de
-- l'appelant). Or elles étaient lisibles par le rôle « anon » (visiteur
-- NON connecté, via l'API PostgREST publique) → fuite potentielle de PII
-- stagiaire (élèves à risque, activité, corrections en attente...).
--
-- Vérifié : AUCUNE page publique n'utilise ces vues. Elles ne sont
-- interrogées que dans les espaces authentifiés (/admin, /formateur,
-- /stats, /classement, /parrainage, crons), toujours via la session
-- authentifiée (createClient). Retirer l'accès « anon » ferme donc
-- l'exposition au visiteur non connecté SANS rien casser.
--
-- On ne touche PAS le grant « authenticated » : les pages admin/formateur
-- et les stats personnelles en dépendent (elles passent par la session
-- de l'utilisateur, pas par service_role).
-- ─────────────────────────────────────────────────────────────────────
REVOKE SELECT ON
  public.accessibility_overview,
  public.at_risk_students,
  public.attendance_summary,
  public.formations_demand,
  public.funder_overview,
  public.inactivity_alerts,
  public.leaderboard_public,
  public.pending_qr_corrections,
  public.quiz_question_flag_rate,
  public.search_top_queries,
  public.survey_stats,
  public.trainer_formation_overview,
  public.trainer_my_students,
  public.user_activity_summary,
  public.user_credit_balance,
  public.user_daily_activity,
  public.user_gamification,
  public.user_last_activity,
  public.user_onboarding_status,
  public.user_training_summary
FROM anon;


-- =====================================================================
-- CONTRÔLES POST-EXÉCUTION (à lancer après)
-- =====================================================================
-- 1) Le consentement « marketing » est accepté :
--    select pg_get_constraintdef(oid) from pg_constraint
--     where conname = 'user_consents_kind_check';
--    → doit contenir 'marketing'.
--
-- 2) anon n'a plus accès aux vues (doit renvoyer 0 ligne) :
--    select c.relname from pg_class c join pg_namespace n on n.oid=c.relnamespace
--     where n.nspname='public' and c.relkind='v'
--       and c.relname = any(array['at_risk_students','user_training_summary',
--         'funder_overview','pending_qr_corrections','trainer_my_students'])
--       and has_table_privilege('anon', c.oid, 'SELECT');
--
-- =====================================================================
-- RÉSIDUEL NON TRAITÉ ICI (chantier séparé, à tester avant application)
-- =====================================================================
-- Un utilisateur CONNECTÉ (authenticated) peut encore lire ces vues via
-- l'API. Pour les vues admin/formateur (at_risk_students, funder_overview,
-- trainer_my_students, pending_qr_corrections...), le vrai correctif est
-- de passer en `security_invoker = on` afin qu'elles respectent la RLS de
-- l'appelant. MAIS c'est SENSIBLE : certaines vues cross-utilisateur
-- (ex. user_gamification alimente /classement) casseraient sous invoker.
-- À faire vue par vue, avec test sur chaque page. Non inclus ici pour ne
-- rien casser dans ce correctif « sûr ».
