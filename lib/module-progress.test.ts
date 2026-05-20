import { describe, it, expect } from "vitest";
import {
  getUnlockMode,
  isFlexibleUnlockFormation,
  getModuleKind,
  computeModuleState,
  computeModulePercent,
  applyLinearLocking,
  pickNextModule,
  type ModuleProgress,
} from "./module-progress";

// Fabrique un ModuleProgress minimal pour les tests de verrouillage.
function mod(p: Partial<ModuleProgress> & { id: string; order: number }): ModuleProgress {
  return {
    slug: p.slug ?? p.id,
    id: p.id,
    kind: p.kind ?? "course",
    order: p.order,
    lessonsTotal: p.lessonsTotal ?? 0,
    lessonsDone: p.lessonsDone ?? 0,
    quizzesTotal: p.quizzesTotal ?? 0,
    quizzesPassed: p.quizzesPassed ?? 0,
    quizzesAttempted: p.quizzesAttempted ?? 0,
    percent: p.percent ?? 0,
    state: p.state ?? "not-started",
    lastTouchedAt: p.lastTouchedAt ?? null,
    formationSlug: p.formationSlug,
  };
}

describe("getUnlockMode / isFlexibleUnlockFormation", () => {
  it("Capacité ≤ 3,5t est flexible, le reste strict", () => {
    expect(getUnlockMode("capacite-3-5t")).toBe("flexible");
    expect(getUnlockMode("gotrm")).toBe("strict");
    expect(getUnlockMode(null)).toBe("strict");
    expect(getUnlockMode(undefined)).toBe("strict");
    expect(isFlexibleUnlockFormation("capacite-3-5t")).toBe(true);
    expect(isFlexibleUnlockFormation("gotrm")).toBe(false);
  });
});

describe("getModuleKind", () => {
  it("détecte final / exam / course via le slug", () => {
    expect(getModuleKind("msp-final")).toBe("final");
    expect(getModuleKind("dossier-pro-gotrm")).toBe("final");
    expect(getModuleKind("examen-blanc-synthese")).toBe("exam");
    expect(getModuleKind("capa-examen-blanc-final")).toBe("exam");
    expect(getModuleKind("capa-droit-civil-commercial")).toBe("course");
  });
});

describe("computeModuleState — mode strict", () => {
  it("done seulement si leçons faites ET quiz tous réussis (avec tentative)", () => {
    expect(
      computeModuleState({
        lessonsTotal: 3, lessonsDone: 3,
        quizzesTotal: 1, quizzesPassed: 1,
        hasAnyAttempt: true, unlockMode: "strict",
      }),
    ).toBe("done");
  });

  it("PAS done si quiz seulement essayé mais raté (strict)", () => {
    expect(
      computeModuleState({
        lessonsTotal: 3, lessonsDone: 3,
        quizzesTotal: 1, quizzesPassed: 0, quizzesAttempted: 1,
        hasAnyAttempt: true, unlockMode: "strict",
      }),
    ).toBe("in-progress");
  });

  it("not-started si module vide", () => {
    expect(
      computeModuleState({
        lessonsTotal: 0, lessonsDone: 0, quizzesTotal: 0, quizzesPassed: 0,
        hasAnyAttempt: false,
      }),
    ).toBe("not-started");
  });
});

describe("computeModuleState — mode flexible (Capacité)", () => {
  it("done si leçons faites ET quiz essayés, même ratés", () => {
    expect(
      computeModuleState({
        lessonsTotal: 3, lessonsDone: 3,
        quizzesTotal: 2, quizzesPassed: 0, quizzesAttempted: 2,
        hasAnyAttempt: true, unlockMode: "flexible",
      }),
    ).toBe("done");
  });

  it("PAS done si un quiz n'a pas été essayé", () => {
    expect(
      computeModuleState({
        lessonsTotal: 3, lessonsDone: 3,
        quizzesTotal: 2, quizzesPassed: 0, quizzesAttempted: 1,
        hasAnyAttempt: true, unlockMode: "flexible",
      }),
    ).toBe("in-progress");
  });
});

