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
  - Les **`Relationships`** sont désormais générées depuis les FK (137 relations) → l'inférence des embeds fonctionne pour l'usage **opt-in** avec des `select` littéraux.
  - **Câblage global** `createClient<Database>()` toujours non activé : mesuré à **~1085 erreurs**. La cause n'est PAS les Relationships (corrigées) mais le fait que beaucoup de `select` sont **concaténés** (`"a,b," + "c"`) — or l'inférence supabase-js exige des **chaînes littérales**. Activer le typage global nécessiterait de convertir ces `select` en littéraux + corriger les `.insert` (refactor lourd). Follow-up : `supabase gen types` (officiel) + passage progressif des `select` en littéraux, fichier par fichier.
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

### Conventions UI back-office (admin)
Pour rester cohérent d'une page admin à l'autre :
- **Titre de page** : `font-display text-3xl md:text-4xl font-semibold text-navy-950 tracking-tight`.
- **Titre de section/carte** : `font-display text-xl font-semibold` (via `CardTitle`).
- **Valeur de KPI (stat tile)** : `font-display text-2xl/3xl font-semibold` (jamais `font-bold` — réservé nulle part dans l'admin).
- **Labels/eyebrows** : `text-[10-11px] uppercase tracking-wider text-slate-500 font-semibold`.
- **Perf** : batcher les URL signées avec `storage.createSignedUrls` (jamais en boucle), paralléliser les lectures indépendantes (`Promise.all`).
- **Logs** : pas de `console.log` (debug) en prod ; utiliser `captureException`/`captureMessage` de `lib/observability.ts`.

## Quand étendre
- Nouveau bloc/module → éditer `supabase/seed.sql` ou créer UI admin
- Nouvelle route protégée → créer `app/<route>/layout.tsx` qui renvoie `<AuthLayout>`
