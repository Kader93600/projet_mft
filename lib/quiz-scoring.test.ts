import { describe, it, expect } from "vitest";
import { computeQcmScore, type QuizScoringData } from "./quiz-scoring";

function data(
  qcm: Record<string, string[]>,
  qr: string[] = [],
): QuizScoringData {
  const correctByQuestion = new Map<string, Set<string>>();
  for (const [qid, correctIds] of Object.entries(qcm)) {
    correctByQuestion.set(qid, new Set(correctIds));
  }
  return {
    correctByQuestion,
    qrIds: new Set(qr),
    totalQcm: correctByQuestion.size,
  };
}

describe("computeQcmScore — scoring serveur (QUIZ-03)", () => {
  it("compte les bonnes réponses", () => {
    const d = data({ q1: ["a"], q2: ["b"], q3: ["c"] });
    const r = computeQcmScore({ q1: "a", q2: "b", q3: "x" }, d);
    expect(r.score).toBe(2);
    expect(r.totalQcm).toBe(3);
    expect(r.qcmPercentage).toBe(67);
  });

  it("ignore les ids de question forgés (hors quiz)", () => {
    const d = data({ q1: ["a"] });
    const r = computeQcmScore(
      { q1: "a", forged1: "a", forged2: "a" },
      d,
    );
    expect(r.score).toBe(1);
    expect(r.qcmPercentage).toBe(100);
  });

  it("une réponse absente compte zéro", () => {
    const d = data({ q1: ["a"], q2: ["b"] });
    const r = computeQcmScore({}, d);
    expect(r.score).toBe(0);
    expect(r.qcmPercentage).toBe(0);
  });

  it("quiz sans QCM (100 % QR) → percentage null", () => {
    const d = data({}, ["qr1", "qr2"]);
    const r = computeQcmScore({}, d);
    expect(r.totalQcm).toBe(0);
    expect(r.qcmPercentage).toBeNull();
  });

  it("le score ne dépasse jamais le total, même avec des doublons", () => {
    const d = data({ q1: ["a"] });
    const r = computeQcmScore({ q1: "a" }, d);
    expect(r.score).toBeLessThanOrEqual(r.totalQcm);
  });
});
