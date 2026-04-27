import type { MetadataRoute } from "next";
import { LEGAL } from "@/lib/legal-config";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: LEGAL.brand,
    short_name: "MFT",
    description: LEGAL.shortDescription,
    start_url: "/dashboard",
    display: "standalone",
    background_color: "#0E1240",
    theme_color: "#0E1240",
    orientation: "portrait-primary",
    lang: "fr-FR",
    categories: ["education", "business"],
    icons: [
      {
        src: "/icon.svg",
        sizes: "any",
        type: "image/svg+xml",
        purpose: "any",
      },
      {
        src: "/apple-icon.svg",
        sizes: "180x180",
        type: "image/svg+xml",
        purpose: "any",
      },
    ],
  };
}
