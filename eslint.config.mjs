import nextCoreWebVitals from "eslint-config-next/core-web-vitals";

/**
 * ESLint 9 — flat config (requis par eslint-config-next 16).
 *
 * `eslint-config-next/core-web-vitals` exporte nativement un tableau de configs
 * flat : on l'étale directement. FlatCompat n'est PAS utilisable ici (il plante
 * sur une structure circulaire en tentant de sérialiser cette config).
 *
 * Reprend à l'identique l'ancien .eslintrc.json : mêmes règles, mêmes ignores.
 */
export default [
  {
    ignores: [
      "node_modules/**",
      ".next/**",
      "out/**",
      "build/**",
      "dist/**",
      "supabase/**",
      "test-results/**",
      "playwright-report/**",
      "coverage/**",
      ".lighthouseci/**",
      "storybook-static/**",
    ],
  },
  ...nextCoreWebVitals,
  {
    rules: {
      "@next/next/no-img-element": "warn",
      "react/no-unescaped-entities": "off",

      // ── Règles React Compiler activées par eslint-config-next 16 ──────────
      // Elles signalent ~82 patterns React PRÉ-EXISTANTS (setState dans un
      // effet, appels impurs pendant le rendu, mutations…). Ce sont de vraies
      // pistes d'amélioration, mais les corriger relève d'un chantier dédié :
      // les traiter à la volée pendant une montée de framework reviendrait à
      // modifier le comportement de composants sans filet de test.
      // Passées en `warn` pour rester visibles sans bloquer le build.
      // TODO(chantier React Compiler) : repasser en "error" au fil des correctifs.
      "react-hooks/set-state-in-effect": "warn",
      "react-hooks/purity": "warn",
      "react-hooks/immutability": "warn",
      "react-hooks/static-components": "warn",
      "react-hooks/preserve-manual-memoization": "warn",
      "react-hooks/refs": "warn",
    },
  },
];
