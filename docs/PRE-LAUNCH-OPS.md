# Checklist ops pré-déploiement

À faire **avant** d'ouvrir les inscriptions.

---

## 1. Domaine et SSL

### 1.1 Achat / DNS

- [ ] Domaine acheté (`<votre-domaine>.fr` ou équivalent) chez OVH / Gandi / Cloudflare.
- [ ] Configurer un alias `www.` qui redirige vers la racine.
- [ ] DNS pointé sur Vercel :
  - `A` (apex) → `76.76.21.21`
  - `CNAME www` → `cname.vercel-dns.com`
- [ ] Sur Vercel → Project → Settings → Domains : ajouter `<votre-domaine>.fr` ET `www.<votre-domaine>.fr`.

### 1.2 SSL / HTTPS

- [ ] Certificat Let's Encrypt généré automatiquement par Vercel (vérifier le badge vert).
- [ ] Forcer HTTPS (Vercel le fait par défaut).
- [ ] Tester `http://<votre-domaine>.fr` → doit rediriger en `https://`.
- [ ] HSTS actif (déjà dans `next.config.mjs` : `Strict-Transport-Security` 2 ans + preload).
- [ ] Optionnel : soumettre le domaine à https://hstspreload.org après 1 mois de stabilité.

### 1.3 Vérification headers

Tester en prod après déploiement :

```bash
curl -sI https://<votre-domaine>.fr | grep -iE 'content-security-policy|strict-transport|x-frame|referrer-policy|permissions-policy'
```

Tous les headers doivent apparaître.

Tester aussi sur https://securityheaders.com — score visé : **A** ou **A+**.

---

## 2. Backups Supabase

### 2.1 Activation

- [ ] Project Settings → Database → Backups : confirmer que les backups quotidiens automatiques sont activés (inclus dans Pro tier ; en Free, à vérifier).
- [ ] Durée de rétention : 7 jours (Pro) ou 30 jours (Team+).

### 2.2 Test de restauration

**À faire au moins une fois avant d'ouvrir aux stagiaires.**

1. Créer un projet Supabase de staging.
2. Restaurer un backup via Project Settings → Database → Backups → Restore.
3. Vérifier que les tables critiques (`profiles`, `enrollments`, `lesson_progress`) sont bien là.
4. Documenter le temps de restauration (typiquement 15-30 min).

### 2.3 Export hebdomadaire externe (recommandé)

Pour ne pas dépendre uniquement de Supabase, mettre en place un export hebdomadaire vers un S3 tiers (OVH Object Storage, Scaleway, Backblaze) :

```bash
# .github/workflows/db-backup.yml (à créer)
# - Cron weekly
# - pg_dump $SUPABASE_DB_URL > backup-$(date).sql.gz
# - Upload vers S3 avec rotation 12 semaines
```

Coût : ~5 €/mois.

### 2.4 Procédure de restauration documentée

Documenter dans le wiki interne :

1. Qui a accès (compte Supabase admin) ?
2. Étapes pour restaurer.
3. Communication aux utilisateurs en cas d'incident (template d'email).
4. RTO (Recovery Time Objective) cible : < 4 h.
5. RPO (Recovery Point Objective) cible : < 24 h.

---

## 3. Email transactionnel

### 3.1 Compte Resend

- [ ] Créer un compte sur https://resend.com (gratuit jusqu'à 3 000 emails/mois).
- [ ] Vérifier le domaine `<votre-domaine>.fr` (ajouter les enregistrements DNS demandés).
- [ ] Récupérer la clé API → `RESEND_API_KEY`.

### 3.2 SPF / DKIM / DMARC

Resend gère DKIM automatiquement après vérification du domaine. Vérifier :

- [ ] **SPF** : `v=spf1 include:_spf.resend.com -all` (ou `~all` pour transition).
- [ ] **DKIM** : 3 enregistrements CNAME ajoutés (vérifiés par Resend).
- [ ] **DMARC** : `v=DMARC1; p=quarantine; rua=mailto:dpo@<votre-domaine>.fr` (commencer en `p=none` pour observer 30 jours).

### 3.3 Test de délivrabilité

- [ ] Envoyer un email test depuis l'app vers https://www.mail-tester.com → score visé **9/10 ou plus**.
- [ ] Tester sur Gmail, Outlook, Apple Mail (rendu HTML + arrivée en boîte de réception, pas spam).

### 3.4 Webhook bounces (optionnel)

Configurer un webhook Resend → endpoint Next.js pour traiter les bounces durs (désinscrire automatiquement les emails invalides).

---

## 4. Sentry

### 4.1 Compte et projet

- [ ] Créer un compte https://sentry.io (gratuit jusqu'à 5k événements/mois).
- [ ] Créer un projet "Next.js" → récupérer le DSN → `NEXT_PUBLIC_SENTRY_DSN`.

### 4.2 Installation officielle (recommandé en prod)

Pour bénéficier de breadcrumbs, performance monitoring, sourcemaps :

```bash
npm install @sentry/nextjs
npx @sentry/wizard@latest -i nextjs
```

Le wizard crée :
- `sentry.client.config.ts`
- `sentry.server.config.ts`
- `sentry.edge.config.ts`
- ajoute des tunnels CSP

Notre `lib/observability.ts` continue de fonctionner en parallèle (utilisé dans les error boundaries) — il appelle automatiquement `window.Sentry` si présent, sinon il poste directement à l'API.

