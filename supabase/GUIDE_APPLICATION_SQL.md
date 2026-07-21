# Guide d'application des SQL en attente (éditeur Supabase)

**Mis à jour : 21/07/2026.** À exécuter dans l'ordre ci-dessous, dans le SQL editor Supabase (projet prod). Chaque étape indique le risque, le prérequis et la vérification. Tous les scripts sont idempotents (ré-exécutables sans dégât).

État constaté en base le 21/07 : corrigés QR **tous appliqués** (791/791 QR avec réponse modèle, toutes actives) ; **43 vues encore en SECURITY DEFINER** ; durcissement RPC du 21/07 **déjà appliqué** (`2026_07_21_security_rpc_hardening.sql` n'est qu'une consignation, ne pas le rejouer, même si le rejouer serait sans dégât).

---

## Étape 1 — Sans prérequis, risque quasi nul

| # | Fichier | Ce que ça fait | Vérification |
|---|---|---|---|
| 1a | `2026_07_21_stripe_idempotency.sql` | Table `stripe_events` : dédup des webhooks Stripe (rejeux + double événement payé). Le code déployé fonctionne avec ou sans. | `SELECT count(*) FROM stripe_events;` → 0. Après un paiement test rejoué depuis le dashboard Stripe : une seule inscription. |
| 1b | `2026_07_21_rate_limit.sql` | Table + RPC `rate_limit_hit` : rate limiting partagé entre instances. Sans elle, repli mémoire (comportement actuel). | `SELECT public.rate_limit_hit('test:manuel', 60);` → 1, puis 2… puis `DELETE FROM rate_limit_hits WHERE key='test:manuel';` |
| 1c | `2026_07_13_perf_rls_and_fk_indexes.sql` | 58 index FK manquants + réécriture `auth.uid()` → `(select auth.uid())` dans ~110 policies (perf RLS). Aucun changement fonctionnel. | Les advisors Supabase (Database → Advisors) ne remontent plus `unindexed_foreign_keys`. |

## Étape 2 — Consolidation RLS (risque faible, vérifier après)

| # | Fichier | Ce que ça fait | Vérification |
|---|---|---|---|
| 2a | `2026_07_13_consolidate_permissive_policies.sql` | Fusionne les policies permissives dupliquées (12 groupes) en une seule par groupe (`OR` explicite). Équivalence stricte, gain perf. | Parcours app : dashboard stagiaire, page module, quiz, espace formateur, admin. Advisor `multiple_permissive_policies` en forte baisse. |

## Étape 3 — Fermeture des vues SECURITY DEFINER (le point sécurité restant)

| # | Fichier | Ce que ça fait | Vérification |
|---|---|---|---|
| 3a | `2026_07_13_security_consent_and_view_grants.sql` | Corrige la preuve de consentement marketing (RGPD) + retire les grants `anon` sur les vues de reporting. | Le point 2 du script liste ses propres requêtes de contrôle. |
| 3b | `2026_07_14_views_security_invoker.sql` | Bascule les vues de reporting en `security_invoker` : elles respectent la RLS de l'appelant (un stagiaire ne peut plus lire les données des autres via l'API). | Après application : connecte-toi en **stagiaire** → dashboard/stats OK ; en **formateur** → corrections + stagiaires OK ; en **admin** → analytics OK. Contrôle SQL : la requête en fin de script doit renvoyer 0 vue restante. |

> ⚠️ 3b est le seul script avec un risque applicatif réel : si un écran (admin/formateur) se vide après application, me le signaler — c'est qu'une vue s'appuyait sur le bypass RLS et il faudra une policy dédiée. Prévoir 10 minutes de vérification.

## Étape 4 — Quiz : APRÈS déploiement du code

| # | Fichier | Prérequis | Ce que ça fait | Vérification |
|---|---|---|---|---|
| 4a | `2026_07_21_quiz_scoring_server.sql` | **Le commit « scoring serveur des quiz » (7ab8f3a) doit être déployé en prod AVANT.** | Supprime les policies d'écriture directe du client sur `quiz_attempts` + la RPC n'accepte plus le score QCM du client. Ferme définitivement la falsification de score. | Passer un quiz d'entraînement ET un examen depuis l'UI : les tentatives apparaissent dans /stats avec le bon score. Les requêtes de contrôle sont en fin de script. |

## Déjà appliqué (ne pas rejouer, consignation)

- `2026_07_21_security_rpc_hardening.sql` (REVOKE RPC monétaires + garde bump_tutor_quota + anonymize_user RGPD) — appliqué le 21/07 pendant l'audit.
- `2026_07_14_corriges_qr_6formations.sql` — appliqué (activation des 370 QR, 6 formations).
- `2026_07_13_corriges_qr_capa_leger.sql` + `2026_07_14_corriges_qr_gotrm.sql` — **appliqués le 21/07** (123 corrigés injectés par script REST service-role). Différence volontaire avec les fichiers : le flag `active` a été CONSERVÉ à true (instruction : questions actives avec leurs corrigés), au lieu du `active = false` prévu par les fichiers. Total : 791/791 QR avec réponse modèle.

## Check-list finale (après les 4 étapes)

1. Parcours stagiaire : login → dashboard → leçon → quiz entraînement → examen blanc → /stats.
2. Parcours formateur : corrections QR → notation.
3. Parcours admin : analytics, banque de questions, exports.
4. Paiement test Stripe (mode test) + rejeu du webhook → une seule inscription.
5. Advisors Supabase : plus d'alerte `security_definer_view` ni `unindexed_foreign_keys`.
