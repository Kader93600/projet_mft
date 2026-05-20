/**
 * Lighthouse CI — audit ACCESSIBILITÉ uniquement, BLOQUANT en CI.
 *
 * Séparé de .lighthouserc.cjs (audit complet, informatif) pour que
 * l'accessibilité soit une vraie barrière qualité : si le score
 * accessibilité d'une page publique passe sous le seuil, la CI échoue.
 *
 * Pages auditées : pages publiques (pas d'auth requise).
 * Lancer localement : npm run build && npm run a11y:ci
 */
module.exports = {
  ci: {
    collect: {
      url: [
        "http://localhost:3000",
        "http://localhost:3000/tarifs",
        "http://localhost:3000/login",
        "http://localhost:3000/formations",
        "http://localhost:3000/contact",
      ],
      startServerCommand: "npm run start",
      startServerReadyPattern: "Ready",
      startServerReadyTimeout: 30000,
      numberOfRuns: 1,
      settings: {
        preset: "desktop",
        // On ne collecte QUE l'accessibilité → run rapide et ciblé.
        onlyCategories: ["accessibility"],
      },
    },
    assert: {
      assertions: {
        // BLOQUANT : seuil 0.9. Remonter progressivement vers 1.0.
        "categories:accessibility": ["error", { minScore: 0.9 }],
      },
    },
    upload: {
      target: "temporary-public-storage",
    },
  },
};
