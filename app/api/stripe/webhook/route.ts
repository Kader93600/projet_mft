import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { verifyStripeSignature } from "@/lib/stripe";
import { captureException } from "@/lib/observability";
import { sendEmail, paymentReceivedEmail } from "@/lib/email";
import { LEGAL } from "@/lib/legal-config";
import { trackServerEvent } from "@/lib/analytics-server";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

// Types Stripe minimaux (le projet ne dépend pas du SDK `stripe` ; la
// signature est vérifiée à la main dans lib/stripe). On modélise
// uniquement les champs réellement consommés par ce webhook de paiement.
interface StripeCheckoutSession {
  id: string;
  metadata?: Record<string, string | undefined> | null;
  customer_email?: string | null;
  customer_details?: { email?: string | null; name?: string | null } | null;
  amount_total?: number | null;
  currency?: string | null;
  invoice?: string | null;
}
interface StripeWebhookEvent {
  id: string;
  type: string;
  data: { object: StripeCheckoutSession };
}

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

  const event = JSON.parse(raw) as StripeWebhookEvent;

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

async function handlePaid(session: StripeCheckoutSession) {
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

    const organizationId: string | null = metadata.organization_id || null;
    const { data: enrollment } = await supabase
      .from("enrollments")
      .insert({
        user_id: userId,
        formation_id: formationId,
        organization_id: organizationId,
        funding_kind: "auto",
        session_label: sessionLabel,
        total_amount_cents: amountCents,
        paid_amount_cents: amountCents,
        status: "en_cours",
        pack: packSlug ?? "initial",
      })
      .select("id")
      .single();

    // ─── Parrainage : qualifier le referral si présent ────────────────
    // Métadonnées posées par /api/stripe/checkout. Si referrer_code,
    // alors le filleul a payé sa 1re inscription → admin pourra valider
    // le cashout dans /admin/referrals.
    const referrerCode: string = metadata.referrer_code || "";
    if (referrerCode && enrollment?.id) {
      const { error: qErr } = await supabase.rpc("qualify_referral", {
        p_referred_user: userId,
        p_enrollment_id: enrollment.id,
      });
      if (qErr) {
        await captureException(qErr, {
          tags: { service: "referrals", action: "qualify" },
          extra: { user_id: userId, code: referrerCode },
        });
      }
    }

    // ─── Programme de fidélité : applique la réduction annoncée ──────────
    // Le checkout a calculé un montant `loyalty_discount_cents` selon le
    // tier du user (avant cette nouvelle enrollment). On consomme via la
    // RPC qui inscrit la ligne ledger + l'événement loyalty_events.
    // IMPORTANT : on appelle AVANT que la nouvelle enrollment n'élève
    // le tier du user (ordre : insert enrollment → RPC loyalty avec le
    // montant ANNONCÉ qui était calculé sur le tier antérieur).
    const loyaltyDiscountCents = Number(
      metadata.loyalty_discount_cents || "0"
    );
    if (loyaltyDiscountCents > 0) {
      const { error: lErr } = await supabase.rpc("apply_loyalty_discount", {
        p_user: userId,
        p_price_cents: loyaltyDiscountCents,
        p_session_id: session.id,
      });
      if (lErr) {
        await captureException(lErr, {
          tags: { service: "loyalty", action: "apply_discount" },
          extra: { user_id: userId, amount: loyaltyDiscountCents },
        });
      }
    }

    // ─── Crédit utilisateur : consommer ce qui a été annoncé au checkout ─
    // Le checkout a calculé un montant `credit_applied_cents` et l'a
    // déduit du prix Stripe. On insère maintenant la ligne ledger
    // négative pour matérialiser la consommation.
    const creditAppliedCents = Number(metadata.credit_applied_cents || "0");
    if (creditAppliedCents > 0) {
      const { error: cErr } = await supabase.rpc("apply_credit_to_checkout", {
        p_user: userId,
        p_price_cents: creditAppliedCents,
        p_session_id: session.id,
      });
      if (cErr) {
        await captureException(cErr, {
          tags: { service: "credits", action: "apply" },
          extra: { user_id: userId, amount: creditAppliedCents },
        });
      }
    }

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
