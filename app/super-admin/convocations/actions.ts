"use server";

// =====================================================================
// Server actions du module Convocations PDF (staff uniquement).
// Préremplissage depuis les données existantes (enrollments, profiles,
// formations, formateurs habilités) + CRUD convocations et lieux.
// =====================================================================

import { revalidatePath } from "next/cache";
import { requireAdmin } from "@/lib/admin-guard";
import {
  buildFileName, buildReference,
  type ConvocationKind, type ConvocationPayload, type ConvocationRow,
  type ConvocationStatus, type ConvocationTemplate,
} from "@/lib/convocations";
import type { Tables } from "@/lib/database.types";

const bust = () => revalidatePath("/super-admin/convocations");

/* La table profiles ne stocke que full_name : on découpe prénom / nom. */
function splitName(full: string | null): { prenom: string; nom: string } {
  const f = (full ?? "").trim();
  if (!f) return { prenom: "", nom: "" };
  const i = f.indexOf(" ");
  if (i === -1) return { prenom: f, nom: "" };
  return { prenom: f.slice(0, i), nom: f.slice(i + 1) };
}

/* ── Référentiels pour le préremplissage ────────────────────────────── */

export interface CandidatOption {
  user_id: string;
  nom: string;
  prenom: string;
  email: string | null;
  telephone: string | null;
  formation_id: string | null;
  formation_titre: string | null;
  session_label: string | null;
  start_date: string | null;
  end_date: string | null;
}

/** Candidats = inscriptions actives (une entrée par inscription). */
export async function listCandidats(formationId?: string): Promise<CandidatOption[]> {
  const { service } = await requireAdmin();
  let q = service
    .from("enrollments")
    .select("user_id, formation_id, session_label, start_date, end_date, status, profiles!enrollments_user_id_fkey(full_name, email, phone), formations(id, title)")
    .in("status", ["inscrit", "en_cours", "termine"])
    .order("created_at", { ascending: false })
    .limit(400);
  if (formationId) q = q.eq("formation_id", formationId);
  const { data } = await q;
  type Row = Pick<Tables<"enrollments">, "user_id" | "formation_id" | "session_label" | "start_date" | "end_date"> & {
    profiles: Pick<Tables<"profiles">, "full_name" | "email" | "phone"> | null;
    formations: Pick<Tables<"formations">, "id" | "title"> | null;
  };
  const rows = (data ?? []) as unknown as Row[];
  return rows
    .filter((r) => r.profiles)
    .map((r) => {
      const p = r.profiles!;
      const { prenom, nom } = splitName(p.full_name);
      return {
        user_id: r.user_id,
        prenom, nom,
        email: p.email, telephone: p.phone,
        formation_id: r.formation_id,
        formation_titre: r.formations?.title ?? null,
        session_label: r.session_label,
        start_date: r.start_date, end_date: r.end_date,
      };
    });
}

export interface JuryOption {
  user_id: string;
  nom: string;
  prenom: string;
  email: string | null;
  telephone: string | null;
  formations: string[];
}

/** Jurys potentiels = formateurs habilités (saisie libre possible côté UI). */
export async function listJurys(): Promise<JuryOption[]> {
  const { service } = await requireAdmin();
  const { data } = await service
    .from("trainer_formations")
    .select("trainer_id, formations(title), profiles!trainer_formations_trainer_id_fkey(full_name, email, phone)")
    .limit(300);
  type Row = { trainer_id: string;
    formations: Pick<Tables<"formations">, "title"> | null;
    profiles: Pick<Tables<"profiles">, "full_name" | "email" | "phone"> | null;
  };
  const rows = (data ?? []) as unknown as Row[];
  const byId = new Map<string, JuryOption>();
  for (const r of rows) {
    if (!r.profiles) continue;
    const p = r.profiles;
    const { prenom, nom } = splitName(p.full_name);
    const cur: JuryOption = byId.get(r.trainer_id) ?? {
      user_id: r.trainer_id,
      prenom, nom,
      email: p.email, telephone: p.phone, formations: [],
    };
    if (r.formations?.title && !cur.formations.includes(r.formations.title)) {
      cur.formations.push(r.formations.title);
    }
    byId.set(r.trainer_id, cur);
  }
  return [...byId.values()];
}

export interface LieuRow {
  id: string; name: string; address: string; postal_code: string; city: string;
  room: string | null; floor: string | null; access_info: string | null;
}

export async function listLieux(): Promise<LieuRow[]> {
  const { service } = await requireAdmin();
  const { data } = await service
    .from("convocation_locations")
    .select("id, name, address, postal_code, city, room, floor, access_info")
    .order("created_at");
  return (data ?? []) as LieuRow[];
}

