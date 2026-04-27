"use server";
import { requireAdmin, auditLog } from "@/lib/admin-guard";
import { z } from "zod";
import { revalidatePath } from "next/cache";

const docUpdateSchema = z.object({
  id: z.string().uuid(),
  title: z.string().trim().min(1).max(200),
  content_md: z.string().max(100_000),
  published: z.boolean(),
  bump_version: z.boolean().optional(),
});

export async function updateDocument(raw: unknown) {
  const { supabase, admin } = await requireAdmin();
  const res = docUpdateSchema.safeParse(raw);
  if (!res.success) throw new Error("Données invalides");
  const { id, title, content_md, published, bump_version } = res.data;

  const { data: current } = await supabase
    .from("onboarding_documents")
    .select("version, type")
    .eq("id", id)
    .single();
  if (!current) throw new Error("Document introuvable");

  const patch: any = {
    title,
    content_md,
    published,
    updated_at: new Date().toISOString(),
    updated_by: admin.id,
  };
  if (bump_version) patch.version = current.version + 1;

  const { error } = await supabase
    .from("onboarding_documents")
    .update(patch)
    .eq("id", id);
  if (error) throw new Error(error.message);

  await auditLog(
    bump_version ? "publish_document_new_version" : "update_document",
    "onboarding_document",
    id,
    { type: current.type, published }
  );
  revalidatePath("/admin/settings/documents");
  return { ok: true, newVersion: bump_version ? current.version + 1 : current.version };
}
