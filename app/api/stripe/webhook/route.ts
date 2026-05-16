import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { verifyStripeSignature } from "@/lib/stripe";
import { captureException } from "@/lib/observability";
import { sendEmail, paymentReceivedEmail } from "@/lib/email";
import { LEGAL } from "@/lib/legal-config";
import { trackServerEvent } from "@/lib/analytics";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function POST(req: Request) {
  const secret = process.env.STRIPE_WEBHOOK_SECRET;
  if (!secret) {
    return NextResponse.json({ error: "webhook_not_configured" }, { status: 500 });
  }

  const raw = await req.text();
  const sig = req.headers.get("stripe-signature");
  const ok = await verifyStripeSignature(raw, sig, secret);
  if (!ok) {
    return NextResponse.json({ error: "invalid_signature" }, { status: 400 });
  }

  const event = JSON.parse(raw) as any;

  try {
    switch (event.type) {
      case "checkout.session.completed":
      case "checkout.session.async_payment_succeeded": {
        const session = event.data.object;
        await handlePaid(session);
        break;
      }
      case "checkout.session.async_payment_failed": {
        const session = event.data.object;
        await captureException(
          new Error(`Async payment failed for session ${session.id}`),
          { level: "warning", tags: { service: "stripe", event: event.type } }
        );
        break;
      }
      default:
        // Évènements non gérés : on accuse réception sans action.
        break;
    }
  } catch (e) {
    await captureException(e, {
      tags: { service: "stripe", event: event.type },
      extra: { event_id: event.id },
    });
    return NextResponse.json({ error: "handler_failed" }, { status: 500 });
  }

  return NextResponse.json({ received: true });
}

async function handlePaid(session: any) {
  // Service-role pour insérer côté admin (le webhook n'a pas de cookie user)
  const supabase = createClient();

  // Métadonnées (2 sources : nouveau format pack ou legacy planId)
  const metadata = session.metadata ?? {};
  const formationSlug: string | null = metadata.formation_slug || null;
  const packSlug: string | null = metadata.pack_slug || null;
  const planId: string | null = metadata.plan_id || null;
  const userId: string | null = metadata.user_id || null;
  const email = session.customer_email ?? session.customer_details?.email ?? "";
  const amountCents = session.amount_total ?? 0;

  // Si on a formation_slug, on résout l'ID de la formation pour le rattachement
  let formationId: string | null = null;
  if (formationSlug) {
    const { data: f } = await supabase
      .from("formations")
      .select("id")
      .eq("slug", formationSlug)
      .maybeSingle();
    formationId = f?.id ?? null;
  }

  // 1) Trace dans une table dédiée (idempotence par session.id)
  await supabase.from("payments_log").upsert(
    {
      stripe_session_id: session.id,
      user_id: userId,
      email,
      // plan_id = combiné formation+pack pour le nouveau format, sinon legacy
      plan_id: planId ?? (packSlug && formationSlug ? `${formationSlug}_${packSlug}` : null),
      amount_cents: amountCents,
      status: "paid",
      payload: session,
    },
    { onConflict: "stripe_session_id" }
  );

  // 2) Si l'utilisateur est connu, créer une enrollment "en cours"
  //    Le pack est extrait de la metadata si présent, sinon "initial" par défaut.
  if (userId) {
    const sessionLabel = formationSlug && packSlug
      ? `Achat en ligne — ${formationSlug} (${packSlug})`
      : `Achat en ligne — ${planId ?? "inconnu"}`;

    await supabase.from("enrollments").insert({
      user_id: userId,
      formation_id: formationId,
      funding_kind: "auto",
      session_label: sessionLabel,
      total_amount_cents: amountCents,
      paid_amount_cents: amountCents,
      status: "en_cours",
      pack: packSlug ?? "initial",
    });

    // Analytics : payment + enrollment
    await trackServerEvent({
      userId,
      event: "payment_success",
      props: {
        formation_slug: formationSlug ?? undefined,
        pack: (packSlug ?? "initial") as "initial" | "medium" | "premium",
        amount_cents: amountCents,
        currency: session.currency ?? "eur",
      },
    });
    await trackServerEvent({
      userId,
      event: "enrollment_created",
      props: {
        formation_slug: formationSlug ?? undefined,
        pack: (packSlug ?? "initial") as "initial" | "medium" | "premium",
        funding_kind: "auto",
      },
    });
  }

  // 3) Email de confirmation (template MFT brandé)
  if (email) {
    const loginUrl = `${process.env.NEXT_PUBLIC_APP_URL || LEGAL.website}/login`;
    const fullName =
      session.customer_details?.name ||
      session.customer_details?.email?.split("@")[0] ||
      null;
    const tmpl = paymentReceivedEmail({
      fullName,
      amountCents,
      loginUrl,
      invoiceUrl: session.invoice
        ? `https://dashboard.stripe.com/invoices/${session.invoice}`
        : null,
    });
    await sendEmail({
      to: email,
      ...tmpl,
      tags: [
        { name: "kind", value: "payment_received" },
        ...(planId ? [{ name: "plan_id", value: String(planId) }] : []),
      ],
    });
  }
}
