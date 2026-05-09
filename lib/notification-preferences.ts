// ============================================================
// Helpers TypeScript pour les préférences de notifications.
//   - Type Channel : "in_app" | "push" | "email"
//   - PreferenceState : forme retournée par fetchPreferences()
//   - isTypeEnabled() : helper de filtrage côté client
// ============================================================
import type { NotificationType } from "@/lib/notifications-icons";

export type NotificationChannel = "in_app" | "push" | "email";

export interface PreferenceState {
  in_app_disabled: string[];
  push_disabled: string[];
  email_disabled: string[];
}

/**
 * Préférences "par défaut" (utilisateur sans ligne en base) :
 * tout activé sur in_app + push, email coupé.
 */
export const DEFAULT_PREFERENCES: PreferenceState = {
  in_app_disabled: [],
  push_disabled: [],
  email_disabled: [],
};

/**
 * Vérifie si un type est ACTIVÉ pour un canal donné, étant données
 * les préférences de l'utilisateur. Si la préférence n'est pas connue,
 * on suppose activé (opt-out par défaut).
 */
export function isTypeEnabled(
  prefs: PreferenceState | null | undefined,
  type: string | null | undefined,
  channel: NotificationChannel
): boolean {
  if (!prefs) return true;
  const t = type ?? "system";
  const key = `${channel}_disabled` as const;
  const list = prefs[key] ?? [];
  return !list.includes(t);
}

/**
 * Description textuelle courte par type (utilisée dans la page settings).
 * Sépare ce qui change de la liste d'icônes (qui est purement visuelle).
 */
export const TYPE_DESCRIPTIONS: Record<NotificationType, string> = {
  message:
    "Messages directs des formateurs et de l'équipe pédagogique.",
  quiz_result:
    "Résultats automatiques de tes quiz d'entraînement.",
  exam:
    "Examens blancs, sessions officielles, dates importantes.",
  achievement:
    "Étapes franchies, niveaux, jalons d'apprentissage.",
  badge:
    "Badges débloqués sur ton parcours.",
  certificate:
    "Certificats et attestations délivrés.",
  course:
    "Nouveaux chapitres, leçons mises à jour, contenus publiés.",
  coaching:
    "Rendez-vous d'accompagnement avec ton formateur.",
  announcement:
    "Annonces générales de l'équipe MA FORMATION TRANSPORT.",
  admin:
    "Demandes administratives nécessitant une action.",
  system:
    "Maintenance, mises à jour techniques, incidents.",
};

/**
 * Ordre d'affichage recommandé dans la page settings (du plus
 * "important pour le stagiaire" au plus "purement informatif").
 */
export const PREFERENCE_DISPLAY_ORDER: NotificationType[] = [
  "message",
  "exam",
  "quiz_result",
  "course",
  "achievement",
  "badge",
  "certificate",
  "coaching",
  "announcement",
  "admin",
  "system",
];
