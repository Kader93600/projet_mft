import { describe, it, expect } from "vitest";
import {
  buildQuestionGenSystem,
  buildQuestionGenUserMessage,
  parseGeneratedQuestions,
} from "./question-gen";

const valid = JSON.stringify({
  questions: [
    {
      statement: "Quelle est la durée légale de conduite continue ?",
      choices: [
        { label: "4h30", is_correct: true },
        { label: "6h", is_correct: false },
        { label: "3h", is_correct: false },
        { label: "5h", is_correct: false },
      ],
      explanation: "La pause est obligatoire après 4h30.",
      difficulty: "moyen",
    },
  ],
});

describe("buildQuestionGenSystem / userMessage", () => {
  it("inclut le nombre demandé et le contexte formation", () => {
    const s = buildQuestionGenSystem({ count: 5, formationTitle: "Capacité" });
    expect(s).toContain("5 questions");
    expect(s).toContain("Capacité");
    expect(s).toContain("JSON");
  });
  it("tronque le contenu de leçon", () => {
    const msg = buildQuestionGenUserMessage("Leçon", "x".repeat(10000), 100);
    expect(msg).toContain("Leçon");
    // 100 chars de contenu max (+ le reste du gabarit)
    expect((msg.match(/x/g) ?? []).length).toBe(100);
  });
});

describe("parseGeneratedQuestions", () => {
  it("parse un JSON valide", () => {
    const qs = parseGeneratedQuestions(valid);
    expect(qs).toHaveLength(1);
    expect(qs[0].statement).toContain("conduite continue");
    expect(qs[0].choices).toHaveLength(4);
    expect(qs[0].choices.filter((c) => c.is_correct)).toHaveLength(1);
    expect(qs[0].difficulty).toBe("moyen");
  });

  it("gère le JSON encadré de markdown ```json", () => {
    const qs = parseGeneratedQuestions("Voici :\n```json\n" + valid + "\n```");
    expect(qs).toHaveLength(1);
  });

  it("gère un tableau racine sans clé questions", () => {
    const arr = JSON.parse(valid).questions;
    expect(parseGeneratedQuestions(JSON.stringify(arr))).toHaveLength(1);
  });

  it("ignore une question SANS bonne réponse", () => {
    const bad = JSON.stringify({
      questions: [
        {
          statement: "Question sans bonne réponse",
          choices: [
            { label: "A", is_correct: false },
            { label: "B", is_correct: false },
          ],
          difficulty: "facile",
        },
      ],
    });
    expect(parseGeneratedQuestions(bad)).toHaveLength(0);
  });

  it("ignore une question avec PLUSIEURS bonnes réponses", () => {
    const bad = JSON.stringify({
      questions: [
        {
          statement: "Deux bonnes réponses",
          choices: [
            { label: "A", is_correct: true },
            { label: "B", is_correct: true },
          ],
        },
      ],
    });
    expect(parseGeneratedQuestions(bad)).toHaveLength(0);
  });

  it("normalise une difficulté inconnue vers 'moyen'", () => {
    const obj = JSON.parse(valid);
    obj.questions[0].difficulty = "extreme";
    expect(parseGeneratedQuestions(JSON.stringify(obj))[0].difficulty).toBe(
      "moyen",
    );
  });

  it("retourne [] sur réponse non-parsable", () => {
    expect(parseGeneratedQuestions("désolé, je ne peux pas")).toEqual([]);
  });

  it("filtre les propositions vides et rejette si <2 valides", () => {
    const bad = JSON.stringify({
      questions: [
        {
          statement: "Une seule proposition valide",
          choices: [
            { label: "A", is_correct: true },
            { label: "", is_correct: false },
          ],
        },
      ],
    });
    expect(parseGeneratedQuestions(bad)).toHaveLength(0);
  });
});
