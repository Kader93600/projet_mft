import { describe, it, expect, vi, beforeEach } from "vitest";
import { z } from "zod";

// Mock Supabase AVANT d'importer admin-guard
vi.mock("@/lib/supabase/server", () => ({
  createClient: vi.fn(),
}));

import { validate, rateLimit, requireAdmin, requireSuperAdmin } from "./admin-guard";
import { createClient } from "@/lib/supabase/server";
import { createMockSupabaseClient } from "@/test/mocks/supabase";

const mocked = vi.mocked(createClient);

beforeEach(() => {
  vi.clearAllMocks();
});

// =====================================================================
// validate (pure, sans Supabase)
// =====================================================================
describe("validate", () => {
  const schema = z.object({
    email: z.string().email(),
    age: z.number().int().positive(),
  });

  it("retourne les données validées en cas de succès", () => {
    const result = validate(schema, { email: "test@example.com", age: 30 });
    expect(result.email).toBe("test@example.com");
    expect(result.age).toBe(30);
  });

  it("throw une erreur formatée si le schéma échoue", () => {
    expect(() => validate(schema, { email: "pas-un-email", age: 30 })).toThrow();
    expect(() => validate(schema, { email: "x@x.fr", age: -5 })).toThrow();
    expect(() => validate(schema, { email: "x@x.fr" })).toThrow();
  });

  it("throw pour les types incompatibles (string au lieu de number)", () => {
    expect(() => validate(schema, { email: "x@x.fr", age: "trente" })).toThrow();
  });
});

// =====================================================================
// rateLimit (en mémoire, pas de Supabase)
// =====================================================================
describe("rateLimit", () => {
  it("autorise jusqu'à `max` requêtes", () => {
    const key = `test-${Date.now()}-${Math.random()}`;
    expect(rateLimit(key, 3, 60_000).allowed).toBe(true);
    expect(rateLimit(key, 3, 60_000).allowed).toBe(true);
    expect(rateLimit(key, 3, 60_000).allowed).toBe(true);
  });

  it("refuse la 4e requête quand max=3", () => {
    const key = `test-${Date.now()}-${Math.random()}`;
    rateLimit(key, 3, 60_000);
    rateLimit(key, 3, 60_000);
    rateLimit(key, 3, 60_000);
    const fourth = rateLimit(key, 3, 60_000);
    expect(fourth.allowed).toBe(false);
    expect(fourth.retryInMs).toBeGreaterThan(0);
  });

  it("isole les compteurs par clé", () => {
    const k1 = `a-${Date.now()}-${Math.random()}`;
    const k2 = `b-${Date.now()}-${Math.random()}`;
    rateLimit(k1, 2, 60_000);
    rateLimit(k1, 2, 60_000);
    // Quota épuisé sur k1
    expect(rateLimit(k1, 2, 60_000).allowed).toBe(false);
    // k2 a son propre compteur
    expect(rateLimit(k2, 2, 60_000).allowed).toBe(true);
  });

  it("reset après expiration de la fenêtre", async () => {
    const key = `test-reset-${Date.now()}-${Math.random()}`;
    rateLimit(key, 1, 50);
    expect(rateLimit(key, 1, 50).allowed).toBe(false);
    // Attendre que la fenêtre expire
    await new Promise((r) => setTimeout(r, 60));
    expect(rateLimit(key, 1, 50).allowed).toBe(true);
  });
});

// =====================================================================
// requireAdmin (utilise Supabase mocké)
// =====================================================================
describe("requireAdmin", () => {
  it("throw 'Non authentifié' si pas de user", async () => {
    mocked.mockReturnValue(
      createMockSupabaseClient({ user: null }) as any
    );
    await expect(requireAdmin()).rejects.toThrow(/non authentifi/i);
  });

  it("throw 'Profil introuvable' si user sans profil", async () => {
    mocked.mockReturnValue(
      createMockSupabaseClient({
        user: { id: "u1" },
        profiles: [],
      }) as any
    );
    await expect(requireAdmin()).rejects.toThrow(/profil/i);
  });

  it("throw 'Compte désactivé' si profile.disabled = true", async () => {
    mocked.mockReturnValue(
      createMockSupabaseClient({
        user: { id: "u1" },
        profiles: [
          { id: "u1", email: "a@x.fr", role: "admin", disabled: true },
        ],
      }) as any
    );
    await expect(requireAdmin()).rejects.toThrow(/d[ée]sactiv/i);
  });

  it("throw 'Accès refusé' pour un trainer", async () => {
    mocked.mockReturnValue(
      createMockSupabaseClient({
        user: { id: "u1" },
        profiles: [
          { id: "u1", email: "t@x.fr", role: "trainer", disabled: false },
        ],
      }) as any
    );
    await expect(requireAdmin()).rejects.toThrow(/refus/i);
  });

  it("throw 'Accès refusé' pour un student", async () => {
    mocked.mockReturnValue(
      createMockSupabaseClient({
        user: { id: "u1" },
        profiles: [
          { id: "u1", email: "s@x.fr", role: "student", disabled: false },
        ],
      }) as any
    );
    await expect(requireAdmin()).rejects.toThrow(/refus/i);
  });

  it("retourne { supabase, admin } pour un admin valide", async () => {
    mocked.mockReturnValue(
      createMockSupabaseClient({
        user: { id: "u1" },
        profiles: [
          { id: "u1", email: "a@x.fr", role: "admin", disabled: false },
        ],
      }) as any
    );
    const result = await requireAdmin();
    expect(result.admin.role).toBe("admin");
    expect(result.admin.email).toBe("a@x.fr");
  });

  it("accepte aussi super_admin", async () => {
    mocked.mockReturnValue(
      createMockSupabaseClient({
        user: { id: "u1" },
        profiles: [
          { id: "u1", email: "sa@x.fr", role: "super_admin", disabled: false },
        ],
      }) as any
    );
    const result = await requireAdmin();
    expect(result.admin.role).toBe("super_admin");
  });
});

// =====================================================================
// requireSuperAdmin
// =====================================================================
describe("requireSuperAdmin", () => {
  it("autorise super_admin", async () => {
    mocked.mockReturnValue(
      createMockSupabaseClient({
        user: { id: "u1" },
        profiles: [
          { id: "u1", email: "sa@x.fr", role: "super_admin", disabled: false },
        ],
      }) as any
    );
    const result = await requireSuperAdmin();
    expect(result.admin.role).toBe("super_admin");
  });

  it("refuse un admin normal", async () => {
    mocked.mockReturnValue(
      createMockSupabaseClient({
        user: { id: "u1" },
        profiles: [
          { id: "u1", email: "a@x.fr", role: "admin", disabled: false },
        ],
      }) as any
    );
    await expect(requireSuperAdmin()).rejects.toThrow(/refus/i);
  });

  it("refuse un trainer", async () => {
    mocked.mockReturnValue(
      createMockSupabaseClient({
        user: { id: "u1" },
        profiles: [
          { id: "u1", email: "t@x.fr", role: "trainer", disabled: false },
        ],
      }) as any
    );
    await expect(requireSuperAdmin()).rejects.toThrow();
  });
});
