import type { MetadataRoute } from "next";
import { LEGAL } from "@/lib/legal-config";
import { FORMATIONS } from "@/lib/formations-config";
import { ARTICLES } from "@/lib/blog-config";

export default function sitemap(): MetadataRoute.Sitemap {
  const base = LEGAL.website.replace(/\/$/, "");
  const now = new Date();

  // Pages publiques principales.
  // NB home : URL SANS slash final pour coïncider avec le canonical rendu
  // par Next (qui normalise `${website}/` en `${website}` via metadataBase).
  const staticEntries: MetadataRoute.Sitemap = [
    { url: base, lastModified: now, changeFrequency: "weekly", priority: 1 },
    { url: `${base}/formations`, lastModified: now, changeFrequency: "weekly", priority: 0.9 },
    { url: `${base}/ecole`, lastModified: now, changeFrequency: "monthly", priority: 0.7 },
    { url: `${base}/financements`, lastModified: now, changeFrequency: "monthly", priority: 0.7 },
    { url: `${base}/contact`, lastModified: now, changeFrequency: "monthly", priority: 0.6 },
    { url: `${base}/tarifs`, lastModified: now, changeFrequency: "monthly", priority: 0.7 },
    { url: `${base}/temoignages`, lastModified: now, changeFrequency: "monthly", priority: 0.6 },
    { url: `${base}/blog`, lastModified: now, changeFrequency: "weekly", priority: 0.7 },
    // Légales
    { url: `${base}/mentions-legales`, lastModified: now, priority: 0.3 },
    { url: `${base}/cgu`, lastModified: now, priority: 0.3 },
    { url: `${base}/cgv`, lastModified: now, priority: 0.3 },
    { url: `${base}/confidentialite`, lastModified: now, priority: 0.3 },
    { url: `${base}/retractation`, lastModified: now, priority: 0.3 },
    { url: `${base}/reglement-interieur`, lastModified: now, priority: 0.3 },
    // /accessibilite est une page PROTÉGÉE (préférences stagiaire) — la
    // page publique indexable est la déclaration d'accessibilité.
    { url: `${base}/declaration-accessibilite`, lastModified: now, priority: 0.3 },
    { url: `${base}/resultats`, lastModified: now, priority: 0.3 },
    { url: `${base}/reclamations`, lastModified: now, priority: 0.3 },
  ];

  // Pages formations dynamiques
  const formationEntries: MetadataRoute.Sitemap = FORMATIONS.map((f) => ({
    url: `${base}/formations/${f.slug}`,
    lastModified: now,
    changeFrequency: "weekly" as const,
    priority: f.featured ? 0.85 : 0.75,
  }));

  // Articles de blog / guides
  const articleEntries: MetadataRoute.Sitemap = ARTICLES.map((a) => ({
    url: `${base}/blog/${a.slug}`,
    lastModified: new Date(a.updatedAt),
    changeFrequency: "monthly" as const,
    priority: 0.6,
  }));

  return [...staticEntries, ...formationEntries, ...articleEntries];
}
