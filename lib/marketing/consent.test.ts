import { describe, it, expect, beforeEach } from "vitest";
import { readConsent, hasMarketingConsent, hasAnalyticsConsent } from "./consent";

const KEY = "gotrm.cookie.consent.v1";

describe("marketing/consent (gate CNIL des traceurs)", () => {
  beforeEach(() => {
    window.localStorage.clear();
  });

  it("défaut prudent : aucun choix enregistré → pas de consentement", () => {
    expect(readConsent()).toBeNull();
    expect(hasMarketingConsent()).toBe(false);
    expect(hasAnalyticsConsent()).toBe(false);
  });

  it("marketing accordé uniquement si marketing === true", () => {
    window.localStorage.setItem(
      KEY,
      JSON.stringify({ marketing: true, analytics: false })
    );
    expect(hasMarketingConsent()).toBe(true);
    expect(hasAnalyticsConsent()).toBe(false);
  });

  it("analytics est indépendant du marketing", () => {
    window.localStorage.setItem(
      KEY,
      JSON.stringify({ marketing: false, analytics: true })
    );
    expect(hasMarketingConsent()).toBe(false);
    expect(hasAnalyticsConsent()).toBe(true);
  });

  it("une valeur truthy non stricte ('true') NE vaut PAS consentement", () => {
    window.localStorage.setItem(KEY, JSON.stringify({ marketing: "true" }));
    expect(hasMarketingConsent()).toBe(false);
  });

  it("JSON corrompu → défaut prudent, pas de crash", () => {
    window.localStorage.setItem(KEY, "{not-json");
    expect(readConsent()).toBeNull();
    expect(hasMarketingConsent()).toBe(false);
  });
});
