"use server";
import { createClient } from "@/lib/supabase/server";
import { headers } from "next/headers";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const acceptSchema = z.object({
  document_id: z.string().uuid(),
  signature_name: z.string().trim().min(2).max(120).optional(),
});

export async function acceptDocument(raw: unknown) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const res = acceptSchema.safeParse(raw);
  if (!res.success) throw new Error("Données invalides");

  const h = await headers();
  const ua = h.get("user-agent") ?? null;
  // IP client : 1er maillon de x-forwarded-for (Vercel), sinon x-real-ip.
  const ip =
    h.get("x-forwarded-for")?.split(",")[0]?.trim() ||
    h.get("x-real-ip") ||
    null;

  const { error } = await supabase.rpc("accept_document", {
    p_document_id: res.data.document_id,
    p_user_agent: ua,
    p_ip: ip,
    p_signature_name: res.data.signature_name ?? null,
  });
  if (error) throw new Error(error.message);
  revalidatePath("/onboarding");
  revalidatePath("/dashboard");
  revalidatePath("/mes-documents");
  return { ok: true };
}

const selectFormationSchema = z.object({
  slug: z.string().min(1),
});

export async function selectFormation(raw: unknown) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const res = selectFormationSchema.safeParse(raw);
  if (!res.success) throw new Error("Formation invalide");

  // Vérifier que la formation existe en BDD
  const { data: formation, error: fErr } = await supabase
    .from("formations")
    .select("id, slug, active")
    .eq("slug", res.data.slug)
    .maybeSingle();
  if (fErr) throw new Error(fErr.message);
  if (!formation) throw new Error("Formation introuvable");
  if (formation.active === false) throw new Error("Formation inactive");

  // Insert idempotent (vérifie l'existant)
  const { data: existing } = await supabase
    .from("enrollments")
    .select("id")
    .eq("user_id", user.id)
    .eq("formation_slug", formation.slug)
    .maybeSingle();

  if (!existing) {
    const { error: eErr } = await supabase.from("enrollments").insert({
      user_id: user.id,
      formation_slug: formation.slug,
      formation_id: formation.id,
      status: "en_cours",
      session_label: `onboarding-${formation.slug}-${Date.now()}`,
    });
    if (eErr) throw new Error(eErr.message);
  }

  revalidatePath("/onboarding");
  revalidatePath("/dashboard");
  return { ok: true, slug: formation.slug };
}

export async function completeOnboarding() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const { error } = await supabase
    .from("profiles")
    .update({ onboarding_completed_at: new Date().toISOString() })
    .eq("id", user.id);
  if (error) throw new Error(error.message);

  revalidatePath("/dashboard");
  return { ok: true };
}
