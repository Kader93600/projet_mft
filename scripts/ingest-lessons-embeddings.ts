// =====================================================================
// scripts/ingest-lessons-embeddings.ts
//
// Pipeline d'ingestion RAG : lit toutes les leçons (lessons.content_md),
// les découpe en chunks ~500 tokens, calcule leur embedding via OpenAI
// (text-embedding-3-small) et les upsert dans la table lesson_chunks.
//
// Idempotent : utilise lesson_chunks.UNIQUE(lesson_id, chunk_index)
// pour pouvoir relancer après une mise à jour de contenu sans dupliquer.
//
// Usage :
//   # Toutes les leçons (incrémental)
//   npx tsx scripts/ingest-lessons-embeddings.ts
//
//   # Filtre par formation
//   npx tsx scripts/ingest-lessons-embeddings.ts --formation=gotrm-rncp-40990
//
//   # Rebuild from scratch (DELETE puis re-INSERT)
//   npx tsx scripts/ingest-lessons-embeddings.ts --rebuild
//
//   # Dry-run (affiche ce qui serait fait sans toucher la DB)
//   npx tsx scripts/ingest-lessons-embeddings.ts --dry-run
//
// Variables d'env (.env.local) :
//   NEXT_PUBLIC_SUPABASE_URL
//   SUPABASE_SERVICE_ROLE_KEY
//   OPENAI_API_KEY
//
// Coût estimé : ~0,02 $/M tokens (très peu cher).
// Une formation GOTRM complète (~150 leçons × ~500 tokens × 5 chunks)
// = ~0,5 M tokens = ~0,01 $ par run complet.
// =====================================================================

import { createClient } from "@supabase/supabase-js";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { config as loadEnv } from "dotenv";

import { chunkMarkdown } from "../lib/tutor/chunking";
import { embedBatch, EMBEDDING_DIM } from "../lib/tutor/embeddings";

const __dirname = dirname(fileURLToPath(import.meta.url));
loadEnv({ path: resolve(__dirname, "..", ".env.local") });

// ---------- Args CLI ----------
const args = process.argv.slice(2);
const flag = (name: string): string | true | undefined => {
  const found = args.find((a) => a === `--${name}` || a.startsWith(`--${name}=`));
  if (!found) return undefined;
  if (!found.includes("=")) return true;
  return found.split("=")[1];
};
const formationFilter =
  typeof flag("formation") === "string" ? (flag("formation") as string) : null;
const rebuild = flag("rebuild") === true;
const dryRun = flag("dry-run") === true;

