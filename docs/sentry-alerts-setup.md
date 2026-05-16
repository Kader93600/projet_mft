# Configuration des alertes Sentry — Mode strict (Email)

> 📅 Document de référence · 16 mai 2026
> 🎯 Objectif : être notifié par email des erreurs critiques de production sans noyade

---

## ✅ Pré-requis (côté code)

Tout est en place dans le repo :

- ✅ Package `@sentry/nextjs` installé
- ✅ `sentry.client.config.ts` + `sentry.server.config.ts` + `sentry.edge.config.ts`
- ✅ `instrumentation.ts` (App Router)
- ✅ `next.config.mjs` wrappé avec `withSentryConfig`
- ✅ `lib/observability.ts` utilise le SDK officiel
- ✅ `app/global-error.tsx` capture les erreurs root
- ✅ `app/error.tsx` capture les erreurs route
- ✅ Endpoint `/api/sentry-test` pour valider

---

## 🔑 1. Variables d'environnement Vercel

Les vars déjà présentes :
- `NEXT_PUBLIC_SENTRY_DSN` ✓
- `SENTRY_ORG` ✓
- `SENTRY_PROJECT` ✓
- `SENTRY_ENVIRONMENT` ✓

**À ajouter** :

| Variable | Valeur | Où l'obtenir |
|---|---|---|
| `SENTRY_AUTH_TOKEN` | Token avec scope `project:releases` | sentry.io → Settings → Account → API → Auth Tokens → Create new token |
| `SENTRY_DSN` | Identique à `NEXT_PUBLIC_SENTRY_DSN` | Copier la même valeur (le SDK serveur ne lit pas la var `NEXT_PUBLIC_*`) |

`SENTRY_AUTH_TOKEN` doit être configuré côté **Production + Preview** uniquement (pas Development) pour que les source maps soient uploadées à chaque build Vercel.

---

## 🚀 2. Push du code

```bash
git add .
git commit -m "feat(sentry): wiring complet + endpoint test + helpers observability"
git push origin main
```

Le build Vercel va :
1. Compiler avec source maps
2. Les uploader automatiquement à Sentry (grâce au `SENTRY_AUTH_TOKEN`)
3. Les supprimer du bundle public (option `hideSourceMaps: true`)

---

## 🧪 3. Test du wiring (après déploiement)

Connectez-vous en admin sur la prod, puis allez sur :

```
https://maformationtransport.fr/api/sentry-test
```

Trois sous-tests disponibles :

| URL | Effet | Doit-il déclencher une alerte ? |
|---|---|---|
| `/api/sentry-test` (défaut) | `throw new Error()` server | ✅ **Oui** (level=error) |
| `/api/sentry-test?kind=warning` | `captureMessage(level=warning)` | ⚠️ Selon votre règle |
| `/api/sentry-test?kind=message` | `captureMessage(level=info)` | ❌ Non (info) |

Vérifiez ensuite sur [sentry.io](https://sentry.io) → Projet `javascript-nextjs` → Issues. Vous devez voir une nouvelle issue dans les 30 secondes.

---

## 🔔 4. Configuration des 3 règles d'alerte (mode strict)

Direction : **sentry.io → Projet `javascript-nextjs` → Alerts → Create Alert → Issue Alert**.

### Règle 1 — Nouvelle erreur en production

**But** : être notifié dès qu'une erreur jamais vue arrive en prod.

```
Name        : 🚨 Nouvelle erreur production
Environment : production
─────────────────────────────────────
WHEN (conditions)
  • A new issue is created

IF (filters — tous obligatoires)
  • The issue's level equals "error" OR "fatal"
  • The event's tag "environment" equals "production"

THEN (actions)
  • Send a notification to "Email"
    → Target : Me (votre adresse)
    → Subject : [MFT] Nouvelle erreur prod : {{ issue.title }}

Frequency  : Perform actions at most once every 5 minutes per issue
```

### Règle 2 — Pic d'erreurs (volume anormal)

**But** : détecter un problème massif (typiquement après un déploiement raté).

```
Name        : 🔥 Pic d'erreurs détecté
Environment : production
─────────────────────────────────────
WHEN
  • The issue is seen more than 20 times in 5 minutes

IF
  • The event's tag "environment" equals "production"

THEN
  • Send a notification to "Email"
    → Subject : [MFT] PIC : {{ issue.title }} ({{ event.count }} en 5 min)

Frequency  : Perform actions at most once every 30 minutes per issue
```

### Règle 3 — Routes critiques (paiement, cron, webhook)

**But** : tout dysfonctionnement sur les routes business-critical déclenche une alerte immédiate.

```
Name        : 💰 Erreur route critique
Environment : production
─────────────────────────────────────
WHEN
  • A new issue is created

IF
  • The event's request URL contains
    "/api/checkout" OR "/api/stripe/webhook" OR "/api/cron"

THEN
  • Send a notification to "Email"
    → Subject : [MFT · CRITIQUE] Route bloquée : {{ issue.title }}

Frequency  : No throttling (toutes les occurrences)
```

---

## 📊 5. Digest hebdomadaire (background)

Ces alertes immédiates sont complétées par un **digest hebdomadaire** envoyé chaque lundi matin avec le top 10 des erreurs de la semaine.

**Configuration** :
1. sentry.io → Settings → Account → Notifications
2. Section **Weekly Reports** → activer pour le projet `javascript-nextjs`
3. Section **Issue Alerts** → garder uniquement les emails marqués `[MFT]` au-dessus

---

## 🎯 6. Acceptance criteria

Une fois tout configuré, vous devez :

- [ ] Recevoir un email **« [MFT] Nouvelle erreur prod »** après avoir appelé `/api/sentry-test`
- [ ] Voir dans Sentry > Issues l'erreur de test avec le bon **tag user_role=admin** + email
- [ ] Voir dans Sentry > Discover les events avec les tags `formation_slug`, `route`, etc.
- [ ] Recevoir le digest hebdomadaire le lundi matin suivant
- [ ] Si vous appelez `/api/checkout/session?test=fail` (à créer plus tard), recevoir une alerte **[MFT · CRITIQUE]**

---

## 🆘 Troubleshooting

| Symptôme | Cause probable | Fix |
|---|---|---|
| Le test ne génère aucune issue Sentry | `NEXT_PUBLIC_SENTRY_DSN` manquant en prod | Vérifier Vercel → Settings → Environment Variables |
| L'issue arrive mais sans source map (code minifié) | `SENTRY_AUTH_TOKEN` manquant | Ajouter le token + redéployer |
| Aucun email reçu | Règle d'alerte mal configurée OU email dans spam | Tester d'abord avec **« Send Test Notification »** dans la règle |
| Trop d'emails | Frequency trop basse | Augmenter le throttling à 30 min ou 1 h |
| Le tag `user_role` n'apparaît pas | `setSentryUser()` non appelé | À ajouter dans le layout authentifié (todo P2 #2) |

---

## 📌 Prochaines étapes (P2 #1)

- ✅ **Sentry alertes Email** ← ce document
- ⏳ Brancher PostHog
- ⏳ Dashboard admin temps réel