describe("computeModulePercent", () => {
  it("pondère 50/50 leçons et quiz quand les deux existent", () => {
    expect(
      computeModulePercent({
        lessonsTotal: 4, lessonsDone: 2, quizzesTotal: 2, quizzesPassed: 1,
      }),
    ).toBe(50);
  });
  it("100% sur la seule dimension présente", () => {
    expect(
      computeModulePercent({ lessonsTotal: 5, lessonsDone: 5, quizzesTotal: 0, quizzesPassed: 0 }),
    ).toBe(100);
  });
  it("flexible pondère sur quizzesAttempted", () => {
    expect(
      computeModulePercent({
        lessonsTotal: 0, lessonsDone: 0,
        quizzesTotal: 4, quizzesPassed: 0, quizzesAttempted: 2,
        unlockMode: "flexible",
      }),
    ).toBe(50);
  });
});

describe("applyLinearLocking", () => {
  it("verrouille les modules course après le 1er non terminé", () => {
    const out = applyLinearLocking([
      mod({ id: "A", order: 10, state: "done" }),
      mod({ id: "B", order: 20, state: "not-started" }),
      mod({ id: "C", order: 30, state: "not-started" }),
    ]);
    const byId = Object.fromEntries(out.map((m) => [m.id, m.state]));
    expect(byId.A).toBe("done");
    expect(byId.B).toBe("not-started"); // accessible
    expect(byId.C).toBe("locked"); // verrouillé tant que B pas done
  });

  it("le 1er module est toujours déverrouillé", () => {
    const out = applyLinearLocking([
      mod({ id: "A", order: 10, state: "not-started" }),
      mod({ id: "B", order: 20, state: "not-started" }),
    ]);
    expect(out.find((m) => m.id === "A")!.state).toBe("not-started");
    expect(out.find((m) => m.id === "B")!.state).toBe("locked");
  });

  it("un examen est verrouillé tant que tous les courses ne sont pas done", () => {
    const out = applyLinearLocking([
      mod({ id: "A", order: 10, state: "done" }),
      mod({ id: "B", order: 20, state: "not-started" }),
      mod({ id: "EX", order: 30, kind: "exam", state: "not-started" }),
    ]);
    expect(out.find((m) => m.id === "EX")!.state).toBe("locked");
  });

  it("l'examen se déverrouille quand tous les courses sont done", () => {
    const out = applyLinearLocking([
      mod({ id: "A", order: 10, state: "done" }),
      mod({ id: "B", order: 20, state: "done" }),
      mod({ id: "EX", order: 30, kind: "exam", state: "not-started" }),
    ]);
    expect(out.find((m) => m.id === "EX")!.state).toBe("not-started");
  });

  it("ne mute pas l'entrée d'origine (pureté)", () => {
    const input = [mod({ id: "A", order: 10, state: "done" }), mod({ id: "B", order: 20, state: "not-started" }), mod({ id: "C", order: 30, state: "not-started" })];
    const snapshot = input.map((m) => m.state);
    applyLinearLocking(input);
    expect(input.map((m) => m.state)).toEqual(snapshot);
  });
});

describe("pickNextModule", () => {
  it("privilégie le module in-progress le plus récemment touché", () => {
    const next = pickNextModule([
      mod({ id: "A", order: 10, state: "in-progress", lastTouchedAt: "2026-05-01" }),
      mod({ id: "B", order: 20, state: "in-progress", lastTouchedAt: "2026-05-10" }),
      mod({ id: "C", order: 30, state: "not-started" }),
    ]);
    expect(next?.id).toBe("B");
  });

  it("sinon le 1er not-started par ordre", () => {
    const next = pickNextModule([
      mod({ id: "B", order: 20, state: "not-started" }),
      mod({ id: "A", order: 10, state: "not-started" }),
    ]);
    expect(next?.id).toBe("A");
  });

  it("null si tout est done", () => {
    expect(
      pickNextModule([mod({ id: "A", order: 10, state: "done" })]),
    ).toBeNull();
  });
});
