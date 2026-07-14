"use server";
import { headers } from "next/headers";
import { createAdminClient } from "@/lib/supabase/admin";
import { appUrl } from "@/lib/app-url";
import { rateLimit, clientIp } from "@/lib/rate-limit";

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/**
 * Renvoi public d'une invitation / lien d'activation.
 *
 * Sécurité :
 *  - Réponse TOUJOURS identique (succès) qu'l'email existe ou non
 *    (anti-énumération de comptes).
 *  - Rate-limit par IP ET par email.
 *  - Ne renvoie un lien d'invitation que si le compte n'est PAS encore
 *    confirmé (email_confirmed_at null). Pour un compte déjà actif, on ne
 *    fait rien (l'utilisateur doit passer par « mot de passe oublié »).
 */
export async function resendInvitation(rawEmail: string): Promise<{
  ok: boolean;
  error?: string;
}> {
  const email = (rawEmail ?? "").trim().toLowerCase();
  if (!EMAIL_RE.test(email)) {
    return { ok: false, error: "Adresse email invalide." };
  }

  const ip = clientIp(await headers());
  const [ipLimit, mailLimit] = await Promise.all([
    rateLimit({ key: `resend-invite:ip:${ip}`, limit: 5, windowSec: 600 }),
    rateLimit({ key: `resend-invite:mail:${email}`, limit: 3, windowSec: 3600 }),
  ]);
  if (!ipLimit.ok || !mailLimit.ok) {
    return {
      ok: false,
      error: "Trop de demandes. Réessayez dans quelques minutes.",
    };
  }

  // Réponse générique renvoyée dans tous les cas non-erreur (anti-énumération).
  const generic = { ok: true as const };

  try {
    const sb = createAdminClient();

    // Cherche le compte (service-role). On ne révèle jamais le résultat.
    const { data: list } = await sb.auth.admin.listUsers();
    const user = (list?.users ?? []).find(
      (u) => (u.email ?? "").toLowerCase() === email
    );

    // Compte inexistant → réponse générique (pas de fuite d'info).
    if (!user) return generic;

    // Compte déjà activé (email confirmé) → on ne renvoie pas d'invitation.
    // L'utilisateur utilisera « mot de passe oublié » s'il en a besoin.
    if (user.email_confirmed_at) return generic;

    const redirectTo = appUrl("/activer?next=/bienvenue");
    await sb.auth.admin.inviteUserByEmail(email, { redirectTo });
    return generic;
  } catch {
    // Même en cas d'erreur interne, on reste générique côté public.
    return generic;
  }
}
