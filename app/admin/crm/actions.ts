"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";
import { sendEmail, quoteEmail } from "@/lib/email";
import { renderQuotePdf } from "@/lib/quote-pdf";

async function ensureAdmin() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) throw new Error("Non authentifié");
  const { data: profile } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .maybeSingle();
  if (
    !profile?.role ||
    !["admin", "super_admin"].includes(profile.role)
  ) {
    throw new Error("Réservé aux administrateurs");
  }
  return { supabase, userId: user.id };
}

function bust(leadId: string) {
  revalidatePath("/admin/crm");
  revalidatePath(`/admin/crm/${leadId}`);
}

// ─── Assignation ────────────────────────────────────────────────────

/** Self-assign : l'admin courant "prend" ce lead. */
export async function selfAssignLead(leadId: string) {
  const { supabase } = await ensureAdmin();
  const { error } = await supabase.rpc("crm_self_assign_lead", {
    p_lead_id: leadId,
  });
  if (error) return { ok: false, error: error.message };
  bust(leadId);
  return { ok: true };
}

/** Libère le lead (qui revient en pool). */
export async function unassignLead(leadId: string) {
  const { supabase } = await ensureAdmin();
  const { error } = await supabase.rpc("crm_unassign_lead", {
    p_lead_id: leadId,
  });
  if (error) return { ok: false, error: error.message };
  bust(leadId);
  return { ok: true };
}

// ─── Notes ──────────────────────────────────────────────────────────

const NOTE_KINDS = ["call", "email", "sms", "meeting", "note"] as const;
type NoteKind = (typeof NOTE_KINDS)[number];

export async function addNote(
  leadId: string,
  kind: NoteKind,
  body: string
) {
  const { supabase, userId } = await ensureAdmin();
  if (!NOTE_KINDS.includes(kind)) {
    return { ok: false, error: "Type de note invalide" };
  }
  const trimmed = body.trim();
  if (!trimmed) return { ok: false, error: "Note vide" };
  if (trimmed.length > 5000) {
    return { ok: false, error: "Note trop longue (5000 caractères max)" };
  }
  const { error } = await supabase.from("lead_notes").insert({
    enrollment_request_id: leadId,
    author_id: userId,
    kind,
    body: trimmed,
  });
  if (error) return { ok: false, error: error.message };
  bust(leadId);
  return { ok: true };
}

// ─── Relance / snooze ───────────────────────────────────────────────

/** Planifie la prochaine relance (date dans le futur). */
export async function scheduleFollowup(leadId: string, daysFromNow: number) {
  const { supabase } = await ensureAdmin();
  if (!Number.isFinite(daysFromNow) || daysFromNow < 0 || daysFromNow > 365) {
    return { ok: false, error: "Délai invalide (0-365 jours)" };
  }
  const followupAt = new Date();
  followupAt.setDate(followupAt.getDate() + daysFromNow);
  followupAt.setHours(9, 0, 0, 0); // 9h du matin
  const { error } = await supabase.rpc("crm_schedule_followup", {
    p_lead_id: leadId,
    p_followup_at: followupAt.toISOString(),
  });
  if (error) return { ok: false, error: error.message };
  bust(leadId);
  return { ok: true };
}

/** Reporte le lead à plus tard (snooze) — le retire de la file active. */
export async function snoozeLead(leadId: string, daysFromNow: number) {
  const { supabase } = await ensureAdmin();
  if (!Number.isFinite(daysFromNow) || daysFromNow < 1 || daysFromNow > 365) {
    return { ok: false, error: "Délai invalide (1-365 jours)" };
  }
  const until = new Date();
  until.setDate(until.getDate() + daysFromNow);
  const { error } = await supabase.rpc("crm_snooze_lead", {
    p_lead_id: leadId,
    p_until: until.toISOString(),
  });
  if (error) return { ok: false, error: error.message };
  bust(leadId);
  return { ok: true };
}

/** Annule le snooze (le lead revient en file active). */
export async function unsnoozeLead(leadId: string) {
  const { supabase } = await ensureAdmin();
  const { error } = await supabase
    .from("enrollment_requests")
    .update({ snoozed_until: null })
    .eq("id", leadId);
  if (error) return { ok: false, error: error.message };
  bust(leadId);
  return { ok: true };
}

// ─── Statut ─────────────────────────────────────────────────────────

const STATUSES = [
  "nouveau",
  "contacte",
  "devis_envoye",
  "inscrit",
  "refuse",
] as const;
type LeadStatus = (typeof STATUSES)[number];

export async function updateStatus(leadId: string, status: LeadStatus) {
  const { supabase } = await ensureAdmin();
  if (!STATUSES.includes(status)) {
    return { ok: false, error: "Statut invalide" };
  }
  const { error } = await supabase
    .from("enrollment_requests")
    .update({ status })
    .eq("id", leadId);
  if (error) return { ok: false, error: error.message };
  bust(leadId);
  return { ok: true };
}

