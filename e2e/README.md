# Tests E2E Playwright

Tests bout-en-bout du flux QR (passage stagiaire → correction formateur →
validation) et de la messagerie formateur ↔ stagiaire.

## Setup initial (une fois)

```bash
npm run test:e2e:install   # installe Chromium + dépendances système
```

## Comptes et données pré-requis

### Setup automatique (recommandé)

1. Dans **Supabase Studio → Authentication → Users**, créer 2 comptes :
   - `stagiaire-e2e@test.local` (mdp solide)
   - `formateur-e2e@test.local` (mdp solide)
2. Dans **SQL Editor**, exécuter `supabase/e2e_seed.sql`. Le script :
   - configure les rôles, bypass onboarding, rattache le formateur,
     inscrit le stagiaire, crée un quiz mixte QCM+QR
   - affiche en sortie l'`E2E_QUIZ_ID` à reporter dans `.env.test`

## Variables d'environnement

Créer un fichier `.env.test` (non commité) à la racine :

```bash
E2E_BASE_URL=http://localhost:3000
E2E_STUDENT_EMAIL=stagiaire-e2e@example.com
E2E_STUDENT_PASSWORD=changeme
E2E_TRAINER_EMAIL=formateur-e2e@example.com
E2E_TRAINER_PASSWORD=changeme
E2E_QUIZ_ID=00000000-0000-0000-0000-000000000000
# Cloisonnement : module + quiz (examen global) d'une formation NON suivie
E2E_FORBIDDEN_MODULE_SLUG=planification-tournees
E2E_FORBIDDEN_QUIZ_ID=00000000-0000-0000-0000-000000000000
```

Puis exporter avant la commande :

```bash
set -a && source .env.test && set +a
```

## Lancement

```bash
npm run test:e2e          # mode CLI (headless)
npm run test:e2e:ui       # mode UI (debug interactif)
```

Le serveur Next.js est démarré automatiquement par Playwright (`webServer`
dans `playwright.config.ts`). Pour réutiliser un serveur déjà lancé sur
:3000, exporter `E2E_NO_SERVER=1`.

## Fichiers

- `qr-flow.spec.ts` — passage QCM+QR, correction, finalisation
- `messaging.spec.ts` — échange message stagiaire ↔ formateur
- `helpers/auth.ts` — helper `login()` partagé
- `helpers/env.ts` — récupération + validation des variables

## Idempotence & nettoyage

Les tests créent des **tentatives** et **messages** réels en BDD. Pour
repartir d'un état propre, vider entre deux runs :

```sql
-- attention : à ne lancer qu'en environnement de test
DELETE FROM quiz_attempts WHERE student_id IN (
  SELECT id FROM profiles WHERE email LIKE '%e2e%'
);
DELETE FROM messages WHERE body LIKE '[E2E %]%';
```

## Robustesse

Les sélecteurs visent les rôles ARIA et les libellés visibles plutôt que
des classes CSS, pour résister aux retouches de design. Si un test casse
après un changement d'UI, mettre à jour le sélecteur dans le helper
plutôt que dans chaque spec.
