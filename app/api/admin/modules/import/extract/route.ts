// =====================================================================
// POST /api/admin/modules/import/extract
//
// Workflow :
//   1. Reçoit un PDF (multipart/form-data) ou pasted_text
//   2. Upload le PDF dans Supabase Storage (bucket question-imports —
//      réutilisé pour les annexes "voir page X du PDF source")
//   3. Extrait le texte par page
//   4. Parse en chapitres + leçons (lib/lesson-parser)
//   5. Renvoie le draft prêt à être édité côté UI
//
// Pas de table d'audit spécifique pour les imports de cours (à la
// différence des questions) — on s'appuie sur audit_logs côté save.
// =====================================================================

import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/lib/admin-guard";
import { extractPdfText, normalizePdfText } from "@/lib/pdf-extract";
import { parseLessons } from "@/lib/lesson-parser";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";
export const maxDuration = 90;

const MAX_BYTES = 15 * 1024 * 1024;
const STORAGE_BUCKET = "question-imports";

export async function POST(req: NextRequest) {
  try {
    const { supabase, admin } = await requireAdmin();

    const form = await req.formData();
    const file = form.get("file");
    const formationSlug = String(form.get("formation_slug") ?? "");
    const blocCode = String(form.get("bloc_code") ?? ""); // ex "BC2"
    const pastedText = (form.get("pasted_text") as string) || null;

    let rawText = "";
    let pageTexts: string[] = [];
    let fileName = "paste.txt";
    let byteLength = 0;
    let pdfBuffer: Buffer | null = null;

    if (file instanceof File) {
      if (file.size > MAX_BYTES) {
        return NextResponse.json(
          { error: "file_too_large", limit: MAX_BYTES },
          { status: 413 },
        );
      }
      fileName = file.name || "cours.pdf";
      byteLength = file.size;
      pdfBuffer = Buffer.from(await file.arrayBuffer());
      if (
        file.type === "application/pdf" ||
        fileName.toLowerCase().endsWith(".pdf")
      ) {
        const extracted = await extractPdfText(pdfBuffer);
        rawText = extracted.text;
        pageTexts = extracted.pageTexts;
      } else {
        rawText = pdfBuffer.toString("utf-8");
        pageTexts = [rawText];
        pdfBuffer = null;
      }
    } else if (pastedText) {
      rawText = pastedText;
      pageTexts = [pastedText];
      fileName = "paste-" + new Date().toISOString().slice(0, 16) + ".txt";
      byteLength = pastedText.length;
    } else {
      return NextResponse.json({ error: "no_file_or_text" }, { status: 400 });
    }

    rawText = normalizePdfText(rawText);

    if (rawText.trim().length < 60) {
      return NextResponse.json(
        {
          error: "empty_extraction",
          message:
            "Le PDF ne contient pas (ou peu) de texte sélectionnable. Si c'est un PDF scanné, copiez-collez le contenu dans le champ Texte brut.",
        },
        { status: 422 },
      );
    }

    // Parse en chapitres + leçons
    const parsed = parseLessons(rawText, pageTexts);

    if (parsed.chapters.length === 0) {
      return NextResponse.json(
        {
          error: "no_chapters_detected",
          message:
            "Aucun chapitre ne suit le format attendu (CHAPITRE N — Titre, puis sections N.M — …). Vérifiez le format ou collez le texte ajusté.",
        },
        { status: 422 },
      );
    }

    // Upload PDF dans Storage si disponible
    let pdfStoragePath: string | null = null;
    if (pdfBuffer) {
      const safeName = fileName.replace(/[^a-zA-Z0-9._-]/g, "_").slice(0, 100);
      pdfStoragePath = `${admin.id}/courses/${Date.now()}-${safeName}`;
      const { error: upErr } = await supabase.storage
        .from(STORAGE_BUCKET)
        .upload(pdfStoragePath, pdfBuffer, {
          contentType: "application/pdf",
          upsert: false,
        });
      if (upErr) {
        // eslint-disable-next-line no-console
        console.warn("[modules/import] upload Storage échoué :", upErr.message);
        pdfStoragePath = null;
      }
    }

    return NextResponse.json({
      chapters: parsed.chapters,
      summary: parsed.summary,
      raw_text: rawText,
      pdf_storage_path: pdfStoragePath,
      file_name: fileName,
      file_size_bytes: byteLength,
      formation_slug: formationSlug,
      bloc_code: blocCode || null,
    });
  } catch (e: any) {
    // eslint-disable-next-line no-console
    console.error("[modules/import/extract] error:", e);
    return NextResponse.json(
      { error: e?.message ?? "unknown_error" },
      { status: 500 },
    );
  }
}
