"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin, auditLog, validate } from "@/lib/admin-guard";
import { a11yAdminUpdateSchema } from "@/lib/validations";

export async function updateA11yRequest(id: string, formData: FormData) {
  const { supabase, admin } = await requireAdmin();
  const data = validate(a11yAdminUpdateSchema, {
    status: String(formData.get("status") ?? ""),
    admin_response: (formData.get("admin_response") as string) || null,
  });
  const patch: any = { ...data, referent_id: admin.id };
  const { error } = await supabase
    .from("accessibility_requests")
    .update(patch)
    .eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("a11y_request_update", "accessibility_request", id, data);
  revalidatePath("/admin/accessibilite");
}