export async function createLieu(input: Omit<LieuRow, "id">): Promise<{ ok: boolean; lieu?: LieuRow; error?: string }> {
  const { service, admin } = await requireAdmin();
  if (!input.name?.trim() || !input.address?.trim() || !input.city?.trim()) {
    return { ok: false, error: "Nom, adresse et ville sont obligatoires." };
  }
  const { data, error } = await service
    .from("convocation_locations")
    .insert({ ...input, created_by: admin.id })
    .select("id, name, address, postal_code, city, room, floor, access_info")
    .single();
  if (error) return { ok: false, error: "Enregistrement du lieu impossible." };
  bust();
  return { ok: true, lieu: data as LieuRow };
}

/* ── CRUD convocations ──────────────────────────────────────────────── */

export interface SaveInput {
  id?: string;
  payload: ConvocationPayload;
  template: ConvocationTemplate;
  status?: ConvocationStatus;
  related_user_id?: string | null;
  formation_id?: string | null;
  batch_id?: string | null;
}

export async function saveConvocation(input: SaveInput): Promise<{ ok: boolean; row?: ConvocationRow; error?: string }> {
  const { service, admin } = await requireAdmin();
  const p = input.payload;
  if (!p.destinataire.nom.trim()) return { ok: false, error: "Le nom du destinataire est obligatoire." };
  if (!p.horaires.date) return { ok: false, error: "La date de l'épreuve est obligatoire." };
  if (!p.lieu.nom.trim()) return { ok: false, error: "Le lieu est obligatoire." };

  const reference = p.reference || buildReference(p.kind, p.horaires.date);
  const payload: ConvocationPayload = { ...p, reference };
  const record = {
    kind: p.kind,
    reference,
    payload,
    template: input.template,
    file_name: buildFileName(payload),
    related_user_id: input.related_user_id ?? null,
    formation_id: input.formation_id ?? null,
    session_label: p.session.label || null,
    exam_date: p.horaires.date,
    batch_id: input.batch_id ?? null,
    updated_at: new Date().toISOString(),
  };

  if (input.id) {
    const { data, error } = await service
      .from("convocations")
      .update({ ...record, status: input.status ?? "modifiee" })
      .eq("id", input.id)
      .select("*")
      .single();
    if (error) return { ok: false, error: "Mise à jour impossible." };
    bust();
    return { ok: true, row: data as unknown as ConvocationRow };
  }
  const { data, error } = await service
    .from("convocations")
    .insert({ ...record, status: input.status ?? "generee", created_by: admin.id })
    .select("*")
    .single();
  if (error) return { ok: false, error: "Enregistrement impossible." };
  bust();
  return { ok: true, row: data as unknown as ConvocationRow };
}

/** Génération en masse : insère N convocations liées par un batch_id. */
export async function saveBatch(
  items: SaveInput[],
): Promise<{ ok: boolean; ids?: string[]; batchId?: string; error?: string }> {
  const { service, admin } = await requireAdmin();
  if (items.length === 0) return { ok: false, error: "Aucune convocation à générer." };
  const batchId = crypto.randomUUID();
  const records = items.map((input) => {
    const reference = input.payload.reference || buildReference(input.payload.kind, input.payload.horaires.date);
    const payload = { ...input.payload, reference };
    return {
      kind: payload.kind,
      status: "generee" as const,
      reference,
      payload,
      template: input.template,
      file_name: buildFileName(payload),
      related_user_id: input.related_user_id ?? null,
      formation_id: input.formation_id ?? null,
      session_label: payload.session.label || null,
      exam_date: payload.horaires.date,
      batch_id: batchId,
      created_by: admin.id,
    };
  });
  const { data, error } = await service.from("convocations").insert(records).select("id");
  if (error) return { ok: false, error: "Enregistrement du lot impossible." };
  bust();
  return { ok: true, ids: (data ?? []).map((r: { id: string }) => r.id), batchId };
}

export async function setStatus(id: string, status: ConvocationStatus): Promise<{ ok: boolean; error?: string }> {
  const { service } = await requireAdmin();
  const { error } = await service
    .from("convocations")
    .update({ status, updated_at: new Date().toISOString() })
    .eq("id", id);
  if (error) return { ok: false, error: "Changement de statut impossible." };
  bust();
  return { ok: true };
}

export async function deleteConvocation(id: string): Promise<{ ok: boolean; error?: string }> {
  const { service } = await requireAdmin();
  const { error } = await service.from("convocations").delete().eq("id", id);
  if (error) return { ok: false, error: "Suppression impossible." };
  bust();
  return { ok: true };
}

export interface HistoryFilters {
  kind?: ConvocationKind | "";
  status?: ConvocationStatus | "";
  search?: string;
}

export async function listHistory(filters: HistoryFilters = {}): Promise<ConvocationRow[]> {
  const { service } = await requireAdmin();
  let q = service
    .from("convocations")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(200);
  if (filters.kind) q = q.eq("kind", filters.kind);
  if (filters.status) q = q.eq("status", filters.status);
  if (filters.search?.trim()) {
    const t = filters.search.trim();
    q = q.or(`reference.ilike.%${t}%,file_name.ilike.%${t}%,session_label.ilike.%${t}%`);
  }
  const { data } = await q;
  return (data ?? []) as unknown as ConvocationRow[];
}
