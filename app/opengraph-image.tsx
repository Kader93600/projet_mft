import { ImageResponse } from "next/og";
import { LEGAL } from "@/lib/legal-config";

export const runtime = "edge";
export const alt = `${LEGAL.brand} — L'école qui forme les pros du transport`;
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

/**
 * OG image par défaut de MA FORMATION TRANSPORT.
 * Utilisée par la home et toutes les pages sans OG spécifique.
 */
export default async function OgImage() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          background: "#0B0F24",
          backgroundImage:
            "radial-gradient(ellipse at 20% 30%, rgba(159,226,32,0.18) 0%, transparent 55%), radial-gradient(ellipse at 80% 70%, rgba(37,48,217,0.40) 0%, transparent 55%), linear-gradient(135deg, #0B0F24 0%, #161B66 100%)",
          color: "white",
          fontFamily: "sans-serif",
          padding: 70,
          position: "relative",
        }}
      >
        {/* Halos */}
        <div
          style={{
            position: "absolute",
            top: -150,
            right: -150,
            width: 500,
            height: 500,
            borderRadius: 9999,
            background: "#9FE220",
            opacity: 0.15,
            filter: "blur(80px)",
          }}
        />
        <div
          style={{
            position: "absolute",
            bottom: -150,
            left: -150,
            width: 500,
            height: 500,
            borderRadius: 9999,
            background: "#2530D9",
            opacity: 0.25,
            filter: "blur(80px)",
          }}
        />

        {/* Logo en haut */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 16,
            marginBottom: 80,
          }}
        >
          <svg width="64" height="64" viewBox="0 0 64 64">
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
                fontSize: 28,
                fontWeight: 700,
                lineHeight: 1.05,
                color: "#FFFFFF",
              }}
            >
              MA FORMATION
            </div>
            <div
              style={{
                fontSize: 28,
                fontWeight: 800,
                lineHeight: 1.05,
                color: "#9FE220",
              }}
            >
              TRANSPORT
            </div>
          </div>
        </div>

        {/* Eyebrow */}
        <div
          style={{
            display: "inline-flex",
            alignSelf: "flex-start",
            padding: "10px 22px",
            borderRadius: 9999,
            background: "rgba(159,226,32,0.12)",
            border: "2px solid rgba(159,226,32,0.40)",
            color: "#9FE220",
            fontSize: 24,
            fontWeight: 700,
            letterSpacing: "0.16em",
            textTransform: "uppercase",
            marginBottom: 30,
          }}
        >
          Centre de formation transport
        </div>

        {/* Tagline principal */}
        <div
          style={{
            fontSize: 78,
            fontWeight: 700,
            lineHeight: 1.05,
            color: "#FFFFFF",
            letterSpacing: "-0.025em",
            marginBottom: 20,
            display: "flex",
            flexWrap: "wrap",
          }}
        >
          L'école qui forme
        </div>
        <div
          style={{
            fontSize: 78,
            fontWeight: 700,
            lineHeight: 1.05,
            color: "#9FE220",
            fontStyle: "italic",
            letterSpacing: "-0.025em",
            marginBottom: 36,
            display: "flex",
          }}
        >
          les pros du transport.
        </div>

        {/* Footer chips */}
        <div
          style={{
            display: "flex",
            gap: 12,
            marginTop: "auto",
            flexWrap: "wrap",
          }}
        >
          {[
            "GOTRM",
            "ECSR",
            "FIMO/FCO",
            "Taxi/VTC",
            "Capacités",
            "+3 autres",
          ].map((chip, i) => (
            <span
              key={chip}
              style={{
                display: "inline-flex",
                padding: "8px 16px",
                borderRadius: 9999,
                background: "rgba(255,255,255,0.06)",
                border: "1px solid rgba(255,255,255,0.15)",
                color: "rgba(255,255,255,0.85)",
                fontSize: 18,
                fontWeight: 600,
                letterSpacing: "0.08em",
              }}
            >
              {chip}
            </span>
          ))}
        </div>

        {/* URL */}
        <div
          style={{
            marginTop: 30,
            paddingTop: 20,
            borderTop: "1px solid rgba(255,255,255,0.12)",
            color: "rgba(255,255,255,0.45)",
            fontSize: 20,
            letterSpacing: "0.08em",
            textTransform: "uppercase",
            display: "flex",
          }}
        >
          {LEGAL.website.replace(/^https?:\/\//, "")} ·{" "}
          {LEGAL.address.city} · Certifié Qualiopi
        </div>
      </div>
    ),
    {
      ...size,
    }
  );
}
