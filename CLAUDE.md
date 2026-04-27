# GOTRM Academy — Notes pour Claude

## Vue d'ensemble
Plateforme e-learning Next.js 14 + Supabase pour la préparation au titre pro GOTRM (RNCP 40990).

## Commandes
- `npm run dev` — dev server
- `npm run build` — build production
- `npm run lint` — ESLint

## Architecture clé
- **Auth & DB** : Supabase. Schéma dans `supabase/schema.sql`, contenu dans `supabase/seed.sql`
- **Middleware** (`middleware.ts`) : redirige non-auth vers `/login`, gate admin sur `/admin`
- **AuthLayout** (`components/auth-layout.tsx`) : utilisé par dashboard/modules/quiz/stats/admin
- **RLS** activé sur toutes les tables. Helper `public.is_admin()` côté Postgres

## Convention
- Server Components par défaut, `"use client"` seulement pour interactivité (forms, quiz runner, toggle)
- Supabase client : `lib/supabase/server.ts` (cookies) ou `lib/supabase/client.ts` (browser)
- UI dans `components/ui/` (Button, Card, Input, ProgressBar)
- Markdown pédagogique rendu via `lib/markdown.ts` (minimaliste, suffisant pour seed)

## Quand étendre
- Nouveau bloc/module → éditer `supabase/seed.sql` ou créer UI admin
- Nouvelle route protégée → créer `app/<route>/layout.tsx` qui renvoie `<AuthLayout>`
