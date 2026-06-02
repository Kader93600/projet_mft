// =====================================================================
// URL de base de l'application — TOUJOURS absolue.
//
// Pourquoi : les liens d'auth Supabase (invitation, reset, magic link)
// exigent un `redirectTo` ABSOLU. Si on passe une URL relative (parce que
// NEXT_PUBLIC_APP_URL est vide côté serveur), Supabase l'ignore et retombe
// sur la « Site URL » du projet — ce qui renvoyait les stagiaires sur la
// page d'accueil au lieu de la page de création de mot de passe.
//
// Ordre de résolution :
//   1. NEXT_PUBLIC_APP_URL (défini explicitement, recommandé)
//   2. VERCEL_URL (injecté automatiquement par Vercel sur chaque déploiement)
//   3. Fallback codé en dur sur le domaine de production
// =====================================================================

const PROD_FALLBACK = "https://www.maformationtransport.fr";

/** Racine absolue de l'app, sans slash final. */
export function getAppUrl(): string {
  const explicit = process.env.NEXT_PUBLIC_APP_URL?.trim();
  if (explicit) return stripTrailingSlash(ensureProtocol(explicit));

  const vercel = process.env.VERCEL_URL?.trim();
  if (vercel) return stripTrailingSlash(ensureProtocol(vercel));

  return PROD_FALLBACK;
}

/** Construit une URL absolue à partir d'un chemin (`/auth/...`). */
export function appUrl(path: string): string {
  const base = getAppUrl();
  return path.startsWith("/") ? base + path : `${base}/${path}`;
}

function ensureProtocol(u: string): string {
  if (/^https?:\/\//i.test(u)) return u;
  // VERCEL_URL est fourni sans protocole (ex. mon-app.vercel.app)
  return `https://${u}`;
}

function stripTrailingSlash(u: string): string {
  return u.replace(/\/+$/, "");
}
