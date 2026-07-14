"use server";

import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";

export async function createOrganization(formData: FormData) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");

  const name = String(formData.get("name") ?? "").trim();
  const legal_name = String(formData.get("legal_name") ?? "").trim();
  const siret = String(formData.get("siret") ?? "").trim();
  const billing_email = String(formData.get("billing_email") ?? "").trim();
  const contact_full_name = String(formData.get("contact_full_name") ?? "").trim();
  const contact_email = String(formData.get("contact_email") ?? "").trim();

  if (!name || !billing_email) {
    return { ok: false, error: "Nom et email de facturation requis" };
  }

  // Trouve le user_id du contact via l'email (s'il existe)
  let contactUserId: string | null = null;
  if (contact_email) {
    const { data: contactProfile } = await supabase
      .from("profiles")
      .select("id")
      .eq("email", contact_email)
      .maybeSingle();
    contactUserId = contactProfile?.id ?? null;
  }

  const { data: orgId, error } = await supabase.rpc("admin_create_organization", {
    p_name: name,
    p_legal_name: legal_name,
    p_siret: siret,
    p_billing_email: billing_email,
    p_contact_full_name: contact_full_name,
    p_contact_user_id: contactUserId,
    p_slug: null,
  });

  if (error) {
    return { ok: false, error: error.message };
  }

  redirect(`/admin/organizations/${orgId}`);
}
