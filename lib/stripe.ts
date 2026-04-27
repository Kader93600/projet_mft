// Mini-client Stripe via fetch — pas de SDK requis.
// Couvre : Checkout Sessions + vérification de signature webhook.
// Si tu installes plus tard `stripe` (SDK officiel), tu peux remplacer
// ce fichier sans toucher au reste.

const STRIPE_API = "https://api.stripe.com/v1";

function form(data: Record<string, any>, prefix = ""): string {
  const parts: string[] = [];
  for (const [k, v] of Object.entries(data)) {
    if (v === undefined || v === null) continue;
    const key = prefix ? `${prefix}[${k}]` : k;
    if (Array.isArray(v)) {
      v.forEach((item, i) => {
        if (item !== null && typeof item === "object") {
          parts.push(form(item, `${key}[${i}]`));
        } else {
          parts.push(`${encodeURIComponent(`${key}[${i}]`)}=${encodeURIComponent(String(item))}`);
        }
      });
    } else if (typeof v === "object") {
      parts.push(form(v as any, key));
    } else {
      parts.push(`${encodeURIComponent(key)}=${encodeURIComponent(String(v))}`);
    }
  }
  return parts.join("&");
}

async function stripeRequest<T = any>(
  path: string,
  body?: Record<string, any>
): Promise<T> {
  const key = process.env.STRIPE_SECRET_KEY;
  if (!key) throw new Error("STRIPE_SECRET_KEY non défini");

  const res = await fetch(`${STRIPE_API}${path}`, {
    method: body ? "POST" : "GET",
    headers: {
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: body ? form(body) : undefined,
    cache: "no-store",
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Stripe ${res.status}: ${text}`);
  }
  return res.json();
}

export interface CheckoutSession {
  id: string;
  url: string;
  payment_status: "paid" | "unpaid" | "no_payment_required";
  amount_total: number;
  customer_email?: string | null;
  metadata: Record<string, string>;
}

interface CreateSessionInput {
  planId: string;
  planName: string;
  amountCents: number;
  email: string;
  successUrl: string;
  cancelUrl: string;
  metadata?: Record<string, string>;
  /** Active le paiement en 3-4× sans frais (Stripe Klarna/Pay-in-X). */
  installments?: boolean;
}

export async function createCheckoutSession(
  input: CreateSessionInput
): Promise<CheckoutSession> {
  return stripeRequest<CheckoutSession>("/checkout/sessions", {
    mode: "payment",
    customer_email: input.email,
    success_url: `${input.successUrl}?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: input.cancelUrl,
    payment_method_types: input.installments ? ["card", "klarna"] : ["card"],
    "line_items[0][quantity]": 1,
    "line_items[0][price_data][currency]": "eur",
    "line_items[0][price_data][unit_amount]": input.amountCents,
    "line_items[0][price_data][product_data][name]": input.planName,
    "line_items[0][price_data][product_data][metadata][plan_id]": input.planId,
    "metadata[plan_id]": input.planId,
    ...Object.fromEntries(
      Object.entries(input.metadata ?? {}).map(([k, v]) => [
        `metadata[${k}]`,
        v,
      ])
    ),
    locale: "fr",
    billing_address_collection: "required",
  });
}

export async function retrieveSession(id: string): Promise<CheckoutSession> {
  return stripeRequest<CheckoutSession>(`/checkout/sessions/${id}`);
}

// =====================================================================
// Vérification de signature webhook (HMAC SHA256)
// Compatible Edge runtime — utilise WebCrypto.
// =====================================================================
export async function verifyStripeSignature(
  rawBody: string,
  signatureHeader: string | null,
  secret: string,
  toleranceSec = 300
): Promise<boolean> {
  if (!signatureHeader) return false;
  const parts = Object.fromEntries(
    signatureHeader.split(",").map((p) => p.split("=") as [string, string])
  ) as { t?: string; v1?: string };
  if (!parts.t || !parts.v1) return false;

  const ts = parseInt(parts.t, 10);
  if (Math.abs(Date.now() / 1000 - ts) > toleranceSec) return false;

  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    enc.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const sig = await crypto.subtle.sign(
    "HMAC",
    key,
    enc.encode(`${parts.t}.${rawBody}`)
  );
  const hex = Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");

  // comparaison constant-time
  if (hex.length !== parts.v1.length) return false;
  let diff = 0;
  for (let i = 0; i < hex.length; i++) {
    diff |= hex.charCodeAt(i) ^ parts.v1.charCodeAt(i);
  }
  return diff === 0;
}
