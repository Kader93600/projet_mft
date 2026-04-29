import { Page, expect } from "@playwright/test";

/**
 * Login flow par formulaire e-mail/mot de passe.
 *
 * Pré-requis : les comptes doivent être déjà provisionnés dans Supabase
 * (voir e2e/README.md). On NE crée PAS de comptes depuis Playwright.
 */
export async function login(page: Page, email: string, password: string) {
  await page.goto("/login");
  await page.getByLabel(/e-?mail/i).fill(email);
  await page.getByLabel(/mot de passe/i).fill(password);
  await page.getByRole("button", { name: /connexion|se connecter/i }).click();

  // Attente d'une redirection hors de /login
  await page.waitForURL((url) => !url.pathname.startsWith("/login"), {
    timeout: 15_000,
  });
}

export async function logout(page: Page) {
  // Cherche le bouton de déconnexion dans la sidebar / topbar
  await page.goto("/dashboard");
  const btn = page.getByRole("button", { name: /déconnexion|se déconnecter/i });
  if (await btn.isVisible().catch(() => false)) {
    await btn.click();
    await page.waitForURL(/\/login/);
  }
}

export async function expectLoggedIn(page: Page) {
  await expect(page).not.toHaveURL(/\/login/);
}
