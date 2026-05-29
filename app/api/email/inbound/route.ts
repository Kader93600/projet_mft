// =====================================================================
// Webhook entrant — insère dans email_log les emails reçus par le provider
// (Resend Inbound, Mailgun, Postmark, …). Authentifié par un secret partagé.
//
// Configurez côté provider :
//   URL    : https://<votre-domaine>/api/email/inbound
//   Secret : env EMAIL_INBOUND_SECRET (envoyé en header X-Inbound-Secret
//            ou en query ?secret=…)
// =====================================================================
import { NextResponse, type NextRequest } from "next/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { captureException } from "@/lib/observability";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

type Parsed = {
  from: string | null;
  fromName?: string | null;
  to: string[];
  subject: string;
  html: string;
  text?: string;
};

function pickStr(v: any): string | null {
  if (typeof v === "string" && v.trim()) return v.trim();
  return null;
}
function pickEmail(v: any): string | null {
  const s = pickStr(v);
  if (!s) return null;
  // "Nom <a@b.fr>" → a@b.fr
  const m = s.match(/<([^>]+@[^>]+)>/);
  return (m ? m[1] : s).toLowerCase();
}

/** Essaie successivement les shapes connues (Resend, Postmark, Mailgun, plat). */
function parseInbound(body: any): Parsed | null {
  // Resend / formats objet imbriqués
  if (body?.from?.email || body?.from?.address) {
    const fromObj = body.from;
    const toArr = Array.isArray(body.to) ? body.to : body.to ? [body.to] : [];
    return {
      from: pickEmail(fromObj.email ?? fromObj.address ?? fromObj),
      fromName: pickStr(fromObj.name),
      to: toArr.map((t: any) => pickEmail(t?.email ?? t?.address ?? t) ?? "").filter(Boolean),
      subject: pickStr(body.subject) ?? "",
      html: pickStr(body.html) ?? pickStr(body.body_html) ?? "",
      text: pickStr(body.text) ?? pickStr(body.body_text) ?? undefined,
    };
  }
  // Postmark
  if (body?.FromFull?.Email || body?.From) {
    const f = body.FromFull ?? {};
    return {
      from: pickEmail(f.Email ?? body.From),
      fromName: pickStr(f.Name),
      to: [pickEmail(body.OriginalRecipient ?? body.To) ?? ""].filter(Boolean),
      subject: pickStr(body.Subject) ?? "",
      html: pickStr(body.HtmlBody) ?? "",
      text: pickStr(body.TextBody) ?? undefined,
    };
  }
  // Mailgun (parsed)
  if (body?.sender || body?.recipient) {
    return {
      from: pickEmail(body.sender ?? body.from),
      fromName: pickStr(body.from),
      to: [pickEmail(body.recipient) ?? ""].filter(Boolean),
      subject: pickStr(body.subject) ?? "",
      html: pickStr(body["body-html"]) ?? "",
      text: pickStr(body["body-plain"]) ?? undefined,
    };
  }
  // Format plat générique
  if (body?.from || body?.to) {
    const toArr = Array.isArray(body.to) ? body.to : [body.to];
    return {
      from: pickEmail(body.from),
      fromName: pickStr(body.from_name),
      to: toArr.map(pickEmail).filter(Boolean) as string[],
      subject: pickStr(body.subject) ?? "",
      html: pickStr(body.html ?? body.body_html) ?? "",
      text: pickStr(body.text ?? body.body_text) ?? undefined,
    };
  }
  return null;
}

function safeHtml(s: string): string {
  return (s || "")
    .replace(/<script[\s\S]*?<\/script>/gi, "")
    .replace(/\son\w+="[^"]*"/gi, "")
    .replace(/\son\w+='[^']*'/gi, "");
}

export async function POST(req: NextRequest) {
  const expected = process.env.EMAIL_INBOUND_SECRET;
  if (!expected) {
    return NextResponse.json(
      { ok: false, error: "EMAIL_INBOUND_SECRET non défini côté serveur." },
      { status: 500 }
    );
  }

  const sent =
    req.headers.get("x-inbound-secret") ??
    req.headers.get("x-webhook-secret") ??
    new URL(req.url).searchParams.get("secret");
  if (sent !== expected) {
    return NextResponse.json({ ok: false, error: "Secret invalide." }, { status: 401 });
  }

  let body: any;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ ok: false, error: "JSON invalide." }, { status: 400 });
  }

  const parsed = parseInbound(body);
  if (!parsed || !parsed.from) {
    return NextResponse.json({ ok: false, error: "Format d'email entrant non reconnu." }, { status: 400 });
  }

  try {
    const admin = createAdminClient();
    const { data, error } = await admin
      .from("email_log")
      .insert({
        direction: "inbound",
        sender_email: parsed.from,
        from_name: parsed.fromName ?? null,
        recipients: parsed.to,
        cc: [],
        bcc: [],
        subject: parsed.subject || "(sans objet)",
        body_html: safeHtml(parsed.html || (parsed.text ? `<pre>${parsed.text}</pre>` : "")),
        status: "received",
        attachments_meta: [],
      })
      .select("id")
      .single();
    if (error) throw error;
    return NextResponse.json({ ok: true, id: data?.id }, { status: 200 });
  } catch (e: any) {
    await captureException(e, { tags: { service: "email-inbound" } });
    return NextResponse.json({ ok: false, error: e?.message ?? "Erreur serveur." }, { status: 500 });
  }
}
