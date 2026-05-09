import { test, expect } from "@playwright/test";
import { login } from "./helpers/auth";
import { E2E_ENV } from "./helpers/env";

/**
 * E2E — Messagerie formateur ↔ stagiaire (UI multi-conv refondue) :
 *   1. Stagiaire ouvre la DM avec son formateur et envoie un message
 *   2. Formateur retrouve la conversation et répond
 *   3. Stagiaire voit la réponse
 *
 * Pré-requis seed : la conv DM stagiaire ↔ formateur existe déjà (créée
 * par e2e_seed.sql section 7b). Les profils ont des full_name
 * "Stagiaire E2E" et "Formateur E2E".
 *
 * Astuce envoi : on utilise Enter (raccourci clavier supporté par le
 * composer) au lieu de cliquer le bouton Envoyer. Plus stable car le
 * bouton se ré-render disabled juste après l'envoi, ce qui peut tromper
 * la logique d'auto-retry de Playwright.
 */

test.describe("Messagerie formateur ↔ stagiaire", () => {
  const stamp = Date.now();
  const studentMsg = `[E2E ${stamp}] Bonjour, question test`;
  const trainerReply = `[E2E ${stamp}] Réponse formateur`;

  test("le stagiaire envoie un message", async ({ page }) => {
    await login(page, E2E_ENV.studentEmail(), E2E_ENV.studentPassword());
    await page.goto("/messages");

    // Sidebar : clic sur la DM avec "Formateur E2E"
    const dmButton = page
      .getByRole("button", { name: /Formateur E2E/i })
      .first();
    await expect(dmButton).toBeVisible({ timeout: 15_000 });
    await dmButton.click();

    // Composer affiché après sélection
    const textarea = page.getByPlaceholder(/écrire|écrivez/i).first();
    await expect(textarea).toBeVisible({ timeout: 5_000 });
    await textarea.fill(studentMsg);
    // Envoi via Enter (le composer le supporte). Plus stable que le
    // click sur l'icône qui devient disabled juste après l'envoi.
    await textarea.press("Enter");

    await expect(page.getByText(studentMsg)).toBeVisible({ timeout: 10_000 });
  });

  test("le formateur retrouve et répond", async ({ page }) => {
    await login(page, E2E_ENV.trainerEmail(), E2E_ENV.trainerPassword());
    await page.goto("/formateur/messages");

    // Clic sur la DM avec "Stagiaire E2E"
    const dmButton = page
      .getByRole("button", { name: /Stagiaire E2E/i })
      .first();
    await expect(dmButton).toBeVisible({ timeout: 15_000 });
    await dmButton.click();

    // Le message stagiaire doit être visible dans le thread
    await expect(page.getByText(studentMsg)).toBeVisible({ timeout: 10_000 });

    // Réponse via Enter
    const textarea = page.getByPlaceholder(/écrire|écrivez/i).first();
    await expect(textarea).toBeVisible({ timeout: 5_000 });
    await textarea.fill(trainerReply);
    await textarea.press("Enter");

    await expect(page.getByText(trainerReply)).toBeVisible({ timeout: 10_000 });
  });

  test("le stagiaire reçoit la réponse", async ({ page }) => {
    await login(page, E2E_ENV.studentEmail(), E2E_ENV.studentPassword());
    await page.goto("/messages");

    // Re-ouvre la même DM pour voir la réponse
    const dmButton = page
      .getByRole("button", { name: /Formateur E2E/i })
      .first();
    await expect(dmButton).toBeVisible({ timeout: 15_000 });
    await dmButton.click();

    await expect(page.getByText(trainerReply)).toBeVisible({ timeout: 10_000 });
  });
});
