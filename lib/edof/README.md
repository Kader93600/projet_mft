# Intégration EDOF (Mon Compte Formation / Caisse des Dépôts)

Fondations d'une **automatisation API complète**, construites *credential-agnostic* :
le code métier est prêt et testé, il ne manque que l'**adapter HTTP réel** —
à écrire dès que la CDC a délivré l'accès API au client.

> Dimensionnement : **volume moyen** (~50–300 dossiers/mois). D'où une synchro
> **cron incrémentale paginée idempotente**, sans infra de queue/streaming.

## Ce qui est déjà en place

| Brique | Fichier | État |
|---|---|---|
| Config + feature flag | `lib/edof/config.ts` | ✅ |
| Types du domaine | `lib/edof/types.ts` | ✅ |
| Machine à états + mapping MFT | `lib/edof/state-machine.ts` (+ tests) | ✅ |
| Interface client + fabrique | `lib/edof/client.ts` | ✅ (interface) |
| Tables de suivi + curseur | `supabase/2026_05_21_edof_dossiers.sql` | ✅ (à jouer) |
| Cron de synchro (squelette) | `app/api/cron/edof-sync/route.ts` | ✅ (gardé, inerte) |
| Page admin de readiness | `app/admin/edof/page.tsx` | ✅ |

Tant que les variables `EDOF_*` ne sont pas définies, **tout est inerte** :
`createEdofClient()` renvoie un client qui échoue proprement, et le cron se
contente de répondre `skipped: edof_not_configured`.

## Cycle de vie d'un dossier (à confirmer avec la CDC)

```
recu ──> accepte ──> entree_declaree ──> en_cours ──> service_fait ──> solde
  │         │              │                 │
  ├─> refuse                └──────────┬──────┘
  └─> annule  <───────────────────────┘  (annulation possible jusqu'à en_cours)
```

Mapping vers les statuts d'inscription MFT : voir `edofStatusToMft()`.

## Pour FINIR l'intégration (quand l'accès CDC arrive)

1. **Jouer la migration** `supabase/2026_05_21_edof_dossiers.sql`.
2. **Renseigner les variables** d'environnement :
   - `EDOF_API_BASE_URL`, `EDOF_CLIENT_ID`, `EDOF_CLIENT_SECRET`, `EDOF_OF_SIRET`
   - `FEATURE_EDOF=true`
3. **Implémenter `HttpEdofClient`** (`lib/edof/client.ts`) à partir des specs CDC :
   - auth OAuth2 `client_credentials` (token + cache),
   - `listDossiers` (pagination + filtre `since`),
   - `acceptDossier` / `refuseDossier` / `declareEntry` / `declareServiceFait`,
   - mapper le payload brut EDOF → `EdofDossier` (statuts → `EdofDossierStatus`).
4. **Planifier le cron** `/api/cron/edof-sync` (Vercel Cron, ex. toutes les 2 h)
   avec le header `Authorization: Bearer ${CRON_SECRET}`.
5. **Étape 2 (règles métier)** : réconciliation `cpf_edof_dossiers ↔ enrollments`
   (lier par e-mail/réf. dossier, et — sur validation — propager le statut via
   `edofStatusToMft`). Volontairement non automatique pour l'instant.

## Garde-fous de conception

- Le cron **ne modifie jamais** les inscriptions automatiquement (pull + upsert
  des dossiers seulement) → aucun risque de corruption avant validation des règles.
- Idempotence via `onConflict: edof_dossier_id`.
- RLS admin sur les tables de suivi ; le cron lit/écrit en `service_role`.
- L'interface `EdofClient` isole tout le reste du code de l'implémentation HTTP.
