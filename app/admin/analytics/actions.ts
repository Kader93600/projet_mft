"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin, validate, auditLog } from "@/lib/admin-guard";
import { uuid } from "@/lib/validations";

export async function deleteAttempt(id: string) {
  const { supabase } = await requireAdmin();
  validate(uuid, id);
  // Le trigger SQL log_attempt_deletion alimente audit_log automatiquement
  const { error } = await supabase.from("quiz_attempts").delete().eq("id", id);
  if (error) throw new Error(error.message);
  revalidatePath("/admin/analytics");
  return { ok: true };
}

export async function resetQuizResults(quizId: string) {
  const { supabase } = await requireAdmin();
  validate(uuid, quizId);
  const { error } = await supabase
    .from("quiz_attempts")
    .delete()
    .eq("quiz_id", quizId);
  if (error) throw new Error(error.message);
  await auditLog("reset_quiz_results", "quiz", quizId);
  revalidatePath("/admin/analytics");
  return { ok: true };
}

export async function resetAllResults() {
  const { supabase } = await requireAdmin();
  const { error: e1 } = await supabase
    .from("quiz_attempts")
    .delete()
    .not("id", "is", null);
  const { error: e2 } = await supabase
    .from("lesson_progress")
    .delete()
    .not("id", "is", null);
  if (e1 || e2) throw new Error((e1 || e2)!.message);
  await auditLog("reset_all_results", "system", "all");
  revalidatePath("/admin/analytics");
  return { ok: true };
}
