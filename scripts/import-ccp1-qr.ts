// =====================================================================
// scripts/import-ccp1-qr.ts
//
// Importe entièrement les Questions Rédigées (QR) du CCP1 GOTRM depuis
// les PDFs fournis par le client (/Users/abdelkader/Downloads/QR_CCP1_GOTRM,
// 17 chapitres / 66 exercices / 23 annexes).
//
// Pipeline complet (exécuté directement contre Supabase via le SDK) :
//   1. Liste tous les exercices et leurs annexes
//   2. Parse chaque PDF (pdf-parse) → CONTEXTE + TRAVAIL DEMANDÉ
//   3. Upload chaque annexe vers bucket "question-attachments"
//      (préfixe ccp1-v2/chXX/)
//   4. DELETE des anciens QR CCP1 (cascade attachments + quiz_question_bank)
//   5. INSERT des nouveaux QR dans question_bank + question_attachments
//   6. Génère AUSSI supabase/gotrm_ccp1_qr_v2.sql en backup/traçabilité
//
// Usage : npx tsx scripts/import-ccp1-qr.ts
//
// Variables d'env (.env.local) :
//   NEXT_PUBLIC_SUPABASE_URL
//   SUPABASE_SERVICE_ROLE_KEY
// =====================================================================

import { createClient } from "@supabase/supabase-js";
import { readFileSync, readdirSync, writeFileSync } from "node:fs";
import { resolve, join, basename, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { config as loadEnv } from "dotenv";
import pdfParse from "pdf-parse";

const __dirname = dirname(fileURLToPath(import.meta.url));
loadEnv({ path: resolve(__dirname, "..", ".env.local") });

// ---------- Configuration ----------
const SOURCE_DIR = "/Users/abdelkader/Downloads/QR_CCP1_GOTRM";
const OUTPUT_SQL = resolve(__dirname, "..", "supabase", "gotrm_ccp1_qr_v2.sql");
const BUCKET = "question-attachments";
const STORAGE_PREFIX = "ccp1-v2";
const SOURCE_REF_PREFIX = "mft-2026-gotrm-ccp1-qr-v2";
const DEFAULT_MAX_SCORE = 6;

const CHAPTER_MODULE_SLUGS: Record<string, string> = {
  "01": "gotrm-ch01-environnement-trm",
  "02": "gotrm-ch02-vehicules-marchandises",
  "03": "gotrm-ch03-analyser-demande",
  "04": "gotrm-ch04-cout-revient-tarification",
  "05": "gotrm-ch05-offre-commerciale",
  "06": "gotrm-ch06-affecter-moyens",
  "07": "gotrm-ch07-documents-transport",
  "08": "gotrm-ch08-planifier-operations",
  "09": "gotrm-ch09-rse-conducteurs",
  "10": "gotrm-ch10-encadrer-conducteurs",
  "11": "gotrm-ch11-suivi-aleas",
  "12": "gotrm-ch12-facturation-litiges-cloture",
  "13": "gotrm-ch13-kpi-rentabilite",
  "14": "gotrm-ch14-environnement-rse",
  "15": "gotrm-ch15-international",
  "16": "gotrm-ch16-supports-charge",
  "17": "gotrm-ch17-anglais-pro",
};

// ---------- Supabase ----------
const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!SUPABASE_URL || !SERVICE_KEY) {
  console.error("Manque NEXT_PUBLIC_SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY dans .env.local");
  process.exit(1);
}
const supabase = createClient(SUPABASE_URL, SERVICE_KEY, { auth: { persistSession: false } });

// ---------- Types ----------
type QrExercise = {
  chapterNum: string;
  exerciseNum: string;
  pdfPath: string;
  annexePath: string | null;
  title: string;
  contextHtml: string;
  workHtml: string;
  storagePath: string | null;
  sourceRef: string;
};

