import { describe, it, expect } from "vitest";
import {
  canTransition,
  isTerminal,
  canAccept,
  canRefuse,
  canDeclareEntry,
  canDeclareServiceFait,
  edofStatusToMft,
  nextActionLabel,
} from "./state-machine";

describe("canTransition / cycle de vie EDOF", () => {
  it("autorise les transitions valides", () => {
    expect(canTransition("recu", "accepte")).toBe(true);
    expect(canTransition("recu", "refuse")).toBe(true);
    expect(canTransition("accepte", "entree_declaree")).toBe(true);
    expect(canTransition("entree_declaree", "en_cours")).toBe(true);
    expect(canTransition("en_cours", "service_fait")).toBe(true);
    expect(canTransition("service_fait", "solde")).toBe(true);
  });

  it("interdit les transitions invalides (sauts d'étapes)", () => {
    expect(canTransition("recu", "service_fait")).toBe(false);
    expect(canTransition("recu", "solde")).toBe(false);
    expect(canTransition("accepte", "service_fait")).toBe(false);
  });

  it("annulation possible jusqu'à en_cours, pas après service_fait", () => {
    expect(canTransition("recu", "annule")).toBe(true);
    expect(canTransition("en_cours", "annule")).toBe(true);
    expect(canTransition("service_fait", "annule")).toBe(false);
  });

  it("identifie les états terminaux", () => {
    expect(isTerminal("refuse")).toBe(true);
    expect(isTerminal("annule")).toBe(true);
    expect(isTerminal("solde")).toBe(true);
    expect(isTerminal("recu")).toBe(false);
    expect(isTerminal("en_cours")).toBe(false);
  });
});

describe("guards d'action", () => {
  it("accepter/refuser uniquement à l'état reçu", () => {
    expect(canAccept("recu")).toBe(true);
    expect(canRefuse("recu")).toBe(true);
    expect(canAccept("accepte")).toBe(false);
    expect(canRefuse("en_cours")).toBe(false);
  });
  it("déclarer entrée à l'état accepté ; service fait en cours", () => {
    expect(canDeclareEntry("accepte")).toBe(true);
    expect(canDeclareEntry("recu")).toBe(false);
    expect(canDeclareServiceFait("en_cours")).toBe(true);
    expect(canDeclareServiceFait("accepte")).toBe(false);
  });
});

describe("edofStatusToMft", () => {
  it("mappe vers les statuts d'inscription MFT", () => {
    expect(edofStatusToMft("recu")).toBe("prospect");
    expect(edofStatusToMft("accepte")).toBe("en_cours");
    expect(edofStatusToMft("en_cours")).toBe("en_cours");
    expect(edofStatusToMft("service_fait")).toBe("termine");
    expect(edofStatusToMft("solde")).toBe("termine");
    expect(edofStatusToMft("refuse")).toBe("refuse");
    expect(edofStatusToMft("annule")).toBe("abandon");
  });
});

describe("nextActionLabel", () => {
  it("propose la prochaine action selon l'état", () => {
    expect(nextActionLabel("recu")).toMatch(/traiter/i);
    expect(nextActionLabel("accepte")).toMatch(/entrée/i);
    expect(nextActionLabel("en_cours")).toMatch(/service fait/i);
    expect(nextActionLabel("refuse")).toBeNull();
    expect(nextActionLabel("solde")).toBeNull();
  });
});
