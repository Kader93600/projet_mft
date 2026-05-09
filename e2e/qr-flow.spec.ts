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
        // QCM : sélectionner la 1ʳᵉ option (boutons custom avec
        // data-testid="quiz-choice", pas de <input type="radio">)
        const choice = page.locator('[data-testid="quiz-choice"]').first();
        if (await choice.isVisible().catch(() => false)) {
          await choice.click();
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

    // Diagnostic : si la redirection ne se fait pas, on dump le texte
    // visible (souvent un setSubmitError() RLS / contrainte) avant de
    // remonter le timeout.
    try {
      await page.waitForURL(/\/quiz\/results\/.+/, { timeout: 15_000 });
    } catch (err) {
      const visibleText = await page.locator("body").innerText();
      // eslint-disable-next-line no-console
      console.log(
        "\n[E2E DEBUG submit failed] visible text on screen:\n" +
          visibleText.slice(0, 2500) +
          "\n[/E2E DEBUG]\n"
      );
      throw err;
    }

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

    // Cible spécifiquement la copie du stagiaire E2E (et pas une autre
    // copie ancienne déjà corrigée qui pourrait apparaître en premier
    // dans le DOM).
    const e2eRow = page
      .locator("a[href*='/formateur/corrections/']")
      .filter({ hasText: /Stagiaire E2E/i })
      .first();
    await expect(e2eRow).toBeVisible({ timeout: 15_000 });
    await e2eRow.click();

    // Attend que les inputs de scoring apparaissent. La page peut
    // mettre un peu de temps à charger les qr_responses (joins SQL).
    const scoreInputs = page.locator('input[type="number"]');
    try {
      await expect(scoreInputs.first()).toBeVisible({ timeout: 15_000 });
    } catch (err) {
      // Diagnostic : dump du contenu visible pour comprendre où on est
      const url = page.url();
      const visibleText = await page.locator("body").innerText();
      // eslint-disable-next-line no-console
      console.log(
        "\n[E2E DEBUG correction page failed]" +
          "\nURL: " +
          url +
          "\n--- VISIBLE TEXT ---\n" +
          visibleText.slice(0, 3000) +
          "\n[/E2E DEBUG]\n"
      );
      throw err;
    }
    const count = await scoreInputs.count();
    expect(count).toBeGreaterThan(0);

    // Pour chaque QR : fill le score puis click "Noter cette réponse"
    // (chaque carte a son propre bouton ; après save il passe à
    // "Modifier la note" → on cible toujours le 1er restant non noté).
    for (let i = 0; i < count; i++) {
      await scoreInputs.nth(i).fill("3");
      const noteBtn = page
        .getByRole("button", { name: /noter cette réponse/i })
        .first();
      await noteBtn.click();
      // Petite pause pour laisser le state se propager
      await page.waitForTimeout(600);
    }

    // Saisir un feedback global (textarea de finalisation)
    const feedback = page.locator("textarea").first();
    if (await feedback.isVisible().catch(() => false)) {
      await feedback.fill("Correction E2E : OK");
    }

    // Finaliser (le bouton ne s'active qu'après que toutes les QR
    // soient notées)
    const finalize = page.getByRole("button", {
      name: /finaliser|valider.*correction/i,
    });
    await expect(finalize).toBeEnabled({ timeout: 10_000 });
    await finalize.click();

    // Confirmation visible
    await expect(
      page.getByText(/copie.*corrigée|finalisée|envoyée au stagiaire/i).first()
    ).toBeVisible({ timeout: 15_000 });
  });

  test("le stagiaire voit son résultat finalisé", async ({ page }) => {
    await login(page, E2E_ENV.studentEmail(), E2E_ENV.studentPassword());

    // On revient sur la page du quiz et on cherche un lien direct vers
    // /quiz/results/<attempt_id> (plus précis qu'un match texte qui
    // pouvait matcher d'autres liens type "Voir mes statistiques").
    await page.goto(`/quiz/${QUIZ_ID()}`);

    const resultLink = page.locator('a[href*="/quiz/results/"]').first();
    if (await resultLink.isVisible().catch(() => false)) {
      await resultLink.click();
      await expect(page).toHaveURL(/\/quiz\/results\/.+/);
    }

    // Le score doit être affiché (% visible)
    await expect(page.locator("text=/%/").first()).toBeVisible({
      timeout: 10_000,
    });
  });
});
