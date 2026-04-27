// Minimal i18n — FR par défaut + EN.
// Couvre les clés essentielles ; à étendre au fur et à mesure.

export type Locale = "fr" | "en";

export const DICT: Record<Locale, Record<string, string>> = {
  fr: {
    "nav.dashboard": "Tableau de bord",
    "nav.modules": "Modules",
    "nav.quiz": "Quiz & Examens",
    "nav.stats": "Mes résultats",
    "nav.coaching": "Accompagnement",
    "nav.achievements": "Réussites",
    "nav.certificates": "Certificats",
    "nav.documents": "Mes documents",
    "nav.messages": "Messages",
    "nav.glossary": "Glossaire",
    "nav.a11y": "Accessibilité",
    "nav.enrollment": "Mon inscription",
    "nav.leaderboard": "Classement",
    "nav.privacy": "Mes données",
    "common.save": "Enregistrer",
    "common.cancel": "Annuler",
    "common.confirm": "Confirmer",
    "common.delete": "Supprimer",
    "common.loading": "Chargement…",
    "privacy.title": "Mes données personnelles",
    "privacy.export": "Exporter mes données",
    "privacy.delete": "Demander la suppression",
    "privacy.consents": "Mes consentements",
  },
  en: {
    "nav.dashboard": "Dashboard",
    "nav.modules": "Modules",
    "nav.quiz": "Quizzes & Exams",
    "nav.stats": "My results",
    "nav.coaching": "Coaching",
    "nav.achievements": "Achievements",
    "nav.certificates": "Certificates",
    "nav.documents": "My documents",
    "nav.messages": "Messages",
    "nav.glossary": "Glossary",
    "nav.a11y": "Accessibility",
    "nav.enrollment": "Enrollment",
    "nav.leaderboard": "Leaderboard",
    "nav.privacy": "My data",
    "common.save": "Save",
    "common.cancel": "Cancel",
    "common.confirm": "Confirm",
    "common.delete": "Delete",
    "common.loading": "Loading…",
    "privacy.title": "My personal data",
    "privacy.export": "Export my data",
    "privacy.delete": "Request deletion",
    "privacy.consents": "My consents",
  },
};

export function t(locale: Locale, key: string): string {
  return DICT[locale]?.[key] ?? DICT.fr[key] ?? key;
}
