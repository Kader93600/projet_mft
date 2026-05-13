import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createCheckoutSession } from "@/lib/stripe";
import { findPlan } from "@/lib/pricing-config";
import { getPackPrice } from "@/lib/pricing-server";
import {
  isPackSlug,
  isPackAvailableForFormation,
  PACK_METADATA,
} from "@/lib/packs";
import { findFormation } from "@/lib/formations-config";
import { rateLimit, rateLimitHeaders, clientIp } from "@/lib/rate-limit";
import { captureException } from "@/lib/observability";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

/**
 * POST /api/stripe/checkout
 *
 * Crée une session Stripe Checkout. 2 modes :
 *
 *   Mode A (NEW — Phase 2) : achat d'un pack pour une formation
 *     body: { formationSlug: "gotrm", packSlug: "medium", email, installments? }
 *     → Prix lookup depuis DB (formation_pack_prices)
 *     → Metadata: { formation_slug, pack_slug, user_id }
 *
 *   Mode B (LEGACY) : ancien système de plans (essentiel / accompagnement / intensif)
 *     body: { planId: "essentiel", email, installments? }
 *     → Prix lookup depuis lib/pricing-config.ts
 *     → Pour compat avec /tarifs et /contact existants. À déprécier après
 *       migration de l'UI.
 *
 * Le mode est déduit de la présence des champs : si `formationSlug` + `packSlug`
 * sont présents → Mode A. Sinon → Mode B.
 */
export async function POST(req: Request) {
  const ip = clientIp(req.headers);
  const rl = await rateLimit({
    key: `stripe:checkout:${ip}`,
    limit: 10,
    windowSec: 60,
  });
  if (!rl.ok) {
    return new NextResponse("Too Many Requests", {
      status: 429,
      headers: rateLimitHeaders(rl, 10),
    });
  }

  let body: any;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }

  // Auth optionnelle : si connecté, on capture l'user_id
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  const email = String(body?.email ?? user?.email ?? "");
  if (!email) {
    return NextResponse.json({ error: "email_required" }, { status: 400 });
  }

  const installments = !!body?.installments;
  const appUrl = process.env.NEXT_PUBLIC_APP_URL || new URL(req.url).origin;

  // ─── Mode A : achat d'un pack pour une formation (Phase 2 architecture) ─
  const formationSlug = body?.formationSlug
    ? String(body.formationSlug)
    : null;
  const packSlug = body?.packSlug ? String(body.packSlug) : null;

  if (formationSlug && packSlug) {
    if (!isPackSlug(packSlug)) {
      return NextResponse.json({ error: "invalid_pack" }, { status: 400 });
    }
    const formation = findFormation(formationSlug);
    if (!formation) {
      return NextResponse.json({ error: "unknown_formation" }, { status: 400 });
    }
    if (!isPackAvailableForFormation(packSlug, formationSlug)) {
      return NextResponse.json(
        { error: "pack_not_available_for_formation" },
        { status: 400 },
      );
    }

    const price = await getPackPrice(formationSlug, packSlug);
    if (!price) {
      return NextResponse.json(
        { error: "price_not_configured" },
        { status: 400 },
      );
    }

    const packName = PACK_METADATA[packSlug].name;
    const productLabel = `${packName} — ${formation.code}`;

    try {
      const session = await createCheckoutSession({
        planId: `${formationSlug}_${packSlug}`,
        planName: productLabel,
        amountCents: price.priceCents,
        email,
        successUrl: `${appUrl}/inscription/success`,
        cancelUrl: `${appUrl}/inscription?cancel=1`,
        installments,
        metadata: {
          formation_slug: formationSlug,
          formation_id: formation.slug, // back-compat (formation_slug ré-utilisé)
          pack_slug: packSlug,
          user_id: user?.id ?? "",
        },
      });
      return NextResponse.json({ id: session.id, url: session.url });
    } catch (e) {
      await captureException(e, {
        tags: { service: "stripe", mode: "pack" },
        extra: { formationSlug, packSlug },
      });
      return NextResponse.json({ error: "checkout_failed" }, { status: 500 });
    }
  }

  // ─── Mode B : LEGACY (planId) — à déprécier ─────────────────────────────
  const planId = String(body?.planId ?? "");
  if (!planId) {
    return NextResponse.json(
      {
        error: "missing_params",
        message:
          "Provide either { formationSlug, packSlug } (recommended) or { planId } (legacy).",
      },
      { status: 400 },
    );
  }

  const plan = findPlan(planId);
  if (!plan) {
    return NextResponse.json({ error: "unknown_plan" }, { status: 400 });
  }
  if (!plan.funding.includes("auto")) {
    return NextResponse.json(
      { error: "plan_not_purchasable_online" },
      { status: 400 },
    );
  }

  try {
    const session = await createCheckoutSession({
      planId: plan.id,
      planName: `${plan.name} — Préparation RNCP 40990`,
      amountCents: plan.priceCents,
      email,
      successUrl: `${appUrl}/inscription/success`,
      cancelUrl: `${appUrl}/tarifs?cancel=1`,
      installments,
      metadata: {
        plan_id: plan.id,
        user_id: user?.id ?? "",
      },
    });
    return NextResponse.json({ id: session.id, url: session.url });
  } catch (e) {
    await captureException(e, {
      tags: { service: "stripe", mode: "legacy" },
    });
    return NextResponse.json({ error: "checkout_failed" }, { status: 500 });
  }
}
