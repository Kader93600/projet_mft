import { describe, it, expect } from "vitest";
import { computeUnlockedModuleIds } from "./module-unlock";

// ── Mock minimal d'un client Supabase ────────────────────────────────
// computeUnlockedModuleIds enchaîne reader.from(t).select().in()/eq().
// Chaque builder est "thenable" et résout { data } selon la table.
function mockReader(data: {
  modules?: { id: string; order: number }[];
  lessons?: { id: string; module_id: string }[];
  lesson_progress?: { lesson_id: string; completed: boolean }[];
  lesson_views?: { lesson_id: string; completed: boolean }[];
}) {
  const tables: Record<string, unknown[]> = {
    modules: data.modules ?? [],
    lessons: data.lessons ?? [],
    lesson_progress: data.lesson_progress ?? [],
    lesson_views: data.lesson_views ?? [],
  };
  return {
    from(table: string) {
      const builder: any = {
        select: () => builder,
        in: () => builder,
        eq: () => builder,
        then: (resolve: (v: { data: unknown[] }) => void) =>
          resolve({ data: tables[table] ?? [] }),
      };
      return builder;
    },
  } as any;
}

const M2F = new Map([
  ["A", "capa"],
  ["B", "capa"],
  ["C", "capa"],
]);
const MODULES = [
  { id: "A", order: 10 },
  { id: "B", order: 20 },
  { id: "C", order: 30 },
];
const LESSONS = [
  { id: "la1", module_id: "A" },
  { id: "lb1", module_id: "B" },
  { id: "lc1", module_id: "C" },
];

async function run(reader: ReturnType<typeof mockReader>, ids = ["A", "B", "C"]) {
  const set = await computeUnlockedModuleIds(reader, "user1", ids, M2F);
  return [...set].sort();
}

describe("computeUnlockedModuleIds", () => {
  it("utilisateur frais : seul le 1er module est débloqué", async () => {
    const got = await run(mockReader({ modules: MODULES, lessons: LESSONS }));
    expect(got).toEqual(["A"]);
  });

  it("leçons du module A terminées (lesson_progress) → A et B débloqués, C verrouillé", async () => {
    const got = await run(
      mockReader({
        modules: MODULES,
        lessons: LESSONS,
        lesson_progress: [{ lesson_id: "la1", completed: true }],
      }),
    );
    expect(got).toEqual(["A", "B"]);
  });

  it("complétion via lesson_views uniquement compte aussi (union)", async () => {
    const got = await run(
      mockReader({
        modules: MODULES,
        lessons: LESSONS,
        lesson_views: [{ lesson_id: "la1", completed: true }],
      }),
    );
    expect(got).toEqual(["A", "B"]);
  });

  it("cascade complète : A et B terminés → C débloqué", async () => {
    const got = await run(
      mockReader({
        modules: MODULES,
        lessons: LESSONS,
        lesson_progress: [
          { lesson_id: "la1", completed: true },
          { lesson_id: "lb1", completed: true },
        ],
      }),
    );
    expect(got).toEqual(["A", "B", "C"]);
  });

  it("un module SANS leçon ne bloque pas la suite", async () => {
    // A n'a aucune leçon → considéré complet → B débloqué d'office
    const got = await run(
      mockReader({
        modules: [
          { id: "A", order: 10 },
          { id: "B", order: 20 },
        ],
        lessons: [{ id: "lb1", module_id: "B" }],
      }),
      ["A", "B"],
    );
    expect(got).toEqual(["A", "B"]);
  });

  it("formations indépendantes : chaque parcours a son propre 1er module", async () => {
    const m2f = new Map([
      ["A", "capa"],
      ["B", "capa"],
      ["X", "gotrm"],
      ["Y", "gotrm"],
    ]);
    const set = await computeUnlockedModuleIds(
      mockReader({
        modules: [
          { id: "A", order: 10 },
          { id: "B", order: 20 },
          { id: "X", order: 10 },
          { id: "Y", order: 20 },
        ],
        lessons: [
          { id: "la", module_id: "A" },
          { id: "lb", module_id: "B" },
          { id: "lx", module_id: "X" },
          { id: "ly", module_id: "Y" },
        ],
      }),
      "user1",
      ["A", "B", "X", "Y"],
      m2f,
    );
    // 1er de chaque formation débloqué, le 2e verrouillé
    expect([...set].sort()).toEqual(["A", "X"]);
  });

  it("incomplet : leçon non terminée garde le module suivant verrouillé", async () => {
    const got = await run(
      mockReader({
        modules: MODULES,
        lessons: LESSONS,
        lesson_progress: [{ lesson_id: "la1", completed: false }],
      }),
    );
    expect(got).toEqual(["A"]);
  });

  it("liste de modules vide → ensemble vide", async () => {
    const set = await computeUnlockedModuleIds(mockReader({}), "u", [], new Map());
    expect(set.size).toBe(0);
  });
});
