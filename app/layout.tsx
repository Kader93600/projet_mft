import type { Metadata } from "next";
import { Inter, Bricolage_Grotesque, JetBrains_Mono } from "next/font/google";
import { cookies } from "next/headers";
import "./globals.css";
import { createClient } from "@/lib/supabase/server";
import { ThemeInit } from "@/components/theme-toggle";
import { CookieBanner } from "@/components/cookie-banner";
import { JsonLd, organizationSchema } from "@/components/seo/json-ld";
import { ServiceWorkerRegister } from "@/components/service-worker-register";
import { AcquisitionTracker } from "@/components/acquisition-tracker";
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

  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  let prefs: any = null;
  if (user) {
    const { data } = await supabase
      .from("profiles")
      .select(
        "a11y_font_scale, a11y_dyslexia_font, a11y_high_contrast, a11y_reduced_motion, a11y_underline_links"
      )
      .eq("id", user.id)
      .maybeSingle();
    prefs = data;
  }
  // Thème SSR : si l'utilisateur a explicitement choisi "dark", on l'applique
  // dès le HTML serveur → zéro flash. "system" reste géré par ThemeInit côté client.
  const themeCookie = cookies().get("gotrm-theme")?.value;
  const themeClass = themeCookie === "dark" ? "dark" : "";

  const a11yClasses = [
    prefs?.a11y_dyslexia_font && "a11y-dyslexia",
    prefs?.a11y_high_contrast && "a11y-contrast",
    prefs?.a11y_reduced_motion && "a11y-motion",
    prefs?.a11y_underline_links && "a11y-underline",
  ]
    .filter(Boolean)
    .join(" ");
  const fontScale = prefs?.a11y_font_scale ?? 1;

  return (
    <html
      lang={locale}
      className={`${inter.variable} ${display.variable} ${jetbrains.variable} ${a11yClasses} ${themeClass}`}
      style={{
        fontSize: `${Math.round(fontScale * 100)}%`,
        colorScheme: themeCookie === "dark" ? "dark" : themeCookie === "light" ? "light" : undefined,
      }}
    >
      <head>
        <ThemeInit />
        <ServiceWorkerRegister />
        <JsonLd schema={organizationSchema()} />
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
          {children}
          {/* CookieBanner doit rester DANS le provider car il appelle
              useTranslations("cookies") côté client. */}
          <CookieBanner />
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
