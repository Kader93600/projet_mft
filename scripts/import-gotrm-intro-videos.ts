// =====================================================================
// scripts/import-gotrm-intro-videos.ts
//
// Importe les vidéos d'introduction des CCP de la formation GOTRM
// depuis un dossier local (par défaut ~/Downloads/GOTRM_Intros/).
//
// Différence avec import-capa-intro-videos.ts :
//   - GOTRM est structuré par CCP (3 blocs) : CCP1 (17 modules),
//     CCP2 (12 modules), CCP3 (12 modules).
//   - Une vidéo intro couvre UN CCP entier, pas un module unique.
//     Conséquence : on attache la même vidéo à TOUS les modules du CCP
//     pour que le stagiaire la voie quel que soit le chapitre ouvert.
//
// Conventions de nommage acceptées dans le dossier source :
//   gotrm_ccp1.mp4, gotrm-ccp1.mp4, gotrm ccp1.mp4
//   ccp1.mp4, ccp-1.mp4, ccp_1.mp4
//   intro_ccp1.mp4, etc.
//
// Usage : npx tsx scripts/import-gotrm-intro-videos.ts
//
// Variables d'env (.env.local) :
//   NEXT_PUBLIC_SUPABASE_URL
//   SUPABASE_SERVICE_ROLE_KEY
// =====================================================================

import { createClient } from "@supabase/supabase-js";
import { readFileSync, readdirSync } from "node:fs";
import { resolve, join, basename, dirname, extname } from "node:path";
import { fileURLToPath } from "node:url";
import { config as loadEnv } from "dotenv";
import { homedir } from "node:os";

const __dirname = dirname(fileURLToPath(import.meta.url));
loadEnv({ path: resolve(__dirname, "..", ".env.local") });

// ---------- Configuration ----------
const SOURCE_DIR =
  process.env.GOTRM_VIDEOS_DIR ??
  resolve(homedir(), "Downloads", "GOTRM_Intros");
const BUCKET = "module-intro-videos";

// Mapping CCP → pattern de slug + label affiché sous la vidéo.
// Le pattern filtre les modules à mettre à jour pour ce CCP.
const CCP_CONFIG: Record<
  string,
  { slugPattern: RegExp; label: string; storagePath: (ext: string) => string }
> = {
  "1": {
    slugPattern: /^gotrm-ch\d+-/, // gotrm-ch01-... à gotrm-ch17-...
    label:
      "Découvrez le CCP1 — Concevoir, organiser et piloter l'exploitation.",
    storagePath: (ext) => `gotrm/ccp1${ext}`,
  },
  "2": {
    slugPattern: /^ccp2-ch/, // ccp2-ch01-... à ccp2-ch12-...
    label: "Découvrez le CCP2 — Manager l'équipe de conduite.",
    storagePath: (ext) => `gotrm/ccp2${ext}`,
  },
  "3": {
    slugPattern: /^ccp3-ch/, // ccp3-ch01-... à ccp3-ch12-...
    label:
      "Découvrez le CCP3 — Optimiser l'ensemble des moyens liés à l'activité de transport.",
    storagePath: (ext) => `gotrm/ccp3${ext}`,
  },
};

// ---------- Supabase ----------
const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!SUPABASE_URL || !SERVICE_KEY) {
  console.error(
    "Manque NEXT_PUBLIC_SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY dans .env.local",
  );
  process.exit(1);
}
const supabase = createClient(SUPABASE_URL, SERVICE_KEY, {
  auth: { persistSession: false },
});

/**
 * Détecte le numéro de CCP (1, 2 ou 3) depuis le nom du fichier.
 * Accepte plusieurs conventions de nommage. Renvoie null si non détecté.
 */
