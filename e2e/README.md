# Tests E2E Playwright

Tests bout-en-bout du flux QR (passage stagiaire → correction formateur →
validation) et de la messagerie formateur ↔ stagiaire.

## Setup initial (une fois)

```bash
npm run test:e2e:install   # installe Chromium + dépendances système
```

## Comptes et données pré-requis

Les tests **n'inscrivent pas** de comptes ni ne créent de quiz : ils
consomment des fixtures déjà présentes en BDD. Provisionner manuellement :

1. **Compte stagiaire** : un user role `student`, inscrit sur la formation
   du quiz de test (table `enrollments`).
2. **Compte formateur** : un user role `trainer`, rattaché à la même
   formation via `trainer_formations`.
3. **Quiz mixte** : un quiz contenant ≥ 1 QCM + ≥ 1 QR, lié à la formation
   ci-dessus. Récupérer son UUID.

## Variables d'environnement

Créer un fichier `.env.test` (non commité) à la racine :

```bash
E2E_BASE_URL=http://localhost:3000
E2E_STUDENT_EMAIL=stagiaire-e2e@example.com
E2E_STUDENT_PASSWORD=changeme
E2E_TRAINER_EMAIL=formateur-e2e@example.com
E2E_TRAINER_PASSWORD=changeme
E2E_QUIZ_ID=00000000-0000-0000-0000-000000000000
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
