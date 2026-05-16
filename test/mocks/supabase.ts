// =====================================================================
// Mock Supabase léger pour tests d'intégration côté Vitest.
//
// Implémente juste les méthodes qu'on utilise dans nos server actions
// et helpers : auth.getUser, from('table').select/.eq/.single/.insert
// /.update/.delete + rpc(). Comportement déterministe basé sur des
// "fixtures" passées en argument.
//
// Pour les tests qui ont besoin de Supabase réel (RLS, triggers,
// transactions), utiliser les tests E2E Playwright dans e2e/.
// =====================================================================

import { vi } from "vitest";

export interface MockProfile {
  id: string;
  email: string;
  role: "student" | "trainer" | "admin" | "super_admin";
  full_name?: string | null;
  disabled?: boolean;
}

export interface MockSupabaseOptions {
  /** Utilisateur actuellement connecté (auth.getUser). null = anonyme. */
  user?: { id: string; email?: string } | null;
  /** Profils retournés par from('profiles').select. */
  profiles?: MockProfile[];
  /** Données génériques par table : from(tableName).select() → rows. */
  tables?: Record<string, any[]>;
  /** Réponses RPC : rpc('function_name', args) → result. */
  rpcs?: Record<string, (args?: any) => any>;
  /** Force une erreur sur certaines opérations. */
  errors?: {
    auth?: string;
    [table: string]: string | undefined;
  };
}

/**
 * Construit un client Supabase mocké compatible avec @supabase/ssr +
 * @supabase/supabase-js. Couvre seulement les méthodes utilisées par
 * le code MFT (suffisant pour les tests unitaires/intégration).
 */
export function createMockSupabaseClient(opts: MockSupabaseOptions = {}) {
  const { user = null, profiles = [], tables = {}, rpcs = {}, errors = {} } = opts;

  // ─── auth ──────────────────────────────────────────────────
  const auth = {
    getUser: vi.fn(async () => {
      if (errors.auth) {
        return { data: { user: null }, error: { message: errors.auth } };
      }
      return { data: { user }, error: null };
    }),
    getSession: vi.fn(async () => ({
      data: { session: user ? { user } : null },
      error: null,
    })),
    signInWithPassword: vi.fn(),
    signOut: vi.fn(),
  };

  // ─── from('table') — query builder ────────────────────────
  function from(table: string) {
    const rows =
      table === "profiles" ? (profiles as any[]) : tables[table] ?? [];

    // État partagé pour chaîner select/eq/in/.single/.maybeSingle/etc.
    const state = {
      table,
      filtered: [...rows],
      selectedCols: "*" as string,
    };

    const builder: any = {
      // SELECT
      select: vi.fn((cols?: string) => {
        if (cols) state.selectedCols = cols;
        return builder;
      }),
      // FILTERS
      eq: vi.fn((col: string, value: any) => {
        state.filtered = state.filtered.filter((r) => r[col] === value);
        return builder;
      }),
      neq: vi.fn((col: string, value: any) => {
        state.filtered = state.filtered.filter((r) => r[col] !== value);
        return builder;
      }),
      in: vi.fn((col: string, values: any[]) => {
        state.filtered = state.filtered.filter((r) => values.includes(r[col]));
        return builder;
      }),
      gte: vi.fn((col: string, value: any) => {
        state.filtered = state.filtered.filter((r) => r[col] >= value);
        return builder;
      }),
      lte: vi.fn((col: string, value: any) => {
        state.filtered = state.filtered.filter((r) => r[col] <= value);
        return builder;
      }),
      not: vi.fn(() => builder),
      order: vi.fn(() => builder),
      limit: vi.fn((n: number) => {
        state.filtered = state.filtered.slice(0, n);
        return builder;
      }),
      // SINGLE
      single: vi.fn(async () => {
        if (errors[table]) {
          return { data: null, error: { message: errors[table] } };
        }
        if (state.filtered.length === 0) {
          return { data: null, error: { code: "PGRST116", message: "No rows" } };
        }
        return { data: state.filtered[0], error: null };
      }),
      maybeSingle: vi.fn(async () => {
        if (errors[table]) {
          return { data: null, error: { message: errors[table] } };
        }
        return { data: state.filtered[0] ?? null, error: null };
      }),
      // MUTATIONS — renvoient simplement OK, le mock ne persiste pas
      insert: vi.fn(async (_payload?: any) => ({
        data: _payload,
        error: errors[table] ? { message: errors[table] } : null,
      })),
      update: vi.fn(async () => ({
        data: null,
        error: errors[table] ? { message: errors[table] } : null,
      })),
      upsert: vi.fn(async () => ({
        data: null,
        error: errors[table] ? { message: errors[table] } : null,
      })),
      delete: vi.fn(async () => ({
        data: null,
        error: errors[table] ? { message: errors[table] } : null,
      })),
      // Permet d'attendre directement le résultat sans .single() pour les select
      then: (resolve: any) =>
        resolve({
          data: errors[table] ? null : state.filtered,
          error: errors[table] ? { message: errors[table] } : null,
        }),
    };

    return builder;
  }

  // ─── rpc() ─────────────────────────────────────────────────
  const rpc = vi.fn(async (fnName: string, args?: any) => {
    const handler = rpcs[fnName];
    if (handler) {
      return { data: handler(args), error: null };
    }
    return { data: null, error: null };
  });

  return {
    auth,
    from,
    rpc,
    channel: vi.fn(() => ({
      on: vi.fn().mockReturnThis(),
      subscribe: vi.fn(),
    })),
    removeChannel: vi.fn(),
  };
}

/**
 * Helper : mocke directement le module `@/lib/supabase/server` pour
 * que `createClient()` retourne notre mock dans les tests qui importent
 * indirectement des server actions.
 *
 * Usage :
 *   vi.mock("@/lib/supabase/server", () => ({
 *     createClient: () => createMockSupabaseClient({ user: …, profiles: … })
 *   }));
 */
