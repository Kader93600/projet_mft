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

// Émargement détaillé par leçon — preuve d'assiduité en FOAD.
// Liste chaque leçon consultée avec horodatage, durée et statut.

const s = StyleSheet.create({
  page: { padding: 36, fontSize: 9, fontFamily: "Helvetica", color: "#0f172a" },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-end",
    marginBottom: 10,
    paddingBottom: 6,
    borderBottomWidth: 2,
    borderBottomColor: "#9FE220",
  },
  brand: { fontSize: 14, fontWeight: "bold", color: "#0E1240" },
  sub: { fontSize: 8, color: "#64748b", marginTop: 2 },
  meta: { fontSize: 7, color: "#64748b" },
  h1: {
    fontSize: 12,
    fontWeight: "bold",
    color: "#0E1240",
    marginTop: 10,
    marginBottom: 6,
  },
  info: {
    marginTop: 2,
    marginBottom: 10,
    padding: 7,
    borderWidth: 1,
    borderColor: "#e2e8f0",
    backgroundColor: "#f8fafc",
    borderRadius: 3,
  },
  iRow: { flexDirection: "row", fontSize: 8.5, marginBottom: 2 },
  iLabel: { width: 90, color: "#64748b" },
  iVal: { flex: 1, color: "#0f172a", fontWeight: "bold" },
  table: {
    borderWidth: 1,
    borderColor: "#e2e8f0",
    borderRadius: 3,
    marginTop: 4,
  },
  tr: {
    flexDirection: "row",
    borderBottomWidth: 1,
    borderBottomColor: "#e2e8f0",
  },
  trLast: { flexDirection: "row" },
  th: {
    padding: 5,
    fontWeight: "bold",
    fontSize: 7.5,
    color: "#475569",
    backgroundColor: "#f1f5f9",
    textTransform: "uppercase",
  },
  td: { padding: 5, fontSize: 8.5 },
  totalRow: {
    flexDirection: "row",
    marginTop: 6,
    padding: 6,
    backgroundColor: "#0E1240",
    borderRadius: 3,
  },
  tLabel: { flex: 1, color: "#fff", fontWeight: "bold", fontSize: 9 },
  tVal: { color: "#9FE220", fontWeight: "bold", fontSize: 9 },
  sign: {
    marginTop: 20,
    flexDirection: "row",
    gap: 16,
  },
  signBox: {
    flex: 1,
    borderTopWidth: 1,
    borderTopColor: "#94a3b8",
    paddingTop: 3,
    fontSize: 7.5,
    color: "#64748b",
    minHeight: 50,
  },
  footer: {
    position: "absolute",
    bottom: 20,
    left: 36,
    right: 36,
    fontSize: 6.5,
    color: "#94a3b8",
    borderTopWidth: 1,
    borderTopColor: "#e2e8f0",
    paddingTop: 4,
    flexDirection: "row",
    justifyContent: "space-between",
  },
});

