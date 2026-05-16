/**
 * Lighthouse CI — audit performance/SEO/accessibilité automatique
 *
 * Audite 3 pages clés du site vitrine (publiques) à chaque déploiement.
 * Les pages authentifiées (dashboard, admin) ne sont PAS auditées ici
 * car Lighthouse ne peut pas s'authentifier facilement.
 *
 * Pour lancer localement :
 *   npm run build && npm run start &
 *   npx lhci autorun
 *
 * Sur Vercel : utiliser l'URL preview de chaque PR (cf. github actions).
 */
module.exports = {
  ci: {
    collect: {
      // Pages publiques uniquement (pas besoin d'auth)
      url: [
        "http://localhost:3000",
        "http://localhost:3000/tarifs",
        "http://localhost:3000/login",
      ],
      // Lance le serveur Next.js avant les audits
      startServerCommand: "npm run start",
      startServerReadyPattern: "Ready",
      startServerReadyTimeout: 30000,
      numberOfRuns: 1, // 1 run suffit en CI (Lighthouse est déterministe)
      settings: {
        // Émulation desktop pour comparer dans des conditions stables
        preset: "desktop",
        // Skip les audits qui dépendent du contexte (PWA install)
        skipAudits: ["uses-http2", "redirects-http"],
      },
    },
    assert: {
      // Seuils initiaux raisonnables — à remonter quand on optimise.
      // Catégories : perf / accessibilité / best-practices / SEO
      assertions: {
        "categories:performance": ["warn", { minScore: 0.75 }],
        "categories:accessibility": ["error", { minScore: 0.9 }],
        "categories:best-practices": ["warn", { minScore: 0.85 }],
        "categories:seo": ["warn", { minScore: 0.9 }],
        // Désactive les audits hors-scope d'un site Next.js
        "uses-text-compression": "off",
        "uses-long-cache-ttl": "off",
        "csp-xss": "off", // CSP custom géré dans next.config.mjs
      },
    },
    upload: {
      // Stocke les rapports dans le LHCI public storage (gratuit, sans config).
      // Pour un setup pro : passer à un serveur LHCI privé ou GitHub Pages.
      target: "temporary-public-storage",
    },
  },
};
