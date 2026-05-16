// =====================================================================
// Vitest — configuration unit + component tests
//
// Périmètre : lib/* et components/* simples (sans dépendances Supabase
// runtime). Les routes API + server actions sont testées via Playwright
// (e2e/) qui tourne sur un Supabase réel.
//
// Lancer : npm run test           (mode watch)
//          npm run test:run       (CI, run-once)
//          npm run test:coverage  (rapport coverage)
//          npm run test:ui        (interface graphique Vitest)
// =====================================================================

import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import path from "node:path";

export default defineConfig({
  plugins: [react()],
  test: {
    environment: "jsdom",
    setupFiles: ["./test/setup.ts"],
    globals: true,
    // Exclut les e2e Playwright et autres
    exclude: [
      "**/node_modules/**",
      "**/dist/**",
      "**/.next/**",
      "**/e2e/**",
      "**/test-results/**",
      "**/playwright-report/**",
      "**/storybook-static/**",
      "**/*.stories.*",
    ],
    coverage: {
      provider: "v8",
      reporter: ["text", "html", "json-summary"],
      include: [
        "lib/**/*.{ts,tsx}",
        "components/ui/**/*.{ts,tsx}",
      ],
      exclude: [
        "lib/database.types.ts",
        "lib/supabase/**", // clients Supabase = wrappers triviaux
        "**/*.d.ts",
      ],
      thresholds: {
        // Seuils volontairement bas au démarrage — on les remontera
        // au fur et à mesure que la couverture augmente.
        lines: 30,
        functions: 30,
        branches: 50,
        statements: 30,
      },
    },
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./"),
    },
  },
});
