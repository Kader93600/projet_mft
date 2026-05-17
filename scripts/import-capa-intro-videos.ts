// =====================================================================
// scripts/import-capa-intro-videos.ts
//
// Importe les vidéos d'introduction des 6 modules Capacité ≤ 3,5 t
// depuis un dossier local (par défaut ~/Downloads/Capa_Intros/).
//
// Pipeline :
//   1. Liste les MP4 dans le dossier source
//   2. Map chaque fichier au module Capa correspondant (par nom)
//   3. Upload vers bucket "module-intro-videos" sous "capa/module-X.mp4"
//   4. UPDATE modules SET intro_video_path / intro_video_label / duration_s
//
// Conventions de nommage acceptées dans le dossier source :
//   capa-a.mp4, capa-b.mp4, …, capa-f.mp4
//   module-a.mp4, module-b.mp4, …
//   a.mp4, b.mp4, …
//   ou tout fichier dont le nom contient "a", "b", ... avant l'extension
//
// Usage : npx tsx scripts/import-capa-intro-videos.ts
//
// Variables d'env (.env.local) :
//   NEXT_PUBLIC_SUPABASE_URL
//   SUPABASE_SERVICE_ROLE_KEY
// =====================================================================

import { createClient } from "@supabase/supabase-js";
import { readFileSync, readdirSync, statSync } from "node:fs";
import { resolve, join, basename, dirname, extname } from "node:path";
import { fileURLToPath } from "node:url";
import { config as loadEnv } from "dotenv";
import { homedir } from "node:os";

const __dirname = dirname(fileURLToPath(import.meta.url));
loadEnv({ path: resolve(__dirname, "..", ".env.local") });

// ---------- Configuration ----------
const SOURCE_DIR = process.env.CAPA_VIDEOS_DIR
  ?? resolve(homedir(), "Downloads", "Capa_Intros");
const BUCKET = "module-intro-videos";

// Mapping : lettre du module (a-f) → slug du module
const MODULE_SLUG_BY_LETTER: Record<string, string> = {
  a: "capa-droit-civil-commercial",
  b: "capa-entreprise-activite-commerciale",
  c: "capa-cadre-reglementaire-transport",
  d: "capa-activite-financiere",
  e: "capa-salaries-droit-social",
  f: "capa-securite",
};

const MODULE_LABEL_BY_LETTER: Record<string, string> = {
  a: "Découvrez le module A — Droit civil et commercial.",
  b: "Découvrez le module B — L'entreprise et son activité commerciale.",
  c: "Découvrez le module C — Cadre réglementaire du transport.",
  d: "Découvrez le module D — Activité financière de l'entreprise.",
  e: "Découvrez le module E — Salariés et droit social.",
  f: "Découvrez le module F — Sécurité (FIMO/FCO, ADR, véhicule).",
};

// ---------- Supabase ----------
const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!SUPABASE_URL || !SERVICE_KEY) {
  console.error("Manque NEXT_PUBLIC_SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY dans .env.local");
  process.exit(1);
}
const supabase = createClient(SUPABASE_URL, SERVICE_KEY, { auth: { persistSession: false } });

/**
 * Détecte la lettre du module (a-f) depuis le nom du fichier.
 * Accepte plusieurs conventions de nommage. Renvoie null si non détecté.
 */
function detectModuleLetter(filename: string): string | null {
  const base = basename(filename, extname(filename)).toLowerCase();
  // Patterns dans l'ordre de spécificité
  const patterns = [
    /capa[-_ ]?module[-_ ]?([a-f])\b/,   // capa-module-a, capa_module_a
    /capa[-_ ]?([a-f])\b/,                // capa-a, capa_a, capa a
    /module[-_ ]?([a-f])\b/,              // module-a, module_a
    /^([a-f])\b/,                         // a.mp4, b.mp4
    /[-_ ]([a-f])(?:[-_ .]|$)/,           // foo-a-bar, foo_a.mp4
  ];
  for (const pat of patterns) {
    const m = base.match(pat);
    if (m && MODULE_SLUG_BY_LETTER[m[1]]) return m[1];
  }
  return null;
}

/**
 * Tentative simple d'extraire la durée d'un MP4 sans dépendance externe.
 * Pour un MP4 standard, on cherche la box "mvhd" qui contient la durée.
 * En cas d'échec, on renvoie null (la durée reste informationnelle).
 */
function extractMp4DurationS(buf: Buffer): number | null {
  try {
    // Cherche la box "mvhd" (movie header) dans le MP4
    const mvhd = buf.indexOf(Buffer.from("mvhd"));
    if (mvhd < 0) return null;
    // Lecture après "mvhd" + 4 bytes version/flags
    // version 0 : timescale @offset+12, duration @offset+16 (32 bits)
    // version 1 : timescale @offset+20, duration @offset+24 (64 bits)
    const version = buf.readUInt8(mvhd + 4);
    if (version === 0) {
      const timescale = buf.readUInt32BE(mvhd + 16);
      const duration = buf.readUInt32BE(mvhd + 20);
      if (timescale > 0) return Math.round(duration / timescale);
    } else if (version === 1) {
      const timescale = buf.readUInt32BE(mvhd + 24);
      const high = buf.readUInt32BE(mvhd + 28);
      const low = buf.readUInt32BE(mvhd + 32);
      const duration = high * 0x100000000 + low;
      if (timescale > 0) return Math.round(duration / timescale);
    }
  } catch {
    // ignore
  }
  return null;
}

