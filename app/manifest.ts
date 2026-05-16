import type { MetadataRoute } from "next";
import { LEGAL } from "@/lib/legal-config";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: LEGAL.brand,
    short_name: "MFT",
    description: LEGAL.shortDescription,
    start_url: "/dashboard",
    scope: "/",
    display: "standalone",
    background_color: "#0E1240",
    theme_color: "#0E1240",
    orientation: "portrait-primary",
    lang: "fr-FR",
    dir: "ltr",
    categories: ["education", "business", "productivity"],
    prefer_related_applications: false,
    icons: [
      // Icône principale — SVG (vectoriel, supportée partout)
      {
        src: "/icon.svg",
        sizes: "any",
        type: "image/svg+xml",
        purpose: "any",
      },
      // Icône Apple iOS (taille recommandée 180×180)
      {
        src: "/apple-icon.svg",
        sizes: "180x180",
        type: "image/svg+xml",
        purpose: "any",
      },
      // Maskable : Android adaptive icons (safe zone respectée)
      {
        src: "/icon.svg",
        sizes: "any",
        type: "image/svg+xml",
        purpose: "maskable",
      },
    ],
    // Raccourcis dans le menu contextuel de l'app installée (Android/Desktop)
    shortcuts: [
      {
        name: "Tableau de bord",
        short_name: "Dashboard",
        url: "/dashboard",
        description: "Reprendre votre formation",
      },
      {
        name: "Exercices",
        short_name: "Exercices",
        url: "/exercices",
        description: "Quiz d'entraînement",
      },
      {
        name: "Examens blancs",
        short_name: "Examens",
        url: "/examens-blancs",
        description: "S'entraîner en conditions réelles",
      },
    ],
  };
}
