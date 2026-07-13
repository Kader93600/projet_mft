// Générateurs de JSON-LD pour le SEO structuré.
// Google indexe les formations comme des "Course" et l'organisme comme une
// "EducationalOrganization", ce qui améliore l'apparence dans les SERP.

import { LEGAL } from "@/lib/legal-config";
import type { Formation } from "@/lib/formations-config";

interface Props {
  schema: object;
}

/** Composant générique : injecte un script JSON-LD. */
export function JsonLd({ schema }: Props) {
  return (
    <script
      type="application/ld+json"
      // eslint-disable-next-line react/no-danger
      dangerouslySetInnerHTML={{
        __html: JSON.stringify(schema, null, 0),
      }}
    />
  );
}

/** Schéma Organization pour le layout root. */
export function organizationSchema() {
  return {
    "@context": "https://schema.org",
    "@type": "EducationalOrganization",
    name: LEGAL.legalName,
    alternateName: LEGAL.brand,
    url: LEGAL.website,
    // Image OG générée dynamiquement (un fichier og-logo.png statique
    // n'existe pas — l'ancienne URL renvoyait 404).
    logo: `${LEGAL.website}/opengraph-image`,
    description: LEGAL.shortDescription,
    address: {
      "@type": "PostalAddress",
      streetAddress: LEGAL.address.street,
      postalCode: LEGAL.address.postalCode,
      addressLocality: LEGAL.address.city,
      addressCountry: "FR",
    },
    contactPoint: {
      "@type": "ContactPoint",
      telephone: LEGAL.phone,
      email: LEGAL.email,
      contactType: "customer support",
      availableLanguage: ["French"],
    },
    sameAs: [LEGAL.website],
  };
}

/** Schéma Course pour une page formation. */
export function courseSchema(f: Formation) {
  return {
    "@context": "https://schema.org",
    "@type": "Course",
    name: f.title,
    description: f.tagline,
    provider: {
      "@type": "EducationalOrganization",
      name: LEGAL.legalName,
      url: LEGAL.website,
    },
    courseCode: f.code,
    inLanguage: "fr-FR",
    educationalLevel: f.level ? `Level ${f.level}` : undefined,
    timeRequired: f.duration,
    teaches: f.skills.join(", "),
    educationalCredentialAwarded: f.rncpCode
      ? `Titre professionnel ${f.rncpCode}`
      : "Attestation de fin de formation",
    occupationalCategory: f.category,
    hasCourseInstance: {
      "@type": "CourseInstance",
      courseMode: f.modality === "presentiel" ? "onsite" : f.modality === "distanciel" ? "online" : "blended",
      inLanguage: "fr-FR",
      location: {
        "@type": "Place",
        name: LEGAL.brand,
        address: {
          "@type": "PostalAddress",
          streetAddress: LEGAL.address.street,
          postalCode: LEGAL.address.postalCode,
          addressLocality: LEGAL.address.city,
          addressCountry: "FR",
        },
      },
    },
  };
}

/**
 * Schéma LocalBusiness pour le SEO local (centre physique à Meaux).
 * Éligible aux résultats locaux / Google Business Profile. À monter sur
 * la page la plus « locale » (l'école) et/ou la home.
 *
 * NB : `geo` (coordonnées GPS) et `openingHours` ne sont PAS renseignés
 * tant que les valeurs exactes ne sont pas confirmées — on ne met pas de
 * données inventées (Google pénalise les incohérences NAP). À compléter
 * dès que disponibles.
 */
export function localBusinessSchema() {
  return {
    "@context": "https://schema.org",
    "@type": ["EducationalOrganization", "LocalBusiness"],
    "@id": `${LEGAL.website}/#organization`,
    name: LEGAL.legalName,
    alternateName: LEGAL.brand,
    url: LEGAL.website,
    logo: `${LEGAL.website}/opengraph-image`,
    image: `${LEGAL.website}/opengraph-image`,
    description: LEGAL.shortDescription,
    telephone: LEGAL.phone,
    email: LEGAL.email,
    priceRange: "€€",
    address: {
      "@type": "PostalAddress",
      streetAddress: LEGAL.address.street,
      postalCode: LEGAL.address.postalCode,
      addressLocality: LEGAL.address.city,
      addressRegion: "Île-de-France",
      addressCountry: "FR",
    },
    areaServed: [
      { "@type": "City", name: "Meaux" },
      { "@type": "AdministrativeArea", name: "Seine-et-Marne" },
      { "@type": "AdministrativeArea", name: "Île-de-France" },
    ],
    sameAs: [LEGAL.website],
  };
}

/**
 * Schéma Article pour une page de blog / guide.
 * Renseigne l'auteur (organisation), l'éditeur, les dates et l'URL
 * canonique. Éligible aux résultats enrichis « Article ».
 */
export function articleSchema(a: {
  title: string;
  description: string;
  slug: string;
  datePublished: string;
  dateModified: string;
}) {
  const url = `${LEGAL.website}/blog/${a.slug}`;
  return {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: a.title,
    description: a.description,
    datePublished: a.datePublished,
    dateModified: a.dateModified,
    inLanguage: "fr-FR",
    mainEntityOfPage: { "@type": "WebPage", "@id": url },
    url,
    image: `${LEGAL.website}/opengraph-image`,
    author: {
      "@type": "Organization",
      name: LEGAL.brand,
      url: LEGAL.website,
    },
    publisher: {
      "@type": "Organization",
      name: LEGAL.brand,
      url: LEGAL.website,
      logo: {
        "@type": "ImageObject",
        url: `${LEGAL.website}/opengraph-image`,
      },
    },
  };
}

/** Schéma BreadcrumbList générique. */
export function breadcrumbSchema(items: { name: string; url: string }[]) {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((it, i) => ({
      "@type": "ListItem",
      position: i + 1,
      name: it.name,
      item: it.url,
    })),
  };
}

// FAQPage — rich result « FAQ » de Google. `items` = [{ q, a }].
export function faqSchema(items: { q: string; a: string }[]) {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: items.map((it) => ({
      "@type": "Question",
      name: it.q,
      acceptedAnswer: { "@type": "Answer", text: it.a },
    })),
  };
}
