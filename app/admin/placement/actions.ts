"use server";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import { z } from "zod";
import { revalidatePath } from "next/cache";
import { placementQuestionSchema } from "@/lib/validations";

// Le superRefine du schéma fait déjà la validation cohérente entre qtype/choices
// et correct_index. Plus besoin de normalize() séparé.

const createSchema = placementQuestionSchema;
// Pour l'update, on accepte des partiels ; on enlève le superRefine en
// repartant des champs raw + on rajoute l'id.
const updateSchema = z.object({
  id: z.string().uuid(),
  bloc_id: z.number().int().positive().optional(),
  qtype: z.enum(["qcm", "qr", "image"]).optional(),
  formation_slug: z.string().trim().optional(),
  prompt: z.string().trim().min(1).max(1000).optional(),
  choices: z.array(z.string().trim().max(300)).max(6).optional(),
  correct_index: z.number().int().min(0).max(5).optional(),
  expected_answer: z.string().trim().max(2000).nullable().optional(),
  image_url: z.string().url().max(2000).nullable().optional(),
  difficulty: z.enum(["facile", "standard", "difficile"]).optional(),
  order: z.number().int().min(0).optional(),
  active: z.boolean().optional(),
});

async function resolveFormationIdPlacement(
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

export async function createPlacementQuestion(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(createSchema, raw);

  const formationId = await resolveFormationIdPlacement(
    supabase,
    data.formation_slug
  );

  const { formation_slug, ...rest } = data;
  const { data: row, error } = await supabase
    .from("placement_questions")
    .insert({ ...rest, formation_id: formationId })
    .select("id")
    .single();
  if (error) throw new Error(error.message);
  await auditLog("create_placement_question", "placement_question", row.id, {
    qtype: data.qtype,
    formation_slug: data.formation_slug,
  });
  revalidatePath("/admin/placement");
  return { id: row.id };
}

export async function updatePlacementQuestion(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(updateSchema, raw);
  const { id, formation_slug, ...patch } = data as any;

  const updateBody: Record<string, any> = { ...patch };
  if (formation_slug) {
    updateBody.formation_id = await resolveFormationIdPlacement(
      supabase,
      formation_slug
    );
  }

  const { error } = await supabase
    .from("placement_questions")
    .update(updateBody)
    .eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("update_placement_question", "placement_question", id);
  revalidatePath("/admin/placement");
  return { ok: true };
}

export async function deletePlacementQuestion(id: string) {
  const { supabase } = await requireAdmin();
  if (!/^[0-9a-f-]{36}$/i.test(id)) throw new Error("id invalide");
  const { error } = await supabase.from("placement_questions").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("delete_placement_question", "placement_question", id);
  revalidatePath("/admin/placement");
  return { ok: true };
}

export async function togglePlacementQuestion(id: string, active: boolean) {
  const { supabase } = await requireAdmin();
  if (!/^[0-9a-f-]{36}$/i.test(id)) throw new Error("id invalide");
  const { error } = await supabase
    .from("placement_questions")
    .update({ active })
    .eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("toggle_placement_question", "placement_question", id, { active });
  revalidatePath("/admin/placement");
  return { ok: true };
}
