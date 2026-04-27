"use server";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import { z } from "zod";
import { revalidatePath } from "next/cache";
import { glossaryTermSchema } from "@/lib/validations";

const updateSchema = glossaryTermSchema.extend({ id: z.string().uuid() });

export async function createGlossaryTerm(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(glossaryTermSchema, raw);
  const { data: row, error } = await supabase
    .from("glossary_terms")
    .insert({
      ...data,
      synonyms: data.synonyms ?? [],
      bloc_id: data.bloc_id ?? null,
    })
    .select("id")
    .single();
  if (error) throw new Error(error.message);
  await auditLog("create_glossary_term", "glossary_term", row.id);
  revalidatePath("/admin/glossary");
  revalidatePath("/glossaire");
  return { id: row.id };
}

export async function updateGlossaryTerm(raw: unknown) {
  const { supabase } = await requireAdmin();
  const data = validate(updateSchema, raw);
  const { id, ...patch } = data as any;
  const { error } = await supabase
    .from("glossary_terms")
    .update({ ...patch, bloc_id: patch.bloc_id ?? null, synonyms: patch.synonyms ?? [] })
    .eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("update_glossary_term", "glossary_term", id);
  revalidatePath("/admin/glossary");
  revalidatePath("/glossaire");
  return { ok: true };
}

export async function deleteGlossaryTerm(id: string) {
  const { supabase } = await requireAdmin();
  if (!/^[0-9a-f-]{36}$/i.test(id)) throw new Error("id invalide");
  const { error } = await supabase.from("glossary_terms").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("delete_glossary_term", "glossary_term", id);
  revalidatePath("/admin/glossary");
  revalidatePath("/glossaire");
  return { ok: true };
}
