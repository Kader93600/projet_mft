"use server";

import { randomUUID } from "node:crypto";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import type { Tables } from "@/lib/database.types";
import { sendEmail, newStudentDocumentEmail } from "@/lib/email";
import { LEGAL } from "@/lib/legal-config";
import {
  MAX_DOC_SIZE,
  isAcceptedFile,
  isValidReason,
  reasonLabel,
  extOf,
} from "@/lib/student-documents";

const BUCKET = "student-documents";

/**
 * Étape 1 — génère une URL d'upload signée (validation rôle/type/taille côté
 * serveur). Le client envoie ensuite le fichier directement au Storage (XHR
 * avec barre de progression), sans transiter par le serveur Next.
 */
export async function createUploadUrl(input: {
  fileName: string;
  sizeBytes: number;
}): Promise<
  | { ok: true; path: string; token: string; signedUrl: string }
  | { ok: false; error: string }
> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: "Non authentifié." };

  if (!isAcceptedFile(input.fileName)) {
    return { ok: false, error: "Format de fichier non autorisé." };
  }
  if (!input.sizeBytes || input.sizeBytes > MAX_DOC_SIZE) {
    return { ok: false, error: "Fichier trop volumineux (10 Mo maximum)." };
  }

  const ext = extOf(input.fileName);
  const path = `${user.id}/${randomUUID()}.${ext}`;
  const admin = createAdminClient();
  const { data, error } = await admin.storage
    .from(BUCKET)
    .createSignedUploadUrl(path);
  if (error || !data) {
    return { ok: false, error: "Préparation de l'envoi impossible." };
  }
  return { ok: true, path, token: data.token, signedUrl: data.signedUrl };
}

/**
 * Étape 2 — enregistre les métadonnées après l'upload réussi et notifie
 * l'administration par email (Resend).
 */
export async function finalizeUpload(input: {
  path: string;
  title: string;
  reason: string;
  customReason?: string;
  fileName: string;
  mimeType?: string;
  sizeBytes: number;
}): Promise<{ ok: true; id: string } | { ok: false; error: string }> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: "Non authentifié." };

  // Sécurité : le chemin doit appartenir à l'utilisateur.
  if (!input.path.startsWith(`${user.id}/`)) {
    return { ok: false, error: "Chemin de fichier invalide." };
  }
  const title = input.title.trim();
  if (!title) return { ok: false, error: "Le titre est obligatoire." };
  if (!isValidReason(input.reason)) {
    return { ok: false, error: "Motif invalide." };
  }
  const custom = input.customReason?.trim() || null;
  if (input.reason === "autres" && !custom) {
    return { ok: false, error: "Précisez le motif personnalisé." };
  }
  if (!isAcceptedFile(input.fileName) || input.sizeBytes > MAX_DOC_SIZE) {
    return { ok: false, error: "Fichier non conforme." };
  }

  // Formation courante du stagiaire (pour l'email + le filtrage admin).
  const { data: profileRow } = await supabase
    .from("profiles")
    .select("full_name, email, current_formation_id")
    .eq("id", user.id)
    .maybeSingle();
  const profile = (profileRow ?? null) as Pick<
    Tables<"profiles">,
    "full_name" | "email" | "current_formation_id"
  > | null;
  const formationId = profile?.current_formation_id ?? null;
  let formationTitle: string | null = null;
  if (formationId) {
    const { data: fRow } = await supabase
      .from("formations")
      .select("title")
      .eq("id", formationId)
      .maybeSingle();
    const f = (fRow ?? null) as Pick<Tables<"formations">, "title"> | null;
    formationTitle = f?.title ?? null;
  }

  const { data: inserted, error } = await supabase
    .from("student_documents")
    .insert({
      user_id: user.id,
      formation_id: formationId,
      title,
      reason: input.reason,
      custom_reason: custom,
      storage_path: input.path,
      file_name: input.fileName,
      mime_type: input.mimeType ?? null,
      size_bytes: input.sizeBytes,
      status: "recu",
    })
    .select("id")
    .single();
  if (error || !inserted) {
    return { ok: false, error: "Enregistrement impossible." };
  }

  // Notification admin (non bloquant).
  try {
    const admin = createAdminClient();
    const { data: signed } = await admin.storage
      .from(BUCKET)
      .createSignedUrl(input.path, 60 * 60 * 24 * 7);
    const email = newStudentDocumentEmail({
      studentName: profile?.full_name || profile?.email || "Stagiaire",
      formation: formationTitle,
      docType: reasonLabel(input.reason, custom),
      title,
      dateTime: new Date().toLocaleString("fr-FR", {
        dateStyle: "long",
        timeStyle: "short",
        timeZone: "Europe/Paris",
      }),
      fileName: input.fileName,
      link: signed?.signedUrl ?? null,
      adminUrl: "https://www.maformationtransport.fr/admin/documents",
    });
    await sendEmail({ to: LEGAL.email, subject: email.subject, html: email.html });
  } catch {
    /* l'email ne doit pas faire échouer l'import */
  }

  revalidatePath("/mes-documents");
  return { ok: true, id: inserted.id };
}

/** Supprime un document du stagiaire (fichier + métadonnées). */
export async function deleteStudentDocument(
  id: string
): Promise<{ ok: boolean; error?: string }> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: "Non authentifié." };

  const { data: docRow } = await supabase
    .from("student_documents")
    .select("id, user_id, storage_path")
    .eq("id", id)
    .maybeSingle();
  const doc = (docRow ?? null) as Pick<
    Tables<"student_documents">,
    "id" | "user_id" | "storage_path"
  > | null;
  if (!doc) return { ok: false, error: "Document introuvable." };
  if (doc.user_id !== user.id) {
    return { ok: false, error: "Action non autorisée." };
  }

  const admin = createAdminClient();
  await admin.storage.from(BUCKET).remove([doc.storage_path]);
  const { error } = await supabase
    .from("student_documents")
    .delete()
    .eq("id", id);
  if (error) return { ok: false, error: "Suppression impossible." };

  revalidatePath("/mes-documents");
  return { ok: true };
}
