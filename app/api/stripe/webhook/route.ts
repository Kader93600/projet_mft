import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { verifyStripeSignature } from "@/lib/stripe";
import { captureException } from "@/lib/observability";
import { sendEmail, emailLayout } from "@/lib/email";
import { LEGAL } from "@/lib/legal-config";

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

  const planId = session.metadata?.plan_id ?? null;
  const userId = session.metadata?.user_id || null;
  const email = session.customer_email ?? session.customer_details?.email ?? "";
  const amountCents = session.amount_total ?? 0;

  // 1) Trace dans une table dédiée (idempotence par session.id)
  await supabase.from("payments_log").upsert(
    {
      stripe_session_id: session.id,
      user_id: userId,
      email,
      plan_id: planId,
      amount_cents: amountCents,
      status: "paid",
      payload: session,
    },
    { onConflict: "stripe_session_id" }
  );

  // 2) Si l'utilisateur est connu, créer/MAJ une enrollment "à payer/payée"
  if (userId) {
    await supabase.from("enrollments").insert({
      user_id: userId,
      funding_kind: "auto",
      session_label: `Achat en ligne — ${planId}`,
      total_amount_cents: amountCents,
      paid_amount_cents: amountCents,
      status: "en_cours",
    });
  }

  // 3) Email de confirmation
  if (email) {
    await sendEmail({
      to: email,
      subject: "Paiement reçu — Bienvenue à bord 🎉",
      html: emailLayout(
        "Paiement confirmé",
        `<p>Merci pour votre confiance. Votre paiement de <strong>${(amountCents / 100).toLocaleString("fr-FR", { style: "currency", currency: "EUR" })}</strong> a bien été enregistré.</p>
         <p>Vous allez recevoir d'ici quelques minutes :</p>
         <ul>
           <li>Votre <strong>convention de formation</strong> (PDF)</li>
           <li>Votre <strong>convocation officielle</strong> avec les modalités d'accès</li>
           <li>Vos identifiants de connexion à la plateforme</li>
         </ul>
         <p style="margin:24px 0">
           <a href="${process.env.NEXT_PUBLIC_APP_URL}/login" style="display:inline-block;padding:12px 22px;background:#0E1240;color:#fff;text-decoration:none;border-radius:12px;font-weight:500">Accéder à ma plateforme</a>
         </p>
         <p style="font-size:13px;color:#64748B">Une question ? Répondez à cet email — réponse sous 4 h ouvrées.</p>`
      ),
    });
  }
}