// ─── Tags ───────────────────────────────────────────────────────────

export async function addTag(leadId: string, tag: string) {
  const { supabase } = await ensureAdmin();
  const cleaned = tag.trim().toLowerCase();
  if (!cleaned || cleaned.length > 30) {
    return { ok: false, error: "Tag invalide" };
  }
  // Lit l'état actuel
  const { data: row } = await supabase
    .from("enrollment_requests")
    .select("tags")
    .eq("id", leadId)
    .maybeSingle();
  const tags = new Set<string>((row?.tags ?? []) as string[]);
  tags.add(cleaned);
  const { error } = await supabase
    .from("enrollment_requests")
    .update({ tags: Array.from(tags) })
    .eq("id", leadId);
  if (error) return { ok: false, error: error.message };
  bust(leadId);
  return { ok: true };
}

export async function removeTag(leadId: string, tag: string) {
  const { supabase } = await ensureAdmin();
  const { data: row } = await supabase
    .from("enrollment_requests")
    .select("tags")
    .eq("id", leadId)
    .maybeSingle();
  const tags = ((row?.tags ?? []) as string[]).filter((t) => t !== tag);
  const { error } = await supabase
    .from("enrollment_requests")
    .update({ tags })
    .eq("id", leadId);
  if (error) return { ok: false, error: error.message };
  bust(leadId);
  return { ok: true };
}

// ─── Devis ──────────────────────────────────────────────────────────

interface QuoteInput {
  formationTitle: string;
  amountEuros: number;
  fundingLabel?: string;
  durationLabel?: string;
  hours?: string;
  modalityLabel?: string;
  startDate?: string; // ISO ("" si non précisé)
  validityDays: number;
  notes?: string;
}

/**
 * Génère un devis PDF pré-rempli et l'envoie par email (Resend) au prospect,
 * journalise l'envoi dans les notes et bascule le lead en "devis_envoye".
 */
export async function sendQuote(leadId: string, input: QuoteInput) {
  const { supabase, userId } = await ensureAdmin();

  const title = (input.formationTitle ?? "").trim();
  if (!title) return { ok: false, error: "Intitulé de la formation requis" };
  const amount = Number(input.amountEuros);
  if (!Number.isFinite(amount) || amount <= 0) {
    return { ok: false, error: "Montant invalide" };
  }
  const validityDays =
    Number.isFinite(input.validityDays) && input.validityDays > 0
      ? Math.min(Math.round(input.validityDays), 180)
      : 30;

  const { data: lead } = await supabase
    .from("enrollment_requests")
    .select("id, full_name, email, phone")
    .eq("id", leadId)
    .maybeSingle();
  if (!lead) return { ok: false, error: "Lead introuvable" };
  if (!lead.email) {
    return { ok: false, error: "Ce prospect n'a pas d'adresse email" };
  }

  const ref = `DEVIS-${new Date().getFullYear()}-${leadId
    .replace(/-/g, "")
    .slice(0, 6)
    .toUpperCase()}`;

  // 1) PDF
  let base64: string;
  try {
    const pdf = await renderQuotePdf({
      ref,
      client: {
        fullName: lead.full_name ?? "",
        email: lead.email,
        phone: lead.phone,
      },
      formationTitle: title,
      durationLabel: input.durationLabel ?? "",
      modalityLabel: input.modalityLabel ?? "",
      fundingLabel: input.fundingLabel ?? "",
      hours: input.hours ?? null,
      startDate: input.startDate || null,
      amountEuros: amount,
      validityDays,
      notes: input.notes ?? null,
    });
    base64 = pdf.toString("base64");
  } catch (e) {
    return {
      ok: false,
      error: `Échec de génération du PDF : ${
        e instanceof Error ? e.message : "inconnu"
      }`,
    };
  }

  // 2) Email + pièce jointe
  const amountFormatted = new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
  }).format(amount);
  const tpl = quoteEmail({
    fullName: lead.full_name ?? "",
    formationTitle: title,
    amountFormatted,
    validityDays,
    ref,
  });
  const sent = await sendEmail({
    to: lead.email,
    subject: tpl.subject,
    html: tpl.html,
    attachments: [{ filename: `${ref}.pdf`, content: base64 }],
  });
  if (!sent.ok) {
    return {
      ok: false,
      error: `Échec de l'envoi de l'email : ${sent.error ?? "inconnu"}`,
    };
  }

  // 3) Journalisation + bascule de statut (non bloquant)
  await supabase.from("lead_notes").insert({
    enrollment_request_id: leadId,
    author_id: userId,
    kind: "email",
    body: `Devis ${ref} envoyé par email à ${lead.email} — ${amountFormatted} (${title}).`,
  });
  await supabase
    .from("enrollment_requests")
    .update({ status: "devis_envoye" })
    .eq("id", leadId);

  bust(leadId);
  return { ok: true, sentTo: lead.email };
}
