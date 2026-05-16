// =====================================================================
// next-intl configuration — Server-side (RSC)
//
// On utilise une approche SANS préfixe de locale dans l'URL (pas de
// /fr/dashboard ni /en/dashboard). La langue est déterminée par :
//   1. Cookie "NEXT_LOCALE" (défini par <LocaleToggle />)
//   2. Header Accept-Language du navigateur (fallback)
//   3. "fr" par défaut (langue principale MFT)
//
// Cette approche garde toutes les URLs existantes intactes. Le compromis :
// pas de SEO multilingue natif (un même /tarifs peut afficher fr ou en
// selon le visiteur). Pour du SEO multilingue, migrer vers [locale]/ plus
// tard, en gardant les mêmes fichiers messages/.
// =====================================================================

import { getRequestConfig } from "next-intl/server";
import { cookies, headers } from "next/headers";

export const locales = ["fr", "en"] as const;
export type Locale = (typeof locales)[number];
export const defaultLocale: Locale = "fr";

function resolveLocale(): Locale {
  // 1. Cookie explicite
  const cookieLocale = cookies().get("NEXT_LOCALE")?.value;
  if (cookieLocale && locales.includes(cookieLocale as Locale)) {
    return cookieLocale as Locale;
  }

  // 2. Accept-Language du navigateur
  const acceptLanguage = headers().get("accept-language") ?? "";
  for (const lang of acceptLanguage.split(",")) {
    const code = lang.split(";")[0].trim().slice(0, 2).toLowerCase();
    if (locales.includes(code as Locale)) {
      return code as Locale;
    }
  }

  // 3. Défaut
  return defaultLocale;
}

export default getRequestConfig(async () => {
  const locale = resolveLocale();
  return {
    locale,
    messages: (await import(`../messages/${locale}.json`)).default,
  };
});