// ---------- Helpers ----------
function escapeSqlString(s: string): string {
  return s.split("'").join("''");
}
function escapeHtml(s: string): string {
  return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
function normalizeSpaces(s: string): string {
  return s.replace(/ /g, " ");
}

function parseExercisePdf(rawText: string, exerciseNum: string): {
  title: string;
  contextHtml: string;
  workHtml: string;
} {
  let text = normalizeSpaces(rawText.replace(/\r\n/g, "\n"));
  text = text
    .replace(/Page\s+\d+\s+sur\s+\d+/gi, "")
    .replace(/^\s*MFT\s*$/gim, "")
    .replace(/^\s*CHAPITRE\s+\d+\s*$/gim, "")
    .replace(/^\s*L'environnement[^\n]*$/gim, "")
    .replace(/^\s*Calculer le co.t de revient[^\n]*$/gim, "");

  const escapedNum = exerciseNum.replace(/\./g, "\\.");
  const sectionPattern = new RegExp(
    `Exercice\\s+${escapedNum}\\s*[\\u2014\\u2013\\-][\\s\\S]*?(?=Exercice\\s+\\d+\\.\\d+(?:bis)?\\s*[\\u2014\\u2013\\-]|$)`,
    "i",
  );
  const sectionMatch = text.match(sectionPattern);
  const section = sectionMatch ? sectionMatch[0] : text;

  const titleMatch = section.match(
    new RegExp(`Exercice\\s+${escapedNum}\\s*[\\u2014\\u2013\\-]\\s*([^\\n]+)`, "i"),
  );
  const title = titleMatch ? titleMatch[1].trim() : `Exercice ${exerciseNum}`;

  const contextMatch = section.match(
    /CONTEXTE\s*\n([\s\S]*?)(?=TRAVAIL\s*(?:A\s*REALISER|DEMAND[ÉéE]|À\s*REALISER)|ANNEXES?\b|$)/i,
  );
  const workMatch = section.match(
    /TRAVAIL\s*(?:A\s*REALISER|DEMAND[ÉéE]|À\s*REALISER)\s*\n([\s\S]*?)(?=ANNEXES?\b|$)/i,
  );
  const annexesInline = section.match(/ANNEXES?\b[^\n]*\n([\s\S]*)/i);

  let contextRaw = contextMatch ? contextMatch[1] : "";
  let workRaw = workMatch ? workMatch[1] : "";

  if (!contextRaw && !workRaw) {
    workRaw = section.replace(
      new RegExp(`^[\\s\\S]*?Exercice\\s+${escapedNum}[^\\n]*\\n`, "i"),
      "",
    );
  }
  if (annexesInline) {
    workRaw += "\n\nDONNÉES FOURNIES POUR RÉSOUDRE L'EXERCICE :\n" + annexesInline[1];
  }

  return {
    title,
    contextHtml: formatSectionToHtml(contextRaw),
    workHtml: formatSectionToHtml(workRaw),
  };
}

function formatSectionToHtml(raw: string): string {
  if (!raw || !raw.trim()) return "";
  let text = raw.replace(/Page\s+\d+\s+sur\s+\d+/gi, "").replace(/\n{3,}/g, "\n\n").trim();
  const blocks = text.split(/\n\s*\n/);
  const htmlParts: string[] = [];
  for (const block of blocks) {
    const lines = block.split("\n").map((l) => l.trimEnd()).filter((l) => l.trim());
    if (lines.length === 0) continue;
    const isNumberedList = lines.every((l) => /^\s*\d+[.)]\s+/.test(l));
    const isBulletList = lines.every(
      (l) => /^\s*[-•o*]\s+/.test(l) || /^\s+[a-z][).]\s+/.test(l),
    );
    const tableLines = lines.filter((l) => /\S\s{3,}\S/.test(l)).length;
    const isLikelyTable = tableLines >= lines.length * 0.5 && lines.length >= 2;

    if (isNumberedList) {
      const items = lines.map((l) => `<li>${escapeHtml(l.replace(/^\s*\d+[.)]\s+/, ""))}</li>`).join("");
      htmlParts.push(`<ol>${items}</ol>`);
    } else if (isBulletList) {
      const items = lines
        .map((l) => `<li>${escapeHtml(l.replace(/^\s*[-•o*]\s+/, "").replace(/^\s+[a-z][).]\s+/, ""))}</li>`)
        .join("");
      htmlParts.push(`<ul>${items}</ul>`);
    } else if (isLikelyTable) {
      htmlParts.push(
        `<pre style="font-family:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,monospace;background:#F8FAFC;border:1px solid #E2E8F0;border-radius:8px;padding:12px;overflow-x:auto;white-space:pre;font-size:13px;line-height:1.5;color:#0F172A;">${escapeHtml(block.trim())}</pre>`,
      );
    } else {
      const para = escapeHtml(lines.join(" ")).replace(/\s+/g, " ");
      if (para.trim()) htmlParts.push(`<p>${para}</p>`);
    }
  }
  return htmlParts.join("\n");
}

