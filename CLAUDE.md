# MA FORMATION TRANSPORT — Notes pour Claude

## Vue d'ensemble
Plateforme e-learning Next.js 14 + Supabase pour la préparation au titre pro GOTRM (RNCP 40990).

## Commandes
- `npm run dev` — dev server
- `npm run build` — build production
- `npm run lint` — ESLint

## Architecture clé
- **Auth & DB** : Supabase. **`supabase/schema.sql` = baseline consolidé** (90 tables, source de vérité du modèle de données, généré par introspection). Historique des 151 migrations dans **`supabase/MIGRATIONS_INDEX.md`**. Contenu/seed dans `supabase/seed.sql` + fichiers `capa_*.sql`.
- **Types DB** : `lib/database.types.ts` (type `Database`, helpers `Tables<"...">`, `Views<"...">`). Régénérer avec `node scripts/introspect-schema.mjs` après tout changement de schéma.
  - **Usage opt-in** (recommandé sur chemins critiques) : typer explicitement les lignes lues, ex. `const rows = (data ?? []) as Pick<Tables<"enrollments">, "user_id" | "status">[]`. Documente + vérifie les colonnes contre la DB réelle.
  - **Câblage global** `createClient<Database>()` non activé : l'introspection REST ne fournit pas les `Relationships`, donc les `select` avec embeds (`modules(...)`) ne s'infèrent pas (≈1100 erreurs). Follow-up : installer la CLI Supabase + `supabase gen types` (nécessite le mot de passe DB) pour des types complets, puis câbler globalement.
- **Middleware** (`middleware.ts`) : redirige non-auth vers `/login`, gate admin sur `/admin`
- **AuthLayout** (`components/auth-layout.tsx`) : utilisé par dashboard/modules/quiz/stats/admin
- **RLS** activé sur toutes les tables. Helper `public.is_admin()` côté Postgres

## Régénérer schéma & types (après modif DB)
```bash
node scripts/introspect-schema.mjs    # → supabase/schema.sql + lib/database.types.ts (introspection live)
node scripts/gen-migrations-index.mjs # → supabase/MIGRATIONS_INDEX.md
```
> Nécessite `.env.local` (URL + SERVICE_ROLE_KEY). Pas de pg_dump requis.

## Convention
- Server Components par défaut, `"use client"` seulement pour interactivité (forms, quiz runner, toggle)
- Supabase client : `lib/supabase/server.ts` (cookies) ou `lib/supabase/client.ts` (browser)
- UI dans `components/ui/` (Button, Card, Input, ProgressBar)
- Markdown pédagogique rendu via `lib/markdown.ts` (minimaliste, suffisant pour seed)

## Quand étendre
- Nouveau bloc/module → éditer `supabase/seed.sql` ou créer UI admin
- Nouvelle route protégée → créer `app/<route>/layout.tsx` qui renvoie `<AuthLayout>`
