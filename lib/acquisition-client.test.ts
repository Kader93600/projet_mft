import { describe, it, expect, beforeEach } from "vitest";
import { buildTrackingPayloadFromBrowser } from "./acquisition-client";

// jsdom est l'environnement global (cf. vitest.config.ts) → window dispo.
function setUrl(url: string) {
  window.history.pushState({}, "", url);
}

describe("buildTrackingPayloadFromBrowser", () => {
  beforeEach(() => setUrl("/"));

  it("capture les click-IDs des régies présents dans l'URL", () => {
    setUrl("/formations/gotrm?gclid=G123&fbclid=F456&ttclid=T789&msclkid=M000");
    const p = buildTrackingPayloadFromBrowser("landing");
    expect(p).not.toBeNull();
    expect(p?.gclid).toBe("G123");
    expect(p?.fbclid).toBe("F456");
    expect(p?.ttclid).toBe("T789");
    expect(p?.msclkid).toBe("M000");
    // Non fournis → null (jamais chaîne vide)
    expect(p?.gbraid).toBeNull();
    expect(p?.wbraid).toBeNull();
  });

  it("capture les UTM et laisse les click-IDs à null s'ils sont absents", () => {
    setUrl("/?utm_source=newsletter&utm_medium=email&utm_campaign=juin_2026");
    const p = buildTrackingPayloadFromBrowser();
    expect(p?.utm_source).toBe("newsletter");
    expect(p?.utm_medium).toBe("email");
    expect(p?.utm_campaign).toBe("juin_2026");
    expect(p?.gclid).toBeNull();
    expect(p?.fbclid).toBeNull();
  });

  it("retombe sur ?ref= comme utm_source", () => {
    setUrl("/?ref=partenaire");
    expect(buildTrackingPayloadFromBrowser()?.utm_source).toBe("partenaire");
  });

  it("renseigne kind et landing_page", () => {
    setUrl("/tarifs?gclid=X");
    const p = buildTrackingPayloadFromBrowser("landing");
    expect(p?.kind).toBe("landing");
    expect(p?.landing_page).toContain("/tarifs");
  });
});
