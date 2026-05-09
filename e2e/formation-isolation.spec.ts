import { test, expect } from "@playwright/test";
import { login } from "./helpers/auth";
import { E2E_ENV } from "./helpers/env";

/**
 * E2E — Cloisonnement multi-formations
 *
 * Régression critique : un stagiaire inscrit à la formation X ne doit
 * PAS pouvoir accéder au contenu d'une formation Y.
 *
 * Note : en dev mode, Next.js peut servir la page 404 avec un statut HTTP
 * 200 (Server Component qui call notFound() est rendu côté client).
 * On vérifie donc le CONTENU (texte "404" + "n'existe pas") plutôt que
 * uniquement le status code, ce qui couvre les 2 environnements.
 */

test.describe("Cloisonnement multi-formations", () => {
  test("le stagiaire ne voit que les modules de sa formation sur /modules", async ({
    page,
  }) => {
    await login(page, E2E_ENV.studentEmail(), E2E_ENV.studentPassword());
    await page.goto("/modules");

    // La page doit charger sans erreur. /modules a 2 h1 (un dans la
    // topbar AppShell "Cours", un dans la page). On cible celui de la
    // page par son texte ("Bonjour ..., voici votre formation").
    await expect(
      page.getByRole("heading", { level: 1, name: /bonjour|formation/i })
    ).toBeVisible({ timeout: 10_000 });

    // Le slug d'une formation interdite ne doit apparaître nulle part
    // dans les liens de modules listés
    const forbidden = E2E_ENV.forbiddenModuleSlug();
    const forbiddenLink = page.locator(`a[href="/modules/${forbidden}"]`);
    await expect(forbiddenLink).toHaveCount(0);
  });

  test("accès direct à un module d'une autre formation → 404", async ({
    page,
  }) => {
    await login(page, E2E_ENV.studentEmail(), E2E_ENV.studentPassword());
    const forbidden = E2E_ENV.forbiddenModuleSlug();

    await page.goto(`/modules/${forbidden}`);

    // Critère robuste : peu importe la nature de la sortie (404 native,
    // overlay d'erreur Next.js dev, ou autre), le titre du module
    // interdit ne doit JAMAIS apparaître. C'est le vrai test de
    // cloisonnement (l'utilisateur ne voit pas le contenu).
    const moduleHeading = page
      .getByRole("heading")
      .filter({ hasText: /environnement|cadre pro|chapitre 1|TRM/i });
    await expect(moduleHeading).toHaveCount(0);

    // Soit on voit "404" (page not-found rendue normalement), soit on
    // détecte le call-to-action retour à l'accueil de la page 404.
    const fourOhFour = page.getByText("404", { exact: false }).first();
    const homeLink = page
      .getByRole("link", { name: /retour|accueil|home/i })
      .first();
    const isFourOhFour = await fourOhFour.isVisible().catch(() => false);
    const hasHomeLink = await homeLink.isVisible().catch(() => false);

    expect(
      isFourOhFour || hasHomeLink,
      "Aucun signal d'une page 404 (texte 404 ni lien retour accueil)"
    ).toBeTruthy();
  });

  test("accès direct à une leçon d'une autre formation → 404", async ({
    page,
  }) => {
    await login(page, E2E_ENV.studentEmail(), E2E_ENV.studentPassword());
    const forbidden = E2E_ENV.forbiddenModuleSlug();

    await page.goto(`/modules/${forbidden}/some-lesson`);

    await expect(page.getByText("404", { exact: false }).first()).toBeVisible({
      timeout: 10_000,
    });
    await expect(
      page.getByText(/n'existe pas|introuvable|not found/i).first()
    ).toBeVisible({ timeout: 5_000 });
  });
});
