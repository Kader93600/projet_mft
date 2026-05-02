"use server";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import {
  requireAdmin,
  requireStaffOrFormationTrainer,
  validate,
  auditLog,
  rateLimit,
} from "@/lib/admin-guard";
import {
  moduleCreateSchema,
  moduleUpdateSchema,
  lessonCreateSchema,
  lessonUpdateSchema,
  lessonResourceSchema,
  validateUpload,
} from "@/lib/validations";
import { z } from "zod";

function slugify(s: string) {
  return s
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80);
}

// ---------------- MODULES ----------------

/**
 * Récupère l'id de la formation à partir du slug.
 * Lève si introuvable — la création de module exige une formation valide.
 */
async function resolveFormationId(
  supabase: any,
  slug: string
): Promise<string> {
  const { data, error } = await supabase
    .from("formations")
    .select("id")
    .eq("slug", slug)
    .maybeSingle();
  if (error) throw new Error(error.message);
  if (!data) throw new Error(`Formation "${slug}" introuvable`);
  return data.id;
}

/**
 * Récupère le slug de la formation actuellement liée à un module.
 * Utilisé pour vérifier l'habilitation trainer avant update/delete.
 */
async function getModuleFormationSlug(
  supabase: any,
  moduleId: string
): Promise<string | null> {
  const { data } = await supabase
    .from("formation_modules")
    .select("formation:formations(slug)")
    .eq("module_id", moduleId)
    .limit(1)
    .maybeSingle();
  return (data?.formation as any)?.slug ?? null;
}

export async function createModule(raw: unknown) {
  // Validation d'abord pour récupérer formation_slug (gating)
  const data = validate(moduleCreateSchema, raw);
  const { supabase } = await requireStaffOrFormationTrainer(data.formation_slug);
  const slug = data.slug || slugify(data.title);

  // 1) Vérifier la formation cible AVANT de créer le module (transactionnel)
  const formationId = await resolveFormationId(supabase, data.formation_slug);

  // 2) Créer le module
  const { formation_slug, ...moduleData } = data;
  const { data: created, error } = await supabase
    .from("modules")
    .insert({ ...moduleData, slug })
    .select()
    .single();
  if (error) throw new Error(error.message);

  // 3) Lier le module à la formation
  const { error: linkErr } = await supabase
    .from("formation_modules")
    .insert({ formation_id: formationId, module_id: created.id });
  if (linkErr) {
    // Best-effort : on supprime le module créé pour ne pas laisser un orphelin
    await supabase.from("modules").delete().eq("id", created.id);
    throw new Error(`Lien formation impossible : ${linkErr.message}`);
  }

  await auditLog("create_module", "module", created.id, {
    title: data.title,
    formation_slug: data.formation_slug,
  });
  revalidatePath("/admin/modules");
  redirect(`/admin/modules/${created.id}`);
}

export async function updateModule(id: string, raw: unknown) {
  const patch = validate(moduleUpdateSchema, raw);
  const { formation_slug, ...modulePatch } = patch;

  // Récupérer le slug actuellement lié au module (pour le gating trainer)
  const sbRead = createClient();
  const currentSlug = await getModuleFormationSlug(sbRead, id);
  const slugToCheck = formation_slug || currentSlug || "";
  const { supabase } = await requireStaffOrFormationTrainer(slugToCheck);

  // Mise à jour du module
  if (Object.keys(modulePatch).length > 0) {
    const { error } = await supabase
      .from("modules")
      .update(modulePatch)
      .eq("id", id);
    if (error) throw new Error(error.message);
  }

  // Re-affectation formation si demandé (remplace les liens existants)
  if (formation_slug) {
    const formationId = await resolveFormationId(supabase, formation_slug);
    // Supprimer les liens actuels (un module = une formation principale en règle générale)
    const { error: delErr } = await supabase
      .from("formation_modules")
      .delete()
      .eq("module_id", id);
    if (delErr) throw new Error(delErr.message);
    const { error: insErr } = await supabase
      .from("formation_modules")
      .insert({ formation_id: formationId, module_id: id });
    if (insErr) throw new Error(insErr.message);
  }

  await auditLog("update_module", "module", id, formation_slug ? { formation_slug } : undefined);
  revalidatePath("/admin/modules");
  revalidatePath(`/admin/modules/${id}`);
  return { ok: true };
}

export async function deleteModule(id: string) {
  if (!id || typeof id !== "string") throw new Error("ID invalide");
  // Gating trainer : doit être habilité sur la formation actuelle
  const sbRead = createClient();
  const currentSlug = await getModuleFormationSlug(sbRead, id);
  const { supabase } = await requireStaffOrFormationTrainer(currentSlug || "");
  const { error } = await supabase.from("modules").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("delete_module", "module", id);
  revalidatePath("/admin/modules");
  return { ok: true };
}

