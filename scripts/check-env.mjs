// =====================================================================
// scripts/check-env.mjs
//
// Vérifie la présence des variables d'environnement nécessaires (déduites
// des process.env réellement utilisés dans le code). À lancer AVANT la
// livraison, contre l'environnement de prod.
//
// Usage :
//   node scripts/check-env.mjs                 # lit process.env (CI / Vercel)
//   node scripts/check-env.mjs .env.production  # lit un fichier .env donné
//
// En prod Vercel : `vercel env pull .env.production` puis la commande ci-dessus,
// ou ajouter `node scripts/check-env.mjs` en début de Build Command.
//
// Sortie : exit 1 si une variable REQUISE (selon les feature flags) manque.
// =====================================================================

import { readFileSync } from "node:fs";

// Charge un fichier .env si fourni, sinon process.env.
const file = process.argv[2];
let env = { ...process.env };
if (file) {
  try {
    const parsed = Object.fromEntries(
      readFileSync(file, "utf8")
        .split("\n")
        .filter((l) => l.includes("=") && !l.trim().startsWith("#"))
        .map((l) => {
          const i = l.indexOf("=");
          return [l.slice(0, i).trim(), l.slice(i + 1).trim().replace(/^["']|["']$/g, "")];
        }),
    );
    env = { ...env, ...parsed };
  } catch (e) {
    console.error(`Impossible de lire ${file}: ${e.message}`);
    process.exit(2);
  }
}

const has = (k) => typeof env[k] === "string" && env[k].trim().length > 0;
const flag = (k) => env[k] === "true";

// Groupes : level = "required" | "recommended" | "optional"
const GROUPS = [
  {
    title: "Cœur (Supabase + app)",
    vars: [
      ["NEXT_PUBLIC_SUPABASE_URL", "required", "URL du projet Supabase"],
      ["NEXT_PUBLIC_SUPABASE_ANON_KEY", "required", "Clé anon (client)"],
      ["SUPABASE_SERVICE_ROLE_KEY", "required", "Clé service_role (server)"],
      ["NEXT_PUBLIC_APP_URL", "required", "URL publique du site (https://…)"],
    ],
  },
  {
    title: "Paiement (Stripe)",
    vars: [
      ["STRIPE_SECRET_KEY", "required", "Clé secrète Stripe"],
      ["STRIPE_WEBHOOK_SECRET", "required", "Secret de signature du webhook"],
    ],
  },
  {
    title: "Email (Resend) — leads & notifications",
    vars: [
      ["RESEND_API_KEY", "required", "Clé API Resend (sinon emails en console)"],
      ["EMAIL_FROM_ADDRESS", "recommended", "Adresse d'expéditeur"],
      ["EMAIL_REPLY_TO", "optional", "Reply-to"],
      ["LEADS_NOTIFY_EMAIL", "recommended", "Destinataire des nouveaux leads"],
    ],
  },
  {
    title: "Crons (Vercel Cron)",
    vars: [
      ["CRON_SECRET", "required", "Bearer des routes /api/cron/* (sinon 500)"],
    ],
  },
  {
    title: "Notifications push (Web Push) — optionnel",
    vars: [
      ["NEXT_PUBLIC_VAPID_PUBLIC_KEY", "optional", "Clé VAPID publique"],
      ["VAPID_PRIVATE_KEY", "optional", "Clé VAPID privée"],
      ["VAPID_SUBJECT", "optional", "mailto: du VAPID"],
      ["PUSH_WEBHOOK_SECRET", "optional", "Secret webhook push"],
    ],
  },
  {
    title: "Rate-limiting (Upstash) — optionnel (fallback mémoire)",
    vars: [
      ["UPSTASH_REDIS_REST_URL", "optional", "Sinon rate-limit en mémoire (par instance)"],
      ["UPSTASH_REDIS_REST_TOKEN", "optional", ""],
    ],
  },
  {
    title: "Observabilité — recommandé",
    vars: [
      ["SENTRY_DSN", "recommended", "Erreurs serveur"],
      ["NEXT_PUBLIC_SENTRY_DSN", "recommended", "Erreurs client"],
      ["NEXT_PUBLIC_POSTHOG_KEY", "recommended", "Analytics produit"],
      ["NEXT_PUBLIC_POSTHOG_HOST", "optional", ""],
    ],
  },
];

// Conditionnels selon feature flags
const aiOn = flag("FEATURE_AI_TUTOR");
const edofOn = flag("FEATURE_EDOF");
GROUPS.push({
  title: `IA tuteur + génération QCM ${aiOn ? "(ACTIVÉ)" : "(désactivé)"}`,
  vars: [
    ["ANTHROPIC_API_KEY", aiOn ? "required" : "optional", "Claude (tuteur, génération QCM, correction QR)"],
    ["OPENAI_API_KEY", aiOn ? "required" : "optional", "Embeddings RAG"],
  ],
});
GROUPS.push({
  title: `EDOF ${edofOn ? "(ACTIVÉ)" : "(désactivé)"}`,
  vars: [
    ["EDOF_API_BASE_URL", edofOn ? "required" : "optional", ""],
    ["EDOF_CLIENT_ID", edofOn ? "required" : "optional", ""],
    ["EDOF_CLIENT_SECRET", edofOn ? "required" : "optional", ""],
    ["EDOF_OF_SIRET", edofOn ? "required" : "optional", ""],
  ],
});

let missingRequired = 0;
let missingRecommended = 0;

for (const group of GROUPS) {
  console.log(`\n  ${group.title}`);
  for (const [key, level, desc] of group.vars) {
    const present = has(key);
    let mark;
    if (present) mark = "  ✓";
    else if (level === "required") {
      mark = "  ✗ MANQUANT (requis)";
      missingRequired++;
    } else if (level === "recommended") {
      mark = "  ⚠ absent (recommandé)";
      missingRecommended++;
    } else {
      mark = "  · absent (optionnel)";
    }
    console.log(`    ${present ? "✓" : " "} ${key.padEnd(34)} ${mark}${desc ? "  — " + desc : ""}`);
  }
}

console.log("\n" + "=".repeat(60));
if (missingRequired > 0) {
  console.log(`✗ ${missingRequired} variable(s) REQUISE(s) manquante(s) — à corriger avant la mise en prod.`);
  if (missingRecommended > 0) console.log(`⚠ ${missingRecommended} recommandée(s) absente(s).`);
  process.exit(1);
}
console.log(
  missingRecommended > 0
    ? `✓ Toutes les variables requises sont présentes (⚠ ${missingRecommended} recommandée(s) absente(s)).`
    : "✓ Toutes les variables requises et recommandées sont présentes.",
);
