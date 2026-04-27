// Stub temporaire — sera remplacé par la génération automatique :
//   export SUPABASE_PROJECT_ID=xxxxx
//   npm run gen:types
// Pour générer en local (avec supabase start) :
//   npm run gen:types:local
//
// Une fois généré, importer ainsi :
//   import type { Database } from "@/lib/database.types";
//   const supabase = createServerClient<Database>(...)
//
// Cela élimine les `any` sur les retours de .from(...).select(...).
export type Database = any;
