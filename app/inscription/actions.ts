"use server";
import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { enrollmentRequestSchema, formatZodError } from "@/lib/validations";
import { sendEmail, enrollmentReceivedEmail } from "@/lib/email";
import { isPackSlug, isPackAvailableForFormation } from "@/lib/packs";

export async function submitEnrollmentRequest(formData: FormData) {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const formationSlug = (formData.get("formation_slug") as string) || null;

  // Pack : pré-rempli depuis /tarifs ou choisi dans le picker /inscription.
  // Validation défensive : on n'accepte qu'un slug connu ET valide pour la
  // formation (Capacité ≤ 3,5 t → Initial uniquement).
  const rawPack = (formData.get("pack_slug") as string) || "";
  let packSlug: "initial" | "medium" | "premium" | null = null;
  if (isPackSlug(rawPack)) {
    if (!formationSlug || isPackAvailableForFormation(rawPack, formationSlug)) {
      packSlug = rawPack;
    }
  }

  const payload = {
    full_name: String(formData.get("full_name") ?? ""),
    email: String(formData.get("email") ?? ""),
    phone: (formData.get("phone") as string) || null,
    funding_kind: String(formData.get("funding_kind") ?? "auto") as any,
    message: (formData.get("message") as string) || null,
    pack_slug: packSlug,
  };
  const parsed = enrollmentRequestSchema.safeParse(payload);
  if (!parsed.success) throw new Error(formatZodError(parsed.error));

  const { error } = await supabase.from("enrollment_requests").insert({
    ...parsed.data,
    formation_slug: formationSlug,
    user_id: user?.id ?? null,
  });
  if (error) throw new Error(error.message);

  // Email d'accusé de réception (fire-and-forget côté UX)
  const tmpl = enrollmentReceivedEmail({ fullName: parsed.data.full_name });
  sendEmail({ to: parsed.data.email, ...tmpl }).catch(() => undefined);

  revalidatePath("/inscription");
}
