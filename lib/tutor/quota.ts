// =====================================================================
// Quota strict mensuel sur le chat IA tuteur.
//
// La table `tutor_quotas` (cf. migration 2026_05_18_ia_tutor.sql) stocke
// déjà le compteur (messages_count, cost_cents) par user × mois, et la
// RPC `bump_tutor_quota` l'incrémente après chaque message assistant.
//
// Ce helper LIT le compteur AVANT chaque appel pour bloquer si le
// stagiaire a atteint son plafond mensuel.
//
// Plafonds par rôle (configurables ici) :
//   - Admin / super_admin / trainer : illimité (override)
//   - Stagiaire Premium             : 200 messages / mois
//
// Quand le plafond est atteint :
//   - L'endpoint /api/tutor/ask retourne 429 avec un message clair
//   - L'UI affiche un toast "Vous avez atteint votre quota mensuel"
//   - Le compteur reset le 1er du mois suivant (basé sur date_trunc('month'))
// =====================================================================

import { createClient } from "@/lib/supabase/server";

/** Plafond mensuel par défaut pour les stagiaires Premium. */
export const MONTHLY_MESSAGE_LIMIT_PREMIUM = 200;

export interface QuotaStatus {
  /** Nombre de messages déjà consommés ce mois. */
  used: number;
  /** Plafond mensuel (Infinity si pas de plafond). */
  limit: number;
  /** True si le stagiaire peut encore poser des questions. */
  allowed: boolean;
  /** Date à laquelle le compteur sera remis à zéro (1er du mois suivant). */
  resets_at: string;
  /** Pourcentage utilisé (0-100), tronqué à 100. */
  percent: number;
}

/**
 * Lit le quota du user. Si la ligne n'existe pas encore pour ce mois,
 * retourne 0/limit. La création de la ligne est faite par bump_tutor_quota
 * APRÈS un message réussi (pas avant).
 */
export async function getQuotaStatus(
  userId: string,
  isStaffOverride: boolean
): Promise<QuotaStatus> {
  const supabase = createClient();

  // Calcule le 1er du mois courant et du mois suivant
  const now = new Date();
  const firstOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
  const firstOfNextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);

  const { data } = await supabase
    .from("tutor_quotas")
    .select("messages_count, cost_cents")
    .eq("user_id", userId)
    .eq("month", firstOfMonth.toISOString().slice(0, 10))
    .maybeSingle();

  const used = (data as any)?.messages_count ?? 0;

  // Override staff = pas de plafond
  if (isStaffOverride) {
    return {
      used,
      limit: Infinity,
      allowed: true,
      resets_at: firstOfNextMonth.toISOString(),
      percent: 0,
    };
  }

  const limit = MONTHLY_MESSAGE_LIMIT_PREMIUM;
  return {
    used,
    limit,
    allowed: used < limit,
    resets_at: firstOfNextMonth.toISOString(),
    percent: Math.min(100, Math.round((used / limit) * 100)),
  };
}

/**
 * Construit un message clair pour l'UI quand le quota est atteint.
 */
export function buildQuotaExceededMessage(status: QuotaStatus): string {
  const resetDate = new Date(status.resets_at).toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
  return `Vous avez atteint votre quota mensuel de ${status.limit} questions au tuteur IA. Votre quota sera réinitialisé le ${resetDate}. En attendant, vous pouvez consulter vos modules ou contacter votre formateur via la messagerie.`;
}
