// =====================================================================
// Logo PDF — primitive SVG @react-pdf/renderer
// =====================================================================
// Reproduit le pictogramme officiel MA FORMATION TRANSPORT
// (cercle bleu + route en perspective verte + toque universitaire bleue)
// au format compatible @react-pdf/renderer (pas de PNG externe à charger,
// rendu vectoriel net à toute taille).
//
// Usage dans un PDF route :
//   import { PdfLogoMark, PdfBrandHeader } from "@/lib/pdf-logo";
//   const C = React.createElement;
//   C(PdfBrandHeader, { organisme: cfg?.organisme_nom, sub: "DA …" })
// =====================================================================

import React from "react";
import {
  View,
  Text,
  Svg,
  Circle,
  Path,
  Rect,
  Line,
  G,
} from "@react-pdf/renderer";

const BRAND = "#2530D9"; // navy/brand bleu
const ROAD = "#9FE220";  // signal vert
const TEXT_NAVY = "#0E1240";
const TEXT_GREEN = "#609015";

/**
 * Pictogramme seul (cercle + route + toque) — vectoriel.
 * Tailles courantes : 28 (small header), 36 (default), 48 (cover page).
 */
export function PdfLogoMark({ size = 36 }: { size?: number }) {
  const C = React.createElement;
  return C(
    Svg,
    { width: size, height: size, viewBox: "0 0 64 64" },
    // Cercle
    C(Circle, {
      cx: 32,
      cy: 36,
      r: 22,
      stroke: BRAND,
      strokeWidth: 3.5,
      fill: "none",
    }),
    // Route en perspective (trapèze)
    C(Path, {
      d: "M22 56 L42 56 L36 22 L28 22 Z",
      fill: ROAD,
    }),
    // Bandes blanches centrales sur la route
    C(Rect, { x: 31.2, y: 26, width: 1.6, height: 4, fill: "#FFFFFF" }),
    C(Rect, { x: 31.1, y: 33, width: 1.8, height: 5, fill: "#FFFFFF" }),
    C(Rect, { x: 30.9, y: 42, width: 2.2, height: 6, fill: "#FFFFFF" }),
    C(Rect, { x: 30.6, y: 51, width: 2.8, height: 4, fill: "#FFFFFF" }),
    // Toque (plateau losange)
    C(Path, {
      d: "M32 6 L52 14 L32 22 L12 14 Z",
      fill: BRAND,
    }),
    // Toque (pompon)
    C(Circle, { cx: 48, cy: 14, r: 1.6, fill: BRAND }),
    C(Line, {
      x1: 48,
      y1: 14,
      x2: 48,
      y2: 22,
      stroke: BRAND,
      strokeWidth: 1.4,
      strokeLinecap: "round",
    }),
    C(Circle, { cx: 48, cy: 22.5, r: 1.4, fill: BRAND })
  );
}

/**
 * Bandeau d'en-tête : pictogramme + nom organisme + ligne sub.
 * À placer en TÊTE de chaque PDF, juste sous la barre verte (topBar).
 */
export function PdfBrandHeader({
  organisme,
  sub,
  size = 36,
}: {
  organisme: string;
  sub?: string;
  size?: number;
}) {
  const C = React.createElement;
  return C(
    View,
    {
      style: {
        flexDirection: "row",
        alignItems: "center",
        gap: 10,
        marginBottom: 8,
      },
    },
    C(PdfLogoMark, { size }),
    C(
      View,
      { style: { flexDirection: "column" } },
      C(
        Text,
        {
          style: {
            fontSize: 14,
            fontWeight: "bold",
            color: TEXT_NAVY,
            letterSpacing: 0.5,
          },
        },
        "MA FORMATION"
      ),
      C(
        Text,
        {
          style: {
            fontSize: 14,
            fontWeight: "bold",
            color: TEXT_GREEN,
            letterSpacing: 0.5,
            marginTop: 1,
          },
        },
        "TRANSPORT"
      ),
      sub
        ? C(
            Text,
            {
              style: {
                fontSize: 8,
                color: "#64748b",
                marginTop: 3,
              },
            },
            sub
          )
        : null
    )
  );
}
