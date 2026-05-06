import { test, expect } from "@playwright/test";
import { login } from "./helpers/auth";
import { E2E_ENV } from "./helpers/env";

/**
 * E2E — Cloisonnement multi-formations
 *
 * Régression critique : un stagiaire inscrit à la formation X ne doit
 * PAS pouvoir accéder au contenu d'une formation Y.
 *
 * Ce test couvre les couches de défense :
 *   1. UI : la page /modules ne liste QUE les modules de ses formations
 *   2. URL direct : /modules/<slug-formation-Y> doit renvoyer 404
 *      (gate côté server component)
 *   3. (Sprint 2) RLS : même via Supabase direct, le contenu n'est
 *      pas lisible — pas testable depuis l'UI Playwright, à valider
 *      en SQL avec un compte stagiaire dans le SQL Editor Supabase.
 *
 * Pré-requis (variables d'env) :
 *   - E2E_STUDENT_EMAIL / E2E_STUDENT_PASSWORD : compte inscrit à 1 formation
 *   - E2E_FORBIDDEN_MODULE_SLUG : slug d'un module d'une AUTRE formation
 */

test.describe("Cloisonnement multi-formations", () => {
  test("le stagiaire ne voit que les modules de sa formation sur /modules", async ({
    page,
  }) => {
    await login(page, E2E_ENV.studentEmail(), E2E_ENV.studentPassword());
    await page.goto("/modules");

    // La page doit charger sans erreur
    await expect(
      page.getByRole("heading", { level: 1 })
    ).toBeVisible({ timeout: 10_000 });

    // Le slug d'une formation interdite ne doit apparaître nulle part
    // dans les liens de modules listés (chaque module-card a un href
    // /modules/<slug>).
    const forbidden = E2E_ENV.forbiddenModuleSlug();
    const forbiddenLink = page.locator(`a[href="/modules/${forbidden}"]`);
    await expect(forbiddenLink).toHaveCount(0);
  });

  test("accès direct à un module d'une autre formation → 404", async ({
    page,
  }) => {
    await login(page, E2E_ENV.studentEmail(), E2E_ENV.studentPassword());
    const forbidden = E2E_ENV.forbiddenModuleSlug();

    const response = await page.goto(`/modules/${forbidden}`);
    // Next.js renvoie un 404 status pour notFound()
    expect(response?.status()).toBe(404);

    // Et la page 404 doit s'afficher (pas une page vide ou une erreur 500)
    await expect(page.getByText(/404|introuvable|not found/i)).toBeVisible({
      timeout: 5_000,
    });
  });

  test("accès direct à une leçon d'une autre formation → 404", async ({
    page,
  }) => {
    await login(page, E2E_ENV.studentEmail(), E2E_ENV.studentPassword());
    const forbidden = E2E_ENV.forbiddenModuleSlug();

    // On essaie une leçon arbitraire (le gate doit fire avant même de
    // chercher la leçon)
    const response = await page.goto(`/modules/${forbidden}/some-lesson`);
    expect(response?.status()).toBe(404);
  });
});
