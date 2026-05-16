# PostHog — Configuration et events trackés

> 📅 Document de référence · 16 mai 2026
> 🎯 Tracking des events stagiaire pour mesurer le funnel pédagogique et le taux de complétion

---

## ✅ Pré-requis côté code

Tout est en place dans le repo :

- ✅ `posthog-js` (client) + `posthog-node` (server) installés
- ✅ `lib/analytics.ts` — wrapper unifié `trackEvent` + `trackServerEvent`
- ✅ `components/posthog-provider.tsx` — init client, identify user, pageview auto
- ✅ Branché dans `components/auth-layout.tsx` (provider entoure tout l'espace authentifié)
- ✅ CSP mise à jour pour autoriser `eu.i.posthog.com`
- ✅ Opt-out RGPD via `/mes-donnees`

---

## 🔑 Variables d'environnement à ajouter sur Vercel

| Variable | Valeur | Environnements |
|---|---|---|
| `NEXT_PUBLIC_POSTHOG_KEY` | Votre clé `phc_...` (Project API Key) | Production + Preview + Development |
| `NEXT_PUBLIC_POSTHOG_HOST` | `https://eu.i.posthog.com` | Production + Preview + Development |

⚠️ Les deux vars sont préfixées `NEXT_PUBLIC_*` car PostHog tourne côté navigateur — c'est attendu. La clé `phc_...` est publique par design (c'est l'équivalent d'une clé Google Analytics).

---

## 📊 Events trackés (niveau Standard)

### Côté client (navigateur)

| Event | Quand | Props |
|---|---|---|
| `quiz_started` | Au clic « Démarrer » dans le runner | `quiz_id`, `formation_slug`, `mode`, `is_mock_exam`, `total_questions` |
| `quiz_finished` | Après INSERT réussi (quiz d'entraînement) | `attempt_id`, `score`, `passed`, `duration_s`, `qcm_score` |
| `exam_finished` | Après INSERT réussi (examen blanc) | idem `quiz_finished` |
| `$pageview` | Sur chaque changement de route (auto) | `$current_url` (sanitized) |

### Côté serveur (server actions, webhooks)

| Event | Quand | Props |
|---|---|---|
| `payment_success` | Stripe webhook `checkout.session.completed` | `formation_slug`, `pack`, `amount_cents`, `currency` |
| `enrollment_created` | Après création d'enrollment via Stripe | `formation_slug`, `pack`, `funding_kind` |
| `session_signed` | Émargement stagiaire dans `/sessions` | `session_id`, `session_kind`, `method` |

### À ajouter dans une prochaine itération (niveau Complet)

- `lesson_viewed` (page leçon RSC)
- `lesson_completed` (clic "Marquer terminé")
- `module_completed` (atteinte 100 %)
- `signup_completed` (page /signup)
- `login_completed` (page /login)
- `payment_failed` (Stripe webhook)

---

## 🛡️ Conformité RGPD

| Mesure | Statut |
|---|---|
| Hébergement EU (Francfort) | ✅ |
| IP anonymisée | ✅ (option `ip: false` dans init) |
| Pas de session recording sans consentement | ✅ (`disable_session_recording: true`) |
| Respect du Do Not Track navigateur | ✅ (`respect_dnt: true`) |
| Toggle opt-out utilisateur | ✅ Dans `/mes-donnees` |
| Sanitization URL (token, password) | ✅ (`sanitize_properties`) |
| Pas de transfert hors UE | ✅ Cloud EU uniquement |

---

## 🚀 Workflow de déploiement

1. **Récupérer la clé API** sur eu.posthog.com → Settings → Project → Project API Key
2. **Ajouter les 2 vars sur Vercel** (Production + Preview + Development)
3. **Redéployer** (commit vide ou Vercel → Redeploy sans cache)
4. **Tester** :
   - Connectez-vous en stagiaire test
   - Démarrez un quiz
   - Allez sur **eu.posthog.com → Activity** → vous devez voir `quiz_started` apparaître sous 30 s

---

## 📈 Premier dashboard à créer

Une fois les premiers events captés, créez un dashboard PostHog avec 4 widgets :

### 1. Funnel d'engagement
```
signup_completed
  → login_completed (J+1)
  → lesson_viewed (J+1)
  → quiz_finished (J+7)
  → exam_finished (J+30)
```

### 2. Taux de complétion par formation
- Trends → `lesson_completed`
- Break down by `formation_slug`

### 3. Pic d'activité hebdomadaire
- Trends → tous les events
- Group by `Hour of week`

### 4. Stagiaires en risque (inactifs > 14j)
- Cohort → users without event in last 14 days
- Sub-cohort → enrollment_created within 30 days (pour cibler les nouveaux décrocheurs)

---

## 🆘 Troubleshooting

| Symptôme | Cause | Fix |
|---|---|---|
| Aucun event dans PostHog | Clé API absente | Vérifier `NEXT_PUBLIC_POSTHOG_KEY` sur Vercel |
| Events arrivent mais pas d'identification | User non loggé OU profile manquant | Vérifier que `identify()` est bien appelé dans PostHogProvider |
| 403 / blocked sur `eu.i.posthog.com` | CSP trop stricte | Déjà autorisé dans `next.config.mjs` |
| Ad-blocker bloque PostHog | Extension navigateur | Pas grave — c'est l'utilisateur qui choisit |
| Quota free tier dépassé (1 M events/mois) | Trop d'events / utilisateur | Réduire le niveau de tracking ou upgrader |

---

## 🔗 Prochaines étapes (P2 #1)

- ✅ Sentry alertes Email (tâche 1/3)
- ✅ **PostHog** ← ce document
- ⏳ Dashboard admin temps réel (tâche 3/3)
