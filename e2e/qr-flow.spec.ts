import { test, expect } from "@playwright/test";
import { login } from "./helpers/auth";
import { E2E_ENV } from "./helpers/env";

/**
 * E2E — Flux QR complet :
 *   1. Stagiaire passe un quiz mixte (QCM + QR)
 *   2. Soumission → statut "awaiting_review"
 *   3. Formateur ouvre la copie, note la QR, finalise
 *   4. Stagiaire voit son score corrigé
 *
 * Ces tests partagent un quiz pré-existant en BDD (E2E_QUIZ_ID) et
 * deux comptes (E2E_STUDENT_*, E2E_TRAINER_*). Voir e2e/README.md.
 */

const QUIZ_ID = () => E2E_ENV.quizId();

test.describe("Flux QR end-to-end", () => {
  test("le stagiaire peut passer un quiz mixte et soumet sa copie", async ({
    page,
  }) => {
    await login(page, E2E_ENV.studentEmail(), E2E_ENV.studentPassword());

    await page.goto(`/quiz/${QUIZ_ID()}`);

    // Landing du quiz : vérifier la présence du badge formation
    await expect(
      page.getByRole("button", { name: /démarrer/i })
    ).toBeVisible();

    // Démarrer
    await page.getByRole("button", { name: /démarrer/i }).click();

    // Boucle : pour chaque question, cocher la 1ʳᵉ option (QCM) ou
    // saisir une réponse (QR), puis "Suivant"
    let safety = 0;
    while (safety++ < 50) {
      const textarea = page.getByPlaceholder(/rédigez votre réponse/i);
      if (await textarea.isVisible().catch(() => false)) {
        await textarea.fill(
          "Réponse de test E2E — argumentaire pédagogique synthétique."
        );
      } else {
        // QCM : sélectionner la 1ʳᵉ option visible
        const choice = page.locator('input[type="radio"]').first();
        if (await choice.isVisible().catch(() => false)) {
          await choice.check();
        }
      }

      const next = page.getByRole("button", { name: /^suivant$/i });
      if (await next.isVisible().catch(() => false)) {
        await next.click();
        continue;
      }

      // Dernière question → relecture
      const review = page.getByRole("button", {
        name: /relecture.*validation/i,
      });
      if (await review.isVisible().catch(() => false)) {
        await review.click();
        break;
      }
      break;
    }

    // Écran de relecture → valider définitivement
    await page
      .getByRole("button", { name: /valider définitivement/i })
      .click();

    // Redirection vers la page résultats
    await page.waitForURL(/\/quiz\/results\/.+/, { timeout: 30_000 });

    // Si le quiz contient des QR, on doit voir un état "en attente"
    await expect(
      page.getByText(/en attente.*correction|copie.*corriger/i).first()
    ).toBeVisible({ timeout: 10_000 });
  });

  test("le formateur voit la copie en attente et peut la corriger", async ({
    page,
  }) => {
    await login(page, E2E_ENV.trainerEmail(), E2E_ENV.trainerPassword());

    await page.goto("/formateur/corrections");
    // Au moins une copie à corriger
    const firstRow = page.locator("a[href*='/formateur/corrections/']").first();
    await expect(firstRow).toBeVisible({ timeout: 15_000 });
    await firstRow.click();

    // Page de correction : noter chaque QR avec un score plein
    const scoreInputs = page.locator('input[type="number"]');
    const count = await scoreInputs.count();
    expect(count).toBeGreaterThan(0);
    for (let i = 0; i < count; i++) {
      await scoreInputs.nth(i).fill("3");
    }

    // Saisir un feedback global (textarea)
    const feedback = page.locator("textarea").first();
    if (await feedback.isVisible().catch(() => false)) {
      await feedback.fill("Correction E2E : OK");
    }

    // Finaliser
    const finalize = page.getByRole("button", {
      name: /finaliser|valider.*correction/i,
    });
    await finalize.click();

    // Confirmation visible
    await expect(
      page.getByText(/copie.*corrigée|finalisée|envoyée au stagiaire/i).first()
    ).toBeVisible({ timeout: 15_000 });
  });

  test("le stagiaire voit son résultat finalisé", async ({ page }) => {
    await login(page, E2E_ENV.studentEmail(), E2E_ENV.studentPassword());

    // On va sur l'historique des quiz / dashboard et on clique sur la copie
    await page.goto("/dashboard");
    await page.goto(`/quiz/${QUIZ_ID()}`);

    // Le bouton "Voir mes résultats" / lien doit apparaître
    const result = page.getByRole("link", { name: /résultat|voir.*copie/i });
    if (await result.isVisible().catch(() => false)) {
      await result.click();
      await expect(page).toHaveURL(/\/quiz\/results\/.+/);
    }

    // Le score doit être affiché (% visible)
    await expect(page.locator("text=/%/").first()).toBeVisible();
  });
});
