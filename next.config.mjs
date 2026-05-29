/** @type {import('next').NextConfig} */

import { withSentryConfig } from "@sentry/nextjs";
import createNextIntlPlugin from "next-intl/plugin";

// next-intl : charge la config depuis ./i18n/request.ts
const withNextIntl = createNextIntlPlugin("./i18n/request.ts");

// === Headers de sécurité ===
// CSP autorise Supabase + Sentry + Resend tracking.
// Si tu ajoutes un nouveau service tiers, ouvre la directive correspondante.

const supabaseHost = (() => {
  try {
    const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
    return url ? new URL(url).host : "*.supabase.co";
  } catch {
    return "*.supabase.co";
  }
})();

const cspDirectives = {
  "default-src": ["'self'"],
  "script-src": [
    "'self'",
    "'unsafe-inline'", // Next.js inline runtime
    process.env.NODE_ENV === "development" ? "'unsafe-eval'" : "",
    "https://*.sentry.io",
    "https://js.stripe.com",
    "https://eu.i.posthog.com",
    "https://eu-assets.i.posthog.com",
  ].filter(Boolean),
  "style-src": ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
  "img-src": [
    "'self'",
    "data:",
    "blob:",
    `https://${supabaseHost}`,
    "https://*.supabase.co",
  ],
  "font-src": ["'self'", "data:", "https://fonts.gstatic.com"],
  "connect-src": [
    "'self'",
    `https://${supabaseHost}`,
    "wss://*.supabase.co",
    "https://*.supabase.co",
    "https://*.ingest.sentry.io",
    "https://api.resend.com",
    "https://api.stripe.com",
    "https://eu.i.posthog.com",
    "https://eu-assets.i.posthog.com",
    // Base Adresse Nationale (autocomplétion d'adresse, officielle/gratuite).
    "https://api-adresse.data.gouv.fr",
  ],
  "frame-src": [
    "'self'",
    "https://js.stripe.com",
    "https://hooks.stripe.com",
    // Annexes PDF stockées dans Supabase Storage et affichées en iframe
    // pendant les quiz (cf. /quiz/[id] AnnexPanel).
    `https://${supabaseHost}`,
    "https://*.supabase.co",
  ],
  // Vidéos d'introduction des modules (Supabase Storage, signed URL).
  // Sans cette directive, le browser tombe sur default-src 'self' et
  // rejette les <video> cross-origin avec MEDIA_ERR_SRC_NOT_SUPPORTED.
  "media-src": [
    "'self'",
    "blob:",
    `https://${supabaseHost}`,
    "https://*.supabase.co",
  ],
  "frame-ancestors": ["'none'"],
  "base-uri": ["'self'"],
  "form-action": ["'self'"],
  "object-src": ["'none'"],
  "upgrade-insecure-requests": [],
};

const cspHeader = Object.entries(cspDirectives)
  .map(([key, values]) =>
    values.length ? `${key} ${values.join(" ")}` : key
  )
  .join("; ");

const securityHeaders = [
  { key: "Content-Security-Policy", value: cspHeader },
  // 2 ans + sous-domaines + preload list
  {
    key: "Strict-Transport-Security",
    value: "max-age=63072000; includeSubDomains; preload",
  },
  { key: "X-Frame-Options", value: "DENY" },
  { key: "X-Content-Type-Options", value: "nosniff" },
  { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
  {
    key: "Permissions-Policy",
    value: [
      "camera=()",
      "microphone=()",
      "geolocation=()",
      "interest-cohort=()",
      "payment=(self)",
      "fullscreen=(self)",
    ].join(", "),
  },
  { key: "X-DNS-Prefetch-Control", value: "on" },
];

const nextConfig = {
  reactStrictMode: true,
  experimental: {
    typedRoutes: false,
    // pdf-parse charge ses modules en require dynamique. Si webpack tente
    // de le bundler, certaines deps (pdfjs-dist) ou son test-fixture
    // (./test/data/05-versions-space.pdf) cassent en serverless. On le
    // garde "externe" → resolved au runtime depuis node_modules.
    serverComponentsExternalPackages: ["pdf-parse"],
    // Composer email : autoriser des Server Actions plus volumineuses pour
    // transmettre les pièces jointes (encodées base64) sans 413.
    serverActions: { bodySizeLimit: "12mb" },
  },
  async headers() {
    return [
      {
        source: "/:path*",
        headers: securityHeaders,
      },
      // PDFs : autoriser l'affichage inline mais empêcher l'iframe externe
      {
        source: "/api/:path*.pdf",
        headers: [{ key: "X-Frame-Options", value: "SAMEORIGIN" }],
      },
    ];
  },
  // =====================================================================
  // PostHog tunneling — bypass des ad-blockers.
  //
  // Les requêtes PostHog (eu.i.posthog.com) sont systématiquement bloquées
  // par uBlock Origin, AdGuard, Brave Shields, etc. (~50 % des users).
  // Solution officielle PostHog : proxyfier via notre propre domaine.
  // Du coup le navigateur "voit" maformationtransport.fr/ingest/...
  // au lieu de eu.i.posthog.com/... → indétectable par les ad-blockers.
  //
  // skipTrailingSlashRedirect évite que Next.js redirige /ingest → /ingest/
  // (PostHog n'aime pas la redirection 308 sur ces endpoints).
  // =====================================================================
  skipTrailingSlashRedirect: true,
  async rewrites() {
    return [
      {
        source: "/ingest/static/:path*",
        destination: "https://eu-assets.i.posthog.com/static/:path*",
      },
      {
        source: "/ingest/:path*",
        destination: "https://eu.i.posthog.com/:path*",
      },
    ];
  },
};

// =====================================================================
// Wrapping Sentry — upload des source maps + instrumentation auto.
//
// Source maps : permet à Sentry d'afficher le code original (TypeScript)
// dans les stack traces au lieu du JS minifié. Requiert SENTRY_AUTH_TOKEN
// dans Vercel (à demander à Sentry > Settings > Auth Tokens, scope :
// project:releases).
// =====================================================================
const sentryOptions = {
  // Configuration de l'organisation et du projet Sentry.
  org: process.env.SENTRY_ORG,
  project: process.env.SENTRY_PROJECT,
  authToken: process.env.SENTRY_AUTH_TOKEN,

  // Silencieux côté build (sinon Sentry parle beaucoup dans les logs Vercel).
  silent: !process.env.CI,

  // Upload des source maps en prod uniquement (sinon ça ralentit le dev).
  widenClientFileUpload: true,
  hideSourceMaps: true,

  // Désactive automatiquement les tunnels Sentry en dev pour ne pas
  // polluer Network tab.
  disableLogger: true,

  // Tree-shake les helpers Sentry non utilisés (réduit la taille du bundle).
  reactComponentAnnotation: { enabled: true },

  // Routes /monitoring → proxy interne pour bypass des ad-blockers.
  // Évite que les utilisateurs avec uBlock Origin ne reportent jamais d'erreur.
  tunnelRoute: "/monitoring",
};

// Compose : next-intl + Sentry wrapping
export default withSentryConfig(withNextIntl(nextConfig), sentryOptions);
