"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { sendEmail } from "@/lib/email";

const STAFF = ["admin", "super_admin", "trainer"];
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const MAX_TOTAL_BYTES = 9 * 1024 * 1024; // ~9 Mo de pièces jointes (base64 ~12 Mo)

export interface ComposeAttachment {
  name: string;
  /** Contenu base64 brut (sans préfixe data:). */
  base64: string;
  size: number;
}

export interface SendPlatformEmailInput {
  to: string[];
  cc?: string[];
  bcc?: string[];
  subject: string;
  html: string;
  attachments?: ComposeAttachment[];
  context?: string | null;
  relatedUserId?: string | null;
}

function clean(list?: string[]): string[] {
  return (list ?? [])
    .map((e) => e.trim().toLowerCase())
    .filter((e) => EMAIL_RE.test(e));
}

/** Retire les <script> et gestionnaires inline par sécurité. */
function safeHtml(html: string): string {
  return (html || "")
    .replace(/<script[\s\S]*?<\/script>/gi, "")
    .replace(/\son\w+="[^"]*"/gi, "")
    .replace(/\son\w+='[^']*'/gi, "");
}

export async function sendPlatformEmail(input: SendPlatformEmailInput): Promise<{
  ok: boolean;
  id?: string;
  error?: string;
}> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: "Non authentifié." };

  const { data: me } = await supabase
    .from("profiles")
    .select("role, email, full_name")
    .eq("id", user.id)
    .maybeSingle();
  const role = (me as any)?.role;
  if (!STAFF.includes(role)) return { ok: false, error: "Accès refusé." };

  const to = clean(input.to);
  const cc = clean(input.cc);
  const bcc = clean(input.bcc);
  if (to.length === 0)
    return { ok: false, error: "Ajoutez au moins un destinataire valide." };
  if (!input.subject?.trim())
    return { ok: false, error: "L'objet est obligatoire." };

  const atts = input.attachments ?? [];
  const total = atts.reduce((s, a) => s + (a.size || 0), 0);
  if (total > MAX_TOTAL_BYTES)
    return { ok: false, error: "Pièces jointes trop volumineuses (9 Mo max au total)." };

  const html = safeHtml(input.html);
  const senderEmail = (me as any)?.email || user.email || undefined;

  const result = await sendEmail({
    to,
    cc: cc.length ? cc : undefined,
    bcc: bcc.length ? bcc : undefined,
    subject: input.subject.trim(),
    html,
    replyTo: senderEmail,
    attachments: atts.map((a) => ({ filename: a.name, content: a.base64 })),
    tags: [{ name: "source", value: "composer" }],
  });

  // Journalisation (service-role : action déjà gated staff).
  try {
    const admin = createAdminClient();
    await admin.from("email_log").insert({
      sender_id: user.id,
      sender_email: senderEmail ?? null,
      recipients: to,
      cc,
      bcc,
      subject: input.subject.trim(),
      body_html: html,
      status: result.ok ? "sent" : "error",
      provider_id: result.id ?? null,
      error: result.ok ? null : result.error ?? null,
      attachments_meta: atts.map((a) => ({ name: a.name, size: a.size })),
      related_user_id: input.relatedUserId ?? null,
      context: input.context ?? null,
    });
  } catch {
    /* journalisation non bloquante (table absente avant migration) */
  }

  revalidatePath("/admin/emails");
  return result.ok
    ? { ok: true, id: result.id }
    : { ok: false, error: result.error ?? "Échec de l'envoi." };
}
