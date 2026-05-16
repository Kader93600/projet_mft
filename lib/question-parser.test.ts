import { describe, it, expect } from "vitest";
import { parseQuestions, findSourcePage } from "./question-parser";

// =====================================================================
// Tests de contrat API : on vérifie le shape, pas les heuristiques de
// parsing précises (qui peuvent évoluer sans casser les consommateurs).
// =====================================================================

describe("parseQuestions — shape de retour", () => {
  it("retourne toujours un objet { questions, summary }", () => {
    const result = parseQuestions("");
    expect(result).toHaveProperty("questions");
    expect(result).toHaveProperty("summary");
    expect(Array.isArray(result.questions)).toBe(true);
  });

  it("summary contient toutes les clés attendues", () => {
    const result = parseQuestions("");
    expect(result.summary).toHaveProperty("total");
    expect(result.summary).toHaveProperty("qcm");
    expect(result.summary).toHaveProperty("qr");
    expect(result.summary).toHaveProperty("withCorrect");
    expect(result.summary).toHaveProperty("withWarnings");
    expect(result.summary).toHaveProperty("detectedFormat");
  });

  it("retourne 0 question pour une chaîne vide", () => {
    const result = parseQuestions("");
    expect(result.questions).toEqual([]);
    expect(result.summary.total).toBe(0);
  });

  it("renumérote les questions à partir de 1 (peu importe l'entrée)", () => {
    const result = parseQuestions(
      "Texte assez long pour être traité comme une question rédigée, " +
        "avec suffisamment de contenu pour passer le seuil minimum de longueur."
    );
    result.questions.forEach((q, i) => {
      expect(q.index).toBe(i + 1);
    });
  });

  it("summary.total est cohérent avec questions.length", () => {
    const result = parseQuestions(
      "Texte assez long pour produire au moins une question de fallback."
    );
    expect(result.summary.total).toBe(result.questions.length);
  });

  it("détecte un format dans { 'exercise', 'qcm_qr', 'numbered', 'unknown', 'empty' }", () => {
    const result = parseQuestions("");
    expect([
      "exercise",
      "qcm_qr",
      "numbered",
      "unknown",
      "empty",
    ]).toContain(result.summary.detectedFormat);
  });
});

describe("findSourcePage", () => {
  it("trouve l'index de la page contenant le needle (1-based)", () => {
    const pages = [
      "introduction au transport routier",
      "chapitre sur les véhicules lourds",
      "réponses aux questions du chapitre",
    ];
    expect(findSourcePage(pages, "véhicules")).toBe(2);
    expect(findSourcePage(pages, "introduction")).toBe(1);
    expect(findSourcePage(pages, "réponses")).toBe(3);
  });

  it("retourne null si needle introuvable", () => {
    const pages = ["Page A", "Page B"];
    expect(findSourcePage(pages, "absent du texte")).toBe(null);
  });

  it("retourne null pour un needle vide ou trop court (< 4 chars)", () => {
    const pages = ["contenu de test"];
    expect(findSourcePage(pages, "")).toBe(null);
    expect(findSourcePage(pages, "abc")).toBe(null);
  });

  it("recherche insensible à la casse", () => {
    const pages = ["VEHICULES de transport"];
    expect(findSourcePage(pages, "vehicules")).toBe(1);
    expect(findSourcePage(pages, "VEHICULES")).toBe(1);
  });

  it("retourne null pour une liste de pages vide", () => {
    expect(findSourcePage([], "anything")).toBe(null);
  });
});
