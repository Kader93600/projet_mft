import { createClient } from "@/lib/supabase/server";
import { NextRequest, NextResponse } from "next/server";
import {
  Document,
  Page,
  Text,
  View,
  StyleSheet,
  renderToBuffer,
} from "@react-pdf/renderer";
import React from "react";
import { PdfLogoMark } from "@/lib/pdf-logo";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const s = StyleSheet.create({
  page: { padding: 40, fontSize: 10, fontFamily: "Helvetica", color: "#0f172a" },
  topBar: { height: 6, backgroundColor: "#9FE220", marginBottom: 18 },
  brand: { fontSize: 16, fontWeight: "bold", color: "#0E1240" },
  sub: { fontSize: 9, color: "#64748b", marginTop: 2, marginBottom: 8 },
  title: {
    fontSize: 22,
    fontWeight: "bold",
    color: "#0E1240",
    textTransform: "uppercase",
    letterSpacing: 2,
    marginTop: 6,
    marginBottom: 2,
  },
  rncp: { fontSize: 10, color: "#609015", fontWeight: "bold", marginBottom: 14 },
  ul: { width: 30, height: 2, backgroundColor: "#9FE220", marginBottom: 16 },
  h2: {
    fontSize: 11,
    fontWeight: "bold",
    color: "#0E1240",
    textTransform: "uppercase",
    letterSpacing: 1,
    marginTop: 14,
    marginBottom: 4,
    borderBottomWidth: 1,
    borderBottomColor: "#9FE220",
    paddingBottom: 3,
  },
  para: { fontSize: 10, lineHeight: 1.55, color: "#334155", marginBottom: 4 },
  list: { fontSize: 10, lineHeight: 1.55, color: "#334155", marginLeft: 8 },
  grid: { flexDirection: "row", gap: 10, marginTop: 6, marginBottom: 6 },
  card: {
    flex: 1,
    padding: 8,
    borderWidth: 1,
    borderColor: "#e2e8f0",
    backgroundColor: "#f8fafc",
    borderRadius: 4,
  },
  cardLabel: { fontSize: 8, color: "#64748b", textTransform: "uppercase", marginBottom: 3 },
  cardVal: { fontSize: 11, fontWeight: "bold", color: "#0E1240" },
  footer: {
    position: "absolute",
    bottom: 24,
    left: 40,
    right: 40,
    fontSize: 7,
    color: "#94a3b8",
    borderTopWidth: 1,
    borderTopColor: "#e2e8f0",
    paddingTop: 6,
    flexDirection: "row",
    justifyContent: "space-between",
  },
});

function lines(txt: string | null | undefined) {
  if (!txt) return [];
  return txt
    .split("\n")
    .map((l) => l.replace(/^[-•]\s*/, "").trim())
    .filter(Boolean);
}

function Programme({ cfg, today }: { cfg: any; today: string }) {
  const C = React.createElement;
  return C(
    Document,
    {},
    C(
      Page,
      { size: "A4", style: s.page },
      C(View, { style: s.topBar }),
      C(
        View,
        { style: { flexDirection: "row", alignItems: "center", gap: 10, marginBottom: 2 } },
        C(PdfLogoMark, { size: 32 }),
        C(Text, { style: s.brand }, cfg?.organisme_nom || "MA FORMATION TRANSPORT")
      ),
      C(
        Text,
        { style: s.sub },
        `Organisme de formation${cfg?.organisme_num_da ? " · DA " + cfg.organisme_num_da : ""}${
          cfg?.organisme_siret ? " · SIRET " + cfg.organisme_siret : ""
        }`
      ),

      C(Text, { style: s.title }, "Programme de formation"),
      C(Text, { style: s.rncp }, cfg?.formation_rncp || ""),
      C(View, { style: s.ul }),

      C(Text, { style: s.para }, cfg?.formation_titre || ""),

      // Tuiles synthétiques
      C(
        View,
        { style: s.grid },
        C(
          View,
          { style: s.card },
          C(Text, { style: s.cardLabel }, "Durée"),
          C(Text, { style: s.cardVal }, `${cfg?.formation_duree_h ?? 0} heures`)
        ),
        C(
          View,
          { style: s.card },
          C(Text, { style: s.cardLabel }, "Modalité"),
          C(Text, { style: s.cardVal }, "100% à distance")
        ),
        C(
          View,
          { style: s.card },
          C(Text, { style: s.cardLabel }, "Tarif"),
          C(Text, { style: s.cardVal }, cfg?.formation_tarif || "Sur devis")
        ),
        C(
          View,
          { style: s.card },
          C(Text, { style: s.cardLabel }, "Délai d'accès"),
          C(Text, { style: s.cardVal }, cfg?.formation_delai_acces || "—")
        )
      ),

      C(Text, { style: s.h2 }, "Public visé"),
      C(Text, { style: s.para }, cfg?.formation_public || "—"),

      C(Text, { style: s.h2 }, "Prérequis"),
      C(Text, { style: s.para }, cfg?.formation_prerequis || "—"),

      C(Text, { style: s.h2 }, "Objectifs pédagogiques"),
      ...lines(cfg?.formation_objectifs).map((l: string, i: number) =>
        C(Text, { key: "o" + i, style: s.list }, `•  ${l}`)
      ),

      C(Text, { style: s.h2 }, "Méthodes pédagogiques"),
      ...lines(cfg?.formation_methodes).map((l: string, i: number) =>
        C(Text, { key: "m" + i, style: s.list }, `•  ${l}`)
      ),

      C(Text, { style: s.h2 }, "Modalités d'évaluation"),
      ...lines(cfg?.formation_evaluation).map((l: string, i: number) =>
        C(Text, { key: "e" + i, style: s.list }, `•  ${l}`)
      ),

      C(Text, { style: s.h2 }, "Accessibilité et handicap"),
      C(Text, { style: s.para }, cfg?.formation_handicap || "—"),
      cfg?.formation_referent_handicap
        ? C(Text, { style: s.para }, `Référent handicap : ${cfg.formation_referent_handicap}`)
        : null,

      C(Text, { style: s.h2 }, "Contact"),
      C(
        Text,
        { style: s.para },
        [
          cfg?.organisme_responsable,
          cfg?.organisme_email,
          cfg?.organisme_telephone,
          cfg?.organisme_adresse,
        ]
          .filter(Boolean)
          .join(" · ") || "—"
      ),

      C(
        View,
        { style: s.footer, fixed: true },
        C(Text, {}, `Programme édité le ${today} — conforme aux exigences Qualiopi`),
        C(Text, {
          render: ({ pageNumber, totalPages }: any) => `${pageNumber} / ${totalPages}`,
        })
      )
    )
  );
}

export async function GET() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "unauth" }, { status: 401 });

  const { data: cfg } = await supabase
    .from("formation_settings")
    .select("*")
    .eq("id", true)
    .single();

  const today = new Date().toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });

  const buffer = await renderToBuffer(Programme({ cfg, today }));
  return new NextResponse(buffer as any, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="programme-formation.pdf"`,
      "Cache-Control": "no-store",
    },
  });
}
