// =====================================================================
// scripts/introspect-schema.mjs
//
// Génère, à partir du schéma PUBLIC réellement déployé sur Supabase
// (introspection via la spec OpenAPI servie par PostgREST) :
//
//   1. supabase/schema.sql        — baseline consolidé (source de vérité
//                                    des TABLES : colonnes, types, NOT NULL,
//                                    défauts, clés primaires, clés étrangères)
//   2. lib/database.types.ts      — types TypeScript (Database) pour typer
//                                    le client Supabase
//
// Pourquoi l'introspection plutôt que `supabase db dump` ?
//   La CLI Supabase / pg_dump nécessitent le mot de passe Postgres direct.
//   PostgREST expose en revanche une spec OpenAPI complète des tables du
//   schéma `public` (types, nullabilité, PK, FK) accessible avec la clé
//   service_role. C'est suffisant pour reconstruire une baseline fidèle.
//
// Limites assumées (documentées dans l'en-tête du schema.sql généré) :
//   - Les VUES et FONCTIONS ne sont pas reconstructibles depuis OpenAPI
//     (pas de corps SQL exposé) → voir l'index des migrations.
//   - Les CHECK constraints / triggers / index ne sont pas exposés.
//
// Usage : node scripts/introspect-schema.mjs
// =====================================================================

import { readFileSync, writeFileSync } from "node:fs";

// Identifiants réservés à quoter dans le SQL généré
const RESERVED = new Set([
  "order", "user", "group", "default", "primary", "references",
  "check", "limit", "offset", "end", "type",
]);
function ident(n) {
  return /^[a-z_][a-z0-9_]*$/.test(n) && !RESERVED.has(n) ? n : `"${n}"`;
}
function tsKey(n) {
  return /^[A-Za-z_$][A-Za-z0-9_$]*$/.test(n) ? n : `"${n}"`;
}

