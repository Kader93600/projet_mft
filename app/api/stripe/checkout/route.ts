import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createCheckoutSession } from "@/lib/stripe";
import { findPlan } from "@/lib/pricing-config";
import { rateLimit, rateLimitHeaders, clientIp } from "@/lib/rate-limit";
import { captureException } from "@/lib/observability";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

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
  const planId = String(body?.planId ?? "");
  const installments = !!body?.installments;
  const plan = findPlan(planId);
  if (!plan) {
    return NextResponse.json({ error: "unknown_plan" }, { status: 400 });
  }
  if (!plan.funding.includes("auto")) {
    return NextResponse.json(
      { error: "plan_not_purchasable_online" },
      { status: 400 }
    );
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

  const appUrl = process.env.NEXT_PUBLIC_APP_URL || new URL(req.url).origin;

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
    await captureException(e, { tags: { service: "stripe" } });
    return NextResponse.json({ error: "checkout_failed" }, { status: 500 });
  }
}