// ---------------- LESSONS ----------------

export async function createLesson(raw: unknown) {
  const data = validate(lessonCreateSchema, raw);
  // Gating trainer : il faut être habilité sur la formation du module parent
  const sbRead = createClient();
  const formationSlug = await getModuleFormationSlug(sbRead, data.module_id);
  const { supabase } = await requireStaffOrFormationTrainer(formationSlug || "");
  const slug = data.slug || slugify(data.title);
  const { data: created, error } = await supabase
    .from("lessons")
    .insert({
      module_id: data.module_id,
      title: data.title,
      slug,
      content_md: data.content_md || "# Nouvelle leçon\n\nContenu…",
      summary_md: data.summary_md ?? null,
      order: data.order ?? 0,
      cover_url: data.cover_url ?? null,
    })
    .select()
    .single();
  if (error) throw new Error(error.message);
  await auditLog("create_lesson", "lesson", created.id, { title: data.title });
  revalidatePath(`/admin/modules/${data.module_id}`);
  redirect(`/admin/modules/${data.module_id}/lessons/${created.id}`);
}

export async function updateLesson(id: string, moduleId: string, raw: unknown) {
  const patch = validate(lessonUpdateSchema, raw);
  // Gating trainer : habilitation sur la formation du module parent
  const sbRead = createClient();
  const slug = await getModuleFormationSlug(sbRead, moduleId);
  const { supabase } = await requireStaffOrFormationTrainer(slug || "");
  const { error } = await supabase.from("lessons").update(patch).eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("update_lesson", "lesson", id);
  revalidatePath(`/admin/modules/${moduleId}`);
  revalidatePath(`/admin/modules/${moduleId}/lessons/${id}`);
  return { ok: true };
}

export async function deleteLesson(id: string, moduleId: string) {
  if (!id || !moduleId) throw new Error("ID invalide");
  const sbRead = createClient();
  const slug = await getModuleFormationSlug(sbRead, moduleId);
  const { supabase } = await requireStaffOrFormationTrainer(slug || "");
  const { error } = await supabase.from("lessons").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("delete_lesson", "lesson", id);
  revalidatePath(`/admin/modules/${moduleId}`);
  return { ok: true };
}

// ---------------- LESSON RESOURCES ----------------

export async function createLessonResource(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(lessonResourceSchema, raw);
  const { data: row, error } = await supabase
    .from("lesson_resources")
    .insert(data)
    .select("id, lesson_id")
    .single();
  if (error) throw new Error(error.message);
  await auditLog("create_lesson_resource", "lesson_resource", row.id);
  revalidatePath(`/admin/modules`);
  return { id: row.id };
}

export async function updateLessonResource(raw: unknown) {
  const { supabase } = await requireAdmin();
  const schema = lessonResourceSchema.extend({ id: z.string().uuid() });
  const data = validate(schema, raw);
  const { id, ...patch } = data as any;
  const { error } = await supabase
    .from("lesson_resources")
    .update(patch)
    .eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("update_lesson_resource", "lesson_resource", id);
  return { ok: true };
}

export async function deleteLessonResource(id: string) {
  const { supabase } = await requireAdmin();
  if (!/^[0-9a-f-]{36}$/i.test(id)) throw new Error("id invalide");
  const { error } = await supabase.from("lesson_resources").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("delete_lesson_resource", "lesson_resource", id);
  return { ok: true };
}

// ---------------- STORAGE upload ----------------

export async function uploadMedia(formData: FormData) {
  const { supabase, admin } = await requireAdmin();

  // Rate limit : 30 uploads / minute / admin
  const rl = rateLimit(`upload:${admin.id}`, 30, 60_000);
  if (!rl.allowed) {
    throw new Error(
      `Trop d'uploads. Réessayez dans ${Math.ceil(rl.retryInMs / 1000)}s.`
    );
  }

  const file = formData.get("file") as File | null;
  if (!file) throw new Error("Aucun fichier");

  // Validation stricte type/taille/extension
  const ext = validateUpload(file);

  const name = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}.${ext}`;
  const path = `content/${name}`;
  const { error } = await supabase.storage
    .from("content-media")
    .upload(path, file, { contentType: file.type, upsert: false });
  if (error) throw new Error(error.message);
  const { data } = supabase.storage.from("content-media").getPublicUrl(path);
  await auditLog("upload_media", "file", path, {
    size: file.size,
    type: file.type,
  });
  return { url: data.publicUrl };
}