function buildStatementHtml(ex: QrExercise): string {
  const parts: string[] = [];
  parts.push(
    `<div style="margin-bottom:16px;padding:14px 18px;background:linear-gradient(135deg,#0E1240 0%,#1E40AF 100%);color:white;border-radius:12px;box-shadow:0 4px 12px rgba(14,18,64,0.15);">
      <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#9FE220;margin-bottom:6px;">Chapitre ${parseInt(ex.chapterNum)} &middot; Exercice ${ex.exerciseNum}</div>
      <div style="font-size:17px;font-weight:600;line-height:1.3;letter-spacing:-0.01em;">${escapeHtml(ex.title)}</div>
    </div>`,
  );
  if (ex.contextHtml) {
    parts.push(
      `<div style="margin:18px 0;padding:16px 18px;background:#EEF6FF;border-left:4px solid #2563EB;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#1D4ED8;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#2563EB;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">i</span>
          Contexte
        </div>
        <div style="color:#0F172A;line-height:1.65;">${ex.contextHtml}</div>
      </div>`,
    );
  }
  if (ex.workHtml) {
    parts.push(
      `<div style="margin:18px 0;padding:16px 18px;background:#F0FDF4;border-left:4px solid #059669;border-radius:10px;">
        <div style="font-size:11px;font-weight:700;letter-spacing:0.16em;text-transform:uppercase;color:#047857;margin-bottom:10px;">
          <span style="display:inline-block;width:18px;height:18px;background:#059669;color:white;border-radius:50%;text-align:center;line-height:18px;font-size:11px;margin-right:6px;">&#10003;</span>
          Travail à réaliser
        </div>
        <div style="color:#0F172A;line-height:1.65;">${ex.workHtml}</div>
      </div>`,
    );
  }
  if (ex.annexePath) {
    parts.push(
      `<div style="margin:18px 0;padding:12px 16px;background:#FEF3C7;border:1px solid #FCD34D;border-radius:10px;font-size:13.5px;color:#92400E;">
        <span style="font-size:18px;margin-right:8px;">&#128206;</span>
        <strong>Annexe à consulter</strong> &mdash; Référez-vous au document joint ci-dessous (données chiffrées, tableaux, lettres de voiture, plannings, etc.) pour résoudre l'exercice.
      </div>`,
    );
  }
  return parts.join("\n");
}

