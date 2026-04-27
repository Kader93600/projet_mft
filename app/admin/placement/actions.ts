"use server";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import { z } from "zod";
import { revalidatePath } from "next/cache";
import { placementQuestionSchema } from "@/lib/validations";

const createSchema = placementQuestionSchema;
const updateSchema = placementQuestionSchema.extend({ id: z.string().uuid() });

function normalize(data: z.infer<typeof placementQuestionSchema>) {
  if (data.correct_index >= data.choices.length) {
    throw new Error("L'index de la bonne réponse dépasse le nombre de choix");
  }
  return data;
}

export async function createPlacementQuestion(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = normalize(validate(createSchema, raw));
  const { data: row, error } = await supabase
    .from("placement_questions")
    .insert(data)
    .select("id")
    .single();
  if (error) throw new Error(error.message);
  await auditLog("create_placement_question", "placement_question", row.id);
  revalidatePath("/admin/placement");
  return { id: row.id };
}

export async function updatePlacementQuestion(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = normalize(validate(updateSchema, raw) as any);
  const { id, ...patch } = data as any;
  const { error } = await supabase
    .from("placement_questions")
    .update(patch)
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
