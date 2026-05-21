import { describe, it, expect } from "vitest";
import { verifyStripeSignature } from "./stripe";

const SECRET = "whsec_test_secret_123";
const BODY = JSON.stringify({ type: "checkout.session.completed", id: "evt_1" });

// Reproduit la signature Stripe : HMAC-SHA256(secret, `${t}.${body}`) en hex.
async function signStripe(secret: string, ts: number, body: string) {
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    enc.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, enc.encode(`${ts}.${body}`));
  return Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}
const header = (ts: number, v1: string) => `t=${ts},v1=${v1}`;
const now = () => Math.floor(Date.now() / 1000);

describe("verifyStripeSignature", () => {
  it("accepte une signature valide et récente", async () => {
    const ts = now();
    const v1 = await signStripe(SECRET, ts, BODY);
    expect(await verifyStripeSignature(BODY, header(ts, v1), SECRET)).toBe(true);
  });

  it("rejette un corps falsifié (HMAC ne correspond plus)", async () => {
    const ts = now();
    const v1 = await signStripe(SECRET, ts, BODY);
    expect(
      await verifyStripeSignature(BODY + "tampered", header(ts, v1), SECRET),
    ).toBe(false);
  });

  it("rejette un mauvais secret", async () => {
    const ts = now();
    const v1 = await signStripe("whsec_autre_secret", ts, BODY);
    expect(await verifyStripeSignature(BODY, header(ts, v1), SECRET)).toBe(
      false,
    );
  });

  it("rejette une signature absente", async () => {
    expect(await verifyStripeSignature(BODY, null, SECRET)).toBe(false);
  });

  it("rejette un header mal formé (pas de v1)", async () => {
    expect(await verifyStripeSignature(BODY, `t=${now()}`, SECRET)).toBe(false);
  });

  it("rejette une signature hors tolérance temporelle (replay)", async () => {
    const oldTs = now() - 10_000; // bien au-delà des 300 s
    const v1 = await signStripe(SECRET, oldTs, BODY);
    expect(await verifyStripeSignature(BODY, header(oldTs, v1), SECRET)).toBe(
      false,
    );
  });

  it("rejette une v1 de longueur incorrecte (pas de crash)", async () => {
    const ts = now();
    expect(await verifyStripeSignature(BODY, header(ts, "abc"), SECRET)).toBe(
      false,
    );
  });

  it("respecte une tolérance personnalisée", async () => {
    const ts = now() - 100;
    const v1 = await signStripe(SECRET, ts, BODY);
    // tolérance 60 s → 100 s d'écart = rejeté
    expect(await verifyStripeSignature(BODY, header(ts, v1), SECRET, 60)).toBe(
      false,
    );
    // tolérance 300 s → accepté
    expect(await verifyStripeSignature(BODY, header(ts, v1), SECRET, 300)).toBe(
      true,
    );
  });
});