### 4.3 Variables Vercel

- `NEXT_PUBLIC_SENTRY_DSN`
- `SENTRY_ORG`
- `SENTRY_PROJECT`
- `SENTRY_AUTH_TOKEN` (uniquement pour upload des sourcemaps en build)
- `SENTRY_ENVIRONMENT=production`

### 4.4 Alertes

Configurer dans Sentry → Alerts :

- [ ] Issue alert : nouvelle erreur unique → email Slack.
- [ ] Issue alert : taux d'erreur > 1 % sur 5 min → email + SMS.
- [ ] Performance alert : LCP P95 > 4 s sur 1 h → email.

---

## 5. Rate limiting

### 5.1 Mode actuel

`lib/rate-limit.ts` fonctionne en **mémoire** par défaut. Suffisant en dev et pour 1 instance.

### 5.2 Mode prod (multi-instance Vercel)

- [ ] Créer un compte gratuit https://upstash.com (10k commandes/jour offertes).
- [ ] Créer une base **Redis** en région UE.
- [ ] Variables Vercel :
  - `UPSTASH_REDIS_REST_URL`
  - `UPSTASH_REDIS_REST_TOKEN`

Dès que ces variables existent, `rate-limit.ts` bascule automatiquement.

### 5.3 Endpoints couverts aujourd'hui

| Route                 | Limite              | Fenêtre |
| --------------------- | ------------------- | ------- |
| `/api/search`         | 60 req / IP         | 60 s    |
| `/api/me/consent`     | 30 req / IP         | 60 s    |

À étendre quand des routes supplémentaires apparaissent (paiement, export RGPD, etc.).

### 5.4 Login Supabase

L'authentification se fait côté client via `supabase.auth.signInWithPassword()`. Supabase a son propre rate limit (Authentication → Rate Limits dans le dashboard). Vérifier :

- [ ] **Sign in with password** : 30 / heure / IP (par défaut, augmentable).
- [ ] **Sign up** : 30 / heure / IP.
- [ ] **Token refresh** : 1800 / heure.

Pour ajouter une couche supplémentaire, encapsuler le login dans une server action / route API qui appelle `rateLimit()` avant `signInWithPassword`.

---

## 6. Variables d'environnement

### 6.1 Checklist Vercel

Pour chaque environnement (Production / Preview / Development), aller dans Vercel → Project → Settings → Environment Variables :

- [ ] `NEXT_PUBLIC_SUPABASE_URL`
- [ ] `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- [ ] `SUPABASE_SERVICE_ROLE_KEY` (sensible — ne jamais exposer côté client)
- [ ] `NEXT_PUBLIC_APP_URL`
- [ ] `RESEND_API_KEY`
- [ ] `EMAIL_FROM_ADDRESS`
- [ ] `EMAIL_REPLY_TO`
- [ ] `NEXT_PUBLIC_SENTRY_DSN`
- [ ] `SENTRY_ORG`, `SENTRY_PROJECT`, `SENTRY_AUTH_TOKEN`, `SENTRY_ENVIRONMENT`
- [ ] (optionnel) `UPSTASH_REDIS_REST_URL`, `UPSTASH_REDIS_REST_TOKEN`

### 6.2 Audit du repo

```bash
# Vérifier qu'aucun secret n'est commit
git log --all --full-history --source -p -- '.env.local' '.env.production'

# Doit être vide. Sinon : régénérer immédiatement les secrets concernés.
```

- [ ] `.env.local`, `.env.production.local` listés dans `.gitignore`.
- [ ] `.env.example` à jour (présent à la racine du repo).

---

## 7. Tests d'acceptation pré-mise en ligne

Manuels (à automatiser plus tard en E2E) :

- [ ] `https://<votre-domaine>.fr` → landing publique s'affiche, footer légal visible.
- [ ] Visiter `/route-inexistante` → page 404 stylée s'affiche.
- [ ] Provoquer une erreur runtime (`throw new Error("test")` dans une page) → page `error.tsx` + Sentry reçoit l'event.
- [ ] Couper le réseau pendant un fetch → `loading.tsx` puis erreur gracieuse.
- [ ] Tester depuis un mobile : Lighthouse mobile > 85.
- [ ] Tester en mode `prefers-reduced-motion: reduce` → aucune animation.
- [ ] Demander 100 fois `/api/search` en 1 minute → 429 attendu.
- [ ] S'inscrire via `/inscription` → email reçu en boîte de réception (pas spam).
- [ ] Lighthouse Best Practices ≥ 95 (vérifie HTTPS, headers, etc.).
- [ ] https://securityheaders.com → grade A ou A+.

---

## 8. Communication d'incident

Préparer **avant** de lancer un template d'email pour les incidents majeurs :

```
Sujet : Incident technique en cours — {service}

Bonjour,

Nous rencontrons actuellement un incident technique sur {service}.
Notre équipe est mobilisée pour rétablir le service au plus vite.

Impact : {impact-utilisateur}
Démarrage : {heure-début}
Statut : en cours d'investigation

Mises à jour : {url-status-page} (si applicable)

Merci pour votre patience,
L'équipe MA FORMATION TRANSPORT
```

Si volume > 100 stagiaires actifs : envisager une page de statut publique (Statuspage.io, BetterStack, ou Vercel Status Page).
