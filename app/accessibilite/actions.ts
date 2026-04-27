"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import {
  a11yPrefsSchema,
  a11yRequestSchema,
  formatZodError,
} from "@/lib/validations";

async function requireUser() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");
  return { supabase, user };
}

export async function saveA11yPrefs(formData: FormData) {
  const { supabase, user } = await requireUser();
  const payload = {
    a11y_font_scale: Number(formData.get("a11y_font_scale") ?? 1),
    a11y_dyslexia_font: formData.get("a11y_dyslexia_font") === "on",
    a11y_high_contrast: formData.get("a11y_high_contrast") === "on",
    a11y_reduced_motion: formData.get("a11y_reduced_motion") === "on",
    a11y_underline_links: formData.get("a11y_underline_links") === "on",
    a11y_notes: (formData.get("a11y_notes") as string) || null,
    a11y_rqth: formData.get("a11y_rqth") === "on",
  };
  const parsed = a11yPrefsSchema.safeParse(payload);
  if (!parsed.success) throw new Error(formatZodError(parsed.error));

  const { error } = await supabase
    .from("profiles")
    .update(parsed.data)
    .eq("id", user.id);
  if (error) throw new Error(error.message);
  revalidatePath("/accessibilite");
  revalidatePath("/", "layout");
}

export async function submitA11yRequest(formData: FormData) {
  const { supabase, user } = await requireUser();
  const payload = {
    category: String(formData.get("category") ?? ""),
    description: String(formData.get("description") ?? ""),
    adaptations_requested:
      (formData.get("adaptations_requested") as string) || null,
  };
  const parsed = a11yRequestSchema.safeParse(payload);
  if (!parsed.success) throw new Error(formatZodError(parsed.error));

  const { error } = await supabase
    .from("accessibility_requests")
    .insert({ ...parsed.data, user_id: user.id });
  if (error) throw new Error(error.message);
  revalidatePath("/accessibilite");
}