function detectCcpNumber(filename: string): string | null {
  const base = basename(filename, extname(filename)).toLowerCase();
  // Patterns dans l'ordre de spécificité
  const patterns = [
    /gotrm[-_ ]?ccp[-_ ]?([123])\b/, // gotrm_ccp1.mp4, gotrm-ccp-1.mp4
    /ccp[-_ ]?([123])\b/, // ccp1.mp4, ccp_1.mp4, ccp-1.mp4
    /intro[-_ ]?ccp[-_ ]?([123])\b/, // intro_ccp1.mp4
    /([123])\.(?:mp4|m4v|webm|mov)$/i, // 1.mp4 (peu spécifique, en dernier)
  ];
  for (const pat of patterns) {
    const m = base.match(pat);
    if (m && CCP_CONFIG[m[1]]) return m[1];
  }
  return null;
}

/**
 * Extraction simple de la durée d'un MP4 via la box "mvhd" du moov atom.
 * Aucune dépendance externe nécessaire (vs ffprobe).
 */
function extractMp4DurationS(buf: Buffer): number | null {
  try {
    const mvhd = buf.indexOf(Buffer.from("mvhd"));
    if (mvhd < 0) return null;
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
    files = readdirSync(SOURCE_DIR).filter((f) =>
      /\.(mp4|m4v|webm|mov)$/i.test(f),
    );
  } catch (e: any) {
    console.error(
      `Impossible de lire le dossier (${SOURCE_DIR}) : ${e?.message ?? e}`,
    );
    console.error(
      `\n→ Crée le dossier et dépose-y tes MP4, ou définis GOTRM_VIDEOS_DIR=<chemin>`,
    );
    process.exit(1);
  }
  if (files.length === 0) {
    console.error(`Aucun fichier vidéo trouvé dans ${SOURCE_DIR}`);
    process.exit(1);
  }
  console.log(
    `${files.length} fichier(s) vidéo détecté(s) : ${files.join(", ")}`,
  );

  type Task = {
    file: string;
    ccp: string;
    storagePath: string;
    label: string;
    slugPattern: RegExp;
    sizeBytes: number;
    durationS: number | null;
  };
  const tasks: Task[] = [];
  const unmapped: string[] = [];

  for (const f of files) {
    const ccp = detectCcpNumber(f);
    if (!ccp) {
      unmapped.push(f);
      continue;
    }
    const fullPath = join(SOURCE_DIR, f);
    const buf = readFileSync(fullPath);
    const cfg = CCP_CONFIG[ccp];
    const ext = extname(f).toLowerCase();
    tasks.push({
      file: fullPath,
      ccp,
      storagePath: cfg.storagePath(ext),
      label: cfg.label,
      slugPattern: cfg.slugPattern,
      sizeBytes: buf.length,
      durationS: extractMp4DurationS(buf),
    });
  }

  if (unmapped.length > 0) {
    console.warn(
      `\n/!\\ ${unmapped.length} fichier(s) non mappé(s) (pas de CCP 1-3 détecté) :`,
    );
    unmapped.forEach((f) => console.warn(`   - ${f}`));
    console.warn(
      "   Renomme-les selon une convention reconnue (gotrm_ccp1.mp4, ccp1.mp4, intro_ccp1.mp4…)",
    );
  }
  if (tasks.length === 0) {
    console.error("\nAucun fichier ne correspond à un CCP GOTRM. Abandon.");
    process.exit(1);
  }

  // Pré-récupère la liste des modules par CCP pour le bilan
  console.log("\nMapping détecté :");
  for (const t of tasks) {
    const sizeMb = (t.sizeBytes / (1024 * 1024)).toFixed(1);
    const dur = t.durationS ? `${Math.round(t.durationS / 60)} min` : "?";
    const { data: modules } = await supabase
      .from("modules")
      .select("slug")
      .like("slug", t.slugPattern.source.includes("gotrm-ch") ? "gotrm-ch%" : `ccp${t.ccp}-ch%`);
    const matching = (modules ?? []).filter((m: any) =>
      t.slugPattern.test(m.slug as string),
    );
    console.log(
      `  ${basename(t.file).padEnd(25)} → CCP${t.ccp} (${matching.length} modules, ${sizeMb} MB, ${dur})`,
    );
  }

  // ───── 1. Upload vers Storage ─────
  console.log("\n[1/2] Upload vers Storage...");
  let uploaded = 0;
  const uploadedTasks: Task[] = [];
  for (const t of tasks) {
    const buf = readFileSync(t.file);
    const ext = extname(t.file).toLowerCase().slice(1);
    const mimeType =
      ext === "webm"
        ? "video/webm"
        : ext === "mov"
          ? "video/quicktime"
          : "video/mp4";
    const { error } = await supabase.storage
      .from(BUCKET)
      .upload(t.storagePath, buf, {
        contentType: mimeType,
        upsert: true,
      });
    if (error) {
      console.error(`  X ${t.storagePath} : ${error.message}`);
      continue;
    }
    uploaded++;
    uploadedTasks.push(t);
    console.log(`  ✓ ${t.storagePath}`);
  }
  console.log(`✓ ${uploaded}/${tasks.length} vidéos uploadées`);

  // ───── 2. UPDATE modules concernés ─────
  // Pour chaque CCP, on récupère TOUS ses modules et on les met à jour
  // avec le même intro_video_path. Cela permet au stagiaire de voir
  // la vidéo intro quel que soit le chapitre du CCP qu'il ouvre.
  console.log("\n[2/2] Mise à jour des modules en base...");
  let totalUpdated = 0;
  for (const t of uploadedTasks) {
    // On récupère tous les modules de ce CCP via le pattern de slug.
    // Postgres LIKE n'accepte pas la regex JS directement, donc on
    // utilise un préfixe LIKE puis filtre côté JS.
    const likePrefix =
      t.ccp === "1" ? "gotrm-ch%" : t.ccp === "2" ? "ccp2-ch%" : "ccp3-ch%";
    const { data: modules, error: listErr } = await supabase
      .from("modules")
      .select("id,slug")
      .like("slug", likePrefix);
    if (listErr) {
      console.error(`  X CCP${t.ccp} : ${listErr.message}`);
      continue;
    }
    const matching = (modules ?? []).filter((m: any) =>
      t.slugPattern.test(m.slug as string),
    );
    if (matching.length === 0) {
      console.warn(`  /!\\ CCP${t.ccp} : aucun module trouvé`);
      continue;
    }

    const { error: updateErr } = await supabase
      .from("modules")
      .update({
        intro_video_path: t.storagePath,
        intro_video_label: t.label,
        intro_video_duration_s: t.durationS,
      })
      .in(
        "id",
        matching.map((m: any) => m.id),
      );
    if (updateErr) {
      console.error(`  X CCP${t.ccp} update : ${updateErr.message}`);
      continue;
    }
    totalUpdated += matching.length;
    console.log(`  ✓ CCP${t.ccp} : ${matching.length} modules mis à jour`);
  }
  console.log(`✓ ${totalUpdated} modules GOTRM mis à jour au total`);

  console.log(
    "\n╔══════════════════════════════════════════════════════════",
  );
  console.log("║ ✓ IMPORT VIDÉOS INTRO GOTRM TERMINÉ");
  console.log("╠══════════════════════════════════════════════════════════");
  console.log(`║ Vidéos uploadées Storage : ${uploaded}/${tasks.length}`);
  console.log(`║ Modules mis à jour DB    : ${totalUpdated}`);
  if (unmapped.length > 0) {
    console.log(
      `║ Fichiers non mappés      : ${unmapped.length} (à renommer + relancer)`,
    );
  }
  console.log(
    "╚══════════════════════════════════════════════════════════",
  );
  console.log(
    "\nLes stagiaires inscrits à GOTRM verront désormais la vidéo intro",
  );
  console.log(
    "du CCP correspondant en haut de chaque module détail (/modules/<slug>).",
  );
}

main().catch((err) => {
  console.error("Erreur :", err);
  process.exit(1);
});
