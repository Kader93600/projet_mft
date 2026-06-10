import { ImageResponse } from "next/og";
import { findFormation } from "@/lib/formations-config";
import { LEGAL } from "@/lib/legal-config";

// NB : pas de `runtime = "edge"` — renvoyait des PNG vides sur Vercel.
export const alt = "MA FORMATION TRANSPORT — Formation";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

/**
 * Génère dynamiquement l'image Open Graph (1200×630) d'une formation.
 * - Fond dégradé brand → couleur d'accent de la formation
 * - Logo MA FORMATION TRANSPORT
 * - Code formation + titre + RNCP
 * - Footer avec qualité Qualiopi
 *
 * Utilisée automatiquement par Next.js dans les balises OG/Twitter.
 */
export default async function OgImage({ params }: { params: { slug: string } }) {
  const f = findFormation(params.slug);
  const accent = f?.accent ?? "#9FE220";
  const code = f?.code ?? "Formation";
  const title = f?.title ?? "Formation transport";
  const rncp = f?.rncpCode;
  const duration = f?.duration ?? "";

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          background: "#0B0F24",
          backgroundImage: `radial-gradient(ellipse at 0% 0%, ${accent}33 0%, transparent 50%), radial-gradient(ellipse at 100% 100%, #2530D955 0%, transparent 50%), linear-gradient(135deg, #0B0F24 0%, #161B66 100%)`,
          color: "white",
          fontFamily: "sans-serif",
          padding: 70,
          position: "relative",
        }}
      >
        {/* Halo accent en haut à droite */}
        <div
          style={{
            position: "absolute",
            top: -120,
            right: -120,
            width: 400,
            height: 400,
            borderRadius: 9999,
            background: accent,
            opacity: 0.18,
            filter: "blur(60px)",
          }}
        />

        {/* Header : Logo */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 16,
            marginBottom: 60,
          }}
        >
          {/* Mark logo SVG inline */}
          <svg width="56" height="56" viewBox="0 0 64 64">
            <circle
              cx="32"
              cy="36"
              r="22"
              fill="none"
              stroke="#FFFFFF"
              strokeWidth="3.5"
            />
            <path d="M22 56 L42 56 L36 22 L28 22 Z" fill="#9FE220" />
            <rect x="31.2" y="26" width="1.6" height="4" fill="#FFFFFF" />
            <rect x="31.1" y="33" width="1.8" height="5" fill="#FFFFFF" />
            <rect x="30.9" y="42" width="2.2" height="6" fill="#FFFFFF" />
            <rect x="30.6" y="51" width="2.8" height="4" fill="#FFFFFF" />
            <path d="M32 6 L52 14 L32 22 L12 14 Z" fill="#FFFFFF" />
            <line
              x1="48"
              y1="14"
              x2="48"
              y2="22"
              stroke="#FFFFFF"
              strokeWidth="1.4"
            />
            <circle cx="48" cy="22.5" r="1.4" fill="#FFFFFF" />
          </svg>
          <div style={{ display: "flex", flexDirection: "column" }}>
            <div
              style={{
                fontSize: 22,
                fontWeight: 700,
                lineHeight: 1.1,
                color: "#FFFFFF",
              }}
            >
              MA FORMATION
            </div>
            <div
              style={{
                fontSize: 22,
                fontWeight: 800,
                lineHeight: 1.1,
                color: "#9FE220",
              }}
            >
              TRANSPORT
            </div>
          </div>
        </div>

        {/* Code formation */}
        <div
          style={{
            display: "flex",
            alignSelf: "flex-start",
            padding: "8px 18px",
            borderRadius: 9999,
            background: `${accent}22`,
            border: `2px solid ${accent}99`,
            color: accent,
            fontSize: 22,
            fontWeight: 700,
            letterSpacing: "0.16em",
            textTransform: "uppercase",
            marginBottom: 28,
          }}
        >
          {code}
        </div>

        {/* Titre formation */}
        <div
          style={{
            fontSize: title.length > 60 ? 52 : title.length > 40 ? 60 : 68,
            fontWeight: 700,
            lineHeight: 1.05,
            color: "#FFFFFF",
            letterSpacing: "-0.025em",
            marginBottom: 24,
            display: "flex",
            maxWidth: 1000,
          }}
        >
          {title}
        </div>

        {/* Métadonnées */}
        <div
          style={{
            display: "flex",
            gap: 24,
            marginTop: "auto",
            color: "rgba(255,255,255,0.7)",
            fontSize: 22,
          }}
        >
          {rncp && (
            <span
              style={{
                display: "flex",
                alignItems: "center",
                gap: 8,
              }}
            >
              <span
                style={{
                  width: 8,
                  height: 8,
                  borderRadius: 9999,
                  background: "#9FE220",
                  display: "block",
                }}
              />
              {rncp}
            </span>
          )}
          {duration && (
            <span
              style={{
                display: "flex",
                alignItems: "center",
                gap: 8,
              }}
            >
              <span
                style={{
                  width: 8,
                  height: 8,
                  borderRadius: 9999,
                  background: accent,
                  display: "block",
                }}
              />
              {duration}
            </span>
          )}
          <span
            style={{
              display: "flex",
              alignItems: "center",
              gap: 8,
            }}
          >
            <span
              style={{
                width: 8,
                height: 8,
                borderRadius: 9999,
                background: "#9FE220",
                display: "block",
              }}
            />
            Certifié Qualiopi
          </span>
        </div>

        {/* URL */}
        <div
          style={{
            marginTop: 24,
            paddingTop: 20,
            borderTop: "1px solid rgba(255,255,255,0.12)",
            color: "rgba(255,255,255,0.45)",
            fontSize: 18,
            letterSpacing: "0.08em",
            textTransform: "uppercase",
            display: "flex",
          }}
        >
          {LEGAL.website.replace(/^https?:\/\//, "")} ·{" "}
          {LEGAL.address.city}
        </div>
      </div>
    ),
    {
      ...size,
    }
  );
}
