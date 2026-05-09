import { Page, expect } from "@playwright/test";

/**
 * Login flow par formulaire e-mail/mot de passe.
 *
 * Pré-requis : les comptes doivent être déjà provisionnés dans Supabase
 * (voir e2e/README.md). On NE crée PAS de comptes depuis Playwright.
 *
 * Après le login on dismiss les bannières (cookie banner, survey banner,
 * annonces) qui interceptent les clics sur les CTAs en bas de page.
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

  // Dismiss banners qui peuvent intercepter les clics ultérieurs
  await dismissBanners(page);
}

/**
 * Ferme les bannières persistantes (cookie, satisfaction, annonce) qui
 * apparaissent en position fixed bottom et bloquent les clics sur les
 * boutons d'action de la page principale.
 */
export async function dismissBanners(page: Page) {
  // 1) Cookie banner (le plus fréquent — texte exact "Tout accepter")
  const acceptCookies = page.getByRole("button", {
    name: /tout accepter|j'accepte/i,
  });
  if (await acceptCookies.isVisible().catch(() => false)) {
    await acceptCookies.click().catch(() => {});
    // Le banner disparaît avec une transition. On laisse le temps.
    await page.waitForTimeout(400);
  }

  // 2) Bannière de satisfaction Qualiopi (fermable via "Plus tard" ou ✕)
  const survey = page
    .locator('[role="dialog"][aria-modal="true"]')
    .filter({ has: page.getByText(/satisfaction|enquête/i) });
  if (await survey.first().isVisible().catch(() => false)) {
    const close = survey
      .first()
      .getByRole("button", { name: /fermer|plus tard/i });
    if (await close.first().isVisible().catch(() => false)) {
      await close.first().click().catch(() => {});
      await page.waitForTimeout(300);
    }
  }
}

export async function logout(page: Page) {
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