// ---------- Setup Supabase service role ----------
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!supabaseUrl || !supabaseKey) {
  console.error("❌ NEXT_PUBLIC_SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY manquante.");
  process.exit(1);
}
if (!process.env.OPENAI_API_KEY) {
  console.error("❌ OPENAI_API_KEY manquante. Ajoute-la dans .env.local.");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

// ---------- Pipeline ----------
const BATCH_SIZE = 50; // 50 chunks par appel OpenAI

async function main() {
  console.log("🚀 Ingestion embeddings — démarrage");
  console.log(`   formation : ${formationFilter ?? "(toutes)"}`);
  console.log(`   rebuild   : ${rebuild}`);
  console.log(`   dry-run   : ${dryRun}`);

  // 1. Récupère les leçons à ingérer
  let lessonsQuery = supabase
    .from("lessons")
    .select(`
      id,
      title,
      content_md,
      module_id,
      modules!inner (
        id,
        slug,
        title,
        formation_modules!inner (
          formations!inner ( slug )
        )
      )
    `);

  const { data: lessons, error: lessonsErr } = await lessonsQuery;
  if (lessonsErr) {
    console.error("❌ Erreur lecture leçons :", lessonsErr.message);
    process.exit(1);
  }

  let filtered = (lessons ?? []) as any[];
  if (formationFilter) {
    filtered = filtered.filter((l) => {
      const fm = l.modules?.formation_modules;
      if (!Array.isArray(fm)) return false;
      return fm.some(
        (m: any) => m.formations?.slug === formationFilter
      );
    });
  }
  // Dédupe par lesson_id
  const byId = new Map<string, any>();
  for (const l of filtered) {
    if (!byId.has(l.id)) byId.set(l.id, l);
  }
  filtered = Array.from(byId.values()).filter(
    (l) => typeof l.content_md === "string" && l.content_md.trim().length > 0
  );

  console.log(`📚 ${filtered.length} leçons à ingérer`);

  if (rebuild && !dryRun) {
    console.log("🧹 Rebuild : suppression des chunks existants…");
    if (formationFilter) {
      // Suppression ciblée : on supprime les chunks dont la leçon
      // appartient à cette formation.
      const ids = filtered.map((l) => l.id);
      const { error } = await supabase
        .from("lesson_chunks")
        .delete()
        .in("lesson_id", ids);
      if (error) {
        console.error("❌ Erreur suppression chunks :", error.message);
        process.exit(1);
      }
    } else {
      const { error } = await supabase
        .from("lesson_chunks")
        .delete()
        .not("id", "is", null);
      if (error) {
        console.error("❌ Erreur suppression globale :", error.message);
        process.exit(1);
      }
    }
  }

  // 2. Pour chaque leçon : chunk + embed + upsert
  let totalChunks = 0;
  let totalCharsEstimated = 0;
  const allRows: Array<{
    lesson_id: string;
    chunk_index: number;
    content: string;
    token_count: number;
    embedding: number[];
  }> = [];

  for (const lesson of filtered) {
    const chunks = chunkMarkdown(lesson.content_md, {
      targetTokens: 500,
      overlapTokens: 50,
    });

    if (chunks.length === 0) continue;

    totalCharsEstimated += chunks.reduce((s, c) => s + c.content.length, 0);

    // Embed en batch de BATCH_SIZE
    for (let i = 0; i < chunks.length; i += BATCH_SIZE) {
      const slice = chunks.slice(i, i + BATCH_SIZE);
      let embeddings: number[][] = [];
      if (!dryRun) {
        try {
          embeddings = await embedBatch(slice.map((c) => c.content));
        } catch (e: any) {
          console.error(
            `❌ Erreur embed batch (lesson ${lesson.id}, chunks ${i}..${i + slice.length}) :`,
            e?.message
          );
          continue;
        }
      } else {
        embeddings = slice.map(() => new Array(EMBEDDING_DIM).fill(0));
      }

      for (let j = 0; j < slice.length; j++) {
        allRows.push({
          lesson_id: lesson.id,
          chunk_index: i + j,
          content: slice[j].content,
          token_count: slice[j].tokenCount,
          embedding: embeddings[j],
        });
      }
      totalChunks += slice.length;
    }

    console.log(
      `   ✓ ${lesson.title.slice(0, 50)}… (${chunks.length} chunks)`
    );
  }

  console.log(`📦 Total chunks générés : ${totalChunks}`);
  console.log(
    `📏 Taille estimée : ${(totalCharsEstimated / 1000).toFixed(0)} k chars`
  );

  if (dryRun) {
    console.log("🧪 Dry-run terminé — rien inséré en DB.");
    return;
  }

  // 3. Upsert par batch (Supabase limite 1000 rows par insert)
  const UPSERT_BATCH = 200;
  for (let i = 0; i < allRows.length; i += UPSERT_BATCH) {
    const batch = allRows.slice(i, i + UPSERT_BATCH);
    const { error } = await supabase
      .from("lesson_chunks")
      .upsert(batch, { onConflict: "lesson_id,chunk_index" });
    if (error) {
      console.error(
        `❌ Erreur upsert batch ${i}..${i + batch.length} :`,
        error.message
      );
      process.exit(1);
    }
    process.stdout.write(
      `\r📤 Upserté ${Math.min(i + batch.length, allRows.length)}/${allRows.length}…`
    );
  }
  console.log("\n✅ Ingestion terminée.");
}

main().catch((e) => {
  console.error("❌ Erreur fatale :", e);
  process.exit(1);
});
