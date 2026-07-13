# Registre des activités de traitement (RGPD, art. 30)

> **MA FORMATION TRANSPORT** — responsable de traitement.
> SIREN 908 851 280 · 39 Avenue des Sablons Bouillants, 77100 Meaux.
> Contact données personnelles : `dpo@maformationtransport.fr` *(à confirmer)*.
>
> ⚠️ **Document de travail** rédigé d'après les traitements réellement mis en
> œuvre par la plateforme. Les **durées de conservation** ci-dessous sont des
> **propositions** conformes aux référentiels CNIL/Qualiopi : à **valider**
> (colonne « Durée »), puis la purge automatique sera câblée sur ces valeurs.
> Dernière révision : 2026-07-13.

## Rôles

- **Responsable de traitement** : MA FORMATION TRANSPORT.
- **Sous-traitants (art. 28)** : Supabase (hébergement BDD/Auth, UE), Vercel
  (hébergement applicatif), Stripe (paiement), Resend (emails transactionnels),
  PostHog/GA4 (mesure d'audience, si consentie). Chacun doit être couvert par
  un accord de sous-traitance (DPA).

## Traitements

| # | Traitement | Finalité | Base légale | Personnes | Données | Destinataires | Durée (proposée, à valider) |
|---|---|---|---|---|---|---|---|
| 1 | Comptes & authentification | Créer/gérer l'accès à la plateforme | Contrat | Stagiaires, formateurs, financeurs | Identité, email, mot de passe (haché), rôle | Interne, Supabase | Durée du compte + **3 ans** après dernière activité |
| 2 | Inscriptions & parcours | Suivre la formation (progression, quiz, examens, certificats) | Contrat | Stagiaires | Progression, réponses, notes, attestations | Interne, formateur | Durée de la formation + **3 ans** (preuve Qualiopi/financeur) |
| 3 | Facturation & paiement | Encaisser, comptabiliser | Obligation légale | Clients | Montants, historique paiement (pas de n° carte : Stripe) | Interne, Stripe, comptable | **10 ans** (pièces comptables, C. com. L123-22) |
| 4 | Financement CPF/OPCO/France Travail | Gérer la prise en charge | Contrat / obligation légale | Stagiaires, financeurs | Dossier de financement, émargements | Interne, financeur, CDC (EDOF) | **3 ans** min. après fin de formation (contrôle) |
| 5 | Prospects / CRM | Traiter les demandes, relancer | Intérêt légitime / consentement | Prospects | Coordonnées, échanges, source | Interne (équipe CRM) | **3 ans** après dernier contact (reco CNIL prospection) |
| 6 | Messagerie interne | Communication pédagogique | Contrat | Stagiaires, formateurs | Messages, pièces jointes | Interne | Durée du compte + **1 an** |
| 7 | Accessibilité / handicap | Adapter la formation (référent handicap) | Obligation légale / intérêt vital | Stagiaires concernés | Besoins déclarés, RQTH (déclaratif) | Interne (référent) | Durée de la formation + **1 an**, puis suppression |
| 8 | Preuve de consentement cookies | Prouver le recueil du consentement | Obligation légale (CNIL) | Visiteurs, stagiaires | ID visiteur, choix, IP, UA, horodatage, version | Interne | **13 mois** (validité) + **3 ans** de preuve |
| 9 | Journaux sécurité / audit | Sécurité, traçabilité des accès admin | Intérêt légitime | Utilisateurs, admins | Actions, cibles, IP | Interne | **6 à 12 mois** |
| 10 | Emails transactionnels | Notifier (inscription, paiement, relances) | Contrat | Stagiaires, prospects | Email, contenu, statut d'envoi | Interne, Resend | **1 an** |
| 11 | Newsletter / marketing | Communication commerciale (opt-in) | Consentement | Abonnés | Email, préférences | Interne | Jusqu'au retrait + **3 ans** d'inactivité |
| 12 | Mesure d'audience | Statistiques d'usage (si consentie) | Consentement | Visiteurs | Événements pseudonymisés | Interne, PostHog/GA4 | **13 mois** (cookies) / **25 mois** (stats) |

## Droits des personnes (art. 12-22)

- Accès, rectification, effacement, portabilité, opposition, limitation.
- Points d'entrée déjà en place : `export_my_data()` (portabilité),
  `anonymize_user()` (droit à l'effacement), demandes via l'espace
  accessibilité et le contact. Délai de réponse : **1 mois**.
- Réclamation possible auprès de la **CNIL**.

## Mesures de sécurité (art. 32)

- Chiffrement en transit (HTTPS) et au repos (Supabase).
- **RLS** activée sur toutes les tables ; helper `is_admin()`.
- Mots de passe hachés (Supabase Auth) ; MFA disponible pour les admins.
- Journaux d'accès et d'audit ; limitation de débit sur les endpoints
  sensibles ; `search_path` des fonctions épinglé.
- Sauvegardes gérées par Supabase (**à documenter** : fréquence, rétention,
  test de restauration).

## Points à finaliser

1. **Valider les durées** de la colonne « Durée » ci-dessus.
2. Nommer un **contact/DPO** et publier son adresse.
3. Signer/collecter les **DPA** des sous-traitants.
4. Documenter la **politique de sauvegarde/restauration**.
5. Une fois les durées validées : **purge automatique** (cron) par traitement.
