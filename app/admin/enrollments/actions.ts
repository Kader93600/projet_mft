"use server";
import { revalidatePath } from "next/cache";
import { requireAdmin, auditLog, validate } from "@/lib/admin-guard";
import {
  funderSchema,
  enrollmentSchema,
  paymentSchema,
} from "@/lib/validations";

// ---- Funders ----
export async function createFunder(formData: FormData) {
  const { service: supabase } = await requireAdmin();
  const data = validate(funderSchema, {
    name: formData.get("name"),
    kind: formData.get("kind"),
    contact_email: formData.get("contact_email") || null,
    contact_phone: formData.get("contact_phone") || null,
    siret: formData.get("siret") || null,
    portal_user_id: (formData.get("portal_user_id") as string) || null,
    notes: formData.get("notes") || null,
  });
  const clean: any = { ...data };
  if (clean.contact_email === "") clean.contact_email = null;
  const { data: row, error } = await supabase
    .from("funders")
    .insert(clean)
    .select("id")
    .single();
  if (error) throw new Error(error.message);
  await auditLog("funder_create", "funder", row.id, { name: data.name });
  revalidatePath("/admin/enrollments");
}

export async function updateFunder(id: string, formData: FormData) {
  const { service: supabase } = await requireAdmin();
  const data = validate(funderSchema, {
    name: formData.get("name"),
    kind: formData.get("kind"),
    contact_email: formData.get("contact_email") || null,
    contact_phone: formData.get("contact_phone") || null,
    siret: formData.get("siret") || null,
    portal_user_id: (formData.get("portal_user_id") as string) || null,
    notes: formData.get("notes") || null,
  });
  const clean: any = { ...data };
  if (clean.contact_email === "") clean.contact_email = null;
  const { error } = await supabase.from("funders").update(clean).eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("funder_update", "funder", id, data);
  revalidatePath("/admin/enrollments");
}

export async function deleteFunder(id: string) {
  const { service: supabase } = await requireAdmin();
  const { error } = await supabase.from("funders").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("funder_delete", "funder", id);
  revalidatePath("/admin/enrollments");
}

// ---- Enrollments ----
export async function upsertEnrollment(formData: FormData) {
  const { service: supabase } = await requireAdmin();
  const id = (formData.get("id") as string) || null;
  // Pack + formation : optionnels (le DEFAULT côté DB est 'initial').
  // Si le formulaire ne les envoie pas, on les omet du payload (laisse DB).
  const rawPack = (formData.get("pack") as string) || "";
  const rawFormationId = (formData.get("formation_id") as string) || "";
  const payload: any = {
    user_id: formData.get("user_id"),
    funder_id: (formData.get("funder_id") as string) || null,
    funding_kind: formData.get("funding_kind"),
    session_label: (formData.get("session_label") as string) || null,
    start_date: (formData.get("start_date") as string) || null,
    end_date: (formData.get("end_date") as string) || null,
    total_amount_cents: Math.round(
      Number(formData.get("total_amount_euros") ?? 0) * 100
    ),
    status: formData.get("status"),
    contract_url: (formData.get("contract_url") as string) || null,
    convention_url: (formData.get("convention_url") as string) || null,
    cpf_dossier_ref: (formData.get("cpf_dossier_ref") as string) || null,
  };
  if (rawPack === "initial" || rawPack === "medium" || rawPack === "premium") {
    payload.pack = rawPack;
  }
  if (rawFormationId) {
    payload.formation_id = rawFormationId;
  }
  const data = validate(enrollmentSchema, payload);
  const clean: any = { ...data };
  if (clean.contract_url === "") clean.contract_url = null;
  if (clean.convention_url === "") clean.convention_url = null;
  if (clean.start_date === "") clean.start_date = null;
  if (clean.end_date === "") clean.end_date = null;

  // Récupère l'ancien pack avant update pour l'audit + détection de changement
  let previousPack: string | null = null;
  if (id) {
    const { data: prev } = await supabase
      .from("enrollments")
      .select("pack")
      .eq("id", id)
      .single();
    previousPack = prev?.pack ?? null;
  }

  if (id) {
    const { error } = await supabase.from("enrollments").update(clean).eq("id", id);
    if (error) {
      // Erreur trigger : Capacité ≤ 3,5 t avec pack ≠ initial
      if (
        error.message.includes("Capacité") ||
        error.message.includes("capacite")
      ) {
        throw new Error(
          "Pack non disponible pour la formation Capacité ≤ 3,5 t (seul Initial est autorisé).",
        );
      }
      throw new Error(error.message);
    }
    await auditLog("enrollment_update", "enrollment", id, {
      pack_changed: previousPack !== (clean.pack ?? previousPack),
      previous_pack: previousPack,
      new_pack: clean.pack ?? previousPack,
    });
  } else {
    const { data: row, error } = await supabase
      .from("enrollments")
      .insert(clean)
      .select("id")
      .single();
    if (error) {
      if (
        error.message.includes("Capacité") ||
        error.message.includes("capacite")
      ) {
        throw new Error(
          "Pack non disponible pour la formation Capacité ≤ 3,5 t (seul Initial est autorisé).",
        );
      }
      throw new Error(error.message);
    }
    await auditLog("enrollment_create", "enrollment", row.id, {
      pack: clean.pack,
    });
  }
  revalidatePath("/admin/enrollments");
  revalidatePath("/inscription");
  revalidatePath("/dashboard");
}

