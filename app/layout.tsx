import type { Metadata } from "next";
import { Suspense } from "react";
import { Inter, Bricolage_Grotesque, JetBrains_Mono } from "next/font/google";
import "./globals.css";
import { ThemeInit } from "@/components/theme-toggle";
import { CookieBanner } from "@/components/cookie-banner";
import { JsonLd, organizationSchema } from "@/components/seo/json-ld";
import { ServiceWorkerRegister } from "@/components/service-worker-register";
import { AcquisitionTracker } from "@/components/acquisition-tracker";
import { FormValidationTooltip } from "@/components/form-validation-tooltip";
import { A11yPrefsLoader } from "@/components/a11y-prefs-loader";
import { LEGAL } from "@/lib/legal-config";
import { NextIntlClientProvider } from "next-intl";
import { getLocale, getMessages } from "next-intl/server";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});
// Display font moderne (sans-serif architecturale, vibe Stripe/Linear).
// On garde l'alias --font-fraunces pour ne pas casser les usages existants.
const display = Bricolage_Grotesque({
  subsets: ["latin"],
  variable: "--font-fraunces",
  display: "swap",
  axes: ["wdth", "opsz"],
});
const jetbrains = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-jetbrains",
  display: "swap",
});

export const metadata: Metadata = {
  metadataBase: new URL(LEGAL.website),
  title: {
    default: `${LEGAL.brand} — L'école qui forme les pros du transport`,
    template: `%s · ${LEGAL.brand}`,
  },
  description: LEGAL.shortDescription,
  keywords: [
    "formation transport",
    "GOTRM",
    "ECSR",
    "FIMO",
    "FCO",
    "Taxi VTC",
    "capacité de transport",
    "Qualiopi",
    "Meaux",
    LEGAL.brand,
  ],
  authors: [{ name: LEGAL.brand }],
  creator: LEGAL.legalName,
  publisher: LEGAL.legalName,
  openGraph: {
    type: "website",
    locale: "fr_FR",
    url: LEGAL.website,
    siteName: LEGAL.brand,
    title: `${LEGAL.brand} — L'école qui forme les pros du transport`,
    description: LEGAL.shortDescription,
  },
  twitter: {
    card: "summary_large_image",
    title: LEGAL.brand,
    description: LEGAL.shortDescription,
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  manifest: "/manifest.webmanifest",
  appleWebApp: {
    capable: true,
    title: LEGAL.brand,
    statusBarStyle: "black-translucent",
  },
};

export const viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#FFFFFF" },
    { media: "(prefers-color-scheme: dark)", color: "#0E1240" },
  ],
  width: "device-width",
  initialScale: 1,
};

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  // i18n : récupère la locale + messages côté serveur via i18n/request.ts
  const locale = await getLocale();
  const messages = await getMessages();

  // NB : ce layout n'appelle PLUS `cookies()` directement → il ne force
  // plus tout le site en rendu dynamique. Les pages vitrine (/, /formations,
  // /ecole, …) redeviennent statiques / cachables par le CDN.
  //   - Thème (dark/light) : géré sans cookie serveur par <ThemeInit/>
  //     (script inline anti-FOUC côté client).
  //   - Préférences a11y de l'utilisateur connecté : isolées dans
  //     <A11yPrefsLoader/> (sous <Suspense>), qui est le seul à lire les
  //     cookies — sans contaminer le cache des pages publiques.

  return (
    <html
      lang={locale}
      className={`${inter.variable} ${display.variable} ${jetbrains.variable}`}
    >
      <head>
        <ThemeInit />
        <ServiceWorkerRegister />
        <JsonLd schema={organizationSchema()} />
        <Suspense fallback={null}>
          <A11yPrefsLoader />
        </Suspense>
      </head>
      <body className="min-h-screen bg-ivory font-sans antialiased text-ink selection:bg-gold-200 selection:text-navy-900">
        <a
          href="#main-content"
          className="sr-only focus:not-sr-only focus:fixed focus:top-2 focus:left-2 focus:z-[100] focus:bg-navy-900 focus:text-white focus:px-4 focus:py-2 focus:rounded-lg focus:shadow-raised"
        >
          {locale === "en" ? "Skip to main content" : "Aller au contenu principal"}
        </a>
        <NextIntlClientProvider locale={locale} messages={messages}>
          {/* AcquisitionTracker : monté globalement, filtre les routes
              publiques uniquement côté client (cf. AUTH_ROUTE_PREFIXES). */}
          <AcquisitionTracker />
          {/* Restyle global des bulles de validation natives (tous les forms). */}
          <FormValidationTooltip />
          {children}
          {/* CookieBanner doit rester DANS le provider car il appelle
              useTranslations("cookies") côté client. */}
          <CookieBanner />
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
