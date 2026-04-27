import { createClient } from "@/lib/supabase/server";
import { isStaff } from "@/lib/permissions";
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

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

// Certificat de réalisation — document officiel distinct de l'attestation
// Mentions obligatoires : nom stagiaire, intitulé de l'action, durée prévue,
// durée réalisée, dates, nature de l'action (à distance).

const s = StyleSheet.create({
  page: { padding: 44, fontSize: 11, fontFamily: "Helvetica", color: "#0f172a" },
  topBar: { height: 8, backgroundColor: "#9FE220", marginBottom: 24 },
  brand: { fontSize: 14, fontWeight: "bold", color: "#0E1240" },
  meta: { fontSize: 8, color: "#64748b", marginTop: 2 },
  title: {
    fontSize: 22,
    fontWeight: "bold",
    color: "#0E1240",
    textAlign: "center",
    marginTop: 28,
    marginBottom: 4,
    textTransform: "uppercase",
    letterSpacing: 2,
  },
  subtitle: {
    fontSize: 9,
    color: "#609015",
    textAlign: "center",
    letterSpacing: 1,
    marginBottom: 6,
  },
  ul: {
    width: 70,
    height: 2,
    backgroundColor: "#9FE220",
    alignSelf: "center",
    marginBottom: 22,
  },
  intro: {
    fontSize: 10.5,
    textAlign: "center",
    lineHeight: 1.6,
    color: "#334155",
    marginBottom: 14,
  },
  name: {
    fontSize: 16,
    fontWeight: "bold",
    textAlign: "center",
    color: "#0E1240",
    paddingVertical: 8,
    borderTopWidth: 1,
    borderBottomWidth: 1,
    borderColor: "#9FE220",
    marginBottom: 16,
  },
  body: {
    fontSize: 10.5,
    lineHeight: 1.7,
    color: "#334155",
    textAlign: "justify",
    marginBottom: 16,
  },
  row: { flexDirection: "row", marginBottom: 4 },
  label: { width: 180, fontSize: 10, color: "#64748b" },
  val: { flex: 1, fontSize: 10.5, color: "#0E1240", fontWeight: "bold" },
  statsRow: { flexDirection: "row", gap: 8, marginTop: 16, marginBottom: 20 },
  stat: {
    flex: 1,
    padding: 10,
    borderWidth: 1,
    borderColor: "#e2e8f0",
    backgroundColor: "#f8fafc",
    alignItems: "center",
  },
  statLabel: {
    fontSize: 8,
    color: "#64748b",
    textTransform: "uppercase",
    marginBottom: 3,
  },
  statVal: { fontSize: 14, fontWeight: "bold", color: "#0E1240" },
  statBig: { fontSize: 16, fontWeight: "bold", color: "#609015" },
  signBox: {
    marginTop: 30,
    flexDirection: "row",
    justifyContent: "space-between",
  },
  signBlock: { width: "45%" },
  signDate: { fontSize: 10, marginBottom: 36 },
  signLine: {
    borderTopWidth: 1,
    borderTopColor: "#0E1240",
    paddingTop: 3,
    fontSize: 8.5,
    color: "#64748b",
  },
  footer: {
    position: "absolute",
    bottom: 26,
    left: 44,
    right: 44,
    fontSize: 7,
    color: "#94a3b8",
    textAlign: "center",
    borderTopWidth: 1,
    borderTopColor: "#e2e8f0",
    paddingTop: 6,
  },
});

function fmtDate(d: string | null) {
  if (!d) return "—";
  return new Date(d).toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
}
function fmtHours(sec: number) {
  const h = Math.floor(sec / 3600);
  const m = Math.floor((sec % 3600) / 60);
  return `${h}h${String(m).padStart(2, "0")}`;
}

