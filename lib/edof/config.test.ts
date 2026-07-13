import { describe, it, expect, afterEach } from "vitest";
import {
  getEdofConfig,
  isEdofConfigured,
  isEdofFeatureEnabled,
} from "./config";

const EDOF_KEYS = [
  "EDOF_API_BASE_URL",
  "EDOF_CLIENT_ID",
  "EDOF_CLIENT_SECRET",
  "EDOF_OF_SIRET",
  "FEATURE_EDOF",
] as const;

// Sauvegarde de l'environnement initial pour restauration après chaque test.
const saved: Record<string, string | undefined> = {};
for (const k of EDOF_KEYS) saved[k] = process.env[k];

function clearEdofEnv() {
  for (const k of EDOF_KEYS) delete process.env[k];
}

afterEach(() => {
  for (const k of EDOF_KEYS) {
    if (saved[k] === undefined) delete process.env[k];
    else process.env[k] = saved[k];
  }
});

describe("edof/config (intégration inerte tant que non habilitée)", () => {
  it("reste inerte tant que les credentials ne sont pas TOUS présents", () => {
    clearEdofEnv();
    expect(getEdofConfig()).toBeNull();
    expect(isEdofConfigured()).toBe(false);

    // Un seul manquant (SIRET) suffit à rester inerte.
    process.env.EDOF_API_BASE_URL = "https://edof.example";
    process.env.EDOF_CLIENT_ID = "id";
    process.env.EDOF_CLIENT_SECRET = "secret";
    expect(getEdofConfig()).toBeNull();
    expect(isEdofConfigured()).toBe(false);
  });

  it("renvoie la config quand toutes les variables sont définies", () => {
    clearEdofEnv();
    process.env.EDOF_API_BASE_URL = "https://edof.example";
    process.env.EDOF_CLIENT_ID = "id";
    process.env.EDOF_CLIENT_SECRET = "secret";
    process.env.EDOF_OF_SIRET = "12345678900011";
    expect(getEdofConfig()).toEqual({
      baseUrl: "https://edof.example",
      clientId: "id",
      clientSecret: "secret",
      ofSiret: "12345678900011",
    });
    expect(isEdofConfigured()).toBe(true);
  });

  it("le feature flag est indépendant des credentials et strict", () => {
    clearEdofEnv();
    expect(isEdofFeatureEnabled()).toBe(false);
    process.env.FEATURE_EDOF = "true";
    expect(isEdofFeatureEnabled()).toBe(true);
    process.env.FEATURE_EDOF = "1";
    expect(isEdofFeatureEnabled()).toBe(false); // strict === "true"
  });
});
