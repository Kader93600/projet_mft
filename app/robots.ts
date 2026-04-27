import type { MetadataRoute } from "next";
import { LEGAL } from "@/lib/legal-config";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: "*",
        allow: "/",
        disallow: [
          "/admin",
          "/admin/",
          "/api/",
          "/dashboard",
          "/login/mfa",
          "/onboarding",
          "/positionnement",
          "/mes-donnees",
          "/financeur",
          "/emargement",
        ],
      },
    ],
    sitemap: `${LEGAL.website}/sitemap.xml`,
    host: LEGAL.website,
  };
}