const env = Object.fromEntries(
  readFileSync(new URL("../.env.local", import.meta.url), "utf8")
    .split("\n")
    .filter((l) => l.includes("="))
    .map((l) => {
      const i = l.indexOf("=");
      return [l.slice(0, i).trim(), l.slice(i + 1).trim().replace(/^["']|["']$/g, "")];
    }),
);

const URL_BASE = env.NEXT_PUBLIC_SUPABASE_URL;
const KEY = env.SUPABASE_SERVICE_ROLE_KEY;
if (!URL_BASE || !KEY) {
  console.error("Manque NEXT_PUBLIC_SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY");
  process.exit(1);
}

const res = await fetch(URL_BASE + "/rest/v1/", {
  headers: { apikey: KEY, Authorization: "Bearer " + KEY },
});
if (!res.ok) {
  console.error("Introspection HTTP", res.status);
  process.exit(1);
}
const spec = await res.json();
const defs = spec.definitions || {};
const paths = spec.paths || {};

// Une relation est une TABLE (vs une VUE) si son path expose POST (insert).
const isWritable = (name) => {
  const p = paths["/" + name];
  return !!(p && (p.post || p.patch || p.delete));
};
// Détection robuste des vues : soit PostgREST ne l'expose pas en écriture,
// soit elle suit la convention de nommage projet (vw_* / *_overview).
// (PostgREST classe parfois à tort une vue d'agrégat comme "updatable".)
const isViewRel = (name) =>
  !isWritable(name) || /^vw_/.test(name) || /_overview$/.test(name);

// Formate un défaut SQL : quote les littéraux texte/enum, laisse les
// expressions (now(), uuid_generate_v4(), nextval...), booléens et
// nombres tels quels.
function formatDefault(d) {
  if (d == null) return null;
  const s = String(d).trim();
  if (s === "") return "''";
  // déjà quoté ou cast explicite
  if (/^'.*'(::[a-z_ \[\]]+)?$/i.test(s)) return s;
  // expression / fonction / nombre / bool / null
  if (
    s.includes("(") ||
    /^[0-9.+-]+$/.test(s) ||
    /^(true|false|null)$/i.test(s) ||
    /^current_/i.test(s) ||
    /nextval/i.test(s)
  ) {
    return s;
  }
  // littéral texte/enum (ex: nouveau, student) ou tableau vide {}
  return `'${s.replace(/'/g, "''")}'`;
}

// ── Parsing d'une colonne ────────────────────────────────────────────
function parseColumn(name, def) {
  const desc = def.description || "";
  const isPk = /<pk\/>/.test(desc);
  const fkMatch = desc.match(/<fk table='([^']+)' column='([^']+)'\/>/);
  const fk = fkMatch ? { table: fkMatch[1], column: fkMatch[2] } : null;
  // Type SQL : on privilégie `format` (= type Postgres réel dans PostgREST).
  let sqlType = def.format || def.type || "text";
  if (def.type === "array") {
    // PostgREST donne parfois le `format` Postgres (text, integer…),
    // parfois seulement le `type` JSON-schema (string, integer, number,
    // boolean) qu'il faut mapper vers un type SQL.
    const jsonToSql = {
      string: "text",
      integer: "integer",
      number: "numeric",
      boolean: "boolean",
    };
    const itemFmt =
      def.items?.format || jsonToSql[def.items?.type] || def.items?.type || "text";
    sqlType = itemFmt + "[]";
  }
  return {
    name,
    sqlType,
    tsType: sqlToTs(def),
    default: def.default ?? null,
    isPk,
    fk,
  };
}

// ── Mapping type SQL → TypeScript ────────────────────────────────────
function sqlToTs(def) {
  if (def.type === "array") {
    const itemTs = sqlToTs({ format: def.items?.format, type: def.items?.type });
    return itemTs + "[]";
  }
  const f = (def.format || def.type || "").toLowerCase();
  if (/(int|serial|numeric|decimal|double|real|float|money)/.test(f)) return "number";
  if (/bool/.test(f)) return "boolean";
  if (/json/.test(f)) return "Json";
  // uuid, text, varchar, char, timestamp, date, time, bytea, enum, etc.
  return "string";
}

// ── Construction des tables ──────────────────────────────────────────
const allNames = Object.keys(defs).sort();
const tables = [];
const views = [];
for (const name of allNames) {
  const def = defs[name];
  const props = def.properties || {};
  const required = new Set(def.required || []);
  const cols = Object.entries(props).map(([cn, cd]) => {
    const c = parseColumn(cn, cd);
    c.notNull = required.has(cn);
    return c;
  });
  const entry = { name, cols };
  if (isViewRel(name)) views.push(entry);
  else tables.push(entry);
}

// ── Génération schema.sql ────────────────────────────────────────────
const now = new Date().toISOString().slice(0, 10);
let sql = `-- =====================================================================
-- supabase/schema.sql — BASELINE CONSOLIDÉ (source de vérité des tables)
-- Généré le ${now} par scripts/introspect-schema.mjs
-- via introspection du schéma public déployé (PostgREST OpenAPI).
--
-- ⚠️  Régénérer avec :  node scripts/introspect-schema.mjs
--
-- CE FICHIER FAIT FOI pour la structure des TABLES (colonnes, types,
-- NOT NULL, défauts, PK, FK). Il remplace l'ancien schema.sql partiel.
--
-- Limites (non reconstructibles depuis l'introspection REST) :
--   • VUES : ${views.length} vues listées en fin de fichier (corps SQL non exposé).
--   • FONCTIONS / TRIGGERS / RLS / INDEX / CHECK : voir les migrations
--     horodatées dans supabase/*.sql (index : supabase/MIGRATIONS_INDEX.md).
--
-- Tables : ${tables.length}
-- =====================================================================

create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

`;

for (const t of tables) {
  sql += `-- ─────────────────────────────────────────────────────────────────────\n`;
  sql += `create table if not exists public.${t.name} (\n`;
  const lines = [];
  const pks = t.cols.filter((c) => c.isPk).map((c) => c.name);
  for (const c of t.cols) {
    let line = `  ${ident(c.name)} ${c.sqlType}`;
    const def = formatDefault(c.default);
    if (def != null) line += ` default ${def}`;
    if (c.notNull && !c.isPk) line += ` not null`;
    const fkNote = c.fk ? `  -- FK → ${c.fk.table}.${c.fk.column}` : "";
    lines.push(line + "," + fkNote);
  }
  if (pks.length) {
    lines.push(`  primary key (${pks.map(ident).join(", ")})`);
  } else {
    // retire la virgule finale de la dernière colonne
    lines[lines.length - 1] = lines[lines.length - 1].replace(/,(\s*--.*)?$/, "$1");
  }
  sql += lines.join("\n") + "\n);\n\n";
}

// Liste des vues (référence)
sql += `-- =====================================================================\n`;
sql += `-- VUES (${views.length}) — corps SQL dans les migrations, voir MIGRATIONS_INDEX.md\n`;
sql += `-- =====================================================================\n`;
for (const v of views) {
  sql += `--   • ${v.name} (${v.cols.length} colonnes)\n`;
}

writeFileSync(new URL("../supabase/schema.sql", import.meta.url), sql);

// ── Génération lib/database.types.ts ─────────────────────────────────
let ts = `// =====================================================================
// lib/database.types.ts — Types du schéma public Supabase
// Généré le ${now} par scripts/introspect-schema.mjs (introspection live).
// NE PAS éditer à la main — régénérer avec : node scripts/introspect-schema.mjs
// =====================================================================

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export interface Database {
  public: {
    Tables: {
`;

for (const t of tables) {
  ts += `      ${tsKey(t.name)}: {\n`;
  ts += `        Row: {\n`;
  for (const c of t.cols) {
    const nul = c.notNull ? "" : " | null";
    ts += `          ${tsKey(c.name)}: ${c.tsType}${nul};\n`;
  }
  ts += `        };\n`;
  // Insert : colonnes avec défaut ou nullable → optionnelles
  ts += `        Insert: {\n`;
  for (const c of t.cols) {
    const optional = !c.notNull || c.default != null || c.isPk;
    const nul = c.notNull ? "" : " | null";
    ts += `          ${tsKey(c.name)}${optional ? "?" : ""}: ${c.tsType}${nul};\n`;
  }
  ts += `        };\n`;
  ts += `        Update: {\n`;
  for (const c of t.cols) {
    const nul = c.notNull ? "" : " | null";
    ts += `          ${tsKey(c.name)}?: ${c.tsType}${nul};\n`;
  }
  ts += `        };\n`;
  // Relationships : générées depuis les FK (annotation <fk> de l'OpenAPI).
  // Permettent l'inférence des `select` avec embeds (ex. modules(...)).
  const rels = t.cols.filter((c) => c.fk);
  if (rels.length === 0) {
    ts += `        Relationships: [];\n`;
  } else {
    ts += `        Relationships: [\n`;
    for (const c of rels) {
      ts += `          {\n`;
      ts += `            foreignKeyName: "${t.name}_${c.name}_fkey";\n`;
      ts += `            columns: ["${c.name}"];\n`;
      ts += `            isOneToOne: false;\n`;
      ts += `            referencedRelation: "${c.fk.table}";\n`;
      ts += `            referencedColumns: ["${c.fk.column}"];\n`;
      ts += `          },\n`;
    }
    ts += `        ];\n`;
  }
  ts += `      };\n`;
}

ts += `    };\n`;
ts += `    Views: {\n`;
for (const v of views) {
  ts += `      ${tsKey(v.name)}: {\n        Row: {\n`;
  for (const c of v.cols) {
    const nul = c.notNull ? "" : " | null";
    ts += `          ${tsKey(c.name)}: ${c.tsType}${nul};\n`;
  }
  ts += `        };\n      };\n`;
}
ts += `    };\n`;
ts += `    Functions: { [key: string]: unknown };\n`;
ts += `    Enums: { [key: string]: unknown };\n`;
ts += `  };\n}\n\n`;

// Helpers d'accès pratiques
ts += `// Helpers : Tables<"profiles">, etc.
type PublicSchema = Database["public"];
export type Tables<T extends keyof PublicSchema["Tables"]> =
  PublicSchema["Tables"][T]["Row"];
export type TablesInsert<T extends keyof PublicSchema["Tables"]> =
  PublicSchema["Tables"][T]["Insert"];
export type TablesUpdate<T extends keyof PublicSchema["Tables"]> =
  PublicSchema["Tables"][T]["Update"];
export type Views<T extends keyof PublicSchema["Views"]> =
  PublicSchema["Views"][T]["Row"];
`;

writeFileSync(new URL("../lib/database.types.ts", import.meta.url), ts);

console.log(`✅ schema.sql : ${tables.length} tables, ${views.length} vues`);
console.log(`✅ database.types.ts : types générés`);
