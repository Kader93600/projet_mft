import { describe, it, expect } from "vitest";
import {
  fileKind,
  isAcceptedFile,
  formatBytes,
  reasonLabel,
  isValidReason,
} from "./student-documents";

describe("student-documents config", () => {
  it("déduit le type de fichier depuis l'extension", () => {
    expect(fileKind("rapport.pdf")).toBe("pdf");
    expect(fileKind("CV.DOCX")).toBe("word");
    expect(fileKind("notes.doc")).toBe("word");
    expect(fileKind("budget.xlsx")).toBe("excel");
    expect(fileKind("photo.JPG")).toBe("image");
    expect(fileKind("scan.png")).toBe("image");
    expect(fileKind("archive.zip")).toBe("other");
    expect(fileKind("sansext")).toBe("other");
  });

  it("n'accepte que la liste blanche", () => {
    expect(isAcceptedFile("a.pdf")).toBe(true);
    expect(isAcceptedFile("a.jpeg")).toBe(true);
    expect(isAcceptedFile("a.xls")).toBe(true);
    expect(isAcceptedFile("a.zip")).toBe(false);
    expect(isAcceptedFile("a.exe")).toBe(false);
    expect(isAcceptedFile("a.svg")).toBe(false);
  });

  it("formate les tailles", () => {
    expect(formatBytes(0)).toBe("0 o");
    expect(formatBytes(512)).toBe("512 o");
    expect(formatBytes(1024)).toBe("1 Ko");
    expect(formatBytes(1536)).toBe("1.5 Ko");
    expect(formatBytes(5 * 1024 * 1024)).toBe("5 Mo");
  });

  it("résout le libellé du motif (dont Autres)", () => {
    expect(reasonLabel("attestation")).toBe("Attestation");
    expect(reasonLabel("autres", "Mon motif perso")).toBe("Mon motif perso");
    expect(reasonLabel("autres", "")).toBe("Autres");
    expect(isValidReason("contrat")).toBe(true);
    expect(isValidReason("inexistant")).toBe(false);
  });
});
