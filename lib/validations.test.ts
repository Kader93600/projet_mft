import { describe, it, expect } from "vitest";
import {
  validateUpload,
  choicesArraySchema,
  enrollmentSchema,
  enrollmentRequestSchema,
  surveySchema,
  placementQuestionSchema,
  funderSchema,
  formatZodError,
  MAX_UPLOAD_SIZE,
} from "./validations";

// Petit faux File (jsdom fournit File, mais on contrôle size/type/name).
function fakeFile(name: string, type: string, size: number): File {
  const f = new File(["x"], name, { type });
  Object.defineProperty(f, "size", { value: size });
  return f;
}

describe("validateUpload (sécurité)", () => {
  it("accepte une image valide et renvoie l'extension", () => {
    expect(validateUpload(fakeFile("photo.png", "image/png", 1000))).toBe("png");
  });
  it("refuse un fichier trop volumineux", () => {
    expect(() =>
      validateUpload(fakeFile("big.png", "image/png", MAX_UPLOAD_SIZE + 1)),
    ).toThrow(/5 MB/);
  });
  it("refuse un type MIME non autorisé (ex. exécutable)", () => {
    expect(() =>
      validateUpload(fakeFile("x.exe", "application/x-msdownload", 100)),
    ).toThrow(/non autoris/i);
  });
  it("refuse une extension non autorisée même avec un bon MIME", () => {
    expect(() =>
      validateUpload(fakeFile("x.php", "image/png", 100)),
    ).toThrow(/[Ee]xtension/);
  });
});

describe("choicesArraySchema (intégrité QCM)", () => {
  const ok = [
    { label: "A", is_correct: true, order: 0 },
    { label: "B", is_correct: false, order: 1 },
  ];
  it("accepte 2 choix dont une bonne réponse", () => {
    expect(choicesArraySchema.safeParse(ok).success).toBe(true);
  });
  it("refuse moins de 2 choix", () => {
    expect(choicesArraySchema.safeParse([ok[0]]).success).toBe(false);
  });
  it("refuse l'absence de bonne réponse", () => {
    const noCorrect = ok.map((c) => ({ ...c, is_correct: false }));
    const r = choicesArraySchema.safeParse(noCorrect);
    expect(r.success).toBe(false);
  });
  it("refuse plus de 10 choix", () => {
    const many = Array.from({ length: 11 }, (_, i) => ({
      label: `c${i}`,
      is_correct: i === 0,
      order: i,
    }));
    expect(choicesArraySchema.safeParse(many).success).toBe(false);
  });
});

describe("enrollmentSchema (argent / statuts)", () => {
  const base = {
    user_id: "00000000-0000-0000-0000-000000000001",
    funding_kind: "cpf",
    total_amount_cents: 150000,
    status: "en_cours",
  };
  it("accepte une inscription valide", () => {
    expect(enrollmentSchema.safeParse(base).success).toBe(true);
  });
  it("refuse un montant négatif", () => {
    expect(
      enrollmentSchema.safeParse({ ...base, total_amount_cents: -1 }).success,
    ).toBe(false);
  });
  it("refuse un statut inconnu", () => {
    expect(
      enrollmentSchema.safeParse({ ...base, status: "n_importe_quoi" }).success,
    ).toBe(false);
  });
  it("refuse un funding_kind hors enum", () => {
    expect(
      enrollmentSchema.safeParse({ ...base, funding_kind: "bitcoin" }).success,
    ).toBe(false);
  });
});

describe("enrollmentRequestSchema (lead public)", () => {
  it("exige un email valide", () => {
    const r = enrollmentRequestSchema.safeParse({
      full_name: "Jean",
      email: "pas-un-email",
      funding_kind: "cpf",
    });
    expect(r.success).toBe(false);
  });
  it("accepte un lead minimal valide", () => {
    expect(
      enrollmentRequestSchema.safeParse({
        full_name: "Jean Dupont",
        email: "jean@example.fr",
        funding_kind: "auto",
      }).success,
    ).toBe(true);
  });
});

describe("surveySchema", () => {
  const base = {
    type: "chaud",
    note_globale: 4,
    note_contenu: 4,
    note_pedagogie: 4,
    note_plateforme: 4,
    note_accompagnement: 4,
    recommandation: 9,
  };
  it("accepte un retour valide (NPS 0-10, notes 1-5)", () => {
    expect(surveySchema.safeParse(base).success).toBe(true);
    expect(surveySchema.safeParse({ ...base, recommandation: 0 }).success).toBe(
      true,
    );
  });
  it("refuse une note hors 1-5", () => {
    expect(surveySchema.safeParse({ ...base, note_globale: 6 }).success).toBe(
      false,
    );
  });
  it("refuse un NPS > 10", () => {
    expect(
      surveySchema.safeParse({ ...base, recommandation: 11 }).success,
    ).toBe(false);
  });
});

describe("placementQuestionSchema (superRefine)", () => {
  const baseQcm = {
    bloc_id: 1,
    qtype: "qcm",
    formation_slug: "capacite-3-5t",
    prompt: "Question ?",
    choices: ["A", "B", "C"],
    correct_index: 1,
  };
  it("accepte un QCM bien formé", () => {
    expect(placementQuestionSchema.safeParse(baseQcm).success).toBe(true);
  });
  it("refuse un QCM avec moins de 2 choix", () => {
    expect(
      placementQuestionSchema.safeParse({ ...baseQcm, choices: ["A"] }).success,
    ).toBe(false);
  });
  it("refuse un correct_index hors plage", () => {
    expect(
      placementQuestionSchema.safeParse({ ...baseQcm, correct_index: 5 })
        .success,
    ).toBe(false);
  });
  it("exige une image_url pour le type image", () => {
    const r = placementQuestionSchema.safeParse({
      ...baseQcm,
      qtype: "image",
      image_url: null,
    });
    expect(r.success).toBe(false);
  });
});

describe("funderSchema", () => {
  it("tolère un email vide (chaîne vide)", () => {
    expect(
      funderSchema.safeParse({ name: "OPCO X", kind: "opco", contact_email: "" })
        .success,
    ).toBe(true);
  });
  it("refuse un email invalide non vide", () => {
    expect(
      funderSchema.safeParse({
        name: "OPCO X",
        kind: "opco",
        contact_email: "nope",
      }).success,
    ).toBe(false);
  });
});

describe("formatZodError", () => {
  it("formate une erreur Zod en message lisible", () => {
    const r = surveySchema.safeParse({ type: "chaud" });
    expect(r.success).toBe(false);
    if (!r.success) {
      const msg = formatZodError(r.error);
      expect(msg).toContain(":");
      expect(msg.length).toBeGreaterThan(0);
    }
  });
  it("gère une erreur générique non-Zod", () => {
    expect(formatZodError(new Error("boom"))).toBe("boom");
  });
});
