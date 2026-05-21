// =====================================================================
// Indicateurs de résultats publiés (obligation Qualiopi — critère 1,
// indicateur 2 ; et indicateur 3 pour les actions certifiantes / RNCP).
//
// ⚠️ HONNÊTETÉ : ne jamais publier de chiffres inventés. Tant qu'un
//    indicateur n'a pas de valeur réelle, laisser `value: null` : la page
//    affiche alors « Publié après la 1ʳᵉ cohorte ». Renseigner les vraies
//    valeurs (issues des enquêtes et des résultats d'examen) après chaque
//    session, puis mettre à jour `referencePeriod` et `lastUpdate`.
// =====================================================================

export interface ResultIndicator {
  key: string;
  /** Libellé affiché. */
  label: string;
  /** Valeur réelle (ex. "92 %", "4,6 / 5", "128"). null = pas encore disponible. */
  value: string | null;
  /** Explication courte de l'indicateur. */
  help: string;
}

export const RESULTS: {
  referencePeriod: string;
  lastUpdate: string; // ISO (YYYY-MM-DD)
  pendingNote: string;
  indicators: ResultIndicator[];
} = {
  referencePeriod: "Promotion 2025 – 2026 (première cohorte)",
  lastUpdate: "2026-05-22",
  pendingNote:
    "En tant qu'organisme récemment certifié Qualiopi, nos premiers indicateurs chiffrés seront publiés à l'issue de la première cohorte complète. Cette page est actualisée à chaque session, conformément à nos engagements qualité.",
  indicators: [
    {
      key: "satisfaction",
      label: "Taux de satisfaction",
      value: null,
      help: "Part des stagiaires satisfaits ou très satisfaits (enquêtes à chaud en fin de formation).",
    },
    {
      key: "success",
      label: "Taux de réussite à l'examen",
      value: null,
      help: "Part des candidats présentés ayant obtenu leur titre ou certification.",
    },
    {
      key: "completion",
      label: "Taux de complétion",
      value: null,
      help: "Part des stagiaires ayant suivi la formation jusqu'à son terme.",
    },
    {
      key: "insertion",
      label: "Insertion & suites de parcours",
      value: null,
      help: "Part des diplômés en emploi ou en poursuite de parcours à 6 mois.",
    },
    {
      key: "trained",
      label: "Stagiaires formés",
      value: null,
      help: "Nombre de stagiaires accueillis sur la période de référence.",
    },
    {
      key: "recommend",
      label: "Taux de recommandation",
      value: null,
      help: "Part des stagiaires recommandant la formation à un proche.",
    },
  ],
};
