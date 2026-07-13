import type { MetadataRoute } from "next";
import { LEGAL } from "@/lib/legal-config";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: "*",
        allow: "/",
        disallow: [
          // Back-office & API
          "/admin",
          "/admin/",
          "/api/",
          "/super-admin",
          // Espace stagiaire (protégé par le middleware)
          "/dashboard",
          "/modules",
          "/quiz",
          "/examens-blancs",
          "/exercices",
          "/evaluation",
          "/stats",
          "/reussites",
          "/classement",
          "/certificats",
          "/messages",
          "/notifications",
          "/glossaire",
          "/recherche",
          "/accompagnement",
          "/satisfaction",
          "/mes-documents",
          "/mes-donnees",
          "/accessibilite",
          // Espaces formateur / financeur
          "/formateur",
          "/financeur",
          // Flux (auth / inscription / signature)
          "/login/mfa",
          "/onboarding",
          "/positionnement",
          "/inscription",
          "/signature-obligatoire",
          "/emargement",
        ],
      },
    ],
    sitemap: `${LEGAL.website}/sitemap.xml`,
    host: LEGAL.website,
  };
}
