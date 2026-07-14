"use server";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
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
import type { Tables } from "@/lib/database.types";

/** Client Supabase serveur (session utilisateur, RLS appliquée). */
type ServerSupabase = ReturnType<typeof createClient>;

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
  supabase: ServerSupabase,
  slug: string
): Promise<string> {
  const { data, error } = await supabase
    .from("formations")
    .select("id")
    .eq("slug", slug)
    .maybeSingle();
  if (error) throw new Error(error.message);
  const formation: Pick<Tables<"formations">, "id"> | null = data;
  if (!formation) throw new Error(`Formation "${slug}" introuvable`);
  return formation.id;
}

/**
 * Récupère le slug de la formation actuellement liée à un module.
 * Utilisé pour vérifier l'habilitation trainer avant update/delete.
 */
async function getModuleFormationSlug(
  supabase: ServerSupabase,
  moduleId: string
): Promise<string | null> {
  // `overrideTypes` : le client n'étant pas câblé sur `Database`, supabase-js
  // infère l'embed to-one `formations` comme un tableau. PostgREST renvoie
  // bien un objet ici (FK simple) — override purement compile-time.
  const { data: row } = await supabase
    .from("formation_modules")
    .select("formation:formations(slug)")
    .eq("module_id", moduleId)
    .limit(1)
    .maybeSingle()
    .overrideTypes<
      { formation: Pick<Tables<"formations">, "slug"> | null },
      { merge: false }
    >();
  return row?.formation?.slug ?? null;
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
  await requireStaffOrFormationTrainer(currentSlug || "");

  // ⚠️ Supprimer un module CASCADE vers ses quizzes (quizzes.module_id ON
  // DELETE CASCADE), mais quiz_attempts.quiz_id est en RESTRICT (audit #15).
  // Sans nettoyage, la suppression d'un module dont les quiz ont des
  // tentatives échoue. On retire donc d'abord les tentatives des quiz du
  // module (qr_responses cascade dessus). Service_role : tentatives d'autres
  // utilisateurs (RLS sinon bloquante).
  const service = createAdminClient();
  const { data: quizzes } = await service
    .from("quizzes")
    .select("id")
    .eq("module_id", id);
  const quizIds = (quizzes ?? []).map((q: { id: string }) => q.id);
  if (quizIds.length > 0) {
    const { error: attErr } = await service
      .from("quiz_attempts")
      .delete()
      .in("quiz_id", quizIds);
    if (attErr) throw new Error(attErr.message);
  }

  const { error } = await service.from("modules").delete().eq("id", id);
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
  const { id, ...patch } = data;
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

/**
 * Upload d'un fichier (image/document) dans le bucket content-media.
 * Ouvert au staff (admin/super_admin) ET aux trainers (la délimitation
 * par formation se fait au niveau du module/quiz qui consomme l'URL).
 *
 * Validation stricte côté serveur (type, taille, extension) + rate limit.
 */
export async function uploadMedia(formData: FormData) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  // Vérifier que c'est un acteur pédagogique (staff OU trainer)
  const { data: profile } = await supabase
    .from("profiles")
    .select("id, role, disabled")
    .eq("id", user.id)
    .single();
  if (!profile) throw new Error("Profil introuvable");
  if (profile.disabled) throw new Error("Compte désactivé");
  const isStaffOrTrainer =
    profile.role === "admin" ||
    profile.role === "super_admin" ||
    profile.role === "trainer";
  if (!isStaffOrTrainer) throw new Error("Accès refusé");

  // Rate limit : 30 uploads / minute / user
  const rl = rateLimit(`upload:${profile.id}`, 30, 60_000);
  if (!rl.allowed) {
    throw new Error(
      `Trop d'uploads. Réessayez dans ${Math.ceil(rl.retryInMs / 1000)}s.`
    );
  }

  const file = formData.get("file") as File | null;
  if (!file) throw new Error("Aucun fichier");

  // Validation stricte type/taille/extension
  const ext = validateUpload(file);

  // Préfixe optionnel pour ranger les uploads par contexte
  // (ex. 'modules/abc-id/cover')
  const prefix = (formData.get("prefix") as string | null) || "content";
  const safePrefix = prefix
    .replace(/[^a-z0-9-_/]/gi, "_")
    .replace(/^\/+|\/+$/g, "")
    .slice(0, 100);

  const name = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}.${ext}`;
  const path = `${safePrefix}/${name}`;
  const { error } = await supabase.storage
    .from("content-media")
    .upload(path, file, { contentType: file.type, upsert: false });
  if (error) throw new Error(error.message);
  const { data } = supabase.storage.from("content-media").getPublicUrl(path);
  await auditLog("upload_media", "file", path, {
    size: file.size,
    type: file.type,
    prefix: safePrefix,
  });
  return { url: data.publicUrl, path };
}

/**
 * Supprime un fichier précédemment uploadé. Le path vient de uploadMedia.
 */
export async function deleteMedia(path: string) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const { data: profile } = await supabase
    .from("profiles")
    .select("id, role, disabled")
    .eq("id", user.id)
    .single();
  if (!profile) throw new Error("Profil introuvable");
  if (profile.disabled) throw new Error("Compte désactivé");
  const isStaffOrTrainer =
    profile.role === "admin" ||
    profile.role === "super_admin" ||
    profile.role === "trainer";
  if (!isStaffOrTrainer) throw new Error("Accès refusé");

  if (!path || typeof path !== "string") throw new Error("Path invalide");
  // Empêche les évasions / chemins absolus
  if (path.includes("..") || path.startsWith("/")) {
    throw new Error("Path invalide");
  }

  const { error } = await supabase.storage.from("content-media").remove([path]);
  if (error) throw new Error(error.message);
  await auditLog("delete_media", "file", path);
  return { ok: true };
}
