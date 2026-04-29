import { test, expect } from "@playwright/test";
import { login } from "./helpers/auth";
import { E2E_ENV } from "./helpers/env";

/**
 * E2E — Messagerie formateur ↔ stagiaire :
 *   1. Stagiaire envoie un message
 *   2. Formateur retrouve la conversation et répond
 *   3. Stagiaire voit la réponse
 */

test.describe("Messagerie formateur ↔ stagiaire", () => {
  const stamp = Date.now();
  const studentMsg = `[E2E ${stamp}] Bonjour, question test`;
  const trainerReply = `[E2E ${stamp}] Réponse formateur`;

  test("le stagiaire envoie un message", async ({ page }) => {
    await login(page, E2E_ENV.studentEmail(), E2E_ENV.studentPassword());
    await page.goto("/messages");

    const textarea = page.locator("textarea").first();
    await textarea.fill(studentMsg);
    await page.getByRole("button").last().click(); // bouton Send (icône)

    await expect(page.getByText(studentMsg)).toBeVisible({ timeout: 10_000 });
  });

  test("le formateur retrouve et répond", async ({ page }) => {
    await login(page, E2E_ENV.trainerEmail(), E2E_ENV.trainerPassword());
    await page.goto("/formateur/messages");

    // Clic sur la 1ʳᵉ conversation
    const firstConv = page
      .locator("a[href*='/formateur/messages/']")
      .first();
    await expect(firstConv).toBeVisible({ timeout: 10_000 });
    await firstConv.click();

    // Le message stagiaire doit être visible
    await expect(page.getByText(studentMsg)).toBeVisible({ timeout: 10_000 });

    // Réponse du formateur
    const textarea = page.locator("textarea").first();
    await textarea.fill(trainerReply);
    await page.getByRole("button").last().click();

    await expect(page.getByText(trainerReply)).toBeVisible({ timeout: 10_000 });
  });

  test("le stagiaire reçoit la réponse", async ({ page }) => {
    await login(page, E2E_ENV.studentEmail(), E2E_ENV.studentPassword());
    await page.goto("/messages");
    await expect(page.getByText(trainerReply)).toBeVisible({ timeout: 10_000 });
  });
});
