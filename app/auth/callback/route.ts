import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

/**
 * Route callback Supabase Auth (PKCE).
 *
 * Tous les liens email envoyés par Supabase (récupération de mot de passe,
 * confirmation d'inscription, magic link, OAuth) doivent pointer ici via
 * le paramètre `redirectTo`. Cette route :
 *
 *   1. Récupère le `?code=xxx` que Supabase a généré
 *   2. L'échange contre une session valide (cookies posés par @supabase/ssr)
 *   3. Redirige vers la page de destination indiquée par `?next=/...`
 *
 * Exemple d'utilisation côté client :
 *   resetPasswordForEmail(email, {
 *     redirectTo: `${origin}/auth/callback?next=/reset-password`
 *   })
 */
export async function GET(request: NextRequest) {
  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  const next = url.searchParams.get("next") ?? "/dashboard";
  const errorDescription = url.searchParams.get("error_description");

  // Erreur renvoyée par Supabase (lien expiré, token invalide, etc.)
  if (errorDescription) {
    return NextResponse.redirect(
      new URL(
        `/login?error=${encodeURIComponent(errorDescription)}`,
        request.url
      )
    );
  }

  // Cas nominal : on échange le code contre une session
  if (code) {
    const supabase = createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      // Garde-fou : on n'autorise que les redirections internes
      const safeNext = next.startsWith("/") ? next : "/dashboard";
      return NextResponse.redirect(new URL(safeNext, request.url));
    }
    // Échec d'échange : lien probablement déjà utilisé
    return NextResponse.redirect(
      new URL(
        `/login?error=${encodeURIComponent(
          "Lien expiré ou déjà utilisé. Demandez un nouveau lien."
        )}`,
        request.url
      )
    );
  }

  // Pas de code : on renvoie sur la page demandée (ou dashboard)
  const safeNext = next.startsWith("/") ? next : "/dashboard";
  return NextResponse.redirect(new URL(safeNext, request.url));
}
