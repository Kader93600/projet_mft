// =====================================================================
// scripts/gen-migrations-index.mjs
// Génère supabase/MIGRATIONS_INDEX.md : inventaire de toutes les
// migrations .sql avec leur 1ère ligne de description (commentaire),
// trié (migrations horodatées d'abord, puis fichiers thématiques).
// Usage : node scripts/gen-migrations-index.mjs
// =====================================================================
import { readFileSync, writeFileSync, readdirSync } from "node:fs";

const dir = new URL("../supabase/", import.meta.url);
const files = readdirSync(dir)
  .filter((f) => f.endsWith(".sql") && f !== "schema.sql")
  .sort();

function firstDesc(path) {
  const txt = readFileSync(path, "utf8").split("\n");
  for (const raw of txt) {
    const l = raw.trim();
    if (!l) continue;
    if (/^--+\s*=+\s*$/.test(l)) continue; // ligne de séparation ===
    const m = l.match(/^--+\s*(.+)$/);
    if (m && m[1] && !/^=+$/.test(m[1].trim())) {
      return m[1].trim().replace(/\s*=+\s*$/, "");
    }
    if (!l.startsWith("--")) break; // premier vrai SQL → pas de desc
  }
  return "(pas de description)";
}

const dated = [];
const thematic = [];
for (const f of files) {
  const desc = firstDesc(new URL(f, dir));
  (/^\d{4}_\d{2}_\d{2}/.test(f) ? dated : thematic).push({ f, desc });
}

const now = new Date().toISOString().slice(0, 10);
let md = `# Index des migrations Supabase

> Généré le ${now} par \`scripts/gen-migrations-index.mjs\`.
> La structure des **tables** fait foi dans \`supabase/schema.sql\` (baseline introspecté).
> Ce fichier documente l'historique : **${files.length} migrations** (vues, fonctions, RLS, triggers, données).

## ⚠️ Provisioning d'une base neuve
1. Jouer les migrations horodatées dans l'ordre chronologique ci-dessous.
2. Puis les fichiers thématiques (seed contenu, formations, etc.).
3. \`schema.sql\` sert de **référence de lecture** du modèle de données, pas de script de création unique.

---

## Migrations horodatées (${dated.length})

| Fichier | Description |
|---|---|
`;
for (const { f, desc } of dated) {
  md += `| \`${f}\` | ${desc.replace(/\|/g, "\\|").slice(0, 110)} |\n`;
}

md += `\n## Fichiers thématiques / contenu (${thematic.length})\n\n| Fichier | Description |\n|---|---|\n`;
for (const { f, desc } of thematic) {
  md += `| \`${f}\` | ${desc.replace(/\|/g, "\\|").slice(0, 110)} |\n`;
}

writeFileSync(new URL("../supabase/MIGRATIONS_INDEX.md", import.meta.url), md);
console.log(`✅ MIGRATIONS_INDEX.md : ${dated.length} horodatées + ${thematic.length} thématiques = ${files.length}`);
