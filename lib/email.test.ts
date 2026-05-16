import { describe, it, expect } from "vitest";
import {
  welcomeEmail,
  paymentReceivedEmail,
  inactivityReminderEmail,
  copyGradedEmail,
  newCopyToGradeEmail,
} from "./email";

// =====================================================================
// Tests des templates email — vérifie que chaque template retourne
// { subject, html } avec les bonnes données substituées dans le HTML.
// =====================================================================

describe("welcomeEmail", () => {
  it("retourne un objet { subject, html } non vide", () => {
    const tmpl = welcomeEmail({
      fullName: "Jean Dupont",
      loginUrl: "https://maformationtransport.fr/login",
    });
    expect(tmpl.subject).toBeTruthy();
    expect(tmpl.html).toBeTruthy();
    expect(tmpl.html.length).toBeGreaterThan(100);
  });

  it("inclut le prénom (premier mot du fullName)", () => {
    const tmpl = welcomeEmail({
      fullName: "Jean Dupont",
      loginUrl: "https://x.fr/login",
    });
    expect(tmpl.html).toContain("Jean");
  });

  it("inclut l'URL de login", () => {
    const tmpl = welcomeEmail({
      fullName: "Test",
      loginUrl: "https://maformationtransport.fr/login",
    });
    expect(tmpl.html).toContain("https://maformationtransport.fr/login");
  });

  it("a un subject brandé MFT", () => {
    const tmpl = welcomeEmail({ fullName: "Test", loginUrl: "x" });
    expect(tmpl.subject.toLowerCase()).toMatch(/(formation|bienvenue)/);
  });

  it("fallback 'stagiaire' si fullName est vide", () => {
    const tmpl = welcomeEmail({ fullName: "", loginUrl: "x" });
    expect(tmpl.html).toContain("stagiaire");
  });
});

describe("paymentReceivedEmail", () => {
  it("inclut le prénom et le montant formaté", () => {
    const tmpl = paymentReceivedEmail({
      fullName: "Alice",
      amountCents: 99900,
      loginUrl: "https://maformationtransport.fr/login",
    });
    expect(tmpl.html).toContain("Alice");
    // 999,00 € (format français)
    expect(tmpl.html).toMatch(/999/);
  });

  it("a un subject explicite", () => {
    const tmpl = paymentReceivedEmail({
      fullName: "X",
      amountCents: 1000,
      loginUrl: "x",
    });
    expect(tmpl.subject.length).toBeGreaterThan(5);
  });

  it("supporte un invoiceUrl optionnel", () => {
    const tmpl = paymentReceivedEmail({
      fullName: "X",
      amountCents: 5000,
      loginUrl: "x",
      invoiceUrl: "https://maformationtransport.fr/invoices/42.pdf",
    });
    expect(tmpl.html).toContain("/invoices/42.pdf");
  });

  it("fonctionne sans fullName (anonyme)", () => {
    const tmpl = paymentReceivedEmail({
      amountCents: 12345,
      loginUrl: "x",
    });
    expect(tmpl.html).toBeTruthy();
  });
});

describe("inactivityReminderEmail", () => {
  it("inclut le nombre de jours d'inactivité", () => {
    const tmpl = inactivityReminderEmail({
      fullName: "Bob",
      daysInactive: 21,
      dashboardUrl: "https://x.fr/dashboard",
    });
    expect(tmpl.html).toContain("21");
    expect(tmpl.html).toContain("Bob");
  });

  it("arrondit le nombre de jours décimaux", () => {
    const tmpl = inactivityReminderEmail({
      fullName: "X",
      daysInactive: 14.7,
      dashboardUrl: "x",
    });
    expect(tmpl.html).toContain("15"); // round(14.7) = 15
  });

  it("fonctionne sans fullName", () => {
    const tmpl = inactivityReminderEmail({
      daysInactive: 7,
      dashboardUrl: "x",
    });
    expect(tmpl.html).toBeTruthy();
  });
});

describe("copyGradedEmail", () => {
  it("affiche le score final et le titre du quiz", () => {
    const tmpl = copyGradedEmail({
      fullName: "Charlie",
      quizTitle: "Examen blanc CCP1",
      scorePct: 78,
      passed: true,
      resultsUrl: "https://x.fr/quiz/results/abc",
    });
    expect(tmpl.html).toContain("Charlie");
    expect(tmpl.html).toContain("Examen blanc CCP1");
    expect(tmpl.html).toContain("78");
  });

  it("inclut l'URL des résultats", () => {
    const tmpl = copyGradedEmail({
      fullName: "X",
      quizTitle: "Y",
      scorePct: 50,
      passed: false,
      resultsUrl: "https://specific-url.example/results/123",
    });
    expect(tmpl.html).toContain("https://specific-url.example/results/123");
  });
});

describe("newCopyToGradeEmail (notif formateur)", () => {
  it("indique le stagiaire dont la copie est à corriger", () => {
    const tmpl = newCopyToGradeEmail({
      trainerName: "Mme Martin",
      studentName: "Élève Test",
      quizTitle: "QR Examen",
      correctionUrl: "https://x.fr/formateur/corrections/123",
    });
    expect(tmpl.html).toContain("Élève Test");
    expect(tmpl.html).toContain("QR Examen");
    expect(tmpl.html).toContain("https://x.fr/formateur/corrections/123");
  });
});

describe("Sécurité — échappement HTML dans les templates", () => {
  it("welcomeEmail échappe les caractères dangereux dans fullName", () => {
    const tmpl = welcomeEmail({
      fullName: "<script>alert('xss')</script>",
      loginUrl: "https://x.fr",
    });
    expect(tmpl.html).not.toContain("<script>alert");
    expect(tmpl.html).toMatch(/&lt;script&gt;|&amp;lt;/);
  });
});
