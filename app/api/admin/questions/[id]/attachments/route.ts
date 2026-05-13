// =====================================================================
// POST   /api/admin/questions/[id]/attachments  → upload + insert
// DELETE /api/admin/questions/[id]/attachments?attachmentId=...
//
// Permet à l'admin d'ajouter / retirer des annexes (image, PDF, doc)
// directement liées à une question existante. Stocke dans le bucket
// privé "question-attachments" et persiste les métadonnées dans la
// table question_attachments.
// =====================================================================

import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/lib/admin-guard";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";
export const maxDuration = 60;

const BUCKET = "question-attachments";
const MAX_BYTES = 15 * 1024 * 1024; // 15 MB

const KIND_BY_MIME: Record<string, "image" | "pdf" | "document" | "other"> = {
  "application/pdf": "pdf",
  "image/png": "image",
  "image/jpeg": "image",
  "image/webp": "image",
  "image/gif": "image",
  "image/svg+xml": "image",
  "application/msword": "document",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
    "document",
  "application/vnd.ms-excel": "document",
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
    "document",
  "text/plain": "document",
  "text/csv": "document",
};

export async function POST(
  req: NextRequest,
  { params }: { params: { id: string } },
) {
  try {
    const { supabase, admin } = await requireAdmin();
    const questionId = params.id;

    // Vérifie que la question existe
    const { data: q, error: qErr } = await supabase
      .from("question_bank")
      .select("id")
      .eq("id", questionId)
      .single();
    if (qErr || !q) {
      return NextResponse.json({ error: "question_not_found" }, { status: 404 });
    }

    const form = await req.formData();
    const file = form.get("file");
    const label = ((form.get("label") as string) ?? "").trim() || null;

    if (!(file instanceof File)) {
      return NextResponse.json({ error: "no_file" }, { status: 400 });
    }
    if (file.size > MAX_BYTES) {
      return NextResponse.json(
        { error: "file_too_large", limit: MAX_BYTES },
        { status: 413 },
      );
    }
    if (file.size === 0) {
      return NextResponse.json({ error: "empty_file" }, { status: 400 });
    }

    const kind = KIND_BY_MIME[file.type] ?? "other";

    // Upload dans Storage
    const safeName = (file.name || "annexe")
      .replace(/[^a-zA-Z0-9._-]/g, "_")
      .slice(0, 100);
    const storagePath = `${questionId}/${Date.now()}-${safeName}`;

    const buffer = Buffer.from(await file.arrayBuffer());
    const { error: upErr } = await supabase.storage
      .from(BUCKET)
      .upload(storagePath, buffer, {
        contentType: file.type || "application/octet-stream",
        upsert: false,
      });
    if (upErr) {
      return NextResponse.json(
        { error: "upload_failed", details: upErr.message },
        { status: 500 },
      );
    }

    // Insère la row
    const { data: row, error: insErr } = await supabase
      .from("question_attachments")
      .insert({
        question_id: questionId,
        storage_path: storagePath,
        file_name: file.name || safeName,
        mime_type: file.type || "application/octet-stream",
        size_bytes: file.size,
        kind,
        label,
        created_by: admin.id,
      })
      .select("id, file_name, mime_type, size_bytes, kind, label, created_at")
      .single();

    if (insErr) {
      // Nettoie le fichier Storage si l'insert a échoué
      await supabase.storage.from(BUCKET).remove([storagePath]);
      return NextResponse.json({ error: insErr.message }, { status: 500 });
    }

    // Génère une signed URL immédiatement utilisable
    const { data: signed } = await supabase.storage
      .from(BUCKET)
      .createSignedUrl(storagePath, 60 * 60);

    return NextResponse.json({
      ok: true,
      attachment: {
        ...row,
        signedUrl: signed?.signedUrl ?? null,
      },
    });
  } catch (e: any) {
    return NextResponse.json(
      { error: e?.message ?? "unknown_error" },
      { status: 500 },
    );
  }
}

export async function DELETE(
  req: NextRequest,
  { params }: { params: { id: string } },
) {
  try {
    const { supabase } = await requireAdmin();
    const questionId = params.id;

    const { searchParams } = new URL(req.url);
    const attachmentId = searchParams.get("attachmentId");
    if (!attachmentId) {
      return NextResponse.json(
        { error: "attachment_id_required" },
        { status: 400 },
      );
    }

    // Charge l'attachement pour récupérer le path Storage
    const { data: att, error: selErr } = await supabase
      .from("question_attachments")
      .select("id, storage_path")
      .eq("id", attachmentId)
      .eq("question_id", questionId)
      .single();
    if (selErr || !att) {
      return NextResponse.json(
        { error: "attachment_not_found" },
        { status: 404 },
      );
    }

    // Supprime d'abord la row (CASCADE n'agit pas sur Storage)
    const { error: delErr } = await supabase
      .from("question_attachments")
      .delete()
      .eq("id", attachmentId);
    if (delErr) {
      return NextResponse.json({ error: delErr.message }, { status: 500 });
    }

    // Best-effort : supprime le fichier Storage. Si ça rate, on log
    // mais on renvoie OK puisque la row DB est déjà partie.
    const { error: rmErr } = await supabase.storage
      .from(BUCKET)
      .remove([att.storage_path]);
    if (rmErr) {
      // eslint-disable-next-line no-console
      console.warn("[attachments] suppression Storage échouée :", rmErr.message);
    }

    return NextResponse.json({ ok: true });
  } catch (e: any) {
    return NextResponse.json(
      { error: e?.message ?? "unknown_error" },
      { status: 500 },
    );
  }
}
