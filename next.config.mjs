/** @type {import('next').NextConfig} */

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
};

export default nextConfig;
