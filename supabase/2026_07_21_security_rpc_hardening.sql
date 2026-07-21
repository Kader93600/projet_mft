-- =====================================================================
-- 2026-07-21 — Durcissement des RPC sensibles (audit pré-livraison)
-- =====================================================================
-- CONSIGNATION : ce script est DÉJÀ APPLIQUÉ en production (base live).
-- Il est versionné ici pour conserver la trace du modèle de sécurité.
-- Ré-exécutable tel quel (idempotent : REVOKE + CREATE OR REPLACE).
--
-- Contexte : l'audit a montré que plusieurs RPC de type "monétaire" ou
-- "parrainage" étaient exécutables par les rôles anon / authenticated,
-- ouvrant une fraude possible (crédit fictif, qualification de parrainage,
-- rattachement de visiteur). Ces RPC ne sont appelées QUE côté serveur
-- (webhook Stripe / service-role), donc on peut retirer l'accès public
-- sans casser aucun chemin légitime. Les RPC réellement appelées en
-- session (createClient) sont, elles, protégées par une garde interne.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) REVOKE : RPC monétaires / parrainage appelées uniquement en service_role
--    (webhook Stripe, jobs). anon + authenticated n'ont plus EXECUTE.
-- ---------------------------------------------------------------------
REVOKE EXECUTE ON FUNCTION public.qualify_referral(uuid, uuid)              FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.apply_credit_to_checkout(uuid, integer, text) FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.apply_loyalty_discount(uuid, integer, text)   FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.link_visitor_to_user(text, uuid)          FROM anon, authenticated;

-- ---------------------------------------------------------------------
-- 2) Garde interne : bump_tutor_quota est appelée EN SESSION (createClient),
--    donc on ne peut pas la REVOKE. On borne l'écriture au propriétaire
--    du quota ou à un admin (empêche de gonfler le quota d'autrui).
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.bump_tutor_quota(
  p_user uuid,
  p_messages integer DEFAULT 1,
  p_cost_cents integer DEFAULT 0
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'extensions', 'pg_temp'
AS $function$
BEGIN
  IF p_user <> auth.uid() AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'forbidden';
  END IF;
  INSERT INTO public.tutor_quotas (user_id, month, messages_count, cost_cents)
  VALUES (p_user, date_trunc('month', now())::date, p_messages, p_cost_cents)
  ON CONFLICT (user_id, month)
  DO UPDATE SET
    messages_count = tutor_quotas.messages_count + EXCLUDED.messages_count,
    cost_cents = tutor_quotas.cost_cents + EXCLUDED.cost_cents,
    updated_at = now();
END;
$function$;

-- ---------------------------------------------------------------------
-- 3) RGPD : anonymize_user étendue pour couvrir TOUTES les données
--    personnelles (l'ancienne version laissait first_name/last_name,
--    adresse, code_postal, ville, pays, date_naissance en clair).
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.anonymize_user(p_user uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'extensions', 'pg_temp'
AS $function$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'admin required';
  END IF;

  UPDATE public.profiles
     SET full_name = NULL,
         first_name = NULL,
         last_name = NULL,
         email = 'deleted-' || p_user::text || '@anonymized.local',
         phone = NULL,
         adresse = NULL,
         code_postal = NULL,
         ville = NULL,
         pays = NULL,
         date_naissance = NULL,
         notes = NULL,
         a11y_notes = NULL,
         disabled = true
   WHERE id = p_user;

  DELETE FROM public.coaching_notes WHERE user_id = p_user;
  DELETE FROM public.accessibility_requests WHERE user_id = p_user;
  DELETE FROM public.notifications WHERE user_id = p_user;

  UPDATE public.deletion_requests
     SET status = 'executed', resolved_at = now()
   WHERE user_id = p_user AND status IN ('pending','approved');

  INSERT INTO public.data_access_log (user_id, actor_id, action, scope)
  VALUES (p_user, auth.uid(), 'delete', 'rgpd_anonymize');
END;
$function$;
