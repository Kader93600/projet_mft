# 🚛 MA FORMATION TRANSPORT

> Plateforme e-learning pour préparer le titre professionnel **Gestionnaire des Opérations de Transport Routier de Marchandises** (RNCP 40990).

![Stack](https://img.shields.io/badge/Next.js-14-black?logo=next.js)
![Stack](https://img.shields.io/badge/TypeScript-5-blue?logo=typescript)
![Stack](https://img.shields.io/badge/Supabase-Auth%20%2B%20Postgres-green?logo=supabase)
![Stack](https://img.shields.io/badge/Tailwind-3-06B6D4?logo=tailwindcss)

---

## ✨ Fonctionnalités

### Espace étudiant
- 🏠 **Dashboard** : progression globale, stats, derniers résultats
- 📚 **Modules** structurés par bloc RNCP (cours détaillé + fiche de synthèse)
- ✅ **Suivi de progression** par leçon (marquer terminé)
- 🧪 **Quiz interactifs** avec correction automatique et explications
- ⏱ **Simulations d'examen** chronométrées
- 📊 **Historique des résultats** avec score, seuil de réussite, durée

### Espace administrateur (rôle `admin`)
- 👥 Gestion des utilisateurs (rôle, niveau)
- 📦 Vue sur les modules, leçons et quiz
- 📈 Analytics globaux : tentatives, moyennes, taux de réussite

### Fonctionnalités transverses
- 🔐 Auth Supabase (email/password) + RLS PostgreSQL
- 📱 Responsive mobile-first (sidebar desktop, bottom nav mobile)
- 🎯 2 modes : **Entraînement** (correction immédiate) vs **Examen** (sans correction live)
- 🔄 Niveaux étudiants : débutant → intermédiaire → avancé → expert

---

## 🛠️ Stack technique

| Couche       | Techno                                   |
|--------------|------------------------------------------|
| Frontend     | Next.js 14 (App Router) + React 18       |
| Langage      | TypeScript strict                        |
| UI           | Tailwind CSS + Lucide icons              |
| Auth + DB    | Supabase (PostgreSQL + RLS + Auth)       |
| Validation   | Zod                                      |
| Déploiement  | Vercel (recommandé) / Node self-hosted   |

---

## 🚀 Démarrage rapide

### 1. Prérequis

- Node.js ≥ 18
- Un compte [Supabase](https://supabase.com) (plan gratuit OK)

### 2. Cloner et installer

```bash
git clone <ce-repo>
cd projet_gotrm
npm install
```

### 3. Créer le projet Supabase

1. Créez un projet sur [supabase.com](https://supabase.com/dashboard)
2. Dans **SQL Editor**, exécutez dans l'ordre :
   - `supabase/schema.sql` (tables, RLS, triggers)
   - `supabase/seed.sql` (blocs, modules, leçons, quiz)
3. Récupérez vos clés dans **Settings → API**

### 4. Variables d'environnement

Copiez `.env.example` en `.env.local` et remplissez :

```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 5. Lancer en développement

```bash
npm run dev
```

→ [http://localhost:3000](http://localhost:3000)

### 6. Créer le premier admin

Après inscription de votre compte via `/signup`, passez-le en admin via le dashboard Supabase :

```sql
update profiles set role = 'admin' where email = 'votre@email.fr';
```

Vous verrez alors apparaître le menu **Administration** dans la sidebar.

---

## 📐 Architecture

```
projet_gotrm/
├── app/                        # Next.js App Router
│   ├── page.tsx                # Landing publique
│   ├── login/ · signup/        # Auth
│   ├── dashboard/              # Tableau de bord étudiant
│   ├── modules/                # Liste + détail module + leçons
│   │   └── [slug]/[lessonSlug] # Page leçon (cours + fiche synthèse)
│   ├── quiz/                   # Liste quiz + runner (mode exam/entraînement)
│   ├── stats/                  # Historique personnel
│   └── admin/                  # Console (users, modules, quizzes, analytics)
│
├── components/
│   ├── ui/                     # Button, Card, Input, ProgressBar
│   ├── app-shell.tsx           # Layout authentifié (sidebar + nav mobile)
│   └── auth-layout.tsx         # Garde auth + rôle
│
├── lib/
│   ├── supabase/
│   │   ├── client.ts           # Client navigateur
│   │   └── server.ts           # Client serveur (cookies)
│   ├── markdown.ts             # Rendu markdown → HTML
│   └── utils.ts
│
├── middleware.ts               # Garde auth globale + redirect
│
└── supabase/
    ├── schema.sql              # Tables + RLS + triggers
    └── seed.sql                # Contenu initial (3 blocs RNCP, quiz, leçons)
```

---

## 🗄️ Modèle de données

```
profiles (auth.users)
  ├─ blocs (BC1, BC2, BC3)
  │    └─ modules
  │         ├─ lessons (content_md + summary_md)
  │         └─ quizzes (type: entrainement | examen)
  │              └─ questions
  │                   └─ choices
  │
  ├─ lesson_progress    (user × lesson)
  ├─ quiz_attempts      (score, %, passed, durée, réponses JSON)
  └─ notifications
```

**RLS activé** : chaque étudiant ne voit que ses propres résultats ; les admins voient tout ; le contenu pédagogique est lisible par tous les utilisateurs authentifiés.

---

## 📚 Référentiel RNCP 40990

Les 3 blocs de compétences officiels :

1. **BC1** — Concevoir, organiser et piloter des opérations de transport
2. **BC2** — Piloter les trafics sous-traités
3. **BC3** — Optimiser les moyens liés à l'activité transport

Chaque bloc contient **2 à 3 modules** seedés avec cours, fiches et quiz. Exemples inclus :
- Planification des tournées + règlement 561/2006 (temps de conduite)
- Lettre de voiture CMR et documents obligatoires
- Accès à la profession (règlement 1071/2009) et ADR
- Calcul du coût de revient kilométrique (CRKM)

---

## 🧭 Roadmap (idées d'extension)

- [ ] Éditeur WYSIWYG de leçons/quiz côté admin
- [ ] Export PDF des résultats / attestation
- [ ] Gamification : badges, streak, XP
- [ ] Notifications par email (rappels, relances)
- [ ] Mode hors-ligne (PWA)
- [ ] Ajout de blocs supplémentaires (autres titres pro)
- [ ] Intégration Stripe pour versions payantes
- [ ] IA : tuteur conversationnel qui répond sur le référentiel

---

## 🚢 Déploiement

### Vercel (recommandé)

1. Push sur GitHub
2. Importez sur [vercel.com/new](https://vercel.com/new)
3. Ajoutez les 3 variables d'env Supabase
4. Deploy

Le middleware Next.js et les Server Components fonctionnent nativement sur Vercel.

---

## 📝 Licence

MIT — libre d'utilisation pour la préparation au titre professionnel GOTRM.

---

**⚠️ Note pédagogique** : Cette plateforme est un outil de préparation. L'inscription à l'examen officiel GOTRM se fait via un centre agréé AFPA ou équivalent.