// ---------- Pipeline ----------
async function main() {
  console.log("Inventaire du dossier source...");
  const chapters = readdirSync(SOURCE_DIR)
    .filter((d) => d.startsWith("Chapitre_"))
    .sort();

  const exercises: QrExercise[] = [];

  for (const chDir of chapters) {
    const chapterNum = chDir.replace("Chapitre_", "");
    const chapterPath = join(SOURCE_DIR, chDir);
    const files = readdirSync(chapterPath).filter((f) => f.endsWith(".pdf"));
    const exoFiles = files.filter((f) => !/_Annexe/i.test(f)).sort((a, b) => {
      const na = parseFloat(a.match(/(\d+(?:\.\d+)?)/)?.[0] ?? "0");
      const nb = parseFloat(b.match(/(\d+(?:\.\d+)?)/)?.[0] ?? "0");
      return na - nb;
    });
    for (const exoFile of exoFiles) {
      const exMatch = exoFile.match(/Exercice_(\d+\.\d+(?:bis)?)/i);
      const exerciseNum = exMatch ? exMatch[1] : exoFile;
      const baseName = exoFile.replace(/\.pdf$/i, "");
      const annexeCandidate = files.find((f) =>
        new RegExp(`^${baseName}_Annexe.*\\.pdf$`, "i").test(f),
      );
      const pdfPath = join(chapterPath, exoFile);
      const annexePath = annexeCandidate ? join(chapterPath, annexeCandidate) : null;
      const rawBuf = readFileSync(pdfPath);
      const parsed = await pdfParse(rawBuf);
      const { title, contextHtml, workHtml } = parseExercisePdf(parsed.text, exerciseNum);
      const storagePath = annexePath
        ? `${STORAGE_PREFIX}/ch${chapterNum}/${basename(annexePath)}`
        : null;
      const sourceRef = `${SOURCE_REF_PREFIX}:ch${chapterNum}:ex${exerciseNum}`;
      exercises.push({
        chapterNum, exerciseNum, pdfPath, annexePath, title,
        contextHtml, workHtml, storagePath, sourceRef,
      });
    }
  }

  console.log(`✓ ${exercises.length} exercices détectés sur ${chapters.length} chapitres`);
  console.log(`  ${exercises.filter((e) => e.annexePath).length} annexes à uploader`);

  // ───── 1. Upload annexes ─────
  console.log("\n[1/4] Upload des annexes vers Storage...");
  let uploaded = 0, skipped = 0;
  for (const ex of exercises) {
    if (!ex.annexePath || !ex.storagePath) continue;
    const buf = readFileSync(ex.annexePath);
    const { error } = await supabase.storage.from(BUCKET).upload(ex.storagePath, buf, {
      contentType: "application/pdf",
      upsert: true,
    });
    if (error) {
      console.error(`  X ${ex.storagePath} :`, error.message);
      skipped++;
    } else {
      uploaded++;
    }
  }
  console.log(`✓ ${uploaded} annexes uploadées (${skipped} échecs)`);

  // ───── 2. Récupère formation_id et module_ids ─────
  console.log("\n[2/4] Récupération formation + modules...");
  const { data: formation, error: fErr } = await supabase
    .from("formations").select("id").eq("slug", "gotrm").single();
  if (fErr || !formation) throw new Error("Formation gotrm introuvable : " + fErr?.message);
  const formationId = formation.id as string;

  const moduleSlugs = Array.from(new Set(Object.values(CHAPTER_MODULE_SLUGS)));
  const { data: modules, error: mErr } = await supabase
    .from("modules").select("id,slug").in("slug", moduleSlugs);
  if (mErr || !modules) throw new Error("Modules introuvables : " + mErr?.message);
  const slugToModuleId = new Map(modules.map((m: any) => [m.slug, m.id]));
  console.log(`✓ Formation GOTRM (${formationId.slice(0, 8)}…) + ${modules.length} modules trouvés`);

  // ───── 3. DELETE anciens QR ─────
  console.log("\n[3/4] Suppression des anciens QR CCP1...");
  const { error: dLegacy } = await supabase
    .from("question_bank").delete()
    .eq("formation_id", formationId)
    .eq("type", "qr")
    .like("source_ref", "mft-2026-gotrm-livret:%:qr:%");
  if (dLegacy) console.warn("  Warning livret :", dLegacy.message);

  const { error: dV2 } = await supabase
    .from("question_bank").delete()
    .eq("formation_id", formationId)
    .eq("type", "qr")
    .like("source_ref", `${SOURCE_REF_PREFIX}:%`);
  if (dV2) console.warn("  Warning v2 :", dV2.message);
  console.log("✓ Anciens QR supprimés (CASCADE → attachments + quiz_question_bank)");

  // ───── 4. INSERT nouveaux QR + attachments ─────
  console.log("\n[4/4] Insertion des nouveaux QR + attachments...");
  let inserted = 0, attached = 0;
  for (const ex of exercises) {
    const moduleSlug = CHAPTER_MODULE_SLUGS[ex.chapterNum];
    const moduleId = slugToModuleId.get(moduleSlug);
    if (!moduleId) {
      console.warn(`  /!\\ Module manquant pour Ch${ex.chapterNum} (${moduleSlug})`);
      continue;
    }
    const statement = buildStatementHtml(ex);

    const { data: q, error: qErr } = await supabase
      .from("question_bank")
      .insert({
        formation_id: formationId,
        module_id: moduleId,
        type: "qr",
        statement,
        max_score: DEFAULT_MAX_SCORE,
        difficulty: "moyen",
        tags: ["CCP1", `Ch${ex.chapterNum}`, "QR-v2"],
        source_ref: ex.sourceRef,
        active: true,
      })
      .select("id")
      .single();
    if (qErr || !q) {
      console.error(`  X Ch${ex.chapterNum} Ex${ex.exerciseNum} :`, qErr?.message);
      continue;
    }
    inserted++;

    if (ex.storagePath && ex.annexePath) {
      const { error: aErr } = await supabase
        .from("question_attachments")
        .insert({
          question_id: q.id,
          storage_path: ex.storagePath,
          file_name: basename(ex.annexePath),
          mime_type: "application/pdf",
          kind: "pdf",
          label: "Annexe — Documents et tableaux à consulter",
          display_order: 1,
        });
      if (aErr) {
        console.error(`  X Annexe Ch${ex.chapterNum} Ex${ex.exerciseNum} :`, aErr.message);
      } else {
        attached++;
      }
    }
  }
  console.log(`✓ ${inserted} QR insérés, ${attached} attachments liés`);

  // ───── 5. Backup SQL pour traçabilité ─────
  console.log("\nGénération du SQL backup (traçabilité git)...");
  const sqlLines: string[] = [];
  sqlLines.push(`-- =====================================================================
-- COURS GOTRM CCP1 — Questions Rédigées (QR) v2 [BACKUP SQL]
--
-- Ce fichier est généré par scripts/import-ccp1-qr.ts et fourni en backup
-- pour traçabilité git. L'import a déjà été exécuté via le SDK Supabase
-- lors de la dernière exécution du script.
--
-- Pour rejouer entièrement (par ex. sur une nouvelle base) :
--   npx tsx scripts/import-ccp1-qr.ts
--
-- Statistiques :
--   ${exercises.length} QR
--   ${exercises.filter((e) => e.annexePath).length} annexes liées
--   Bucket Storage : ${BUCKET} (préfixe ${STORAGE_PREFIX}/)
--   source_ref pattern : ${SOURCE_REF_PREFIX}:chNN:exX.Y
-- =====================================================================

DO $ccp1_qr_v2$
DECLARE
  v_formation uuid;
  v_module uuid;
  v_question uuid;
  v_count_questions int := 0;
  v_count_attachments int := 0;
BEGIN
  SELECT id INTO v_formation FROM public.formations WHERE slug = 'gotrm';
  IF v_formation IS NULL THEN RAISE EXCEPTION 'Formation gotrm introuvable'; END IF;

  DELETE FROM public.question_bank
   WHERE formation_id = v_formation
     AND type = 'qr'
     AND (source_ref LIKE 'mft-2026-gotrm-livret:%:qr:%'
          OR source_ref LIKE '${SOURCE_REF_PREFIX}:%');
  RAISE NOTICE 'Anciens QR CCP1 supprimés';
`);

  for (const ex of exercises) {
    const moduleSlug = CHAPTER_MODULE_SLUGS[ex.chapterNum];
    if (!moduleSlug) continue;
    const statement = buildStatementHtml(ex);
    sqlLines.push(`
  -- Ch${ex.chapterNum} Ex ${ex.exerciseNum} : ${ex.title.replace(/'/g, "''").slice(0, 60)}
  SELECT id INTO v_module FROM public.modules WHERE slug = '${moduleSlug}';
  INSERT INTO public.question_bank (formation_id, module_id, type, statement, max_score, difficulty, tags, source_ref, active)
  VALUES (v_formation, v_module, 'qr', '${escapeSqlString(statement)}', ${DEFAULT_MAX_SCORE}, 'moyen',
    ARRAY['CCP1','Ch${ex.chapterNum}','QR-v2'], '${ex.sourceRef}', true)
  RETURNING id INTO v_question;
  v_count_questions := v_count_questions + 1;`);
    if (ex.storagePath && ex.annexePath) {
      sqlLines.push(`  INSERT INTO public.question_attachments (question_id, storage_path, file_name, mime_type, kind, label, display_order)
  VALUES (v_question, '${escapeSqlString(ex.storagePath)}', '${escapeSqlString(basename(ex.annexePath))}', 'application/pdf', 'pdf', 'Annexe — Documents et tableaux à consulter', 1);
  v_count_attachments := v_count_attachments + 1;`);
    }
  }
  sqlLines.push(`
  RAISE NOTICE 'CCP1 QR v2 : % questions, % attachments', v_count_questions, v_count_attachments;
END $ccp1_qr_v2$;
`);
  writeFileSync(OUTPUT_SQL, sqlLines.join("\n"), "utf-8");
  console.log(`✓ Backup SQL : ${OUTPUT_SQL}`);

  // ───── Récap final ─────
  console.log("\n╔══════════════════════════════════════════════════════════");
  console.log("║ ✓ IMPORT CCP1 QR v2 TERMINÉ");
  console.log("╠══════════════════════════════════════════════════════════");
  console.log(`║ Annexes uploadées Storage : ${uploaded}`);
  console.log(`║ QR insérés DB             : ${inserted}`);
  console.log(`║ Attachments liés DB       : ${attached}`);
  console.log("╚══════════════════════════════════════════════════════════");
  console.log("\nRécap par chapitre :");
  for (const ch of chapters) {
    const num = ch.replace("Chapitre_", "");
    const inCh = exercises.filter((e) => e.chapterNum === num);
    const withAnnex = inCh.filter((e) => e.annexePath).length;
    console.log(`  Ch${num} : ${inCh.length} QR${withAnnex ? ` (${withAnnex} avec annexe)` : ""}`);
  }
}

main().catch((err) => {
  console.error("Erreur :", err);
  process.exit(1);
});