export async function deleteEnrollment(id: string) {
  // Mutation sensible : on passe par service_role pour bypass RLS
  // (les policies enrollments_* retournent 0 ligne pour les super_admin
  // dans certains contextes, ce qui fait échouer le DELETE silencieusement).
  // requireAdmin() vérifie l'autorisation côté code en amont.
  const { service } = await requireAdmin();
  const { error } = await service.from("enrollments").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("enrollment_delete", "enrollment", id);
  revalidatePath("/admin/enrollments");
}

// ---- Payments ----
export async function upsertPayment(formData: FormData) {
  const { service: supabase } = await requireAdmin();
  const id = (formData.get("id") as string) || null;
  const data = validate(paymentSchema, {
    enrollment_id: formData.get("enrollment_id"),
    due_date: formData.get("due_date"),
    amount_cents: Math.round(Number(formData.get("amount_euros") ?? 0) * 100),
    paid_at: (formData.get("paid_at") as string) || null,
    paid_amount_cents: Math.round(
      Number(formData.get("paid_amount_euros") ?? 0) * 100
    ),
    method: (formData.get("method") as string) || null,
    reference: (formData.get("reference") as string) || null,
    notes: (formData.get("notes") as string) || null,
  });
  const clean: any = { ...data };
  if (clean.paid_at === "") clean.paid_at = null;
  if (id) {
    const { error } = await supabase.from("payment_schedule").update(clean).eq("id", id);
    if (error) throw new Error(error.message);
  } else {
    const { error } = await supabase.from("payment_schedule").insert(clean);
    if (error) throw new Error(error.message);
  }
  await auditLog("payment_upsert", "payment", id ?? "new");
  revalidatePath("/admin/enrollments");
}

export async function deletePayment(id: string) {
  const { service: supabase } = await requireAdmin();
  const { error } = await supabase.from("payment_schedule").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("payment_delete", "payment", id);
  revalidatePath("/admin/enrollments");
}

// ---- Leads (enrollment_requests) ----
type RequestStatus = "nouveau" | "contacte" | "devis_envoye" | "inscrit" | "refuse";

export async function setRequestStatus(id: string, status: RequestStatus) {
  const { service: supabase } = await requireAdmin();
  const { error } = await supabase
    .from("enrollment_requests")
    .update({ status })
    .eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("lead_status", "enrollment_request", id, { status });
  revalidatePath("/admin/enrollments");
}

export async function deleteEnrollmentRequest(id: string) {
  const { service: supabase } = await requireAdmin();
  const { error } = await supabase
    .from("enrollment_requests")
    .delete()
    .eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("lead_delete", "enrollment_request", id);
  revalidatePath("/admin/enrollments");
}

// ---- Enrollment status (changement rapide depuis la liste) ----
type EnrollmentStatus =
  | "prospect"
  | "devis"
  | "accord_financeur"
  | "a_payer"
  | "en_cours"
  | "termine"
  | "abandon"
  | "refuse";

export async function setEnrollmentStatus(id: string, status: EnrollmentStatus) {
  const { service: supabase } = await requireAdmin();
  const { error } = await supabase
    .from("enrollments")
    .update({ status })
    .eq("id", id);
  if (error) throw new Error(error.message);
  await auditLog("enrollment_status", "enrollment", id, { status });
  revalidatePath("/admin/enrollments");
}
