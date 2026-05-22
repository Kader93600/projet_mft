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

const docCreateSchema = z.object({
  title: z.string().trim().min(1).max(200),
});

/** Crée un nouveau document d'accueil (brouillon, version 1, contenu vide). */
export async function createDocument(raw: unknown) {
  const { supabase, admin } = await requireAdmin();
  const res = docCreateSchema.safeParse(raw);
  if (!res.success) throw new Error("Titre invalide");
  const title = res.data.title;

  // `type` = identifiant interne unique (l'affichage utilise le titre).
  const slug =
    title
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
      .slice(0, 40) || "document";
  const type = `${slug}-${Date.now().toString(36).slice(-4)}`;

  const { data, error } = await supabase
    .from("onboarding_documents")
    .insert({
      type,
      title,
      content_md: "",
      published: false,
      version: 1,
      updated_by: admin.id,
    })
    .select("id")
    .single();
  if (error) throw new Error(error.message);

  await auditLog("create_document", "onboarding_document", data.id, {
    type,
    title,
  });
  revalidatePath("/admin/settings/documents");
  return { ok: true, id: data.id };
}

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
