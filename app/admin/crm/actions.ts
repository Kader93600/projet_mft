"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

async function ensureAdmin() {
  const supabase = createClient();
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