function Certificat({
  cfg,
  user,
  summary,
  today,
}: {
  cfg: any;
  user: any;
  summary: any;
  today: string;
}) {
  const C = React.createElement;
  const realisedSec =
    (summary?.total_session_s ?? 0) + (summary?.lesson_time_s ?? 0);
  const realisedH = realisedSec / 3600;
  const prevuH = cfg?.formation_duree_h ?? 0;
  const pct = prevuH ? Math.min(100, Math.round((realisedH / prevuH) * 100)) : 0;

  return C(
    Document,
    {},
    C(
      Page,
      { size: "A4", style: s.page },
      C(View, { style: s.topBar }),
      C(Text, { style: s.brand }, cfg?.organisme_nom || "GOTRM Academy"),
      C(
        Text,
        { style: s.meta },
        `${cfg?.organisme_num_da ? "DA " + cfg.organisme_num_da : ""}${
          cfg?.organisme_siret ? " · SIRET " + cfg.organisme_siret : ""
        }`
      ),

      C(Text, { style: s.title }, "Certificat de réalisation"),
      C(Text, { style: s.subtitle }, "Action de formation à distance"),
      C(View, { style: s.ul }),

      C(
        Text,
        { style: s.intro },
        `Je soussigné(e), ${
          cfg?.organisme_responsable || "responsable pédagogique"
        }, représentant légal de l'organisme ${
          cfg?.organisme_nom || "GOTRM Academy"
        }, certifie que :`
      ),

      C(Text, { style: s.name }, user?.full_name || user?.email || "—"),

      C(
        Text,
        { style: s.body },
        `a suivi l'action de formation intitulée « ${
          cfg?.formation_titre || ""
        } » (${cfg?.formation_rncp || ""}) dispensée en distanciel sur la plateforme ${
          cfg?.organisme_nom || "GOTRM Academy"
        }.`
      ),

      // Infos clés
      C(
        View,
        {},
        C(
          View,
          { style: s.row },
          C(Text, { style: s.label }, "Nature de l'action :"),
          C(Text, { style: s.val }, "Action de formation (article L.6313-1 1°)")
        ),
        C(
          View,
          { style: s.row },
          C(Text, { style: s.label }, "Modalité :"),
          C(Text, { style: s.val }, "Formation à distance (FOAD)")
        ),
        C(
          View,
          { style: s.row },
          C(Text, { style: s.label }, "Début du parcours :"),
          C(Text, { style: s.val }, fmtDate(summary?.first_session))
        ),
        C(
          View,
          { style: s.row },
          C(Text, { style: s.label }, "Dernière activité :"),
          C(Text, { style: s.val }, fmtDate(summary?.last_session))
        )
      ),

      // Durées
      C(
        View,
        { style: s.statsRow },
        C(
          View,
          { style: s.stat },
          C(Text, { style: s.statLabel }, "Durée prévue"),
          C(Text, { style: s.statVal }, `${prevuH} h`)
        ),
        C(
          View,
          { style: s.stat },
          C(Text, { style: s.statLabel }, "Durée réalisée"),
          C(Text, { style: s.statBig }, fmtHours(realisedSec))
        ),
        C(
          View,
          { style: s.stat },
          C(Text, { style: s.statLabel }, "Taux de réalisation"),
          C(Text, { style: s.statVal }, `${pct}%`)
        ),
        C(
          View,
          { style: s.stat },
          C(Text, { style: s.statLabel }, "Leçons suivies"),
          C(Text, { style: s.statVal }, String(summary?.lessons_viewed ?? 0))
        )
      ),

      C(
        Text,
        { style: s.body },
        "Le présent certificat est délivré pour servir et valoir ce que de droit, conformément à l'article L.6353-1 du Code du travail."
      ),

      // Signatures
      C(
        View,
        { style: s.signBox },
        C(
          View,
          { style: s.signBlock },
          C(Text, { style: s.signDate }, `Fait le ${today}`),
          C(Text, { style: s.signLine }, "Date")
        ),
        C(
          View,
          { style: s.signBlock },
          C(Text, { style: s.signDate }, " "),
          C(
            Text,
            { style: s.signLine },
            `Signature et cachet${
              cfg?.organisme_responsable ? " — " + cfg.organisme_responsable : ""
            }`
          )
        )
      ),

      C(
        Text,
        { style: s.footer },
        `${cfg?.organisme_nom || "GOTRM Academy"}${
          cfg?.organisme_siret ? " — SIRET " + cfg.organisme_siret : ""
        }${cfg?.organisme_num_da ? " — DA " + cfg.organisme_num_da : ""}`
      )
    )
  );
}

export async function GET(req: NextRequest) {
  const supabase = createClient();
  const {
    data: { user: authUser },
  } = await supabase.auth.getUser();
  if (!authUser) return NextResponse.json({ error: "unauth" }, { status: 401 });
  const { data: me } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", authUser.id)
    .single();
  if (!isStaff(me?.role))
    return NextResponse.json({ error: "forbidden" }, { status: 403 });

  const userId = req.nextUrl.searchParams.get("user");
  if (!userId) return NextResponse.json({ error: "user requis" }, { status: 400 });

  const [{ data: cfg }, { data: user }, { data: summary }] = await Promise.all([
    supabase.from("formation_settings").select("*").eq("id", true).single(),
    supabase.from("profiles").select("*").eq("id", userId).single(),
    supabase
      .from("user_training_summary")
      .select("*")
      .eq("id", userId)
      .single(),
  ]);

  const today = new Date().toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });

  const buffer = await renderToBuffer(
    Certificat({ cfg, user, summary, today })
  );
  const safe = (user?.full_name || user?.email || "stagiaire")
    .replace(/[^a-z0-9]+/gi, "-")
    .toLowerCase();
  return new NextResponse(buffer as any, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="certificat-realisation-${safe}.pdf"`,
      "Cache-Control": "no-store",
    },
  });
}