function fmtDay(d: string | Date) {
  return new Date(d).toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  });
}
function fmtDT(d: string | Date) {
  return new Date(d).toLocaleString("fr-FR", {
    day: "2-digit",
    month: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
}
function fmtDur(sec: number) {
  const h = Math.floor(sec / 3600);
  const m = Math.floor((sec % 3600) / 60);
  if (h > 0) return `${h}h${String(m).padStart(2, "0")}`;
  return `${m} min`;
}

function Emargement({
  cfg,
  user,
  views,
  from,
  to,
  total,
  today,
}: {
  cfg: any;
  user: any;
  views: any[];
  from: string;
  to: string;
  total: number;
  today: string;
}) {
  const C = React.createElement;
  return C(
    Document,
    {},
    C(
      Page,
      { size: "A4", style: s.page },
      C(
        View,
        { style: s.header },
        C(
          View,
          {},
          C(Text, { style: s.brand }, cfg?.organisme_nom || "GOTRM Academy"),
          C(
            Text,
            { style: s.sub },
            "Émargement détaillé — Formation à distance"
          )
        ),
        C(Text, { style: s.meta }, `Édité le ${today}`)
      ),

      // Info stagiaire
      C(
        View,
        { style: s.info },
        C(
          View,
          { style: s.iRow },
          C(Text, { style: s.iLabel }, "Stagiaire :"),
          C(Text, { style: s.iVal }, user?.full_name || user?.email || "—")
        ),
        C(
          View,
          { style: s.iRow },
          C(Text, { style: s.iLabel }, "Formation :"),
          C(
            Text,
            { style: s.iVal },
            `${cfg?.formation_titre || ""} (${cfg?.formation_rncp || ""})`
          )
        ),
        C(
          View,
          { style: s.iRow },
          C(Text, { style: s.iLabel }, "Période :"),
          C(Text, { style: s.iVal }, `Du ${fmtDay(from)} au ${fmtDay(to)}`)
        ),
        C(
          View,
          { style: s.iRow },
          C(Text, { style: s.iLabel }, "Nb leçons :"),
          C(Text, { style: s.iVal }, `${views.length}`)
        )
      ),

      C(Text, { style: s.h1 }, "Détail des activités pédagogiques"),

      C(
        View,
        { style: s.table },
        // Header
        C(
          View,
          { style: s.tr },
          C(Text, { style: [s.th, { width: "12%" }] }, "Date"),
          C(Text, { style: [s.th, { width: "40%" }] }, "Leçon"),
          C(Text, { style: [s.th, { width: "16%" }] }, "Module"),
          C(Text, { style: [s.th, { width: "12%" }] }, "Début"),
          C(Text, { style: [s.th, { width: "10%" }] }, "Durée"),
          C(Text, { style: [s.th, { width: "10%" }] }, "Statut")
        ),
        ...(views.length === 0
          ? [
              C(
                View,
                { style: s.trLast, key: "empty" },
                C(
                  Text,
                  {
                    style: [
                      s.td,
                      { width: "100%", color: "#94a3b8", textAlign: "center" },
                    ],
                  },
                  "Aucune activité sur la période."
                )
              ),
            ]
          : views.map((v: any, i: number) =>
              C(
                View,
                {
                  key: v.id ?? i,
                  style: i === views.length - 1 ? s.trLast : s.tr,
                },
                C(
                  Text,
                  { style: [s.td, { width: "12%" }] },
                  fmtDay(v.started_at)
                ),
                C(
                  Text,
                  { style: [s.td, { width: "40%", fontWeight: "bold" }] },
                  v.lesson_title || "—"
                ),
                C(
                  Text,
                  { style: [s.td, { width: "16%", color: "#64748b" }] },
                  v.module_title || "—"
                ),
                C(Text, { style: [s.td, { width: "12%" }] }, fmtDT(v.started_at)),
                C(
                  Text,
                  { style: [s.td, { width: "10%", fontWeight: "bold" }] },
                  fmtDur(v.duration_s ?? 0)
                ),
                C(
                  Text,
                  {
                    style: [
                      s.td,
                      {
                        width: "10%",
                        color: v.completed ? "#047857" : "#b45309",
                        fontWeight: "bold",
                      },
                    ],
                  },
                  v.completed ? "Validée" : "En cours"
                )
              )
            ))
      ),

      // Total
      C(
        View,
        { style: s.totalRow },
        C(Text, { style: s.tLabel }, "TEMPS PÉDAGOGIQUE CUMULÉ"),
        C(Text, { style: s.tVal }, fmtDur(total))
      ),

      // Signatures
      C(
        View,
        { style: s.sign },
        C(
          Text,
          { style: s.signBox },
          "Signature du stagiaire\n(précédée de la mention « Lu et approuvé »)"
        ),
        C(
          Text,
          { style: s.signBox },
          "Signature et cachet du responsable pédagogique"
        )
      ),

      C(
        View,
        { style: s.footer, fixed: true },
        C(
          Text,
          {},
          `${cfg?.organisme_nom || "GOTRM Academy"} — Émargement détaillé FOAD / Qualiopi`
        ),
        C(Text, {
          render: ({ pageNumber, totalPages }: any) =>
            `${pageNumber} / ${totalPages}`,
        })
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

  const now = new Date();
  const defaultFrom = new Date(now.getTime() - 30 * 86400_000);
  const from =
    req.nextUrl.searchParams.get("from") ??
    defaultFrom.toISOString().slice(0, 10);
  const to = req.nextUrl.searchParams.get("to") ?? now.toISOString().slice(0, 10);

  const [{ data: cfg }, { data: user }, { data: views }] = await Promise.all([
    supabase.from("formation_settings").select("*").eq("id", true).single(),
    supabase.from("profiles").select("*").eq("id", userId).single(),
    supabase
      .from("lesson_views")
      .select(
        "id, started_at, duration_s, completed, lessons(title, modules(title))"
      )
      .eq("user_id", userId)
      .gte("started_at", from + "T00:00:00")
      .lte("started_at", to + "T23:59:59")
      .order("started_at"),
  ]);

  const list = (views ?? []).map((v: any) => ({
    id: v.id,
    started_at: v.started_at,
    duration_s: v.duration_s,
    completed: v.completed,
    lesson_title: v.lessons?.title,
    module_title: v.lessons?.modules?.title,
  }));
  const total = list.reduce((s: number, v: any) => s + (v.duration_s || 0), 0);
  const today = now.toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });

  const buffer = await renderToBuffer(
    Emargement({ cfg, user, views: list, from, to, total, today })
  );
  const safe = (user?.full_name || user?.email || "stagiaire")
    .replace(/[^a-z0-9]+/gi, "-")
    .toLowerCase();
  return new NextResponse(buffer as any, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="emargement-${safe}-${from}-${to}.pdf"`,
      "Cache-Control": "no-store",
    },
  });
}