async function main() {
  console.log(`Dossier source : ${SOURCE_DIR}`);
  let files: string[] = [];
  try {
    files = readdirSync(SOURCE_DIR).filter((f) => /\.(mp4|m4v|webm|mov)$/i.test(f));
  } catch (e: any) {
    console.error(`Impossible de lire le dossier (${SOURCE_DIR}) : ${e?.message ?? e}`);
    console.error(`\n→ Crée le dossier et dépose-y tes MP4, ou définis CAPA_VIDEOS_DIR=<chemin>`);
    process.exit(1);
  }
  if (files.length === 0) {
    console.error(`Aucun fichier vidéo trouvé dans ${SOURCE_DIR}`);
    console.error("Formats acceptés : .mp4, .m4v, .webm, .mov");
    process.exit(1);
  }
  console.log(`${files.length} fichier(s) vidéo détecté(s) : ${files.join(", ")}`);

  // ───── Mapping fichier → lettre module ─────
  type Task = {
    file: string;
    letter: string;
    slug: string;
    label: string;
    storagePath: string;
    sizeBytes: number;
    durationS: number | null;
  };
  const tasks: Task[] = [];
  const unmapped: string[] = [];

  for (const f of files) {
    const letter = detectModuleLetter(f);
    if (!letter) {
      unmapped.push(f);
      continue;
    }
    const fullPath = join(SOURCE_DIR, f);
    const buf = readFileSync(fullPath);
    tasks.push({
      file: fullPath,
      letter,
      slug: MODULE_SLUG_BY_LETTER[letter],
      label: MODULE_LABEL_BY_LETTER[letter],
      storagePath: `capa/module-${letter}${extname(f).toLowerCase()}`,
      sizeBytes: buf.length,
      durationS: extractMp4DurationS(buf),
    });
  }

  if (unmapped.length > 0) {
    console.warn(`\n/!\\ ${unmapped.length} fichier(s) non mappé(s) (pas de lettre A-F détectée) :`);
    unmapped.forEach((f) => console.warn(`   - ${f}`));
    console.warn("   Renomme-les selon une convention reconnue (capa-a.mp4, module-a.mp4, a.mp4…)");
  }

  if (tasks.length === 0) {
    console.error("\nAucun fichier ne correspond à un module Capa. Abandon.");
    process.exit(1);
  }

  console.log("\nMapping détecté :");
  for (const t of tasks) {
    const sizeMb = (t.sizeBytes / (1024 * 1024)).toFixed(1);
    const dur = t.durationS ? `${Math.round(t.durationS / 60)} min` : "?";
    console.log(`  ${basename(t.file).padEnd(40)} → ${t.slug.padEnd(40)} (${sizeMb} MB, ${dur})`);
  }

  // ───── 1. Upload vers Storage ─────
  console.log("\n[1/2] Upload vers Storage...");
  let uploaded = 0;
  const uploadedTasks: Task[] = [];
  for (const t of tasks) {
    const buf = readFileSync(t.file);
    const ext = extname(t.file).toLowerCase().slice(1);
    const mimeType =
      ext === "webm" ? "video/webm" : ext === "mov" ? "video/quicktime" : "video/mp4";
    const { error } = await supabase.storage.from(BUCKET).upload(t.storagePath, buf, {
      contentType: mimeType,
      upsert: true,
    });
    if (error) {
      console.error(`  X ${t.storagePath} : ${error.message}`);
      // Nettoie l'éventuel intro_video_path précédent en base
      // (si l'upload échoue, on ne veut pas pointer vers un fichier inexistant)
      const { error: cleanErr } = await supabase
        .from("modules")
        .update({
          intro_video_path: null,
          intro_video_label: null,
          intro_video_duration_s: null,
        })
        .eq("slug", t.slug);
      if (cleanErr) console.error(`     /!\\ Cleanup DB ${t.slug} : ${cleanErr.message}`);
      else console.error(`     → intro_video_path remis à NULL pour ${t.slug}`);
      continue;
    }
    uploaded++;
    uploadedTasks.push(t);
    console.log(`  ✓ ${t.storagePath}`);
  }
  console.log(`✓ ${uploaded}/${tasks.length} vidéos uploadées`);

  // ───── 2. UPDATE modules (seulement pour ceux dont l'upload a réussi) ─────
  console.log("\n[2/2] Mise à jour des modules en base...");
  let updated = 0;
  for (const t of uploadedTasks) {
    const { error } = await supabase
      .from("modules")
      .update({
        intro_video_path: t.storagePath,
        intro_video_label: t.label,
        intro_video_duration_s: t.durationS,
      })
      .eq("slug", t.slug);
    if (error) {
      console.error(`  X ${t.slug} : ${error.message}`);
      continue;
    }
    updated++;
    console.log(`  ✓ ${t.slug}`);
  }
  console.log(`✓ ${updated}/${uploadedTasks.length} modules mis à jour`);

  console.log("\n╔══════════════════════════════════════════════════════════");
  console.log("║ ✓ IMPORT VIDÉOS INTRO CAPA TERMINÉ");
  console.log("╠══════════════════════════════════════════════════════════");
  console.log(`║ Vidéos uploadées : ${uploaded}/${tasks.length}`);
  console.log(`║ Modules mis à jour : ${updated}/${tasks.length}`);
  if (unmapped.length > 0) {
    console.log(`║ Fichiers non mappés : ${unmapped.length} (à renommer + relancer)`);
  }
  console.log("╚══════════════════════════════════════════════════════════");
  console.log("\nLes stagiaires inscrits à Capa verront désormais la vidéo intro");
  console.log("en haut de chaque module détail (/modules/<slug>).");
}

main().catch((err) => {
  console.error("Erreur :", err);
  process.exit(1);
});
