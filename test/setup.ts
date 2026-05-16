// =====================================================================
// Vitest — setup global avant chaque test.
//
// • Active les matchers @testing-library/jest-dom (toBeInTheDocument,
//   toHaveClass, etc.)
// • Mocke les variables d'env publiques pour éviter les undefined dans
//   les helpers Sentry / PostHog qui sont chargés en cascade.
// =====================================================================

import "@testing-library/jest-dom/vitest";

// Vars d'env nécessaires aux modules qu'on importe
process.env.NEXT_PUBLIC_APP_URL = "https://maformationtransport.fr";

// Polyfills jsdom pour les APIs Next/React modernes (mode défensif —
// jsdom récent les fournit déjà, mais on s'assure d'un fallback).
if (typeof globalThis.crypto === "undefined") {
  Object.defineProperty(globalThis, "crypto", {
    configurable: true,
    value: {
      randomUUID: (): `${string}-${string}-${string}-${string}-${string}` =>
        "00000000-0000-4000-8000-000000000000",
    },
  });
}

if (typeof globalThis.fetch === "undefined") {
  Object.defineProperty(globalThis, "fetch", {
    configurable: true,
    value: async () =>
      new Response("{}", {
        status: 200,
        headers: { "content-type": "application/json" },
      }),
  });
}
