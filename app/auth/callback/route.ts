import { NextRequest, NextResponse } from "next/server";
import type { EmailOtpType } from "@supabase/supabase-js";
import { createClient } from "@/lib/supabase/server";

/**
 * Route callback Supabase Auth — gère TOUS les liens email.
 *
 * Supabase peut renvoyer le lien sous deux formes selon le réglage du
 * projet et le type d'email :
 *
 *   A. PKCE         : ?code=xxx            → exchangeCodeForSession(code)
 *   B. Token hash   : ?token_hash=xxx&type=invite|recovery|signup|email
 *                     → verifyOtp({ token_hash, type })
 *
 * Le flux B est INDISPENSABLE pour les invitations générées côté serveur
 * (inviteUserByEmail) : elles sont ouvertes sur un autre appareil que
 * celui de l'admin, donc sans `code_verifier` PKCE en cookie. C'est l'une
 * des causes du bug « le stagiaire est renvoyé sur la home » : l'ancien
 * callback ne gérait que le flux A.
 *
 * Après établissement de la session, on redirige vers `?next=/...`
 * (chemin interne uniquement). Pour une invitation, next = /bienvenue.
 */
export async function GET(request: NextRequest) {
  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  const tokenHash = url.searchParams.get("token_hash");
  const type = url.searchParams.get("type") as EmailOtpType | null;
  const next = url.searchParams.get("next") ?? "/dashboard";
  const errorDescription = url.searchParams.get("error_description");

  const safeNext = next.startsWith("/") ? next : "/dashboard";

  const loginError = (msg: string) =>
    NextResponse.redirect(
      new URL(`/login?error=${encodeURIComponent(msg)}`, request.url)
    );

  const expiredPage = (reason: string) =>
    NextResponse.redirect(
      new URL(
        `/invitation-expiree?reason=${encodeURIComponent(reason)}`,
        request.url
      )
    );

  // Erreur explicite renvoyée par Supabase (lien expiré, déjà utilisé…)
  if (errorDescription) {
    if (type === "invite" || type === "recovery") return expiredPage(errorDescription);
    return loginError(errorDescription);
  }

  const supabase = await createClient();

  // ── Flux B : token_hash (invitation, recovery, signup, email change) ──
  if (tokenHash && type) {
    const { error } = await supabase.auth.verifyOtp({
      type,
      token_hash: tokenHash,
    });
    if (!error) {
      return NextResponse.redirect(new URL(safeNext, request.url));
    }
    if (type === "invite" || type === "recovery") return expiredPage(error.message);
    return loginError("Lien expiré ou déjà utilisé. Demandez un nouveau lien.");
  }

  // ── Flux A : PKCE ?code= (reset classique depuis le même navigateur) ──
  if (code) {
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      return NextResponse.redirect(new URL(safeNext, request.url));
    }
    return loginError("Lien expiré ou déjà utilisé. Demandez un nouveau lien.");
  }

  // Aucun paramètre exploitable → on renvoie sur la destination demandée.
  return NextResponse.redirect(new URL(safeNext, request.url));
}
