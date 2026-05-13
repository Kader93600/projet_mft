// =====================================================================
// POST /api/admin/questions/import/extract
//
// Workflow :
//   1. Reçoit un PDF (multipart) ou un pasted_text
//   2. Upload le PDF dans Supabase Storage (bucket "question-imports")
//      pour pouvoir l'afficher au stagiaire plus tard (annexes)
//   3. Extrait le texte (global + par page)
//   4. Détecte les pages d'annexes
//   5. Parse les questions, résout les références aux annexes
//   6. Crée la ligne question_imports
//   7. Renvoie { import_id, raw_text, questions, summary, annexes }
// =====================================================================

import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/lib/admin-guard";
import { extractPdfText, normalizePdfText } from "@/lib/pdf-extract";
import { parseQuestions } from "@/lib/question-parser";
import {
  detectAnnexPages,
  resolveAnnexesForQuestion,
  type AnnexPage,
} from "@/lib/annex-detect";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";
export const maxDuration = 60;

const MAX_BYTES = 12 * 1024 * 1024;
const STORAGE_BUCKET = "question-imports";

export async function POST(req: NextRequest) {
  try {
    const { supabase, admin } = await requireAdmin();

    const form = await req.formData();
    const file = form.get("file");
    const formationSlug = String(form.get("formation_slug") ?? "");
    const expectedType = String(form.get("expected_type") ?? "mixed");
    const moduleId = (form.get("module_id") as string) || null;
    const lessonId = (form.get("lesson_id") as string) || null;
    const notes = (form.get("notes") as string) || null;
    const pastedText = (form.get("pasted_text") as string) || null;

    if (!["qcm", "qr", "mixed", "exam"].includes(expectedType)) {
      return NextResponse.json(
        { error: "expected_type_invalid" },
        { status: 400 },
      );
    }

    let rawText = "";
    let pageTexts: string[] = [];
    let byteLength = 0;
    let fileName = "paste.txt";
    let fileKind: "pdf" | "txt" | "paste" = "paste";
    let pdfBuffer: Buffer | null = null;

    if (file instanceof File) {
      if (file.size > MAX_BYTES) {
        return NextResponse.json(
          { error: "file_too_large", limit: MAX_BYTES },
          { status: 413 },
        );
      }
      fileName = file.name || "document.pdf";
      byteLength = file.size;
      pdfBuffer = Buffer.from(await file.arrayBuffer());

      if (
        file.type === "application/pdf" ||
        fileName.toLowerCase().endsWith(".pdf")
      ) {
        const extracted = await extractPdfText(pdfBuffer);
        rawText = extracted.text;
        pageTexts = extracted.pageTexts;
        fileKind = "pdf";
      } else {
        rawText = pdfBuffer.toString("utf-8");
        pageTexts = [rawText];
        fileKind = "txt";
        pdfBuffer = null; // pas un PDF, pas d'upload Storage
      }
    } else if (pastedText) {
      rawText = pastedText;
      pageTexts = [pastedText];
      fileKind = "paste";
      fileName = "paste-" + new Date().toISOString().slice(0, 16) + ".txt";
      byteLength = pastedText.length;
    } else {
      return NextResponse.json(
        { error: "no_file_or_text" },
        { status: 400 },
      );
    }

    rawText = normalizePdfText(rawText);

    if (rawText.trim().length < 30) {
      return NextResponse.json(
        {
          error: "empty_extraction",
          message:
            "Le PDF ne contient pas (ou peu) de texte sélectionnable. Si c'est un PDF scanné, copiez-collez le contenu dans le champ Texte brut.",
        },
        { status: 422 },
      );
    }

    // Résout formation_id
    let formationId: string | null = null;
    if (formationSlug) {
      const { data: f } = await supabase
        .from("formations")
        .select("id")
        .eq("slug", formationSlug)
        .single();
      formationId = f?.id ?? null;
    }

    // Détecte annexes par page
    const annexes: AnnexPage[] = detectAnnexPages(pageTexts);

    // Parse questions + résout les références d'annexes
    const parsed = parseQuestions(rawText);
    for (const q of parsed.questions) {
      const { pages, labels } = resolveAnnexesForQuestion(
        q.statement,
        annexes,
      );
      q.annexPages = pages;
      q.annexLabels = labels;
      if (pages.length > 0) {
        q.warnings = q.warnings.filter((w) => !w.includes("Annexe"));
      }
    }

    // Upload PDF dans Storage si on en a un
    let pdfStoragePath: string | null = null;
    if (pdfBuffer && fileKind === "pdf") {
      const safeName = fileName.replace(/[^a-zA-Z0-9._-]/g, "_").slice(0, 100);
      pdfStoragePath = `${admin.id}/${Date.now()}-${safeName}`;
      const { error: upErr } = await supabase.storage
        .from(STORAGE_BUCKET)
        .upload(pdfStoragePath, pdfBuffer, {
          contentType: "application/pdf",
          upsert: false,
        });
      if (upErr) {
        // Non bloquant : on continue sans annexes utilisables côté stagiaire
        // eslint-disable-next-line no-console
        console.warn("[import] upload Storage échoué :", upErr.message);
        pdfStoragePath = null;
      }
    }

    // Crée la ligne d'audit
    const { data: importRow, error: importErr } = await supabase
      .from("question_imports")
      .insert({
        file_name: fileName,
        file_size_bytes: byteLength,
        file_kind: fileKind,
        formation_id: formationId,
        module_id: moduleId,
        expected_type: expectedType,
        status: "parsed",
        questions_count: parsed.questions.length,
        raw_text: rawText,
        notes,
        created_by: admin.id,
        pdf_storage_path: pdfStoragePath,
        annex_pages: annexes.map((a) => a.pageNumber),
        annex_labels: annexes.map((a) => a.label),
      })
      .select("id")
      .single();

    if (importErr) {
      return NextResponse.json(
        { error: importErr.message },
        { status: 500 },
      );
    }

    return NextResponse.json({
      import_id: importRow.id,
      raw_text: rawText,
      questions: parsed.questions,
      summary: parsed.summary,
      annexes,
      pdf_storage_path: pdfStoragePath,
      lesson_id: lessonId, // renvoie ce que le client a sélectionné
    });
  } catch (e: any) {
    return NextResponse.json(
      { error: e?.message ?? "unknown_error" },
      { status: 500 },
    );
  }
}
