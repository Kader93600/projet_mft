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
    logo: `${LEGAL.website}/og-logo.png`,
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
